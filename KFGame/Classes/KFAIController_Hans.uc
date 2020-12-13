//=============================================================================
// KFAIController_Hans
//=============================================================================
// Hans's AIController
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_Hans extends KFAIController_ZedBoss
	native(AI);

/*********************************************************************************************
* Initialization
********************************************************************************************* */
/** Cached copy of Hans pawn to avoid casting */
var transient KFPawn_ZedHansBase	MyHansPawn;

/** Destination navigation point Hans wants to throw a grenade from */
//var NavigationPoint RangedAttackMoveGoal;
var vector          RangedAttackMoveLoc;
var bool			bFoundGrenadeThrowLocation;
var bool			bWantsToThrowGrenade;

var vector          CalcedGreanadeTossVelForNavMeshLoc;
var float           TimeCalcedGreanadeTossVelWasFound;
var vector          EnemysLocationWhenTossVelWasFound;

/*********************************************************************************************
* Sprint behavior
**********************************************************************************************/

/** How long Hans should wait to start sprinting after losing sight of his enemy */
var             float           LostSightSprintDelay;

/*********************************************************************************************
* Gun shooting related variables brought over from AICommand_HansGunAttack.
* Put here because the shoot AICommand keeps getting pushed onto the stack and
* resetting these vars
**********************************************************************************************/

/** The time a new barrage started */
var             float           BarrageStartTime;
/** The last time we started firing our gun */
var             float           LastFireTime;
/** The time we started drawing our gun */
var             float			StartDrawGunsTime;
/** The time we started this gun attack */
var             float			StartGunAttackTime;
/** Cache our last target */
var             Actor           LastTarget;
/** The time we first saw our current target we are shooting at */
var             float			TimeFirstSawTarget;

/** Last time we changed weapon stances */
var             float			LastStanceChangeTime;
/** Can't change stances more often than this */
var()   	    float			StanceChangeCooldown;

/** Last time we finished a melee attack */
var             float			LastAttackMoveFinishTime;
/** Wait this long to do a gun attack after doing a melee attack */
var()   	    float			PostAttackMoveGunCooldown;

/*********************************************************************************************
* Enemy Tracking
**********************************************************************************************/

/**
 *	Struct to track AI knowledge of visible enemies
 */
struct native TrackedEnemyInfo
{
	/** Enemy we're tracking */
	var KFPawn         TrackedEnemy;
	/** Enemy we're tracking */
	var float          LastTimeVisible;
	/** Enemy we're tracking */
	var vector         LastVisibleLocation;
	/** The last time we fired on this enemy */
	var float          LastTimeFiredOn;
	/** The last time we tossed a grenade at this enemy */
	var float          LastTimeGrenadeAttacked;
	/** How often we've chosen this enemy as a target recently */
	var int            NumTimesEngagedRecently;
};

/** List of tracked enemies that have recently been seen */
var array<TrackedEnemyInfo> RecentlySeenEnemyList;

/** The last enemy we gunned at that was recently seen */
var KFPawn LastRecentlySeenEnemyGunned;

/** The last enemy we grenaded that was recently seen */
var KFPawn LastRecentlySeenEnemyGrenaded;

/** How often to update RecentlySeenEnemyList */
var() float RecentSeenEnemyListUpdateInterval;

/** Last time we updated the RecentlySeenEnemyList*/
var float LastRecentSeenEnemyListUpdateTime;

/** The last time we changed to a new target */
var float LastRetargetTime;

/** How long to wait before attempting to find a new target */
var vector2d RetargetWaitTimeRange;

/** The actual retarget wait time after last retarget time has been set */
var transient float ActualRetargetWaitTime;

/*********************************************************************************************
* Vars for handing the timing of firing, when to shoot, the shooting cadence, etc
**********************************************************************************************/
/** Min length of a burst for this weapon when used by AI. Randomly used to calculate the BurstAmount */
var(Firing)	    int				MinBurstAmount;
/** Max length of a burst for this weapon when used by AI. Randomly used to calculate the BurstAmount */
var(Firing)	    int				MaxBurstAmount;
/** How long to wait between bursts when this weapon is used by AI */
var(Firing)	    float			BurstWaitTime;
/** How long to wait between barrages (groups of bursts) when this weapon is used by AI */
var(Firing)	    float			BarrageWaitTime;

/** Interp curve to scale how long Hans waits between barrages for different ranges **/
var() InterpCurveFloat BarrageWaitDistanceCurve;

/** Interp curve to scale how long Hans waits between bursts for different ranges **/
var() InterpCurveFloat BurstWaitDistanceCurve;

/** How long a barrage (groups of bursts) will last */
var(Firing)	    float			BarrageLength;
/** Tracks the current burst and what size it is */
var     	    int				BurstAmount;
/** How long to wait to stop firing after losing sight of an enemy */
var(Firing)	    float			LostSightStopFireDelay;
/** The fire mode the last time we fired our gun */
var             float           LastFireMode;
/** How long to wait after starting to draw our guns to fire */
var(Firing)	    float			DrawGunFireDelay;
/** How long to wait after starting to see an enemy to fire */
var(Firing)	    float			TargetAquisitionDelay;
/** How long this gun attack should last at the max */
var(Firing)	    float			MaxGunAttackLength;
/** How long to wait after drawing the guns before allowing a grenade toss to interrupt them */
var(Firing)	    float			GrenadeGunInterruptDelay;

/** The range the zed needs to be within to start shooting bullets */
var float StartShootingRange;

/** The range the zed needs to be outside to disallow shooting bullets */
var float MinShootingRange;

/** min delay between shooting attacks */
var float ShootingCooldown;

enum EHansNadeType
{
    HNT_None,
    HNT_HEGrenade,
    HNT_NerveGas,
    HNT_Smoke,
    HNT_HEGrenadeBarrage,
    HNT_NerveGasBarrage,
    HNT_SmokeBarrage,
};

/* The grenade attack type we have queued up to do */
var EHansNadeType CurrentNadeAttackType;

/* How often to check if we want to do a grenade attack */
var() float GrenadeAttackEvalInterval;

/* Last time we evaluated if we wanted to do a grenade attack*/
var float LastGrenadeAttackEvalTime;

/** Whether we've already thrown a smoke grenade barrage this hunt and heal phase */
var bool bHasUsedSmokeScreenThisPhase;

/*********************************************************************************************
* Fleeing
**********************************************************************************************/

/** TRUE if flee is in progress */
var bool bFleeing;

/** TRUE if flee was interrupted (to attack, etc) */
var bool bWantsToFlee;

/** Set to true once the flee has been completed */
var bool bHasFledThisPhase;

/** How long we should flee */
var float MinFleeDuration, MaxFleeDuration;

/** Maximum flee distance */
var float MaxFleeDistance;

/** The start time of the last flee */
var float FleeStartTime;

/** The total cumulative time spent fleeing */
var float TotalFleeTime;

/** Whether the flee was interrupted by the targeting loop */
var bool bFleeInterrupted;

cpptext
{
	/** Overridden to allow grab attack check */
	virtual UBOOL TickMeleeCombatDecision( FLOAT DeltaTime );
}

/*********************************************************************************************
* Initialization, Pawn Possession, and Destruction
********************************************************************************************* */

/** Set MyHansPawn to avoid casting */
event Possess( Pawn inPawn, bool bVehicleTransition )
{
	if( KFPawn_ZedHansBase(inPawn) != none )
	{
		MyHansPawn = KFPawn_ZedHansBase( inPawn );
	}
	else
	{
		`warn( GetFuncName()$"() attempting to possess "$inPawn$", but it's not a KFPawn_ZedHansBase class! MyHansPawn variable will not be valid." );
	}

    // Initialize retarget time
    LastRetargetTime = WorldInfo.TimeSeconds;
    ActualRetargetWaitTime = RandRange( RetargetWaitTimeRange.X, RetargetWaitTimeRange.Y );

	super.Possess( inPawn, bVehicleTransition );
}

function PawnDied( Pawn InPawn )
{
	if( MyHansPawn != none )
	{
		`DialogManager.PlayBossDeathDialog( MyHansPawn );
		MyHansPawn = None;
	}
	Super.PawnDied( InPawn );
}

/** Clean up all internal objects and references when the AI is destroyed
	TBD: Look into using Unpossessed() to do this! */
simulated event Destroyed()
{
	MyHansPawn = None;

	super.Destroyed();
}

/** Overridden to allow grab attack check */
/*
function DoMeleeAttack( optional Pawn NewEnemy, optional Actor InTarget, optional byte AttackFlags )
{
	local float DistSq;

	if( CommandList == None || AICommand(CommandList).bAllowedToAttack )
	{
		DistSq = VSizeSq( Enemy.Location - Pawn.Location );

		if( DistSq < 32400.f || DistSq > 10000.f )
		{
			if( CanGrabAttack() )
			{
				//	DumpCommandStack();
				DoGrabAttack();
				return;
			}
		}
	}
	super.DoMeleeAttack( NewEnemy, inTarget, AttackFlags );
}
*/

/** Start the throw grenade command, optionally for the grenade barrage attack */
function DoGrenadeThrow( optional bool bGrenadeBarrage )
{
    if( MyHansPawn != none )
    {
        MyHansPawn.SetActiveGrenadeClassGrenade();
    }

	if( class'AICommand_ThrowGrenade'.static.ThrowGrenade(self, bGrenadeBarrage ? 2 : 0) )
	{
        if( MyHansPawn != none )
        {
            MyHansPawn.BarrageTossCount=0;
            MyHansPawn.bDoingBarrage=bGrenadeBarrage;
        }
	}
}

/** Start the throw grenade command with smoke, optionally for the grenade barrage attack */
function DoSmokeGrenadeThrow( optional bool bGrenadeBarrage, optional bool bIsHuntAndHeal )
{
    local bool bThrowSuccess;

    if( MyHansPawn != none )
    {
        MyHansPawn.SetActiveGrenadeClassSmoke();
    }

    // Spawn some zeds if we need to
    bThrowSuccess = class'AICommand_ThrowGrenade'.static.ThrowGrenade(self, bGrenadeBarrage ? 1 : 0, bIsHuntAndHeal);

	if( bThrowSuccess )
	{
        if( MyHansPawn != none )
        {
            MyHansPawn.bPendingSmokeGrenadeBarrage=false;
            MyHansPawn.BarrageTossCount=0;
            MyHansPawn.bDoingBarrage=bGrenadeBarrage;
        }
	}
}

/** Notification from the pawn that it has taken damage */
function NotifyTakeHit( Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum )
{
    local float HealThreshold, HealthPct;

    super.NotifyTakeHit( InstigatedBy, HitLocation, Damage, damageType, Momentum );

    // When our health gets low, go hunt a player to draw life and enter the next battle phase
    if( !MyHansPawn.bHealedThisPhase && MyHansPawn.CurrentBattlePhase < 4 )
    {
        HealThreshold = MyHansPawn.BattlePhases[MyHansPawn.CurrentBattlePhase-1].HealThresholds[WorldInfo.Game.GetModifiedGameDifficulty()];
        HealthPct = GetHealthPercentage();

        // Summon minions if we haven't yet
        if( !bSummonedThisPhase && HealthPct < HealThreshold + 0.18f ) //0.16
        {
            MyHansPawn.SummonMinions();
            bSummonedThisPhase = true;

            // Fallback so zeds can't spawn forever
            SetTimer( 30.f, false, nameOf(Timer_StopSummoningZeds) );
        }

        // Enter hunt and heal mode if we've dropped below the health threshold
        if( HealthPct < HealThreshold )
        {
            MyHansPawn.SetHuntAndHealMode( true );
        }
    }
}

/** Special move has ended, whether cleanly or aborted */
function NotifySpecialMoveEnded(KFSpecialMove SM)
{
    super.NotifySpecialMoveEnded(SM);

    // Our guns are put away, toss some grenades
    if( !bWantsToFlee && !bFleeing && Enemy != None && MyHansPawn != none && MyHansPawn.bPendingSmokeGrenadeBarrage )
    {
        DoSmokeGrenadeThrow( true, true );
    }

    if( SM.Handle == 'KFSM_MeleeAttack'
        || SM.Handle == 'KFSM_Hans_GrenadeBarrage'
        || SM.Handle == 'KFSM_Hans_GrenadeHalfBarrage'
        || SM.Handle == 'KFSM_Hans_ThrowGrenade'
        || SM.Handle == 'KFSM_Taunt'
        || SM.Handle == 'KFSM_WalkingTaunt' )
    {
        LastAttackMoveFinishTime = WorldInfo.TimeSeconds;
    }

    // Handle flee interruptions
    if( !bWantsToFlee )
    {
        // Retarget if it's been enough time since we changed targets
        if( SM.Handle == 'KFSM_MeleeAttack' && `TimeSince(LastRetargetTime) > ActualRetargetWaitTime )
        {
            CheckForEnemiesInFOV( 3000.f, -1.f, 1.f, true );
        }
    }
    else if( MyHansPawn.bGunsEquipped )
    {
        class'AICommand_Hans_GunStance'.static.SetGunStance( self, 0 );
    }
    else if( PendingDoor == none && !bFleeing )
    {
        Flee();

        // Play dialog indicating the next phase has started
        if( !bFleeInterrupted )
        {
            `DialogManager.PlayHansSmokeDialog( MyHansPawn, true );
        }
    }

    // Reset flee interrupted flag in case this was an attack special move
    bFleeInterrupted = false;

    // Evaluate sprinting whenever we finish a special move so sprinting will be snappy!
    EvaluateSprinting();
}

/** Evaluate if we should start/stop sprinting, and then set the sprinting flag */
function EvaluateSprinting()
{
    if( MyKFPawn == none || !MyKFPawn.IsAliveAndWell() )
    {
        return;
    }

    if( bFleeing || bWantsToFlee )
    {
        MyKFPawn.SetSprinting( true );
    }
    else if( Enemy != none )
	{
		if( ShouldSprint() )
		{
			MyKFPawn.SetSprinting( true );
		}
		else
		{
			MyKFPawn.SetSprinting( false );
		}
	}
}

/** NPC has seen a player - use SeeMonster for similar notifications about seeing any pawns (currently not in use) */
event SeePlayer( Pawn Seen )
{
    local int EnemyListIndex;
    local TrackedEnemyInfo NewTrackedEnemy;
    local KFPawn KFP;

    Super.SeePlayer(Seen);

	// Evaluate sprinting when visibility changes
    EvaluateSprinting();

	// Reject potential enemy if it's invalid or not on our team, or if it's already my current enemy, or if my pawn is dead or invalid
	if( Seen == none || !Seen.IsAliveAndWell() || Pawn.IsSameTeam( Seen ) ||
		Pawn == none || !Pawn.IsAliveAndWell() || !Seen.CanAITargetThisPawn(self) )
	{
		return;
	}

    KFP = KFPawn(Seen);

    // Add or update recently seen enemy in the list for tracking ranged enemies
    if( KFP != none )
    {
        EnemyListIndex = RecentlySeenEnemyList.Find('TrackedEnemy', KFP);

        if( EnemyListIndex == INDEX_NONE )
        {
            NewTrackedEnemy.TrackedEnemy = KFP;
            NewTrackedEnemy.LastTimeVisible = WorldInfo.TimeSeconds;
            NewTrackedEnemy.LastVisibleLocation = Seen.Location;
            RecentlySeenEnemyList[RecentlySeenEnemyList.Length] = NewTrackedEnemy;
        }
        else
        {
            RecentlySeenEnemyList[EnemyListIndex].LastTimeVisible = WorldInfo.TimeSeconds;
            RecentlySeenEnemyList[EnemyListIndex].LastVisibleLocation = Seen.Location;
        }
    }

    // Throw down our smoke screen before going after a player to heal
    if( bHasFledThisPhase && MyHansPawn.bInHuntAndHealMode && !bHasUsedSmokeScreenThisPhase )
    {
        bHasUsedSmokeScreenThisPhase = true;        
        SetTimer( 2.f + fRand(), false, nameOf(Timer_DoHuntAndHealSmokeGrenadeThrow) );
    }
}

/** Throws a smoke grenade barrage after waiting a short time */
function Timer_DoHuntAndHealSmokeGrenadeThrow()
{
    // Toss some smoke grenades out and summon some minions to help
    // while I try and find someont to suck some life from. If Hans
    // has his guns out, set the flag to wait til his guns are put
    // away before trying to throw the smoke grenade barrage and
    // Spawn the minion zeds
    if( !MyHansPawn.bGunsEquipped && !MyHansPawn.IsImpaired() && !MyHansPawn.IsIncapacitated() )
    {
        DoSmokeGrenadeThrow( true );
    }
    else
    {
        MyHansPawn.bPendingSmokeGrenadeBarrage = true;
    }
}

/** Start the throw grenade command with nerve gas, optionally for the grenade barrage attack */
function DoNerveGasGrenadeThrow( optional bool bGrenadeBarrage )
{
    if( MyHansPawn != none )
    {
        MyHansPawn.SetActiveGrenadeClassNerveGas();
    }

	if( class'AICommand_ThrowGrenade'.static.ThrowGrenade(self, bGrenadeBarrage ? 1 : 0) )
	{
        if( MyHansPawn != none )
        {
            MyHansPawn.BarrageTossCount=0;
            MyHansPawn.bDoingBarrage=bGrenadeBarrage;
        }
	}
}

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting */
function bool ShouldSprint()
{
    local float RangeToEnemy;

	if( Enemy != none && MyHansPawn != none && !MyHansPawn.bIsHeadless && !MyHansPawn.bEmpPanicked )
	{
		// Always sprint if we're trying to track down players to heal from
        if( MyHansPawn.bInHuntAndHealMode )
		{
			//`log(self@GetFuncName()$" bInHuntAndHealMode should sprint!");
            return true;
		}

		// Sprint if we can't see our enemy
		if( LastEnemySightedTime == 0 || `TimeSince(LastEnemySightedTime) > LostSightSprintDelay )
		{
			//`log(self@GetFuncName()$" don't see any enemy should sprint = true! LastEnemySightedTime: "$LastEnemySightedTime$" TimeSince(LastEnemySightedTime): "$`TimeSince(LastEnemySightedTime));
            return true;
		}

        // No sprinting with the guns out!
        if( MyHansPawn.bGunsEquipped )
        {
            RangeToEnemy = VSize( Enemy.Location - Pawn.Location );

            // Sprint if we're too close to shoot
            if( RangeToEnemy > StartShootingRange*MyHansPawn.GetAttackRangeScale() || rangeToEnemy < MinShootingRange )
            {
                //`log(self@GetFuncName()$" guns out but enemy not in gun range. Should sprint = true!");
                return true;
            }
            else
            {
                //`log(self@GetFuncName()$" guns out enemy not in gun range. Should sprint = false!");
                return false;
            }
        }

        //`log(self@GetFuncName()$" Generic should sprint depending on phase: "$MyHansPawn.DesireSprintingInThisPhase());
        return MyHansPawn.DesireSprintingInThisPhase();
	}
	//`log(self@GetFuncName()$" Generic should sprint = false!");
	return false;
}

/*********************************************************************************************
* Combat
**********************************************************************************************/

/*********************************************************************************************
* Shooting
********************************************************************************************* */

/**
 * Handle the firing of the pawn's weapon
 */
function FireTimer()
{
    local float UsedBarrageWaitTime, UsedBurstWaitTime;

	// if we no longer have an Enemy or a pawn return
	if ( Enemy == none || Pawn == none )
	{
		// We've got nothing to Fire at
		ClearFireTiming();
		return;
	}

	// Lost sight of enemy, stop firing
	if( !CanSee(Enemy) && (WorldInfo.TimeSeconds - LastEnemySightedTime >= LostSightStopFireDelay) )
	{
		//`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() Can't see the enemy, stopping shooting TimeDiff: "$`TimeSince(LastEnemySightedTime)$" LostSightStopFireDelay = "$LostSightStopFireDelay);
		ClearFireTiming();
		TimeFirstSawTarget=0;
        // Clear any previous barrage so we start firing again immediately after reacquiring the target
        BarrageStartTime = 0;
		return;
	}

    // Don't fire during a Melee attack!
    if( MyKFPawn.IsDoingMeleeAttack() )
    {
		ClearFireTiming();
		return;
    }

	// if there is a friendly in the way don't fire!
//	if( IsFriendlyBlockingFireLine() )
//	{
//		// `CombatLog(Self$" "$GetStateName()$" "$GetFuncName()$"() Friendly blocking fire line, not shooting");
//		SetTimer(0.5, false, 'FireTimer');
//		return;
//	}

    // Store some info so we can time target acquisition
    if( LastTarget == none || TimeFirstSawTarget == 0 )
    {
        LastTarget = Enemy;
        TimeFirstSawTarget = WorldInfo.TimeSeconds;
    }

    // Wait to fire until the TargetAquisitionDelay is over
    if( TimeFirstSawTarget > 0 && `TimeSince(TimeFirstSawTarget) < TargetAquisitionDelay )
    {
        //`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() Waiting to aquire target, TimeDiff: "$`TimeSince(TimeFirstSawTarget)$" TargetAquisitionDelay = "$TargetAquisitionDelay);
        SetTimer(TargetAquisitionDelay - `TimeSince(TimeFirstSawTarget), false, nameof(FireTimer), self);
        Pawn.StopFiring();
        // Clear any previous barrage so we start firing again immediately after reacquiring the target
        BarrageStartTime = 0;
        return;
    }

    // Pause between groups of bursts to give the firing a good cadence
    if( BarrageStartTime > 0 && `TimeSince(BarrageStartTime) > BarrageLength )
    {
        if( Enemy != none && Pawn != none  )
        {
            UsedBarrageWaitTime = BarrageWaitTime * EvalInterpCurveFloat(BarrageWaitDistanceCurve, VSize(Pawn.Location - Enemy.Location));
            //`log("Barrage Shooting at enemy that is "$VSize(Pawn.Location - Enemy.Location)/100.0$" meters away BarrageWait is "$UsedBarrageWaitTime$" scale is "$EvalInterpCurveFloat(BarrageWaitDistanceCurve, VSize(Pawn.Location - Enemy.Location)));
        }
        else
        {
            UsedBarrageWaitTime = BarrageWaitTime;

        }

        SetTimer(UsedBarrageWaitTime, false, nameof(FireTimer), self);

        BarrageStartTime = 0;
        Pawn.StopFiring();
        //`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() Pausing between baragges");

        return;
    }
    else if( BarrageStartTime == 0 )
    {
        BarrageStartTime = WorldInfo.TimeSeconds;
    }

	// Reset the burst settings when we finish a burst
	if( BurstAmount == 0 )
	{
		//`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() Burst amount is 0");

		BurstAmount = RandRange(MinBurstAmount,MaxBurstAmount);

        // See if we can no longer shoot at our target when a burst ends
        if( !CanPerformShotAttack() )
        {
            //`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() BurstAmount hit zero, and CanPerformShotAttack is false so stopping shooting");
            ClearFireTiming();
            // Clear any previous barrage so we start firing again immediately after reacquiring the target
            BarrageStartTime = 0;
        }
        // Set up the next burst
        else
        {

            UsedBurstWaitTime = BurstWaitTime + ((FRand() * BurstWaitTime * 0.15) - (BurstWaitTime * 0.3));

            if( Enemy != none && Pawn != none  )
            {
                UsedBurstWaitTime = UsedBurstWaitTime * EvalInterpCurveFloat(BurstWaitDistanceCurve, VSize(Pawn.Location - Enemy.Location));
                //`log("Burst Shooting at enemy that is "$VSize(Pawn.Location - Enemy.Location)/100.0$" meters away BurstWaitTime is "$UsedBurstWaitTime$" scale is "$EvalInterpCurveFloat(BurstWaitDistanceCurve, VSize(Pawn.Location - Enemy.Location)));
            }

        	//`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() BurstAmount hit zero, stopping firing. New BurstAmount is: "$BurstAmount);
        	SetTimer(UsedBurstWaitTime, false, nameof(FireTimer), self);
    		Pawn.StopFiring();

    		// Select a new enemy 50% of the time when a burst ends
            if( FRand() < 0.50 )
    		{
                SelectNewGunFireEnemy(KFPawn(Enemy));
    		}
		}
		return;
	}
	// if we can see our Enemy and we're facing our Enemy and we've waited long enough to shoot again
	if ( !Pawn.NeedToTurn(GetAimingLocation()) && WorldInfo.TimeSeconds - LastFireTime > Pawn.Weapon.FireInterval[LastFireMode] )
	{
		// Shoot at our Enemy and record the Fire Time
		Pawn.BotFire(true);
		LastFireMode = 0;
		// `Log("Time since last fire = "$(WorldInfo.TimeSeconds - LastFireTime));
		LastFireTime = WorldInfo.TimeSeconds;
		//`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() Shooting!!!!! BurstAmount is: "$BurstAmount);

		SetTimer(Pawn.Weapon.FireInterval[LastFireMode] * BurstAmount, false, nameof(FireTimer), self);
		BurstAmount = 0;

		`DialogManager.PlayBeingShotAtDialog( KFPawn_Human(Enemy), MyKFPawn );
	}
	else
	{
		//`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() Not Shooting NeedToTurn = "$Pawn.NeedToTurn(Enemy.Location)$" Last Fire Diff = "$(WorldInfo.TimeSeconds - LastFireTime)$" FireInterval = "$Pawn.Weapon.FireInterval[0]);
		SetTimer(0.1, false, nameof(FireTimer), self);
	}
}

/**
 * Clear firing cycle
 */
function ClearFireTiming()
{
    SetTimer(0.0, false, nameof(FireTimer), self);
	SetTimer(0.0, false, nameof(StartFireTiming), self);
	if( Pawn != none )
	{
		Pawn.StopFiring();
	}
}

/** Set a new enemy, returns false potential enemy is a player and AI is set to ignore players */
event bool SetEnemy( Pawn NewEnemy )
{
    // Don't let Hans switch enemies in the middle of draining his current enemy,
    // unless that enemy is dead
    if( !CanSwitchEnemies()
        || (MyKFPawn != none && MyKFPawn.IsDoingSpecialMove(SM_GrappleAttack) && Enemy != none
        && Enemy.IsAliveAndWell() && Enemy.CanAITargetThisPawn(self)) )
    {
        return false;
    }

    return Super.SetEnemy( NewEnemy );
}

/** Overridden to stop retargeting enemies when fleeing or cloaked */
event ChangeEnemy( Pawn NewEnemy, optional bool bCanTaunt = true )
{
    local Pawn OldEnemy;

    if( !CanSwitchEnemies() )
    {
        return;
    }

    OldEnemy = Enemy;

    super.ChangeEnemy( NewEnemy, bCanTaunt );

    if( OldEnemy != Enemy )
    {
        LastRetargetTime = WorldInfo.TimeSeconds;
        ActualRetargetWaitTime = RandRange( RetargetWaitTimeRange.X, RetargetWaitTimeRange.Y );
    }
}

/**
 * Pick a different visible enemy to fire at so we can cycle between enemies
 */
function SelectNewGunFireEnemy( KFPawn CurrentEnemy )
{
    local int RandIdx, i;
    local array<TrackedEnemyInfo> TargetCandidates;
//    local Vector	CamLoc;
//	local Rotator	CamRot;
//	local Vector	X, Y, Z;
	local int EnemyListIndex;

    // Randomly pick another visible enemy to shoot at
    if( RecentlySeenEnemyList.Length > 0 )
    {
    	// Validate targets to shoot
        for( i = RecentlySeenEnemyList.Length-1; i >= 0; i-- )
    	{
            if( RecentlySeenEnemyList[i].TrackedEnemy == none
                || !RecentlySeenEnemyList[i].TrackedEnemy.IsAliveAndWell()
                || !RecentlySeenEnemyList[i].TrackedEnemy.CanAITargetThisPawn(self) )
            {
                RecentlySeenEnemyList.Remove(i,1);
                continue;
            }
            else if( !MyHansPawn.NeedToTurnEx(RecentlySeenEnemyList[i].LastVisibleLocation, 0.0) )
            {
                TargetCandidates[TargetCandidates.Length] = RecentlySeenEnemyList[i];
            }
    	}

    	// Clear out this pawn if it was the last one we fired at and it was engaged recently
        for( i = TargetCandidates.Length-1; i >= 0; i-- )
    	{
            if( TargetCandidates.Length > 1 && TargetCandidates[i].TrackedEnemy == LastRecentlySeenEnemyGunned
                && `TimeSince(TargetCandidates[i].LastTimeFiredOn) < 3.0 )
            {
                TargetCandidates.Remove(i,1);
            }
    	}

    	// Target selection debugging
        // Get camera location/rotation
//    	GetPlayerViewPoint( CamLoc, CamRot );
//    	GetAxes( CamRot, X, Y, Z );
//      FlushPersistentDebugLines();
//    	DrawDebugCone(CamLoc,X,500.0, Acos(0.0), Acos(0.0),16,MakeColor(0,255,0,255),true);

        if( TargetCandidates.Length > 0 )
        {
            RandIdx = Rand(TargetCandidates.Length);
            //`log("Selected random gunfire target index "$RandIdx$" Pawn: "$TargetCandidates[RandIdx].TrackedEnemy);

            LastRecentlySeenEnemyGunned = TargetCandidates[RandIdx].TrackedEnemy;

            if( LastRecentlySeenEnemyGunned != none )
            {
                EnemyListIndex = RecentlySeenEnemyList.Find('TrackedEnemy', LastRecentlySeenEnemyGunned);

                if( EnemyListIndex != INDEX_NONE )
                {
                    RecentlySeenEnemyList[EnemyListIndex].LastTimeFiredOn = WorldInfo.TimeSeconds;
                }
            }
        }
    }
}

/**
 * Returns the location this AI should be aiming at to shoot its enemy.
 */
function vector GetAimingLocation()
{
	local KFPawn KFP;
	local vector AimingLocation;
	local int EnemyListIndex;

	KFP = KFPawn(Enemy);

    // Flag the last guy we selected to fire at and aim at him
    if( LastRecentlySeenEnemyGunned != none )
    {
        EnemyListIndex = RecentlySeenEnemyList.Find('TrackedEnemy', LastRecentlySeenEnemyGunned);

        if( EnemyListIndex != INDEX_NONE )
        {
            RecentlySeenEnemyList[EnemyListIndex].LastTimeFiredOn = WorldInfo.TimeSeconds;

            // We recently selected this guy to fire on
            if( `TimeSince(RecentlySeenEnemyList[EnemyListIndex].LastTimeFiredOn) < 1.0 )
            {
                KFP = LastRecentlySeenEnemyGunned;
            }
        }
    }

	if( KFP == none )
	{
		if( Focus != none )
		{
			AimingLocation = Focus.Location;
		}
		else if( Pawn != none )
		{
			AimingLocation = Pawn.Location + vector( Pawn.Rotation ) * 128;
		}
	}
	else
	{
		AimingLocation = KFP.Location + Vect(0,0,1) * KFP.BaseEyeHeight * 0.5;//KFP.Mesh.GetBoneLocation(KFP.HeadBoneName,0);
	}

	return AimingLocation;
}

/**
 * Start a firing cycle
 */
function StartFireTiming()
{
	// Check to see if its the first time we have fired, or the first time we've fired this attack.
	// If that is the case, fire now, then let the FireTimer handle any subsequent fires
	if( Pawn !=  none && Pawn.Weapon != none  )
	{
		if( `TimeSince( LastFireTime ) > (Pawn.Weapon.FireInterval[0] + BurstWaitTime + BurstWaitTime * 0.3) )
		{
			//`log(Self$" "$GetStateName()$" "$GetFuncName());
			BurstAmount = RandRange(MinBurstAmount,MaxBurstAmount);
			FireTimer();

		}
		else
		{
			//`log(Self$" "$GetStateName()$" "$GetFuncName()$" ?????????????????????????????? Not starting fire timing!!!");
		}
	}
}

/**
 * Validate the next gun shot attack
 */
function bool CanPerformShotAttack(optional bool bStart)
{
	local float rangeToEnemy;

    // No guns when fleeing
    if( bFleeing || bWantsToFlee )
    {
        return false;
    }

    // Don't start shooting if hans hasn't drawn his gun yet, or is already trying to fire
    if( bStart && ( Pawn.IsFiring()
                || IsTimerActive(nameof(FireTimer), self) || IsTimerActive(nameof(StartFireTiming), self)) )
    {
        //`log("bStart not shooting because: TimeSince(StartDrawGunsTime): "$`TimeSince(StartDrawGunsTime)$" <  DrawGunFireDelay: "$DrawGunFireDelay$" Pawn.IsFiring(): "$Pawn.IsFiring()$" FireTimer Active: "$IsTimerActive(nameof(FireTimer), self)$" StartFireTiming Active: "$IsTimerActive(nameof(StartFireTiming), self));
        return false;
    }

    // Don't start shooting if Hans just did a melee attack
    if( bStart && (`TimeSince(LastAttackMoveFinishTime) < PostAttackMoveGunCooldown) )
    {
        return false;
    }

    // Don't let us shoot if Hans hasn't had his guns out long enough
	if( `TimeSince(StartDrawGunsTime) < DrawGunFireDelay )
	{
		return false;
	}

    // Don't shoot while sprinting
    if( MyKFPawn != none && MyKFPawn.bIsSprinting )
    {
        return false;
    }

	if( Enemy != none )
	{
		if( bStart && LastShotTime > 0 && (`TimeSince(LastShotTime) < ShootingCooldown) )
		{
			return false;
		}

		if( MyKFPawn.IsImpaired() )
		{
			return false;
		}

		rangeToEnemy = VSize(Enemy.Location - MyKFPawn.Location);

		if( rangeToEnemy < StartShootingRange*MyHansPawn.GetAttackRangeScale() && rangeToEnemy > MinShootingRange && !MyKFPawn.IsDoingMeleeAttack() )
		{
			if( CanSee(Enemy) )
			{
				return true;
			}
			else if( (WorldInfo.TimeSeconds - LastEnemySightedTime) >= LostSightStopFireDelay )
        	{
        		//`Log(Self$" "$GetStateName()$" "$GetFuncName()$"() Can't see the enemy, can't shoot TimeDiff: "$`TimeSince(LastEnemySightedTime)$" LostSightStopFireDelay = "$LostSightStopFireDelay);
        		TimeFirstSawTarget=0;
        	}
		}
	}

	return false;
}

/**
 * Can I do a stance change right now
 */
function bool CanStanceChange()
{
    return (LastStanceChangeTime == 0 || (`TimeSince(LastStanceChangeTime) > StanceChangeCooldown));
}

/** Override to tick the ranged combat system */
simulated function Tick( FLOAT DeltaTime )
{
	Super.Tick(DeltaTime);

	if( Role == ROLE_Authority )
	{
	   TickRangedCombatDecision();
	}
}

/** Tick the ranged combat system */
function TickRangedCombatDecision()
{
    local int i;

    // Update the ranged enemy visibility tracking
    // TODO: update this slower if we aren't doing an attack!
    if( LastRecentSeenEnemyListUpdateTime == 0 || `TimeSince(LastRecentSeenEnemyListUpdateTime) > RecentSeenEnemyListUpdateInterval )
    {
        LastRecentSeenEnemyListUpdateTime = WorldInfo.TimeSeconds;

    	for( i = RecentlySeenEnemyList.Length-1; i >= 0; i-- )
    	{
    	   if( RecentlySeenEnemyList[i].TrackedEnemy == none
            || !RecentlySeenEnemyList[i].TrackedEnemy.IsAliveAndWell()
            || !RecentlySeenEnemyList[i].TrackedEnemy.CanAITargetThisPawn(self)
            || `TimeSince(RecentlySeenEnemyList[i].LastTimeVisible) > 5.0 )
    	   {
    	       RecentlySeenEnemyList.Remove(i,1);
    	   }
    	   else if( CanSee(RecentlySeenEnemyList[i].TrackedEnemy) )
    	   {
    	       RecentlySeenEnemyList[i].LastVisibleLocation = RecentlySeenEnemyList[i].TrackedEnemy.Location;
               RecentlySeenEnemyList[i].LastTimeVisible = WorldInfo.TimeSeconds;
    	   }
    	}
    }

    // No grenades or guns when fleeing
    if( bFleeing || bWantsToFlee )
    {
        return;
    }

    //Don't attack while we're in theatrics
    if (CommandList != none && CommandList.class == class'AICommand_BossTheatrics')
    {
        return;
    }

    if( Enemy != None && (LastGrenadeAttackEvalTime == 0 || `TimeSince(LastGrenadeAttackEvalTime) > GrenadeAttackEvalInterval) )
    {
        LastGrenadeAttackEvalTime = WorldInfo.TimeSeconds;

        if( SetupGrenadeAttack() )
        {
            if( CurrentNadeAttackType == HNT_HEGrenade )
            {
                DoGrenadeThrow( false );
            }
            else if( CurrentNadeAttackType == HNT_HEGrenadeBarrage )
            {
                DoGrenadeThrow( true );
            }
            else if( CurrentNadeAttackType == HNT_NerveGas )
            {
                DoNerveGasGrenadeThrow( false );
            }
            else if( CurrentNadeAttackType == HNT_NerveGasBarrage )
            {
                DoNerveGasGrenadeThrow( true );
            }
            else if( CurrentNadeAttackType == HNT_Smoke )
            {
                DoSmokeGrenadeThrow( false );
            }
        }
    }

    TickGunSystem();
}

/** Tick the gun attack system which handles drawing/putting away the weapon, starting the shooting cycle, etc */
function TickGunSystem()
{
	local KFPawn_ZedHansBase HansPawn;
	local KFSpecialMove curMove;
    local float rangeToEnemy;
    //local vector EyeLocation;
    local bool bGrenadeAttackInterrupt;

	if( MyKFPawn.SpecialMoves.Length > MyKFPawn.SpecialMove )
	{
		curMove = MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove];
	}
	else
	{
		curMove = none;
	}

    if( Pawn.Physics == PHYS_Walking )
    {
        HansPawn = KFPawn_ZedHansBase(MyKFPawn);

		// Aiming debugging
        /*EyeLocation = MyKFPawn.Location + vect(0,0,1) * MyKFPawn.BaseEyeHeight;

        if( Focus == none )
        {
            if( IsZero(GetFocalPoint()) )
            {
                DrawDebugLine( EyeLocation, EyeLocation + normal( GetFocalPoint()) * 5000.f, 255, 0, 0, false );
            }
            else
            {
                DrawDebugLine( EyeLocation, EyeLocation + normal( GetFocalPoint() - EyeLocation ) * 5000.f, 0, 255, 0, false );
            }
        }
        else
        {
            DrawDebugLine( EyeLocation, Focus.Location, 255, 255, 0, false );
        }*/

        // Don't shoot if we're performing a special move that prevents it
        if( curMove != none && curMove.bDisablesWeaponFiring )
        {
            //`log("Not shooting because special move disallows it");
            if( Pawn.IsFiring() || IsTimerActive(nameof(FireTimer), self) || IsTimerActive(nameof(StartFireTiming), self) )
            {
                ClearFireTiming();
                // Clear any previous barrage so we are eligible to firing again right after special move is over
                BarrageStartTime = 0;
            }

            return;
        }

		// Make sure we're not in the middle of switching stances with the weapon, or doing boss theatrics
        if( HansPawn != none && (curMove == none || !MyKFPawn.IsDoingSpecialMove(SM_ChangeStance) && !MyKFPawn.IsDoingSpecialMove(SM_BossTheatrics)) )
		{
            // If we're firing at our target, aim at that location
            if( Pawn.IsFiring() || IsTimerActive(nameof(FireTimer), self) || IsTimerActive(nameof(StartFireTiming), self) )
            {
        		Focus = none;
        		SetFocalPoint( GetAimingLocation() );
            }
            // Switch back to aiming at our enemy if we're not moving to a pathnode
            else if( Focus == none )
            {
                Focus = Enemy;
            }

            if( Enemy != none )
            {
                rangeToEnemy = VSize(Enemy.Location - MyKFPawn.Location);
            }
            else
            {
                // If there is not enemy just act like they are out of range
                rangeToEnemy = MaxInt;
            }

            bGrenadeAttackInterrupt = GrenadeAttackInterruptGuns();

            // Put the guns away if the enemy is out of range
            if( HansPawn.bGunsEquipped && ((rangeToEnemy > StartShootingRange*MyHansPawn.GetAttackRangeScale() )
                || HansPawn.bInHuntAndHealMode || !HansPawn.CanUseGunsInThisPhase() || HansPawn.bPendingSmokeGrenadeBarrage
                || bGrenadeAttackInterrupt )
                && CanStanceChange() )
            {
                ClearFireTiming();
                class'AICommand_Hans_GunStance'.static.SetGunStance( self, 0 );
                //`log("Putting the guns away because there is an enemy too close");
            }
            // Draw the guns if the enemy is in range, and we're not waiting for a cooldown
            else if( !HansPawn.bGunsEquipped && (LastShotTime == 0 || (`TimeSince(LastShotTime) > ShootingCooldown))
                && rangeToEnemy < StartShootingRange*MyHansPawn.GetAttackRangeScale() && !HansPawn.bInHuntAndHealMode
                && HansPawn.CanUseGunsInThisPhase() && CanStanceChange() && !bGrenadeAttackInterrupt )
            {
                class'AICommand_Hans_GunStance'.static.SetGunStance( self, 1 );

                StartDrawGunsTime = WorldInfo.TimeSeconds;
                //`log("Drawing our guns StartDrawGunsTime = "$StartDrawGunsTime);

                // Clear any previous barrage so we are eligible to firing again right after special move is over
                BarrageStartTime = 0;

                // Don't start the cooldown again if we haven't already crossed the cooldown
                if( StartGunAttackTime == 0 || (`TimeSince(StartGunAttackTime) > MaxGunAttackLength) )
                {
                    StartGunAttackTime = WorldInfo.TimeSeconds;
                    //`log("Setting StartGunAttackTime = "$StartGunAttackTime);
                }
            }
            // Put the guns away if its time to cooldown or we can't use guns in this phase
            else if( StartGunAttackTime > 0 && (`TimeSince(StartGunAttackTime) > MaxGunAttackLength//StartDrawGunsTime > 0 && (`TimeSince(StartDrawGunsTime) > MaxGunAttackLength
                || !HansPawn.CanUseGunsInThisPhase() ) && CanStanceChange() )
            {
                //`log("Not shooting because we're in cooldown");
                if(  HansPawn.bGunsEquipped )
                {
                    ClearFireTiming();
                    LastShotTime = WorldInfo.TimeSeconds;
                    // Reset the draw guns time
                    StartDrawGunsTime = 0;
                    //`log("Putting our guns away StartDrawGunsTime = "$StartDrawGunsTime);

                    //`log("Putting Guns Away due to cooldown StartDrawGunsTime = "$StartDrawGunsTime$" LastShotTime = "$LastShotTime);

                    class'AICommand_Hans_GunStance'.static.SetGunStance( self, 0 );
                }
            }
            // All clear, start shooting!
            else if( HansPawn.bGunsEquipped && HansPawn.CanUseGunsInThisPhase()
                && CanPerformShotAttack(true) )
            {
            	//`DialogManager.PlayBeingShotAtDialog( KFPawn_Human(Enemy), HansPawn );
                StartFireTiming();
            }
        }
    }
}

/** Shows this KFAIController's RandgedAttack info on screen (see ShowAIInfo cheat) */
function DrawRangedAttackInfo( HUD Hud )
{
	local Canvas		Canvas;
    local float UsedShootCooldown;
	local KFSpecialMove curMove;
    local bool bMoveDisablesFiring;
    local float UsedGunAttackCooldown;
    local float UsedGlobalNadeAttackCooldown;
    local float UsedHENadeTossCooldown;
    local float UsedHENadeBarrageCooldown;
    local float UsedNerveGasTossCooldown;
    local float UsedNerveGasBarrageCooldown;
    local float UsedSmokeTossCooldown;
    local float UsedDrawGunsCooldown;
    local float UsedAttackMoveGunsCooldown;
    local float UsedGunTargetAquisitionCooldown;
    local int i;
    local vector EyeLocation;

	if( MyKFPawn == none )
	{
		return;
	}

	if( MyKFPawn.SpecialMoves.Length > MyKFPawn.SpecialMove )
	{
		curMove = MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove];
	}
	else
	{
		curMove = none;
	}

    // Don't shoot if we're performing a special move that prevents it
    if( curMove != none && curMove.bDisablesWeaponFiring )
    {
        bMoveDisablesFiring = true;
    }

	Canvas = HUD.Canvas;
	Canvas.Font = class'Engine'.Static.GetTinyFont();
	Canvas.SetPos(Canvas.SizeX * 0.7f, Canvas.SizeY * 0.25f);

	Canvas.SetDrawColor(0,200,50);

    DrawDebugText( HUD, "Ranged Combat for "$string(MyKFPawn.Name));
    DrawDebugText( HUD, "--------------------------------------" );
    DrawDebugText( HUD, "Battle Phase: "$MyHansPawn.CurrentBattlePhase );
    DrawDebugText( HUD, "--Guns--" );
    DrawDebugText( HUD, "Guns Equipped: "$MyHansPawn.bGunsEquipped$" Can Use Guns In This Phase: "$MyHansPawn.CanUseGunsInThisPhase() );
    DrawDebugText( HUD, "Stance Changing: "$MyKFPawn.IsDoingSpecialMove(SM_ChangeStance)$" CurrentMove: "$curMove$" bDisablesWeaponFiring: "$bMoveDisablesFiring );

    if(`TimeSince(StartDrawGunsTime) > DrawGunFireDelay)
    {
        UsedDrawGunsCooldown = 0;
    }
    else
    {
        UsedDrawGunsCooldown = DrawGunFireDelay - `TimeSince(StartDrawGunsTime);
    }

    if(`TimeSince(LastAttackMoveFinishTime) > PostAttackMoveGunCooldown)
    {
        UsedAttackMoveGunsCooldown = 0;
    }
    else
    {
        UsedAttackMoveGunsCooldown = PostAttackMoveGunCooldown - `TimeSince(LastAttackMoveFinishTime);
    }

    if(`TimeSince(LastShotTime) > ShootingCooldown)
    {
        UsedShootCooldown = 0;
    }
    else
    {
        UsedShootCooldown = ShootingCooldown - `TimeSince(LastShotTime);
    }

    if(`TimeSince(StartGunAttackTime) > MaxGunAttackLength)
    {
        UsedGunAttackCooldown = 0;
    }
    else
    {
        UsedGunAttackCooldown = MaxGunAttackLength - `TimeSince(StartGunAttackTime);
    }

    if(`TimeSince(TimeFirstSawTarget) > TargetAquisitionDelay)
    {
        UsedGunTargetAquisitionCooldown = 0;
    }
    else
    {
        UsedGunTargetAquisitionCooldown = TargetAquisitionDelay - `TimeSince(TimeFirstSawTarget);
    }

    DrawDebugText( HUD, "Time Til We Can Shoot : "$UsedShootCooldown$" Time Til We Must Stop Shooting: "$UsedGunAttackCooldown, (UsedShootCooldown <= 0) ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255)  );
    DrawDebugText( HUD, "Draw Guns Delay Til We Can Shoot : "$UsedDrawGunsCooldown, (UsedDrawGunsCooldown <= 0) ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "Attack Move Delay Til We Can Shoot : "$UsedAttackMoveGunsCooldown, (UsedAttackMoveGunsCooldown <= 0) ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "Target Aquisition Delay Til We Can Shoot : "$UsedGunTargetAquisitionCooldown, (UsedGunTargetAquisitionCooldown <= 0) ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "FireTimer : "$GetRemainingTimeForTimer(nameof(FireTimer))$" StartFireTiming: "$GetRemainingTimeForTimer(nameof(StartFireTiming)), MakeColor(0,255,0,255));


    DrawDebugText( HUD, "--Grenades--" );
    DrawDebugText( HUD, "CurrentNadeAttackType: "$CurrentNadeAttackType$" IsThrowingGrenade: "$MyHansPawn.IsThrowingGrenade() );
    if( Enemy != none )
    {
        DrawDebugText( HUD, "Good Line Of Site: "$CanSeeByPoints( Pawn.GetPawnViewLocation(), Enemy.Location, Rotator(Enemy.Location - Pawn.GetPawnViewLocation()))$" Too Close To Regular Nade: "$IsWithinAttackRange() );
    }
    else
    {
        DrawDebugText( HUD, "Good Line Of Site: No Enemy, Too Close To Regular Nade: "$IsWithinAttackRange() );
    }

    if( MyHansPawn.LastOffensiveNadeTime == 0 || `TimeSince(MyHansPawn.LastOffensiveNadeTime) > MyHansPawn.GlobalOffensiveNadeCooldown )
    {
        UsedGlobalNadeAttackCooldown = 0;
    }
    else
    {
        UsedGlobalNadeAttackCooldown =  MyHansPawn.GlobalOffensiveNadeCooldown - `TimeSince(MyHansPawn.LastOffensiveNadeTime);
    }

    if( MyHansPawn.LastHENadeTossTime == 0 || `TimeSince(MyHansPawn.LastHENadeTossTime) > MyHansPawn.HENadeTossCooldown )
    {
        UsedHENadeTossCooldown = 0;
    }
    else
    {
        UsedHENadeTossCooldown =  MyHansPawn.HENadeTossCooldown - `TimeSince(MyHansPawn.LastHENadeTossTime);
    }

    if( MyHansPawn.LastHENadeBarrageTime ==0 || `TimeSince(MyHansPawn.LastHENadeBarrageTime) > MyHansPawn.HENadeBarrageCooldown )
    {
        UsedHENadeBarrageCooldown = 0;
    }
    else
    {
        UsedHENadeBarrageCooldown =  MyHansPawn.HENadeBarrageCooldown - `TimeSince(MyHansPawn.LastHENadeBarrageTime);
    }

    if( MyHansPawn.LastNerveGasTossTime ==0 || `TimeSince(MyHansPawn.LastNerveGasTossTime) > MyHansPawn.NerveGasTossCooldown )
    {
        UsedNerveGasTossCooldown = 0;
    }
    else
    {
        UsedNerveGasTossCooldown =  MyHansPawn.NerveGasTossCooldown - `TimeSince(MyHansPawn.LastNerveGasTossTime);
    }

    if( MyHansPawn.LastNerveGasBarrageTime ==0 || `TimeSince(MyHansPawn.LastNerveGasBarrageTime) > MyHansPawn.NerveGasBarrageCooldown )
    {
        UsedNerveGasBarrageCooldown = 0;
    }
    else
    {
        UsedNerveGasBarrageCooldown =  MyHansPawn.NerveGasBarrageCooldown - `TimeSince(MyHansPawn.LastNerveGasBarrageTime);
    }

    if( MyHansPawn.LastSmokeTossTime ==0 || `TimeSince(MyHansPawn.LastSmokeTossTime) > MyHansPawn.SmokeTossCooldown )
    {
        UsedSmokeTossCooldown = 0;
    }
    else
    {
        UsedSmokeTossCooldown =  MyHansPawn.SmokeTossCooldown - `TimeSince(MyHansPawn.LastSmokeTossTime);
    }

    DrawDebugText( HUD, "Global Nade Cooldown Complete: "$MyHansPawn.OffensiveGrenadeCooldownComplete()$" GlobalNadeAttackCooldown: "$UsedGlobalNadeAttackCooldown, MyHansPawn.OffensiveGrenadeCooldownComplete() ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "Can Smoke Toss: "$MyHansPawn.CanSmokeTossInThisPhase()$" SmokeTossCooldown: "$UsedSmokeTossCooldown, MyHansPawn.CanSmokeTossInThisPhase() ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "Can Nerve Gas Toss: "$MyHansPawn.CanTossNerveGasInThisPhase()$" NerveGasTossCooldown: "$UsedNerveGasTossCooldown, MyHansPawn.CanTossNerveGasInThisPhase() ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "Can HE Grenade Toss: "$MyHansPawn.CanTossGrenadeInThisPhase()$" HENadeTossCooldown: "$UsedHENadeTossCooldown, MyHansPawn.CanTossGrenadeInThisPhase() ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "Can Nerve Gas Barrage: "$MyHansPawn.CanBarrageNerveGasInThisPhase()$" NerveGasBarrageCooldown: "$UsedNerveGasBarrageCooldown, MyHansPawn.CanBarrageNerveGasInThisPhase() ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );
    DrawDebugText( HUD, "Can HE Grenade Barrage: "$MyHansPawn.CanGrenadeBarrageInThisPhase()$" HENadeBarrageCooldown: "$UsedHENadeBarrageCooldown, MyHansPawn.CanGrenadeBarrageInThisPhase() ? MakeColor(0,255,0,255) : MakeColor(255,0,0,255) );

    DrawDebugText( HUD, "--RecentlySeenEnemyList--" );
	for( i = 0; i < RecentlySeenEnemyList.Length; i++ )
	{
        DrawDebugText( HUD, "TrackedEnemy #"$i$": "$RecentlySeenEnemyList[i].TrackedEnemy);
	    EyeLocation = MyKFPawn.Location + vect(0,0,1) * MyKFPawn.BaseEyeHeight;
        DrawDebugLine( EyeLocation, RecentlySeenEnemyList[i].LastVisibleLocation, 254, 89, 18, false );
	}
}


/*********************************************************************************************
* Grenades
**********************************************************************************************/

/** Return true if one of the standard (not smoke) grenade attack cooldowns is reached and we can attempt a nade throw*/
function bool GrenadeAttackInterruptGuns()
{
    // Don't interrupt the gun attack with the grenade attack if we just pulled the guns
    if( MyHansPawn.bGunsEquipped && `TimeSince(StartDrawGunsTime) < GrenadeGunInterruptDelay )
    {
        return false;
    }

    if( MyHansPawn.CanGrenadeBarrageInThisPhase() )
    {
        return true;
    }
    else if( MyHansPawn.CanBarrageNerveGasInThisPhase() )
    {
        return true;
    }
    else if( MyHansPawn.CanTossGrenadeInThisPhase() )
    {
        return true;
    }
    else if( MyHansPawn.CanTossNerveGasInThisPhase() )
    {
        return true;
    }

    return false;
}

/** Returns true if we can successfully set up a grenade attack */
function bool SetupGrenadeAttack()
{
	/** See if Hans can/should do a grenade attack right now*/
	if( MyHansPawn != none && Enemy != none && !MyHansPawn.IsDoingSpecialMove(SM_ChangeStance)
        && !MyHansPawn.IsThrowingGrenade() && !MyHansPawn.bGunsEquipped
        && CanSeeByPoints( Pawn.GetPawnViewLocation(), Enemy.Location, Rotator(Enemy.Location - Pawn.GetPawnViewLocation()) )
        && MyHansPawn.CacheGrenadeThrowLocation())
	{
        // Clear the last grenade attack type
        CurrentNadeAttackType = HNT_None;

        // Don't throw grenades up close, unless it's a smoke grenade during hunt and heal
        if( !IsWithinAttackRange() )
        {
            // Pick what kind of nade attack Hans should do
            if( MyHansPawn.CanGrenadeBarrageInThisPhase() )
            {
                CurrentNadeAttackType=HNT_HEGrenadeBarrage;
            }
            else if( MyHansPawn.CanBarrageNerveGasInThisPhase() )
            {
                CurrentNadeAttackType=HNT_NerveGasBarrage;
            }
            else if( MyHansPawn.CanTossGrenadeInThisPhase() )
            {
                CurrentNadeAttackType=HNT_HEGrenade;
            }
            else if( MyHansPawn.CanTossNerveGasInThisPhase() )
            {
                CurrentNadeAttackType=HNT_NerveGas;
            }
        }
        //Hans keeps tossing out smoke grenades occasionally when he's hunting a
        // player to heal from
        else
        {
            if( MyHansPawn.CanSmokeTossInThisPhase() )
            {
                CurrentNadeAttackType=HNT_Smoke;
            }
        }

        // Return true if we found a valid nade attack
        if( CurrentNadeAttackType != HNT_None )
        {
            return true;
        }
        else
        {
            return false;
        }
	}
	else
	{
	   return false;
	}
}

function DoStrike()
{
	local name AttackName;

	if( MyHansPawn != none && MyHansPawn.PawnAnimInfo != none )
	{
		AttackName = MyHansPawn.PawnAnimInfo.Attacks[PendingAnimStrikeIndex].Tag;

		// @todo: figure out a way to make this less hard-coded? (see also KFDialogManager::PlayHansKilledDialog)
		if( AttackName == 'Frenzy_Lunge' )
		{
			`DialogManager.PlayHansFrenzyDialog( MyHansPawn );
		}
        else if( AttackName == 'AOE' )
        {
            `DialogManager.PlayHansAOEDialog( MyHansPawn );
        }
	}

	super.DoStrike();
}

/**
 *  Used by movement commands to determine if NPC is close enough consider a strike
 *  Overridden so that Hans will move all the way to grab range and not get stuck.
 */
function bool IsWithinAttackRange()
{
	local float DistSqToEnemy;

    // Don't try to attack if our enemy isn't visible
    if( MyHansPawn == none || !bEnemyIsVisible )
    {
        return false;
    }

	// Don't grab players if you aren't in hunt and heal mode or are waiting for the smoke grenade barrage
    if( !MyHansPawn.bInHuntAndHealMode )
	{
	   return Super.IsWithinAttackRange();
	}

	// Check distance from enemy versus my grab range value.
	DistSqToEnemy = VSizeSq( Enemy.Location - Pawn.Location );
	if( DistSqToEnemy <= Square(MinDistanceToPerformGrabAttack) )
	{
		return true;
	}

	return false;
}

function bool CanAttackDestructibles()
{
    return !MyHansPawn.bGunsEquipped && bCanDoHeavyBump;
}

/*********************************************************************************************
* Battle-phase switching
**********************************************************************************************/

/** Overridden to handle door usage in flee state */
function NotifyAttackDoor( KFDoorActor Door )
{
    // We need to count up the total flee time so infinite fleeing isn't possible
    if( bFleeing )
    {
        TotalFleeTime = TotalFleeTime + (WorldInfo.TimeSeconds - FleeStartTime);
        bWantsToFlee = true;
        bFleeInterrupted = true;
        bFleeing = false;
        
        // Kill our flee and move commands
        AbortCommand( CommandList );

        // Allow melee again
        EnableMeleeRangeEventProbing();

        // Restart default command
        BeginCombatCommand( GetDefaultCommand(), "Restarting default command" );
    }

    super.NotifyAttackDoor( Door );
}

/** Overridden to handle door usage in flee state */
function bool DoorFinished()
{
    local bool bSuperFinished;

    bSuperFinished = super.DoorFinished();

    if( bWantsToFlee && !bFleeing )
    {
        if( MyHansPawn.IsDoingSpecialMove() )
        {
            MyHansPawn.EndSpecialMove();
        }
        Flee();
    }

    return bSuperFinished;
}

/**
 * Set Hans to the next phase in the battle
 */
function NextBattlePhase()
{
    // Set flee flags
    bHasFledThisPhase = false;
    MaxFleeDuration = RandRange( MinFleeDuration, MaxFleeDuration );
    bWantsToFlee = true;
    DisableMeleeRangeEventProbing();

    // Set smoke grenade barrage flag
    bHasUsedSmokeScreenThisPhase = false;
}

/** Whether enemy switch commands can be run */
function bool CanSwitchEnemies()
{
    return !bWantsToFlee && !bFleeing;
}

/* Starts Flee AICommand, with optional duration and distance */
function DoFleeFrom( actor FleeFrom,
    optional float FleeDuration,
    optional float FleeDistance,
    optional bool bShouldStopAtGoal=false,
    optional bool bFromFear=false )
{
    if( !bFromFear || !MyHansPawn.bInHuntAndHealMode )
    {
        super.DoFleeFrom( FleeFrom, FleeDuration, FleeDistance, bShouldStopAtGoal, bFromFear );
    }
}

/** Sets flee target if there is no enemy, starts flee command */
function Flee()
{
    local Actor FleeFromTarget;
    local float FleeDuration;
    local AICommand_SpecialMove AICSM;

    // Reset flee state
    bFleeing = false;
    bWantsToFlee = false;
    bFleeInterrupted = false;

    // We need a target to flee from
    Enemy = none;
    CheckForEnemiesInFOV( 3000.f, 0.2f, 1.f, true, false );
    if( Enemy == None )
    {
        SetEnemy( GetClosestEnemy() );
    }

    // Try to get an enemy, if not just choose a nearby navigation point (always flee!)
    if( Enemy != None )
    {
        FleeFromTarget = Enemy;
    }
    else
    {
        FleeFromTarget = class'NavigationPoint'.static.GetNearestNavToActor( MyHansPawn );
    }

    // Prevent timeout from interrupting flee
    AICSM = FindCommandOfClass( class'AICommand_SpecialMove' );
    if( AICSM != none )
    {
        AICSM.ClearTimeout();
    }

    // Abort all commands
    AbortCommand( CommandList );

    // Perform flee
    bFleeing = true;
    MyHansPawn.SetSprinting( true );
    DisableMeleeRangeEventProbing();

    FleeDuration = fMax( MaxFleeDuration - TotalFleeTime, 6.f );
    //`log("[FLEE] FleeDuration:"@FleeDuration);
    //`log("[FLEE] FleeStartTime:"@WorldInfo.TimeSeconds);
    FleeStartTime = WorldInfo.TimeSeconds;
    DoFleeFrom( FleeFromTarget, FleeDuration, MaxFleeDistance + Rand(MaxFleeDistance * 0.25f), true );
    EvaluateSprinting();

    // Constantly make sure we don't have a player trying to block us
    if( !IsTimerActive(nameOf(Timer_SearchForFleeObstructions)) )
    {
        SetTimer( 1.5f, false, nameOf(Timer_SearchForFleeObstructions) );
    }
}

/** Custom target searching when fleeing -- we only want to attack targets that are blocking our flee path */
function Timer_SearchForFleeObstructions()
{
    local KFPawn ObstructingEnemy;

    if( !bFleeing || bWantsToFlee || MyHansPawn.IsDoingSpecialMove() )
    {
        SetTimer( 0.25f, false, nameOf(Timer_SearchForFleeObstructions) );
        return;
    }

    // See if there's someone blocking us
    ObstructingEnemy = CheckForEnemiesInFOV( AttackRange * 1.1f, 0.5f, 1.f, false, false );
    if( ObstructingEnemy != none )
    {
        // We need to count up the total flee time so infinite fleeing isn't possible
        TotalFleeTime = TotalFleeTime + (WorldInfo.TimeSeconds - FleeStartTime);
        bFleeInterrupted = true;
        bFleeing = false;

        // Kill our flee and move commands
        AbortCommand( CommandList );

        // Set our new enemy
        ChangeEnemy( ObstructingEnemy, false );

        // Set our pending flee
        bWantsToFlee = true;

        // Sprint to new enemy
        MyHansPawn.SetSprinting( true );
        SetEnemyMoveGoal( self, true );
        EnableMeleeRangeEventProbing();

        // Restart default command
        BeginCombatCommand( GetDefaultCommand(), "Restarting default command" );

        // Give hans a little bit of time to flee after this attack
        SetTimer( 2.0f, false, nameOf(Timer_SearchForFleeObstructions) );
    }
    else
    {
        SetTimer( 0.25f, false, nameOf(Timer_SearchForFleeObstructions) );
    }
}


/** Command finished. Used to catch instances where the flee command is interrupted by another command */
function NotifyCommandFinished( AICommand FinishedCommand )
{
    if( !bWantsToFlee && bFleeing && PendingDoor == none && (ActorEnemy == none || ActorEnemy.bPendingDelete) && AICommand_Flee(FinishedCommand) != none )
    {
        // Add to our total flee time
        TotalFleeTime = TotalFleeTime + (WorldInfo.TimeSeconds - FleeStartTime);

        // Abort the flee command
        AbortCommand( FinishedCommand );

        // Cancel any special moves
        if( MyHansPawn.IsDoingSpecialMove() )
        {
            MyHansPawn.EndSpecialMove();
        }

        // Delay flee by a tiny bit to allow command to finish up
        SetTimer( 0.06f, false, nameOf(Flee), self );
    }
}

/** We have finished fleeing for one reason or another, notify pawn to heal */
function NotifyFleeFinished( optional bool bAcquireNewEnemy=true )
{
    local KFAISpawnManager SpawnManager;

    // Don't do additional cleanup if this wasn't a hunt and heal flee
    if( !MyHansPawn.bInHuntAndHealMode )
    {
        return;
    }

    // Restore flee flags to default
    bFleeing = false;
    bWantsToFlee = false;

    // Stop searching for targets
    ClearTimer( nameOf(Timer_SearchForFleeObstructions) );

    // Stop summoning minions
    SpawnManager = KFGameInfo(WorldInfo.Game).SpawnManager; 
    if( SpawnManager != none )
    {
        SpawnManager.StopSummoningBossMinions();
    }

    // Prevent infinite fleeing
    bHasFledThisPhase = true;

    // Find a new enemy and move to them
    if( bAcquireNewEnemy )
    {
        ChangeEnemy( GetClosestEnemy(), true );
    }

    // Allow melee again
    EnableMeleeRangeEventProbing();

    // Restart default command
    BeginCombatCommand( GetDefaultCommand(), "Restarting default command" );
}

/** Aborts the flee (shield was destroyed, etc) */
function CancelFlee( optional bool bAcquireNewEnemy=true )
{
    if( bFleeing )
    {
        bFleeing = false;
        bWantsToFlee = false;

        // Kill our flee command
        AbortCommand( FindCommandOfClass(class'AICommand_Flee') );

        // End flee as normal
        NotifyFleeFinished( bAcquireNewEnemy );
    }
    else
    {
        // Make sure hans doesn't try to flee again
        bWantsToFlee = false;
        bHasFledThisPhase = true;
    }
}

/**
 * Hans's prefers using health drain (grab) on players when he's wounded.  Currently he
 *	won't attempt this attack if he's already at full health
 */
event bool CanGrabAttack()
{
	local KFPawn KFPawnEnemy;
	local float DistSq;
	local vector HitLocation, HitNormal;
	local Actor HitActor;

    /** Don't try to grab while still fleeing */
    if( bFleeing || bWantsToFlee )
    {
        return false;
    }

	/** Hans shouldn't do this attack if at full health */
	if( Enemy == none || MyKFPawn == none || MyKFPawn.Health <= 0 || GetHealthPercentage() >= 1.f )
	{
		return false;
	}

	// Don't grab players if you aren't in hunt and heal mode or are waiting for the smoke grenade barrage
    if( MyHansPawn != none && (!MyHansPawn.bInHuntAndHealMode || MyHansPawn.bPendingSmokeGrenadeBarrage) )
	{
	   return false;
	}

	// If I'm dead, incapable of grabbing, or have no enemy, or my enemy is a player, or I'm busy doing a melee attack, refuse.
	if( (MyKFPawn == none || !MyKFPawn.bCanGrabAttack || MyKFPawn.Health <= 0) || (Enemy == none) || (Enemy != none && Pawn.IsSameTeam(Enemy)) )
	{
		return false;
	}

	KFPawnEnemy = KFPawn( Enemy );

	if( KFPawnEnemy != none && KFPawnEnemy.IsDoingSpecialMove(SM_GrappleVictim)
        && VSizeSq(MyHansPawn.Location - Enemy.Location) < Square(MinDistanceToPerformGrabAttack*1.5f) )
	{
        // End the move immediately so other zed stops grabbing our target!
        KFPawnEnemy.InteractionPawn.EndSpecialMove();
	}

	if( KFPawnEnemy == none || !KFPawnEnemy.CanBeGrabbed(MyKFPawn) )
	{
		return false;
	}

	// If I'm crippled, falling, busy doing an attack, or incapacitated, refuse.
	if( MyKFPawn.bIsHeadless || (MyKFPawn.Physics == PHYS_Falling) || IsDoingAttackSpecialMove() || MyKFPawn.IsImpaired() || MyKFPawn.IsIncapacitated() )
	{
		return false;
	}

	if( LastAttackTime_Grab == 0.f || (`TimeSince(LastAttackTime_Grab) > MinTimeBetweenGrabAttacks) )
	{
        // Make sure the enemy's center of mass (location) is within my collision cylinder
		if( Abs(Enemy.Location.Z - Pawn.Location.Z) > Pawn.CylinderComponent.CollisionHeight )
		{
			return false;
		}

		DistSq = VSizeSq(Enemy.Location - Pawn.Location);
		if( DistSq > Square(MinDistanceToPerformGrabAttack) )
		{
			return false;
		}
        // Do the same kind of trace we do in KFSM_GrappleStart
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Pawn.Location, true);
		if ( HitActor != None && HitActor != Enemy )
		{
            return false;
		}
		if( !CanTargetBeGrabbed(KFPawn(Enemy)) )
		{
			return false;
		}
		/** Makes Zed have high desire to grab as initial attack */
		if( !MyKFPawn.IsDoingMeleeAttack() )
		{
			return true;
		}
	}
	`AILog( GetFuncName()$"() returning FALSE", 'GrabAttack' );
	return false;

}

function bool CanTargetBeGrabbed( KFPawn TargetKFP )
{
	local KFAIController OtherKFAIC;

	// Disallow if target is invalid, already being grabbed, or currently falling
	if( TargetKFP == none || (TargetKFP.Health <= 0) || (TargetKFP.IsDoingSpecialMove(SM_GrappleVictim)) || TargetKFP.Physics == PHYS_Falling )
	{
		return false;
	}

	// Need to check that no other clots are performing initial grab move on player since SM_GRAB is run without the player in a special move
	foreach WorldInfo.AllControllers( class'KFAIController', OtherKFAIC )
	{
		if( OtherKFAIC == self )
		{
			continue;
		}
		// If the the other Zed is doing a grab start or grab attack special move, and TargetKFP is also his enemy, disallow
		// this grab. Already checked if player is doing a grapplevictim special move above, but the player isn't executing
		// the victim special move until the other Zed's initial grab anim is complete (see KFSM_Clot_Grab - this is the move that determines
		// whether the clot's grab should miss or succeed based on when the initial sequence is interrupted)...  so instead check
		// whether the starting-to-grab Zed has the same enemy.
		// The grab special move assumes that the grab victim is also the grabber's enemy.
		if( OtherKFAIC.MyKFPawn != none && OtherKFAIC.Enemy == TargetKFP && OtherKFAIC.IsDoingGrabSpecialMove() )
		{
            if( VSizeSq(MyHansPawn.Location - TargetKFP.Location) < 250000 ) // 5 Meters
            {
                // End the move immediately so other zed stops grabbing our target!
                OtherKFAIC.MyKFPawn.EndSpecialMove();
            }
		}
	}

	return true;
}

/** Launch a grab attack */
event DoGrabAttack( optional Pawn NewEnemy, optional float InPostSpecialMoveSleepTime=0.f )
{
	if( CommandList == None || AICommand(CommandList).bAllowedToAttack )
	{
		if( NewEnemy != None && NewEnemy != Enemy )
		{
			ChangeEnemy( NewEnemy, false );
		}
		/** Abort qany movement commands */
		ClearMovementInfo();
		`AILog( GetFuncName()$"() Init AICommand_Attack_Grab", 'InitAICommand' );
		class'AICommand_Attack_Grab'.static.Grab( self, InPostSpecialMoveSleepTime );
	}
	else if( CommandList != none && !AICommand(CommandList).bAllowedToAttack )
	{
		`AILog( GetFuncName()$"() not doing grab attack because current command ("$CommandList$") will not allow it", 'GrabAttack' );
	}
}

/** Effects and damage from a zed sprinting and bumping other monsters */
function bool DoHeavyZedBump( Actor Other, vector HitNormal )
{
	local int BumpEffectDamage;
	local KFPawn_Monster BumpedMonster;

	/** If we bumped into a glass window, break it */
	if( Other.bCanBeDamaged && KFFracturedMeshGlass(Other) != none )
	{
		KFFracturedMeshGlass(Other).BreakOffAllFragments();
		return true;
	}

	BumpedMonster = KFPawn_Monster(Other);
	if( BumpedMonster == none || !BumpedMonster.IsAliveAndWell() || BumpedMonster.ZedBumpDamageScale <= 0 )
	{
		return false;
	}

	if( MyKFPawn == none || !MyKFPawn.IsAliveAndWell() )
	{
		return false;
	}

	// Hans knocks guys out of the way always if he is in hunt and heal
    if( (MyHansPawn.bInHuntAndHealMode && !IsZero(MyKFPawn.Velocity)) || (MyKFPawn.bIsSprinting && !MyKFPawn.IsDoingSpecialMove()) )
	{
		BumpEffectDamage = ZedBumpEffectThreshold * BumpedMonster.ZedBumpDamageScale;

		// If the Bumped Zed is near death, play either a knockdown or an immediate obliteration
		if( BumpedMonster.Health - BumpEffectDamage <= 0 )
		{
			// Chance to obliterate if at low health
			if( FRand() < ZedBumpObliterationEffectChance )
			{
				BumpedMonster.TakeDamage(BumpEffectDamage, self, BumpedMonster.Location, vect(0,0,0), MyKFPawn.GetBumpAttackDamageType());
			}
			else
			{
				BumpedMonster.Knockdown( , vect(1,1,1), Pawn.Location, 1000, 100 );
			}
			return true;
		}
		else
		{
			// otherwise deal damage and stumble the zed
			BumpedMonster.TakeDamage(BumpEffectDamage, self, BumpedMonster.Location, vect(0,0,0), MyKFPawn.GetBumpAttackDamageType());
			BumpedMonster.DoSpecialMove(SM_Stumble,,, class'KFSM_Stumble'.static.PackBodyHitSMFlags(BumpedMonster, HitNormal));
			return true;
		}
	}
	return false;
}

function bool CanDoStrike()
{
    local bool bInGrabRange;
    local float DistSq;

    if( !bFleeing && !bWantsToFlee )
    {
    	/** See if we want to grab an enemy, and they are in grab range */
    	if( Enemy != none && MyHansPawn != none && MyHansPawn.bInHuntAndHealMode &&
            MyKFPawn != none && MyKFPawn.Health > 0 )
    	{
        	DistSq = VSizeSq(Enemy.Location - Pawn.Location);
    		if( DistSq < Square(MinDistanceToPerformGrabAttack) )
    		{
                bInGrabRange = true;
    		}
    	}

    	// Never do melee strikes when in bInHuntAndHealMode unless we can't grab attack, and the enemy is in grab range
    	if( MyHansPawn == none || (MyHansPawn.bInHuntAndHealMode && (!bInGrabRange || CanGrabAttack())) )
    	{
    		return false;
    	}
    }

	return super.CanDoStrike();
}

event EdgeAndPolySubRegionRejectedDueToDist( vector EdgeCenterRejected, ENavmeshEdgeType EdgeTypeRecjted, Color EdgeTypeColorRejected, vector SubRegionLocation, vector PolyCenterRejected, float Dist )
{
 	local KFDebugLines KFDL;

	if( class'KFGameEngine'.default.bEnableAdvDebugLines )
	{
//
 		KFDL = class'KFDebugLines'.static.GetDebugLines();
	//
 		KFDL.AddDebugSphere( SubRegionLocation, 32, 8, 255, 0, 0, true);
 		KFDL.AddDebugText3D( SubRegionLocation + vect(0,0,1) * 72.f, "FAILED DUE TO Dist:"$Dist, true, 100, 100, 0, true );

	}
}

event EdgeAndPolySubRegionRejectedDueToRating( vector EdgeCenterRejected, ENavmeshEdgeType EdgeTypeRecjted, Color EdgeTypeColorRejected, vector SubRegionLocation, vector PolyCenterRejected, int Rating )
{
 	local KFDebugLines KFDL;
//
	if( class'KFGameEngine'.default.bEnableAdvDebugLines )
	{
 		KFDL = class'KFDebugLines'.static.GetDebugLines();
	//
 		KFDL.AddDebugSphere( SubRegionLocation, 32, 8, 255, 255, 0, true );
 		KFDL.AddDebugText3D( SubRegionLocation + vect(0,0,1) * 72.f, "FAILED DUE TO RATING:"$Rating, true, 100, 200, 0, true );
	}
}

event EntireEdgeAndPolyRejectedDueToRating( vector EdgeCenterRejected, ENavmeshEdgeType EdgeTypeRecjted, Color EdgeTypeColorRejected, vector PolyCenterRejected, int Rating )
{
 	local KFDebugLines KFDL;
	local vector centerOfLineFromEdgeToPolyCenter;

	if( class'KFGameEngine'.default.bEnableAdvDebugLines )
	{
		centerOfLineFromEdgeToPolyCenter = 0.5 * (PolyCenterRejected - EdgeCenterRejected);
	//
 		KFDL = class'KFDebugLines'.static.GetDebugLines();
	//
 		//KFDL.AddDebugSphere( PossibleGoal.Location, 32, 8, 255, 255, 0, true );
		KFDL.AddDebugLine( EdgeCenterRejected, PolyCenterRejected, 255, 0, 0, true );
 		KFDL.AddDebugText3D( EdgeCenterRejected + centerOfLineFromEdgeToPolyCenter + vect(0,0,1) * 72.f, "Entire Edge FAILED DUE TO RATING:"$Rating, true, 100, 200, 0, true );

	}
}

event EdgeAndPolySubRegionRejectedDueToLOS( vector EdgeCenterRejected, ENavmeshEdgeType EdgeTypeRecjted, Color EdgeTypeColorRejected, vector SubRegionLocation, vector PolyCenterRejected, vector HitLocation, Actor HitActor )
{
 	local KFDebugLines KFDL;

	if( class'KFGameEngine'.default.bEnableAdvDebugLines )
	{
	//
 		KFDL = class'KFDebugLines'.static.GetDebugLines();
	//
 		KFDL.AddDebugSphere( SubRegionLocation, 32, 8, 255, 0, 0, true );
 		KFDL.AddDebugText3D( SubRegionLocation+ vect(0,0,1) * 72.f, "FAILED DUE TO LOS", true, 100, 100, 0, true );

	}
}

event EdgeAndPolySubRegionRejectedDueToAdjustToss( vector EdgeCenterRejected, ENavmeshEdgeType EdgeTypeRecjted, Color EdgeTypeColorRejected, vector SubRegionLocation, vector PolyCenterRejected, vector HitLocation )
{
 	local KFDebugLines KFDL;

	if( class'KFGameEngine'.default.bEnableAdvDebugLines )
	{
	//
 		KFDL = class'KFDebugLines'.static.GetDebugLines();
	//
 		KFDL.AddDebugSphere( SubRegionLocation, 32, 8, 255, 0, 0, true );
 		KFDL.AddDebugText3D( SubRegionLocation + vect(0,0,1) * 72.f, "FAILED DUE TO AdjustToss", true, 100, 100, 0, true );

	}
}

event EdgeAndPolySubRegionRejectedDueToProximityToTarget( vector EdgeCenterRejected, ENavmeshEdgeType EdgeTypeRecjted, Color EdgeTypeColorRejected, vector SubRegionLocation, vector PolyCenterRejected, float Range, Actor Target )
{
}

`if(`notdefined(ShippingPC))
/** Debug command to advance battle phase */
function DebugNextPhase()
{
    MyHansPawn.SetHuntAndHealMode( true );
    MyHansPawn.Health = MyHansPawn.HealthMax * 0.34;
}
`endif

/*********************************************************************************************
* Pathfinding
********************************************************************************************* */

function bool AmIAllowedToSuicideWhenStuck()
{
	return false;
}


function InitalizeBaseCommand( class<AICommand> CmdClass )
{

	CmdClass.static.InitCommand( self );
}

/*********************************************************************************************
* Dialog
********************************************************************************************* */

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageType)
{
	if( self == Killer )
	{
		`DialogManager.PlayHansKilledDialog( MyHansPawn, damageType );
	}
}

function PlayDamagePlayerDialog( class<DamageType> DmgType )
{
	`DialogManager.PlayHansDamagePlayerDialog( MyHansPawn, DmgType );
}

DefaultProperties
{
	Steering=none
	DefaultCommandClass=class'KFGame.AICommand_Base_Hans'
	MeleeCommandClass=class'KFGame.AICommand_Base_Hans'
    MinDistanceToPerformGrabAttack=350.f
    MinTimeBetweenGrabAttacks=2.5f
    bRepathOnInvalidStrike=true

	//DefaultBehavior="Hans_BT"
	//UsedETQQueries[ENQ_EnemySelection]="BaseZedEnemySelection"

    AggroEnemySwitchWaitTime=7.0f //7
    RetargetWaitTimeRange=(X=4.4, Y=5.0)  //(X=5.0, Y=7.0)  (X=5.0, Y=8.0)feels good but he finishs people off to much

	bCanDoHeavyBump=true
	LostSightSprintDelay=0.5

    StartShootingRange=4000
    MinShootingRange=300

    LostSightStopFireDelay=1.25
	BurstWaitTime=0.5
	MinBurstAmount=3
	MaxBurstAmount=8
	BarrageLength=3.0
	BarrageWaitTime=1.5
	GrenadeGunInterruptDelay=5.0

	BarrageWaitDistanceCurve=(Points=((InVal=0.f,OutVal=1.25f),(InVal=2500.0f, OutVal=1.f)))
	BurstWaitDistanceCurve=(Points=((InVal=0.f,OutVal=4.f),(InVal=2500.0f, OutVal=1.f)))

	TargetAquisitionDelay=0.25
	DrawGunFireDelay=1.0

	StanceChangeCooldown=0.3
	PostAttackMoveGunCooldown=0.3

	CurrentNadeAttackType=HNT_None
	GrenadeAttackEvalInterval=0.1
	LastRecentSeenEnemyListUpdateTime=0.1

    MinFleeDuration=5.f //10 //3 //2
    MaxFleeDuration=6.f //15  //5  //3
    MaxFleeDistance=3000.f //10000. //5000

	TeleportCooldown=15.0
	HiddenRelocateTeleportThreshold=12.0

    // ---------------------------------------------
    // Danger Evasion Settings
    DangerEvadeSettings.Empty

    DangerEvadeSettings(0)={(ClassName="KFProj_Bullet_Pellet",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.85, 0.95), //0.1, 0.3, 0.5, 0.6
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(1)={(ClassName="KFProj_Nail_Nailgun",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.85, 0.95),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(2)={(ClassName="KFProj_Bullet_DragonsBreath",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.85, 0.95),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(3)={(ClassName="KFProj_HighExplosive_M79",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(4)={(ClassName="KFProj_HighExplosive_M32",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(5)={(ClassName="KFProj_Rocket_RPG7",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(6)={(ClassName="KFDT_Explosive_M16M203",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(7)={(ClassName="KFDT_Explosive_HRGIncendiaryRifle",
                                Cooldowns=(4.0, 3.0, 2.0, 1.0), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}


    //shooting fire
    DangerEvadeSettings(8)={(ClassName="KFProj_CaulkNBurn_GroundFire",
                                Cooldowns=(3.0, 3.0, 2.5, 1.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.0, 0.3, 0.5, 0.8),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(9)={(ClassName="KFProj_FlameThrower_GroundFire",
                                Cooldowns=(3.0, 3.0, 2.5, 1.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.0, 0.3, 0.5, 0.8),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(10)={(ClassName="KFWeap_Flame_CaulkBurn",
                                Cooldowns=(3.0, 3.0, 2.5, 1.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.0, 0.3, 0.5, 0.8),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(11)={(ClassName="KFWeap_Flame_Flamethrower",
                                Cooldowns=(3.0, 3.0, 2.5, 1.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.8),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(12)={(ClassName="KFWeap_Beam_Microwave",
                                Cooldowns=(3.0, 3.0, 2.5,  1.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.8),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(13)={(ClassName="KFProj_Flame_HRGIncendiaryRifle",
                                Cooldowns=(3.0, 3.0, 2.5, 1.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.0, 0.3, 0.5, 0.8),
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
                                SoloChanceMultiplier=1.0)}

    //Aimed weapons it dodges //sharpshooter
    DangerEvadeSettings(14)={(ClassName="KFWeap_Bow_Crossbow",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}  
    DangerEvadeSettings(15)={(ClassName="KFWeap_Bow_CompoundBow",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(16)={(ClassName="KFWeap_Rifle_M14EBR",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(17)={(ClassName="KFWeap_Rifle_Winchester1894",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(18)={(ClassName="KFWeap_Rifle_RailGun",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}

    //Grenades
    DangerEvadeSettings(19)={(ClassName="KFProj_FragGrenade",
                                Cooldowns=(6.0, 5.0, 3.0, 2.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}  
    DangerEvadeSettings(20)={(ClassName="KFProj_MolotovGrenade",
                                Cooldowns=(6.0, 5.0, 3.0, 2.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}  
    DangerEvadeSettings(21)={(ClassName="KFProj_DynamiteGrenade",
                                Cooldowns=(6.0, 5.0, 3.0, 2.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}  
    DangerEvadeSettings(22)={(ClassName="KFProj_NailBombGrenade",
                                Cooldowns=(6.0, 5.0, 3.0, 2.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}  
    DangerEvadeSettings(23)={(ClassName="KFProj_HEGrenade",
                                Cooldowns=(6.0, 5.0, 3.0, 2.5), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.1, 0.3, 0.5, 0.6),
                                ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
                                SoloChanceMultiplier=1.0)}

    //Aim Blocks
    DangerEvadeSettings(24)={(ClassName="KFWeap_Rifle_Winchester1894",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(25)={(ClassName="KFWeap_Bow_Crossbow",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(26)={(ClassName="KFWeap_Rifle_M14EBR",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(27)={(ClassName="KFWeap_Rifle_RailGun",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(28)={(ClassName="KFWeap_Bow_CompoundBow",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}   
}