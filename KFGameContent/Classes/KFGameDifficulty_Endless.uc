//=============================================================================
// KFGameDifficulty_Endless
//=============================================================================
// Manages difficulty based gameplay settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFGameDifficulty_Endless extends KFGameDifficultyInfo;

struct ZedAdjustments
{
	// How each Zed type will be adjusted.
	var() array<StatAdjustments> ZedsToAdjust;
};

struct SpecialWaveInfo
{
	var() EAIType ZedType;
	var() float PctChance;
	var() float WaveScale;
	var() float SpawnRateMultiplier;
	var() bool bSpawnEnraged;
	var() float NextSpawnTimeModMin;

	structdefaultproperties
	{
		WaveScale=1.f
		PctChance=0.f
		SpawnRateMultiplier=1.f
		NextSpawnTimeModMin=0.f
	}
};

struct SpecialWaveDifficultyInfo
{
	var() array<SpecialWaveInfo> SpecialWaveInfos;

	structdefaultproperties
	{
		SpecialWaveInfos[0]=(ZedType=AT_Clot, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.0f),
		SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f),
		SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=1.f, NextSpawnTimeModMin=0.25f)
	}
};

struct ZedDifficultyOverride
{
	var() class<KFPawn_Monster> ClassToAdjust;
	/** The individual health modifier for this zed type */
	var() float HealthMod;
	/** A per zed damage mod configurable by difficulty */
	var() float DamageMod;
	/** A per zed damage mod configurable by difficulty when playing solo/offline */
	var() float SoloDamageMod;

	structdefaultproperties
	{
		HealthMod = 1.f,
		DamageMod = 1.f,
		SoloDamageMod = 1.f
	}
};

struct DifficultyOverride
{
	var() array<ZedDifficultyOverride> ZedsOverride;
};

/** How the difficulty will scale each difficulty increase based on the starting difficulty. */
struct DifficultyScaling
{
	// The difficulty settings for each difficulty.
	var() array<DifficultySettings> Difficulties;

	// When we get into Hell on Earth plus rounds, how will difficulty settings adjust
	var() DifficultySettings DifficultyIncrement;

	// Which difficulty we're currently on
	var() int CurrentDifficultyIndex;

	// The starting probability that a zed will upgrade to the next class
	var() const float BaseUpgradeZedPctChance;

	// Amount that the zed upgrade percent chance will increase each round.
	var() const float IncreaseUpgradeZedPctChance;

	// The probability that a zed will upgrade to the next class.
	var() float UpgradeZedPctChance;

	// Starting probability that a zed will fully upgrade to the final class
	var() const float BaseFullUpgradeZedPctChance;

	// Amount that the zed full upgrade will increase each round
	var() const float IncreaseFullUpgradeZedPctChance;

	// The probability that a zed will fully upgrade to the final class.
	var() float FullUpgradeZedPctChance;

	// How each Stat Adjustment will vary by current difficulty.
	var() array<ZedAdjustments> ZedAdjustmentsByDifficulty;

	// How the Hell on Earth Stat Adjustment will adjust past each boss fight.
	var() StatAdjustments ZedAdjustmentIncrement;

	// The probability that the wave will be an outbreak
	var() array<float> OutbreakPctChances;

	// The probability that the wave will be a special wave.
	var() array<float> SpecialWavePctChance;

	// If we're in a special wave, then what is the probability of a certain zed type being chosen
	var() array<SpecialWaveDifficultyInfo> DifficultySpecialWaveTypes;

	// If a Zed Difficulty Setting needs to be overriden.
	var() array<DifficultyOverride> ZedDiffOverride;

	structdefaultproperties
	{
		BaseUpgradeZedPctChance=.01f,
		IncreaseUpgradeZedPctChance=.01f,
		UpgradeZedPctChance=0.f,

		BaseFullUpgradeZedPctChance=0.001f,
		IncreaseFullUpgradeZedPctChance=0.001f,
		FullUpgradeZedPctChance=0.f
	}
};

var DifficultyScaling CurrentDifficultyScaling;
var() array<DifficultyScaling> DifficultyScalings;

function IncrementHoePlus()
{
	local int DifficultyIndex;
	DifficultyIndex = CurrentDifficultyScaling.CurrentDifficultyIndex;

	if (DifficultyIndex < 0 || DifficultyIndex >= CurrentDifficultyScaling.Difficulties.length)
	{
		return;
	}

	AdjustDifficulties(DifficultyIndex);
	AdjustZedStats(DifficultyIndex);

	SetDifficultySettings(CurrentDifficultyScaling.CurrentDifficultyIndex);
}

function AdjustDifficulties(int DifficultyIndex)
{
	if (DifficultyIndex < 0 || DifficultyIndex >= CurrentDifficultyScaling.Difficulties.length)
	{
		return;
	}

	CurrentDifficultyScaling.Difficulties[DifficultyIndex].TraderTime += CurrentDifficultyScaling.DifficultyIncrement.TraderTime;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].GlobalHealthMod += CurrentDifficultyScaling.DifficultyIncrement.GlobalHealthMod;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].MovementSpeedMod += CurrentDifficultyScaling.DifficultyIncrement.MovementSpeedMod;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].WaveCountMod += CurrentDifficultyScaling.DifficultyIncrement.WaveCountMod;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].DoshKillMod += CurrentDifficultyScaling.DifficultyIncrement.DoshKillMod;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].StartingDosh += CurrentDifficultyScaling.DifficultyIncrement.StartingDosh;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].RespawnDosh += CurrentDifficultyScaling.DifficultyIncrement.RespawnDosh;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].AmmoPickupsMod += CurrentDifficultyScaling.DifficultyIncrement.AmmoPickupsMod;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].ItemPickupsMod += CurrentDifficultyScaling.DifficultyIncrement.ItemPickupsMod;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].WeakAttackChance += CurrentDifficultyScaling.DifficultyIncrement.WeakAttackChance;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].MediumAttackChance += CurrentDifficultyScaling.DifficultyIncrement.MediumAttackChance;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].HardAttackChance += CurrentDifficultyScaling.DifficultyIncrement.HardAttackChance;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].SelfInflictedDamageMod += CurrentDifficultyScaling.DifficultyIncrement.SelfInflictedDamageMod;
	CurrentDifficultyScaling.Difficulties[DifficultyIndex].SpawnRateModifier += CurrentDifficultyScaling.DifficultyIncrement.SpawnRateModifier;
}

function AdjustZedStats(int DifficultyIndex)
{
	local int i;

	if (DifficultyIndex < 0 || DifficultyIndex >= CurrentDifficultyScaling.ZedAdjustmentsByDifficulty.length)
	{
		return;
	}

	for (i = 0; i < CurrentDifficultyScaling.ZedAdjustmentsByDifficulty[DifficultyIndex].ZedsToAdjust.length; i++)
	{
		CurrentDifficultyScaling.ZedAdjustmentsByDifficulty[DifficultyIndex].ZedsToAdjust[i].HealthScale += CurrentDifficultyScaling.ZedAdjustmentIncrement.HealthScale;
		CurrentDifficultyScaling.ZedAdjustmentsByDifficulty[DifficultyIndex].ZedsToAdjust[i].HeadHealthScale += CurrentDifficultyScaling.ZedAdjustmentIncrement.HeadHealthScale;
		CurrentDifficultyScaling.ZedAdjustmentsByDifficulty[DifficultyIndex].ZedsToAdjust[i].ShieldScale += CurrentDifficultyScaling.ZedAdjustmentIncrement.ShieldScale;
		CurrentDifficultyScaling.ZedAdjustmentsByDifficulty[DifficultyIndex].ZedsToAdjust[i].DamageDealtScale += CurrentDifficultyScaling.ZedAdjustmentIncrement.DamageDealtScale;
		CurrentDifficultyScaling.ZedAdjustmentsByDifficulty[DifficultyIndex].ZedsToAdjust[i].DamageTakenScale += CurrentDifficultyScaling.ZedAdjustmentIncrement.DamageTakenScale;
	}
}

function IncrementDifficulty()
{
	CurrentDifficultyScaling.CurrentDifficultyIndex = Clamp(CurrentDifficultyScaling.CurrentDifficultyIndex + 1, 0, CurrentDifficultyScaling.Difficulties.length - 1);
	`log("Incrementing Difficulty Index to" @ CurrentDifficultyScaling.CurrentDifficultyIndex);
	SetDifficultySettings(CurrentDifficultyScaling.CurrentDifficultyIndex);
}

function SetDifficultySettings(float GameDifficulty)
{
	local int DiffSettingIndex;

	if(CurrentDifficultyScaling.Difficulties.length > 0)
	{
		DiffSettingIndex = Clamp(GameDifficulty, 0, CurrentDifficultyScaling.Difficulties.length - 1);
		`log("Setting Difficulty Settings to" @ DiffSettingIndex);
		CurrentSettings = CurrentDifficultyScaling.Difficulties[DiffSettingIndex];
	}
}

function SetDifficultyScaling(float StartingGameDifficulty)
{
	local int DiffScalingIndex;

	if(DifficultyScalings.length > 0)
	{
		DiffScalingIndex = Min(StartingGameDifficulty, DifficultyScalings.length - 1);
		`log("Setting Difficulty Scalings to" @ DiffScalingIndex);
		CurrentDifficultyScaling = DifficultyScalings[DiffScalingIndex];
	}
}

function float GetZedUpgradePctChance()
{
	return CurrentDifficultyScaling.UpgradeZedPctChance;
}

function float GetZedFullUpgradePctChance()
{
	return CurrentDifficultyScaling.FullUpgradeZedPctChance;
}

function IncreaseZedUpgradePct()
{
	CurrentDifficultyScaling.UpgradeZedPctChance = FClamp(CurrentDifficultyScaling.UpgradeZedPctChance + CurrentDifficultyScaling.IncreaseUpgradeZedPctChance, 0.f, 1.f);
}

function IncreaseZedFullUpgradePct()
{
	CurrentDifficultyScaling.FullUpgradeZedPctChance = FClamp(CurrentDifficultyScaling.FullUpgradeZedPctChance + CurrentDifficultyScaling.IncreaseFullUpgradeZedPctChance, 0.f, 1.f);
}

function SetZedUpgradeToBase()
{
	CurrentDifficultyScaling.UpgradeZedPctChance = CurrentDifficultyScaling.BaseUpgradeZedPctChance;
}

function SetZedFullUpgradeToBase()
{
	CurrentDifficultyScaling.FullUpgradeZedPctChance = CurrentDifficultyScaling.BaseFullUpgradeZedPctChance;
}

function bool ShouldStartHoePlus()
{
	return CurrentDifficultyScaling.CurrentDifficultyIndex + 1 >= CurrentDifficultyScaling.Difficulties.length - 1;
}

function array<StatAdjustments> GetZedsToAdjust()
{
	return CurrentDifficultyScaling.ZedAdjustmentsByDifficulty[CurrentDifficultyScaling.CurrentDifficultyIndex].ZedsToAdjust;
}

function array<ZedDifficultyOverride> GetZedsOverride()
{
	return CurrentDifficultyScaling.ZedDiffOverride[CurrentDifficultyScaling.CurrentDifficultyIndex].ZedsOverride;
}

function float GetOutbreakPctChance()
{
	if(CurrentDifficultyScaling.OutbreakPctChances.length > 0)
	{
		return CurrentDifficultyScaling.OutbreakPctChances[Min(CurrentDifficultyScaling.CurrentDifficultyIndex, CurrentDifficultyScaling.OutbreakPctChances.length - 1)];
	}
	return 0.f;
}

function float GetSpeicalWavePctChance()
{
	if(CurrentDifficultyScaling.SpecialWavePctChance.length > 0)
	{
		return CurrentDifficultyScaling.SpecialWavePctChance[Min(CurrentDifficultyScaling.CurrentDifficultyIndex, CurrentDifficultyScaling.SpecialWavePctChance.length - 1)];
	}
	return 0.f;
}

function EAIType GetSpecialWaveType()
{
	local array<SpecialWaveInfo> SpecialWaves;
	local float RandF;
	local float TotalProb;
	local SpecialWaveInfo It;

	SpecialWaves = CurrentDifficultyScaling.DifficultySpecialWaveTypes[CurrentDifficultyScaling.CurrentDifficultyIndex].SpecialWaveInfos;
	RandF = FRand();

	if (SpecialWaves.length == 0)
	{
		return AT_Clot;
	}

	foreach SpecialWaves(It)
	{
		TotalProb += It.PctChance;
		if (It.PctChance > 0 && RandF < TotalProb)
		{
			return It.ZedType;
		}
	}

	return SpecialWaves[RandRange(0, SpecialWaves.length - 1)].ZedType;
}

function bool GetSpecialWaveModifiers(EAIType AIType, out float WaveCountMod, out float SpawnRateMod)
{
	local array<SpecialWaveInfo> SpecialWaves;
	local SpecialWaveInfo It;

	SpecialWaves = CurrentDifficultyScaling.DifficultySpecialWaveTypes[CurrentDifficultyScaling.CurrentDifficultyIndex].SpecialWaveInfos;

	WaveCountMod = 1.f;
	SpawnRateMod = 1.f;

	foreach SpecialWaves(It)
	{
		if (It.ZedType == AIType)
		{
			WaveCountMod = It.WaveScale;
			SpawnRateMod = 1.f / It.SpawnRateMultiplier;
			return true;
		}
	}

	return false;
}

function float GetSpecialWaveScale(EAIType AIType)
{
	local array<SpecialWaveInfo> SpecialWaves;
	local SpecialWaveInfo It;

	SpecialWaves = CurrentDifficultyScaling.DifficultySpecialWaveTypes[CurrentDifficultyScaling.CurrentDifficultyIndex].SpecialWaveInfos;

	`log(self @ "-" @ GetFuncName() @ "- AIType:" @ AIType);

	foreach SpecialWaves(It)
	{
		`log(self @ "-" @ GetFuncName() @ "- It.ZedType:" @ It.ZedType);
		if (It.ZedType == AIType)
		{
			`log(self @ "-" @ GetFuncName() @ "- Wave Scale:" @ It.WaveScale);
			return It.WaveScale;
		}
	}

	return 1.f;
}

function float GetSpecialWaveSpawnRateMod(EAIType AIType)
{
	local array<SpecialWaveInfo> SpecialWaves;
	local SpecialWaveInfo It;

	SpecialWaves = CurrentDifficultyScaling.DifficultySpecialWaveTypes[CurrentDifficultyScaling.CurrentDifficultyIndex].SpecialWaveInfos;

	foreach SpecialWaves(It)
	{
		if (It.ZedType == AIType)
		{
			return 1.f / It.SpawnRateMultiplier;
		}
	}

	return 1.f;
}

function float GetSpecialWaveSpawnTimeModMin(EAIType AIType)
{
	local array<SpecialWaveInfo> SpecialWaves;
	local SpecialWaveInfo It;

	SpecialWaves = CurrentDifficultyScaling.DifficultySpecialWaveTypes[CurrentDifficultyScaling.CurrentDifficultyIndex].SpecialWaveInfos;

	foreach SpecialWaves(It)
	{
		if (It.ZedType == AIType)
		{
			return It.NextSpawnTimeModMin;
		}
	}

	return 0.f;
}

function float GetAIDamageModifier(KFPawn_Monster P, float GameDifficulty, bool bSoloPlay)
{
	local float PerZedDamageMod, SoloPlayDamageMod;
	local array<ZedDifficultyOverride> ZedsToAdjust;
	local ZedDifficultyOverride ZedDifficulty;
	local bool bFoundOverride;

	// default if no InMonsterInfo
	PerZedDamageMod = 1.0;
	SoloPlayDamageMod = 1.0;
	bFoundOverride = false;

	ZedsToAdjust = GetZedsOverride();

	foreach ZedsToAdjust(ZedDifficulty)
	{
		if (ZedDifficulty.ClassToAdjust != P.class)
		{
			continue;
		}

		PerZedDamageMod = ZedDifficulty.DamageMod;
		if (bSoloPlay)
		{
			SoloPlayDamageMod = ZedDifficulty.SoloDamageMod;
		}
		bFoundOverride = true;
		break;
	}

	if (bFoundOverride)
	{
		return PerZedDamageMod * SoloPlayDamageMod;
	}
	else
	{
		return super.GetAIDamageModifier(P, Clamp(GetCurrentDifficultyIndex(), 0, 3), bSoloPlay);
	}
}

function GetAIHealthModifier(KFPawn_Monster P, float GameDifficulty, byte NumLivingPlayers, out float HealthMod, out float HeadHealthMod, optional bool bApplyDifficultyScaling = true)
{
	local array<StatAdjustments> ZedsToAdjust;
	local StatAdjustments ZedAdjustment;

	// Clamp Difficulty Index to normal difficulty range in case we're in Hell on Earth+.
	super.GetAIHealthModifier(P, Clamp(GetCurrentDifficultyIndex(), 0, 3), NumLivingPlayers, HealthMod, HeadHealthMod, bApplyDifficultyScaling);

	ZedsToAdjust = GetZedsToAdjust();

	foreach ZedsToAdjust(ZedAdjustment)
	{
		if (ZedAdjustment.ClassToAdjust == P.class)
		{
			HealthMod *= ZedAdjustment.HealthScale;
			HeadHealthMod *= ZedAdjustment.HeadHealthScale;
		}
	}
}

function float GetCharHealthModDifficulty(KFPawn_Monster P, float GameDifficulty)
{
	local array<ZedDifficultyOverride> ZedsToAdjust;
	local ZedDifficultyOverride ZedDifficulty;

	ZedsToAdjust = GetZedsOverride();

	foreach ZedsToAdjust(ZedDifficulty)
	{
		if (ZedDifficulty.ClassToAdjust == P.class)
		{
			return ZedDifficulty.HealthMod;
		}
	}

	// Clamp Difficulty Index to normal difficulty range in case we're in Hell on Earth+.
	return super.GetCharHealthModDifficulty(P, Clamp(GetCurrentDifficultyIndex(), 0, 3));
}

function float GetCharHeadHealthModDifficulty(KFPawn_Monster P, float GameDifficulty)
{
	// Clamp Difficulty Index to normal difficulty range in case we're in Hell on Earth+.
	return super.GetCharHeadHealthModDifficulty(P, Clamp(GetCurrentDifficultyIndex(), 0, 3));
}

function float GetCharSprintChanceByDifficulty(KFPawn_Monster P, float GameDifficulty)
{
	local KFGameInfo_Endless KFGI;

	KFGI = KFGameInfo_Endless(P.WorldInfo.Game);
	if (KFGI != none && KFGI.bUseSpecialWave && ShouldSpawnEnraged(KFGI.SpecialWaveType))
	{
		return 1.f;
	}

	// Clamp Difficulty Index to normal difficulty range in case we're in Hell on Earth+.
	return super.GetCharSprintChanceByDifficulty(P, Clamp(GetCurrentDifficultyIndex(), 0, 3));
}

function float GetCharSprintWhenDamagedChanceByDifficulty(KFPawn_Monster P, float GameDifficulty)
{
	local KFGameInfo_Endless KFGI;

	KFGI = KFGameInfo_Endless(P.WorldInfo.Game);
	if (KFGI != none && KFGI.bUseSpecialWave && ShouldSpawnEnraged(KFGI.SpecialWaveType))
	{
		return 1.f;
	}

	// Clamp Difficulty Index to normal difficulty range in case we're in Hell on Earth+.
	return super.GetCharSprintWhenDamagedChanceByDifficulty(P, Clamp(GetCurrentDifficultyIndex(), 0, 3));
}

function int GetCurrentDifficultyIndex()
{
	return CurrentDifficultyScaling.CurrentDifficultyIndex;
}

function bool ShouldSpawnEnraged(EAIType AIType)
{
	local array<SpecialWaveInfo> CurrentSpecialWave;
	local SpecialWaveInfo CurrentWaveInfo;

	CurrentSpecialWave = CurrentDifficultyScaling.DifficultySpecialWaveTypes[CurrentDifficultyScaling.CurrentDifficultyIndex].SpecialWaveInfos;
	foreach CurrentSpecialWave(CurrentWaveInfo)
	{
		if (CurrentWaveInfo.ZedType == AIType)
		{
			return CurrentWaveInfo.bSpawnEnraged;
		}
	}

	return false;
}

defaultproperties
{
	//NORMAL START----------------------------------------------------------------------------------------------------------------------------------------------------------------
	DifficultyScalings(0)={(
		// Normal
		Difficulties[0]={(
			TraderTime = 75, //75
			SpawnRateModifier = 0.8,
			MovementSpeedMod = 0.90000,
			WaveCountMod = 0.750000, //0.85
			DoshKillMod = 1.10000, //1.2
			StartingDosh = 300,
			AmmoPickupsMod = 0.400000,
			ItemPickupsMod = 0.450000,
			SelfInflictedDamageMod = 0.100000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hard
		Difficulties[1]={(
			TraderTime = 75, //75
			RespawnDosh = 300,
			SpawnRateModifier = 0.8,
			MovementSpeedMod = 0.95,
			WaveCountMod = 0.80000, //0.85
			DoshKillMod = 1.0, //1.0 //0.8
			AmmoPickupsMod = 0.300000,
			ItemPickupsMod = 0.350000,
			SelfInflictedDamageMod = 0.100000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Suicidal
		Difficulties[2]={(
			TraderTime = 75, //75
			WaveCountMod = 0.9000, //0.95
			SpawnRateModifier = 0.7,   //1.0
			MovementSpeedMod = 0.95,  //1.0
			DoshKillMod = 1.00000,  //0.9 //0.7
			AmmoPickupsMod = 0.40000, //0.25
			ItemPickupsMod = 0.250000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 0.500000,
			SelfInflictedDamageMod = 0.100000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth
		Difficulties[3]={(
			TraderTime = 75, //75
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.68, //1.0
			WaveCountMod = 0.950000, //1.0
			DoshKillMod = 1.00000, //0.8 0.6
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.10000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth Plus
		Difficulties[4]={(
			TraderTime = 75, //75
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.68, //1.0
			WaveCountMod = 1.000000, //1.7
			DoshKillMod = 1.00000,  //0.7 0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.10000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},

		DifficultyIncrement={(
			TraderTime = 0,
			GlobalHealthMod = 0.0,
			MovementSpeedMod = 0.0,
			WaveCountMod = 0.1, //0.1
			SpawnRateModifier = -0.3,
			DoshKillMod = -0.01,
			StartingDosh = 0,
			RespawnDosh = 0,
			AmmoPickupsMod = 0.2,    //this will need to go to other diff
			ItemPickupsMod = 0.2,    // this will need to go to other diff
			WeakAttackChance = 0.0,
			MediumAttackChance = 0.0,
			HardAttackChance = 0.0,
			SelfInflictedDamageMod = 0.0,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},

		// Normal
		ZedAdjustmentsByDifficulty[0] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.65,DamageDealtScale = 0.75,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.45,DamageDealtScale = 0.75,DoshGiven = 250),  //750
				
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.55,DamageDealtScale = 0.75,DoshGiven = 250),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.62,DamageDealtScale = 0.75,DoshGiven = 250), //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 0.5,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.42,DamageDealtScale = 0.75,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.42,DamageDealtScale = 0.75,DoshGiven = 11)
			)}
		)},
		// Hard
		ZedAdjustmentsByDifficulty[1] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.9,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 500),
				
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.75,DamageDealtScale = 0.85,DoshGiven = 500),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.84,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.84,DamageDealtScale = 0.85,DoshGiven = 11)
			)}
		)},
		// Suicidal
		ZedAdjustmentsByDifficulty[2] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 1.0,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 1.0,DamageDealtScale = 0.85,DoshGiven = 11)
			)}
		)},
		// Hell On Earth
		ZedAdjustmentsByDifficulty[3] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},
		// Hell On Earth Plus Base
		ZedAdjustmentsByDifficulty[4] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},

		ZedAdjustmentIncrement = {(
			HealthScale=0.0,
			DamageDealtScale=.01,
			DamageTakenScale=0.0
		)},

		// Normal
		ZedDiffOverride[0]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.25f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=0.75f,DamageMod=0.35f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=0.85f,DamageMod=0.425f,SoloDamageMod=0.425),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=0.75f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.5f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.71f,DamageMod=0.54f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=0.75f,DamageMod=0.67f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.7f,DamageMod=0.6f,SoloDamageMod=0.37),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.63f,DamageMod=0.51f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.65f,DamageMod=0.7f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.35f,DamageMod=0.2f)
			)}
		)},
		// Hard
		ZedDiffOverride[1]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.25f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=0.75f,DamageMod=0.35f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=0.85f,DamageMod=0.425f,SoloDamageMod=0.425),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=0.75f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.5f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.71f,DamageMod=0.54f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=0.75f,DamageMod=0.67f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.7f,DamageMod=0.6f,SoloDamageMod=0.37),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.63f,DamageMod=0.51f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.65f,DamageMod=0.7f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.35f,DamageMod=0.2f)
			)}
		)},
		// Suicidal
		ZedDiffOverride[2]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.25f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=0.75f,DamageMod=0.35f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=0.85f,DamageMod=0.425f,SoloDamageMod=0.425),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=0.75f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.5f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.71f,DamageMod=0.54f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=0.75f,DamageMod=0.67f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.7f,DamageMod=0.6f,SoloDamageMod=0.37),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.63f,DamageMod=0.51f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.65f,DamageMod=0.7f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.35f,DamageMod=0.2f)
			)}
		)},
		// Hell on Earth
		ZedDiffOverride[3]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.25f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=0.75f,DamageMod=0.35f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=0.85f,DamageMod=0.425f,SoloDamageMod=0.425),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=0.75f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.5f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.71f,DamageMod=0.54f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=0.75f,DamageMod=0.67f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.7f,DamageMod=0.6f,SoloDamageMod=0.37),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.63f,DamageMod=0.51f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.65f,DamageMod=0.7f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.35f,DamageMod=0.2f)
			)}
		)},
		// Hell on Earth Plus
		ZedDiffOverride[4]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.25f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=0.75f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=0.75f,DamageMod=0.4f,SoloDamageMod=0.3),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=0.75f,DamageMod=0.35f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=0.85f,DamageMod=0.425f,SoloDamageMod=0.425),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=0.75f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.5f,DamageMod=0.31f,SoloDamageMod=0.31),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.71f,DamageMod=0.54f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=0.75f,DamageMod=0.67f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.7f,DamageMod=0.6f,SoloDamageMod=0.37),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.63f,DamageMod=0.51f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.65f,DamageMod=0.7f,SoloDamageMod=0.35),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.35f,DamageMod=0.2f)
			)}
		)},

		// Normal
		OutbreakPctChances[0]=0.0,
		// Hard
		OutbreakPctChances[1]=0.2, //0.1
		// Suicidal
		OutbreakPctChances[2]=0.3,  //0.2
		// Hell on Earth
		OutbreakPctChances[3]=0.4, //0.25
		// Hell on Earth Plus
		OutbreakPctChances[4]=0.5,   //0.3

		// Normal
		SpecialWavePctChance[0]=0.1, //
		// Hard
		SpecialWavePctChance[1]=0.25,  //0.1
		// Suicidal
		SpecialWavePctChance[2]=0.35,   //0.2
		// Hell on Earth
		SpecialWavePctChance[3]=0.45,  //0.025
		// Hell on Earth Plus
		SpecialWavePctChance[4]=0.5,   //0.3

		// Normal
		DifficultySpecialWaveTypes[0]={(
			SpecialWaveInfos[0]=(ZedType=AT_Clot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=3.f),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f),
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hard
		DifficultySpecialWaveTypes[1]={(
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.2, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.2, WaveScale=1.f, SpawnRateMultiplier=3.f)
		)},
		// Suicidal
		DifficultySpecialWaveTypes[2]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.17, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.17, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth
		DifficultySpecialWaveTypes[3]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.5f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.25, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.25, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth Plus
		DifficultySpecialWaveTypes[4]={(
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.15f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=1.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)}
	)}

	// HARD START ----------------------------------------------------------------------------------------------------------------------------------------------------------------
	DifficultyScalings(1)={(
		// Hard
		Difficulties[0]={(
			TraderTime = 60,
			RespawnDosh = 300,
			SpawnRateModifier = 0.8,
			MovementSpeedMod = 0.95,
			WaveCountMod = 0.750000, //0.85
			DoshKillMod = 1.1, //1.0 //0.8
			AmmoPickupsMod = 0.300000,
			ItemPickupsMod = 0.350000,
			SelfInflictedDamageMod = 0.200000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Suicidal
		Difficulties[1]={(
			TraderTime = 60,
			WaveCountMod = 0.8000, //0.95
			SpawnRateModifier = 0.7,   //1.0
			MovementSpeedMod = 0.95,  //1.0
			DoshKillMod = 1.00000,  //0.9 //0.7
			AmmoPickupsMod = 0.40000, //0.25
			ItemPickupsMod = 0.250000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 0.500000,
			SelfInflictedDamageMod = 0.200000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth
		Difficulties[2]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.68, //1.0
			WaveCountMod = 0.850000, //1.0
			DoshKillMod = 1.00000, //0.8 0.6
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.20000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth +
		Difficulties[3]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.65, //1.0
			WaveCountMod = 0.900000, //1.7
			DoshKillMod = 1.000000,  //0.7 0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.20000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth ++
		Difficulties[4]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.6, //1.0
			WaveCountMod = 0.950000, //1.7
			DoshKillMod = 1.000000,  //0.7 0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.20000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},

		DifficultyIncrement={(
			TraderTime = 0,
			GlobalHealthMod = 0.0,
			MovementSpeedMod = 0.0,
			WaveCountMod = 0.1, //0.1
			SpawnRateModifier = -0.3,
			DoshKillMod = -0.01,
			StartingDosh = 0,
			RespawnDosh = 0,
			AmmoPickupsMod = 0.2,    //this will need to go to other diff
			ItemPickupsMod = 0.2,    // this will need to go to other diff
			WeakAttackChance = 0.0,
			MediumAttackChance = 0.0,
			HardAttackChance = 0.0,
			SelfInflictedDamageMod = 0.0,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)

		)},

		// Normal
		ZedAdjustmentsByDifficulty[0] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.65,DamageDealtScale = 0.75,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.45,DamageDealtScale = 0.75,DoshGiven = 250),  //750

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.55,DamageDealtScale = 0.75,DoshGiven = 250),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.62,DamageDealtScale = 0.75,DoshGiven = 250), //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 0.5,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.42,DamageDealtScale = 0.75,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.42,DamageDealtScale = 0.75,DoshGiven = 11)
			)}
		)},
		// Hard
		ZedAdjustmentsByDifficulty[1] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.9,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 500),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.75,DamageDealtScale = 0.85,DoshGiven = 500),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.84,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.84,DamageDealtScale = 0.85,DoshGiven = 11)
			)}
		)},
		// Suicidal
		ZedAdjustmentsByDifficulty[2] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 1.0,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 1.0,DamageDealtScale = 0.85,DoshGiven = 11)
			)}
		)},
		// Hell On Earth
		ZedAdjustmentsByDifficulty[3] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},
		// Hell On Earth Plus Base
		ZedAdjustmentsByDifficulty[4] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},

		ZedAdjustmentIncrement = {(
			HealthScale=0.0,
			DamageDealtScale=.01,
			DamageTakenScale=0.0
		)},

		// Normal
		ZedDiffOverride[0]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.85f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.f,DamageMod=0.7f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.75f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.82f,DamageMod=0.73f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.f,DamageMod=0.81f,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.9f,DamageMod=0.75f,SoloDamageMod=0.45),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.83f,DamageMod=0.75f,SoloDamageMod=0.5,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.8f,DamageMod=0.85f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.95f,DamageMod=0.75f)
			)}
		)},
		// Hard
		ZedDiffOverride[1]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.85f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.f,DamageMod=0.7f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.75f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.82f,DamageMod=0.73f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.f,DamageMod=0.81f,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.9f,DamageMod=0.75f,SoloDamageMod=0.45),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.83f,DamageMod=0.75f,SoloDamageMod=0.5,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.8f,DamageMod=0.85f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.95f,DamageMod=0.75f)
			)}
		)},
		// Suicidal
		ZedDiffOverride[2]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.85f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.f,DamageMod=0.7f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.75f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.82f,DamageMod=0.73f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.f,DamageMod=0.81f,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.9f,DamageMod=0.75f,SoloDamageMod=0.45),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.83f,DamageMod=0.75f,SoloDamageMod=0.5,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.8f,DamageMod=0.85f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.95f,DamageMod=0.75f)
			)}
		)},
		// Hell on Earth
		ZedDiffOverride[3]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.85f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.f,DamageMod=0.7f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.75f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.82f,DamageMod=0.73f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.f,DamageMod=0.81f,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.9f,DamageMod=0.75f,SoloDamageMod=0.45),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.83f,DamageMod=0.75f,SoloDamageMod=0.5,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.8f,DamageMod=0.85f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.95f,DamageMod=0.75f)
			)}
		)},
		// Hell on Earth Plus
		ZedDiffOverride[4]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=0.85f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=0.75f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.8),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=0.75f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.f,DamageMod=0.7f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=0.75f,DamageMod=0.65f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.82f,DamageMod=0.73f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.f,DamageMod=0.81f,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=0.9f,DamageMod=0.75f,SoloDamageMod=0.45),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=0.83f,DamageMod=0.75f,SoloDamageMod=0.5,SoloDamageMod=0.42),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.8f,DamageMod=0.85f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=0.95f,DamageMod=0.75f)
			)}
		)},

		// Normal
		OutbreakPctChances[0]=0.0,
		// Hard
		OutbreakPctChances[1]=0.2, //0.1
		// Suicidal
		OutbreakPctChances[2]=0.3,  //0.2
		// Hell on Earth
		OutbreakPctChances[3]=0.4, //0.25
		// Hell on Earth Plus
		OutbreakPctChances[4]=0.5,   //0.3

		// Normal
		SpecialWavePctChance[0]=0.1, //
		// Hard
		SpecialWavePctChance[1]=0.25,  //0.1
		// Suicidal
		SpecialWavePctChance[2]=0.35,   //0.2
		// Hell on Earth
		SpecialWavePctChance[3]=0.45,  //0.025
		// Hell on Earth Plus
		SpecialWavePctChance[4]=0.5,   //0.3

		// Normal
		DifficultySpecialWaveTypes[0]={(
			SpecialWaveInfos[0]=(ZedType=AT_Clot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=3.f),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f),
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hard
		DifficultySpecialWaveTypes[1]={(
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.2, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.2, WaveScale=1.f, SpawnRateMultiplier=3.f)
		)},
		// Suicidal
		DifficultySpecialWaveTypes[2]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.17, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.17, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth
		DifficultySpecialWaveTypes[3]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.5f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.25, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.25, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth Plus
		DifficultySpecialWaveTypes[4]={(
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.15f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=1.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)}
	)}

	// SUICIDAL START ----------------------------------------------------------------------------------------------------------------------------------------------------------
	DifficultyScalings(2)={(
			// Sucidal
		Difficulties[0]={(
			TraderTime = 60,
			WaveCountMod = 0.750000, //0.95  //0.9
			SpawnRateModifier = 0.7,   //1.0
			MovementSpeedMod = 0.95,  //1.0
			DoshKillMod = 1.1,  //0.9 //0.7  0.8
			AmmoPickupsMod = 0.40000, //0.25
			ItemPickupsMod = 0.250000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 0.500000,
			SelfInflictedDamageMod = 0.200000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth
		Difficulties[1]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.68, //1.0
			WaveCountMod = 0.80000, //1.0 //0.95
			DoshKillMod = 1.0, //0.8 0.6 //0.7
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.20000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth +
		Difficulties[2]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.65, //1.0
			WaveCountMod = 0.9000, //1.7 //1.0
			DoshKillMod = 1.000000,  //0.7 0.5  0.6
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.20000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth ++
		Difficulties[3]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.6, //1.0
			WaveCountMod = 0.950000, //1.7 //1.05
			DoshKillMod = 1.000000,  //0.7 0.5  0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.20000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth +++
		Difficulties[4]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.55, //1.0
			WaveCountMod = 1.000000, //1.7  //1.1
			DoshKillMod = 1.000000,  //0.7 0.5  0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.20000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},

		DifficultyIncrement={(
			TraderTime = 0,
			GlobalHealthMod = 0.0,
			MovementSpeedMod = 0.0,
			WaveCountMod = 0.1, //0.1
			SpawnRateModifier = -0.3,
			DoshKillMod = -0.01,
			StartingDosh = 0,
			RespawnDosh = 0,
			AmmoPickupsMod = 0.2,    //this will need to go to other diff
			ItemPickupsMod = 0.2,    // this will need to go to other diff
			WeakAttackChance = 0.0,
			MediumAttackChance = 0.0,
			HardAttackChance = 0.0,
			SelfInflictedDamageMod = 0.0,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)

		)},

				// Normal
		ZedAdjustmentsByDifficulty[0] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.65,DamageDealtScale = 0.75,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.45,DamageDealtScale = 0.75,DoshGiven = 250),  //750

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.55,DamageDealtScale = 0.75,DoshGiven = 250),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.62,DamageDealtScale = 0.75,DoshGiven = 250), //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 0.5,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.42,DamageDealtScale = 0.75,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.42,DamageDealtScale = 0.75,DoshGiven = 11)
			)}
		)},
		// Hard
		ZedAdjustmentsByDifficulty[1] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.9,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 500),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.75,DamageDealtScale = 0.85,DoshGiven = 500),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 0.85,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.84,DamageDealtScale = 0.85,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.84,DamageDealtScale = 0.85,DoshGiven = 11)
			)}
		)},
		// Suicidal
		ZedAdjustmentsByDifficulty[2] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 1.0,DamageDealtScale = 0.85,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.95,DamageDealtScale = 0.95,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 1.0,DamageDealtScale = 0.85,DoshGiven = 11)
			)}
		)},
		// Hell On Earth
		ZedAdjustmentsByDifficulty[3] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},
		// Hell On Earth Plus Base
		ZedAdjustmentsByDifficulty[4] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},

		ZedAdjustmentIncrement = {(
			HealthScale=0.0,
			DamageDealtScale=0.01,
			DamageTakenScale=0.0
		)},

		// Normal
		ZedDiffOverride[0]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.2f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.1f,DamageMod=1.125f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.85f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.13f,DamageMod=1.47f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.0f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.9f,DamageMod=1.15f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Hard
		ZedDiffOverride[1]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.2f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.1f,DamageMod=1.125f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.85f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.13f,DamageMod=1.47f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.0f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.9f,DamageMod=1.15f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Suicidal
		ZedDiffOverride[2]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.2f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.1f,DamageMod=1.125f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.85f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.13f,DamageMod=1.47f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.0f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.9f,DamageMod=1.15f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Hell on Earth
		ZedDiffOverride[3]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.2f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.1f,DamageMod=1.125f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.85f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.13f,DamageMod=1.47f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.0f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.9f,DamageMod=1.15f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Hell on Earth Plus
		ZedDiffOverride[4]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.2f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.1f,DamageMod=1.125f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.1f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.85f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.13f,DamageMod=1.47f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.0f,DamageMod=1.15f,SoloDamageMod=0.4),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=0.9f,DamageMod=1.15f,SoloDamageMod=0.41),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},

		// Normal
		OutbreakPctChances[0]=0.0,
		// Hard
		OutbreakPctChances[1]=0.2, //0.1
		// Suicidal
		OutbreakPctChances[2]=0.3,  //0.2
		// Hell on Earth
		OutbreakPctChances[3]=0.4, //0.25
		// Hell on Earth Plus
		OutbreakPctChances[4]=0.5,   //0.3

		// Normal
		SpecialWavePctChance[0]=0.1, //
		// Hard
		SpecialWavePctChance[1]=0.25,  //0.1
		// Suicidal
		SpecialWavePctChance[2]=0.35,   //0.2
		// Hell on Earth
		SpecialWavePctChance[3]=0.45,  //0.025
		// Hell on Earth Plus
		SpecialWavePctChance[4]=0.5,   //0.3

		// Normal
		DifficultySpecialWaveTypes[0]={(
			SpecialWaveInfos[0]=(ZedType=AT_Clot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=3.f),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f),
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hard
		DifficultySpecialWaveTypes[1]={(
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.2, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.2, WaveScale=1.f, SpawnRateMultiplier=3.f)
		)},
		// Suicidal
		DifficultySpecialWaveTypes[2]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.17, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.17, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth
		DifficultySpecialWaveTypes[3]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.5f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.25, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.25, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth Plus
		DifficultySpecialWaveTypes[4]={(
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.15f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=1.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)}
	)}

	// HELL ON EARTH START -----------------------------------------------------------------------------------------------------------------------------------------------------
	DifficultyScalings(3)={(
		// Hell On Earth
		Difficulties[0]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.5, //1.0 //0.65
			WaveCountMod = 0.850000, //1.0
			DoshKillMod = 1.1, //0.8 0.6
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.50000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth +
		Difficulties[1]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.5, //1.0
			WaveCountMod = 0.9, //1.7
			DoshKillMod = 1.000000,  //0.7 0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.50000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth ++
		Difficulties[2]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.65, //1.0
			WaveCountMod = 0.95, //1.7
			DoshKillMod = 1.0,  //0.7 0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.50000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth +++
		Difficulties[3]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.6, //1.0
			WaveCountMod = 1.0, //1.7
			DoshKillMod = 1.00000,  //0.7 0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.50000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},
		// Hell On Earth ++++
		Difficulties[4]={(
			TraderTime = 60,
			MovementSpeedMod = 0.95, //1.05
			SpawnRateModifier = 0.55, //1.0
			WaveCountMod = 1.05000, //1.7
			DoshKillMod = 1.00000,  //0.7 0.5
			StartingDosh = 250, //200
			AmmoPickupsMod = 0.250000,
			ItemPickupsMod = 0.100000,
			MediumAttackChance = 1.000000,
			HardAttackChance = 1.000000,
			SelfInflictedDamageMod = 0.50000,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)
		)},

		DifficultyIncrement={(
			TraderTime = 0,
			GlobalHealthMod = 0.0,
			MovementSpeedMod = 0.0,
			WaveCountMod = 0.1, //0.1
			SpawnRateModifier = -0.3,
			DoshKillMod = -0.01,
			StartingDosh = 0,
			RespawnDosh = 0,
			AmmoPickupsMod = 0.2,    //this will need to go to other diff
			ItemPickupsMod = 0.2,    // this will need to go to other diff
			WeakAttackChance = 0.0,
			MediumAttackChance = 0.0,
			HardAttackChance = 0.0,
			SelfInflictedDamageMod = 0.0,
			TraderTimerMapOverride[0]=(MapName="KF-DieSector",TraderTime=45)

		)},


				// Normal
		ZedAdjustmentsByDifficulty[0] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.65,DamageDealtScale = 1.0,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.45,DamageDealtScale = 1.0,DoshGiven = 250),  //750

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.55,DamageDealtScale = 1.0,DoshGiven = 250),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.62,DamageDealtScale = 1.0,DoshGiven = 250), //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.42,DamageDealtScale = 1.0,DoshGiven = 250),  //750
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.55,DamageDealtScale = 1.0,DoshGiven = 11)
			)}
		)},
		// Hard
		ZedAdjustmentsByDifficulty[1] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.9,DamageDealtScale = 1.0,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.85,DamageDealtScale = 1.0,DoshGiven = 500),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.75,DamageDealtScale = 1.0,DoshGiven = 500),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.85,DamageDealtScale = 1.0,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.84,DamageDealtScale = 1.0,DoshGiven = 500),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 0.84,DamageDealtScale = 1.0,DoshGiven = 11)
			)}
		)},
		// Suicidal
		ZedAdjustmentsByDifficulty[2] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 0.95,DamageDealtScale = 1.0,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 0.95,DamageDealtScale = 1.0,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 0.95,DamageDealtScale = 1.0,DoshGiven = 800),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 0.95,DamageDealtScale = 1.0,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 5),

				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 0.95,DamageDealtScale = 1.0,DoshGiven = 800),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 11)
			)}
		)},
		// Hell On Earth
		ZedAdjustmentsByDifficulty[3] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},
		// Hell On Earth Plus Base
		ZedAdjustmentsByDifficulty[4] = {(
			ZedsToAdjust = {(
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedPatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedHans',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedMatriarch',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedBloatKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000),
				(ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.0,DamageDealtScale = 1.0,DoshGiven = 1000)
			)}
		)},

		ZedAdjustmentIncrement = {(
			HealthScale=0.0,
			DamageDealtScale=.01,
			DamageTakenScale=0.0
		)},

		// Normal
		ZedDiffOverride[0]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.2f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.15f,DamageMod=1.05f, SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.91f,DamageMod=1.18f,SoloDamageMod=0.51),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.39f,DamageMod=1.45f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.2f,DamageMod=1.45f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.2f,DamageMod=1.2f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=1.05f,DamageMod=1.2f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Hard
		ZedDiffOverride[1]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.2f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.15f,DamageMod=1.05f, SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.91f,DamageMod=1.18f,SoloDamageMod=0.51),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.39f,DamageMod=1.45f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.2f,DamageMod=1.45f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.2f,DamageMod=1.2f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=1.05f,DamageMod=1.2f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Suicidal
		ZedDiffOverride[2]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.2f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.15f,DamageMod=1.05f, SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.91f,DamageMod=1.18f,SoloDamageMod=0.51),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.39f,DamageMod=1.45f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.2f,DamageMod=1.45f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.2f,DamageMod=1.2f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=1.05f,DamageMod=1.2f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Hell on Earth
		ZedDiffOverride[3]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.2f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.15f,DamageMod=1.05f, SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.91f,DamageMod=1.18f,SoloDamageMod=0.51),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.39f,DamageMod=1.45f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.2f,DamageMod=1.45f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.2f,DamageMod=1.2f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=1.05f,DamageMod=1.2f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},
		// Hell on Earth Plus
		ZedDiffOverride[4]={(
			ZedsOverride={(
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthMod=1.f,DamageMod=1.f),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthMod=1.f,DamageMod=1.f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthMod=1.3f,DamageMod=1.5f,SoloDamageMod=0.75),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthMod=1.1f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthMod=1.2f,DamageMod=1.25f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthMod=1.15f,DamageMod=1.05f, SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthMod=0.91f,DamageMod=1.18f,SoloDamageMod=0.51),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthMod=1.39f,DamageMod=1.45f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthMod=1.2f,DamageMod=1.45f,SoloDamageMod=0.5),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthMod=1.2f,DamageMod=1.2f,SoloDamageMod=0.65),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthMod=1.05f,DamageMod=1.2f,SoloDamageMod=0.52),
				(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthMod=1.f,DamageMod=1.f)
			)}
		)},

		// Normal
		OutbreakPctChances[0]=0.0,
		// Hard
		OutbreakPctChances[1]=0.2, //0.1
		// Suicidal
		OutbreakPctChances[2]=0.3,  //0.2
		// Hell on Earth
		OutbreakPctChances[3]=0.4, //0.25
		// Hell on Earth Plus
		OutbreakPctChances[4]=0.5,   //0.3

		// Normal
		SpecialWavePctChance[0]=0.1, //
		// Hard
		SpecialWavePctChance[1]=0.25,  //0.1
		// Suicidal
		SpecialWavePctChance[2]=0.35,   //0.2
		// Hell on Earth
		SpecialWavePctChance[3]=0.45,  //0.025
		// Hell on Earth Plus
		SpecialWavePctChance[4]=0.5,   //0.3

		// Normal
		DifficultySpecialWaveTypes[0]={(
			SpecialWaveInfos[0]=(ZedType=AT_Clot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.0, WaveScale=1.f, SpawnRateMultiplier=3.f),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f),
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.25, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.0, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.0, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hard
		DifficultySpecialWaveTypes[1]={(
			SpecialWaveInfos[7]=(ZedType=AT_AlphaClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.2, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[2]=(ZedType=AT_Crawler, PctChance=0.2, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[3]=(ZedType=AT_Stalker, PctChance=0.2, WaveScale=1.f, SpawnRateMultiplier=3.f)
		)},
		// Suicidal
		DifficultySpecialWaveTypes[2]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[1]=(ZedType=AT_SlasherClot, PctChance=0.17, WaveScale=2.f, SpawnRateMultiplier=10.0f, bSpawnEnraged=true),
			SpecialWaveInfos[4]=(ZedType=AT_Siren, PctChance=0.17, WaveScale=0.5f, SpawnRateMultiplier=2.f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.17, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.17, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth
		DifficultySpecialWaveTypes[3]={(
			SpecialWaveInfos[8]=(ZedType=AT_GoreFast, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.5f, bSpawnEnraged=true),
			SpecialWaveInfos[9]=(ZedType=AT_Bloat, PctChance=0.25, WaveScale=0.5f, SpawnRateMultiplier=1.5f),
			SpecialWaveInfos[5]=(ZedType=AT_Husk, PctChance=0.25, WaveScale=0.75f, SpawnRateMultiplier=1.0f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=0.25, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)},
		// Hell on Earth Plus
		DifficultySpecialWaveTypes[4]={(
			SpecialWaveInfos[10]=(ZedType=AT_FleshPound, PctChance=0.0, WaveScale=0.2f, SpawnRateMultiplier=0.15f),
			SpecialWaveInfos[6]=(ZedType=AT_Scrake, PctChance=1.0, WaveScale=0.2f, SpawnRateMultiplier=0.25f)
		)}
	)}
}
