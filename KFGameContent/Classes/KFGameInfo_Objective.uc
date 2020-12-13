//=============================================================================
// KFGameInfo_Objective
//=============================================================================
// Game type with a variable number of objective-based waves
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFGameInfo_Objective extends KFGameInfo_Survival;

var KFMapInfo MyKFMI;

 /* Initialize the game.
 The GameInfo's InitGame() function is called before any other scripts (including
 PreBeginPlay() ), and is used by the GameInfo to initialize parameters and spawn
 its helper classes.
 Warning: this is called before actors' PreBeginPlay.
*/
event InitGame(string Options, out string ErrorMessage)
{
 	Super.InitGame(Options, ErrorMessage);

	// Force objective mode to default to "long" game logic (particularly spawnmanager)
	// We will override a lot of stuff elsewhere, anyway
	GameLength = GL_Long;
}

static function bool GametypeChecksWaveLength()
{
	return false;
}

event PreBeginPlay()
{
	// Intentionally set before super so it can be used by super
	MyKFMI = KFMapInfo(WorldInfo.GetMapInfo());

	super.PreBeginPlay();
}

/** Set up the spawning */
function InitSpawnManager()
{
	SpawnManager = new(self) SpawnManagerClasses[GameLength];
	SpawnManager.Initialize();

	WaveMax = MyKFMI.ObjectiveModeObjectives.Length;
	MyKFGRI.WaveMax = WaveMax;
}

//Find and preload content for the chosen boss index
function SetBossIndex()
{
	if (MyKFGRI.IsBossWave())
	{
		if (KFMapObjective_ExterminateWave(MyKFGRI.CurrentObjective).bRandomBoss)
		{
			BossIndex = Rand(BAT_MAX);
		}
		else
		{
			BossIndex = KFMapObjective_ExterminateWave(MyKFGRI.CurrentObjective).BossType;
		}
		
		MyKFGRI.CacheSelectedBoss(BossIndex);
	}
	else if (BossIndex == -1)
	{
		super.SetBossIndex();
	}
}

/** Custom logic to determine what the game's current intensity is */
function byte GetGameIntensityForMusic()
{
	local int AppliedWaveNum;

	AppliedWaveNum = MyKFMI.GetAppliedWaveNum();

	// use normal game logic
	if (AppliedWaveNum <= 1)
		return 1;
	else if (AppliedWaveNum <= 3)
		return 4;
	else if (AppliedWaveNum <= 5)
		return 7;
	else
		return 10;
}

/** @TODO: update logic */
function int CalculateLateJoinerStartingDosh(int MinimumRespawnDosh)
{
	if (default.LateArrivalStarts.Length > 0 && GameLength >= 0 && GameLength < default.LateArrivalStarts.Length)
	{
		if (default.LateArrivalStarts[GameLength].StartingDosh.Length > 0 && WaveNum - 1 >= 0 && WaveNum - 1 < default.LateArrivalStarts[GameLength].StartingDosh.Length)
		{
			`log("SCORING: Late joiner received" @ LateArrivalStarts[GameLength].StartingDosh[WaveNum - 1]);
			return default.LateArrivalStarts[GameLength].StartingDosh[WaveNum - 1];
		}
	}

	`log("SCORING: Late joiner - invalid parameters to properly award late joiner dosh. Will instead receive Minimum Respawn Dosh of" @ MinimumRespawnDosh, bLogScoring);
	return MinimumRespawnDosh;
}

function SetupNextWave(int WaveBuffer)
{
	if (MyKFGRI.IsBossWave())
	{
		SpawnManager.SetupNextWave(10, WaveBuffer);
	}
	else
	{
		SpawnManager.SetupNextWave(MyKFMI.GetAppliedWaveNum(), WaveBuffer);
	}
}

/** Allow specific map to override the spawn class.  Default implementation returns from the AI class list. */
function class<KFPawn_Monster> GetAISpawnType(EAIType AIType)
{
	local array<SpawnReplacement> SpawnReplacements;
	local int i;

	if (MyKFMI != none)
	{
		SpawnReplacements = MyKFMI.ObjectiveModeObjectives[WaveNum-1].SpawnReplacements;
		if (SpawnReplacements.Length > 0)
		{
			for (i = 0; i < SpawnReplacements.Length; ++i)
			{
				if (SpawnReplacements[i].SpawnEntry == AIType && FRand() < SpawnReplacements[i].PercentChance)
				{
					if (SpawnReplacements[i].NewClass.Length > 0)
					{
						return SpawnReplacements[i].NewClass[Rand(SpawnReplacements[i].NewClass.Length)];
					}
				}
			}
		}
	}

    return AIClassList[AIType];
}

/** Scale to use against WaveTotalAI to determine full wave size */
function float GetTotalWaveCountScale()
{
	local float WaveScale;

	WaveScale = super.GetTotalWaveCountScale();
	if (MyKFMI != none)
	{
		WaveScale *= MyKFMI.ObjectiveModeObjectives[WaveNum-1].WaveScale;
	}

	return WaveScale;
}

/** Allow specific game types to modify the spawn rate at a global level */
function float GetGameInfoSpawnRateMod()
{
	local float SpawnRateMod;
	local KFGameReplicationInfo KFGRI;
	local int NumPlayersAlive;

	SpawnRateMod = super.GetGameInfoSpawnRateMod();

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if (KFGRI == none)
	{
		return SpawnRateMod;
	}

	if (MyKFMI == none)
	{
		return SpawnRateMod;
	}

	NumPlayersAlive =
		Clamp(KFGRI.GetNumPlayersAlive(), 1, MyKFMI.ObjectiveModeObjectives[WaveNum-1].PerPlayerSpawnRateMod.Length) - 1;
	SpawnRateMod *= MyKFMI.ObjectiveModeObjectives[WaveNum-1].PerPlayerSpawnRateMod[NumPlayersAlive];

	return SpawnRateMod;
}

function NotifyTakeHit(KFPawn Pawn, Controller InstigatedBy, vector HitLocation, int Damage,
	class<DamageType> DamageType, vector Momentum, Actor DamageCauser)
{
	local KFPawn_Monster KFPM;
	local KFMapObjective_ExterminateWave ExterminateObj;

	super.NotifyTakeHit(Pawn, InstigatedBy, HitLocation, Damage, DamageType, Momentum, DamageCauser);

	KFPM = KFPawn_Monster(Pawn);
	if (KFPM != none && KFPM.IsABoss())
	{
		ExterminateObj = KFMapObjective_ExterminateWave(MyKFGRI.CurrentObjective);
		if(ExterminateObj != none)
		{
			ExterminateObj.NotifyBossDamaged(KFPM, Damage);
		}
	}
}

/** @TODO: update logic */
function EndOfMatch(bool bVictory)
{
	local KFPlayerController KFPC;

	`AnalyticsLog(("match_end", None, "#"$WaveNum, "#"$(bVictory ? "1" : "0"), "#"$GameConductor.ZedVisibleAverageLifespan));

	if(bVictory)
	{
		SetTimer(EndCinematicDelay, false, nameof(SetWonGameCamera));

		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			KFPC.ClientWonGame( WorldInfo.GetMapName( true ), GameDifficulty, GameLength,	IsMultiplayerGame() );
		}

		BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_MatchWon);
	}
	else
	{
		BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_MatchLost);
		SetZedsToVictoryState();
	}

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		KFPC.ClientGameOver( WorldInfo.GetMapName(true), GameDifficulty, GameLength, IsMultiplayerGame(), WaveNum );
	}

	GotoState('MatchEnded');
}

/**
 * @brief Adjusts the dosh you get based on difficulty and player count
 *
 * @param MonsterClass pawn class of thge killed zed
 * @return Adjusted dosh amount
 */
/** @TODO: update logic */
function float GetAdjustedAIDoshValue( class<KFPawn_Monster> MonsterClass )
{
	local float TempValue;

	if(!ShouldOverrideDoshOnKill(MonsterClass, TempValue))
	{
		TempValue = MonsterClass.static.GetDoshValue();
	}
	TempValue *= DifficultyInfo.GetKillCashModifier();
	ModifyAIDoshValueForPlayerCount( TempValue );
	TempValue *= GameLengthDoshScale[GameLength];

	KFMapInfo(WorldInfo.GetMapInfo()).ModifyAIDoshValue(TempValue);

	if (MyKFGRI.CurrentObjective != none)
	{
		TempValue *= KFInterface_MapObjective(MyKFGRI.CurrentObjective).GetDoshValueModifier();
	}

	return TempValue;
}

function StartWave()
{
	// check whether the wave should automatically start
	if(MyKFMI != none && MyKFMI.ObjectiveModeObjectives[WaveNum].bShouldAutoStartWave)
	{
		super.StartWave();
	}
	// don't start a wave at the normal time, wait for the kismet action to kick it off (SeqActStartWave())
	else
	{
		// still want to try to close the trader at this time
		if (MyKFGRI.OpenedTrader != none)
		{
			MyKFGRI.CloseTrader();
			NotifyTraderClosed();
		}
	}
}

simulated function SeqActStartWave()
{
	// if the game is in a PlayingWave state waiting for this input to kick off a new wave
	if (IsInState('PlayingWave') && MYKFGRI != none)
	{
		// and doesn't already have an active objective
		if (MyKFGRI.CurrentObjective == none || !KFInterface_MapObjective(MyKFGRI.CurrentObjective).IsActive())
		{
			super.StartWave();
		}
	}
}

defaultproperties
{
	GameReplicationInfoClass=class'KFGameContent.KFGameReplicationInfo_Objective'

	DifficultyInfoClass=class'KFGameDifficulty_Objective'
	DifficultyInfoConsoleClass=class'KFGameDifficulty_Objective_Console'

	TraderVoiceGroupClass=class'KFGameContent.KFTraderVoiceGroup_Objective'
}