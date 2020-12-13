//=============================================================================
// KFAIController_Monster.uc
//=============================================================================
// Base AIController for KF2's Zeds
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_Monster extends KFAIController
	dependson(KFAIController)
	abstract
	native(AI);

`include(KFGame\KFGameAnalytics.uci);

/** Zeds who can grab prefer to use a grab as their initial attack - if true, they've already done this */
var bool		bCompletedInitialGrabAttack;
/** Clot won't perform grab until closer than this distance. TODO: If we keep this, change it to a % scale of MaxGrabDistance in KFSM_Clot_Grab */
var float		MinDistanceToPerformGrabAttack;
/** Time frequency for grab attacks */
var float		MinTimeBetweenGrabAttacks;
/** Last time a grab attack was performed */
var float		LastAttackTime_Grab;
var bool		bPathAroundDestructiblesICantBreak;
/** Determines if a zed should try to force a repath if they cannot execute a valid strike */
var bool 		bRepathOnInvalidStrike;

/*********************************************************************************************
* RunOverWarning (warns Zeds nearby that my pawn's about to run into them)
********************************************************************************************* */
/** Zed will transmit ReceiveRunOverWarning events to other Zeds if its about to run them over */
var bool		bUseRunOverWarning;
/** Speed must be greater than this to transmit run over warning (if bUseRunOverWarning=true) */
var float		MinRunOverSpeed;
/** Last time checked for pawns to transmit RunOverWarning to (if bUseRunOverWarning=true) */
var	float		LastRunOverWarningTime;
/** Minimum angle to victim required to transmit RunOverWarning (if bUseRunOverWarning=true) */
var	float		MinRunOverWarningAim;
/** When TRUE, this Zed will attempt to evade when warned of being run over */
var bool 		bEvadeOnRunOverWarning;
/** Scales the delay from the initial warning notification. Increase for zeds that are fast evaders, decrease for slow evaders */
var float 		RunOverEvadeDelayScale;

cpptext
{
	UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );

	// Called by native Tick() to evaluate if Zed in melee range of target - if so, will call InMeleeRange() event
	virtual UBOOL TickMeleeCombatDecision( FLOAT DeltaTime );
	// Supports "run over" warning notification to other NPCs - mainly for larger Zeds to use
	// to give nearby Zeds a chance to get out of the way.
	virtual void TickRunOverWarning( FLOAT DeltaSeconds );
}

/*********************************************************************************************
* Initialization, Pawn Possession, and Destruction
********************************************************************************************* */

/** Only spawning a PRI for gameplayevents! */
function InitPlayerReplicationInfo()
{
	local KFGameInfo KFGI;
	local string NPCName;

	KFGI = KFGameInfo(WorldInfo.Game);
	if( KFGI != none && KFGI.bEnableGameAnalytics )
	{
		PlayerReplicationInfo = Spawn(class'KFDummyReplicationInfo', self,, vect(0,0,0),rot(0,0,0));
		if ( Pawn != none )
		{
			NPCName = string(Pawn.name);
			NPCName = Repl(NPCName,"KFPawn_Zed","",false);
		}
		else
		{
			NPCName = string(self.name);
			NPCName = Repl(NPCName,"KFAIController_Zed","",false);
		}

		PlayerReplicationInfo.PlayerName = NPCName;

		/* __TW_ANALYTICS_ */
		`RecordZedSpawn(self);
		// don't call SetPlayerName() as that will broadcast entry messages but the GameInfo hasn't had a chance
		// to potentionally apply a player/bot name yet
		//PlayerReplicationInfo.PlayerName = class'GameInfo'.default.DefaultPlayerName;
	}
}

/** Set MyKFPawn to avoid casting */
event Possess( Pawn inPawn, bool bVehicleTransition )
{
	if( KFPawn_Monster(inPawn) != none )
	{
		MyKFPawn = KFPawn_Monster( inPawn );
	}
	else
	{
		`warn( GetFuncName()$"() attempting to possess "$inPawn$", but it's not a KFPawn_Monster class! MyKFPawn variable will not be valid." );
	}

	super.Possess( inPawn, bVehicleTransition );

	SetPawnDefaults();
}

function SetPawnDefaults()
{
	local float SprintChance;
	local float SprintDamagedChance;
	local float HiddenSpeedMod;
	local float GameDifficulty;
	local KFGameDifficultyInfo DifficultyInfo;
	local KFGameInfo KFGI;

	KFGI = KFGameInfo( WorldInfo.Game );

    GameDifficulty = KFGI.GetModifiedGameDifficulty();
    DifficultyInfo = KFGI.DifficultyInfo;

	SprintChance = DifficultyInfo.GetCharSprintChanceByDifficulty( MyKFPawn, GameDifficulty );
	SprintDamagedChance = DifficultyInfo.GetCharSprintWhenDamagedChanceByDifficulty( MyKFPawn, GameDifficulty );
	HiddenSpeedMod = DifficultyInfo.GetAIHiddenSpeedModifier( KFGI.GetLivingPlayerCount() );
	MyKFPawn.HiddenGroundSpeed = MyKFPawn.default.HiddenGroundSpeed * HiddenSpeedMod;

	if ( MyKFPawn.PawnAnimInfo != none )
	{
		MyKFPawn.PawnAnimInfo.SetDifficultyValues( DifficultyInfo );
	}

	// Each zed has a chance he will sprint at a certain difficulty
	// NOTE: Some zeds now bypass this check because they need to sprint under certain conditions regardless of
	//	difficulty!  Search the code for bIsSprinting = true.  Evil, yes, but necessary
	SetCanSprint( FRand() <= SprintChance );
	SetCanSprintWhenDamaged( FRand() <= SprintDamagedChance );

	bDefaultCanSprint = bCanSprint;

	if( KFGI.BaseMutator != None )
	{
		KFGI.BaseMutator.ModifyAI( Pawn );
	}
}

/*********************************************************************************************
* Notifications & Events
********************************************************************************************* */

/** Re-Enables notifications from TickMeleeCombatDecision() */
function Timer_EnableMeleeRangeEventProbing()
{
	if( !MyKFPawn.IsDoingSpecialMove() )
	{
		EnableMeleeRangeEventProbing();
	}
	else
	{
		// Re-Enable timer once at a time (added 7/2014)
		SetTimer( 0.12f, false, nameof(Timer_EnableMeleeRangeEventProbing), self );
	}
}

/** Notification that we have passed all our basic melee checks and are ready to attempt a melee attack */
event ReadyToMelee()
{
	// Check script to see if a strike is allowed
	if( CanDoStrike() )
	{
		// Update our next pending strike
		UpdatePendingStrike();
		LastGetStrikeTime = WorldInfo.TimeSeconds;

		// Perform strike if we have a valid animation
		if( PendingAnimStrikeIndex != 255 )
		{
			DoStrike();
			return;
		}
	}

	// Attempt to find another path to enemy
	if( bRepathOnInvalidStrike && (bFailedToMoveToEnemy || (!bMovingToGoal && !bMovingToEnemy)) )
	{
		SetEnemyMoveGoal(self, true,,, true);
	}
	// If we can't attack, and are close to the enemy, do a taunt so we don't just stand there
	else if( !CheckOverallCooldownTimer() && Enemy != none && Pawn != none && Pawn.IsAliveAndWell() )
	{
        if( VSize(Enemy.Location - Pawn.Location) < MyKFPawn.CylinderComponent.CollisionRadius * 3.0 )
		{
			if( MyKFPawn.CanDoSpecialMove(SM_Taunt) && `TimeSince(LastTauntTime) > 2.f )
			{
				`AILog( GetFuncName()$" starting taunt command", 'CantMelee' );
				class'AICommand_TauntEnemy'.static.Taunt( self, KFPawn(Enemy), TAUNT_Standard );
			}
		}
	}
}

/*********************************************************************************************
* Pathfinding
********************************************************************************************* */

/** Set up path constraints and attempt to build a path to Goal actor. Distance is an optional offset. */
event Actor GeneratePathTo( Actor Goal, optional float Distance, optional bool bAllowPartialPath )
{
	local actor PathResult;
	local int i;

	if( bDisablePartialPaths )
	{
		bAllowPartialPath = false;
	}

	AddBasePathConstraints();

	class'Path_TowardGoal'.static.TowardGoal( Pawn, Goal );

	if( bPathAroundDestructiblesICantBreak )
	{
		/** NPC will build path around destructible objects not configured to accept bump damage */
		class'Path_AroundDestructibles'.static.AvoidDestructibles( Pawn, true, true );
		class'Goal_Null'.static.GoUntilBust( Pawn, 2024 );
	}
	else
	{
		class'Goal_AtActor'.static.AtActor( Pawn, Goal, Distance, bAllowPartialPath );
	}
	// Attempt to build the path.
	PathResult = FindPathToward( Goal );
	Pawn.ClearConstraints();

	if( PathResult == None )
	{
		`AILog( GetFuncName()$"() failed to build a path to "$Goal$", offset distance was "$Distance$", bAllowPartialPath was "$bAllowPartialPath, 'PathWarning' );
	}

	if( bShowMovePointsDebugInfo )
	{
		for( i = 0; i < RouteCache.Length; i++ )
		{
			DrawDebugStar( RouteCache[i].Location, PathNodeShowRouteCacheCrossSize, PathNodeShowRouteCacheColor.R, PathNodeShowRouteCacheColor.G, PathNodeShowRouteCacheColor.B, true);
			DrawDebugString( RouteCache[i].Location + vect(0,0,5), string(i), , PathNodeShowRouteCacheColor, PathNodeShowRouteCacheNumberLabelDuration);

			if( i > 0 )
			{
				DrawDebugLine( RouteCache[i].Location, RouteCache[i-1].Location, PathNodeShowRouteCacheColor.R, PathNodeShowRouteCacheColor.G, PathNodeShowRouteCacheColor.B, true);
			}
		}
	}

	return PathResult;
}

/*********************************************************************************************
* Combat
**********************************************************************************************/

/** Can this pawn perform a grab attack? */
event bool CanGrabAttack()
{
	local KFPawn_Human KFPH;
	local KFPerk EnemyPerk;
	local KFPawn KFPawnEnemy;
	local float DistSq;
	local vector Extent, HitLocation, HitNormal;
	local Actor HitActor;

	// If I'm dead, incapable of grabbing, or have no enemy, or my enemy is a player, or I'm busy doing a melee attack, refuse.
	if( (MyKFPawn == none || !MyKFPawn.bCanGrabAttack || MyKFPawn.Health <= 0) || (Enemy == none) || (Enemy != none && Pawn.IsSameTeam(Enemy)) )
	{
		return false;
	}

	KFPawnEnemy = KFPawn( Enemy );
	if( KFPawnEnemy == none || !KFPawnEnemy.CanBeGrabbed(MyKFPawn) )
	{
		return false;
	}

	// If I'm crippled, falling, busy doing an attack, or incapacitated, refuse.
	if( MyKFPawn.bIsHeadless || (MyKFPawn.Physics == PHYS_Falling) || IsDoingAttackSpecialMove() || !MyKFPawn.IsCombatCapable() )
	{
		return false;
	}

	// Check for fakeout perk
	KFPH = KFPawn_Human(Enemy);
	if ( KFPH != none )
	{
		EnemyPerk = KFPH.GetPerk();
		if ( EnemyPerk != none && EnemyPerk.CanNotBeGrabbed() )
		{
			return false;
		}
	}

	if( !bCompletedInitialGrabAttack || (LastAttackTime_Grab == 0.f || (`TimeSince(LastAttackTime_Grab) > MinTimeBetweenGrabAttacks)) )
	{
        // Make sure the enemy's center of mass (location) is within my collision cylinder
		if( Abs(Enemy.Location.Z - Pawn.Location.Z) > class'KFSM_GrappleCombined'.default.MaxVictimZOffset )
		{
			return false;
		}

		DistSq = VSizeSq(Enemy.Location - Pawn.Location);
		if( DistSq > MinDistanceToPerformGrabAttack * MinDistanceToPerformGrabAttack || MyKFPawn.IsPawnMovingAwayFromMe(Enemy, 300.f) )
		{
			return false;
		}

		// Set our extent
		Extent.X = Pawn.GetCollisionRadius() * 0.5f;
		Extent.Y = Extent.X;
		Extent.Z = Pawn.GetCollisionHeight() * 0.5f;

        // Do the same kind of trace we do in KFSM_GrappleStart
		HitActor = Trace(HitLocation, HitNormal, Enemy.Location, Pawn.Location, true, Extent);
		if ( HitActor != None && HitActor != Enemy )
		{
            return false;
		}
		if( !CanTargetBeGrabbed(KFPawnEnemy) )
		{
			return false;
		}
		/** Makes Zed have high desire to grab as initial attack */
		if( !MyKFPawn.IsDoingMeleeAttack() && (!bCompletedInitialGrabAttack || (FRand() < MyKFPawn.GrabAttackFrequency)) ) //&& !MyKFPawn.IsPawnMovingAwayFromMe(Enemy, 250.f) )
		{
			return true;
		}
	}
	`AILog( GetFuncName()$"() returning FALSE", 'GrabAttack' );
	return false;
}

function bool CanDoStrike()
{
	local actor HitActor;
	local vector TraceStepLocation;

	// Used by KFPawnAnimInfo to determine if an attack can be performed if legs are blocked (lunges, etc)
	bIsBodyBlocked = false;

	// Check if a wall or another Zed is blocking my pawn from performing a melee attack, ignore zed collision if bCanStrikeThroughEnemies is true,
	TraceStepLocation = Pawn.Location + (vect(0,0,-1) * (Pawn.CylinderComponent.CollisionHeight * 0.5f));
	HitActor = ActorBlockTest( Pawn, Enemy.Location, TraceStepLocation,, !bCanStrikeThroughEnemies );
	if( HitActor != none && HitActor != Enemy )
	{
		if( HitActor.bWorldGeometry )
		{
			// Set the body blocked flag so the anim info can check it
			bIsBodyBlocked = true;
		}

		// Try again at eyeheight
		HitActor = ActorBlockTest( Pawn, Enemy.Location + (vect(0,0,1) * Enemy.BaseEyeHeight), Pawn.Location + (vect(0,0,1) * Pawn.BaseEyeHeight),, !bCanStrikeThroughEnemies );
		if( HitActor != None && HitActor != Enemy && (!bCanStrikeThroughEnemies || HitActor.bWorldGeometry) )
		{
			return false;
		}
	}

	return true;
}

function DoStrike()
{
	local byte StrikeFlags;

	if( MyKFPawn != none && MyKFPawn.PawnAnimInfo != none )
	{
		StrikeFlags = MyKFPawn.PawnAnimInfo.GetStrikeFlags(PendingAnimStrikeIndex);
		if( StrikeFlags != 255 )
		{
			`AILog( GetFuncName()$"() "$VSize(MyKFPawn.Location - Enemy.Location)$" units from enemy and I DO HAVE AN available attack!", 'Command_Attack_Melee' );
			class'AICommand_Attack_Melee'.static.Melee( self, Enemy, StrikeFlags );

			MyKFPawn.PawnAnimInfo.UpdateAttackCooldown(self, PendingAnimStrikeIndex);

			UpdatePendingStrike();
		}
		else
		{
			`AILog( GetFuncName()$"() "$VSize(MyKFPawn.Location - Enemy.Location)$" units from enemy and I have no available attack!", 'Command_Attack_Melee' );
		}
	}
}

/** Perform a melee attack AICommand.. InTarget is optional actor to attack (door, etc.) */
function DoMeleeAttack( optional Pawn NewEnemy, optional Actor InTarget, optional byte AttackFlags )
{
	/*
	local AICommand AIC;

	if( MyKFPawn != none && (!MyKFPawn.bIsHeadless && !MyKFPawn.bEmpPanicked && !IsMeleeRangeEventProbingEnabled()) || (MyKFPawn.IsDoingSpecialMove() && !MyKFPawn.IsDoingSpecialMove(SM_ChargeRun)) )
	{
		`AILog( GetFuncName()$"() skipping melee attack because "$Pawn$" is already busy.", 'Command_Attack_Melee' );
		return;
	}
	AIC = AICommand( GetActiveCommand() );
	if( AIC != none )
	{
		if( !AIC.bAllowedToAttack )
		{
			`AILog( GetFuncName()$"() refusing to do melee attack because "$AIC$" bAllowedToAttack is FALSE", 'Command_Attack_Melee' );
			return;
		}
		if( AICommand_Pause(AIC) != none )
		{
			return;
		}
		if( AICommand_TauntEnemy(AIC) != none )
		{
			return;
		}
	}
	if( MyKFPawn != none && MyKFPawn.PawnAnimInfo != none )
	{
		// Only Pack flags if 255 was initially passed in
		if( AttackFlags == 255 )
		{
			AttackFlags = ChooseStrikeAnimation();
		}

		if( AttackFlags != 255 )
		{
			`AILog( GetFuncName()$"() Aborting movement commands and starting melee attack command", 'Command_Attack_Melee' );
			class'AICommand_Attack_Melee'.static.Melee( self, InTarget, AttackFlags );
		}
		return;
	}

	if( !AICommand(CommandList).bAllowedToAttack )
	{
		`AILog( GetFuncName()$"() refusing to do melee attack because "$CommandList$" bAllowedToAttack is FALSE", 'Command_Attack_Melee' );
	}
	*/
}

/** Called when in melee range but enemy is blocked from me, probably by another Zed */
function bool HandleZedBlockedPath()
{
	local actor HitActor;
	local KFPawn_Monster HitMonster;

	HitActor = ActorBlockTest( Pawn, Enemy.Location + vect(0,0,1) * (Enemy.BaseEyeHeight * 0.5f), MyKFPawn.Location + vect(0,0,1) * (MyKFPawn.BaseEyeHeight * 0.5f), MyKFPawn.GetCollisionExtent() * vect(0.2f,0.2f,0.2f), true );
	if( HitActor == none || HitActor == Enemy )
	{
		return false;
	}

	// If we hit a monster check HandleEnemyBlocked, otherwise we're good to strike
	HitMonster = KFPawn_Monster(HitActor);
	if( HitMonster != none && HitMonster.Health > 0 )
	{
		if( MyKFPawn == none || MyKFPawn.Health <= 0 || MyKFPawn.IsDoingSpecialMove() )
		{
			return true;
		}

		`AILog( GetFuncName()$" ENEMY IS BLOCKED", 'ReachedEnemy' );
		DisableMeleeRangeEventProbing();
		SetTimer( 1.5f + (2.f*FRand()), false, nameof(Timer_EnableMeleeRangeEventProbing), self );
		if( FindNewEnemy() )
		{
			ForcePauseAndRepath();
			return true;
		}

		if( VSize(Enemy.Location - Pawn.Location) < AttackRange && bDirectMoveToGoal )
		{
			if( MyKFPawn.CanDoSpecialMove(SM_Taunt) && FRand() < 0.32 && `TimeSince(LastTauntTime) > 2.f )
			{
				`AILog( GetFuncName()$" starting taunt command", 'ReachedEnemy' );
				class'AICommand_TauntEnemy'.static.Taunt( self, KFPawn(Enemy), TAUNT_Standard );
			}
 			else
 			{
				`AILog( GetFuncName()$" starting pauseAI command", 'ReachedEnemy' );
				DoPauseAI( 1.f + (3.f * FRand()), true );
			}
			return true;
		}
	}
	return false;
}

/** Notification I'm about to be run into by a Zed which has bUseRunOverWarning set to true */
event RunOverWarning( KFPawn IncomingKFP, float IncomingSpeedSquared, vector RunOverPoint )
{
	local float Delay;

	if( bEvadeOnRunOverWarning && CanEvade(true) )
	{
		Delay = ( VSize(IncomingKFP.Location - MyKFPawn.Location) / Sqrt(IncomingSpeedSquared) ) * RunOverEvadeDelayScale;
		DoEvade( GetBestEvadeDir(RunOverPoint,, false), IncomingKFP,, Delay, true );
	}
}

DefaultProperties
{
	// ---------------------------------------------
	// Combat
	MeleeCommandClass=class'AICommand_Base_Zed'
	DoorMeleeDistance=200.f
	MinTimeBetweenGrabAttacks=5.f
	MinDistanceToPerformGrabAttack=188.f

	// ---------------------------------------------
	// AI / Navigation
	DefaultCommandClass=class'AICommand_Base_Zed'
	SightCounterInterval=0.35f
	bEvadeOnRunOverWarning=false
	RunOverEvadeDelayScale=0.25f

	bIsPlayer=false
}