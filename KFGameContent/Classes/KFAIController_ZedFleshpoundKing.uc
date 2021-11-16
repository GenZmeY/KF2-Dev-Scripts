//=============================================================================
// KFAIController_ZedFleshpoundKing
//=============================================================================
// AI Controller for the Fleshpound King
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Matt 'Squirrlz' Farber
//=============================================================================
class KFAIController_ZedFleshpoundKing extends KFAIController_ZedFleshpound;

const MaxPhases = 4;

/** Cached pawn reference */
var KFPawn_ZedFleshpoundKing MyPawn;

/** Next time we should attempt to do a beam attack */
var protected float NextBeamCheckTime;

/** Last time we ticked the beam attack check code */
var transient protected float LastBeamTickTime;

/** How long to wait after the first time seeing a player before we should attempt to check for a beam attack */
var const vector2d BeamAttackWaitTimeRange;

/** Minimum angle a target must be from the fleshpound's rotation when starting the chest beam attack */
var const float MinChestBeamTargetAngle;

/** Maximum height offset a target can be from the fleshpound to start the chest beam attack*/
var const float MaxChestBeamHeightOffset;

/** Current battle phase, 0 = start, indexes into PhaseThresholds*/
var int CurrentPhase;

/** Health percentage cutoffs for the current fight phase */
var const float PhaseThresholds[MaxPhases];

/** Phase at which the chest beam can start */
var const int ChestBeamMinPhase;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    local KFGameReplicationInfo KFGRI;
    super.Possess(inPawn, bVehicleTransition);

    // Play entrance animation
    KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    if (KFGRI != none && KFGRI.WaveNum >= KFGRI.WaveMax)
    {
        class'AICommand_BossTheatrics'.static.DoTheatrics(self, THEATRIC_Entrance);
    }

    MyPawn = KFPawn_ZedFleshpoundKing(inPawn);
}

function bool AmIAllowedToSuicideWhenStuck()
{
	return false;
}

/** We have seen a player -- start checking for beam attack */
event SeePlayer( Pawn Seen )
{
	super.SeePlayer( Seen );

	if( NextBeamCheckTime == 0.f )
	{
		NextBeamCheckTime = WorldInfo.TimeSeconds + RandRange( BeamAttackWaitTimeRange.X, BeamAttackWaitTimeRange.Y );
	}
}

/** Tick our chest beam attack */
simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

    //Don't attack while we're in theatrics
    if (CommandList != none && CommandList.class == class'AICommand_BossTheatrics')
    {
        return;
    }

	if( NextBeamCheckTime > 0.f && `TimeSince(LastBeamTickTime) > 0.2f && WorldInfo.TimeSeconds >= NextBeamCheckTime )
	{
		LastBeamTickTime = WorldInfo.TimeSeconds;
		CheckForBeamAttack();
	}
}

/** Decides if we should attempt a beam attack */
function CheckForBeamAttack()
{
	local Pawn P, BestTarget;
	local float MaxBeamTargetDistSQ, Dist, DotAngle, Rating, BestRating;
	local vector Projection, PawnDir;

	// Don't allow beam attack during special moves
	if( MyKFPawn.IsDoingSpecialMove() )
	{
		return;
	}

    // Don't allow beam when not in the correct phase
    if (CurrentPhase < ChestBeamMinPhase)
    {
        return;
    }

    // Don't allow beam while enraged
    if (RagePlugin.bIsEnraged)
    {
        return;
    }

	// Subtract 15% from the max beam length when choosing targets due to wind up time
	MaxBeamTargetDistSQ = Square( class'KFSM_FleshpoundKing_ChestBeam'.default.MaxBeamLength * 0.85f );

	PawnDir = vector( MyKFPawn.Rotation );
	BestRating = -1.f;

	foreach WorldInfo.AllPawns( class'Pawn', P )
	{
		// Only target enemies
		if( P.GetTeamNum() == MyKFPawn.GetTeamNum() || !P.IsAliveAndWell() )
		{
			continue;
		}

		// Only target things that are targetable
		if (!P.CanAITargetThisPawn(MyKFPawn.Controller))
		{
			continue;
		}

		Projection = P.Location - MyKFPawn.Location;
		Dist = VSizeSQ( Projection );

		// Distance check
		if( Dist > MaxBeamTargetDistSQ )
		{
			continue;
		}

		// Within field of view and not behind geometry and within allowed height offset
		DotAngle = PawnDir dot Normal(Projection);
		if( DotAngle > MinChestBeamTargetAngle && MyKFPawn.FastTrace(P.Location, MyKFPawn.Location) && Abs(P.Location.Z - MyKFPawn.Location.Z) < MaxChestBeamHeightOffset )
		{
			// Lower ratings are better (smaller distance and closer to center of pawn's rotation)
			Rating = Dist * ( 1.f - DotAngle );
			if( BestRating == -1.f || Rating < BestRating )
			{
				BestRating = Rating;
				BestTarget = P;
			}
		}
	}

	// Target check
	if( BestTarget != none )
	{
		if( BestTarget != Enemy )
		{
			ChangeEnemy( BestTarget, false );
		}

		// Start blasting!
		NextBeamCheckTime = 0.f;
		class'AICommand_FleshpoundKing_ChestBeamAttack'.static.ChestBeamAttack( self );
	}
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
    local float CurrentHealth;
    super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, damageType, Momentum);

    //Can still transition
    if (MyPawn != none && CurrentPhase + 1 < MaxPhases)
    { 
        CurrentHealth = float(MyPawn.Health) / float(MyPawn.HealthMax);
        if (CurrentHealth < PhaseThresholds[CurrentPhase + 1])
        {
            TransitionToPhase(CurrentPhase + 1);
        }
    }
}

/** Handle any updates caused by a phase transition */
function TransitionToPhase(int NewPhase)
{
    CurrentPhase = NewPhase;
    MyPawn.CurrentPhase = NewPhase;

    MyPawn.SpawnSubWave();

    switch (NewPhase)
    {
    case 3:
        MyPawn.ActivateShield();
        break;
    }
}

function NotifySpecialMoveEnded( KFSpecialMove SM )
{
    super.NotifySpecialMoveEnded( SM );

    if (SM.Handle == 'KFSM_Zed_Boss_Theatrics')
    {
        //Start initial phase if theatrics just finished
        TransitionToPhase(0);
    }

    // This ensures that we don't attempt to do a beam attack immediately after a special move ends
    if( NextBeamCheckTime < WorldInfo.TimeSeconds + 2.0f )
    {
    	NextBeamCheckTime = WorldInfo.TimeSeconds + 2.0f + fRand();
    }
}

/** Whether enemy switch commands can be run */
function bool CanSwitchEnemies()
{
	return (MyKFPawn != none && MyKFPawn.SpecialMove != SM_HoseWeaponAttack);
}

/** Overridden to stop retargeting enemies when firing the chest beam */
event bool FindNewEnemy()
{
	if( !CanSwitchEnemies() )
	{
		return false;
	}

	return super.FindNewEnemy();
}

/** Overridden to stop retargeting enemies when firing the chest beam */
event bool SetEnemy( Pawn NewEnemy )
{
	if( !CanSwitchEnemies() )
	{
		return false;
	}

	return super.SetEnemy( NewEnemy );
}

/** Overridden to stop retargeting enemies when firing the chest beam */
event ChangeEnemy( Pawn NewEnemy, optional bool bCanTaunt=true )
{
	if( !CanSwitchEnemies() )
	{
		return;
	}

	super.ChangeEnemy( NewEnemy, bCanTaunt );
}

/** Forces a target change, bypasses our custom ChangeEnemy() */
function ForceTargetChange( Pawn NewEnemy )
{
	super.ChangeEnemy( NewEnemy, false );
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

DefaultProperties
{
	BeamAttackWaitTimeRange=(X=1.5f, Y=3.0f)
	MinChestBeamTargetAngle=0.77f
    MaxChestBeamHeightOffset=64.f

    PhaseThresholds[0]=1
    PhaseThresholds[1]=0.75 //0.65 //0.75
    PhaseThresholds[2]=0.6 //0.5
    PhaseThresholds[3]=0.3 //0.2 //0.25 //0.1

    ChestBeamMinPhase=2

    SpawnRagedChance(`DIFFICULTY_NORMAL)=1.f
    SpawnRagedChance(`DIFFICULTY_HARD)= 1.f
    SpawnRagedChance(`DIFFICULTY_SUICIDAL)= 1.f
    SpawnRagedChance(`DIFFICULTY_HELLONEARTH)= 1.f
}