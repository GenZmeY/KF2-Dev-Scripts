//=============================================================================
// KFAIController_ZedBoss
//=============================================================================
// Base Zed boss AIController
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
//
class KFAIController_ZedBoss extends KFAIController_Monster
	native(AI);

/*********************************************************************************************
* Battle phases
**********************************************************************************************/

/** TRUE if we've already summoned minions this battle phase */
var bool bSummonedThisPhase;

/** NPC has lost sight of current enemy */
event EnemyNotVisible()
{
	local KFPawn_Human HumanEnemy;

	// EnemyNotVisible can be triggered rapidly due to minor obstructions like streetlights,
	// so try to account for that by only having the player say something after a period of
	// visibility
	if( `TimeSince(EnemyVisibilityTime) > 1.f )
	{
		HumanEnemy = KFPawn_Human(Enemy);
		if( HumanEnemy != none )
		{
			`DialogManager.PlayLoseSightOfBossDialog( MyKFPawn, HumanEnemy );
			`DialogManager.PlayBossLoseSightOfDialog( MyKFPawn, HumanEnemy );
		}
	}

	super.EnemyNotVisible();
}

event bool SetEnemy( Pawn NewEnemy )
{
	if( NewEnemy != Enemy )
	{
		`DialogManager.PlayBossChallengeDialog( MyKFPawn );
	}

	return super.SetEnemy( NewEnemy );
}

/** Bosses should not be processed in frustration mode */
function UpdateSprintFrustration( optional byte bForceFrustrationState=255 )
{
}

function PlayDamagePlayerDialog( class<DamageType> DmgType );

/** Stub debug command to advance battle phase */
function DebugNextPhase();

/** Stop summoning zeds */
function Timer_StopSummoningZeds()
{
    MyKFGameInfo.SpawnManager.StopSummoningBossMinions();
}

function PawnDied(Pawn InPawn)
{
	super.PawnDied(InPawn);

	Timer_StopSummoningZeds();
}

/*********************************************************************************************
*  Victory
********************************************************************************************* */
function EnterZedVictoryState()
{
	ClearMovementInfo();
	if( CommandList != None )
	{
		AbortCommand( CommandList );
	}

	DisableMeleeRangeEventProbing();
	ChangeEnemy(none);
	MyKFPawn.SetSprinting( false );

    // Keep boss looking at the camera
    LockPawnRotationTo(MyKFPawn.Rotation);
    MyKFPawn.SetRemoteViewPitch(0);

    // Force end any special moves
    if( MyKFPawn.IsDoingSpecialMove() )
    {
    	MyKFPawn.EndSpecialMove();
    }

    GotoState( 'ZedVictory', 'Begin');
}

state ZedVictory
{
Begin:
    Sleep(0.1f);
    if (MyKFPawn != none)
    {
        class'AICommand_BossTheatrics'.static.DoTheatrics(self, THEATRIC_Victory, -1);
    }
}

/*********************************************************************************************
*  Possess
********************************************************************************************* */
event Possess(Pawn inPawn, bool bVehicleTransition)
{
    local KFGameReplicationInfo KFGRI;
    super.Possess(inPawn, bVehicleTransition);

    // Play entrance animation
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none && KFGRI.IsBossWave() && KFGRI.ShouldSetBossCamOnBossSpawn())
    {
        class'AICommand_BossTheatrics'.static.DoTheatrics(self, THEATRIC_Entrance);
    }
}

DefaultProperties
{
	FrustrationThreshold=0
    bCanTeleportCloser=false
    LowIntensityAttackCooldown=0
}
