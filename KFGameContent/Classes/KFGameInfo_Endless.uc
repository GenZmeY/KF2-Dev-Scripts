//=============================================================================
// KFGameInfo_Endless
//=============================================================================
// Game Info for Endless Game Mode
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFGameInfo_Endless extends KFGameInfo_Survival;

`include(KFGame\KFMatchStats.uci);

var bool bIsInHoePlus;

var KFGameDifficulty_Endless EndlessDifficulty;

var int CurrentFrameBooms;

var array<EAIType> SpecialWaveTypes;
var EAIType SpecialWaveType;
var bool bUseSpecialWave;

/** Which wave should we start rolling for special waves. */
var const int SpecialWaveStart;

/** Which wave should we start rolling for outbreak waves. */
var const int OutbreakWaveStart;

event InitGame( string Options, out string ErrorMessage )
{
	Super.InitGame( Options, ErrorMessage );

	GameLength = 2;
	ResetDifficulty();
}

event PostBeginPlay()
{
	super.PostBeginPlay();

	OutbreakEvent.CacheGRI();
	OutbreakEvent.CacheWorldInfo();
}

function InitSpawnManager()
{
	SpawnManager = new(self) SpawnManagerClasses[0];
	SpawnManager.Initialize();
	WaveMax = INDEX_NONE;
	MyKFGRI.WaveMax = WaveMax;
}

function ResetDifficulty()
{
	if(EndlessDifficulty == none)
	{
		EndlessDifficulty = KFGameDifficulty_Endless(DifficultyInfo);
	}

	if (EndlessDifficulty != none)
	{
		EndlessDifficulty.SetDifficultyScaling(GameDifficulty);
		EndlessDifficulty.CurrentDifficultyScaling.CurrentDifficultyIndex = 0;
		EndlessDifficulty.SetDifficultySettings(0);
	}
}

static function bool GetShouldShowLength()
{
	return false;
}

function WaveStarted()
{
	super.WaveStarted();

	if ((bForceSpecialWave && !bUseSpecialWave) || (bForceOutbreakWave && KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode == INDEX_NONE))
	{
		TrySetNextWaveSpecial();
	}

	if (KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode != INDEX_NONE)
	{
		`log("Starting Outbreak" @ KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode);
		StartOutbreakRound(KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode);
	}
	else if (bUseSpecialWave)
	{
		`log("Starting special wave" @ SpecialWaveType);
	}

	// Put a 1 second delay so it doesn't conflict with the first wave setup.
	SetTimer(1, false, 'WaveStarted', KFGameReplicationInfo_Endless(GameReplicationInfo));
}

function byte GetWaveStartMessage()
{
	local int TempInt;

	if (MyKFGRI.IsSpecialWave(TempInt))
	{
		return GMT_WaveStartSpecial;
	}
	else if (MyKFGRI.IsWeeklyWave(TempInt))
	{
		return GMT_WaveStartWeekly;
	}

	return Super.GetWaveStartMessage();
}

// we don't need special "first wave" dialog in endless
function PlayWaveStartDialog();

function bool TrySetNextWaveSpecial()
{
	local float OutbreakPct, SpecialWavePct;
	local int OutbreakEventIdx;

	if (MyKFGRI.IsBossWave() || MyKFGRI.IsBossWaveNext())
	{
		return false;
	}

	OutbreakPct = EndlessDifficulty.GetOutbreakPctChance();
	SpecialWavePct = EndlessDifficulty.GetSpeicalWavePctChance();
	if (bForceOutbreakWave || (WaveNum >= OutbreakWaveStart && OutbreakPct > 0.f && FRand() < OutbreakPct))
	{
		if(DebugForcedOutbreakIdx == INDEX_NONE)
		{
			OutbreakEventIdx = Rand(OutbreakEvent.SetEvents.length);
		}
		else
		{
			`log("Forcing Outbreak" @ DebugForcedOutbreakIdx);
			OutbreakEventIdx = DebugForcedOutbreakIdx;
		}
		KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode = OutbreakEventIdx;
		bForceOutbreakWave = false;
		DebugForcedOutbreakIdx = INDEX_NONE;
		return true;
	}
	else if (bForceSpecialWave || (WaveNum >= SpecialWaveStart && SpecialWavePct > 0.f && FRand() < SpecialWavePct))
	{
		bUseSpecialWave = true;
		if(DebugForceSpecialWaveZedType == INDEX_NONE)
		{
			SpecialWaveType = EndlessDifficulty.GetSpecialWaveType();
		}
		else
		{
			`log("Forcing Special Wave Type" @ EAIType(DebugForceSpecialWaveZedType));
			SpecialWaveType = EAIType(DebugForceSpecialWaveZedType);
		}
		KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentSpecialMode = SpecialWaveType;
		bForceSpecialWave = false;
		DebugForceSpecialWaveZedType = INDEX_NONE;
		return true;
	}

	bForceOutbreakWave = false;
	bForceSpecialWave = false;

	DebugForcedOutbreakIdx = INDEX_NONE;
	DebugForceSpecialWaveZedType = INDEX_NONE;

	return false;
}

function WaveEnded(EWaveEndCondition WinCondition)
{
	if(!bWaveStarted && !MyKFGRI.bTraderIsOpen && WinCondition != WEC_TeamWipedOut)
	{
		return;
	}

	WaveMax = WaveNum + 2;
	MyKFGRI.WaveMax = WaveMax;

	if(KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode != INDEX_NONE)
	{
		EndOutbreakRound();
	}
	bUseSpecialWave = false;

	KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode = INDEX_NONE;
	KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentSpecialMode = INDEX_NONE;

	HellOnEarthPlusRoundIncrement();

	Super.WaveEnded(WinCondition);

	TrySetNextWaveSpecial();
}

function HellOnEarthPlusRoundIncrement()
{
	if (bIsInHoePlus)
	{
		EndlessDifficulty.IncreaseZedUpgradePct();
		EndlessDifficulty.IncreaseZedFullUpgradePct();
	}
}

function BossDied(Controller Killer, optional bool bCheckWaveEnded = true)
{
	local KFPawn_Monster AIP;
	local KFPlayerController KFPC;

	super.BossDied(Killer, bCheckWaveEnded);

	KFPC = KFPlayerController(Killer);
	`RecordBossMurderer(KFPC);

	foreach WorldInfo.AllPawns(class'KFPawn_Monster', AIP)
	{
		if (AIP.Health > 0)
		{
			AIP.Died(none, none, AIP.Location);
		}
	}

	if (KFAISpawnManager_Endless(SpawnManager) != none)
	{
		KFAISpawnManager_Endless(SpawnManager).OnBossDied();
	}

	IncrementDifficulty();

	SetBossIndex();

	if (bCheckWaveEnded)
	{
		CheckWaveEnd(true);
	}
}

function SetBossIndex()
{
	local int OldBossIndex;
	local BossSpawnReplacement Replacement;
	local int ReplaceIdx;
	local bool bShouldCacheBoss;

	OldBossIndex = BossIndex;
	BossIndex = Rand(default.AIBossClassList.Length);

	bShouldCacheBoss = OldBossIndex != BossIndex;

	if (OutbreakEvent.ActiveEvent.BossSpawnReplacementList.length > 0)
	{
		foreach OutbreakEvent.ActiveEvent.BossSpawnReplacementList(Replacement)
		{
			if (Replacement.SpawnEntry == BossIndex)
			{
				ReplaceIdx = AIBossClassList.Find(Replacement.NewClass);
				if (ReplaceIdx != INDEX_NONE)
				{
					bShouldCacheBoss = true;
					BossIndex = ReplaceIdx;
					break;
				}
			}
		}
	}

	if(bShouldCacheBoss)
	{
		MyKFGRI.CacheSelectedBoss(BossIndex);
	}
}

function IncrementDifficulty()
{
	if (bIsInHoePlus)
	{
		EndlessDifficulty.IncrementHoePlus();

		`log("Incrementing Hell on Earth Plus.");
	}
	else
	{
		if (EndlessDifficulty.ShouldStartHoePlus())
		{
			StartHoePlus();

			`log("Starting Hell on Earth Plus.");
		}
		else
		{
			GameDifficultyModifier = Clamp(GameDifficultyModifier + 1, MinGameDifficulty, MaxGameDifficulty);  //UPDATE DIFFICULTY HERE
			MyKFGRI.SetModifiedGameDifficulty(GameDifficultyModifier); //UPDATE DIFFICULTY HERE

			`log("Increasing Difficulty to" @ GameDifficulty);
		}

		EndlessDifficulty.IncrementDifficulty();
	}

	if (KFAISpawnManager_Endless(SpawnManager) != none)
	{
		KFAISpawnManager_Endless(SpawnManager).OnDifficultyUpdated();
	}

	TimeBetweenWaves = GetTraderTime();

	UpdateGameSettings();
}

function class<KFPawn_Monster> GetAISpawnType(EAIType AIType)
{
	local EAIType OldAIType;
	local string OldAITypeStr, NewAITypeStr;
	local class<KFPawn_Monster> OverrideType;

	if (bUseSpecialWave)
	{
		return super.GetAISpawnType(SpecialWaveType);
	}

	if (ShouldFullyUpgradeAIType())
	{
		OldAIType = AIType;
		AIType = GetFullyUpgradedAIType(AIType);

		OldAITypeStr = SpawnManager.ZedTypeToString(OldAIType);
		NewAITypeStr = SpawnManager.ZedTypeToString(AIType);

		`log("Upgrade" @ OldAITypeStr @ "to" @ NewAITypeStr, SpawnManager.bLogAISpawning);
	}
	else if (ShouldUpgradeAIType())
	{
		OldAIType = AIType;
		AIType = GetUpgradedAIType(AIType);

		OldAITypeStr = SpawnManager.ZedTypeToString(OldAIType);
		NewAITypeStr = SpawnManager.ZedTypeToString(AIType);

		`log("Upgrade" @ OldAITypeStr @ "to" @ NewAITypeStr, SpawnManager.bLogAISpawning);
	}

	if (KFGameReplicationInfo_Endless(GameReplicationInfo).CurrentWeeklyMode != INDEX_NONE && (!MyKFGRI.IsBossWave() || OutbreakEvent.ActiveEvent.bAllowSpawnReplacementDuringBossWave))
	{
		OverrideType = OutbreakEvent.GetAISpawnOverrirde(AIType);
		`log("KFGameInfo_Endless.GetAISpawnType - Force AI Type during Outbreak Event:" @ OverrideType, SpawnManager.bLogAISpawning);
		return OverrideType;
	}

	return Super.GetAISpawnType(AIType);

}

function bool ShouldUpgradeAIType()
{
	local float DieRoll;
	local bool bShouldUpgrade;
	local float UpgradeChance;

	bShouldUpgrade = false;
	if(bIsInHoePlus)
	{
		DieRoll = frand();
		UpgradeChance = EndlessDifficulty.GetZedUpgradePctChance();
		bShouldUpgrade = DieRoll < UpgradeChance;

		`log("Should Upgrade AI Type:" @ bShouldUpgrade, SpawnManager.bLogAISpawning);
		`log("bIsInHoePlus:" @ bIsInHoePlus @ "Upgrade Chance:" @ DieRoll @ "Zed Upgrade Chance:" @ UpgradeChance, SpawnManager.bLogAISpawning);
	}

	return bShouldUpgrade;
}

function bool ShouldFullyUpgradeAIType()
{
	local float DieRoll;
	local bool bShouldUpgrade;
	local float UpgradeChance;

	if(bIsInHoePlus)
	{
		DieRoll = frand();
		UpgradeChance = EndlessDifficulty.GetZedFullUpgradePctChance();
		bShouldUpgrade = bIsInHoePlus && DieRoll < UpgradeChance;

		`log("Should Full Upgrade AI Type:" @ bShouldUpgrade, SpawnManager.bLogAISpawning);
		`log("bIsInHoePlus:" @ bIsInHoePlus @ "Upgrade Chance:" @ DieRoll @ "Zed Upgrade Chance:" @ UpgradeChance, SpawnManager.bLogAISpawning);
	}

	return bShouldUpgrade;
}

function EAIType GetUpgradedAIType(EAIType AIType)
{
	switch (AIType)
	{
	case AT_Clot:
		return AT_AlphaClot;
	case AT_SlasherClot:
		return AT_Stalker;
	case AT_AlphaClot:
		return AT_GoreFast;
	case AT_Crawler:
		return AT_SlasherClot;
	case AT_GoreFast:
		return AT_Bloat;
	case AT_Stalker:
		return AT_Siren;
	case AT_Bloat:
		return AT_FleshpoundMini;
	case AT_Siren:
		return AT_Husk;
	case AT_Husk:
		return AT_Scrake;
	case AT_FleshpoundMini:
		return AT_FleshPound;
	case AT_Scrake:
	case AT_FleshPound:
	default:
		return AIType;
	}
}

function EAIType GetFullyUpgradedAIType(EAIType AIType)
{
	switch (AIType)
	{
	case AT_SlasherClot:
	case AT_Crawler:
	case AT_Stalker:
	case AT_Siren:
	case AT_Husk:
	case AT_Scrake:
		return AT_Scrake;
	case AT_Clot:
	case AT_AlphaClot:
	case AT_GoreFast:
	case AT_Bloat:
	case AT_FleshpoundMini:
	case AT_FleshPound:
		return AT_FleshPound;
	default:
		return AIType;
	}
}

function StartHoePlus()
{
	bIsInHoePlus = true;
	EndlessDifficulty.SetZedUpgradeToBase();
	EndlessDifficulty.SetZedFullUpgradeToBase();
}

function float GetGameInfoSpawnRateMod()
{
	local float AdjustedSpawnRateMod;

	AdjustedSpawnRateMod = super.GetGameInfoSpawnRateMod();

	if (EndlessDifficulty != none && bUseSpecialWave)
	{
		AdjustedSpawnRateMod *= EndlessDifficulty.GetSpecialWaveSpawnRateMod(SpecialWaveType);
	}

	return AdjustedSpawnRateMod;
}

function RestartPlayer(Controller NewPlayer)
{
	local KFPawn_Human KFPH;

	super.RestartPlayer(NewPlayer);

	KFPH = KFPawn_Human(NewPlayer.Pawn);
	OutbreakEvent.AdjustRestartedPlayer(KFPH);
}

function ReduceDamage(out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser, TraceHitInfo HitInfo)
{
	local StatAdjustments ToAdjust;
	local array<StatAdjustments> ZedsToAdjust;
	local KFPawn InstigatorPawn;

	super.ReduceDamage(Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser, HitInfo);

	if (InstigatedBy != none)
	{
		InstigatorPawn = KFPawn(InstigatedBy.Pawn);
	}

	ZedsToAdjust = EndlessDifficulty.GetZedsToAdjust();

	foreach ZedsToAdjust(ToAdjust)
	{
		if (ClassIsChildOf(Injured.class, ToAdjust.ClassToAdjust))
		{
			Damage *= ToAdjust.DamageTakenScale;
		}

		if (InstigatorPawn != none && ClassIsChildOf(InstigatorPawn.class, ToAdjust.ClassToAdjust))
		{
			Damage *= ToAdjust.DamageDealtScale;
		}
	}
}

function StartOutbreakRound(int OutbreakIdx)
{
	OutbreakEvent.SetActiveEvent(OutbreakIdx, self);
	OutbreakEvent.UpdateGRI();
	OutbreakEvent.SetWorldInfoOverrides();

	if (OutbreakEvent.ActiveEvent.GlobalDamageTickRate > 0.f && OutbreakEvent.ActiveEvent.GlobalDamageTickAmount > 0.f)
	{
		SetTimer(OutbreakEvent.ActiveEvent.GlobalDamageTickRate, true, 'ApplyGlobalDamage', OutbreakEvent);
	}
}

function EndOutbreakRound()
{
	local KFPawn KFP;

	OutbreakEvent.ClearActiveEvent();

	foreach WorldInfo.AllPawns(class'KFPawn', KFP)
	{
		KFP.IntendedBodyScale = 1.f;
	}

	if (IsTimerActive('ApplyGlobalDamage', OutbreakEvent))
	{
		ClearTimer('ApplyGlobalDamage', OutbreakEvent);
	}
}

function Tick(float DeltaTime)
{
	CurrentFrameBooms = 0;
	Super.Tick(DeltaTime);
}

function DoDeathExplosion(Pawn DeadPawn, KFGameExplosion ExplosionTemplate, class<KFPawn> ExplosionIgnoreClass)
{
	local KFExplosionActorReplicated ExploActor;

	if (CurrentFrameBooms < OutbreakEvent.ActiveEvent.MaxBoomsPerFrame)
	{
		ExploActor = Spawn(class'KFExplosionActorReplicated', DeadPawn, , DeadPawn.Location);
		if (ExploActor != none)
		{
			ExploActor.InstigatorController = DeadPawn.Controller;
			ExploActor.Instigator = DeadPawn;
			ExploActor.Attachee = DeadPawn;
			ExplosionTemplate.ActorClassToIgnoreForDamage = ExplosionIgnoreClass;
			ExploActor.Explode(ExplosionTemplate, vect(0, 0, 1));
			++CurrentFrameBooms;
		}
	}
}

function bool ShouldOverrideDoshOnKill(class<KFPawn_Monster> KilledPawn, out float DoshGiven)
{
	local StatAdjustments ToAdjust;
	local array<StatAdjustments> ZedsToAdjust;

	ZedsToAdjust = EndlessDifficulty.GetZedsToAdjust();

	foreach ZedsToAdjust(ToAdjust)
	{
		if (ToAdjust.ClassToAdjust == KilledPawn && ToAdjust.DoshGiven != INDEX_NONE)
		{
			DoshGiven = ToAdjust.DoshGiven;
			return true;
		}
	}

	return false;
}

exec function SetWave(byte NewWaveNum)
{
	local int CurrRound;

	if (!AllowWaveCheats())
	{
		return;
	}

	// Stop Wave
	GotoState('DebugSuspendWave');
	WaveNum = NewWaveNum - 1;
	MyKFGRI.WaveNum = WaveNum;
	bIsInHoePlus = false;

	// Reset Endless Stats to round 1.
	ResetDifficulty();
	SpawnManager.GetWaveSettings(SpawnManager.WaveSettings);
	UpdateGameSettings();

	// Apply Endless Stats round by round to ensure all numbers are correct.
	for (CurrRound = 0; CurrRound < WaveNum; CurrRound++)
	{
		if (CurrRound > 0 && (CurrRound % 5) == 0)
		{
			IncrementDifficulty();
		}

		HellOnEarthPlusRoundIncrement();
	}

	ResetAllPickups();

	// Restart Wave
	GotoState('PlayingWave');
}

function int CalculateMinimumRespawnDosh(float UsedMaxRespawnDosh)
{
	return Round(UsedMaxRespawnDosh * Min(1.f, (float(WaveNum) / 10.f)));
}

function float GetTotalWaveCountScale()
{
	local float WaveScale;

	if ((bForceSpecialWave && !bUseSpecialWave))
	{
		TrySetNextWaveSpecial();
	}

	WaveScale = super.GetTotalWaveCountScale();
	if (bUseSpecialWave)
	{
		WaveScale *= EndlessDifficulty.GetSpecialWaveScale(SpecialWaveType);
	}

	return WaveScale;
}

static function bool HasCustomTraderVoiceGroup()
{
	return true;
}

function SetMonsterDefaults(KFPawn_Monster P)
{
	local KFAIController KFAIC;

	if (bUseSpecialWave && EndlessDifficulty.ShouldSpawnEnraged(SpecialWaveType))
	{
		KFAIC = KFAIController(P.Controller);
		if(KFAIC != none)
		{
			KFAIC.SetSprintingDisabled(false);
			KFAIC.SetCanSprint(true);
			KFAIC.SetCanSprintWhenDamaged(true);
		}

		if(P != none)
		{
			P.SetEnraged(true);
			P.SetSprinting(true);
		}
	}

	super.SetMonsterDefaults(P);
}

// Save player's stats on leave
function UnregisterPlayer(PlayerController PC)
{
	super.UnregisterPlayer(PC);

	if (GetNumPlayers() == 0 && MyKFGRI.bIsEndlessPaused)
	{
		ResumeEndlessGame();
	}
}

defaultproperties
{
	bIsEndlessGame = true
	bIsInHoePlus=false

	SpawnManagerClasses(0)=class'KFGameContent.KFAISpawnManager_Endless'

	GameReplicationInfoClass=class'KFGameContent.KFGameReplicationInfo_Endless'

	OutbreakEventClass=class'KFOutbreakEvent_Endless'

	TraderVoiceGroupClass=class'KFGameContent.KFTraderVoiceGroup_Patriarch' //plays patty VO for trader

	DifficultyInfoClass = class'KFGameDifficulty_Endless'
	DifficultyInfoConsoleClass = class'KFGameDifficulty_Endless_Console'

	SpecialWaveStart=6
	OutbreakWaveStart=6

	SpecialWaveTypes(0)=AT_Clot
	SpecialWaveTypes(1)=AT_SlasherClot
	SpecialWaveTypes(2)=AT_Crawler
	SpecialWaveTypes(3)=AT_Stalker
	SpecialWaveTypes(4)=AT_Siren
	SpecialWaveTypes(5)=AT_Husk
	SpecialWaveTypes(6)=AT_Scrake
	SpecialWaveTypes(7)=AT_AlphaClot
	SpecialWaveTypes(8)=AT_GoreFast
	SpecialWaveTypes(9)=AT_Bloat
	SpecialWaveTypes(10)=AT_FleshPound

	bSplitBossDoshReward=false
}
