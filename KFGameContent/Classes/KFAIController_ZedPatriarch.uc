//=============================================================================
// KFAIController_ZedPatriarch
//=============================================================================
// The Patriarch's AIController
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_ZedPatriarch extends KFAIController_ZedBoss;

/** Cached reference to patriarch pawn */
var KFPawn_ZedPatriarch MyPatPawn;

/*********************************************************************************************
* Enemy Handling
**********************************************************************************************/

/** Whether attack evaluation is enabled or not */
var bool bCanEvaluateAttacks;

/** How long the Patriarch should wait to start sprinting after losing sight of his enemy */
var float LostSightSprintDelay;

/** How long to wait before ticking off aggro damage */
var float AggroFalloffWaitTime;

/** How much damage to tick off of accumulated aggro, per second */
var float AggroFalloffPerSecond;

/** The threshold at which aggro from a visible player becomes critical */
var float VisibleAggroDmgThreshold;

/** The threshold at which aggro from a hidden player becomes critical */
var float HiddenAggroDmgThreshold;

/**
 *	Struct to track AI knowledge of visible enemies
 */
struct Patriarch_TrackedEnemyInfo
{
	/** Enemy we're tracking */
	var KFPawn 			TrackedEnemy;
	/** Last time enemy was visible */
	var float 			LastTimeVisible;
	/** Last location enemy was visible */
	var vector 			LastVisibleLocation;
	/** The last time we took damage from this enemy */
	var float 			LastTakeDamageTime;
	/** Accumulated damage towards this enemy's aggro rating */
	var int 			AggroDamage;
};

/** List of tracked enemies that have recently been seen */
var array<Patriarch_TrackedEnemyInfo> RecentlySeenEnemyList;

/** List of tracked enemies that are hidden */
var array<Patriarch_TrackedEnemyInfo> HiddenEnemies;

/** List of enemies that have been minigun attacked */
var array<KFPawn> LastMinigunEnemies;

/** Minimum distance for a minigun attack */
var float MinMinigunRangeSQ;

/** Maximum distance for a minigun attack */
var float MaxMinigunRangeSQ;

/** Maximum distance enemies are allowed to be for a fan fire attack */
var float MaxFanFireRangeSQ;

/** List of enemies that have been charge attacked */
var array<KFPawn> LastChargedPlayers;

/** Min distance an enemy can be for a charge */
var float MinChargeRangeSQ;

/** Are we doing a charge attack? */
var bool bDoingChargeAttack;

/** Last time we executed a charge attack */
var float LastChargeAttackTime;

/** If we were charging a player, but were interrupted by an obstruction */
var bool bWantsToCharge;

/** Cached charge target */
var Pawn CachedChargeTarget;

/** List of enemies that have been tentacle grabbed */
var array<KFPawn> LastGrabbedPlayers;

/** Last time we executed a tentacle grab */
var float LastGrabAttackTime;

/** Minimum distance to be able to use a tentacle attack */
var float MinTentacleRangeSQ;

/** List of enemies that have been missile attacked */
var array<KFPawn> LastMissileEnemies;

/** Last time we executed a missile attack */
var float LastMissileAttackTime;

/** Min distance an enemy can be for a missile attack */
var float MinMissileRangeSQ;

/** Max distance an enemy can be for a missile attack */
var float MaxMissileRangeSQ;

/** Last time we executed a mortar attack */
var float LastMortarAttackTime;

/** Last time we successfully hit an enemy with a melee attack */
var float LastSuccessfulAttackTime;

/** Variable used for determining if the Patriarch should pick a minigun or missile attack */
var bool bHadMinigunAttack;

/* How often to update RecentlySeenEnemyList */
var() float RecentSeenEnemyListUpdateInterval;

/* Last time we updated the RecentlySeenEnemyList*/
var float LastRecentSeenEnemyListUpdateTime;

/** Last time we finished a melee attack */
var float LastAttackMoveFinishTime;

/** How long to wait before evaluating special attacks */
var float NextAttackCheckTime;

/** Last time we activated a battle phase sprint */
var float LastSprintTime;

/** Whether we should sprint until we complete a melee attack */
var bool bSprintUntilAttack;

/** The last time we changed to a new target */
var float LastRetargetTime;

/** How long to wait before attempting to find a new target */
var float RetargetWaitTime;

/*********************************************************************************************
* Paternal Instinct
**********************************************************************************************/

/** True if we've entered into rage mode */
var bool bRaging;

/** Whether we've raged this phase or not */
var bool bRagedThisPhase;

/** Maximum number of attacks to do before ending rage mode */
var int MaxRageAttacks;

/** Current tally of rage attacks done */
var int RageAttackCount;

/** Maximum distance an enemy can be to be considered for a rage attack */
var float MaxRageRangeSQ;

/** Time before forcing rage mode to end */
var float RageTimeOut;

/** Players that have already been attacked in this rage state */
var array<KFPawn> RageAttackedTargets;

/*********************************************************************************************
* Flee And Heal
**********************************************************************************************/

/** The amount of damage to do to bumped humans when fleeing */
var int HumanBumpDamage;

/** How much momentum to apply to humans when bumping them */
var int HumanBumpMomentum;

/** Do we have a pending flee? */
var bool bWantsToFlee;

/** Whether we are currently fleeing or not */
var bool bFleeing;

/** The health threshold at which a flee and heal should be triggered */
var float FleeHealthThreshold;

/** The maximum amount of time that can be spent in the flee state */
var float MaxFleeDuration;

/** The maximum distance allowed to flee before command pops */
var float MaxFleeDistance;

/** The start time of the last flee */
var float FleeStartTime;

/** The total cumulative time spent fleeing */
var float TotalFleeTime;

/** Whether the flee was interrupted by the targeting loop */
var bool bFleeInterrupted;

/*********************************************************************************************
* Initialization, Pawn Possession, and Destruction
********************************************************************************************* */

/** Set MyPatPawn to avoid casting */
event Possess( Pawn inPawn, bool bVehicleTransition )
{
	if( KFPawn_ZedPatriarch(inPawn) != none )
	{
		MyPatPawn = KFPawn_ZedPatriarch( inPawn );
	}
	else
	{
		`warn( GetFuncName()$"() attempting to possess "$inPawn$", but it's not a KFPawn_ZedPatriarchBase class! MyPatPawn variable will not be valid." );
	}

	// Initialize retarget time
	LastRetargetTime = WorldInfo.TimeSeconds;

	// Initialize sprint time
	LastSprintTime = WorldInfo.TimeSeconds;
	LastSuccessfulAttackTime = WorldInfo.TimeSeconds;
	LastGrabAttackTime = WorldInfo.TimeSeconds;
	LastMissileAttackTime = WorldInfo.TimeSeconds;
	LastMortarAttackTime = WorldInfo.TimeSeconds;
	
	// Wait a bit before evaluating special attacks
	NextAttackCheckTime = 2.5f + fRand();

	// Start evaluating on next tick
	bCanEvaluateAttacks = true;

	super.Possess( inPawn, bVehicleTransition );
}

function PawnDied( Pawn InPawn )
{
	if( MyPatPawn != none )
	{
		//`DialogManager.PlayBossDeathDialog( MyHansPawn );
		MyPatPawn = None;
	}
	Super.PawnDied( InPawn );
}

/** Clean up all internal objects and references when the AI is destroyed
	TBD: Look into using Unpossessed() to do this! */
simulated event Destroyed()
{
	if( MyPatPawn != none )
	{
		MyPatPawn.ClearMortarTargets();
	}
	MyPatPawn = None;
	MyKFGameInfo.SpawnManager.StopSummoningBossMinions();

	super.Destroyed();
}

/*********************************************************************************************
* Enemy and Attack Handling
********************************************************************************************* */

/** We can't allow aggro enemy switches during certain special moves */
function bool IsAggroEnemySwitchAllowed()
{
	return super.IsAggroEnemySwitchAllowed()
			&& !MyPatPawn.IsDoingSpecialMove(SM_StandAndShootAttack)
			&& !MyPatPawn.IsDoingSpecialMove(SM_HoseWeaponAttack)
			&& !MyPatPawn.IsDoingSpecialMove(SM_GrappleAttack);
}

/** Whether enemy switch commands can be run */
function bool CanSwitchEnemies()
{
	return !bWantsToFlee
			&& !bFleeing
			&& MyPatPawn != none
			&& !MyPatPawn.bIsCloaking
			&& !MyPatPawn.IsDoingSpecialMove(SM_Heal)
			&& !MyPatPawn.IsDoingSpecialMove(SM_StandAndShootAttack)
			&& !MyPatPawn.IsDoingSpecialMove(SM_SonicAttack)
			&& !MyPatPawn.IsDoingSpecialMove(SM_GrappleAttack);
}

/** Returns an aggro rating on a scale of 0.0f to 1.0f */
function float GetAggroRating( KFPawn KFP )
{
	local int EnemyIndex;
	local float AggroDmg;

	EnemyIndex = RecentlySeenEnemyList.Find( 'TrackedEnemy', KFP );
	if( EnemyIndex != INDEX_NONE )
	{
		AggroDmg = RecentlySeenEnemyList[EnemyIndex].AggroDamage;
		if( AggroDmg > 0.f )
		{
			return fMin( AggroDmg/VisibleAggroDmgThreshold, 1.f );
		}
		else
		{
			return 0.f;
		}
	}
	else
	{
		EnemyIndex = HiddenEnemies.Find( 'TrackedEnemy', KFP );
		if( EnemyIndex != INDEX_NONE )
		{
			AggroDmg = HiddenEnemies[EnemyIndex].AggroDamage;
			if( AggroDmg > 0.f )
			{
				return fMin( AggroDmg/HiddenAggroDmgThreshold, 1.f );
			}
			else
			{
				return 0.f;
			}
		}
		else
		{
			return 0.5f;
		}
	}

	return 1.f;
}

/** Overridden to stop retargeting enemies when fleeing or cloaked */
event bool FindNewEnemy()
{
	if( !CanSwitchEnemies() )
	{
		return false;
	}

	return super.FindNewEnemy();
}

/** Overridden to stop retargeting enemies when fleeing or cloaked */
event bool SetEnemy( Pawn NewEnemy )
{
	if( !CanSwitchEnemies() )
	{
		return false;
	}

	return super.SetEnemy( NewEnemy );
}

/** Forces the enemy to the new pawn, bypassing CanSwitchEnemies() */
function ForceSetEnemy( Pawn NewEnemy )
{
	super.SetEnemy( NewEnemy );
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

	super.ChangeEnemy( NewEnemy, !MyPatPawn.bIsCloaking && bCanTaunt );

	if( OldEnemy != Enemy )
	{
		LastRetargetTime = WorldInfo.TimeSeconds;
	}
}

/** Sets the enemy to the best target, based on several factors */
function bool SetBestTarget( out array<KFPawn> RecentTargets,
						optional float MinDistSQ=-1.f,
						optional float MaxDistSQ=-1.f,
						optional float ClampFOV=-1.f,
						optional bool bPreferFurtherTargets,
						optional bool bIsWeaponAttack )
{
	local KFPawn_Human KFPH;
	local KFPawn KFP, BestTarget;
	local int i, FoundIndex, BestIndex;
	local float TempRating, BestRating;
	local vector TempDist;

	// Filter out dead/absent players
	for( i = 0; i < RecentTargets.Length; ++i )
	{
		if( RecentTargets[i] == none || !RecentTargets[i].IsAliveAndWell() )
		{
			RecentTargets.Remove( i, 1 );
			i--;
		}
	}

	// If we've had no previously charged players or in solo play, charge enemy
	if( RecentTargets.Length == 0 || WorldInfo.NetMode == NM_StandAlone )
	{
		// Fallback
		if( Enemy == none )
		{
			//if( !bPreferFurtherTargets )
			//{
				ChangeEnemy( GetClosestEnemy(), false );
			//}
		}

		// Can't get an enemy for whatever reason
		if( Enemy == none )
		{
			return false;
		}

		// Initial rating value is based on distance
		TempRating = VSizeSQ( MyPatPawn.Location - Enemy.Location );

		// Early out if we're outside distance limits
		if( (MinDistSQ >= 0.f && TempRating < MinDistSQ) || (MaxDistSQ > 0.f && TempRating > MaxDistSQ) )
		{
			return false;
		}

		// Even if we can see our targets, make sure that our gun has clearance
		if( bIsWeaponAttack && !IsWeaponArmClear(Enemy.Location) )
		{
			return false;
		}

		KFP = KFPawn( Enemy );
		FoundIndex = RecentTargets.Find( KFP );
		if( FoundIndex == INDEX_NONE )
		{
			RecentTargets[RecentTargets.Length] = KFP;
		}

		return true;
	}

	// Try to find a better target
	foreach WorldInfo.AllPawns( class'KFPawn_Human', KFPH )
	{
		if( KFPH != none && KFPH.IsAliveAndWell() )
		{
			// Initial rating value is based on distance
			TempDist = KFPH.Location - MyPatPawn.Location;
			TempRating = VSizeSQ( TempDist );

			// Filter based on distance limits, if we have any
			if( (MinDistSQ >= 0.f && TempRating < MinDistSQ) || (MaxDistSQ > 0.f && TempRating > MaxDistSQ) )
			{
				continue;
			}

			// Filter out pawns not in the clamp FOV, if we have one
			if( vector(Pawn.Rotation) dot Normal(TempDist) < ClampFOV )
			{
				continue;
			}

			// Even if we can see our targets, make sure that our gun has clearance
			if( bIsWeaponAttack && !IsWeaponArmClear(KFPH.Location) )
			{
				return false;
			}

			// Recently attacked players get lowest priority
			FoundIndex = RecentTargets.Find( KFPH );
			if( FoundIndex != INDEX_NONE )
			{
				// Scale priority based on position in list -- the higher the more recent
				TempRating *= bPreferFurtherTargets ? 
							( 2.5f + 2.5f*(FMax(float(FoundIndex),1.f)/RecentTargets.Length) ) :
							( 1.f - 0.5f*(FMax(float(FoundIndex),1.f)/RecentTargets.Length) );
			}

			// Lower priority for players that haven't been seen recently
			if( RecentlySeenEnemyList.Find('TrackedEnemy', KFPH) == INDEX_NONE )
			{
				TempRating *= bPreferFurtherTargets ? 0.5f : 2.0f;
			}

			// Apply aggro rating
			TempRating *= bPreferFurtherTargets ? 0.5f + 0.5f*GetAggroRating(KFPH) : 1.0f - 0.5f*GetAggroRating(KFPH);

			if( BestRating == 0.f || ((bPreferFurtherTargets && TempRating > BestRating)
				|| (!bPreferFurtherTargets && TempRating < BestRating)) )
			{
				BestTarget = KFPH;
				BestRating = TempRating;
				BestIndex = FoundIndex;
			}
		}
	}

	if( BestTarget != none )
	{
		// Set our enemy
		ChangeEnemy( BestTarget, false );

		// Shuffle target out of current spot if chosen from array
		if( BestIndex != INDEX_NONE )
		{
			RecentTargets.Remove( BestIndex, 1 );
		}

		// Place target at end of array
		RecentTargets[RecentTargets.Length] = BestTarget;

		return true;
	}

	return false;
}

/** Override to tick the ranged combat system */
simulated function Tick( FLOAT DeltaTime )
{
	Super.Tick(DeltaTime);

	UpdateRecentlySeenEnemyList();
	EvaluateAttacks( DeltaTime );
}

/** NPC has seen a player - use SeeMonster for similar notifications about seeing any pawns (currently not in use) */
event SeePlayer( Pawn Seen )
{
    local int EnemyListIndex, HiddenEnemyIndex;
    local Patriarch_TrackedEnemyInfo NewTrackedEnemy;
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
        	HiddenEnemyIndex = HiddenEnemies.Find('TrackedEnemy', KFP);
        	if( HiddenEnemyIndex != INDEX_NONE )
        	{
        		HiddenEnemies.Remove(HiddenEnemyIndex, 1);
        	}
            NewTrackedEnemy.TrackedEnemy = KFP;
            NewTrackedEnemy.LastTimeVisible = WorldInfo.TimeSeconds;
            NewTrackedEnemy.LastVisibleLocation = Seen.Location;

			// Delay attacks a bit if we are just acquiring an enemy after having not seen anyone
			if( RecentlySeenEnemyList.Length == 0 )
			{
				NextAttackCheckTime = 1.5f + fRand();
			}

            RecentlySeenEnemyList[RecentlySeenEnemyList.Length] = NewTrackedEnemy;
        }
        else
        {
            RecentlySeenEnemyList[EnemyListIndex].LastTimeVisible = WorldInfo.TimeSeconds;
            RecentlySeenEnemyList[EnemyListIndex].LastVisibleLocation = Seen.Location;
        }

        LastEnemySightedTime = WorldInfo.TimeSeconds;
    }
}

/** Update the ranged enemy visibility tracking */
function UpdateRecentlySeenEnemyList()
{
    local int i;
    local bool bWantsNewEnemy;

    if( LastRecentSeenEnemyListUpdateTime == 0 || `TimeSince(LastRecentSeenEnemyListUpdateTime) > RecentSeenEnemyListUpdateInterval )
    {
        LastRecentSeenEnemyListUpdateTime = WorldInfo.TimeSeconds;

    	for( i = RecentlySeenEnemyList.Length-1; i >= 0; i-- )
    	{
    		bWantsNewEnemy = false;

			if( RecentlySeenEnemyList[i].TrackedEnemy == none
				|| !RecentlySeenEnemyList[i].TrackedEnemy.IsAliveAndWell()
				|| !RecentlySeenEnemyList[i].TrackedEnemy.CanAITargetThisPawn(self)
				|| `TimeSince(RecentlySeenEnemyList[i].LastTimeVisible) > 0.5f )
			{
				// If enemy is still valid but out of view, add it to hidden enemies
				if( RecentlySeenEnemyList[i].TrackedEnemy != none && RecentlySeenEnemyList[i].TrackedEnemy.IsAliveAndWell() )
				{
					HiddenEnemies[HiddenEnemies.Length] = RecentlySeenEnemyList[i];
				}

				// Try to get a new enemy
				if( Enemy == RecentlySeenEnemyList[i].TrackedEnemy )
				{
					if( RecentlySeenEnemyList.Length > 1 )
					{
						bWantsNewEnemy = true;
					}
					else
					{
						FindNewEnemy();
					}
				}

				RecentlySeenEnemyList.Remove(i, 1);

				if( bWantsNewEnemy )
				{
					ChangeEnemy( RecentlySeenEnemyList[Rand(RecentlySeenEnemyList.Length)].TrackedEnemy );
				}
			}
			else if( CanSee(RecentlySeenEnemyList[i].TrackedEnemy) )
			{
				if( `TimeSince(RecentlySeenEnemyList[i].LastTakeDamageTime) > AggroFalloffWaitTime )
				{
		    		RecentlySeenEnemyList[i].AggroDamage -= fMax( AggroFalloffPerSecond * (RecentSeenEnemyListUpdateInterval/1.f), 0.f );
		    	}
				RecentlySeenEnemyList[i].LastVisibleLocation = RecentlySeenEnemyList[i].TrackedEnemy.Location;
				RecentlySeenEnemyList[i].LastTimeVisible = WorldInfo.TimeSeconds;
			}
    	}

    	for( i = HiddenEnemies.Length-1; i >= 0; i-- )
    	{
			if( `TimeSince(HiddenEnemies[i].LastTakeDamageTime) > AggroFalloffWaitTime )
			{    		
	    		HiddenEnemies[i].AggroDamage -= fMax( AggroFalloffPerSecond * (RecentSeenEnemyListUpdateInterval/1.f), 0.f );
	    	}
			if( HiddenEnemies[i].TrackedEnemy == none
				|| !HiddenEnemies[i].TrackedEnemy.IsAliveAndWell()
				|| !HiddenEnemies[i].TrackedEnemy.CanAITargetThisPawn(self) )
			{
				HiddenEnemies.Remove(i, 1);
			}
    	}
    }
}

/** Evaluates whether or not the Patriarch can do a special attack */
function EvaluateAttacks( float DeltaTime )
{
	local bool bCanFireMinigun, bCanFireMissile, bCanFireMortar, bShouldFireMortar, bShouldFireMissile, bMortarBarrage;

	if( !bCanEvaluateAttacks )
	{
		return;
	}

    //Don't attack while we're in theatrics
    if (CommandList != none && CommandList.class == class'AICommand_BossTheatrics')
    {
        return;
    }

	NextAttackCheckTime -= DeltaTime;

	if( bWantsToCharge || bWantsToFlee || bFleeing || MyPatPawn == none || MyPatPawn.IsDoingSpecialMove() || NextAttackCheckTime > 0.f )
	{
		return;
	}

	// Evaluate grab attack
	if ( MyPatPawn.CanTentacleGrab()
		&& RecentlySeenEnemyList.Length > 0
		&& `TimeSince(LastGrabAttackTime) > MyPatPawn.TentacleGrabCooldownTime
		&& (!MyPatPawn.bIsCloaking || fRand() < 0.25f) )
	{
		if( SetBestTarget(LastGrabbedPlayers, MinTentacleRangeSQ, Square(class'KFSM_Patriarch_Grapple'.default.MaxRange*0.8f*MyPatPawn.GetAttackRangeScale()), 0.4f, true, true) )
		{
			MyPatPawn.SetCloaked( false );
			class'AICommand_Patriarch_Grab'.static.TentacleGrab( self );
			return;
		}
	}

	// Evaluate charge attack
	if( !MyPatPawn.bIsCloaking
		&& MyPatPawn.CanChargeAttack()
		&& (bHadMinigunAttack || fRand() < 0.75f) 
		&& `TimeSince(LastChargeAttackTime) > MyPatPawn.ChargeAttackCooldownTime )
	{
		// Make sure we have a target
		if( SetBestTarget(LastChargedPlayers, MinChargeRangeSQ) )
		{
			// Cache our charge target
			CachedChargeTarget = Enemy;

			bDoingChargeAttack = true;
			bSprintUntilAttack = true;
			MyPatPawn.SetSprinting( true );
			MyPatPawn.SetCloaked( true );

			// Delay ranged attack checking a bit
			NextAttackCheckTime = 2.5f + fRand();

			SetTimer( 2.f, false, nameOf(Timer_SearchForChargeObstructions) );
			return;
		}
	}

	// Evaluate weapon attack
	bCanFireMinigun = (!MyPatPawn.CanChargeAttack() || fRand() < 0.5f)
						&& (!MyPatPawn.bIsCloaking || fRand() < 0.75f)
						&& RecentlySeenEnemyList.Length > 0 
						&& `TimeSince(LastSuccessfulAttackTime) > MyPatPawn.MinigunAttackCooldownTime;
	bCanFireMissile = (!MyPatPawn.CanChargeAttack() || fRand() < 0.5f)
						&& (!MyPatPawn.bIsCloaking || fRand() < 0.75f)
						&& MyPatPawn.CanMissileAttack() && RecentlySeenEnemyList.Length > 0
						&& `TimeSince(LastMissileAttackTime) > MyPatPawn.MissileAttackCooldownTime;
	bCanFireMortar = !MyPatPawn.bIsCloaking
						&& MyPatPawn.CanMortarAttack()
						&& `TimeSince(LastMortarAttackTime) > MyPatPawn.MortarAttackCooldownTime;

	if( bCanFireMissile || bCanFireMinigun || bCanFireMortar )
	{
		// Decide if we can fire our mortar attack
		bShouldFireMortar = bCanFireMortar
							&& (!bCanFireMissile || fRand() < 0.5f)
							&& (!bCanFireMinigun || fRand() < 0.75f)
							&& IsCeilingClear();

		if( bShouldFireMortar )
		{
			// Random chance to do an area denial
			if( MyPatPawn.CanDoMortarBarrage() && fRand() < 0.2f )
			{
				bMortarBarrage = true;
				bShouldFireMortar = MyPatPawn.CollectMortarTargets( true, true );
			}
			else if( HiddenEnemies.Length > 0 )
			{
				bMortarBarrage = false;
				bShouldFireMortar = SomeEnemiesAreHidden() && MyPatPawn.CollectMortarTargets( true );
			}
			else
			{
				bShouldFireMortar = false;
			}
		}

		// Decide whether we should fire a missile or the minigun
		bShouldFireMissile = !bShouldFireMortar && bCanFireMissile
							&& (((bCanFireMinigun || !bHadMinigunAttack) && fRand() < 0.2f) || fRand() < 0.6f)
							&& SetBestTarget( LastMissileEnemies, MinMissileRangeSQ, MaxMissileRangeSQ*MyPatPawn.GetAttackRangeScale(), 0.5f, true, true );

		// No other attacks, find a minigun target!
		if( bCanFireMinigun && !bShouldFireMissile && !bShouldFireMortar )
		{
			bCanFireMinigun = SetBestTarget( LastMinigunEnemies, MinMinigunRangeSQ, MaxMinigunRangeSQ*MyPatPawn.GetAttackRangeScale(), 0.25f, false, true );
		}

		if( bShouldFireMortar )
		{
			class'AICommand_Patriarch_MortarAttack'.static.FireMortar( self, bMortarBarrage );
			return;
		}
		else if( bShouldFireMissile )
		{
			bHadMinigunAttack = false;
			MyPatPawn.SetCloaked( false );
			class'AICommand_Patriarch_MissileAttack'.static.FireMissiles( self );
			return;
		}
		else if( bCanFireMinigun )
		{
			bHadMinigunAttack = true;
			MyPatPawn.SetCloaked( false );
			class'AICommand_Patriarch_MinigunBarrage'.static.MinigunBarrage( self );
			return;
		}
	}

	// Evaluate attacks every half second
	NextAttackCheckTime = 0.5f;
}

/** Returns true if the path from the weapon arm to the target location is clear */
function bool IsWeaponArmClear( vector EndTrace )
{
	local vector StartTrace;

	MyPatPawn.Mesh.GetSocketWorldLocationAndRotation( 'MissileCenter', StartTrace );

	return MyPatPawn.FastTrace( EndTrace, StartTrace,, true );
}

/**
 * Adjusts aim to always point at the enemy we're targeting
 * @param	W, weapon about to fire
 * @param	StartFireLoc, world location of weapon fire start trace, or projectile spawn loc.
 */
function Rotator GetAdjustedAimFor( Weapon W, vector StartFireLoc )
{
	if( Enemy != none )
	{
		return rotator(Enemy.Location - StartFireLoc);
	}

	return super.GetAdjustedAimFor( W, StartFireLoc );
}

function DoStrike()
{
	local name AttackName;

	if( MyPatPawn != none && MyPatPawn.PawnAnimInfo != none )
	{
		AttackName = MyPatPawn.PawnAnimInfo.Attacks[PendingAnimStrikeIndex].Tag;

		// @todo: figure out a way to make this less hard-coded? (see also KFDialogManager::PlayHansKilledDialog)
		if( AttackName == 'Radial' )
		{
			`DialogManager.PlayPattyWhirlwindDialog( MyPatPawn );
		}
	}

	super.DoStrike();
}

/*********************************************************************************************
* Sprinting
**********************************************************************************************/

/** Evaluate if we should start/stop sprinting, and then set the sprinting flag */
function EvaluateSprinting()
{
    if( MyKFPawn != none && MyKFPawn.IsAliveAndWell() && Enemy != none )
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

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting */
function bool ShouldSprint()
{
	if( Enemy != none && MyPatPawn != none && !MyPatPawn.bIsHeadless )
	{
		// Don't allow sprinting in minigun attack
		if( MyPatPawn.IsDoingSpecialMove(SM_HoseWeaponAttack) )
		{
			return false;
		}

		// Always sprint if fleeing
        if( bFleeing )
		{
			//`log(self@GetFuncName()$" bInFleeAndHealMode should sprint!");
            return true;
		}

		// Always sprint if cloaked
		if( MyPatPawn.bIsCloaking )
		{
			//`log(self@GetFuncName()$" bIsCloaking should sprint!");
			return true;
		}

		// Always sprint if raging
        if( bRaging )
		{
			//`log(self@GetFuncName()$" In Paternal Instinct mode, should sprint!");
            return true;
		}

		// EMP check always comes after any forced sprint state
		if( MyPatPawn.bEmpPanicked )
		{
			return false;
		}

		// Sprint until we attack
		if( bSprintUntilAttack )
		{
			//`log(self@GetFuncName()$" sprint until attack, should sprint!");
			return true;
		}

		// Sprint if we can't see our enemy
		if( LastEnemySightedTime == 0 || `TimeSince(LastEnemySightedTime) > LostSightSprintDelay )
		{
			//`log(self@GetFuncName()$" don't see any enemy should sprint = true! LastEnemySightedTime: "$LastEnemySightedTime$" TimeSince(LastEnemySightedTime): "$`TimeSince(LastEnemySightedTime));
            return true;
		}

        //`log(self@GetFuncName()$" Generic should sprint depending on phase: "$MyPatPawn.DesireSprintingInThisPhase());
        if( MyPatPawn.DesireSprintingInThisPhase() && `TimeSince(LastSprintTime) > MyPatPawn.SprintCooldownTime )
        {
        	bSprintUntilAttack = true;
        	return true;
        }
	}
	//`log(self@GetFuncName()$" Generic should sprint = false!");
	return false;
}

/** Disallow sprinting if we're in a minigun */
function bool CanSetSprinting( bool bNewSprintStatus )
{
	return super.CanSetSprinting( bNewSprintStatus ) && ( !bNewSprintStatus || !MyPatPawn.IsDoingSpecialMove(SM_HoseWeaponAttack) );
}

/*********************************************************************************************
* Mortar
**********************************************************************************************/

/** Returns true if the ceiling is clear for a mortar attack */
function bool IsCeilingClear()
{
	local vector TraceStart, TraceEnd, Extent;

	TraceStart = MyPatPawn.Location + vect(0,0,1)*MyPatPawn.GetCollisionHeight();
	TraceEnd = TraceStart + vect(0,0,1)*500.f;
	Extent.X = MyPatPawn.GetCollisionRadius() * 2.f;
	Extent.Y = Extent.X;
	Extent.Z = 1.f;

	return MyPatPawn.FastTrace( TraceEnd, TraceStart, Extent, true );
}

/** Returns true if a certain percentage of enemies are hidden */
function bool SomeEnemiesAreHidden()
{
	local KFPawn KFP;
	local float TargetDist;
	local int i, NumValidHiddenEnemies;

	for( i = 0; i < HiddenEnemies.Length; ++i )
	{
		KFP = HiddenEnemies[i].TrackedEnemy;
		if( !KFP.IsAliveAndWell() || MyPatPawn.IsSameTeam(KFP) )
		{
			continue;
		}

		// Too close or too far
		TargetDist = VSizeSQ(KFP.Location - MyPatPawn.Location);
		if( TargetDist < MyPatPawn.MinMortarRangeSQ || TargetDist > MyPatPawn.MaxMortarRangeSQ )
		{
			continue;
		}

		NumValidHiddenEnemies++;

		if( NumValidHiddenEnemies >= 2
			|| NumValidHiddenEnemies >= (Max(HiddenEnemies.Length + RecentlySeenEnemyList.Length, 1)/2) )
		{
			return true;
		}
	}

	return false;
}

/*********************************************************************************************
* Notifications
**********************************************************************************************/

/** Overloaded to handle door usage in cloaked state */
function NotifyAttackDoor( KFDoorActor Door )
{
    // We need to count up the total flee time so infinite fleeing isn't possible
    if( bFleeing || bWantsToFlee )
    {
    	if( bFleeing )
    	{
	        bFleeInterrupted = true;
	        bFleeing = false;
	        TotalFleeTime = TotalFleeTime + (WorldInfo.TimeSeconds - FleeStartTime);
	        bWantsToFlee = true;
	    }
        
        // Kill our flee and move commands
        AbortCommand( CommandList );

        // Allow melee again
        EnableMeleeRangeEventProbing();

        // Restart default command
        BeginCombatCommand( GetDefaultCommand(), "Restarting default command" );
    }
	else if( MyPatPawn.bIsCloaking )
	{
		MyPatPawn.SetCloaked( false );
		bWantsToCharge = true;
	}

	super.NotifyAttackDoor( Door );
}

/** Overloaded to handle door usage in cloaked state */
function bool DoorFinished()
{
	local bool bSuperFinished;

	bSuperFinished = super.DoorFinished();

	if( bWantsToFlee && !bFleeing )
	{
		if( MyPatPawn.IsDoingSpecialMove() )
		{
			MyPatPawn.EndSpecialMove();
		}
		Flee();
	}
	else if( bWantsToCharge )
	{
		ChangeEnemy( CachedChargeTarget, false );
		bDoingChargeAttack = true;
		bSprintUntilAttack = true;
		bWantsToCharge = false;
		MyPatPawn.SetSprinting( true );
		MyPatPawn.SetCloaked( true );
		SetTimer( 2.f, false, nameOf(Timer_SearchForChargeObstructions) );		

		// Delay ranged attack checking a bit
		NextAttackCheckTime = 2.5f + fRand();
	}

	return bSuperFinished;
}

/** Overloaded to decloak patty and set pending flee */
function NotifyAttackActor( Actor A )
{
	// do nothing for now, causes issues

	/**
	// We need to count up the total flee time so infinite fleeing isn't possible
	if( bFleeing )
	{
		TotalFleeTime = TotalFleeTime + (WorldInfo.TimeSeconds - FleeStartTime);
		bWantsToFlee = true;
		bFleeInterrupted = true;
		bFleeing = false;
		
		// Kill our flee command
		AbortCommand( FindCommandOfClass(class'AICommand_Flee') );

		// Allow melee again
		EnableMeleeRangeEventProbing();
	}
	else if( MyPatPawn.bIsCloaking )
	{
		MyPatPawn.SetCloaked( false );
		bWantsToCharge = true;
	}

	super.NotifyAttackActor( A );**/
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
		if( MyPatPawn.IsDoingSpecialMove() )
		{
			MyPatPawn.EndSpecialMove();
		}

		// Delay flee by a tiny bit to allow command to finish up
		SetTimer( 0.06f, false, nameOf(Flee) );
	}
}

function NotifySpecialMoveEnded( KFSpecialMove SM )
{
    super.NotifySpecialMoveEnded(SM);

    bFleeInterrupted = false;

    if( !bWantsToFlee )
    {
	  	if( SM.Handle == 'KFSM_DoorMeleeAttack'
	  		|| SM.Handle == 'KFSM_MeleeAttack'
	  		|| SM.Handle == 'KFSM_Patriarch_Grapple'
	  		|| SM.Handle == 'KFSM_Patriarch_MinigunBarrage' )
		{
		    if( PendingDoor == none && bWantsToCharge && CachedChargeTarget != none && CachedChargeTarget.IsAliveAndWell() )
		    {
				ChangeEnemy( CachedChargeTarget, false );
				bDoingChargeAttack = true;
				bSprintUntilAttack = true;
				bWantsToCharge = false;
				MyPatPawn.SetSprinting( true );
				MyPatPawn.SetCloaked( true );
				SetTimer( 2.f, false, nameOf(Timer_SearchForChargeObstructions) );

				// Delay ranged attack checking a bit
				NextAttackCheckTime = 2.5f + fRand();
		    }
		    else if( bRaging )
			{
				RageAttackCount++;
				UpdateRageState();
			}
	        else if( bSprintUntilAttack )
	        {
				if( bDoingChargeAttack )
				{
					LastChargeAttackTime = WorldInfo.TimeSeconds;
				}

				LastSprintTime = WorldInfo.TimeSeconds;
		        bSprintUntilAttack = false;
		        bWantsToCharge = false;
		        CachedChargeTarget = none;
				ClearTimer( nameOf(Timer_SearchForChargeObstructions) );
		    }

		    // Retarget if it's been enough time since we changed targets
		    if( SM.Handle == 'KFSM_MeleeAttack' && `TimeSince(LastRetargetTime) > RetargetWaitTime )
		    {
		    	CheckForEnemiesInFOV( 3000.f, -1.f, 1.f, true );
		    }
		}
		else if( SM.Handle == 'KFSM_Patriarch_Heal' )
		{
			// Get a new enemy
			ChangeEnemy( GetClosestEnemy(), true );

			// Start moving to enemy
			SetEnemyMoveGoal( self, true );

			// Enable attacks again
			NextAttackCheckTime = fRand();
		}		

		// Use special move handlers, AI commands have a slight delay before popping    
		if( SM.Handle == 'KFSM_Patriarch_MinigunBarrage' )
		{
			NextAttackCheckTime = 2.25f+fRand();
			CheckForEnemiesInFOV( 2000.f, -1.f, 1.f );
		}
		else if( SM.Handle == 'KFSM_Patriarch_MissileAttack' )
		{
			LastMissileAttackTime = WorldInfo.TimeSeconds;
			NextAttackCheckTime = 2.25f+fRand();
			CheckForEnemiesInFOV( 2000.f, -1.f, 1.f );
		}
		else if( SM.Handle == 'KFSM_Patriarch_MortarAttack' )
		{
			LastMortarAttackTime = WorldInfo.TimeSeconds;
			NextAttackCheckTime = 2.25f+fRand();
			CheckForEnemiesInFOV( 2000.f, -1.f, 1.f );
		}
		else if( SM.Handle == 'KFSM_Patriarch_Grapple' )
		{
			// We don't want the grab to retarget so we can kick our enemy in the face
			LastSuccessfulAttackTime = WorldInfo.TimeSeconds;
			LastGrabAttackTime = WorldInfo.TimeSeconds;
			NextAttackCheckTime = 2.25f+fRand();
		}

		// Turn ranged attack eval back on
		bCanEvaluateAttacks = true;

	    // Turn melee attack probing back on
	    EnableMeleeRangeEventProbing();
    }
    else if( PendingDoor == none && !bFleeing )
	{
		bSprintUntilAttack = false;
		Flee();
	}

	// Evaluate sprinting whenever we finish a special move so sprinting will be snappy!
    EvaluateSprinting();

    // Reset charge attack state
    bDoingChargeAttack = false;
}

/** Reset minigun timer if we've landed a successful melee attack */
function NotifyMeleeDamageDealt()
{
	super.NotifyMeleeDamageDealt();

	LastSuccessfulAttackTime = WorldInfo.TimeSeconds;
}

/** If a monster other than the Patriarch is killed, and the Patriarch sees it, rage out */
function NotifyKilled( Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageType )
{
	if( GetIsInZedVictoryState() )
	{
		return;
	}

	if( self == Killer && Killed.GetTeamNum() != GetTeamNum() )
	{
		`DialogManager.PlayPattyKilledDialog( MyPatPawn, damageType );
	}
	else if( !bWantsToFlee && !bFleeing && !bRagedThisPhase && MyPatPawn.MaxRageAttacks > 0
		&& !MyPatPawn.IsDoingSpecialMove(SM_Heal) && Killed != self && Killed.GetTeamNum() == GetTeamNum() )
	{
		if( CanSee(KilledPawn) )
		{
			if( Killer.Pawn != none )
			{
				ChangeEnemy( Killer.Pawn, false );
			}
			StartPaternalInstinct();
		}
	}
	else if( Killed.Pawn == Enemy && MyPatPawn.IsDoingSpecialMove(SM_HoseWeaponAttack) )
	{
		// Allow minigun kills to either force a target switch or end the move
		KFSM_Patriarch_MinigunBarrage( MyPatPawn.SpecialMoves[SM_HoseWeaponAttack] ).Timer_SearchForMinigunTargets();
	}

	super.NotifyKilled( Killer, Killed, KilledPawn, damageType );
}

/** Notification from the pawn that it has taken damage */
function NotifyTakeHit( Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum )
{
	local KFPawn EnemyPawn;
	local int EnemyIndex;
	local int pawnDmg;
	local vector pawnRotToVec;

	// Aggro system
	if( InstigatedBy.Pawn != none )
	{
		EnemyPawn = KFPawn(InstigatedBy.Pawn);
		if( EnemyPawn != none )
		{
			EnemyIndex = RecentlySeenEnemyList.Find( 'TrackedEnemy', EnemyPawn );
			if( EnemyIndex != INDEX_NONE )
			{
				pawnDmg = Damage;
				pawnRotToVec = vector(MyPatPawn.Rotation);
				pawnRotToVec.Z = 0.f;
				if( pawnRotToVec dot Normal2D(EnemyPawn.Location - MyPatPawn.Location) < -0.25f )
				{
					// Aggro damage scales by 2 if it came from behind
					pawnDmg *= 2;
				}
				RecentlySeenEnemyList[EnemyIndex].AggroDamage += pawnDmg;
				RecentlySeenEnemyList[EnemyIndex].LastTakeDamageTime = WorldInfo.TimeSeconds;
			}
			else
			{
				EnemyIndex = HiddenEnemies.Find( 'TrackedEnemy', EnemyPawn );
				if( EnemyIndex != INDEX_NONE )
				{
					pawnDmg = Damage;
					pawnRotToVec = vector(MyPatPawn.Rotation);
					pawnRotToVec.Z = 0.f;
					if( pawnRotToVec dot Normal2D(EnemyPawn.Location - MyPatPawn.Location) < -0.25f )
					{
						// Aggro damage scales by 2 if it came from behind
						pawnDmg *= 2;
					}
					HiddenEnemies[EnemyIndex].AggroDamage += pawnDmg;
					HiddenEnemies[EnemyIndex].LastTakeDamageTime = WorldInfo.TimeSeconds;
				}
			}
		}
	}

    // When our health gets low, summon zeds and escape from the battle to heal
    if( !bWantsToFlee && !bFleeing && MyPatPawn != None && !MyPatPawn.bHealedThisPhase && MyPatPawn.CanSummonChildren()
    	&& !MyPatPawn.IsDoingSpecialMove(SM_Heal) )
    {
		if( !bSummonedThisPhase && GetHealthPercentage() < FleeHealthThreshold+0.075f )
		{
			bSummonedThisPhase = true;
			MyAIDirector.bForceFrustration = true;
		    MyPatPawn.SummonChildren();

			// Fallback so zeds can't spawn forever
			SetTimer( 30.f, false, nameOf(Timer_StopSummoningZeds) );
		}

	   	if( !MyPatPawn.IsDoingSpecialMove(SM_Taunt) && GetHealthPercentage() < FleeHealthThreshold )
	   	{
	   		// Force any special move to end
	   		if( MyPatPawn.IsDoingSpecialMove() )
	   		{
	   			MyPatPawn.EndSpecialMove();
	   		}

	   		// Prevent timeout from interrupting flee
	   		if( GetActiveCommand().IsA('AICommand_SpecialMove') )
	   		{
	   			AICommand_SpecialMove(GetActiveCommand()).ClearTimeout();
	   		}

	   		TotalFleeTime = 0.f;
	   		bCanEvaluateAttacks = false;
	   		bWantsToFlee = true;
		    EndPanicWander();
			NextBattlePhase();
   			class'AICommand_TauntEnemy'.static.Taunt( self, Enemy, TAUNT_Enraged, class'KFSM_Patriarch_Taunt' );
	       	MyPatPawn.SetFleeAndHealMode( true );
	   	}
	}

    Super.NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

/*********************************************************************************************
* Paternal Instinct
**********************************************************************************************/

/** Enter Paternal Instinct mode. Rage out! */
function StartPaternalInstinct()
{
	//local KFPawn MissileEnemy;

	// Play a dialog event
	`DialogManager.PlayPattyChildKilledDialog( MyPatPawn );

	// Let the rest of code know we're raging
	bRaging = true;
	bRagedThisPhase = true;

	// Zero our attack count
	RageAttackCount = 0;

	// Set the maximum number of attacks via phase and difficulty
	MaxRageAttacks = MyPatPawn.MaxRageAttacks + Max(0, MyKFGameInfo.GetModifiedGameDifficulty() - 1);

	// Always sprint when raging
	MyPatPawn.SetSprinting( true );

	// Set our timeout timer
	SetTimer( RageTimeOut, false, nameOf(Timer_RageTimeOut) );

	/*// Do our mortar rage if the ceiling is clear
	if( !MyPatPawn.IsDoingSpecialMove(SM_StandAndShootAttack) && !MyPatPawn.IsDoingSpecialMove(SM_SonicAttack) )
	{
		if( IsCeilingClear() && CollectMortarTargets(true, true) )
		{
			if( MyPatPawn.IsDoingSpecialMove() )
			{
				MyPatPawn.EndSpecialMove();
			}

			class'AICommand_Patriarch_MortarAttack'.static.FireMortar( self, true );
			bCanEvaluateAttacks = false;
		}
		else if( RecentlySeenEnemyList.Length > 0 )
		{
			if( MyPatPawn.IsDoingSpecialMove() )
			{
				MyPatPawn.EndSpecialMove();
			}

			// See if our enemy was visible recently, if not then choose a random visible one
			MissileEnemy = KFPawn(Enemy);
			if( RecentlySeenEnemyList.Find('TrackedEnemy', MissileEnemy) == INDEX_NONE )
			{
				MissileEnemy = RecentlySeenEnemyList[Rand(RecentlySeenEnemyList.Length)].TrackedEnemy;
			}

			ChangeEnemy( MissileEnemy, false );
			class'AICommand_Patriarch_MissileAttack'.static.FireMissiles( self );
			bCanEvaluateAttacks = false;
		}
	}*/
}

/** Determine if rage state should continue, if so try to get a new enemy */
function UpdateRageState()
{
	local float DistSQ, BestDistSQ;
	local KFPawn KFP, BestTarget;
	local int i;

	// Stop raging if we've cleared the attack threshold
	if( RageAttackCount >= MaxRageAttacks )
	{
		bRaging = false;
		bCanEvaluateAttacks = true;
		RageAttackCount = 0;
		RageAttackedTargets.Length = 0;
		ClearTimer( nameOf(Timer_RageTimeOut) );

		// See if we can still sprint or not
		EvaluateSprinting();
	}
	else
	{
		// Find a (hopefully new) enemy to rage out on
		foreach WorldInfo.AllPawns( class'KFPawn', KFP )
		{
			if( !KFP.IsAliveAndWell() || MyPatPawn.IsSameTeam(KFP) )
			{
				continue;
			}

			// Prefer players that haven't been attacked yet
			if( RageAttackedTargets.Find(KFP) != INDEX_NONE )
			{
				continue;
			}

			// Filter out players that are too far
			DistSQ = VSizeSQ( KFP.Location - MyPatPawn.Location );
			if( DistSQ > MaxRageRangeSQ )
			{
				continue;
			}

			// Favor closer targets
			if( BestDistSQ == 0.f || DistSQ < BestDistSQ )
			{
				BestDistSQ = DistSQ;
				BestTarget = KFP;
			}
		}

		if( BestTarget == none )
		{
			// Most recent targets are at the end of the array, start at the top
			for( i = 0; i < RageAttackedTargets.Length; ++i )
			{
				KFP = RageAttackedTargets[i];

				// Remove any enemies that are no longer valid
				if( KFP == none || !KFP.IsAliveAndWell() )
				{
					RageAttackedTargets.Remove( i, 1 );
					--i;
					continue;
				}

				// Get the first target that's within range
				DistSQ = VSizeSQ( KFP.Location - MyPatPawn.Location );
				if( DistSQ > MaxRageRangeSQ )
				{
					continue;
				}

				BestTarget = KFP;
				RageAttackedTargets.Remove(i, 1);
				break;
			}
		}

		if( BestTarget != none )
		{
			RageAttackedTargets[RageAttackedTargets.Length] = BestTarget;
			ChangeEnemy( BestTarget );
		}
		else
		{
			// End rage state if we couldn't get a valid target
			RageAttackCount = MaxRageAttacks;
			UpdateRageState();
		}
	}
}

/** If we've raged for too long, end Paternal Instinct */
function Timer_RageTimeOut()
{
	// End rage state if it's been too long
	RageAttackCount = MaxRageAttacks;
	UpdateRageState();
}

/*********************************************************************************************
* Pathfinding
**********************************************************************************************/

function bool AmIAllowedToSuicideWhenStuck()
{
	return false;
}

/*********************************************************************************************
* Zed Summoning
**********************************************************************************************/

/** Stop summoning children */
function Timer_StopSummoningZeds()
{
	// Allow summoning of children for this phase
	bSummonedThisPhase = false;	

	super.Timer_StopSummoningZeds();
}

/*********************************************************************************************
* Flee And Heal
**********************************************************************************************/

/** Initiate the Patriarch's next battle phase */
function NextBattlePhase()
{
	bRagedThisPhase = false;
 	
 	// Play a dialog event
 	`DialogManager.PlayPattyBattlePhaseDialog( MyPatPawn, MyPatPawn.CurrentBattlePhase );
	
	if( MyPatPawn != None )
	{
		MyPatPawn.IncrementBattlePhase();
	}
}

/** Custom target searching when fleeing -- we only want to attack targets that are blocking our flee path */
function Timer_SearchForFleeObstructions()
{
	local KFPawn ObstructingEnemy;

	if( !bFleeing || bWantsToFlee || MyPatPawn.IsDoingSpecialMove() )
	{
		SetTimer( 0.25f, false, nameOf(Timer_SearchForFleeObstructions) );
		return;
	}

	// See if there's someone blocking us
	ObstructingEnemy = CheckForEnemiesInFOV( AttackRange * 1.1f, 0.4f, 1.f, false, false );
	if( ObstructingEnemy != none )
	{
		// We need to count up the total flee time so infinite fleeing isn't possible
		TotalFleeTime = TotalFleeTime + (WorldInfo.TimeSeconds - FleeStartTime);
		bFleeInterrupted = true;
		bFleeing = false;

		// Temporarily end flee state
		MyPatPawn.SetCloaked( false );

        // Kill our flee and move commands
        AbortCommand( CommandList );

		// Set our new enemy
		ChangeEnemy( ObstructingEnemy, false );

		// Set our pending flee
		bWantsToFlee = true;

		// Sprint to new enemy
		bSprintUntilAttack = true;
		SetEnemyMoveGoal( self, true );
		EnableMeleeRangeEventProbing();

        // Restart default command
        BeginCombatCommand( GetDefaultCommand(), "Restarting default command" );

		// Give the patty a little bit of time to flee after this attack
		SetTimer( 3.0f, false, nameOf(Timer_SearchForFleeObstructions) );
	}
	else
	{
		SetTimer( 0.25f, false, nameOf(Timer_SearchForFleeObstructions) );
	}
}

/** Searches for enemies that are blocking the path to my charge target */
function Timer_SearchForChargeObstructions()
{
	local KFPawn ObstructingEnemy;

	if( bWantsToCharge || MyPatPawn.IsDoingSpecialMove() )
	{
		SetTimer( 0.25f, false, nameOf(Timer_SearchForChargeObstructions) );
		return;
	}

	// See if there's someone blocking us
	ObstructingEnemy = CheckForEnemiesInFOV( AttackRange * 1.1f, 0.4f, 1.f, false, false );
	if( ObstructingEnemy != none )
	{
		// Set our new enemy
		MyPatPawn.SetCloaked( false );
		ChangeEnemy( ObstructingEnemy, false );

		// Set pending charge
		bWantsToCharge = true;
	}
	else
	{
		SetTimer( 0.25f, false, nameOf(Timer_SearchForChargeObstructions) );
	}
}

/** Bump damage for human players */
function DoHeavyBump( Actor Other, vector HitNormal )
{
	local KFPawn_Human KFPH;

	// Only bump human pawns when we're not in the middle of an attack
	if( IsTimerActive(nameOf(Timer_SearchForFleeObstructions)) )
	{
		KFPH = KFPawn_Human( Other );
		if( KFPH != none )
		{
			KFPH.TakeDamage( HumanBumpDamage, self, KFPH.Location, HitNormal*HumanBumpMomentum, MyPatPawn.GetBumpAttackDamageType() );
			return;
		}
	}

	DoHeavyZedBump( Other, HitNormal );
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

	/*if( Other.IsA('KFDestructibleActor') && !GetActiveCommand().IsA('AICommand_Melee') && Other.bCollideActors && !MyPatPawn.IsDoingSpecialMove() )
	{
		AIZeroMovementVariables();
		DisableBump(2.f);
		NotifyAttackActor( Other );
		return true;
	}*/

	BumpedMonster = KFPawn_Monster(Other);
	if( BumpedMonster == none || !BumpedMonster.IsAliveAndWell() || BumpedMonster.ZedBumpDamageScale <= 0 )
	{
		return false;
	}

	if( MyPatPawn == none || !MyPatPawn.IsAliveAndWell() )
	{
		return false;
	}

	// Patriarch knocks guys out of the way always if he is in hunt and heal
    if( MyPatPawn.bIsSprinting && !MyKFPawn.IsDoingSpecialMove() )
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

/* Starts Flee AICommand, with optional duration and distance */
function DoFleeFrom( actor FleeFrom,
	optional float FleeDuration,
	optional float FleeDistance,
	optional bool bShouldStopAtGoal=false,
	optional bool bFromFear=false,
	optional bool bUseRandomDirection=false )
{
	if( !bFromFear || !MyPatPawn.bInFleeAndHealMode )
	{
        super.DoFleeFrom( FleeFrom, FleeDuration, FleeDistance, bShouldStopAtGoal, bFromFear, bUseRandomDirection );
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
		FleeFromTarget = class'NavigationPoint'.static.GetNearestNavToActor( MyPatPawn );
	}

	// If we somehow ended up taking a ton of damage in rage state, turn it off
	if( bRaging )
	{
		RageAttackCount = MaxRageAttacks;
		UpdateRageState();
	}

	// Prevent timeout from interrupting flee
	AICSM = FindCommandOfClass(class'AICommand_SpecialMove');
	if( AICSM != none )
	{
		AICSM.ClearTimeout();
	}

    // Abort all commands
    EndPanicWander();
    AbortCommand( CommandList );

	// Perform flee
	bFleeing = true;
	bCanEvaluateAttacks = false;
	MyPatPawn.SetCloaked( true );
	SetSprintingDisabled( false );
	MyPatPawn.SetSprinting( true );
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
		SetTimer( 2.f, false, nameOf(Timer_SearchForFleeObstructions) );
	}
}

/** We have finished fleeing for one reason or another, notify pawn to heal */
function NotifyFleeFinished( optional bool bAcquireNewEnemy=true )
{
	// If this was not a flee for healing, don't do additional cleanup
	if( !MyPatPawn.bInFleeAndHealMode )
	{
		return;
	}

	if( MyPatPawn != None )
	{
		MyPatPawn.SetCloaked( false );

		// Delay stop summoning, to give paternal instinct a chance to trigger
		if( IsTimerActive(nameOf(Timer_StopSummoningZeds)) )
		{
			SetTimer( 4.f, false, nameOf(Timer_StopSummoningZeds) );
		}

		// Stop searching for targets
		ClearTimer( nameOf(Timer_SearchForFleeObstructions) );

		// Flee debug
		//`log("[HEAL] FleeDuration:"@fMax(MaxFleeDuration - TotalFleeTime, 6.f));
		//`log("[HEAL] FleeEndTime:"@WorldInfo.TimeSeconds);
		//scripttrace();

		// End flee state
		bWantsToFlee = false;
		bFleeing = false;

		// Heal
		MyPatPawn.DoSpecialMove( SM_Heal,,, class'KFSM_Patriarch_Heal'.static.PackSMFlags(MyPatPawn.CurrentBattlePhase-1) );
	}

    // Allow melee again
	EnableMeleeRangeEventProbing();

    // Restart default command
	BeginCombatCommand( GetDefaultCommand(), "Restarting default command" );
}

/** Forces a heal regardless of what state we're in */
function ForceHeal()
{
    if( bFleeing )
    {
        bFleeing = false;
        bWantsToFlee = false;

        // Kill our flee command
        AbortCommand( FindCommandOfClass(class'AICommand_Flee') );
    }
    else
    {
        // Make sure hans doesn't try to flee again
        bWantsToFlee = false;
    }

    // End flee as normal
    NotifyFleeFinished( false );
}

/** Victory */
function EnterZedVictoryState()
{
	bCanEvaluateAttacks = false;
	bRaging = false;
	MyPatPawn.SetCloaked( false );
	bWantsToFlee = false;
	bFleeing = false;
	bFleeInterrupted = false;

	if( IsTimerActive(nameOf(Timer_SearchForFleeObstructions)) )
	{
		ClearTimer( nameOf(Timer_SearchForFleeObstructions) );
	}

	if( IsTimerActive(nameOf(Timer_SearchForChargeObstructions)) )
	{
		ClearTimer( nameOf(Timer_SearchForChargeObstructions) );
	}

	if( IsTimerActive(nameOf(Timer_RageTimeOut)) )
	{
		ClearTimer( nameOf(Timer_RageTimeOut) );
	}

	MyKFGameInfo.SpawnManager.StopSummoningBossMinions();
	super.EnterZedVictoryState();

	KFWeapon(MyPatPawn.Weapon).GotoState( 'Inactive' );
}

state ZedVictory
{
	ignores NotifyTakeHit, NotifyKilled, NotifySpecialMoveEnded, NotifyFleeFinished, SeePlayer, UpdateRageState, CheckForEnemiesInFOV,
			EvaluateSprinting, ChangeEnemy, SetEnemy, FindNewEnemy, EvaluateAttacks, UpdateRecentlySeenEnemyList, Timer_SearchForFleeObstructions,
			Timer_SearchForChargeObstructions;

Begin:
	Sleep(0.1f);
	class'AICommand_BossTheatrics'.static.DoTheatrics( self, THEATRIC_Victory, -1 );
}

/*********************************************************************************************
* Dialog
********************************************************************************************* */

function PlayDamagePlayerDialog( class<DamageType> DmgType )
{
	//`DialogManager.PlayHansDamagePlayerDialog( MyHansPawn, DmgType );
}

/*********************************************************************************************
* Debug
********************************************************************************************* */

simulated function DrawDebug( KFHUDBase HUD, name Category )
{
	local Canvas C;

	super.DrawDebug( HUD, Category );

	if( MyPatPawn == None || Category != 'All' )
	{
		return;
	}

	C = HUD.Canvas;
	// Patriarch info
	C.SetDrawColor( 255, 255, 255, 255 );
	DrawDebugText( HUD, "************************************************************" );
	C.SetDrawColor( 0, 0, 255, 255 );
	DrawDebugText( HUD, "PATRIARCH STATUS" );
	C.SetDrawColor( 0, 255, 0, 255);
	DrawDebugText( HUD, "BattlePhase:"@MyPatPawn.CurrentBattlePhase );
}


`if(`notdefined(ShippingPC))
/** Debug command to advance battle phase */
function DebugNextPhase()
{
	// Force any special move to end
	if( MyPatPawn.IsDoingSpecialMove() )
	{
		MyPatPawn.EndSpecialMove();
	}

	bCanEvaluateAttacks = false;
	bWantsToFlee = true;
	NextBattlePhase();
	//MyPatPawn.DoSpecialMove( SM_Heal,,, class'KFSM_Patriarch_Heal'.static.PackSMFlags(MyPatPawn.CurrentBattlePhase-1) );
	class'AICommand_TauntEnemy'.static.Taunt( self, Enemy, TAUNT_Enraged, class'KFSM_Patriarch_Taunt' );
   	MyPatPawn.SetFleeAndHealMode( true );
}
`endif

DefaultProperties
{
	Steering=none
	DefaultCommandClass=class'KFGameContent.AICommand_Base_Patriarch'
	MeleeCommandClass=class'KFGameContent.AICommand_Base_Patriarch'
    bRepathOnInvalidStrike=true
	LastRecentSeenEnemyListUpdateTime=0.1
	LostSightSprintDelay=5.0
	bSprintUntilAttack=true
	bHadMinigunAttack=false
	bCanDoHeavyBump=true
	EvadeGrenadeChance=1.0f
	RetargetWaitTime=5.f
	AggroFalloffWaitTime=1.f
	AggroFalloffPerSecond=25.f
	VisibleAggroDmgThreshold=260.f
	HiddenAggroDmgThreshold=200.f

    // Run over warning
    bUseRunOverWarning=true
    MinRunOverSpeed=360.f
    MinRunOverWarningAim=0.85f

	// Special attacks
	MinMinigunRangeSQ=160000.f
	MaxMinigunRangeSQ=16000000.f
	MaxFanFireRangeSQ=490000.f
	MinChargeRangeSQ=810000.f
	MinTentacleRangeSQ=90000.f
	MinMissileRangeSQ=360000.f
	MaxMissileRangeSQ=16000000.f

	// Flee
	HumanBumpDamage=10.f
	HumanBumpMomentum=8000.f
	FleeHealthThreshold=0.35f
	MaxFleeDuration=25.f
	MaxFleeDistance=20000.f

	// Rage
	MaxRageRangeSQ=1440000.f
	RageTimeOut=16.f

	// ---------------------------------------------
	// Danger Evasion Settings
	DangerEvadeSettings.Empty

    //Aim Blocks
    DangerEvadeSettings(0)={(ClassName="KFWeap_Rifle_Winchester1894",
                                Cooldowns=(0.0, 0.0, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.0, 0.0, 1.0, 1.0))}
    DangerEvadeSettings(1)={(ClassName="KFWeap_Bow_Crossbow",
                                Cooldowns=(0.0, 0.0, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.0, 0.0, 1.0, 1.0))}
    DangerEvadeSettings(2)={(ClassName="KFWeap_Rifle_M14EBR",
                                Cooldowns=(0.0, 0.0, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.0, 0.0, 1.0, 1.0))}
    DangerEvadeSettings(3)={(ClassName="KFWeap_Rifle_RailGun",
                                Cooldowns=(0.0, 0.0, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.0, 0.0, 1.0, 1.0))}	
    DangerEvadeSettings(4)={(ClassName="KFWeap_Bow_CompoundBow",
                                Cooldowns=(0.0, 0.0, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.0, 0.0, 1.0, 1.0))}
}