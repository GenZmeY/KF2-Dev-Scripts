//=============================================================================
// KFMapInfo
//=============================================================================
// The Killing Floor 2 mapinfo
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFMapInfo extends MapInfo
	native;

/** Base value to use for how long to wait between spawning groups of AI. Turn this number down to make zeds spawn faster and the map harder, turn it up to make zeds spawn slower and the map easier  */
var(Spawning)	float						WaveSpawnPeriod;

/** list of destructibles that require replicated damage states in this map */
var()			array<KFDestructibleActor> 	DestructibleActors;

/** list of music tracks played when a wave is active */
// @todo: make these not editconst when we're ready to have mappers or whomever change them
var(Music) array< KFMusicTrackInfo > 	ActionMusicTracks;
/** List of random indices into the ActionMusicTracks array */
var transient array< byte > 				ShuffledActionMusicTrackIdxes;
/** Current position within the ShuffledActionMusicTrackIdxes array */
var transient byte							CurrShuffledActionMusicTrackIdx;

/** list of music tracks played during trader time */
// @todo: make these not editconst when we're ready to have mappers or whomever change them
var(Music) array< KFMusicTrackInfo > 	AmbientMusicTracks;
/** List of random indices into the AmbientMusicTracks array */
var transient array< byte > 	 			ShuffledAmbientMusicTrackIdxes;
/** Current position within the ShuffledAmbientMusicTrackIdxes array */
var transient byte							CurrShuffledAmbientMusicTrackIdx;

enum ECollectibleType
{
	ECT_DoshBling,
	ECT_ClotMotherBaby
};

/** Type of collectible in this map (used for collectible text/localization) */
var/*(Collectibles)*/ const ECollectibleType CollectibleType;
/** How many collectibles players need to find in this map to unlock the achievement */
var(Collectibles) const int	CollectiblesToFind;
/** How many collectibles players have found */
var const transient int		CollectiblesFound;

/** Custom map gameplay types */
enum ESubGameType
{
	ESGT_Normal,
	ESGT_Descent
};

/**
 * The sub-gameplay type of map this (i.e. Descent map inside Survival)
 * NOTE: Setting this option incorrectly may disable or enable unwanted game features!
 */
var() ESubGameType SubGameType;

/** Objective mode types and data */

/**
PossibleObjectives: possible objectives, one chosen at random.
bUseEndlessSpawning: whether zeds should spawn endlessly during this wave.
SpawnReplacements: which zed types should be replaced by which other zed types
PerPlayerSpawnRateMod: spawn rate modification based on number of players
WaveScale: scalar for number of zeds this wave
AppliedWaveNum: what wave intensity (1-9) to apply to this wave/objective
bShouldAutoStartWave: whether this wave should start immediately after trader time
*/
struct native WaveObjectivePair
{
    var() array<KFInterface_MapObjective> PossibleObjectives;
	var() bool bUseEndlessSpawning;
	var() array<SpawnReplacement> SpawnReplacements;
	var() array<float> PerPlayerSpawnRateMod;
	var() float WaveScale;
	var() int AppliedWaveNum<ClampMin=0|ClampMax=9>;
	var() bool bShouldAutoStartWave;

	structdefaultproperties
	{
		PerPlayerSpawnRateMod=(1.f, 1.f, 1.f, 1.f, 1.f, 1.f)
		WaveScale=1.f
		bShouldAutoStartWave=true
	}
};

struct native PresetWavePairs
{
    var() WaveObjectivePair ShortObjectives[5];
    var() WaveObjectivePair MediumObjectives[8];
    var() WaveObjectivePair LongObjectives[11];
};

/** Whether or not to use the preset wave objective type */
var(SurvivalObjectives) bool bUsePresetObjectives <EditCondition=!bUseRandomObjectives>;
var(SurvivalObjectives) PresetWavePairs PresetWaveObjectives <EditCondition=bUsePresetObjectives>;

/** Whether or not to use the random wave objective type */
var(SurvivalObjectives) bool bUseRandomObjectives <EditCondition=!bUsePresetObjectives>;
var(SurvivalObjectives) array<KFInterface_MapObjective> RandomWaveObjectives;
var(SurvivalObjectives) array<int> RandomObjectiveWavesToDisable;
var array<KFInterface_MapObjective> CurrentAvailableRandomWaveObjectives;

var() string TraderVoiceGroupClassPath;
var() string TraderVoiceGroupClassPath_Endless;
var() string TraderVoiceGroupClassPath_Objective;

// Whether to override the boss of a Survival match
var() bool bOverrideSurvivalBoss;
// Which boss to use as the override
var() EBossAIType SurvivalBossOverride<EditCondition=bOverrideSurvivalBoss>;
// Which seasonal zeds to use for this map (SEI_None follows TW seasonal events)
var() SeasonalEventIndex ZedSeasonalThemeId;
// Mutator code class that can override various map settings
var() class<KFMapMutator> MapMutatorClass;

// Objectives to use in Objective Mode
var(ObjectiveMode) array<WaveObjectivePair> ObjectiveModeObjectives;

cpptext
{
#if WITH_EDITOR
	virtual void CheckForErrors();
	virtual void PostEditChangeChainProperty(struct FPropertyChangedChainEvent& PropertyChangedEvent);
#endif
}

/********************************************************************************************
*
* GetNextMusicTrackStruct and StaticGetNextMusicTrackStruct have been reduced to stubs due to a music refactor
*
********************************************************************************************/

/* (NOT FUNCTIONAL BUT STILL NEEDED FOR LEGACY) Returns a randomly chosen song from the trackstruct array */
function MusicTrackStruct GetNextMusicTrackStruct(bool bActionTrack = true);

/* (NOT FUNCTIONAL BUT STILL NEEDED FOR LEGACY) Returns a randomly chosen song from the trackstruct array */
static function MusicTrackStruct StaticGetNextMusicTrackStruct(bool bActionTrack = true);

/** Returns a music track based on wave activity and game progress */
function KFMusicTrackInfo GetNextMusicTrackByGameIntensity( bool bPlayActionTrack, byte GameIntensity )
{
	if( bPlayActionTrack )
	{
		if( ActionMusicTracks.length == 0 )
		{
			`log("KFMapInfo::GetNextMusicTrackByGameIntensity - NO ACTION MUSIC TRACKS TO PICK FROM");
			return none;
		}

		// initialize shuffled tracks
		if( ShuffledActionMusicTrackIdxes.length == 0 )
		{
			ShuffleTracks( ShuffledActionMusicTrackIdxes, CurrShuffledActionMusicTrackIdx, ActionMusicTracks.length );
		}

		return GetRandomTrack( GameIntensity, ActionMusicTracks, ShuffledActionMusicTrackIdxes, CurrShuffledActionMusicTrackIdx );
	}
	else
	{
		if( AmbientMusicTracks.length == 0 )
		{
			`log("KFMapInfo::GetNextMusicTrackByGameIntensity - NO AMBIENT MUSIC TRACKS TO PICK FROM");
			return none;
		}

		// initialize shuffled tracks
		if( ShuffledAmbientMusicTrackIdxes.length == 0 )
		{
			ShuffleTracks( ShuffledAmbientMusicTrackIdxes, CurrShuffledAmbientMusicTrackIdx, AmbientMusicTracks.length );
		}

		return GetRandomTrack( GameIntensity, AmbientMusicTracks, ShuffledAmbientMusicTrackIdxes, CurrShuffledAmbientMusicTrackIdx );
	}
}

/** Returns a random music track from the specified track list and re-shuffles the list if necessary */
function KFMusicTrackInfo GetRandomTrack( byte GameIntensity, const out array<KFMusicTrackInfo> Tracks, out array< byte > ShuffledTrackIdxes, out byte CurrShuffledTrackIdx )
{
	local KFMusicTrackInfo CheckTrack;
	local byte ShuffleCount;

	while( ShuffleCount <= 1 )
	{
		// iterate through the list starting with our previous position
		while( CurrShuffledTrackIdx < ShuffledTrackIdxes.length )
		{
			CheckTrack = Tracks[ ShuffledTrackIdxes[CurrShuffledTrackIdx++] ];

			// check if this track is allowed to be played for the specified game progression
			if( GameIntensity == 255 || (GameIntensity >= CheckTrack.MinGameIntensityLevel && GameIntensity <= CheckTrack.MaxGameIntensityLevel) )
			{
				return CheckTrack;
			}
		}

		// when we reach the last element, reshuffle ONE TIME
		if( CurrShuffledTrackIdx == ShuffledTrackIdxes.length )
		{
			if( ShuffleCount > 0 )
			{
				`warn("KFMapInfo::GetRandomTrack - no suitable track found!");
				return none;
			}

			ShuffleTracks( ShuffledTrackIdxes, CurrShuffledTrackIdx );
			ShuffleCount++;
		}
	}

	return none;
}

/** Shuffles the given array of music tracks */
function ShuffleTracks( out array<byte> TrackIdxes, out byte TrackIdx, optional int InitLength )
{
	local int NumTracks, i, RandNum;
	local byte TempTrackIdx;

	// initialize shuffled array of indices if necessary
	if( InitLength > 0 )
	{
		TrackIdxes.length = InitLength;
		for( i = 0; i < InitLength; ++i )
		{
			TrackIdxes[i] = i;
		}
	}

	NumTracks = TrackIdxes.length;

	// shuffle!
	for( i = 0; i < NumTracks; ++i )
	{
		RandNum = Rand( NumTracks );
		TempTrackIdx = TrackIdxes[i];
		TrackIdxes[i] = TrackIdxes[ RandNum ];
		TrackIdxes[ RandNum ] = TempTrackIdx;
	}

	TrackIdx = 0;
}

static function KFMusicTrackInfo StaticGetRandomTrack( bool bPlayActionTrack )
{
	local int RandTrackIdx;
	local KFMusicTrackInfo RandTrackInfo;

    if( bPlayActionTrack )
    {
    	if( default.ActionMusicTracks.length == 0 )
		{
			`log("KFMapInfo::StaticGetRandomTrack - NO DEFAULT ACTION MUSIC TRACKS TO PICK FROM");
			return none;
		}

    	RandTrackIdx = Rand(default.ActionMusicTracks.length);
    	RandTrackInfo = default.ActionMusicTracks[RandTrackIdx];
    }
    else
    {
    	if( default.AmbientMusicTracks.length == 0 )
		{
			`log("KFMapInfo::StaticGetRandomTrack - NO DEFAULT AMBIENT MUSIC TRACKS TO PICK FROM");
			return none;
		}

    	RandTrackIdx = Rand(default.AmbientMusicTracks.length);
    	RandTrackInfo = default.AmbientMusicTracks[RandTrackIdx];
    }

    return RandTrackInfo;
}

/** Figures out if player has collected enough collectibles to unlock its related achievement */
native final function OnCollectibleFound( KFDestructibleActor Collectible, Controller Collecter );

function bool WaveHasPresetObjectives(int WaveNum, int GameLength)
{
	if (!bUsePresetObjectives)
	{
		return false;
	}

	switch (GameLength)
	{
	case GL_Short:
		return PresetWaveObjectives.ShortObjectives[WaveNum-1].PossibleObjectives.Length > 0;

	case GL_Normal:
		return PresetWaveObjectives.MediumObjectives[WaveNum-1].PossibleObjectives.Length > 0;

	case GL_Long:
		return PresetWaveObjectives.LongObjectives[WaveNum-1].PossibleObjectives.Length > 0;

	default:
		return false;
	};
}

/*****************************************************************************************************
* @name Map Mutator
*****************************************************************************************************/

final event ModifySeasonalEventId(out int EventId)
{
	if (ZedSeasonalThemeId != SEI_None)
	{
		EventId = ZedSeasonalThemeId;
	}
}

final event ModifyGameClassBossAIClassList(out array< class<KFPawn_Monster> > GameClassBossAIClassList)
{
	if (MapMutatorClass != none)
	{
		MapMutatorClass.static.ModifyGameClassBossAIClassList(GameClassBossAIClassList);
	}
}

final event ModifyAIDoshValue(out float AIDoshValue)
{
	if (MapMutatorClass != none)
	{
		MapMutatorClass.static.ModifyAIDoshValue(AIDoshValue);
	}
}

/*****************************************************************************************************
* @name Objective Mode
*****************************************************************************************************/

simulated function int GetAppliedWaveNum()
{
	local KFGameReplicationInfo KFGRI;
	local int AppliedWaveNum;
	local WaveObjectivePair Wave;

	KFGRI = KFGameReplicationInfo(class'WorldInfo'.static.GetWorldInfo().GRI);
	AppliedWaveNum = KFGRI.WaveNum;

	if (KFGRI.IsObjectiveMode())
	{
		Wave = ObjectiveModeObjectives[KFGRI.WaveNum-1];
		if (Wave.AppliedWaveNum >= 0)
		{
			AppliedWaveNum = Wave.AppliedWaveNum;
		}
	}
	else
	{
		if (bUsePresetObjectives)
		{
			switch (KFGRI.GameLength)
			{
			case GL_Short:
				Wave = PresetWaveObjectives.ShortObjectives[KFGRI.WaveNum-1];
				break;

			case GL_Normal:
				Wave = PresetWaveObjectives.MediumObjectives[KFGRI.WaveNum-1];
				break;

			case GL_Long:
				Wave = PresetWaveObjectives.LongObjectives[KFGRI.WaveNum-1];
				break;
			};

			if (Wave.AppliedWaveNum > 0)
			{
				AppliedWaveNum = Wave.AppliedWaveNum;
			}
		}
	}

	return AppliedWaveNum;
}

DefaultProperties
{
	WaveSpawnPeriod=2.0f

	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_BAJ_KF2_5_3')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_BAJ_KF2_8')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_D_Disunion')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_BTA_MountainOfSouls')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_Collapsing')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_CrossToBear')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_Death')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_FireToMySoul')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_IHaveSeen')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_Infected')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_LifeWar')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_NotI')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_Ribcage')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_SomeoneToHate')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_ThisIKnow')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_TurnYourBack')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_DH_WeDontCare')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_FFAK_BitterEnd')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_ID_DeathWillReign')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_ID_Murderer')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_ID_RavenousDisease')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_Bloodwork')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_DeathMachine')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_Despair')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_Flatline')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_HandOfTheDead')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_NotMyOwn')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_SomethingMore')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_TheReaping')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_LS_YourWar')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_RG_CloneMutation')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_RG_CreepingZed')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_RG_KillOrBeKilled')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action113')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action115')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action116')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action119')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action201')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action205')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action206')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action207')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action208')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action209')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action210')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action300')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action302')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action303')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action304')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action305')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI_Z_Action306')
	ActionMusicTracks.Add(KFMusicTrackInfo'WW_MACT_Default.TI__SJ_Infectious')

	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_RG_InTheDark')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Ambient200')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Ambient202')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Ambient203')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Ambient300')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Ambient301')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Ambient302')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Ambient303')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_AssemblyLab')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_Malformitate')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_MomentaryReprieve')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_PhantomSecurity')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_Z_RendezvousPoint')
	AmbientMusicTracks.Add(KFMusicTrackInfo'WW_MAMB_Default.TI_SJ_Menace')

	TraderVoiceGroupClassPath="KFGameContent.KFTraderVoiceGroup_Default"
}
