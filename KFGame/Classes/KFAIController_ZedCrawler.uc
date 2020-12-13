//=============================================================================
// KFAIController_ZedCrawler
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Base controller for the Crawler, and responsible for updating its Crawler
// pawn's rotation updates when it's using PHYS_Spider.
//
// * Note!
// * Normally AIControllers receive NotifyHitWall() events, and then the
// * pawn's HitWall() event is called depending on NotifyHitWall's return value.
// * The Crawler receives these events differently. The Crawler pawn first receives
// * its HitWall() event, and it will call its controller's NotifyHitWall() only
// * it doesn't know what else to do about the obstruction. NotifyHitWall() will
// * not be called from native code, however (see usage of the Pawn bDirectHitWall
// * flag).
//=============================================================================

class KFAIController_ZedCrawler extends KFAIController_Monster
	native(AI);

/** Last NavigationPoint used to ambush enemy from (see AICommand_Crawler_MoveToGoal) */
var Actor	LastAmbushNode;
/** Used in emergence related code after rootmotion has stopped */
var vector	LastRMVelocity;
/** Min/Max pathfinding cost applied to pathnodes (the higher the number, the more Crawlers will prefer using WallPathNodes
	(10000000 should make a Crawler never accept a path that isn't composed entirely of wall pathnodes).  */
var int		MinExtraCostForFloorNodes;
var int		MaxExtraCostForFloorNodes;

/** Used in translation adjustments (see Tick() below) */
var vector 	OriginalMeshTranslation;

/*********************************************************************************************
* Emergency teleport handling:
* When FailedToFindAnchorCount exceeds MaxFailedToFindAnchorCount, Crawler will attempt to
* teleport to the nearest navigation point. This fixes problems like badly-placed spawners
* causing Crawlers to sometimes finish KFSM_Emerge partially embedded in a wall, etc. Ideally,
* FitCollision() should fix this, but it's called later for a Crawler than it is for other
* emerged NPCs.
********************************************************************************************* */
/** Tracks how many times I completely failed to build a path */
var int		FailedToFindAnchorCount;
/** Max number of times I can completely fail a path within a short duration before I give up and teleport */
var int		MaxFailedToFindAnchorCount;

/** See usage in UpdatePawnRotation() and CalcCrawlerX() */
var vector	LastCrawlerX;
/** Pawn's previous floor vector */
var vector	OldFloor;

cpptext
{
	// Combat
	virtual UBOOL TickMeleeCombatDecision( FLOAT DeltaTime );
	// Spider Physics
	virtual void UpdatePawnRotation();
	virtual FVector CalcSpiderX();
}


/** Don't turn on steering for Crawlers */
// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//simulated function StartSteering() {}

/** Completely failed to build a path, so increment the failed anchor count and if it's
	exceeded max allowed within 1.5 seconds, the Crawler will attempt to teleport to the
	best nearby navigation point */
event FailedToFindAnchor()
{
	`AILog( "Failed to Find Anchor! Phys: "$MyKFPawn.GetPhysicsName(), 'PathWarning' );
	FailedToFindAnchorCount++;
	if( !IsTimerActive(nameof(Timer_ResetFailedToFindAnchorCount)) )
	{
		SetTimer( 1.5f, false, nameof(Timer_ResetFailedToFindAnchorCount) );
	}
	if( FailedToFindAnchorCount > MaxFailedToFindAnchorCount )
	{
		AttemptToTeleport();
	}
}

/** Resets FailedToFindAnchorCount every 1.5 seconds. */
function Timer_ResetFailedToFindAnchorCount()
{
	FailedToFindAnchorCount = 0;
}

function bool AmIAllowedToStillUsePathNodes()
{
	return true;
}

/** My current enemy is blocked from me, probably because other Zeds are in the way */
// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm P.S. doesn't seem to be called anywhere anyway.
//function bool HandleEnemyBlocked()
//{
//	local KFPathnode KFPN;
//
//	if( (Enemy == none || AICommand_Pause(GetActiveCommand()) != none) && !IsDoingLatentMove() )
//	{
//		return true;
//	}
//
//	if( VSizeSq(Enemy.Location - Pawn.Location) > 160000 )
//	{
//		return false;
//	}
//
//	DisableMeleeRangeEventProbing();
//	SetTimer( 1.5 + (2.f * FRand()), false, nameof(Timer_EnableMeleeRangeEventProbing), self );
//
//	/*
//	React to being blocked from reaching enemy by moving to a KFPathnode with a clear
//	view to my enemy, or by trying to move to a nearby wall (and re-pathing from there), or just
//	kill time by pausing and occasionally taunting.
//	*/
//
//	if( FRand() < 0.25f )
//	{
//		foreach WorldInfo.AllNavigationPoints( class'KFPathnode', KFPN )
//		{
//			// Try to move to a reachable KFPathnode within 500 units of my enemy and that's in a location where my enemy is still visible to me.
//			if( VSize(KFPN.Location - Enemy.Location) < 500.f && CanSeeByPoints( KFPN.Location + (vect(0,0,1) * MyKFPawn.BaseEyeHeight), Enemy.Location, Rotator(Enemy.Location - KFPN.Location)) )
//			{
//				// TODO: Better to use in state code for benefit of latency
//				SetMoveGoal( KFPN,, false, 128.f, false, true, true, false, true );
//				return true;
//			}
//		}
//	}
//	// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
////	else if( FRand() < 0.5f  )
////	{
////		// Abort my current movement command(s) and try to move to a nearby wall.
////		AbortMovementCommands();
////		AbortMovementPlugIns();
////		AICommand_Base_Crawler( GetActiveCommand() ).BeginMoveToWall();
////		return true;
////	}
//	else if( MyKFPawn.CanDoSpecialMove(SM_Taunt) && FRand() < 0.22 && `TimeSince(LastTauntTime) > 2.f )
//	{
//		// Taunt the enemy I'm blocked from reaching.
//		class'AICommand_TauntEnemy'.static.Taunt( self, KFPawn(Enemy), TAUNT_Standard );
//		return true;
//	}
//	else
//	{
//		// Just stay idle and pause.
//		DoPauseAI( 1.f + (0.7f * FRand()), true );
//		return true;
//	}
//
//	return false;
//}

/*********************************************************************************************
* Movement Methods
********************************************************************************************* */

/**
 * ShouldSprint()
 * Timer function called during latent moves that determines whether NPC should sprint or
 * stop sprinting.
 */
function bool ShouldSprint()
{
	if( bCanSprint || (bCanSprintWhenDamaged && MyKFPawn.Health < MyKFPawn.HealthMax) )
	{
		return true;
	}

	return false;
}

/** Overridden to handle fractured mesh actors - setting physics to falling in case
	the Crawler was on a wall */
// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//event bool NotifyBump( Actor Other, vector HitNormal )
//{
//	DisableBump( 0.12f );
//
//	/** If we bumped into a glass window, break it */
//	if( Other.bCanBeDamaged && KFFracturedMeshGlass(Other) != none )
//	{
//		KFFracturedMeshGlass( Other ).BreakOffAllFragments();
//		MyKFPawn.SetPhysics( PHYS_Falling );
//		return false;
//	}
//
//	return Super.NotifyBump( Other, HitNormal );
//}
//
///** Notification from pawn that it has received a BaseChange event */
//function bool NotifyBaseChange( actor NewBase, vector NewFloor )
//{
//	/** If I'm using PHYS_Spider and my floor has changed and is considered 'walkable'... */
//	if( MyKFPawn != none && NewFloor != OldFloor && NewFloor.Z > 0.98f && MyKFPawn.Physics == PHYS_Spider )
//	{
//		Pawn.SetPhysics( PHYS_Walking );
//	}
//
//	return super.NotifyBaseChange( NewBase, NewFloor );
//}
//
///** Set PHYS_Walking just in case, and find a new anchor if I don't already have one */
//event bool NotifyLanded( vector HitNormal, Actor FloorActor )
//{
//	if( HitNormal.Z == 1.f )
//	{
//		Pawn.SetPhysics( PHYS_Walking );
//		if( MyKFPawn.Anchor == none )
//		{
//			SetBestAnchor();
//		}
//	}
//	return super.NotifyLanded( HitNormal, FloorActor );
//}
//
///** Notification that I've run into a wall. If the pawn's bDirectHitWall flag is true, this will be bypassed and
//	the pawn's HitWall() event will be called directly.  */
//event bool NotifyHitWall( vector HitNormal, actor Wall )
//{
//	local AICommand ActiveCommand;
//	local bool bCanBaseOnWall;
//
//	if( KFDoorActor(Wall) != none )
//	{
//		Super.NotifyHitWall(HitNormal, Wall);
//	}
//
//	RecordHitWall( Wall );
//
//	if( Wall.bWorldGeometry && Wall.bCrawlable && Wall != Base ) // 1/8/2014
//	//if( Wall.bWorldGeometry && Wall != Base )
//	{
//		// New as of 1/9/2014
//		ActiveCommand = AICommand( GetActiveCommand() );
//		//if( Physics == PHYS_Falling && (bWallJumping || (ActiveCommand != none && AICommand_Crawler_LeapToWall(ActiveCommand) != none)) )
//		if( Pawn.Physics == PHYS_Falling && ActiveCommand != none && AICommand_Crawler_LeapToWall(ActiveCommand) != none )
//		{
//			bCanBaseOnWall = true;
//		}
//
//		ActiveCommand = AICommand( GetActiveCommand() );
//		if( (Pawn.Physics == PHYS_Walking || bCanBaseOnwall) )
//		{
//			if( (NavigationPoint(MoveTarget) != none && MoveTarget.Base == Wall) )
//			{
//				if( KFPathNode(MoveTarget).GetUpVector() == vect(0,0,0) )
//				{
//					return false;
//				}
//			}
//
//			if( Pawn.Physics != PHYS_Spider )
//			{
//				`AILog_Ext( GetFuncName()$" Wall: "$Wall$" HitNormal: "$HitNormal$" setting phys to spider & base to wall!", 'Crawler', self );
//				Pawn.SetPhysics( PHYS_Spider );
//				Pawn.SetBase( Wall, HitNormal );
//				return false;
//			}
//		}
//	}
//	else if( !Wall.bCrawlable )
//	{
//		`AILog_Ext( self$" Rejecting "$Wall$" because it's not crawlable! "$GetFuncName(), 'Crawler', self );
//	}
//
//	return Super.NotifyHitWall( HitNormal, Wall );
//}
//
///** Find a nearby navigation point that's preferably on a wall and make sure I can see my
//	enemy from its location. Then I'll build a path and move to it and pounce on my enemy
//	from there. */
//function bool FindAmbushNode( optional bool bOnlyWallNodes )
//{
//	// Apply 1000 extra cost to navigation points which aren't on walls.
//	class'Path_PreferWalls'.static.PreferWalls( Pawn, true, 1000 );
//	// The end goal should be on a wall, and I must be able to see my enemy from that location.
//	class'Goal_WallToEnemy'.static.WallToEnemy( Pawn );
//	class'Goal_Null'.static.GoUntilBust( Pawn, 2024 );
//
//	if( FindPathToward( Enemy ) != None )
//	{
//		// Found the ambush node - but don't use it if I'm already on a wall and it's
//		// the same as my LastAmbushNode.
//		if( MyKFPawn.Physics != PHYS_Spider || RouteGoal != LastAmbushNode )
//		{
//			//PauseAndShowMsg( "PATH: "$RouteGoal$" RouteCache Length: "$RouteCache.Length );
//			return true;
//		}
//	}
//	return false;
//}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm P.S. doesn't seem to be called anywhere.
//function bool TestPath()
//{
//	//class'Path_PreferWalls'.static.PreferWalls( Pawn, true );
//	class'Path_PreferWalls'.static.PreferWalls( Pawn );
//	class'Goal_WallToEnemy'.static.WallToEnemy( Pawn );
//	if( FindPathToward( Enemy ) != None )
//	{
//		//PauseAndShowMsg( "PATH: "$RouteGoal$" RouteCache Length: "$RouteCache.Length );
//		return true;
//	}
//	else
//	{
//		return false;
//	}
//}

/**
 * GeneratePathTo()
 * Set up path constraints and attempt to build a path to Goal actor.
 * Overridden for Crawlers to prefer using wall pathnodes when possible.
 *
 * @param	Goal				Goal actor to build path to
 * @param	Distance			Optional offset distance from goal
 * @param	bAllowPartialPath	Allow a partial path to be used if a full path fails to generate
 *
 * @return	Actor				Next navigation point to move to, if a path was generated
 */
// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//event Actor GeneratePathTo( Actor Goal, optional float Distance, optional bool bAllowPartialPath )
//{
//	local actor PathResult;
//
//	AddBasePathConstraints();
//
//	// Build a path toward my goal, applying an extra cost to any non-wallpathnodes evaluated
//	class'Path_TowardGoal'.static.TowardGoal( Pawn, Goal );
//	class'Path_PreferWalls'.static.PreferWalls( Pawn, false, RandRange(MinExtraCostForFloorNodes, MaxExtraCostForFloorNodes) );
//	class'Goal_Null'.static.GoUntilBust( Pawn, 2024 );
//
//	// Attempt to build the path.
//	PathResult = FindPathToward( Goal );
//	Pawn.ClearConstraints();
//
//	if( PathResult == None )
//	{
//		`AILog( GetFuncName()$"() failed to build a path to "$Goal$", offset distance was "$Distance$", bAllowPartialPath was "$bAllowPartialPath, 'PathWarning' );
//	}
//	return PathResult;
//}


/**
 * MayFall() - Called when a pawn is about to fall off a ledge, and allows the controller to prevent a fall by toggling
 * bCanJump. This event is also passed if a floor is found over the edge, and the normal of the floor if so.
 * Called by PhysWalking() and CheckForLedges()
 *
 * @param	bFloor			True if a floor was found below gap
 * @param	FloorNormal		Normal of potential new floor
 */
// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//event MayFall( bool bFloor, vector FloorNormal )
//{
//	// Allow the fall
//	Pawn.bCanJump = true;
//}

/**
 * Overridden to use AICommand_Crawler_MoveToGoal rather than AICommand_MoveToGoal.
 * @param	NewMoveGoal			What I'll be moving toward
 * @param	NewMoveFocus		Optional focus override while moving
 * @param	bInterruptable		Whether or not this move can be interrupted
 * @param	OffsetDist			Optional offset distance from move point
 * @param	bIsValidCache		Whether routecache is currently valid
 * @param	bInCanPathfind		When false, NPC will only move if goal is directly reachable
 * @param	bForce				Forces the move regardless of interruptability
 * @param	bAllowedToAttack	Whether or not NPC is permitted to attack during this move
 * @param	bAllowPartialPath	Whether or not to allow a partial path
 */
// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//event SetMoveGoal( Actor NewMoveGoal, optional Actor NewMoveFocus,
//						optional bool bInterruptable, optional float OffsetDist,
//						optional bool bIsValidCache, optional bool bInCanPathfind = true,
//						optional bool bForce, optional bool bAllowedToAttack=true,
//						optional bool bAllowPartialPath )
//{
//	MoveGoal	= NewMoveGoal;
//	MoveFocus	= NewMoveFocus;
//	MoveOffset	= OffsetDist;
//
//	bMoveGoalInterruptable = bInterruptable;
//	SetBasedPosition( MovePosition, vect(0,0,0) );
//	`AILog( GetFuncName()$"() initializing AICommand_Crawler_MoveToGoal"@NewMoveGoal@NewMoveFocus@bInterruptable@bAllowedToAttack, 'InitAICommand' );
//
//	if( NewMoveGoal != None && (MoveIsInterruptable(bForce) || !bInterruptable) )
//	{
//		class'AICommand_Crawler_MoveToGoal'.static.CrawlerMoveToGoal( self, NewMoveGoal, NewMoveFocus, OffsetDist, bIsValidCache, bInCanPathfind, bAllowedToAttack, bAllowPartialPath );
//	}
//	else if( NewMoveGoal != none )
//	{
//		`AILog( GetFuncName() @"!! -- ignoring movegoal because I already have a moveaction, which is non-interruptable, and the new movegoal IS interruptable.. trumped", 'InitAICommand' );
//	}
//}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//simulated function Tick( float DeltaTime )
//{
//	local vector CeilingTrans;
//
////	if( Role == ROLE_Authority && MyKFPawn != none && MyKFPawn.Health > 0 && !MyKFPawn.IsDoingSpecialMove(SM_Emerge) )
////	{
//		if( Pawn.Floor.Z == -1 )
//		{
//			if( Pawn.Floor.Z == -1 )
//			{
//				CeilingTrans = OriginalMeshTranslation;
//				CeilingTrans.X = -36;
//				Pawn.Mesh.SetTranslation( CeilingTrans );
//			}
//
//		}
//		else
//		{
//			Pawn.Mesh.SetTranslation( vect(-36,0,-36) );
//		}
////	}
//	super.Tick( DeltaTime );
//}

DefaultProperties
{
	// ---------------------------------------------
	// AI / Navigation
 	MeleeCommandClass=class'AICommand_Base_Crawler'
 	DefaultCommandClass=class'AICommand_Base_Crawler'
	MaxFailedToFindAnchorCount=3
	bNotifyFallingHitWall=true
	RotationRate=(Pitch=70000,Yaw=70000,Roll=40000)
    EvadeGrenadeChance=0.5f
	bEvadeOnRunOverWarning=true
	RunOverEvadeDelayScale=0.75f
	// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
	//InUseNodeCostMultiplier=4.f

	MinExtraCostForFloorNodes=14000
	MaxExtraCostForFloorNodes=25000


    // Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
	//WallWalkingPluginClass=none//"KFAiPluginWallWalkingMovement"

	// ---------------------------------------------
	// Combat
 	bIsProbingMeleeRangeEvents=true

	// ---------------------------------------------
	// Danger Evasion Settings
	DangerEvadeSettings.Empty
	DangerEvadeSettings(0)={(ClassName="KFProj_Bullet_Pellet",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(1)={(ClassName="KFProj_Nail_Nailgun",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(2)={(ClassName="KFProj_Bullet_DragonsBreath",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(3)={(ClassName="KFProj_HighExplosive_M79",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(4)={(ClassName="KFProj_HighExplosive_M32",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(5)={(ClassName="KFProj_Rocket_RPG7",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(6)={(ClassName="KFDT_Explosive_M16M203",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(7)={(ClassName="KFDT_Explosive_HRGIncendiaryRifle",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}


	//shooting fire
	DangerEvadeSettings(8)={(ClassName="KFProj_CaulkNBurn_GroundFire",
								Cooldowns=(3.0, 0.3, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 1.0, 1.0, 1.0),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(9)={(ClassName="KFProj_FlameThrower_GroundFire",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 1.0, 1.0, 1.0),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(10)={(ClassName="KFWeap_Flame_CaulkBurn",
								Cooldowns=(3.0, 0.3, 0.1,  0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 1.0, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(11)={(ClassName="KFWeap_Flame_Flamethrower",
								Cooldowns=(3.0, 1.0, 0.1,  0.1), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 1.0, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(12)={(ClassName="KFWeap_Beam_Microwave",
							    Cooldowns=(3.0, 3.0, 2.5,  1.5), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.3, 0.5, 0.8),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}


    //Aimed weapons it dodges //sharpshooter
    DangerEvadeSettings(13)={(ClassName="KFWeap_Bow_Crossbow",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}  
    DangerEvadeSettings(14)={(ClassName="KFWeap_Rifle_M14EBR",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(15)={(ClassName="KFWeap_Rifle_Winchester1894",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(16)={(ClassName="KFWeap_Rifle_RailGun",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}

	//Grenades
	DangerEvadeSettings(17)={(ClassName="KFProj_FragGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(18)={(ClassName="KFProj_MolotovGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(19)={(ClassName="KFProj_DynamiteGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(20)={(ClassName="KFProj_NailBombGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(21)={(ClassName="KFProj_HEGrenade",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(22)={(ClassName="KFProj_HighExplosive_M16M203",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(23)={(ClassName="KFProj_Grenade_HRGIncendiaryRifle",
								Cooldowns=(3.0, 1.0, 0.1, 0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.9, 1.0),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}

	// Flashlight
	DangerEvadeSettings(24)={(ClassName="KFFlashlightAttachment",
								Cooldowns=(3.0, 1.0, 0.75, 0.5), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.5, 0.8, 0.9),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.5), (X=0.0, Y=0.5), (X=0.0, Y=0.5))},
								SoloChanceMultiplier=1.0)}

	// Ground Fire
	DangerEvadeSettings(25)={(ClassName="KFProj_Flame_HRGIncendiaryRifle",
								Cooldowns=(3.0, 0.3, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 1.0, 1.0, 1.0),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
}