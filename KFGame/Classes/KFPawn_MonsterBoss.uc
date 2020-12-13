//=============================================================================
// KFPawn_MonsterBoss
//=============================================================================
// A base (abstract) class for bosses based on unique designs.  Bosses based on
//      existing zeds simply implement the boss interface.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_MonsterBoss extends KFPawn_Monster
	abstract
	native(Pawn)
    implements(KFInterface_MonsterBoss);

`include(KFGameDialog.uci)

var KFPlayerController KFPC; //used to notify UI

/** Info for minion wave spawning */
struct native BossMinionWaveInfo
{
    /** The minion wave to spawn for Phase 1 healing*/
    var	KFAIWaveInfo				PhaseOneWave;
    /** The minion wave to spawn for Phase 2 healing*/
    var	KFAIWaveInfo				PhaseTwoWave;
    /** The minion wave to spawn for Phase 3 healing*/
    var	KFAIWaveInfo				PhaseThreeWave;
    /** The minion wave to spawn for Phase 4 healing*/
    var	KFAIWaveInfo				PhaseFourWave;
};

/** Waves to summon at each stage by difficulty level*/
var	BossMinionWaveInfo				SummonWaves[4];

/** The base amount of minions to spawn when boss goes into hunt and heal mode */
var             vector2D                 NumMinionsToSpawn;

/** The current phase of the battle we're in */
var repnotify   int 				CurrentBattlePhase;

/** Scalar to apply to attack range when there is only one player remaining in a multiplayer game */
var 			float				LastPlayerAliveAttackRangeScale;

/** Set when the speed increase timer detects that there is only one player left */
var protected 	float 				LastPlayerAliveStartTime;

/** How long after spawn before the boss starts to increase its speed */
var protected const float			TimeUntilSpeedIncrease;

/** How high the speed limit can go */
var protected const float 			SpeedLimitScalar;

/** How much to increase the sprint speed by (per minute) when the speed increase timer elapses */
var protected const	float 			SpeedPctIncreasePerMinute;

/** The final sprint speed after being modified by SetMonsterDefaults() */
var protected 	float 				ActualSprintSpeed;

//Intro Camera
var bool bUseAnimatedCamera;
var vector AnimatedBossCameraOffset;

//Localization
var localized array<string> BossCaptionStrings;

replication
{
	if( bNetDirty )
		CurrentBattlePhase;
}

/************************************
* @name	KFInterface_MonsterBoss
************************************/
//Quick access to a pawn reference
simulated function KFPawn_Monster GetMonsterPawn()
{
    return self;
}

simulated function string GetRandomBossCaption()
{
    if (default.BossCaptionStrings.Length <= 0)
    {
        return "";
    }

    return default.BossCaptionStrings[Rand(default.BossCaptionStrings.Length)];
}

//Status Accessors
static simulated event bool IsABoss()
{
    return true;
}

simulated function float GetHealthPercent()
{
    return float(Health) / float(HealthMax);
}

//Intro functionality
/** Turn on the boss camera animation mode */
simulated function SetAnimatedBossCamera(bool bEnable, optional vector CameraOffset)
{
    bUseAnimatedCamera = bEnable;
    if (bUseAnimatedCamera)
    {
        AnimatedBossCameraOffset = CameraOffset;
    }
    else
    {
        AnimatedBossCameraOffset = vect(0, 0, 0);
    }
}

/** Whether this pawn is in theatric camera mode */
simulated function bool UseAnimatedBossCamera()
{
    return bUseAnimatedCamera;
}

/** The name of the socket to use as a camera base for theatric sequences */
simulated function name GetBossCameraSocket()
{
    return 'TheatricCameraRootSocket';
}

/** The relative offset to use for the cinematic camera */
simulated function vector GetBossCameraOffset()
{
    return AnimatedBossCameraOffset;
}

function OnZedDied(Controller Killer)
{
    super.OnZedDied(Killer);

    KFGameInfo(WorldInfo.Game).BossDied(Killer);
}

function KFAIWaveInfo GetWaveInfo(int BattlePhase, int Difficulty)
{
    switch (BattlePhase)
    {
    case 1:
        return SummonWaves[Difficulty].PhaseOneWave;
        break;
    case 2:
        return SummonWaves[Difficulty].PhaseTwoWave;
        break;
    case 3:
        return SummonWaves[Difficulty].PhaseThreeWave;
        break;
    }

    return none;
}

/** Returns the number of minions to spawn based on number of players */
function byte GetNumMinionsToSpawn()
{
    return byte(Lerp(NumMinionsToSpawn.X, NumMinionsToSpawn.Y, fMax(WorldInfo.Game.NumPlayers, 1) / float(WorldInfo.Game.MaxPlayers)));
}

//
simulated event ReplicatedEvent(name VarName)
{
	if( VarName == nameOf(CurrentBattlePhase) )
	{
		OnBattlePhaseChanged();
	}
	else
	{
		Super.ReplicatedEvent( VarName );
	}
}

// Called immediately before gameplay begins.
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();
	OnBattlePhaseChanged();
	KFPC = KFPlayerController(GetALocalPlayerController());
}

// Mostly indistinguishable from PreBeginPlay().  Following Pawn conventions only one is 'simulated'
simulated event PostBeginPlay()
{
	Super.PostBeginPlay();
}

static simulated function SetupHealthBar(KFInterface_MonsterBoss BossRef)
{
	local KFPawn_Monster BossMonster;
	local KFPlayerController LocalKFPC;

	BossMonster = KFPawn_Monster(BossRef);
	if (BossMonster != none && BossMonster.WorldInfo.NetMode != NM_DedicatedServer)
	{
		LocalKFPC = KFPlayerController(BossMonster.GetALocalPlayerController());
		if(LocalKFPC.MyGFxHUD != none && LocalKFPC.MyGFxHUD.BossHealthBar != none)
		{
			LocalKFPC.MyGFxHUD.BossHealthBar.SetBossPawn(BossRef);

			if (!KFGameReplicationInfo(BossMonster.WorldInfo.GRI).ShouldSetBossCamOnBossSpawn())
			{
				LocalKFPC.MyGFxHUD.BossHealthBar.OnNamePlateHidden();
			}
		}
	}
}

/** Called from Possessed event when this controller has taken control of a Pawn */
function PossessedBy( Controller C, bool bVehicleTransition )
{
	Super.PossessedBy( C, bVehicleTransition );

	PlayBossMusic();
	PlayBossEntranceTheatrics(self);

	// Set a timer to begin increasing this boss's speed after enough time has elapsed
	if( !IsHumanControlled() )
	{
		ActualSprintSpeed = SprintSpeed;
		SetTimer( TimeUntilSpeedIncrease, false, nameOf(Timer_IncreaseSpeed) );
	}
}

static function PlayBossEntranceTheatrics(KFInterface_MonsterBoss BossRef)
{
	local KFPawn_Monster BossMonster;

	BossMonster = KFPawn_Monster(BossRef);
	if (BossMonster != none && KFGameReplicationInfo(BossMonster.WorldInfo.GRI).ShouldSetBossCamOnBossSpawn())
	{
		BossMonster.ServerDoSpecialMove(SM_BossTheatrics);
	}
}

/** Gradually increases sprint speed */
function Timer_IncreaseSpeed()
{
	SetTimer( 10.f, false, nameOf(Timer_IncreaseSpeed) );

	if( IsOnePlayerLeftInTeamGame() )
	{
		if( LastPlayerAliveStartTime == 0.f )
		{
			LastPlayerAliveStartTime = WorldInfo.TimeSeconds;
		}

		// Adjust sprint speed but don't let it go below original or higher than 2x
		SprintSpeed = fClamp( ActualSprintSpeed + ((`TimeSince(LastPlayerAliveStartTime) / 60.f)
						* (ActualSprintSpeed * SpeedPctIncreasePerMinute)), ActualSprintSpeed, ActualSprintSpeed * SpeedLimitScalar );
	}
	else
	{
		LastPlayerAliveStartTime = 0.f;
		SprintSpeed = ActualSprintSpeed;
	}
}

/** sends any notifications to anything that needs to know this pawn has taken damage */
function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> DamageType, vector Momentum, Actor DamageCauser)
{
	Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum, DamageCauser);

	`DialogManager.PlayBossTakeDamageDialog( self );
}


/** Return true if AI can target this pawn */
function bool CanAITargetThisPawn(Controller TargetingController)
{
    if( TargetingController.Pawn.IsSameTeam( self ) )
    {
        // Don't let weaker zeds target a boss!!!
        return false;
    }

    return Super.CanAITargetThisPawn(TargetingController);
}

simulated function PlayDyingSound()
{
    if (!HasMouth())
    {
        return;
    }

    super.PlayDyingSound();
}

/** Called when pawn dies or is destroyed. Overloaded to call OnBattlePhaseChanged. */
simulated function TerminateEffectsOnDeath()
{
	super.TerminateEffectsOnDeath();

	OnBattlePhaseChanged();
}

/** Reapply active gameplay related MIC params (e.g. when switching to the gore mesh) */
simulated function UpdateGameplayMICParams()
{
	super.UpdateGameplayMICParams();
	OnBattlePhaseChanged();
}

/** Returns current battle phase, used by KFPawnAnimInfo */
simulated function int GetCurrentBattlePhase()
{
	return CurrentBattlePhase;
}

/** Called when current battle phase changes */
/* Network: ALL
 */
simulated function OnBattlePhaseChanged()
{
	UpdateBattlePhaseOnLocalPlayerUI();
}

simulated function UpdateBattlePhaseOnLocalPlayerUI()
{
	if( KFPC == none || KFPC.MyGFxHUD == none || KFPC.MyGFxHUD.bossHealthBar == none )
	{
		return;
	}

    KFPC.MyGFxHUD.bossHealthBar.UpdateBossBattlePhase(CurrentBattlePhase);
}

/** Returns the attack range scalar when there is only one player remaining */
function float GetAttackRangeScale()
{
	if( IsOnePlayerLeftInTeamGame() )
	{
		return LastPlayerAliveAttackRangeScale;
	}

	return 1.f;
}

/** Returns true if there is only one player remaining in a multiplayer game */
function bool IsOnePlayerLeftInTeamGame()
{

	if( WorldInfo.Game.NumPlayers > 1 )
	{
		return KFGameInfo(WorldInfo.Game).GetLivingPlayerCount() == 1;
	}

	return false;
}

/** Similar to IsOnePlayerLeftInTeamGame(), but more expensive and can be called on clients */
native function bool LocalIsOnePlayerLeftInTeamGame();

/**
 * This pawn has died.
 */
function bool Died( Controller Killer, class<DamageType> DamageType, vector HitLocation )
{
	local bool result;

	result = super.Died( Killer, DamageType, HitLocation );

	ClearTimer( nameOf(Timer_IncreaseSpeed) );

	return result;
}

/** Play music for this boss (overridden for each boss) */
function PlayBossMusic();

// bosses cannot be decapitated
function CauseHeadTrauma(float BleedOutTime=5.f);
simulated function PlayHeadAsplode();

function PlayGrabDialog()
{
	`DialogManager.PlayBossGrabDialog( self );
}

function PlayHealDialog()
{
	`DialogManager.PlayBossHealDialog( self );
}

function PlayLeapedDialog()
{
	`DialogManager.PlayBossLeapedDialog( self );
}

function PlayLandedDialog()
{
	`DialogManager.PlayBossLandedDialog( self );
}

function PlayGrabbedPlayerDialog( KFPawn_Human Target );

function PlayGrabKilledDialog();


simulated function string GetIconPath()
{
	return "ZED_Patriarch_UI.ZED-VS_Icon_Boss";
}

defaultproperties
{
`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Patriarch';
`endif

	Begin Object Name=KFPawnSkeletalMeshComponent
		// Enabling kinematic for physics interaction while alive.  (see also MinDistFactorForKinematicUpdate)
		bUpdateKinematicBonesFromAnimation=true
	End Object

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_BossTheatrics)		= class'KFGame.KFSM_Zed_Boss_Theatrics'
		//SpecialMoveClasses(SM_RecoverFromRagdoll)	= None
		//SpecialMoveClasses(SM_Knockdown)			= None
	End Object
	bAlwaysRelevant=true

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Boss

    bWeakZedGrab=false

	// ---------------------------------------------
	// Last Player Remaining Difficulty
	LastPlayerAliveAttackRangeScale=0.75f
	TimeUntilSpeedIncrease=60.0
	SpeedPctIncreasePerMinute=0.20
	SpeedLimitScalar=1.30

	bCanBePinned=false
}