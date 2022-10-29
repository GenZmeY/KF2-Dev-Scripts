//=============================================================================
// KFAIController
//=============================================================================
// Base AI Controller for KFMonsterPawns.
// A lot of this should really be in KFAIController_Monster, which hasn't been
// a priority because currently all KFAI pawns are monsters/player enemies.
// TODO: Move zed-specific code down to KFAIController_Monster.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController extends BaseAIController
	native(AI);

`include(KFGame\KFGameAnalytics.uci);

/*********************************************************************************************
* Misc. Defines
********************************************************************************************* */
/** For convenience (LATENT_MOVETOWARD is already defined in Controller.uc) */
const LATENT_MOVETO				= 501;

/*********************************************************************************************
* Misc. Defines
********************************************************************************************* */

/** If true, will call ScriptGetTeamNum() to determine team if there is no PRI for this AI */
var bool bAllowScriptTeamCheck;

/*********************************************************************************************
* Initialization
********************************************************************************************* */
/** Cached copy of gameinfo to avoid casting */
var transient KFGameInfo 		MyKFGameInfo;
/** Cached copy of AI pawn to avoid casting */
var transient KFPawn_Monster	MyKFPawn;
/** GameInfo's current AIManager */
var transient KFAIDirector		MyAIDirector;
/** Steering used to actually move the controlled pawn */
var instanced KFAISteering		Steering;

/** Default Combat Command we should move into when spotting an enemy */
var class<AICommand>	DefaultCommandClass;
/** command we should use when we want to pursue and melee an enemy */
var class<AICommand>	MeleeCommandClass;

/*********************************************************************************************
* Behavior Properties
******************************************************************************************** */
/** (Default behavior) Will send NPC to move to nearest enemy after possession, from ActionIdle startup state */
var bool			bIdleMoveToNearestEnemy;

/*********************************************************************************************
* General Movement
********************************************************************************************* */
/** Intermediate move goal used when pathfinding to MoveGoal */
var Actor			IntermediateMoveGoal;
/** Used in tracking # of times AICommand_MoveToEnemy has failed */
var int				FailedMoveToEnemyCount;
/** Acceptable distance offset from the goal, used by AICommand_MoveToGoal (TODO: Move this into AICommand_MoveToGoal if not
	needed here) */
var float			MoveOffset;
/** Actor to move toward when destination is an actor rather than a vector, used in latent movement (MOVETOWARD)*/
var Actor			MoveGoal;
/** Location to move to when destination is a vector rather than an actor, used in latent movement (MOVETO) */
var BasedPosition	MovePosition;
/** Focus override while performing a move */
var Actor			MoveFocus;
/** Last time we researched for a destination after a delay, used by AICommand_MoveToGoal */
var float			LastDetourCheckTime;
/** Was current MoveGoal successfully reached? */
var bool			bReachedMoveGoal;
/** Forces movement command to build a new path when command resumes, regardless of current routecache */
var bool			bReevaluatePath;
/** TRUE if my pawn is currently moving to its goal (that is, if an AICommand_MoveToGoal is active) */
var bool			bMovingToGoal;
/** TRUE if my pawn is currently moving to its enemy (AICommand_MoveToEnemy is active) */
var bool 			bMovingToEnemy;
/** Currently moving directly to a goal, rather than still on my path */
var bool			bDirectMoveToGoal;
/** Is the current movement goal interruptable? If you need to rely on this, re-confirm that it's working properly (haven't needed this) */
var bool			bMoveGoalInterruptable;
/** AI should not update route cache - flag to prevent cache from being changed when pathing is used to pick locations (flank, hide, etc.) */
var bool			bSkipRouteCacheUpdates;
/** Used by base Zed AICommand and AICommand_MoveToEnemy */
var bool			bFailedToMoveToEnemy;
/** Used with HandlePathObstruction() event (see AICommand_MoveToGoal version, which is a function called by the controller's HPO event) */
var float			LastObstructionTime;
/** Use to track when my pawn last transitioned from walk to sprint (or vice versa) to prevent changing too frequently */
var float			LastSprintChangeTime;
/** Lock the AI to a specific rotation, see KFAIController::UpdatePawnRotation() */
var Rotator			LockedRotation;
/** Cached version of CommandList that's an AICommand (instead of BaseAICommand) */
var AICommand		CachedAICommandList;
/** Currently not turned, going to be deprecated */
var transient bool	bAvoidChokePoints;
/** Used in determining how often (when moving along a path) to check if my goal is now directly reachable */
var transient float	NextDirectPathCheckTime;
var float			DirectPathCheckFrequency_Min;
var float			DirectPathCheckFrequency_Max;
/** Used by AKFAIController::DirectPathToGoal */
var float			DirectPathExtentModifier;
/** Should sprint if enemy distance is > X and < Y - older, might be able to get rid of this */
var	Vector2D		SprintWithinEnemyRange;
/** Modifier to rotation rate whenever not already modified by a special move */
var float			RotationRateMultiplier;
/** Current closed door that I'm for (assuming bPreparingMove is true to delay any latent move) */
var KFDoorActor		PendingDoor;
/** If true, this pawn will receuve NotifyOnAddToRouteCache() events for any NavigationPoints with bNotifyOnAddToRouteCache=true when they
	are added to a path I'm building */
var bool			bProbeNotifyOnAddToRouteCache;
/** Set to true by KFJumpSpot, used in MayFall() event but might be able to get rid of this, it's old */
var bool			bPlannedJump;
/** Used by direct reachability checking code while NPC is pathfinding, Used by AKFAIController::HasDirectPathToGoal */
var float			LastLOSCheckTime;
/** Used by direct reachability if MinTimeBetweenLOSChecks seconds have yet to pass  */
var bool			CachedLOSCheck;
/** Minimum time that must pass between checking direct reachability to goal */
var float			MinTimeBetweenLOSChecks;
/** Used when failing a move in AICommand_MoveToGoal... testing */
var KFPathnode		BlockedPath; // 2.21.2014
var bool			bIgnoreBlockedPathList;
var float			MaxBlockedPathDuration;
/** Turns PathLane code on/off (see ShouldUsePathlanes()) */
var bool		    bShouldUsePathLanes;
/** Turns corner cutting on off (see ShouldOffsetCorners()) */
var bool		    bShouldOffsetCorners;
/** If this is on, NPC will always be willing to accept partial paths when using movement AICommands */
var bool		bAlwaysAcceptPartialPaths;

/** This monster has the capability to sprint in general */
var				bool	bCanSprint;
/** This monster has the capability to sprint when damaged */
var				bool	bCanSprintWhenDamaged;
/** This monster's ability to sprint is currently disabled */
var             bool    bSprintingDisabled;

var config Color PathNodeShowRouteCacheColor;
var config vector PathNodeShowRouteCacheCrossOffset;
var config float PathNodeShowRouteCacheCrossSize;
var config vector PathNodeShowRouteCacheNumberLabelOffset;
var config float PathNodeShowRouteCacheNumberLabelDuration;

// ----------------------------------------------------------------------- //
// DEPRECATED KF Cached version of movement Plugins
// ----------------------------------------------------------------------- //
var AIPluginMovement 	KfMovementPlugin;
var AIPluginLeap 		KfLeapPlugin;
var AIPluginStuckFix	KfStuckFixPlugin;

//var class<AIPluginMovement> WallWalkingPluginClass;
var AIPluginMovement KfWallWalkingPlugIn;

//var bool bGoToEnemiesOutsideNavmesh;
//var Actor ActorFindingNavMeshPointCloseToo;
//var KFNavigationHandle MyKFNavigationHandle;

var MOVEMENT_PHASE_TYPE CurrentMovementPhase;


// failure

var config Color Move_failure_type_none_color;
var config Color Move_failure_type_no_nav_mesh_path_color;
var config Color Move_failure_type_same_intermediate_point_too_many_times_color;
var config Color MoveFailureTypeTargetOffNavMeshAndCanNotFindLocaitonNearThemICanMoveTo;

var float DefaultMaxTimeAllowedToStayStuckBeforeSuicide;
var float NoNavMeshPathMaxTimeAllowedToStayStuckBeforeSuicide;
var float SameIntermediatePointToManyTimesMaxTimeAllowedToStayStuckBeforeSuicide;
var float TargetOffNavMeshAndCanNotFindLocaitonNearThemICanMoveTooMaxTimeAllowedToStayStuckBeforeSuicide;

var float SameIntermediatePointToManyTimesDurationAfterStartedMovingAgaintToStopStuckCheck;

var float DefaultMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide;
var float NoNavMeshPathMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide;
var float SameIntermediatePointToManyTimesMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide;


var MOVE_FAILURE_TYPE TypeOfMovementStuckOn;

// Pathnode icons
var Texture2D MovementPhaseTypePathNodeNormalMoveToIcon;
var Texture2D MovementPhaseTypePathNodeMoveFailedIcon;
var Texture2D MovementPhaseTypePathNodeMoveToPointIcon;
var Texture2D MovementPhaseTypePathNodeRotateToFocusIcon;
var Texture2D MovementPhaseTypePathNodeDelayMoveIcon;
// end Pathnode icons

var Texture2D MovementPhaseTypeUnknownIcon;
var Texture2D MovementPhaseTypeNavMeshNormalMoveToIcon;
var Texture2D MovementPhaseTypeFinalDestMoveTowardsIcon;
var Texture2D MovementPhaseTypeEMT_LOS_MoveTowardsIcon;
var Texture2D MovementPhaseTypeMovingToNavMeshUsingPathNodesIcon;
var Texture2D MovementPhaseTypeFALLBACK_REFUSED_TO_BE_EXPLOTIED_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POSIcon;
var Texture2D MovementPhaseTypeFALLBACK_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POSIcon;

var Texture2D TypeOfMovementStuckOnUnknownWhyIcon;
var Texture2D TypeOfMovementStuckOnMOVE_FAILURE_TYPE_NO_NAV_MESH_PATHIcon;
var Texture2D TypeOfMovementStuckOnMOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMESIcon;
var Texture2D TypeOfMovementStuckOnMOVE_FAILURE_TYPE_TARGET_OFF_NAV_MESH_AND_CAN_NOT_FIND_LOCAITON_NEAR_THEM_I_CAN_MOVE_TOIcon;
var Texture2D TypeOfMovementStuckOnLookingForBetterIntermediateLoc;
var Texture2D TypeOfMovementStuckOnMoveToBetterIntermediate;

var config bool bConfigShowMovePointsDebugInfo;
var bool bShowMovePointsDebugInfo;

var config bool bConfigShowHighDetailCombatMovementDebugInfo;
var bool bShowHighDetailCombatMovementDebugInfo;

var config bool bConfigShowVisualStuckZedDebugInfo;
var bool bShowVisualStuckZedDebugInfo;

var config color	ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOff;
var config color	ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOn;

var config bool bConfigShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState;
var bool bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState;

/** how far away to look for position on the nav mesh when I end up off the nav mesh, first try */
var float	DistanceToCheckForClearPathOnNavMeshLocWhenOffNavMesh;
/** how far away to look for position on the nav mesh when I end up off the nav mesh, 2nd try */
var float	DistanceToCheckForNonExploitedOnNavMeshLocWhenOffNavMesh;
/** how far away to look for position on the nav mesh when I end up on a dead end of the nav mesh */
var float	DistanceToCheckForNonExploitedOnNavMeshLocWhenOnDeadEndOfNavMesh;

var config color	DefaultColorOfValidLocationWhenLookingForLocationsOnNavMesh;
var config color	DefaultColorOfSearchSphereWhenNoValidLocationsFoundWhenLookingForLocationsOnNavMesh;

var config color	ColorOfValidLocationFoundFor1stTryLookingForLocationsOnNavMesh;
var config color	ColorOfSearchSphereWhenNoValidLocationsFoundFor1stTryLookingForLocationsOnNavMesh;
var config color	ColorOfValidLocationFoundFor2ndTryLookingForLocationsOnNavMesh;
var config color	ColorOfSearchSphereWhenNoValidLocationsFoundFor2ndTryLookingForLocationsOnNavMesh;

var config color	ColorOfValidLocationFoundFor3rdTryLookingForLocationsOnNavMesh;
var config color	ColorOfSearchSphereWhenNoValidLocationsFoundFor3rdTryLookingForLocationsOnNavMesh;

var config color	ColorOfValidLocationFoundForLookingForLocationsOnNavMeshWhenOnDeadEndOfNavMesh;
var config color	ColorOfSearchSphereWhenNoValidLocationsFoundForTryLookingForLocationsOnNavMeshWhenOnDeadEndOfNavMesh;


/** how far away to look for position on the nav mesh when my enemy ends up off the nav mesh, first try */
var float	DistanceToCheckForClearPathOnNavMeshLocWhenEnemyIsOffNavMesh;
/** how far away to look for position on the nav mesh when my enemy ends up off the nav mesh, 2nd try */
var float	DistanceToCheckForNonExploitedOnNavMeshLocWhenEnemyIsOffNavMesh;

/** How far away can the door be from the closest nav loc so that I can reach it */
var float	GeneralGoalDistanceForMovingToDoor;

/** If the enemy moves more than this distance away from where it was when we pathed, repath */
var float	RecastEnemyRepathDistance;

/** DropEdgeLeapVelocity */
var Vector	DropEdgeLeapVelocity;

/** MaxRangeToDropEdgeAllowedToLeadFrom */
var float	MaxRangeToDropEdgeAllowedToLeadFrom;

/** DistanceDownRangeToFocusForDropEdgeLeap */
var float    DistanceDownRangeToFocusForDropEdgeLeap;

var bool            bShowLeapDownDebugArtifacts;
var config bool     bConfigShowLeapDownDebugArtifacts;
var bool            bShowDoorNavigationDebugArtifacts;
var config bool     bConfigShowDoorNavigationDebugArtifacts;
var bool            bShowDestructibleNavigationDebugArtifacts;
var config bool     bConfigShowDestructibleNavigationDebugArtifacts;
var config float    TimeToShowEdgeTypeForNavMeshPathting;

/** determiner whether given AI actor respects numerous leader person/distance restrictions */
var bool bMindLeader;
var vector LastLeaderPosOffset;

/*********************************************************************************************
* Tracking obstructions via NotifyHitWall
**********************************************************************************************/
var float	        LastNotifyHitWallTime;
var actor	        LastHitWall;
var vector          LastWallHitNormal;
var int             HitWallCount;
var bool			LastPathFailTime;

struct native sBlockedPathInfo
{
	var	ReachSpec		BlockedReachSpec;
	var int				BlockedCost;	// 0 = Completely blocked
	var float			BlockedTime;
};
var array<sBlockedPathInfo>	BlockedPathList;

// Is the AI locked to a specific rotation
var bool IsRotationLocked;
/** My pawn was spawned from an emerge portal, set to false by AICommandMove or first time UpdateRotation
	is called in PHYS_Spider */
var bool bSpawnedByEmergeSpecialMove;
/** Will call TargetedByPlayer event if true when calling AKFAIController::IsTargetedByPlayer() */
var bool bUseTargetedByPlayerEvent;

/*********************************************************************************************
* Bump testing - only in use if bSpecialBumpHandling is true (see BumperSomewhereToGo, Tick)
********************************************************************************************* */
var	bool            bBumpedThisFrame;
var KFPawn          LastBumper;
var		   float    CurBumpVal;
var		   float    BumpThreshold;
var		   float    BumpDecayRate;
var		   float    BumpGrowthRate;
var config bool	    bDoNotBlockFriendlyAI;
var config bool	    bSuperSpeedDoNotBlockFriendlyAI;
var bool	        bSpecialBumpHandling;

/*********************************************************************************************
* Stuck checking
**********************************************************************************************/

/** This last time this AI checked to see if it was stuck */
var                     float       LastStuckCheckTime;
/** How much time we've spent within close range to the player */
var 					float 		TotalStuckCheckCloseRangeTime;
/** The last time we checked and found that we were within close range to the player */
var 					float 		LastStuckCheckCloseRangeTime;
/** How often to check and see if this AI is stuck */
var(StuckChecking)      float       StuckCheckInterval;
/** How slow a zed needs to be moving (squared) in the X/Y access to be considered possibly stuck */
var(StuckChecking)      float       StuckVelocityThreshholdSquared;

/** How stuck this zed thinks it might be */
var                     float       StuckPossiblity;
/** The threshold to actually consider this zed stuck when it thinks it might be */
var(StuckChecking)      float       StuckPossiblityThreshhold;

/** The zed thinks it is stuck and is trying to get unstuck */
var                     bool        bTryingToGetUnstuck;
/** The time at which this AI started thinking it was stuck */
var                     float       LastStuckTime;

/** Is this AI allowed to teleport to move closer? */
var 					bool 		bCanTeleportCloser;
/** The minimum number of zeds remaining before teleportation is disabled for this zed */
var(Teleport)           byte 	    AIRemainingTeleportThreshold;
/** The last time this AI checked to see if it can teleport closer to it's enemy */
var                     float       LastTeleportCheckTime;
/** The last time this AI teleported either because it was stuck or relocated */
var                     float       LastTeleportTime;
/** How often to check and see if this AI can relocate teleport*/
var(Teleport)           float       TeleportCheckInterval;
/** How long to wait after teleporting to be able to teleport again*/
var(Teleport)           float       TeleportCooldown;
/** How long this zed must be hidden before it can relocate teleport. Must be at least 5, because hidden checks can be delayed as much as 5 seconds*/
var(Teleport)           float       HiddenRelocateTeleportThreshold;
/** How long this zed must ahve been alive before it can relocate teleport. */
var(Teleport)           float       PostSpawnRelocateTeleportCooldown;
/** The last location this zed teleported from */
var                     vector      LastTeleportLocation;

/** This last time this AI finished a special move */
var                     float       LastSpecialMoveEndTime;

/** Where this AI was the last time we did a stuck check */
var                     vector      LastStuckCheckLocation;

/** How far this AI should have moved in 2d space since last check to not be considered stuck */
var                     float       XYMoveStuckThresholdSquared;
/** How far this AI should have moved in Z space since last check to not be considered stuck */
var                     float       ZMoveStuckThresholdSquared;

/** If I am closer than this distance to my enemy, then don't do any special stuck checking/handling */
var                     float       StuckCheckEnemyDistThreshholdSquared;
/** If I am closer than this distance to my enemy, then don't reduce collision size with other zeds */
var                     float       NavigationBumpTeamCollisionThreshholdSquared;

/** How long we've been falling with no z velocity */
var                     float       FallingStuckNoZVelocityTime;
/** Number of times a walk move has failed to apply velocity while Pawn->Acceleration is nonzero */
var 					int 		NumFailedLatentWalkMoves;


/*********************************************************************************************
* StepAside
********************************************************************************************* */
/** Current step aside goal, for StepAside state */
var Pawn		StepAsideGoal;
/** Distance to attempt to step aside when bumping into other players */
var float		MaxStepAsideDist;
/** should we ignore stepasidefor calls? **/
var bool		bIgnoreStepAside;
var float		LastFailedToFindStepAsideLocation;
/** last pawn we bumped */
var Pawn		LastBumpedPawn;
/** last time we bumped someone */
var float		LastBumpTime;

/*********************************************************************************************
 Combat
 ********************************************************************************************* */
/** The range a zed needs to be from a player to begin considering his attack, also this is the MAX range I will ever be able to do a strike, any strike at, if I can not get this close I am SOL */
var float 		AttackRange;
/** The next melee attack index we will attempt */
var byte 		PendingAnimStrikeIndex;
 /** The range a zed needs to be from a player to perform a melee attack */
var float 		StrikeRange;
/** Used to get the StrikeRange as a value between the min and max PawnAnimInfoGroup's attacks */
var float StrikeRangePercentage;
/** Used to get the StrikeRange as a value between the min and max PawnAnimInfoGroup's attacks */
var bool		bCanStrikeThroughEnemies;
/** Used by KFPawnAnimInfo to determine if an attack can be performed if legs are blocked (lunges, etc) */
var bool 		bIsBodyBlocked;
/** Desired melee distance when attacking a door */
var float		DoorMeleeDistance;
/** Max height offset (normalized degrees) that zed is able to attack in melee from */
var float 		MaxMeleeHeightAngle;
/** Last time a melee attack was performed */
var float		LastAttackTime_Melee;

/** Last time a we have taken damage */
var float		LastDamageTime_Taken;

/** Last time a melee attack decision was evaluated */
var float		LastMeleeAttackDecisionTime;
/** Last time an enemy was selected using SelectEnemy() */
var float		LastSelectEnemyTime;
/** Last time an enemy was set using SelectEnemy() */
var float		LastSetEnemyTime;
var float       MinTimeBetweenStatusUpdates;
var float       MaxTimeBetweenStatusUPdates;
/** Last time a latent move completed */
var float		LastMoveFinishTime;
/** Used to prevent changing my enemy too frequently (see SetEnemy()) */
var float		MinTimeBetweenEnemyChanges;
/** Last time we collided with a destructible */
var float 		LastDestructibleBumpTime;
/** Enemies are pawns - use this for temporary actor enemies (like destructibles that need to be melee-attacked) */
var Actor		ActorEnemy;
/** Set when attacking a welded door */
var KFDoorActor DoorEnemy;
/** Current melee target, if any - stored here for separation steering.. don't want a Zed to be pushed away from his melee target. */
var KFPawn		MeleeTarget;
/** Result of last enemy LineOfSightTo() check */
var	bool		bEnemyIsVisible;
/** Result of last call to SeePlayer */
var transient bool bIsVisibleToEnemy;
/** Result of previous call to SeePlayer */
var transient bool bWasVisibleToEnemy;
/** When last enemy LineOfSightTo() check was done */
var	float		EnemyVisibilityTime;
/** The last time an enemy switch occurred (only set if enemy was set to a new enemy) */
var float 		LastEnemySwitchTime;
/** Who the enemy was for the last LineOfSightTo() check */
var	Pawn		CachedVisibleEnemy;
/** Incoming projectile that I should evade away from (see ReceiveProjectileWarning()) */
var Projectile	PendingEvadeProjectile;
/** The chance that this zed has to dodge an incoming grenade */
var float 		EvadeGrenadeChance;
/** If true, will continually rotate to enemy during non-rootmotion melee attacks */
var bool		bUseDesiredRotationForMelee;
/** The last time we tried to get a new move */
var float		LastGetStrikeTime;
/** How long we need to wait before picking another move */
var const float MaxGetStrikeTime;
/** The movement system has done its best to get me to my enemy but can not get me any closer, the attack behavior needs to come up with something */
var bool bIamAsClosesToTheEnemyAsICanGet;

/** Force frustration on, regardless of frustration threshold settings */
var(Frustration) bool bForceFrustration;
/** The minimum number of zeds remaining before frustration mode (sprint) is activated */
var(Frustration) byte 	FrustrationThreshold;
/** The amount of time to delay zeds from entering frustration mode after it's first detected */
var(Frustration) float 	FrustrationDelay;
var float 				LastFrustrationCheckTime;
/** Cached default to workaround an issue with frustration reset */
var transient bool 		bDefaultCanSprint;

var float GoalDistanceWhenMovingToLocationForMeleeStrikeWhenEnemyIsOffNavMesh;

struct native CooldownData
{
	var() name		Tag;
	var() float		ActivationTime;
	var() float		Duration;
};

/** List of active attack cooldown timers */
var array<CooldownData> CooldownTimers;

/** Store info for an overall attack cooldown timer so we can throttle all attacks by this zed in certain circumstances */
var() CooldownData      OverallAttackCooldownTimer;

/** Attack cooldown time to use when throttling all attacks by this zed in certain circumstances */
var() float             LowIntensityAttackCooldown;

//var KFAiBallisticProjectileFireBehavior BallisticProjectileFireBehavior;
var KFAiDirectProjectileFireBehavior DirectProjectileFireBehavior;
var KFAiLeapBehavior LeapBehavior;

//var KFAiDestructibleInterActionBehavior DestructibleInterActionBehavior;

var const vector BaseShapeOfProjectileForCalc;

/** The last time this AI did an AICommand_ShootBase attack. See AICommand_ShootBase for notes on why this was brought over here - Ramm */
var float LastShotTime;

/** Set to true if we want to knockdown and possibly obliterate other zeds on bump */
var const bool			bCanDoHeavyBump;
/** The threshold of life to consider doing a special bump effect (ex. enraged or knockdown) */
var const int			ZedBumpEffectThreshold;

/** The chance of obliterating a zed on an enraged bump */
var const float			ZedBumpObliterationEffectChance;

// Only enabled while we didn't receive damage and we use Aggro for choosing Enemy
var bool CanForceEnemy;
var Pawn ForcedEnemy;
var Pawn LastForcedEnemy;
var float ForcedEnemyLastTime;
var float DamageRatioToChangeForcedEnemy;
var float TimeCanRestartForcedEnemy;
var float TimeCannotChangeFromForcedEnemy;

/*********************************************************************************************
 Evasion / Blocking
 ********************************************************************************************* */

/** Struct containing info for forced evade directions and their chance of being selected  */
struct native sForcedEvadeChanceInfo
{
	/** Forward-Left */
	var float FL;

	/** Forward-Right */
	var float FR;
};

/** Struct containing information for AI to evade danger */
struct native sDangerEvadeInfo
{
	/** Projectile class to check against */
	var name ClassName;

	/** Cooldown period, per-difficulty. Difficulty ranges are 0 to 3, Normal-Hard-Suicidal-HoE */
	var array<float> Cooldowns;

	/** Maximum evade chance, per-difficulty */
	var array<float> EvadeChances;

	/** Forced evade chances per difficulty */
	var array<sForcedEvadeChanceInfo> ForcedEvadeChances;

	/** Minimum and maximum delay before AI reacts to a projectile of this type */
	var array<vector2d> ReactionDelayRanges;

	/** Chances to block instead of evade */
	var array<float> BlockChances;

	/** How much to multiply the chance by when in a solo game */
	var float SoloChanceMultiplier;

	/** Last time a projectile of this type was evaded */
	var transient float LastEvadeTime;
};

/** Struct containing information for AI to evade on damage */
struct native sEvadeOnDamageInfo
{
	var float Chance;
	var float DamagedHealthPctToTrigger;
	var sForcedEvadeChanceInfo ForcedEvadeChance;

	structdefaultproperties
	{
		Chance=0.f
	}
};

/** Settings used for danger evasion, set on a per-projectile or per-weapon basis */
var protected array<sDangerEvadeInfo> DangerEvadeSettings;

/** What percentage of max health AccumulatedEvadeDamage needs to reach before an evade is triggered */
var transient sEvadeOnDamageInfo EvadeOnDamageSettings;

/** How much damage we've accumulated towards our next evade trigger */
var transient protected int AccumulatedEvadeDamage;

/** How much damage we've accumulated towards our next block trigger */
var transient protected int AccumulatedBlockDamage;

/*********************************************************************************************
 Aggro
 ********************************************************************************************* */
struct native sFriendlyDamageInfo
{
	var Controller DamagerController;
	var int Damage;
};

/** Array containing all friendly AI that have damaged us */
var array<sFriendlyDamageInfo> FriendlyDamageHistory;

var byte CurrentEnemysHistoryIndex;
/** The percentage of damage that needs to be dealt to a zed to make this controller consider attacking the player */
var const float AggroPlayerHealthPercentage;
/** The time it will take before we will reset our damage history from an attacking player */
var const float AggroPlayerResetTime;
/** The time it will take before we will reset our damage history from another zed */
var float		MinDistanceToAggroZed;
/** The time it will take before we will reset our damage history from another zed */
var const float AggroZedResetTime;
/** The percentage of damage that needs to be taken from another zed to make this controller consider attacking him */
var const float AggroZedHealthPercentage;
/** How long to wait between aggro switches */
var const float AggroEnemySwitchWaitTime;

/*********************************************************************************************
 AI Commands
 ********************************************************************************************* */
/** Allow/Disallow combat transitions (see CheckCombatTransition()) */
var bool	bAllowCombatTransitions;
/** If true, NPC is polling range to enemy, used in TickMeleeCombatDecision() */
var bool	bIsProbingMeleeRangeEvents;
/** Last time this NPC performed a taunt */
var float	LastTauntTime;
/** The time until we can perform another walking taunt */
var float	RepeatWalkingTauntTime;

var float NextTauntTime;
var float NextRandomTauntTime;

var config float TauntTeamFactor;
var config Vector2D TauntTimeDelay;
var config Vector2D RandomTauntTimeDelay;

struct native InvalidAnchorItem
{
	/** Anchor that was invalid */
	var()	NavigationPoint InvalidNav;
	/** Time of path search that invalidated the anchor */
	var()	float			InvalidTime;
};
var transient array<InvalidAnchorItem>	InvalidAnchorList;

/*********************************************************************************************
 * @name	GameConductor balance values
**********************************************************************************************/

/** Tracks the time that this controller first saw an enemy player */
var float	TimeFirstSawPlayer;

/*********************************************************************************************
* Debugging Related
********************************************************************************************* */
var Vector			ChargeLocation;
/** String displayed with KFSceneCaptureDebugCam */
var string			RecentActionInfo;
/** Render AI debug info to screen */
var bool			bDebug_DrawAIDebug;
/** Draw line to Pawn's anchor when true */
var config bool		bDebug_DrawAnchor;
/** Draws sphere around Pawn when bPreparingMove is true */
var config bool		bDebug_ShowPreparingMove;
/** Draws the ranges for pending and current melee attacks  */
var config bool		bDebug_ShowStrikeRange;
/** Draws the ranges for all melee attacks  */
var config bool		bDebug_ShowAllStrikeRange;
/** Log AI_Log events to AIProfiler */
var config bool		bDebug_LogToProfiler;
/** Render line to intermediate goal and one to end-goal during MoveToward calls */
var config bool		bDebug_DrawPath;
/** Render overhead debug text */
var config bool		bDebug_DrawOverheadInfo;
/** Used for debugging StepAside command */
var Rotator			Debug_StepRot;
/** Used for debugging StepAside command */
var BasedPosition	Debug_StepLoc;
/** If true, AILog will use a unique log file for each NPC rather than dumping everything in Launch.log */
var config bool		bUseUniqueAILogFile;
/** Allows postrendering of AI debug info */
var config bool		bDebug_PostRenderInfo;
/** Renders Separation steering force between NPCs if enabled */
var config bool		bDebug_DrawSeparationSteering;
/** If true, NPC is in debug mode (AICommand_Debug is active command) */
var bool			bHasDebugCommand;
/** Used internally, set by KFAIDirector on possess if KFAIDirector.bDebugAllAI is true */
var bool			bForceDebugCommand;
/** Renders attack anim info if true */
var config bool		bDebug_DrawAttackAnimInfo;
/** Draw viewcone (used in seeplayer) */
var config bool		bDebug_ShowViewCone;
var KFPawn			ChargeTarget;
var string			AIActionStatus;
var config color	Debug_TextColorOverride;
var array<name>		EnabledDebugTextCategories;
/** Used for tracking down Zeds who might get stuck when spawning from certain volumes */
var KFSpawnVolume	MySpawnVolume;
var bool			bDisablePartialPaths;
/** The melee attack index we are currently doing ONLY USED FOR DEBUGGING */
var byte 			DebugCurrentStrikeIndex;
/** If set to true, this AI is considered a player by KFAISpawnManager_Versus */
var bool 			bIsSimulatedPlayerController;

var Vector              LocationAtStartOfStuckCheck;
var Vector              LocationAtLastStuckCheck;
var AICommand           CmdTriggeringHardCoreStuckChecking;
var AITickablePlugin    PlugInTriggeringTriggeringHardCoreStuckChecking;

/*********************************************************************************************
* AICommand History Debugging - useful in tracking down command related bugs. Enable through
* config file and each NPC will dump its history of AICommands and related info. If enabled,
* history will be output when this controller is destroyed, the pawn dies, or optionally only
* when exiting the game.
********************************************************************************************* */
/** Used when dumping all NPC AICommand history to log file */
var config bool	bDebugCommandHistory;
/** When true, each NPCs AICommand history is dumped to log file when exiting game */
var bool    	bDumpCommandHistoryOnExit;
/** True if my AICommand history was already dumped to the log file */
var bool		bDumpedCommandHistory;

/** Used with DumpCommandHistory(), contains info about each AICommand instance executed (see bDebugCommandHistory) */
struct native KFAICmdHistoryItem
{
	var class<AICommandBase>	CmdClass;
	var string				    CmdName;
	var float				    TimeStamp;		// World time command was started
	var float				    Duration;		// Total time spent in the command
	var bool				    bAborted;		// Command was aborted (which is often fine and intentional depending on the context) (TODO:Change to bytes)
	var bool				    bFailure;		// Command failed (this is also not necessarily bad, at times it's expected)
	var bool				    bSuccess;		// Command succeeded
	var string				    VerboseString;	// Optional extra info that can be added
};
var array<KFAICmdHistoryItem>	KFAICommandHistory;

cpptext
{
	virtual void    Initialize();
	virtual void	JumpOverWall(FVector WallNormal, AActor* Wall);
	virtual void	StoreCommandHistory( UGameAICommand* Cmd );
	virtual UReachSpec* PrepareForMove( ANavigationPoint *NavGoal, UReachSpec* Path );
	virtual DWORD	LineOfSightTo( const AActor* Other, INT bUseLOSFlag=0, const FVector* chkLocation = NULL, UBOOL bTryAlternateTargetLoc = FALSE );
	virtual UBOOL	AirControlFromWall( float DeltaTime, FVector& RealAcceleration );
	virtual FVector	DesiredDirection();
	virtual void	BeginDestroy();
	virtual UBOOL	Tick( FLOAT DeltaTime, enum ELevelTick TickType );
	virtual UBOOL	TickMeleeCombatDecision( FLOAT DeltaTime ) { return FALSE; }
	virtual UBOOL	ShouldOffsetCorners();
	virtual UBOOL	ShouldUsePathLanes();
	virtual UBOOL	ForceReached( ANavigationPoint *Nav, const FVector& TestPosition );
	virtual void	UpdatePawnRotation();
 	virtual void	UpdateLatentMoveDestination();
 	virtual void	AdjustFromWall( FVector Hitnormal, AActor* HitActor );
	virtual void	RouteCache_Empty();
	virtual void	RouteCache_AddItem( ANavigationPoint* Nav );
	virtual void	RouteCache_InsertItem( ANavigationPoint* Nav, INT Idx );
	virtual void	RouteCache_RemoveItem( ANavigationPoint* Nav );
	virtual void	RouteCache_RemoveIndex( INT Index, INT Count );
	virtual void	StoreKFAICommandHistory( UGameAICommand* Cmd );
	virtual UBOOL	DirectPathToGoal( FVector TargetLoc, FLOAT TargetGroundOffset, FCheckResult &HitList, FVector FromLocation = FVector(0,0,0), UBOOL bCheckActors=true );
	virtual UBOOL	ShouldIgnoreNavigationBlockingFor( const AActor* Other );
	virtual FRotator SetRotationRate( FLOAT deltaTime );
	virtual INT		ControllerModifyCostForReachSpec( UReachSpec* Spec, INT Cost );
	virtual void 	PostPhysWalking(FLOAT DeltaTime);
	virtual void 	MoveToward(AActor* goal, AActor* viewfocus, FLOAT DesiredOffset, UBOOL bStrafe, UBOOL bShouldWalk);

	// Debugging
#if __TW_AIDEBUGGING_
	virtual void FailMove( const FString& Reason );
#endif
}

/*********************************************************************************************
* General native function declarations
********************************************************************************************* */
/** Experimental - if repeatedly bumped by a moving Zed in a very short timespan, this will temporarily
	turn off the collision for the bumped-into Zed to let the moving Zed pass through. GOW has similar
	code to let players pass through blocking friendly NPC teammates. */
native function bool BumperSomewhereToGo();
native function bool LineBlockedByActor( vector Start, vector End, ReachSpec Spec, actor Actor );
native function bool IsPawnBlockingLine( vector Start, vector End, optional float MinCollisionHeight );
//native function bool CanJumpTo( Actor JumpToActor );
native function vector ComputeTrajectoryByTime( vector StartPosition, vector EndPosition, float EndTime );

native function CleanUp(optional bool bBeingDestroyed);

/** Aborts a command and any children if it has any. */
native function bool AbortCommand( GameAICommand AbortCmd, optional class<GameAICommand> AbortClass );
/** Push a new command on to the stack */
native function PushCommand(GameAICommand NewCommand);
/** Pop a command from the stack */
native function PopCommand(GameAICommand ToBePoppedCommand);
/** AI should ignore notifications that would alter behavior - ie. seeing/hearing enemies, getting shot, etc */
native function bool IgnoreNotifies() const;
/** Returns true if CheckPawn is currently moving away from my pawn, optionally at MinSpeed */
native function bool IsPawnMovingAwayFromMe( Pawn CheckPawn, optional float MinSpeed );
/** Returns a KFPawn if there is one blocking the path to EnemyPawn */
native function Pawn GetPawnBlockingPathTo( Pawn EnemyPawn, optional bool bTestTeam, optional bool bCheckVisible );
/** Lock the AI pawn rotation to a specific rotation, to unlock the pawn pass in zero */
native function LockPawnRotationTo( Rotator NewRotation );
/** Unlock the AI pawn's rotation */
native function UnlockPawnRotation();
/** Checks to see if our line of fire is blocked by friendlies. Return True if it is blocked */
final native function bool IsFriendlyBlockingFireLine( vector FireStart );
/** Used for leading Zed's target */
native function vector CalcAimLocToHit( vector AimSpot, vector StartFireLoc, float inSpeed, float inMaxSpeed, optional Vector LeadTargetVelocity );
/** Used for leading Zed's target */
static native function float EstimateProjectileTimeToTarget( float Distance, float StartSpeed, float MaxSpeed );
static native function bool FastActorTrace( Actor OriginTestActor, vector TraceEnd, optional vector TraceStart, optional vector BoxExtent, optional bool bTraceComplex );
static native function Actor ActorBlockTest( Actor OriginTestActor, vector TraceEnd, optional vector TraceStart, optional vector BoxExtent, optional bool bTraceActors, optional bool bTraceComplex );
native function bool TestTrace( vector TraceEnd, optional vector TraceStart );
native function bool IsPawnInFireLine( Pawn CheckPawn, vector FireStart, vector FireLine );
native final function bool SuggestNewWanderPoint( out vector out_NewMovePt, vector TryThisDirFirst, optional float MoveDist = 1024.f );

/** Queries the PRI and returns our current team index */
simulated native function byte GetTeamNum();
protected native function bool IsLookingAtWall( optional float CheckDist=768.f );

/*********************************************************************************************
* Initializtion, Pawn Possession, and Destruction
********************************************************************************************* */

/*---------------------------------------------------------
  Native Init/Destroy related function declarations
---------------------------------------------------------*/

/** Clean up all the subobjects for the controller */
native function CleanUpOnDestroy();

/** TODO: Make this a native function */
event SetChargeLocation( Actor Victim, Vector VictimLocation );

/** This might be useful if you want a Zed to be notified when the player is aiming at it. If
	bUseTargetedByPlayerEvent is true for this KFAIC, when you call IsTargetedByPlayer(), this
	event will be called. */
event TargetedByPlayer( KFPawn InPlayer );

event PostBeginPlay()
{
	Super.PostBeginPlay();

	//BallisticProjectileFireBehavior = new(self) class'KFAiBallisticProjectileFireBehavior';
	//BallisticProjectileFireBehavior.MyAiCtrl = self;

	DirectProjectileFireBehavior = new(self) class'KFAiDirectProjectileFireBehavior';
	DirectProjectileFireBehavior.MyAiCtrl = self;

	LeapBehavior = new(self) class'KFAiLeapBehavior';
	LeapBehavior.MyAiCtrl = self;

	//DestructibleInterActionBehavior = new(self) class'KFAiDestructibleInterActionBehavior';
	//DestructibleInterActionBehavior.MyAiCtrl = self;

	bIamAsClosesToTheEnemyAsICanGet = false;

	//BallisticProjectileFireBehavior.SetUp();
	DirectProjectileFireBehavior.SetUp();
	LeapBehavior.SetUp();

	// Set our frustration delay
	FrustrationDelay = RandRange(default.FrustrationDelay, default.FrustrationDelay*2); //+ Rand(3) + (2.0*fRand());

    //Set initial value so things spawning dependent on this have a safe starting point
    LastEnemySightedTime = WorldInfo.TimeSeconds;
}

/** Called when this controller has possessed inPawn */
event Possess( Pawn inPawn, bool bVehicleTransition )
{
	local KFAIDirector Director;

	`AILog( GetFuncName()$"() possessing pawn "$inPawn, 'AIController' );

	super.Possess( inPawn, bVehicleTransition );

	// Currently only enabling SeePlayer during latent moves in AICommand_MoveToGoal
	Disable( 'SeePlayer' );
	if( Steering != none )
	{
		InitSteering();
	}
	Pawn.bCanJump = true;
	Pawn.bCanWalkOffLedges = true;

	MyKFGameInfo = KFGameInfo( WorldInfo.Game );

	if( MyKFGameInfo != none )
	{
		// Register new possession with AIDirector
		Director = MyKFGameInfo.GetAIDirector();
		if( Director != none )
		{
			MyAIDirector = Director;
			MyAIDirector.NotifyNewPossess( self );
		}
	}

	// Transition to the idle state.
	BeginCombatCommand( None, "Possessed" );
	// Init AI Steering object in 1-3 seconds
	SetTimer( RandRange(1, 3), false, nameof(StartSteering) );
	SetTimer( RandRange(MinTimeBetweenStatusUpdates, MaxTimeBetweenStatusUpdates), false, nameof(Timer_EvaluateStatus), self );
	// Set up any desired debug related options.
	SetupDebug();

	// Give myself a PlayerReplicationInfo if bEnableGameAnalytics is true so I'll be viewable as if I'm a player when playing
	// back recorded gamestats files.
	if ( !bIsPlayer && MyKFGameInfo.bEnableGameAnalytics && !bDeleteMe && (WorldInfo.NetMode != NM_Client) )
	{
		InitPlayerReplicationInfo();
	}

	bShowVisualStuckZedDebugInfo = MyAIDirector.bShowVisualStuckZedDebugInfo;
	bShowMovePointsDebugInfo = MyAIDirector.bShowMovePointsDebugInfo;
	bShowHighDetailCombatMovementDebugInfo = MyAiDirector.bShowHighDetailCombatMovementDebugInfo;


	bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState = MyAIDirector.bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState;

	bShowLeapDownDebugArtifacts = MyAIDirector.bShowLeapDownDebugArtifacts;
	bShowDoorNavigationDebugArtifacts = MyAIDirector.bShowDoorNavigationDebugArtifacts;
	bShowDestructibleNavigationDebugArtifacts = MyAiDirector.bShowDestructibleNavigationDebugArtifacts;

    if( bUsePluginsForMovement )
    {
    	//KfMovementPlugin = KFAIPluginMovement_Recast(MovementPlugin);
    	//KfLeapPlugin = KFAIPluginLeap(LeapPlugin);
    	//KfStuckFixPlugin = KFAIPluginStuckFix(StuckFixPlugin);
	}

    // Give our pawn a pending attack upon on possesion
	if( MyKFPawn != none && MyKFPawn.PawnAnimInfo != none )
	{
		AttackRange = MyKFPawn.PawnAnimInfo.GetAttackRange( self );
	}
}

/** Used to initialize a pending attack, and choose our next attack after once we've started the pending attack */
function UpdatePendingStrike()
{
	local KFPawnAnimInfo KFPAI;

	if( MyKFPawn == none || MyKFPawn.PawnAnimInfo == none )
	{
		return;
	}

	DebugCurrentStrikeIndex = PendingAnimStrikeIndex;
	KFPAI = MyKFPawn.PawnAnimInfo;

	// Make sure we always have an attack range
	if( AttackRange == 0 )
	{
		AttackRange = KFPAI.GetAttackRange( self );
	}

	PendingAnimStrikeIndex = KFPAI.ChooseNextStrike(MyKFPawn, Enemy);
	// Make sure our attack name matches the PawnAnimInfo's tag
	if( PendingAnimStrikeIndex == 255 )
	{
		StrikeRange = 0;
		return;
	}

    // Update the range we want to get to perform our strike
	UpdateStrikeRange();

	`AILog( GetFuncName()$"() using AttackRange of "$AttackRange$" for attack polling.", 'Command_Attack_Melee' );
	return;
}

/** Find the min/max range of each Tag (attack category) defined in my KFPawn_AnimGroup. This is per-Tag,
 *  not per attack animation, and is used to pre-determine if any of the attacks for a Tag is within range. */
function UpdateStrikeRange()
{
	local float CollisionRadius;

	if( PendingAnimStrikeIndex != 255 )
	{
		CollisionRadius = MyKFPawn.CylinderComponent.CollisionRadius;
		StrikeRange = MyKFPawn.PawnAnimInfo.GetMedianStrikeRange(PendingAnimStrikeIndex, StrikeRangePercentage, CollisionRadius);
		`AILog( GetFuncName()$"() using StrikeRange of "$StrikeRange$" for attack polling.", 'Command_Attack_Melee' );
	}
}

/* Temporarily block the specified NavigationPoint if it's in my current path. This will only affect my own navigation,
 * it's not globally blocked for all NPCs. */
event bool CreateTemporaryBlockedPath( NavigationPoint Nav )
{
	local int i, x, PointIdx;

	`AILog( GetFuncName()$"() for "$Nav, 'PathWarning' );

	for( i = 0; i < RouteCache.Length; ++i )
	{
		if( RouteCache[i] == Nav )
		{
			for( x = 0; x < Nav.PathList.Length; ++x )
			{
				//`AILog( GetFuncName()$" Nav to block: "$Nav$", Anchor: "$Pawn.Anchor$"... checking current end actor "$Nav.PathList[x].End.Actor, 'PathWarning' );
				DebugLogRoute();
				PointIdx = i + 1;
				if( RouteCache.Length > PointIdx && Nav.PathList[x].End.Actor == RouteCache[PointIdx] )
				{
					`AILog( GetFuncName()$"() Found a match, calling AddBlockedReachSpec for spec "$Nav.PathList[x]$" on nav point "$RouteCache[PointIdx]  );
					//`Log( GetFuncName()$"() Found a match, calling AddBlockedReachSpec for spec "$Nav.PathList[x]$" on nav point "$RouteCache[i+1] );
					`RecordAIBlockedPath( self, Nav, RouteCache[PointIdx], "TestBlockedPath from "$Nav$" to "$RouteCache[PointIdx] );
					`RecordAIRedirectedPath( self, IntermediateMoveGoal, "[HPO]Path:"$IntermediateMoveGoal$" and "$RouteCache[PointIdx] );
					AddBlockedReachSpec( Nav.PathList[x], 10000000 );
					return true;
				}
			}
		}
	}
	return false;
}

/* Temporarily block the specified NavigationPoint if it's in my current path. This will only affect my own navigation,
 * it's not globally blocked for all NPCs. */
function bool CreateTemporaryBlockedReach( NavigationPoint Nav, ReachSpec Reach )
{
	`AILog( GetFuncName()$"() for "$Nav@Reach , 'PathWarning' );

    if( Reach != none && Reach.End.Actor == Nav )
    {
		//`AILog( GetFuncName()$" Nav to block: "$Nav$", Anchor: "$Pawn.Anchor$"... checking current end actor "$Nav.PathList[x].End.Actor, 'PathWarning' );
		DebugLogRoute();
		`AILog( GetFuncName()$"() Found a match, calling AddBlockedReachSpec for spec "$Reach$" to nav point "$Nav );
		//`Log( GetFuncName()$"() Found a match, calling AddBlockedReachSpec for spec "$Reach$" to nav point "$Nav );
		`RecordAIBlockedPath( self, Nav, NavigationPoint(Reach.End.Actor), "TestBlockedPath from "$Nav$" to "$Reach.End.Actor );
		`RecordAIRedirectedPath( self, IntermediateMoveGoal, "[HPO]Path:"$IntermediateMoveGoal$" and "$RouteCache[1] );
		AddBlockedReachSpec( Reach, 10000000 );
		return true;
    }

	return false;
}

function Timer_EvaluateStatus()
{
	if( `TimeSince(LastNotifyHitWallTime) > 3.f )
	{
		LastHitWall = none;
		LastWallHitNormal = vect(0.f,0.f,0.f);
		HitWallCount = 0;
	}

	if( bHasDebugCommand || MyKFPawn == none || MyKFPawn.Health <= 0 || MyKFPawn.IsDoingSpecialMove() )
	{
		return;
	}

	if( Enemy == None || !Enemy.IsAliveAndWell() )
	{
		FindNewEnemy();
	}
	SetTimer( RandRange(MinTimeBetweenStatusUpdates, MaxTimeBetweenStatusUpdates), false, nameof(Timer_EvaluateStatus), self );
}

/** Called after PostBeginPlay(), and sets the initial state for this controller, if not already in that state */
simulated event SetInitialState()
{
	if( GetStateName() != InitialState )
	{
		GotoState( InitialState );
	}
}

/** Returns the default AI Command class for this controller */
function class<AICommand> GetDefaultCommand()
{
	return DefaultCommandClass;
}

/** Returns whether we should exit combat and return to the idle state, generally because we don't have any more enemies */
function bool ShouldReturnToIdle()
{
	local bool bShouldReturn;

	bShouldReturn = ( !bMovingToGoal && Enemy == None );

	return bShouldReturn;
}

function SetBestAnchor()
{
	local NavigationPoint BestAnchor;
	local float Dist;

	BestAnchor = Pawn.GetBestAnchor( Pawn, Pawn.Location, true, false, Dist );
	if( BestAnchor != none )
	{
		Pawn.SetAnchor( BestAnchor );
	}
}

/** So far, no KF2 NPCs really need to return to idle, but leaving this in for now. Can override in subclasses */
function ReturnToIdle() {}

/** Used to add path constraints that we want on all the time */
function AddBasePathConstraints() {}

/** Returns current health percentage */
simulated final function float GetHealthPercentage()
{
	local Pawn	P;

	P = Pawn;

	if( P == none )
	{
		return 1.f;
	}
	else
	{
		return ( P.Health / float(P.HealthMax) );
	}
}

function PawnDied( Pawn InPawn )
{
	if( MyKFPawn != none )
	{
		`AILog( GetFuncName()$"() InPawn: "$InPawn$" - Lifetime was "$`TimeSince(MyKFPawn.CreationTime), 'Damage' );
	}
	else
	{
		`AILog( GetFuncName()$"() InPawn: "$InPawn, 'Damage' );
	}

	if( bDumpCommandHistoryOnExit )
	{
		if( bDebugCommandHistory && !bDumpedCommandHistory )
		{
			bDumpedCommandHistory = true;
			DumpCommandHistory();
		}
	}

	if( MyAIDirector != none )
	{
		// Unregister NPC with the AIDirector
		MyAIDirector.UnregisterAIMember( self );
	}
	if( MyKFPawn != none )
	{
		MyKFPawn = None;
	}

	if( KFPawn_Monster(Pawn) != none && KFGameInfo(WorldInfo.Game) != none &&
        TimeFirstSawPlayer >= 0 )
	{
	   KFGameInfo(WorldInfo.Game).GameConductor.HandleZedKill( FMax(`TimeSince(TimeFirstSawPlayer),0.0));
	   // Set this so we know we already logged a kill for our pawn
       TimeFirstSawPlayer = -1;
	}

	Super.PawnDied( InPawn );
}

function bool AttemptToTeleport( optional float CheckRadius=512 )
{
	local NavigationPoint ResNav;

	`AILog( GetFuncName() );
	ResNav = class'KFPathnode'.static.GetNearestValidFloorNavWithinRadiusToPawn(Pawn, CheckRadius);
	if( ResNav != none && TeleportToLocation(Resnav.Location, Pawn.Rotation) )
	{
		return true;
	}
	return false;
}

event bool TeleportToLocation(vector NewLoc, rotator NewRot, optional bool bGiveNavZBuffer = true, optional bool bCancelCombat=true, optional bool bCancelMovement=true )
{
    local vector OldLocation;

	//debug
	`AILog( GetFuncName()@bCancelCombat@bCancelMovement@NewLoc, 'PathError' );
	//DrawDebugLine(Pawn.Location,NewLoc,255,0,0,TRUE);
	//DrawDebugCoordinateSystem(NewLoc,rot(0,0,0),100.f,TRUE);

    if (Pawn != None )
    {
        OldLocation = Pawn.Location;
    }

    if( bGiveNavZBuffer )
    {
	   NewLoc.Z += 32.f;
	}
	if (Pawn != None &&
		Pawn.SetLocation(NewLoc))
	{
		LastTeleportLocation = OldLocation;
		LastTeleportTime = WorldInfo.TimeSeconds;

        if( Pawn.Physics == PHYS_RigidBody )
		{
			Pawn.Mesh.SetRBPosition( NewLoc );
		}

		RouteCache_Empty();

		if( bCancelMovement )
		{
			ClearMovementInfo( false );
		}

		if( bCancelCombat && CommandList != None )
		{
			BeginCombatCommand( None, "Teleported" );
		}
		Pawn.SetRotation(NewRot);
		Pawn.SetMovementPhysics();
		AIZeroMovementVariables();
		return true;
	}

	//debug
	`AILog( "TELEPORT FAILED?!", 'PathWarning' );

	return false;
}

/** Clean up all internal objects and references when the AI is destroyed
	TBD: Look into using Unpossessed() to do this! */
simulated event Destroyed()
{
	local KFDebugLines KFDL;

	KFDL = class'KFDebugLines'.static.GetDebugLines();

	if( KFDL != none )
	{
		KFDL.RemoveOwnedDebugLines( name );
		KFDL.RemoveOwnedDebugSpheres( name );
		KFDL.RemoveOwnedDebugText3D( name );
		//     SetPostRendering( false );
	}

	AbortCommand(CommandList);

	MyKFPawn = None;

	if( MyAIDirector != none )
	{
		// Unregister NPC with the AIDirector
		MyAIDirector.UnregisterAIMember( self );
	}
	// Get rid of steering object.
	if ( Steering != None )
	{
		Steering.OnOwnerDestroy();
		Steering = None;
	}

	// Unregister NPC with the AIDirector
	if( MyAIDirector != none )
	{
		MyAIDirector.UnregisterAIMember( self );
	}

	super.Destroyed();
}

/*********************************************************************************************
* Combat
**********************************************************************************************/

/*---------------------------------------------------------
  Native combat function declarations
---------------------------------------------------------*/

/** Do I have an enemy within the specified distance range? */
final native function bool HasEnemyWithinDistance( float Distance, optional out Pawn out_EnemyPawn, optional bool bExact );
/** If enemy or my pawn is moving, will return the time (seconds) until and distance (UU) the two pawns will be closest along their trajectories */
native function GetClosestTimeAndDistToPawn( KFPawn CheckPawn, out float out_ClosestTime, out float out_ClosestDist );
/** Have I moved closely enough to my enemy? */
native function bool IsCloseEnoughToEnemy();
/** Is test location within melee range? */
native function bool InMeleeRange( const Vector TestLocation, optional name AttackTag );
native function bool InAttackTagRange( const name AttackTag, const Vector TestLocation );
native function bool InAnyAttackTagRange( const Vector TestLocation, out name outAttackTag );
/** Is test location within charge attack range? */
native function bool InChargeRange( const Vector TestLocation );
/** Enable polling for medium/long range attack range checking */
final native simulated final function EnableMeleeRangeEventProbing();
/** Disable polling for medium/long range attack range checking */
final native simulated final function DisableMeleeRangeEventProbing();
/** Is medium/long range attack range checking currently enabled? */
final native simulated final function bool IsMeleeRangeEventProbingEnabled() const;
/** Calls StopLatentExecution() if currently performing a latent moveto or movetoward */
native function StopAllLatentMoveExecution();
/** Am I being targeted by a player (optionally returns first found) */
native function bool IsTargetedByPlayer( optional out KFPawn outThreateningPlayer );

function Pawn FindForcedEnemy()
{
	local KFGameInfo KFGI;
    local KFPlayerController_WeeklySurvival KFPC_WS;
	local class<KFPawn_Monster> MyMonster;

	KFGI = KFGameInfo(WorldInfo.Game);
	if(KFGI != none && KFGI.OutbreakEvent != none && KFGI.OutbreakEvent.ActiveEvent.bVIPGameMode)
	{
		MyMonster = class<KFPawn_Monster>(Pawn.Class);

		// If this monster is included on the vip targetting, force VIP as enemy
		if (KFGI.OutbreakEvent.ActiveEvent.VIPTargetting.Find(MyMonster) != INDEX_NONE)
		{
			foreach WorldInfo.AllControllers(class'KFPlayerController_WeeklySurvival', KFPC_WS)
			{
				if (KFPC_WS.VIPGameData.IsVIP && KFPC_WS.Pawn.IsAliveAndWell() && KFPC_WS.Pawn.CanAITargetThisPawn(self))
				{
					return KFPC_WS.Pawn;
				}
			}
		}
	}

	return none;
}

/**
* Originally from KF1, KFMonsterController.uc, added check to take # of Zeds targeting
* the threat into account.
*/
event bool FindNewEnemy()
{
	local Pawn				 PotentialEnemy, BestEnemy;
	local float				 BestDist, NewDist;
	local int 				 BestEnemyZedCount;
	local int 				 PotentialEnemyZedCount;
	local bool 				 bUpdateBestEnemy;

	if( Pawn == none )
	{
		return false;
	}

	BestEnemy = none;

	if (BestEnemy == none)
	{	
		foreach WorldInfo.AllPawns( class'Pawn', PotentialEnemy )
		{
			if( !PotentialEnemy.IsAliveAndWell() || Pawn.IsSameTeam( PotentialEnemy ) ||
				!PotentialEnemy.CanAITargetThisPawn(self) )
			{
				continue;
			}

			NewDist = VSizeSq( PotentialEnemy.Location - Pawn.Location );
			if( BestEnemy == none || BestDist > NewDist )
			{
				// New best enemies do not care about the number of zeds around us yet
				BestEnemyZedCount = INDEX_None;
				bUpdateBestEnemy = true;
			}
			else
			{
				// Only update NumZedsTargetingBestEnemy if it's a new best enemy and the best enemy is further
				if(BestEnemyZedCount == INDEX_None)
				{
					// Cache BestEnemyZedCount so we don't need to calculate it again
					BestEnemyZedCount = NumberOfZedsTargetingPawn( BestEnemy );
				}

				PotentialEnemyZedCount = NumberOfZedsTargetingPawn( PotentialEnemy );
				if( PotentialEnemyZedCount < BestEnemyZedCount )
				{
					BestEnemyZedCount = PotentialEnemyZedCount;
					bUpdateBestEnemy = true;
				}
			}

			if( bUpdateBestEnemy )
			{
				BestEnemy = PotentialEnemy;
				BestDist = NewDist;
				bUpdateBestEnemy = false;
			}
		}
	}

	if( Enemy != none && BestEnemy != none && BestEnemy == Enemy )
	{
		return false;
	}
	if( BestEnemy != none )
	{
		ChangeEnemy( BestEnemy );

		return HasValidEnemy();
	}

	return false;
}

/** Returns true if our new enemy has enough zeds already attacking him, for him to be our target */
function bool GetHasAcceptableEnemyCount( Pawn NewEnemy )
{
	local Float NumZedsTargetingCurrentEnemy, NumZedsTargetingNewEnemy;
	local float RatioOfZedsOldEnemyToNewEnemy;

	 // Added some rudimentary checks to help zeds prioritize when to switch targets - Ramm
    if( Enemy != none )
    {
        // Check for zeds targeting the enemies out to 10 meters
        NumZedsTargetingCurrentEnemy = NumberOfZedsTargetingPawn( Enemy,false,1000 );
        NumZedsTargetingNewEnemy = NumberOfZedsTargetingPawn( NewEnemy,false,1000 );

        // New enemy already has a full dance card, stick with current enemy
        if( NumZedsTargetingNewEnemy >= 3 )
        {
            `AILog(GetFuncName()$" New enemy already has a full dance card, stick with current enemy", 'SetEnemy');
            return false;
        }

        // Nobody nearby targeting the new enemy, go for it
        if( NumZedsTargetingNewEnemy < 1 )
        {
        	`AILog(GetFuncName()$" accepting "$NewEnemy$" because it's closer than our current, and nobody nearby targeting the new enemy", 'SetEnemy');
        	return true;
        }
        else
        {
            RatioOfZedsOldEnemyToNewEnemy = NumZedsTargetingCurrentEnemy/NumZedsTargetingNewEnemy;

            // Don't switch to the new enemy if there are too few zeds targeting the current one
            if( RatioOfZedsOldEnemyToNewEnemy <= 0.5 )
            {
                `AILog(GetFuncName()$" not accepting "$NewEnemy$" because there are too few zeds targeting the current one", 'SetEnemy');
                return false;
            }
        }
	}
	return true;
}

/** Set a new enemy, returns false potential enemy is a player and AI is set to ignore players */
event bool SetEnemyToZed( Pawn NewEnemy )
{
	local float NewEnemyDist, TimeSinceLastEnemyChange;

	`AILog( GetFuncName()$"(), desired new enemy: "$NewEnemy, 'SetEnemy' );

	// Reject potential enemy if it's invalid or not on our team, or if it's already my current enemy, or if my pawn is dead or invalid
	if( NewEnemy == none || !NewEnemy.IsAliveAndWell() ||
		Pawn == none || !Pawn.IsAliveAndWell() ||
		Pawn == NewEnemy || !NewEnemy.CanAITargetThisPawn(self) )
	{
		return false;
	}

	// Evaluate whether enough time has passed since I last changed my enemy (TODO: Need to be able to override this in some situations)
	TimeSinceLastEnemyChange = `TimeSince(LastSetEnemyTime);
	if( TimeSinceLastEnemyChange < MinTimeBetweenEnemyChanges )
	{
		`AILog( GetFuncName()$"() not evaluating because not enough time has passed ("$TimeSinceLastEnemyChange$") since last SetEnemy() call.", 'SetEnemy' );
		return false;
	}

	// Accept new enemy if its distance (plus some padding) is closer than enemy distance
    NewEnemyDist = VSize(NewEnemy.Location - Pawn.Location);
	if( NewEnemyDist < MinDistanceToAggroZed )
	{
		if( !GetHasAcceptableEnemyCount(NewEnemy) )
		{
			return false;
		}

		`AILog( GetFuncName()$"() accepting "$NewEnemy$" because Enemy ("$Enemy$") dist is > 1.2 * NewEnemy dist", 'SetEnemy' );
		ChangeEnemy( NewEnemy );
		return true;
	}

	return false;
}

/** Set a new enemy, returns false potential enemy is a player and AI is set to ignore players */
event bool SetEnemy( Pawn NewEnemy )
{
	local float EnemyDistSq, NewEnemyDistSq, TimeSinceLastEnemyChange;

	`AILog( GetFuncName()$"(), desired new enemy: "$NewEnemy, 'SetEnemy' );

	// Reject potential enemy if it's invalid or not on our team, or if it's already my current enemy, or if my pawn is dead or invalid
	if( NewEnemy == none || !NewEnemy.IsAliveAndWell() || Pawn.IsSameTeam( NewEnemy ) ||
		Pawn == none || !Pawn.IsAliveAndWell() || !NewEnemy.CanAITargetThisPawn(self) )
	{
		return false;
	}

	if(Enemy != none && NewEnemy == Enemy)
	{
		// Was attacking a door to get to enemy, but enemy has now become reachable
		if( DoorEnemy != none && LineOfSightTo( Enemy ) )
		{
			ChangeEnemy( NewEnemy );
			return true;
		}
		return false;
	}

	// Ignore cooldown time and accept the new enemy if I absolutely need one
	if( Enemy == none || !Enemy.IsAliveAndWell() )
	{
		`AILog( GetFuncName()$"(), accepting new enemy "$NewEnemy$" because current enemy is none or dead", 'SetEnemy' );
		ChangeEnemy( NewEnemy );
		return true;
	}

	// Evaluate whether enough time has passed since I last changed my enemy (TODO: Need to be able to override this in some situations)
	TimeSinceLastEnemyChange = `TimeSince(LastSetEnemyTime);
	if( TimeSinceLastEnemyChange < MinTimeBetweenEnemyChanges )
	{
		`AILog( GetFuncName()$"() not evaluating because not enough time has passed ("$TimeSinceLastEnemyChange$") since last SetEnemy() call.", 'SetEnemy' );
		return false;
	}

	// Give any AICommands on the stack an opportunity to reject changing my enemy.
	if( CachedAICommandList != none && !CachedAICommandList.CanChangeEnemy(NewEnemy) )
	{
		`AILog( GetFuncName()$"() rejecting "$NewEnemy$" because an AICommand rejected it", 'SetEnemy' );
		return false;
	}

	// From KF1 - if I already have an enemy, and I have LOS to my enemy and my enemy is closer than NewEnemy, then keep my current enemy.
	if( LineOfSightTo(Enemy) && VSize(Enemy.Location-Pawn.Location) < VSize(NewEnemy.Location-Pawn.Location) )
	{
		`AILog( GetFuncName()$"() rejecting "$NewEnemy$" because I have LOS to current enemy ("$Enemy$") and current enemy is also closer to me", 'SetEnemy' );
		return false;
	}

	// Accept new enemy if I can't see my current enemy (CanSee takes PeripheralVision into account)
	if( !CanSee(Enemy) )
	{
		`AILog( GetFuncName()$"() accepting "$NewEnemy$" because I cannot see my current enemy "$Enemy, 'SetEnemy' );
		ChangeEnemy( NewEnemy );
		return true;
	}
	// Reject new enemy if I can't see it (CanSee takes PeripheralVision into account)
	if( !CanSee(NewEnemy) )
	{
		`AILog( GetFuncName()$"() rejecting "$NewEnemy$" because I cannot see it, but I can see my current enemy "$Enemy, 'SetEnemy' );
		return false;
	}

	// Reject new enemy if my current enemy is within my StrikeRange
	EnemyDistSq = VSizeSq( Enemy.Location - Pawn.Location );
	if( MyKFPawn != none && EnemyDistSq < Square(StrikeRange) )
	{
		`AILog( GetFuncName()$"() rejecting "$NewEnemy$" because current enemy ("$Enemy$") is within my desired melee range", 'SetEnemy' );
		return false;
	}

	// Accept new enemy if its distance (plus some padding) is closer than enemy distance
    NewEnemyDistSq = Square( 1.2f * VSize(NewEnemy.Location - Pawn.Location) );
	if( EnemyDistSq > NewEnemyDistSq )
	{
		if( !GetHasAcceptableEnemyCount(NewEnemy) )
		{
			return false;
		}

		`AILog( GetFuncName()$"() accepting "$NewEnemy$" because Enemy ("$Enemy$") dist is > 1.2 * NewEnemy dist", 'SetEnemy' );
		ChangeEnemy( NewEnemy );
		return true;
	}

	return false;

	if( MyKFPawn != none && Enemy != none && Enemy == NewEnemy )
	{
		MyKFPawn.LookAtPawn( NewEnemy );
	}
	return true;
}

function ChangeEnemy( Pawn NewEnemy, optional bool bCanTaunt = true )
{
	local Pawn OldEnemy, NewForcedEnemy;

	local KFGameInfo KFGI;

	if (CanForceEnemy)
	{
		NewForcedEnemy = FindForcedEnemy();
	}
	else if (NewEnemy == LastForcedEnemy)
	{
		return; // Don't allow to change to the ForcedEnemy while we can't (we reenable that again from outside)
	}

	if (NewForcedEnemy != none)
	{
		ForcedEnemy = NewForcedEnemy;

		if (Enemy != ForcedEnemy)
		{
			LastForcedEnemy = ForcedEnemy;

			ForcedEnemyLastTime = WorldInfo.TimeSeconds;
		}
		
		NewEnemy = NewForcedEnemy;
	}
	else
	{
		ForcedEnemy = none;
	}

	// gameinfo hook that calls mutator hook
	KFGI = KFGameInfo( WorldInfo.Game );
	if( KFGI != none )
	{
		KFGI.OnAIChangeEnemy( self, NewEnemy );
	}

	if( Enemy != none && Enemy != NewEnemy )
	{
		if( bCanTaunt && MyKFPawn != none && MyKFPawn.CanDoSpecialMove(SM_WalkingTaunt) )
		{
			MyKFPawn.DoSpecialMove(SM_WalkingTaunt);
		}

		OldEnemy = Enemy;
		if( OldEnemy != none )
		{
			`RecordAIChangedEnemy( self, NewEnemy, OldEnemy, "ChangeEnemy() " );
		}

		// Set our last enemy switch time for the aggro system
		LastEnemySwitchTime = WorldInfo.TimeSeconds;
	}
	`AILog( GetFuncName()$"() set Enemy to "$NewEnemy, 'SetEnemy' );
	Enemy = NewEnemy;

	BroadcastEnemyKnowledge(NewEnemy, WSPM_Belief);

	// Notify AI commands about the enemy change.
	if( CachedAICommandList != none )
	{
		if( OldEnemy != none )
		{
			CachedAICommandList.NotifyEnemyChanged( OldEnemy );
		}
		else
		{
			CachedAICommandList.NotifyEnemyChanged();
		}
	}

	// Update cooldown time.
	LastSetEnemyTime = WorldInfo.TimeSeconds;
}

/** Search for enemies within a set FOV range */
function KFPawn CheckForEnemiesInFOV( float MaxRange,
									float MinFOV,
									float MaxFOV,
									optional bool bForceRetarget,
									optional bool bTauntNewEnemy=true )
{
	local vector PawnDir, Projection;
	local float FOVDot, TempDistSQ, BestDistSQ;
	local KFPawn KFP, BestTarget;

	if( Pawn == none )
	{
		return none;
	}

	PawnDir = vector( Pawn.Rotation );

	foreach Pawn.OverlappingActors( class'KFPawn', KFP, MaxRange )
	{
		if( bForceRetarget && Enemy == KFP )
		{
			continue;
		}

		if( !KFP.IsAliveAndWell() || KFP.GetTeamNum() == GetTeamNum() || !KFP.CanAITargetThisPawn(Pawn.Controller))
		{
			continue;
		}

		Projection = KFP.Location - Pawn.Location;

		// Only care about players within the FOV range
		FOVDot = PawnDir dot Normal( Projection );
		if( FOVDot < MinFOV || FOVDot > MaxFOV )
		{
			continue;
		}

		// Make sure enemy isn't obstructed
		if( !`FastTracePhysX(KFP.Location, Pawn.Location) )
		{
			continue;
		}

		// Make sure enemy isn't too far away
		TempDistSQ = VSizeSQ( Projection );

		// Scales distance by aggro rating (0.0 - 1.0)
		TempDistSQ *= 1.f - GetAggroRating( KFP );

		if( BestTarget == none || TempDistSQ < BestDistSQ )
		{
			BestDistSQ = TempDistSQ;
			BestTarget = KFP;
		}
	}

	if( BestTarget != none && BestTarget != Enemy )
	{
		ChangeEnemy( BestTarget, bTauntNewEnemy );
		return BestTarget;
	}

	return none;
}

/** Allows subclasses to assess aggro ratings on a pawn-by-pawn basis */
function float GetAggroRating( KFPawn KFP )
{
	return 0.f;
}

/** Enable notifications sent from native code which signial when NPC is in range to perform certain attacks */
function EnableProbingMeleeRangeEvents( optional bool bForce )
{
	if( bForce || !MyKFPawn.IsDoingSpecialMove()  )
	{
		`AILog( GetFuncName()$"() setting bIsProbingMeleeRangeEvents to true, restoring ability to melee attack", 'AIController' );
		EnableMeleeRangeEventProbing();
		ClearTimer( nameof(EnableProbingMeleeRangeEvents) );
	}
	else
	{
		`AILog( GetFuncName()$"() waiting to restore ability to melee attack, will check again in 0.1 seconds", 'AIController' );
		SetTimer( 0.25f, true, nameof(EnableProbingMeleeRangeEvents) );
	}
}

/** Disable notifications sent from native code which signial when NPC is in range to perform certain attacks */
function ResetProbingMeleeRangeEvents( optional float DelayOverride )
{
	local float Delay;

	//DelayOverride = 0.5;
	Delay = (DelayOverride>0.f?DelayOverride:0.07f);
	`AILog( GetFuncName()$"() will be resetting bIsProbingMeleeRangeEvents to true in "$Delay$" seconds", 'Command_Attack_Melee' );
	SetTimer( Delay, false, nameof(EnableProbingMeleeRangeEvents), self );
	//EnableProbingMeleeRangeEvents();
}

/** Event called by TickMeleeCombatDecision() if MeleeRangeEventProbing is enabled and all basic melee checks have passed */
event ReadyToMelee();

/** Override in child classes for NPCs using the suicide AICommand (i.e, Husks) */
function bool IsSuicidal()
{
	return false;
}

function bool IsDoingGrabSpecialMove()
{
	return ( MyKFPawn != none && MyKFPawn.IsDoingSpecialMove(SM_GrappleAttack) );
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
			return false;
		}
	}

	return true;
}

/**
 * BeginCombatCommand() - Initiates general base combat command for NPC.
 *
 * @param	CmdClass	Command to start.
 * @param	Reason		Debug string.
 * @param	bForced		Init command regardless of combat transition status.
 */
function BeginCombatCommand( class<AICommand> CmdClass, optional coerce string Reason, optional bool bForced )
{
	local class<AICommand_Base_Combat> CurClass;
	local AICommand_Base_Combat	CurCommand;

	`AILog( GetFuncName()@CmdClass@"(CommandList:"$CommandList$") Reason: "$Reason$" bForced: "$bForced, 'InitAICommand' );

	if( CommandList != None )
	{
		CurCommand = AICommand_Base_Combat(CommandList);
		if( CurCommand != None )
		{
			CurClass = AICommand_Base_Combat(CommandList).Class;
		}
	}

	if( !bForced )
	{
		if( CmdClass != None && !bAllowCombatTransitions )
		{
			`AILog( self$" Not allowing combat transition due to scripting", 'InitAICommand' );
			return;
		}

		if( CommandList != None && !CommandList.AllowTransitionTo( CmdClass ) )
		{
			`AILog( self$" Current command stack rejected transiton", 'InitAICommand' );
			return;
		}
	}

	CleanOutCommandListOnCombatTransition();

	if( CmdClass != None )
	{
		InitalizeBaseCommand( CmdClass );
	}
	else
	{
		// If moving from combat back to Idle
		if( CurClass != None )
		{
			ReturnToIdle();
		}
		GotoState( 'Action_Idle', 'Begin' );
	}
}

function InitalizeBaseCommand( class<AICommand> CmdClass )
{
	CmdClass.static.InitCommand( self );
}

function CleanOutCommandListOnCombatTransition()
{
	if( CommandList != None )
	{
		AbortCommand( CommandList ); //[NEWCODE] was commented out, isn't in gow3
	}
}


/** Find the closest potential enemy to my pawn */
final function Pawn GetClosestEnemy( optional Pawn ExcludePawn )
{
	local Pawn P, Best;
	local float Dist, BestDist;

	BestDist = 1000000.0;
	foreach WorldInfo.AllPawns( class'Pawn', P )
	{
		if( !P.IsAliveAndWell() || (ExcludePawn != none && ExcludePawn == P) || !P.CanAITargetThisPawn(self) )
		{
			continue;
		}
		if( (P.Controller != None && P.Controller != self && P.IsAliveAndWell()) && !Pawn.IsSameTeam( P ) )
		{
			Dist = VSize( P.Location - Pawn.Location );
			if( Dist < BestDist )
			{
				Best = P;
				BestDist = Dist;
			}
		}
	}
	`AILog( GetFuncName()$"() returning closest enemy "$Best, 'SetEnemy' );
	if( Best == none && ExcludePawn != none )
	{
		Best = ExcludePawn;
	}
	return Best;
}

/** Returns true if NPC is doing an attack-related special move. TODO: Needs refactor (remove IsA, etc.) */
final event bool IsDoingAttackSpecialMove()
{
	local ESpecialMove KFSM;

	if( MyKFPawn.IsDoingSpecialMove() )
	{
		KFSM = MyKFPawn.SpecialMove;

		if( KFSM == SM_MeleeAttack || KFSM == SM_GrappleAttack || KFSM == SM_SonicAttack || KFSM == SM_MeleeAttackDoor
			|| KFSM == SM_Suicide )
		{
			return true;
		}
	}
	return false;
}

/** Check for a combat transition, called once the current behavior has completed */
function CheckCombatTransition()
{
	local class<AICommand> NewCommand;
	local string Reason;
	local bool bTransition;
	local AICommand_Base_Combat CurCommand;

	`AILog( GetFuncName()$"() bAllowCombatTransitions: "$bAllowCombatTransitions, 'CombatTransitions' );
	if (Pawn == None || !Pawn.IsAliveAndWell() || !bAllowCombatTransitions || IsDead() )
	{
		return;
	}

	`AILog( GetFuncName()@CommandList$" calling CheckInterruptCombatTransitions now", 'CombatTransitions' );

	// First check for interrupt transitions
	bTransition = !CheckInterruptCombatTransitions();
	// If no interrupt occurred
	if( bTransition )
	{
		`AILog( "bTransition was true from CheckInterruptCombatTransitions()", 'CombatTransitions' );
		CurCommand = AICommand_Base_Combat(CommandList);
		if( CurCommand != None &&
			CurCommand.CheckTransition( NewCommand, Reason ) )
		{
			`AILog( GetFuncName()$"() Calling BeginCombatCommand for "$NewCommand, 'CombatTransitions' );
			BeginCombatCommand( NewCommand, Reason );
		}
		else
		if( CurCommand == None && (CommandList == none || CommandList.Class != DefaultCommandClass))
		{
			NewCommand = GetDefaultCommand();
			if(NewCommand == none)
			{
				`AILog("WARNING! "$self$" has no default command specified!", 'CombatTransitions');
				return;
			}
			`AILog( GetFuncName()$"() Calling BeginCombatCommand for 2 "$NewCommand, 'CombatTransitions' );
			BeginCombatCommand(NewCommand, "No Command Specified" );
		}
	}
}

//function NotifyKilled(Controller Killer, Controller Killed, Pawn KilledPawn)
function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageTyp)
{
    // TODO: add a radius check so that zeds won't taunt over really far away guys
    // or if there is another enemy really close!
    if( Killer != none && Killer == self && KilledPawn != none && Pawn != none
        && !Pawn.IsSameTeam( KilledPawn ) && KilledPawn == Enemy )
    {
        class'AICommand_TauntEnemy'.static.Taunt(self, KilledPawn, TAUNT_EnemyKilled );
    }
    else if ( KilledPawn != none && KilledPawn == Enemy )
    {
        // Find a new enemy if our current enemy dies!
        FindNewEnemy();
    }

	super.NotifyKilled(Killer, Killed, KilledPawn, damageTyp);
}

/** Returns true if we have a valid enemy targeted  */
final function bool HasValidEnemy( optional Pawn TestEnemy )
{
	if( TestEnemy == None )
	{
		TestEnemy = Enemy;
	}

	if(  TestEnemy == None ||
		!TestEnemy.IsValidEnemyTargetFor( PlayerReplicationInfo, true ) )
	{
		return false;
	}

	return true;
}

/** TODO: Refactor to always just use FindNewEnemy */
function bool SelectEnemy()
{
    return FindNewEnemy();
}

/** TODO: Refactor to always just use FindNewEnemy */
function bool SelectTarget()
{
    return FindNewEnemy();
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

	if( (MyKFPawn.bIsSprinting || MyKFPawn.IsEnraged()) )
	{
		BumpEffectDamage = ZedBumpEffectThreshold * BumpedMonster.ZedBumpDamageScale * (MyKFPawn.bIsSprinting ? 2 : 1);

		// If the Bumped Zed is near death, play either a knockdown or an immediate obliteration
		if( BumpedMonster.Health - BumpEffectDamage <= 0 )
		{
			BumpedMonster.TakeDamage(BumpEffectDamage, self, BumpedMonster.Location, vect(0, 0, 0), MyKFPawn.GetBumpAttackDamageType());
			BumpedMonster.Knockdown(, vect(1, 1, 1), Pawn.Location, 1000, 100);
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

/*********************************************************************************************
* MELEE
********************************************************************************************* */

/** Notification from AICommand_Attack_Melee that I've just completed an attack */
function NotifyMeleeAttackFinished();

/** Starts base melee AI command */
function BeginMeleeCommand( Pawn TargetPawn, optional coerce String Reason )
{
	`AILog( GetFuncName()$"() TargetPawn: "$TargetPawn, 'Command_Attack_Melee' );

	if( AICommand_Base_Zed(CommandList) == none )
	{
		// Optionally set my enemy to TargetPawn
		if( TargetPawn != None )
		{
			SetEnemy( TargetPawn );
		}

		if( MeleeCommandClass != GetDefaultCommand() )
		{
			`AILog( GetFuncName()$"() calling BeginCombatCommand for "$MeleeCommandClass, 'Command_Attack_Melee' );
			BeginCombatCommand( MeleeCommandClass, Reason, true );
		}
	}
}

/** Is current potential target valid? TODO: Conditions need refactoring */
function bool IsValidAttackTarget( Actor CheckActor )
{
	if( CheckActor == none || CheckActor.bTearOff )
	{
		return false;
	}

	return true;
}

/**
 *  Used by movement commands to determine if NPC is close enough consider a strike
 */
function bool IsWithinAttackRange()
{
	local float DistSqToEnemy;

	// If my current enemy isn't valid, set my enemy to the closest one available
	if( MyKFPawn == none || Enemy == none || !MyKFPawn.IsAliveAndWell() || !Enemy.IsAliveAndWell() )
	{
		if( Enemy == none || Enemy.Health <= 0 )
		{
			Enemy = none;
			SetEnemy( GetClosestEnemy() );
			return false;
		}
		return true;
	}

	if( MyKFGameInfo.NumPlayers > 1 )
	{
		// If at least 4 other KFPawns are within 350 units of my enemy, and I'm close enough to see my enemy...
		if( KFPawn(Enemy).IsSurrounded(false, 4, 350.f) && CanSee(Enemy) )
		{
			// ... Try to find a new enemy and return false if I decided to change targets
			if( FindNewEnemy() )
			{
				`AILog( GetFuncName()$" found that enemy is surrounded so changed enemy to "$Enemy, 'ReachedEnemy' );
				return false;
			}
		}
	}

	if( MyKFPawn.PawnAnimInfo == none )
	{
		`warn( "No PawnAnimInfo defined for "$MyKFPawn );
		return IsCloseEnoughToEnemy();
	}

	// Check distance from enemy versus my PawnAnimInfo's AttackRange value.
	DistSqToEnemy = VSizeSq( Enemy.Location - Pawn.Location );
	if( DistSqToEnemy <= AttackRange * AttackRange )
	{
		return true;
	}

	return false;
}

/** Check to see if this KFPawn is within allowed height difference for melee */
function bool WithinMeleeHeightDifference( KFPawn EnemyPawn )
{
	local vector EnemyPawnGroundPos, MyPawnGroundPos;
	local vector EnemyPawnCylinder, MyPawnCylinder;

	EnemyPawnCylinder.Z = EnemyPawn.CylinderComponent.CollisionHeight;
	MyPawnCylinder.Z = Pawn.CylinderComponent.CollisionHeight;

	EnemyPawnGroundPos = EnemyPawn.Location - EnemyPawnCylinder;
	MyPawnGroundPos = Pawn.Location - MyPawnCylinder;
	return ( Abs(Normal(EnemyPawnGroundPos - MyPawnGroundPos).Z) < MaxMeleeHeightAngle );
}

/** Notification that a melee attack has ended or been aborted */
function EndOfMeleeAttackNotification();

/** Notification from melee attack command that it was aborted due to damage taken */
function NotifyCommandMeleeAttackAborted()
{
	local AICommand_Attack_Melee MeleeCommand;
	`AILog( GetFuncName()$"()", 'Command_Attack_Melee' );

	// Push AICommand if it is defined. (jessnew)
	if( CommandList != None && GetActiveCommand().IsA('AICommand_Attack_Melee') )
	{
		MeleeCommand = AICommand_Attack_Melee( GetActiveCommand() );

		if( MeleeCommand != none )
		{
			`AILog( GetFuncName()$"() calling AbortCommand for "$MeleeCommand, 'Command_Attack_Melee' );
			AbortCommand( MeleeCommand );
		}
	}
}

/** Updates time of last melee attack performed by this NPC (TODO: Need to update this) */
function UpdateLastMeleeTime( EAnimSlotStance BodyStance )
{
	LastAttackTime_Melee = WorldInfo.TimeSeconds;
}

/** Chooses a melee attack animation by name */
function ChooseStrikeByName( name AttackName, optional bool bForce )
{
	local int DesiredStrikeIndex;
	local KFPawnAnimInfo KFPAI;

	if( AttackName != '' && MyKFPawn != none && MyKFPawn.PawnAnimInfo != none )
	{
		KFPAI = MyKFPawn.PawnAnimInfo;
		DesiredStrikeIndex = KFPAI.GetAttackIndexByTag(AttackName);

		// Make sure our attack name matches the PawnAnimInfo's tag
		if( DesiredStrikeIndex < 0 )
		{
			`warn("MeleeAttackRandList Tag "$ AttackName $" Could not be found in the PawnAnimInfo");
			return;
		}

		// if we aren't forcing the attack, check to see if this is a valid attack
		if ( bForce || KFPAI.CanDoAttackAnim(DesiredStrikeIndex, MyKFPawn, Enemy) )
		{
			// Updates the next time this attack can be used
			KFPAI.UpdateAttackCooldown(self, DesiredStrikeIndex);

			return;
		}
	}
	`log(self@GetFuncName()@"failed to find a valid attack");
}

/** Override in child classes - return true if permitted to grab enemy */
event bool CanGrabAttack()
{
	return false;
}

/** Override in child classes if pawn can grab */
event DoGrabAttack( optional Pawn NewEnemy, optional float InPostSpecialMoveSleepTime=0.f ) {}

/** Count how many Zeds are currently targeting P, optionally excluding myself from the count */
function int NumberOfZedsTargetingPawn( Pawn P, optional bool bExcludeMe=true, optional float MinDistanceToInclude )
{
	local Controller C;
	local int ZedCount;

	if( P == none || !P.IsAliveAndWell() )
	{
		return 0;
	}

	foreach WorldInfo.AllControllers( class'Controller', C )
	{
		if( C.Enemy == P && C.Pawn != none && (C.Pawn != Pawn || !bExcludeMe) && C.Pawn.IsAliveAndWell() )
		{
			if( MinDistanceToInclude == 0.f || (MinDistanceToInclude > 0.f && (VSizeSq(C.Pawn.Location - P.Location) <= MinDistanceToInclude * MinDistanceToInclude)) )
			{
				ZedCount++;
			}
		}
	}

	return ZedCount;
}

/**
 * How many other Zeds are currently targeting my enemy? Use to determine ahead of time if it'd be worthwhile
 * to target players with fewer Zeds targeting them.
 */
function int OtherZedsTargetingMyEnemy()
{
	local KFAIController KFAIC;
	local int ZedCount;

	if( Enemy == none || !Enemy.IsAliveAndWell() )
	{
		return 0;
	}

	foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
	{
		if( KFAIC != self && KFAIC.Pawn != none && KFAIC.Pawn.IsAliveAndWell() && KFAIC.Enemy != none && KFAIC.Enemy == Enemy )
		{
			ZedCount++;
		}
	}

	return ZedCount;
}

/** Returns how many Zeds are out there, optionally how many are within the specified # of units to my pawn */
function int GetZedCount( optional float MinDistanceFromMyPawn=0.f )
{
	local KFAIController KFAIC;
	local int ZedCount;

	foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
	{
		if( KFAIC.Pawn != none && KFAIC.Pawn.IsAliveAndWell() )
		{
			if( MinDistanceFromMyPawn > 0.f )
			{
				if( VSizeSq(KFAIC.Pawn.Location - Pawn.Location) <= (MinDistanceFromMyPawn*MinDistanceFromMyPawn) )
				{
					ZedCount++;
				}
			}
			else
			{
				ZedCount++;
			}
		}
	}

	return ZedCount;
}

native final function bool CanSeeByPointsEx( Vector ViewLocation, Vector TestLocation, Rotator ViewRotation, out Vector outHitLoc, out Actor outHitActor );

/**
 * True if MinimalCount Zeds are within CheckRadius units of aLocation, optionally requiring a Zed can currently see
 * that location before counting him.
 */
function bool AreZedsNear( vector aLocation, optional bool bRequireCanSee=false, optional float CheckRadius=650.f, optional int MinimalCount=1 )
{
	local int i, ZedCount;
	local rotator ViewRot;
	local vector ViewLoc;

	if( MyAIDirector == none )
	{
		return false;
	}

	// Can use KFAIDirector's AIList rather than AllControllers, etc.
	for( i = 0; i < MyAIDirector.AIList.Length; i++ )
	{
		if( ZedCount >= MinimalCount )
		{
			return true;
		}
		if( MyAIDirector.AIList[i] == self || MyAIDirector.AIList[i].MyKFPawn == none || MyAIDirector.AIList[i].MyKFPawn.IsUsingSuperSpeed() )
		{
			continue;
		}
		if( CheckRadius > 0.f && VSizeSq( MyAIDirector.AIList[i].Pawn.Location - aLocation ) < (CheckRadius * CheckRadius) )
		{
			if( bRequireCanSee )
			{
				MyAIDirector.AIList[i].MyKFPawn.GetActorEyesViewPoint( ViewLoc, ViewRot );
				if( MyAIDirector.AIList[i].CanSeeByPoints( ViewLoc, aLocation, ViewRot ) )
				{
					ZedCount++;
				}
				else
				{
					continue;
				}
			}
			else
			{
				ZedCount++;
			}
		}
	}
	return false;
}

/** Returns false if this attack is still on cooldown */
function bool CheckCooldownTimer(name CooldownTag)
{
	local int i;

	i = CooldownTimers.Find('Tag', CooldownTag);
	if ( i != INDEX_None )
	{
		if ( `TimeSince(CooldownTimers[i].ActivationTime) < CooldownTimers[i].Duration )
		{
			return false;
		}
	}

	return true;
}

/** Add (or update existing) cooldown timer */
function AddCooldownTimer(name CooldownTag, float CooldownTime)
{
	local int i;
	local CooldownData NewCooldown;

	i = CooldownTimers.Find('Tag', CooldownTag);
	if ( i == INDEX_None )
	{
		NewCooldown.Tag = CooldownTag;
		i = CooldownTimers.AddItem(NewCooldown);
	}

	CooldownTimers[i].Duration = CooldownTime;
	CooldownTimers[i].ActivationTime = WorldInfo.TimeSeconds;
}

/** Set overall attack cooldown timer */
function SetOverallCooldownTimer(float CooldownTime)
{
	OverallAttackCooldownTimer.Duration = CooldownTime;
	OverallAttackCooldownTimer.ActivationTime = WorldInfo.TimeSeconds;
}

/** Returns false if the overall attacks are still on cooldown */
function bool CheckOverallCooldownTimer()
{
	if ( OverallAttackCooldownTimer.Duration > 0 &&
        `TimeSince(OverallAttackCooldownTimer.ActivationTime) < OverallAttackCooldownTimer.Duration )
	{
		return false;
	}

	return true;
}

/*---------------------------------------------------------
  Combat transitions
---------------------------------------------------------*/

/** Check for an interrupt transition, can override any normal transition */
function bool CheckInterruptCombatTransitions()
{
	local AICommand_Base_Combat	CurCommand;

	`AILog( "---- "$GetFuncName()$"() IgnoreNotifies? : "$IgnoreNotifies(), 'CombatTransitions' );
	// If dead, gone, or ignoring notifies don't bother
	if( Pawn == None || !Pawn.IsAliveAndWell() || IsDead() || IgnoreNotifies() )
	{
		`AILog( "---- "$GetFuncName()$"() aborting early", 'CombatTransitions' );
		return false;
	}

	// check that our enemy is still valid
	if( Enemy != None && ( !Enemy.IsAliveAndWell() || Enemy.Controller == none ) )
	{
		`AILog( GetFuncName()$"() setting enemy to NONE because they have no controller or they are dead!", 'CombatTransitions' );
		SetEnemy( None );
	}

	// If not already in combat then don't bother
	CurCommand = AICommand_Base_Combat( CommandList );
	if( CurCommand == None )
	{
		`AILog( "---- "$GetFuncName()$"() setting enemy aborting because current command ("$CurCommand$") isn't a combat based command", 'CombatTransitions' );
		return false;
	}

	if( AICommand_Base_Combat(CommandList) != None && ShouldReturnToIdle() )
	{
		//`AILog( "---- "$GetFuncName()$"() setting enemy aborting because current command ("$CurCommand$") isn't a combat based command", 'CombatTransitions' );
		`AILog( GetFuncName()$"() returning true because I have a combat command and ShouldReturnToIdle returned true", 'CombatTransitions' );
		//BeginCombatCommand( None, "No Enemies" );

		return true;
	}
	`AILog( GetFuncName()$"() returning false", 'CombatTransitions' );
	return false;
}

/*********************************************************************************************
* Movement Methods
********************************************************************************************* */

/*---------------------------------------------------------
  Native  definitions
---------------------------------------------------------*/
/** Same as actor reachable, only allows the "no anchor check" option to be used from script */
native final function bool ActorReachableNoAnchorCheck( actor anActor );
// Returns true if next intermediate move target is a KFJumpPoint node
native function bool IsMovingToJumpPoint();
// Initializes NPC steering
native function InitSteering();
// Returns NPC's steering object
native function KFAISteering GetSteering();
// Calculates distance along current path, using NPC's routecache if valid
final native function float GetRouteCacheDistance();
// < -1 = Already passed LocB, nearly zero = nearly parallel
native function float CalcClosestPointTime( Vector LocA, Vector VelocityA, Vector LocB, Vector VelocityB );
// Used in checking direct reachability to goal while pawn is moving along a path
native function SetDirectPathCheckTime();

/** Is my pawn currently performing a latent move? */
function bool IsDoingLatentMove()
{
	return (InLatentExecution(LATENT_MOVETOWARD) || InLatentExecution(LATENT_MOVETO));
}

/*********************************************************************************************
* MOVEMENT AND PATHFINDING
********************************************************************************************* */

/** Forcibly stops any active latent movement and execution and stops accel/velocity */
event StopAllLatentMovement( optional bool bForced )
{
	StopAllLatentMoveExecution();
	AIZeroMovementVariables();
}

/** Abort any movement commands and reset MoveTarget */
function ClearMovementInfo( optional bool bSafeAbort, optional string DebugMsg )
{
	`AILog( GetFuncName()$"() Aborting movement commands and setting MoveTarget to none", 'Command_MoveToGoal' );
	AbortMovementCommands();
	AbortMovementPlugIns();
	MoveTarget  = None;
}

/** Abort the main movement commands, might change to abort others like StepAside */
event AbortMovementCommands( optional bool bSafeAbort, optional string DebugMsg )
{
	`AILog( GetFuncName()$"() called, aborting MoveToEnemy and MoveToGoal commands if they are active", 'Command_MoveToGoal' );
	if( DebugMsg != "" )
	{
		FindCommandOfClass(class'AICommand_MoveToEnemy').UpdateHistoryString(DebugMsg);
		FindCommandOfClass(class'AICommand_MoveToGoal').UpdateHistoryString(DebugMsg);
	}
	AbortCommand( None, class'AICommand_MoveToEnemy' );
	AbortCommand( None, class'AICommand_MoveToGoal'	);
}

/** Abort the main movement commands, might change to abort others like StepAside */
event AbortMovementPlugIns( optional bool bSafeAbort, optional string DebugMsg )
{
	`AILog( GetFuncName()$"() called, aborting MovementPlugin and LeapPlugin Plug Ins if they are active", 'Movement_Plugins' );
	if( DebugMsg != "" )
	{
		if( KfMovementPlugin != none )
		{
            KfMovementPlugin.UpdateHistoryString(DebugMsg);
        }
        if( KfLeapPlugin != none )
        {
            KfLeapPlugin.UpdateHistoryString(DebugMsg);
		}
        if( StuckFixPlugin != none )
        {
            StuckFixPlugin.UpdateHistoryString(DebugMsg);
		}
	}

		if( KfMovementPlugin != none )
		{
            KfMovementPlugin.AbortMove(false);
        }
        if( KfLeapPlugin != none )
        {
            KfLeapPlugin.AbortMove(false);
		}
        if( StuckFixPlugin != none )
        {
            StuckFixPlugin.AbortMove(false);
		}
}

/** Stops latent move, and zeroes pawn Acceleration and Velocity if the pawn's not falling (or if bForce is true) */
function AIZeroMovementVariables( optional bool bForce )
{
	`AILog( WorldInfo.TimeSeconds$" "$GetFuncName()$" setting movetimer to -1", 'PathWarning' );
	MoveTimer = -1.f;  // Keep an eye on this

	if( Pawn != none )
	{
		if( !bForce && Pawn.Physics == PHYS_Falling )
		{
			return;
		}

		Pawn.ZeroMovementVariables();
	}
}

function StopMovement(optional EActionPriority ActionPriority = AP_Logic)
{
	Super.StopMovement(ActionPriority);

	if( KfWallWalkingPlugIn != none )
	{
		KfWallWalkingPlugIn.AbortMove(false);
	}
}

/** Called by AICommands to notify that a move is about to start */
event StartingMovement()
{
	`AILog( self$" StartingMovement", 'AIController' );
}

/** Called by AICommands to notify that a move has ended */
event StoppingMovement()
{
	`AILog( self$" StoppingMovement", 'AIController' );
}

/** Called by AICommands to determine if NPC is allowed to move */
event bool AllowedToMove()
{
	// Disallow for SM attacks since movement will be handled by root motion
	return ( !IsDoingAttackSpecialMove() );
}

/** Called by movetogoal when we arrive at our destination */
event ReachedMoveGoal()
{
	`AILog( self$" Reached MoveGoal!", 'AIController' );
}

/** Called by movetogoal when we arrive at an intermediate point in our path (pathnode location, etc.) */
function ReachedIntermediateMoveGoal()
{
	`AILog( self$" ReachedIntermediateMoveGoal!", 'AIController' );
}

/** TODO: Needs to be deprecated or revised */
function bool MoveIsInterruptable(optional bool bForce)
{
	return true;
}

/** Check if given goal is valid */
function bool MoveGoalIsValid( optional Actor Goal )
{
	if( Goal == None )
	{
		Goal = MoveGoal;
	}
	return (Goal != None);
}

/** Check if given point is valid */
function bool MovePointIsValid( optional Vector Point )
{
	if( Point == vect(0,0,0) )
	{
		Point = GetBasedPosition( MovePosition );
	}
	return (Point != vect(0,0,0));
}

/*********************************************************************************************
* PATH BUILDING
********************************************************************************************* */

/** Build a path to goal actor */
event Actor GeneratePathTo( Actor Goal, optional float Distance, optional bool bAllowPartialPath )
{
	local actor PathResult;

	AddBasePathConstraints();
	`AILog( GetFuncName()$"() Goal: "$Goal$" optional distance: "$Distance$" bAllowPartialPath: "$bAllowPartialPath, 'AIController' );
	class'Path_TowardGoal'.static.TowardGoal( Pawn, Goal );
	if( bDisablePartialPaths )
	{
		bAllowPartialPath = false;
	}
	class'Goal_AtActor'.static.AtActor( Pawn, Goal, Distance, bAllowPartialPath );
	PathResult = FindPathToward( Goal );
	Pawn.ClearConstraints();
	return PathResult;
}

event bool GenerateNavMeshPathTo( Actor Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	if( NavigationHandle == None )
	{
		return false;
	}

	NavigationHandle.ClearConstraints();

	class'NavMeshPath_Toward'.static.TowardGoal( NavigationHandle, Goal );
	class'NavMeshGoal_At'.static.AtActor( NavigationHandle, Goal, WithinDistance, bAllowPartialPath );

	return NavigationHandle.FindPath();
}

event bool GenerateNavMeshPathToLocation( Vector Goal, optional float WithinDistance, optional bool bAllowPartialPath )
{
	if( NavigationHandle == None )
	{
		return FALSE;
	}

	NavigationHandle.ClearConstraints();

	// NavMeshPathConstraint
	class'NavMeshPath_Toward'.static.TowardPoint( NavigationHandle, Goal );

	// NavMeshPathGoalEvaluator
	class'NavMeshGoal_At'.static.AtLocation( NavigationHandle, Goal, WithinDistance, bAllowPartialPath );

	return NavigationHandle.FindPath();
}


/** Generates a path to goal which avoids passing through closed and locked doors */
event Actor GenerateDoorlessPathTo( Actor Goal, optional float Distance, optional bool bAllowPartialPath )
{
	local actor PathResult;
	local KFPawn CheckPawn;

	CheckPawn = KFPawn(Goal);

	AddBasePathConstraints();

	class'Path_TowardGoal'.static.TowardGoal( Pawn, CheckPawn );

	class'Path_AvoidClosedDoors'.static.AvoidClosedDoors( Pawn, true );
	class'Goal_Null'.static.GoUntilBust( Pawn, 2024 );
	//class'Goal_AtActor'.static.AtActor( Pawn, Goal, Distance, bAllowPartialPath );
	// Attempt to build the path.
	PathResult = FindPathToward( Goal );
	Pawn.ClearConstraints();

	if( PathResult == None )
	{
		`AILog( GetFuncName()$"() failed to build a path to "$Goal$", offset distance was "$Distance$", bAllowPartialPath was "$bAllowPartialPath, 'PathWarning' );
	}
	return PathResult;
}

/** Manually block a troublesome path connection, or specify a cost which won't explicitly block it */
native function bool AddBlockedReachSpec( ReachSpec BlockedSpec, INT BlockedCost );

static function ShowAdvancedRouteEdgeDebugInfo( NavigationHandle KFNavigationHandle2Use, optional bool bShowPathCachePolys = false )
{
	//local array<KFNavMeshMovementStepData> debugPathData;
	//local array<string> listOfEdgeTrips;
	//local int i;
	//local Vector textOffset;

	//if( bShowPathCachePolys )
	//{
	//	//FlushPersistentDebugLines();
	//	KFNavigationHandle2Use.DrawPathCache(,true);
	//}
	//KFNavigationHandle2Use.FillArrayWithAllCurrentNavMeshMovementStepData(debugPathData);
	//KFNavigationHandle2Use.FillArrayWithAllCurrentPathEdgeTrippyDebugInfo( listOfEdgeTrips );

	//for( i = 0; i < KFNavigationHandle2Use.PathCache.EdgeList.Length; i++ )
	//{
	//	//typeOfEdge = listOfEdgeTypes[i];

	//	textOffset = Vect(0,0,1);
	//	textOffset *= 10.0f + 10*i;

	//	DrawDebugString( debugPathData[i].EdgeCenter + textOffset, string(i) @ listOfEdgeTrips[i] /*string(typeOfEdge)*/, , debugPathData[i].EdgeColor, default.TimeToShowEdgeTypeForNavMeshPathting);
	//	DrawDebugLine( debugPathData[i].EdgeCenter , debugPathData[i].EdgeCenter + textOffset , debugPathData[i].EdgeColor.R, debugPathData[i].EdgeColor.G, debugPathData[i].EdgeColor.B, true );

	//	DrawDebugLine( debugPathData[i].EdgeCenter + textOffset , debugPathData[i].Poly0Center + textOffset , debugPathData[i].EdgeColor.R, debugPathData[i].EdgeColor.G, debugPathData[i].EdgeColor.B, true );

	//	if( i != 0 )
	//	{
	//		DrawDebugLine( debugPathData[i].EdgeCenter + textOffset, debugPathData[i-1].EdgeCenter + textOffset , debugPathData[i].EdgeColor.R, debugPathData[i].EdgeColor.G, debugPathData[i].EdgeColor.B, true );
	//	}
	//}
}

/*********************************************************************************************
* AICOMMANDS
********************************************************************************************* */

/** Pauses the AI for specified duration (seconds), optionally stops movement, aborts AI commands, and delays pause until
	pawn is on the ground */
function DoPauseAI( float InDuration, optional bool bStopMovement, optional bool bAbortCommands, optional bool bWaitForLanding )
{
    local vector OldVelocity;
    local bool bWasFalling;

	if( bStopMovement )
	{
        if( Pawn != none && Pawn.Physics == PHYS_Falling )
        {
            OldVelocity = Pawn.Velocity;
            bWasFalling = true;
        }

		AbortMovementCommands();
		AbortMovementPlugIns();

        // Set our old velocity if we zeroed our movement while falling (probably from being pushed by weapon physics)
        if( Pawn != none && bWasFalling )
        {
            Pawn.Velocity = OldVelocity;
        }
	}
	`AILog( GetFuncName()$"() Init AICommand_Pause Duration: "$InDuration$" Active command: "$GetActiveCommand(), 'Command_Pause'  );
	class'AICommand_Pause'.static.Pause( self, InDuration, bStopMovement );
}

/** Starts wander AICommand, with optional goal to wander toward or away from, wander duration (-1 = none), and maximum distance to wander */
function DoWander( optional actor WanderGoal, optional float WanderDuration=-1.f, optional bool bWanderAwayFromGoal, optional float MaxWanderDist=10000.f )
{
	class'AICommand_Wander'.static.BeginWander( self, WanderDuration, WanderGoal, bWanderAwayFromGoal, MaxWanderDist );
}

/** Begins Hide AICommand, hiding from HideFrom, with an optional duration to control when the command expires */
/*function DoHideFrom( actor HideFrom, optional float HideDuration, optional float HideDistance )
{
	class'AICommand_Hide'.static.HideFrom( self, HideFrom, HideDuration, HideDistance );

	`DialogManager.PlaySpotRunAwayDialog( MyKFPawn );
}*/

/* Starts Flee AICommand, with optional duration and distance */
function DoFleeFrom( actor FleeFrom,
	optional float FleeDuration,
	optional float FleeDistance,
	optional bool bShouldStopAtGoal=false,
	optional bool bFromFear=false )
{
	class'AICommand_Flee'.static.FleeFrom( self, FleeFrom, FleeDuration, FleeDistance, bShouldStopAtGoal );
}

/*
 * SetMoveGoal() - main function used to initiate NPC movement toward a goal actor
 * @param	NewMoveGoal
 * @param	NewMoveFocus		Optional focus override while moving
 * @param	bInterruptable		Whether or not this move can be interrupted
 * @param	OffsetDist			Optional offset distance from move point
 * @param	bIsValidCache		Whether routecache is currently valid
 * @param	bInCanPathfind		When false, NPC will only move if goal is directly reachable
 * @param	bForce				Forces the move regardless of interruptability
 * @param	bAllowedToAttack	Whether or not NPC is permitted to attack during this move
 * @param	bAllowPartialPath	Whether or not to allow a partial path
 */
event SetMoveGoal( Actor NewMoveGoal, optional Actor NewMoveFocus,
						optional bool bInterruptable, optional float OffsetDist,
						optional bool bIsValidCache, optional bool bInCanPathfind = true,
						optional bool bForce, optional bool bAllowedToAttack=true,
						optional bool bAllowPartialPath )
{
	// Sandbox
	if( bAlwaysAcceptPartialPaths && MyKFPawn.Physics != PHYS_Spider )
	{
		bAllowPartialPath = true;
	}

	bMoveGoalInterruptable = bInterruptable;
	MoveGoal	= NewMoveGoal;
	SetBasedPosition( MovePosition, vect(0,0,0) );
	MoveFocus	= NewMoveFocus;
	MoveOffset	= OffsetDist;
	`AILog( GetFuncName()$"() initializing AICommand_MoveToGoal"@NewMoveGoal@NewMoveFocus@bInterruptable@bAllowedToAttack, 'InitAICommand' );

	if( NewMoveGoal != None && (MoveIsInterruptable(bForce) || !bInterruptable) )
	{
		class'AICommand_MoveToGoal'.static.MoveToGoal( self, NewMoveGoal, NewMoveFocus, OffsetDist, bIsValidCache, bInCanPathfind, bAllowedToAttack, bAllowPartialPath );
	}
	else if( NewMoveGoal != none )
	{
		`AILog( GetFuncName() @"!! -- ignoring movegoal because I already have a moveaction, which is non-interruptable, and the new movegoal IS interruptable.. trumped", 'InitAICommand' );
	}
}

/**
 * SetMovePoint() - main function used to initiate NPC movement to a location
 * @param	NewMovePoint		Move to this location
 * @param	NewMoveFocus		Optional focus override while moving
 * @param	bInterruptable		Whether or not this move can be interrupted
 * @param	OffsetDist			Optional offset distance from move point
 * @param	bIsValidCache		Whether routecache is currently valid
 * @param	bAllowedToAttack	Whether or not NPC is permitted to attack during this move
 * @param	bAllowPartialPath	Whether or not to allow a partial path
 */
final event SetMovePoint( Vector NewMovePoint, optional Actor NewMoveFocus,
						 optional bool bInterruptable, optional float OffsetDist,
						 optional bool bIsValidCache, optional bool bAllowedToAttack=true,
						 optional bool bAllowPartialPath, optional bool bCanPathfind=true )
{
	`AILog( GetFuncName()$"() initializing AICommand_MoveToGoal"$NewMovePoint@NewMoveFocus@bInterruptable@bAllowedToAttack, 'InitAICommand' );

	bReachedMoveGoal = false;
	bMoveGoalInterruptable = bInterruptable;
	MoveGoal	= None;
	SetBasedPosition( MovePosition, NewMovePoint );
	MoveFocus	= NewMoveFocus;
	MoveOffset	= OffsetDist;

	if( NewMovePoint != vect(0,0,0) )
	{
		class'AICommand_MoveToGoal'.static.MoveToPoint( self, NewMovePoint, NewMoveFocus, OffsetDist, bIsValidCache, bCanPathfind, bAllowedToAttack, bAllowPartialPath );
	}
}

/**
 * SetEnemyMoveGoal() - initiates movement toward NPC's current enemy.
 * @param	bCompleteMove		When false, a partial move is acceptable
 * @param	GoalDistance		Optional offset distance (UU) from enemy
 * @param	AbandonDistance		Distance (UU) from enemy that will forcibly abort the command
 * @param	bAllowedToAttack	Whether or not NPC is permitted to attack during this move
 */
final event SetEnemyMoveGoal(   Object Observer,
								optional bool bCompleteMove,
								optional float GoalDistance=0.f,
								optional float AbandonDistance=0.f,
								optional bool bAllowedToAttack=true)
{
	`AILog( GetFuncName()$"() initializing AICommand_MoveToEnemy - setting enemy goal Dist:"@GoalDistance@"bCompleteMove?"@bCompleteMove@"bAllowedToAttack?"@bAllowedToAttack, 'InitAICommand' );

	PreMoveToEnemy();

	if( bUseNavMesh && bUsePluginsForMovement )
	{
		//MoveToEnemyRequest(Observer, AP_Logic, bAllowedToAttack, GoalDistance);
	}
	else
	{
        class'AICommand_MoveToEnemy'.static.MoveToEnemy( self, bCompleteMove, GoalDistance, AbandonDistance, bAllowedToAttack, Enemy );
	}
}

// ----------------------------------------------------------------------- //
// UBTTaskGoto methods
// ----------------------------------------------------------------------- //

/** Begin a strike attack */
function DoStrike();

function bool CanDoStrike();

/** Notification I'm about to be run into by a Zed which has bUseRunOverWarning set to true */
event RunOverWarning( KFPawn IncomingKFP, float IncomingSpeedSquared, vector RunOverPoint );

/** Triggers an evade from the PendingEvadeProjectile, if possible and it's still on target */
final function DoProjectileEvade()
{
	local byte BestDir;
	//local KFDebugLines KFDL;

	//KFDL = class'KFDebugLines'.static.GetDebugLines();
	MyKFPawn.SetHeadTrackTarget( none );
	if( MyKFPawn != none && (MyKFPawn.CanDoSpecialMove(SM_Evade) || MyKFPawn.CanDoSpecialMove(SM_Evade_Fear)) && PendingEvadeProjectile != none && !PendingEvadeProjectile.bDeleteMe &&
		!IsZero(PendingEvadeProjectile.Velocity) && CanEvade() )
	{
		BestDir = GetBestEvadeDir( PendingEvadeProjectile.Location, PendingEvadeProjectile.Instigator );
		if( BestDir != DIR_None )
		{
			DoEvade( BestDir, PendingEvadeProjectile,, 0.1f + FRand() * 0.2f, true );
		}
	}
	PendingEvadeProjectile = None;
}

/** Called just prior to setting MoveToEnemy */
function PreMoveToEnemy();

function DoEvade( byte EvadeDir, optional actor EvadeActor, optional vector DangerInstigatorLocation=vect(0,0,0), optional float Delay, optional bool bFrightened, optional bool bTurnToThreat )
{
	`AILog( GetFuncName()@EvadeDir@Pawn.Physics@Pawn.Anchor, 'Command_Evade' );
	class'AICommand_Evade'.static.Evade( self, EvadeDir, Delay, bFrightened,, DangerInstigatorLocation );
}

function DoStumble( vector Momentum, EHitZoneBodyPart HitZoneLimb )
{
	local AICommand_Attack_Melee MeleeCommand;

	// Don't stumble if we're in a panic wander state
	if( GetActiveCommand() != none && AICommand_PanicWander(GetActiveCommand()) != none )
	{
		return;
	}

	if( CommandList != None && GetActiveCommand().IsA('AICommand_Attack_Melee') )
	{
		MeleeCommand = AICommand_Attack_Melee( GetActiveCommand() );

		if( MeleeCommand != none )
		{
			`AILog( GetFuncName()$"() Aborting Melee Command", 'InitAICommand' );
			AbortCommand( MeleeCommand );
		}
	}
	`AILog( GetFuncName()$"() Aborting movement commands", 'Command_MoveToGoal' );
	AbortMovementCommands();
	AbortMovementPlugIns();

	if( CommandList == None || !GetActiveCommand().IsA( 'AICommand_Stumble' ) )
	{
		`AILog( GetFuncName()$"() Init AICommand_Stumble", 'InitAICommand' );
		class'AICommand_Stumble'.static.Stumble( self, Momentum, HitZoneLimb );
	}
}

function DoHeadlessWander()
{
	class'AICommand_HeadlessWander'.Static.HeadlessWander( self );
}

/** Launch the AICommand to send the KFAIController into the EMP Wander state */
function DoPanicWander()
{
	class'AICommand_PanicWander'.Static.PanicWander( self );
}

/** Stop doing the AICommand with the AI in the  EMP Wander state */
function EndPanicWander()
{
	local AICommand_PanicWander	CurCommand;

	if( GetActiveCommand() != None )
	{
		CurCommand = AICommand_PanicWander(GetActiveCommand());
		if( CurCommand != None )
		{
			CurCommand.EndWander(self);
		}
	}
}

event AttitudeStateChanged( name NewState ){}

/*********************************************************************************************
* StepAside
* StepAside is a potentially useful AICommand that hasn't gotten much use, but should work.
* It's similar to evading, only it's not animation-based and instead performs a latent move
* to move the NPC a few steps away in a safe direction (usually left/right).
*
* Call StepAsideFor() to start the command. ChkPawn is the pawn to step aside from. If ChkPawn
* is my own pawn, a random stepaside direction will be chosen. See GetStepAsideLocation()
* in AICommand_StepAside.
*
********************************************************************************************* */

/**	StepAsideFor() - starts the StepAside AI Command */
event bool StepAsideFor( Pawn ChkPawn, Vector HitNormal )
{
	local bool bResult, bStepAside, bDelayStep;
	local KFAIController AI;
	local bool bNoFocus;

	`AILog(GetFuncName()@ChkPawn);
	if( !bIgnoreStepAside && /*(MyKFPawn.Physics != PHYS_Spider &&*/ !MyKFPawn.IsDoingSpecialMove() )
	{
		// step aside for players
		bResult		= true;
		bStepAside	= true;

		// if we're dealing with another AI
		AI = KFAIController(ChkPawn.Controller);
		if( AI != None && (AI.StepAsideGoal == Pawn) )
		{
			`AILog("- other AI is stepping aside for us already");

			bResult = true;
			bStepAside = false;
		}

		// If we are moving (11/7 changed Velocity is zero check to InLatentExecution check)
		if( Pawn.IsSameTeam(ChkPawn) && InLatentExecution(LATENT_MOVETOWARD) && (Pawn.Velocity DOT ChkPawn.Velocity) > 0.f )
		{
			bDelayStep = ShouldDelayStepAside(ChkPawn);
			if( !bDelayStep )
			{
				`AILog( self$" - moving in the same direction as pawn we bumped" );

				bResult = true;
				bStepAside = false;
			}
		}

		if( bStepAside && StepAsideGoal != ChkPawn )
		{
			// note: don't need to abort existing instances because stepaside is set bReplaceActiveSameClassInstance=true
			if( GetActiveCommand().IsA( 'AICommand_Debug' ) )
			{
				bNoFocus = AICommand_Debug( GetActiveCommand() ).bNoFocus;
			}
			bResult = class'AICommand_StepAside'.static.StepAside( self, ChkPawn, bDelayStep, bNoFocus );
		}
	}

	return bResult;
}

/** Checks to see if a step-aside should be delayed because my pawn's moving in the same general
	direction as (or already in front of) the pawn set to be stepped aside from */
function bool ShouldDelayStepAside( Pawn GoalPawn )
{
	local float VelDotVel, GoalDotVel;
	local Vector VectToGoal, VelDir;

	if( !IsZero(Pawn.Velocity) && !IsZero(GoalPawn.Velocity) )
	{
		// If moving in the same direction as pawn we bumped
		VelDir = Normal(Pawn.Velocity);
		VelDotVel = Normal(GoalPawn.Velocity) DOT VelDir;
		if( VelDotVel > 0.3 )
		{
			// If pawn we bumped is in front of us already
			VectToGoal = Normal(GoalPawn.Location - Pawn.Location);
			GoalDotVel = VectToGoal DOT VelDir;
			if( GoalDotVel > 0 )
			{
				// Just delay movement
				return true;
			}
		}
	}

	return false;
}


/** Alerts NPC that current move has failed */
event FailedMove( optional string Reason )
{
	`AILog( "FailedMove! Reason: "$Reason, 'PathWarning' );
	`RecordAIMoveFailure(self,Pawn.Location,Pawn.Rotation,MoveGoal,"4 "$Reason);
}

/** Optionally overrides movefocus for upcoming move toward enemy */
function Actor MoveToEnemy_GetMoveFocus()
{
	if( Enemy != none )
	{
		return Enemy;
	}

	return None;
}

function float GetEstimatedGroundSpeedForMoveTimout( bool bDoingLeadinOutWalk )
{
	local float GroundSpeed;

	GroundSpeed = Pawn.GroundSpeed;

	if( MyKFPawn != none )
	{
		GroundSpeed = MyKFPawn.NormalGroundSpeed;
	}

	return GroundSpeed;
}

function float GetMoveTimeOutDuration(vector dest, bool bDoingLeadInOutWalk)
{
	local float dist;
	local float GroundSpeed;
	local float Duration;

	if( Pawn == none )
	{
		return 5.f;
	}
	else
	{
		GroundSpeed = Pawn.GroundSpeed;
	}

	if( MyKFPawn != none )
	{
		GroundSpeed = MyKFPawn.NormalGroundSpeed;
	}

	Dist = VSize( Pawn.Location - Dest );

	if( Pawn.bIsWalking || bDoingLeadInOutWalk )
	{
		GroundSpeed *= Pawn.WalkingPct;
	}
	Duration = FMax(0.5f,2.0f * (Dist / GroundSpeed));
	`AILog( GetFuncName()$"() returning "$Duration$" for dist of "$Dist, 'Command_MoveToGoal' );
	return Duration;
}

/** Determines if we can even consider sprinting */
function SetCanSprint( bool bNewSprintStatus )
{
	bCanSprint = bNewSprintStatus;

	if ( !bCanSprint || bSprintingDisabled )
	{
		MyKFPawn.bIsSprinting = false;
	}
}

/** Determines if we can't at the moment */
function SetSprintingDisabled( bool bNewSprintStatus )
{
	bSprintingDisabled = bNewSprintStatus;

	if ( MyKFPawn != none && (!bCanSprint || bSprintingDisabled) )
	{
		MyKFPawn.bIsSprinting = false;
	}
}

/** Determines if we can sprint when damaged */
function SetCanSprintWhenDamaged( bool bNewSprintDamagedStatus )
{
	bCanSprintWhenDamaged = bNewSprintDamagedStatus;

	if ( (!bCanSprint && !bCanSprintWhenDamaged) || bSprintingDisabled )
	{
		MyKFPawn.bIsSprinting = false;
	}
}

function bool CanSetSprinting( bool bNewSprintStatus )
{
	if ( bNewSprintStatus && ( (!bCanSprint && !bCanSprintWhenDamaged) || bSprintingDisabled) )
	{
	 	return false;
	}

	return true;
}

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting. This is often
	overridden in child classes */
function bool ShouldSprint()
{
	local float DistToEnemy;
	local name AttackTag;

	if( MyKFPawn != none && MyKFPawn.IsAliveAndWell() && Enemy != none && Enemy.IsAliveAndWell() )
	{
		// Don't allow sprinting when blocking attacks
		if( MyKFPawn.IsDoingSpecialMove(SM_Block) )
		{
			return false;
		}

		// Sprint if we've reached the frustration threshold
		if ( IsFrustrated() )
		{
			return true;
		}

		if( SprintWithinEnemyRange.X > 0.f && SprintWithinEnemyRange.Y > 0.f )
		{
			DistToEnemy = VSize( Enemy.Location - Pawn.Location );

			if( DistToEnemy > SprintWithinEnemyRange.X && DistToEnemy < SprintWithinEnemyRange.Y )
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
			return false;  // Old bug undiscovered until now (6.17.14), keep an eye on npcs no longer sprinting when they should
		}
	}

	if( MyKFPawn == none || Enemy == none /*|| !bDirectMoveToGoal*/ )
	{
		return false;
	}

	if( Enemy.Velocity dot ( Pawn.Location - Enemy.Location ) < 0.f )
	{
		//if( !InMeleeRange( Enemy.Location ) )
		if( !MyKFPawn.InAnyAttackTagRange(Enemy.Location, AttackTag) )
		{
			return true;
		}
	}
	else if( !MyKFPawn.InAnyAttackTagRange(Enemy.Location, AttackTag) && VSize( Pawn.Location - Enemy.Location ) > 300.f )
	{
		return true;
	}

	if( VSize( Enemy.Location - Pawn.Location ) <= 512.f )
	{
		return false;
	}

	return false;
}

/**
 * Update sprint settings based on Frustration
 */
function UpdateSprintFrustration( optional byte bForceFrustrationState=255 )
{
	if( FrustrationThreshold > 0 )
	{
		if( bForceFrustrationState == 1 || (IsFrustrated() && bForceFrustrationState != 0) )
		{
			bCanSprint = true;
		}
		else
		{
			// can't use true default as it's modified by difficulty
			bCanSprint = bDefaultCanSprint;
		}
	}
}

function bool IsFrustrated()
{
	// Forced frustration, controlled by AI director
	if( MyAIDirector.bForceFrustration )
	{
		return true;
	}

	// Forced frustration, controlled by individual AI
	if( bForceFrustration )
	{
		return true;
	}

	if( FrustrationThreshold > 0 && MyKFGameInfo.MyKFGRI != None && MyKFGameInfo.MyKFGRI.AIRemaining <= FrustrationThreshold )
	{
		if( LastFrustrationCheckTime == 0 )
		{
			LastFrustrationCheckTime = WorldInfo.TimeSeconds;
		}

		if( `TimeSince(LastFrustrationCheckTime) >= FrustrationDelay )
		{
			return true;
		}
	}

	return false;
}

/*---------------------------------------------------------
  Pathfinding events and related notifications
---------------------------------------------------------*/

/** Notification from AICommand::Popped that it has completed */
function NotifyCommandFinished( AICommand FinishedCommand );

/** Notification from the flee command that the flee completed successfully (was not interrupted) */
function NotifyFleeFinished( optional bool bAcquireNewEnemy=true );

/** Notification from the move command that we've arrived at an intermediate destination */
function NotifyReachedLatentMoveGoal();

event NotifyLatentPostPhysWalking()
{
	if( CachedAICommandList != none )
	{
		/** Let the current AICommand, if any, handle this. */
		CachedAICommandList.NotifyLatentPostPhysWalking();
	}
}

`if(`__TW_PATHFINDING_)
event NotifyFailMove( string Reason )
{
	//`RecordAIMoveFailure(self,Pawn.Location,Pawn.Rotation,MoveGoal,"5 "$Reason);
	//      if( GetActiveKFCommand() != none )
	//      {
	//           //GetActiveKFCommand().UpdateHistoryString( "[NotifyFailMove: "$Reason$"]" );
	//      }
	`AILog( "NotifyFailMove, Reason: "$Reason, 'PathWarning' );
}
`endif //__TW_PATHFINDING_

/** Notification from gameinfo that paths have changed */
event NotifyPathChanged()
{
	`AILog( GetFuncName()$"() Command: "$GetActiveCommand(), 'PathWarning' );
}


/** Returns true if the actor is currently directly reachable */
function bool IsValidDirectMoveGoal( Actor A )
{
// 	if( Pawn(A) != none && !FastTrace(A.Location, Pawn.Location, Pawn.GetCollisionExtent()) )
// 	{
// 		return false;
// 	}
	if( ActorReachable(A) )
	{
		return true;
	}
	return false;
}

final function SetFailedPathToEnemy( Pawn TestEnemy, optional float Offset )
{
	`RecordAIMoveFailure(self,Pawn.Location,Pawn.Rotation,MoveGoal,"7 SetFailedpathToEnemy");
	`AILog( GetFuncName()$"() TestEnemy: "$TestEnemy$" Offset: "$Offset, 'PathWarning' );

	// Below might come in handy, but haven't tested it enough.
// 	if( Pawn.Anchor != none )
// 	{
// 		`AILog( GetFuncName()$"() calling InvalidateAnchor (Anchor: "$Pawn.Anchor$")", 'PathWarning' );
// 		//InvalidateAnchor( Pawn.Anchor );
// 	}
}

/** Used by pathfinding code to allow NPC to detour to special navigation points (pickups, etc.) */
event bool AllowDetourTo( NavigationPoint N )
{
	return true;
}

/** Forces NPC to re-evaluate in-progress move, to see if the goal is now directly reachable, otherwise
	the pawn will need pathfind to the goal. */
event FindDirectPath()
{
	if( CachedAICommandList != none )
	{
		/** Let the current AICommand, if any, handle this. */
		CachedAICommandList.FindDirectPath();
	}

	SetDirectPathCheckTime();
}

/** Alert from movement code that path is blocked by an actor which has its bBlocksNavigation flag set to true.
	Note that if ShouldIgnoreNavigationBlockingFor() returns true for BlockedBy, this event will not be called.
	See UReachSpec::PrepareForMove() */
event bool HandlePathObstruction( Actor BlockedBy )
{
//	local Pawn BlockPawn;
	local bool bResult;

	if( LastObstructionTime == 0.f || `TimeSince(LastObstructionTime) > 0.7f )
	{
		LastObstructionTime = WorldInfo.TimeSeconds;
		`AILog( GetFuncName()@BlockedBy@`TimeSince(LastObstructionTime), 'HandlePathObstruction' );
		// Let the current AICommand deal with the obstruction.
		if( CachedAICommandList != None )
		{
			bResult = CommandList.HandlePathObstruction( BlockedBy );
		}
	}
	return bResult;
}

function bool HandleZedBlockedPath();

event FailMove( string Reason )
{
	//`RecordAIMoveFailure(self,Pawn.Location,Pawn.Rotation,MoveGoal,Reason);
	`AILog( GetFuncName()$"() REASON: "$Reason, 'PathWarning' );
}

/** Event from latent movement code notifying that current move goal is not reachable */
event MoveUnreachable( Vector AttemptedDest, Actor AttemptedTarget )
{
	`AILog( GetFuncName()$"()"$AttemptedDest@AttemptedTarget, 'PathWarning' );

	if( CachedAICommandList != None )
	{
		CachedAICommandList.MoveUnreachable( AttemptedDest, AttemptedTarget );
	}

	if( KfMovementPlugin != none )
	{
		KfMovementPlugin.MoveUnreachable( AttemptedDest, AttemptedTarget );
	}
}

/** Will cause AI to briefly pause and sets ReevaluatePath to true so if the AI is moving it will re-path */
event ForcePauseAndRepath( optional Actor InInstigator )
{
	//`Log( GetFuncName()@InInstigator );
	bReevaluatePath = true;
	NotifyNeedRepath();
	class'AICommand_Pause'.static.Pause( self, 0.25f + FRand() );
}

/** Notification that any existing pathing should be checked and rebuilt */
function NotifyNeedRepath()
{
	`AILog( GetFuncName()$"()", 'PathWarning' );
	if( CachedAICommandList != None )
	{
		CachedAICommandList.NotifyNeedRepath();
	}
}

/*---------------------------------------------------------
  Anchor handling
---------------------------------------------------------*/

/** Invalidates pawn's current anchor, making it unusable by pawn for a brief duration and sets current
	anchor to none, forcing the pawn to find a new valid anchor on next pathfind attempt (with the
	expectation that the newly invalidated anchor will be skipped since it's in the invalid anchor list */
final function InvalidateAnchor( NavigationPoint Nav )
{
	local int Idx;

	Idx = InvalidAnchorList.Find( 'InvalidNav', Nav );
	`AILog( GetFuncName()@Nav@Idx, 'PathWarning' );
	if( Idx < 0 )
	{
		Idx								   = InvalidAnchorList.Length;
		InvalidAnchorList.Length		   = Idx + 1;
		InvalidAnchorList[Idx].InvalidNav  = Nav;
		InvalidAnchorList[Idx].InvalidTime = WorldInfo.TimeSeconds;
		`AILog( GetFuncName()$" Invalidating anchor ("$Nav$") - setting anchor to NONE", 'PathWarning' );
		// Clear the old anchor so we need to get a new one
		Pawn.SetAnchor( none );
	}
}

final function NavigationPoint GetFallbackAnchor()
{
	local NavigationPoint LastAnchor, ResultAnchor;
	local float AnchorDist;

	`AILog( GetFuncName()$"() trying to get fallback anchor", 'PathWarning' );
	// block the current anchor if possible to prevent it from being reacquired as an anchor
	if (Pawn.Anchor != None && !Pawn.Anchor.bBlocked)
	{
		`AILog( GetFuncName()$"() setting Pawn anchor ("$Pawn.Anchor$") to bBlocked to true!", 'PathWarning' );
		LastAnchor = Pawn.Anchor;
		LastAnchor.bBlocked = true;
	}
	// look for the nearest anchor
	ResultAnchor = Pawn.GetBestAnchor(  Pawn,Pawn.Location, true, true, AnchorDist );
	// unblock the last anchor
	if (LastAnchor != None)
	{
		LastAnchor.bBlocked = false;
		if (LastAnchor == ResultAnchor)
		{
			`AILog( "ERROR! LastAnchor == ResultAnchor", 'PathWarning' );
		}
	}
	if (ResultAnchor == None)
	{
		FailedToFindFallbackAnchor();
	}
	return ResultAnchor;
}

final function FailedToFindFallbackAnchor()
{
	`AILog( self$" FailedToFindFallbackAnchor!", 'PathWarning' );
	// Haven't actually gotten a pawn yet
	if( Pawn == None )
		return;
}


/** Returns true if Nav is found in the RouteCache (i.e, is it part of NPC's current path) */
function bool IsNavInRouteCache( NavigationPoint Nav )
{
	local int i;

	for( i = 0; i < RouteCache.Length; i++ )
	{
		if( RouteCache[i] == Nav )
		{
			return true;
		}
	}

	return false;
}

/**
 * Event called when specific navigation points (with bProbeNotifyOnAddToRouteCache true) are
 * added to this controller's route cache.
 */
event NotifyOnAddToRouteCache( NavigationPoint Nav ) {}

/*********************************************************************************************
* FALLING, PHYS_FALLING
********************************************************************************************* */

// Called when NPC reaches a ledge, setting bCanJump to true here will allow NPC to continue move despite pending fall
event MayFall( bool bFloor, vector FloorNormal )
{
	`AILog( "MayFall Event! bFloor: "$bFloor$" Phys: "$Pawn.Physics$" MoveTarget: "$MoveTarget$" Reachable: "$ActorReachable(Enemy), 'Falling' );

	if( !bPlannedJump )
	{
		//msg( "MayFall Event! bFloor: "$bFloor$" Phys: "$Pawn.Physics$" MoveTarget: "$MoveTarget$" Reachable: "$ActorReachable(Enemy)  );
		Pawn.JumpZ = 100.f;
	}
	else
	{
		Pawn.JumpZ = Pawn.Default.JumpZ;
	}
	Pawn.bCanJump = true;
}

/** NPC has attempted to jump over an obstruction after bumping into it */
event JumpedOverWall( vector WallHitNormal, optional actor Wall )
{
	`AiLog(GetFuncName() @ " WallHitNormal: " @ WallHitNormal @ " Wall: " @Wall );
    /* Below untested - enable to lower jump over wall frequency */
	//MyKFPawn.bCanJumpOverWalls = false;
	//SetTimer( 2.f * FRand() + 0.25f, false, nameof(Timer_EnableJumpOverWalls), self );
	`RecordAIWall( `StatID(AI_JUMPOVERWALL), self, Pawn.Location, Pawn.Rotation, Wall, "HN: "$string(WallHitNormal) );
}

/** Re-Enables pawn's ability to jump over obstructions */
function Timer_EnableJumpOverWalls()
{
	MyKFPawn.bCanJumpOverWalls = true;
}

function Vector GetDropEdgeLeapVelocity()
{
	return DropEdgeLeapVelocity;// Vect( 200.0f,0.0f, 20.0f );
}

/*********************************************************************************************
* Sight/Hearing/Bump
********************************************************************************************* */

function RecordLeapToWall()
{
	//`RecordAILeapToWall( self, Pawn.Location, Pawn.Rotation, "Base: "$Pawn.Base );
}

function RecordHitWall( actor Wall )
{
	//`RecordAIHitWall( self, Pawn.Location, Pawn.Rotation, Wall, "SS: "$MyKFPawn.IsUsingSuperSpeed()$" WallGeo:"$Wall.bWorldGeometry$" Crawlable:"$Wall.bCrawlable );
}

function bool NotifyBaseChange( actor NewBase, vector NewFloor )
{
	if( CachedAICommandList != none )// && Enemy == Seen )
	{
		if( CachedAICommandList.NotifyBaseChange( NewBase, NewFloor ) )
		{
			return true;
		}
	}

	return false;
}

/** Notification from ProcessLanded() that pawn has stopped falling */
event bool NotifyLanded( vector HitNormal, Actor FloorActor )
{

	`AILog( GetFuncName() $  " - HitNormal: " $ HitNormal $ " - FloorActor: " $ FloorActor, 'LandedEvent' );

	if( MyKFPawn != none )
	{
        MyKFPawn.BaseEyeHeight = MyKFPawn.default.BaseEyeHeight;

		// Reset JumpZ (might not be necessary anymore)
		Pawn.JumpZ		= Pawn.Default.JumpZ;

		// If movement AI is not active, reset acceleration to zero to prevent sliding
		if( bPreparingMove )
		{
			Pawn.Acceleration = vect(0,0,0);
    }
    }

	bPlannedJump	= false;
	// Reset NotifyJumpApex event notification, turned off by PHYS_Falling
	bNotifyApex		= Default.bNotifyApex;

	if( CachedAICommandList != none )// && Enemy == Seen )
	{
		//`AILog( "NotifyLanded: "$FloorActor$" - while I'm moving to goal, notifying "$CommandList$" and letting it handle this event", 'NotifyLanded' );
		return CachedAICommandList.NotifyLanded( HitNormal, FloorActor );
	}

	return super.NotifyLanded( HitNormal, FloorActor );
}

/** Notification that my current enemy is surrounded by other Zeds */
event bool EnemyIsSurrounded()
{
	`AILog( "EnemyIsSurrounded! ("$Enemy$")", 'EnemyStatus' );

	if( CachedAICommandList != none )// && Enemy == Seen )
	{
		//`AILog( "EnemyIsSurrounded", 'Command_MoveToEnemy' );
		return CachedAICommandList.EnemyIsSurrounded();
	}
	return false;
}

/** Notification that a Husk is going to commit suicide, providing chance to move away */
function bool NotifyHuskSuicide( KFPawn_Monster Husk )
{
	return false; // Temp disabled

	if( CachedAICommandList != none )// && Enemy == Seen )
	{
		if( CachedAICommandList.NotifyHuskSuicide( Husk ) )
		{
			return true;
		}
	}

	if( !IgnoreNotifies() )
	{
	//	class'AICommand_Hide'.static.HideFrom( self, Husk,, false );
	//	class'AICommand_Scatter'.static.ScatterFrom( self, Husk,, true );
	}
	return false;
}

/*********************************************************************************************
* HitWall Handling
* NotifyHitWall is enabled by default. Note that if the pawn's bDirectHitWall flag is true,
* this will be bypassed and the pawn's HitWall event will be called directly.
********************************************************************************************* */

/** Timer which re-enables SeePlayer event polling */
final function EnableNotifyHitWall()
{
	`AILog( GetFuncName()$"() Enabling NotifyHitWall event", 'HitWall' );
	Enable( 'NotifyHitWall' );
}

/** Disable this NPC's SeePlayer polling for DisabledTime seconds */
final function DisableNotifyHitWall( optional float DisabledTime=0.2f )
{
	//`AILog( GetFuncName()$"() disabling NotifyHitWall for "$DisabledTime$" seconds", 'HitWall' );
	Disable( 'NotifyHitWall' );
	if( DisabledTime > 0.f )
	{
		SetTimer( DisabledTime, false, nameof(EnableNotifyHitWall) );
	}
}

/** Notification that I've run into a wall. If the pawn's bDirectHitWall flag is true, this will be bypassed and
	the pawn's HitWall() event will be called directly.  */
event bool NotifyHitWall( vector HitNormal, actor Wall )
{
	local KFDestructibleActor KFDA;
	local bool bEmerging;

	LastWallHitNormal       = HitNormal;
	LastHitWall             = Wall;
	LastNotifyHitWallTime   = WorldInfo.TimeSeconds;

	`AiLog( GetFuncName() @ " Wall: " @ Wall @ " HitNormal: " @ HitNormal );

	if( MyKFPawn != none && MyKFPawn.IsDoingSpecialMove(SM_Emerge) )
	{
		bEmerging = true;
	}

	if( !Wall.bStatic && Wall.bCollideActors && Wall.bCanBeDamaged )
	{
		KFDA = KFDestructibleActor( Wall );
		if( KFDA != none )
		{
			MyKFPawn.HandleDestructibleBump( KFDA, HitNormal );

			if( bEmerging )
			{
				return true;
			}

			if( ActorEnemy != KFDA
				&& KFDA.bBlockActors
				&& !MyKFPawn.IsDoingSpecialMove()
				&& (LastDestructibleBumpTime == 0.f || `TimeSince(LastDestructibleBumpTime) > 1.f)
				&& CanAttackDestructibles()
				&& KFDA.HasAnyHealth()
				&& !GetActiveCommand().IsA('AICommand_Melee') )
			{
				// FOV test
				if( vector(MyKFPawn.Rotation) dot Normal(KFDA.Location - MyKFPawn.Location) >= 0.67f )
				{
					AIZeroMovementVariables();
					NotifyAttackActor( Wall );
				}
			}

			LastDestructibleBumpTime = WorldInfo.TimeSeconds;
		}
	}

	/** I shouldn't be colliding if I'm emerging, so ignore notification but return true to prevent move adjusting in native code */
	if( bEmerging )
	{
		return true;
	}

	/** Return whatever the current AICommand wants me to */
	if( CachedAICommandList != none )
	{
		return CachedAICommandList.NotifyHitWall( HitNormal, Wall );
	}
	else
	{
		DisableNotifyHitWall(0.2f);
	}
	return Super.NotifyHitWall( HitNormal, Wall );
}

/** Pawn has bumped into a wall while falling - unusual given KF2 NPCs have very little air control */
event NotifyFallingHitWall( vector HitNormal, actor Wall )
{
	if( CachedAICommandList != none )
	{
		`AILog( "NotifyFallingHitWall: "$Wall$" - while I'm moving to goal, notifying "$CommandList$" and letting it handle this event", 'HitWall' );
		CachedAICommandList.NotifyFallingHitWall( HitNormal, Wall );
	}
}

/*********************************************************************************************
* SEEPLAYER
* KF2 NPCs do not heavily rely on SeePlayer() and EnemyNotVisible(), since the NPCs are
* omniscient when it comes to choosing an enemy. If the NPCs were to begin in a state where
* they randomly wander about, they would then need to rely more on these events.
* Currently they are used for some miscellaneous things, like using SeePlayer() when
* attacking a door and using that notification to stop attacking the door and target the
* newly spotted enemy instead.
********************************************************************************************* */

/** Timer which re-enables SeePlayer event polling */
final event EnableSeePlayer()
{
	`AILog( GetFuncName()$"() Enabling SeePlayer event", 'SeePlayer' );
	if( !bHasDebugCommand )
	{
		Enable( 'SeePlayer' );
	}
}

/** Disable this NPC's SeePlayer polling for DisabledTime seconds */
final event DisableSeePlayer( optional float DisabledTime )
{
	`AILog( GetFuncName()$"() disabling SeePlayer polling for "$DisabledTime$" seconds", 'SeePlayer' );
	Disable( 'SeePlayer' );
	if( DisabledTime > 0.f )
	{
		SetTimer( DisabledTime, false, nameof(EnableSeePlayer) );
	}
}

/** Timer which re-enables SeePlayer event polling */
final event EnableEnemyNotVisible()
{
	`AILog( GetFuncName()$"() Enabling EnemyNotVisible event", 'EnemyNotVisible' );
	Enable( 'EnemyNotVisible' );
}

/** Disable this NPC's SeePlayer polling for DisabledTime seconds */
final event DisableEnemyNotVisible( optional float DisabledTime=2.f )
{
	`AILog( GetFuncName()$"() disabling EnemyNotVisible polling for "$DisabledTime$" seconds", 'EnemyNotVisible' );
	Disable( 'EnemyNotVisible' );
	if( DisabledTime > 0.f )
	{
		SetTimer( DisabledTime, false, nameof(EnableEnemyNotVisible) );
	}
}


function bool IsPawnVisibleViaTrace( Pawn PawnToCheck, optional bool bUsePawnRotation )
{
	local Vector TestLocation;
	local Rotator Rot;

	Rot = Pawn.Rotation;
	TestLocation = PawnToCheck.GetPawnViewLocation();
	if( !bUsePawnRotation )
	{
		Rot = Rotator( PawnToCheck.Location - Pawn.Location );
	}

	return CanSeeByPoints( Pawn.Location, TestLocation, Rot );
}

/*********************************************************************************************
* HEARING
* Use MakeNoise() to simulate noise for NPCs to "hear."
********************************************************************************************* */

/** Timer which re-enables HearNoise event polling. */
final event EnableHearNoise()
{
	Enable( 'HearNoise' );
	`AILog( GetFuncName()$"() Enabled HearNoise event", 'HearNoise' );
}

/** Disable this NPC's hearing for DisabledTime seconds */
final event DisableHearNoise( optional float DisabledTime=1.f )
{
	if( DisabledTime <= 0.f )
	{
		DisabledTime = 1.f + FRand();
	}

	`AILog( GetFuncName()$"() disabling noise hearing for "$DisabledTime$" seconds", 'HearNoise' );
	Disable( 'HearNoise' );
	SetTimer( DisabledTime, false, nameof(EnableHearNoise) );
}

/*********************************************************************************************
* BUMP HANDLING
********************************************************************************************* */

/** Records bump related gameplay event */
function RecordBump( actor Other )
{
	`RecordAIBump( `StatID(AI_BUMP), self, Pawn.Location, Pawn.Rotation, Other, "SSpeed: "$MyKFPawn.IsUsingSuperSpeed() );
}

/** Timer which re-enables Bump event polling */
final event EnableBump()
{
	`AILog( GetFuncName()$" Enabling Bump Events" , 'BumpEvent' );
	Enable( 'NotifyBump' );
}

/** Disable this NPC's Bump event polling for DisabledTime seconds */
final event DisableBump( optional float DisabledTime=0.5f )
{
	DisabledTime = FMax(0.1f,DisabledTime);

	`AILog( GetFuncName()$"() disabling Bump polling for "$DisabledTime$" seconds", 'BumpEvent' );
	Disable( 'NotifyBump' );
	if( DisabledTime > 0.f )
	{
		SetTimer( DisabledTime, false, nameof(EnableBump) );
	}
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	`AILog( GetFuncName()$" - Other: "$Other$" OtherComp"$OtherComp$" - HitLocation: " $ HitLocation $ " - HitNormal: " $ HitNormal, 'TouchEvent' );

	if( CachedAICommandList != none )
	{
		CachedAICommandList.NotifyTouch( Other, OtherComp, HitLocation, HitNormal);
	}

	if( KfMovementPlugin != none )
	{
		//KfMovementPlugin.NotifyTouch( Other, OtherComp, HitLocation, HitNormal);
	}

	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

/** Override is currently only used if bSpecialBumpHandling is true in .ini file */
simulated function Tick( FLOAT DeltaTime )
{
	Super.Tick(DeltaTime);

	if (GetIsInZedVictoryState())
	{
		return;
	}

	if( bSpecialBumpHandling && Role == ROLE_Authority && MyKFPawn != None && MyKFPawn.Health >= 0 && !MyKFPawn.IsDoingSpecialMove() )
	{
		SpecialBumpHandling(DeltaTime);
	}

    // Regularly check to see if this zed is stuck
    if( Role == ROLE_Authority && MyKFPawn != none && MyKFPawn.Health > 0 && ((`TimeSince(LastStuckCheckTime) > StuckCheckInterval
        && !MyKFPawn.IsDoingSpecialMove()) || (MyKFPawn.Physics == PHYS_Falling && MyKFPawn.Velocity.Z == 0))  )
    {
        EvaluateStuckPossibility(DeltaTime);
    }

    // Regularly check to see if this AI can teleport closer to the enemy
    if( bCanTeleportCloser && PendingDoor == none && Role == ROLE_Authority && MyKFPawn != none && MyKFGameInfo.MyKFGRI != None
    	&& MyKFPawn.Health > 0 && `TimeSince(LastTeleportCheckTime) > TeleportCheckInterval && !MyKFPawn.IsDoingSpecialMove()
    	&& MyKFGameInfo.MyKFGRI.AIRemaining >= AIRemainingTeleportThreshold )
    {
        EvaluateTeleportPossibility(DeltaTime);
    }
}

function EvaluateTeleportPossibility(float DeltaTime)
{
    LastTeleportCheckTime = WorldInfo.TimeSeconds;

    // Teleport if we have an enemy and we're superspeeding and we haven't teleported in a while
    if( Enemy != none && MyKFPawn != none && MyKFPawn.IsUsingSuperSpeed() )
    {
        if( `TimeSince(MyKFPawn.LastLOSOrRelevantTime) > HiddenRelocateTeleportThreshold
            && `TimeSince(LastTeleportTime) > TeleportCooldown
            && `TimeSince(MyKFPawn.SpawnTime) > PostSpawnRelocateTeleportCooldown)
        {
            RelocateTeleport();
        }
    }
}

/** Evaluate if this zed might be getting stuck, and then call functions to handle it */
function EvaluateStuckPossibility(float DeltaTime)
{
    local float DistToEnemySquared;
    local vector OldStuckCheckLocation;
    local bool bSeenRecently;
    local int i;

    LastStuckCheckTime = WorldInfo.TimeSeconds;
    OldStuckCheckLocation = LastStuckCheckLocation;
    LastStuckCheckLocation = Pawn.Location;

    // Special big hack here. This fixes the bug where zeds would get stuck
    // floating in air unable to move. Someday perhaps we'll track down the
    // source of that issue and won't need this code - Ramm
    if( MyKFPawn.Physics == PHYS_Falling && MyKFPawn.Velocity.Z == 0 )
    {
        //`log(self@GetFuncName()$" falling with no Z velocity!!!");
        FallingStuckNoZVelocityTime += DeltaTime;
        MyKFPawn.Velocity = MyKFPawn.GroundSpeed * Normal(GetDestinationPosition() - MyKFPawn.Location);
        MyKFPawn.Acceleration = MyKFPawn.AccelRate * Normal(GetDestinationPosition() - MyKFPawn.Location);

        // Continue on and try and get unstuck if this time is greather than the
        // StuckCheckInterval, otherwise just return out and see if the hack will
        // get us unstuck!
        if( FallingStuckNoZVelocityTime < StuckCheckInterval )
        {
            return;
        }
    }
    else
    {
        FallingStuckNoZVelocityTime = 0;
    }

	if( `TimeSince(LastDamageTime_Taken) < 5.0 )
	{
		StuckPossiblity = 0;
		bTryingToGetUnstuck = false;
		return;
	}

    // Don't check stuck if we recently melee'd
    if( `TimeSince(LastAttackTime_Melee) < 5.0 )
    {
        StuckPossiblity=0;
        bTryingToGetUnstuck=false;
        return;
    }

    // Don't check stuck if we just teleported
    if( `TimeSince(LastTeleportTime) < 5.0 )
    {
        StuckPossiblity=0;
        bTryingToGetUnstuck=false;
        return;
    }

    if( `TimeSince(LastSpecialMoveEndTime) < 5.0 )
    {
        StuckPossiblity=0;
        bTryingToGetUnstuck=false;
        return;
    }

    bSeenRecently = !MyKFPawn.IsUsingSuperSpeed();

    // Don't do any stuck checking if we're close to an enemy
    if( Enemy != none )
    {
        DistToEnemySquared = VSizeSq(Enemy.Location - Pawn.Location);

        // Modified to only allow it to bypass the rest of the stuck checks for 5 seconds
        // if we are down to only a few zeds. Would never run HandleStuck() on stuck zeds
        // if any players were too close to them.
        if( DistToEnemySquared < StuckCheckEnemyDistThreshholdSquared )
        {
        	if( MyKFGameInfo.MyKFGRI.AIRemaining > 5 || TotalStuckCheckCloseRangeTime < 5.0f )
        	{
		        if( LastStuckCheckCloseRangeTime > 0.f )
                {
		        	TotalStuckCheckCloseRangeTime += `TimeSince(LastStuckCheckCloseRangeTime);
		        }
		        LastStuckCheckCloseRangeTime = WorldInfo.TimeSeconds;

                StuckPossiblity=0;
                bTryingToGetUnstuck=false;
                return;
            }
        }
        else
        {
			TotalStuckCheckCloseRangeTime = 0.f;
			LastStuckCheckCloseRangeTime = 0.f;
        }
    }

	// Don't check stuck if we're line of site pathing to the enemy
    if( Enemy != none && MoveTarget == Enemy && RouteCache.Length <= 0 )
	{
        //`log(self@GetFuncName()$"I'm on final approach to enemy, just keep going");
        StuckPossiblity=0;
        bTryingToGetUnstuck=false;
        return;
	}

	// Don't check stuck if we're waiting outside a welded door while it's being beaten down
    for ( i=0; i<RouteCache.Length; i++ )
	{
		if ( RouteCache[i] != None )
		{
            if( KFDoorMarker(RouteCache[i]) != none && KFDoorMarker(RouteCache[i]).MyKFDoor.WeldedShut()
                && VSizeSq2d(RouteCache[i].Location - Pawn.Location) < 1000000 ) // 10 Meters
            {
                //`log(self@GetFuncName()$"I'm trying to pass through a welded door. Just chill here");
                StuckPossiblity=0;
                bTryingToGetUnstuck=false;
                return;
            }
		}
	}

    // See if the zed isn't moving around in the XY plane while walking
    if( MyKFPawn.Physics != PHYS_Falling && VSizeSq2d(MyKFPawn.Velocity) < StuckVelocityThreshholdSquared )
    {
        if( !IsZero(OldStuckCheckLocation) )
        {
            //`log(self$" XY Move since last check: "$VSizeSq2d(Pawn.Location - OldStuckCheckLocation)$" XYMoveStuckThresholdSquared "$XYMoveStuckThresholdSquared);
            if( VSizeSq2d(Pawn.Location - OldStuckCheckLocation) > XYMoveStuckThresholdSquared )
            {
                StuckPossiblity=0;
                bTryingToGetUnstuck=false;
                return;
            }
        }
        else
        {
            StuckPossiblity=0;
            bTryingToGetUnstuck=false;
            return;
        }

        StuckPossiblity += 0.5;

        if( StuckPossiblity > StuckPossiblityThreshhold )
        {
            //`log(self$" thinks he's stuck!!!!!!!!!!!!!!!!! StuckPossiblity: "$StuckPossiblity$" 2d Velocity "$VSize2d(MyKFPawn.Velocity)$" Physics: "$Pawn.GetPhysicsName());
            //`log(self$" MoveTarget: "$GetItemName(String(MoveTarget))$" MoveTimer: "$MoveTimer$" RouteGoal: "$GetItemName(string(RouteGoal))$" RouteDist: "$RouteDist$" bPreparingMove: "$bPreparingMove);
            StuckPossiblity=0;
            HandleStuck();

         	DumpCommandStack();
            DumpCommandHistory();
        }
        else
        {
            //`log(self$" thinks he's getting stuck!!!!!!!!!!!!!!!!! StuckPossiblity: "$StuckPossiblity$" 2d Velocity "$VSize2d(MyKFPawn.Velocity)$" Physics: "$Pawn.GetPhysicsName());
            //`log(self$" MoveTarget: "$GetItemName(String(MoveTarget))$" MoveTimer: "$MoveTimer$" RouteGoal: "$GetItemName(string(RouteGoal))$" RouteDist: "$RouteDist$" bPreparingMove: "$bPreparingMove);
        }
    }
    // See if the zed is stuck while falling
    else if( MyKFPawn.Physics == PHYS_Falling )
    {
        // Check if jumping up and down in the same place
        if( MyKFPawn.Velocity.Z != 0 )
        {
            if( !IsZero(OldStuckCheckLocation) )
            {
                //`log(self$" XY Move since last check: "$VSizeSq2d(Pawn.Location - OldStuckCheckLocation)$" XYMoveStuckThresholdSquared "$XYMoveStuckThresholdSquared);
                if( VSizeSq2d(Pawn.Location - OldStuckCheckLocation) < XYMoveStuckThresholdSquared )
                {
                    if( bSeenRecently )
                    {
                        StuckPossiblity += 1.0;
                    }
                    else
                    {
                        StuckPossiblity += 0.5;
                    }

                    if( StuckPossiblity > StuckPossiblityThreshhold )
                    {
                        //`log(self$" is falling stuck because of XY!!!!!!!!!!!!!!!!! StuckPossiblity: "$StuckPossiblity$" Falling Velocity "$MyKFPawn.Velocity.Z$" Physics: "$Pawn.GetPhysicsName());
                        //`log(self$" MoveTarget: "$GetItemName(String(MoveTarget))$" MoveTimer: "$MoveTimer$" RouteGoal: "$GetItemName(string(RouteGoal))$" RouteDist: "$RouteDist$" bPreparingMove: "$bPreparingMove);
                        StuckPossiblity=0;
                        HandleStuck();
                    }
                    else
                    {
                        //`log(self$" thinks he's falling stuck because of XY!!!!!!!!!!!!!!!!! StuckPossiblity: "$StuckPossiblity$" Falling Velocity "$MyKFPawn.Velocity.Z$" Physics: "$Pawn.GetPhysicsName());
                        //`log(self$" MoveTarget: "$GetItemName(String(MoveTarget))$" MoveTimer: "$MoveTimer$" RouteGoal: "$GetItemName(string(RouteGoal))$" RouteDist: "$RouteDist$" bPreparingMove: "$bPreparingMove);
                    }
                }
            }
            else
            {
                StuckPossiblity=0;
                bTryingToGetUnstuck=false;
                return;
            }
        }
        // Falling, but no velocity so possibly stuck in place
        else
        {
            if( bSeenRecently )
            {
                StuckPossiblity += 2.0;
            }
            else
            {
                StuckPossiblity += 1.0;
            }

            if( StuckPossiblity > StuckPossiblityThreshhold )
            {
                //`log(self$" is falling stuck!!!!!!!!!!!!!!!!! StuckPossiblity: "$StuckPossiblity$" Falling Velocity "$MyKFPawn.Velocity.Z$" Physics: "$Pawn.GetPhysicsName());
                //`log(self$" MoveTarget: "$GetItemName(String(MoveTarget))$" MoveTimer: "$MoveTimer$" RouteGoal: "$GetItemName(string(RouteGoal))$" RouteDist: "$RouteDist$" bPreparingMove: "$bPreparingMove);
                StuckPossiblity=0;
                HandleStuck();
            }
            else
            {
                //`log(self$" thinks he's falling stuck!!!!!!!!!!!!!!!!! StuckPossiblity: "$StuckPossiblity$" Falling Velocity "$MyKFPawn.Velocity.Z$" Physics: "$Pawn.GetPhysicsName());
                //`log(self$" MoveTarget: "$GetItemName(String(MoveTarget))$" MoveTimer: "$MoveTimer$" RouteGoal: "$GetItemName(string(RouteGoal))$" RouteDist: "$RouteDist$" bPreparingMove: "$bPreparingMove);
            }
        }
    }
    else
    {
        StuckPossiblity=0;
        bTryingToGetUnstuck=false;
    }
}

/** Handle a zed that thinks it's stuck. Teleport it to a spawn volume, or handle it some other way */
function HandleStuck()
{
    local bool bSeenRecently;

    if( !bTryingToGetUnstuck )
    {
        LastStuckTime = WorldInfo.TimeSeconds;
        bTryingToGetUnstuck = true;
    }

 	DumpCommandStack();
    DumpCommandHistory();

    bSeenRecently = !MyKFPawn.IsUsingSuperSpeed();

    //`log(self@GetFuncName()$" bSeenRecently = "$bSeenRecently$" `TimeSince(LastLOSOrRelevantTime): "$`TimeSince(MyKFPawn.LastLOSOrRelevantTime)$" TimeSeconds: "$WorldInfo.TimeSeconds$" LastLOSOrRelevantTime: "$MyKFPawn.LastLOSOrRelevantTime);

    if( bSeenRecently )
    {
        if( AmIAllowedToSuicideWhenStuck() )
        {
            //`log(self$" killed itself because it was stuck and being seen!!!");
            //ScreenMessagePlayer(self$" killed itself because it was stuck and being seen!!!");
        	StuckSuicide();
        }
    	else if( StuckTeleportToPathNode() )
    	{
            //`log(self$" teleported because it was stuck, and seen, but couldn't suicide!!!");
            //ScreenMessagePlayer(self$" teleported  because it was stuck, and seen, but couldn't suicide!!!");
    	}
     	else if( StuckTeleportToSpawnVolume() )
    	{
            //`log(self$" teleported to spawn volume because it was stuck, and seen, but couldn't suicide and couldn't teleport to pathnode!!!");
            //ScreenMessagePlayer(self$" teleported to spawn volume because it was stuck, and seen, but couldn't suicide and couldn't teleport to pathnode!!!");
    	}
    	else
    	{
    	   //`log(self$" stuck but can't teleport to spawn or nav or suicide and I've been seen!!!");
    	   //ScreenMessagePlayer(self$" stuck but can't teleport to spawn or nav or suicide and I've been seen!!!");
    	}
    }
    else
    {
     	if( StuckTeleportToSpawnVolume() )
    	{
            //`log(self$" teleported to spawn volume because it was stuck!!!");
            //ScreenMessagePlayer(self$" teleported to spawn volume because it was stuck!!!");
    	}
    	else if( StuckTeleportToPathNode() )
    	{
            //`log(self$" teleported because it was stuck, but couldn't teleport to spawn volume!!!");
            //ScreenMessagePlayer(self$" teleported because it was stuck, but couldn't teleport to spawn volume!!!");
    	}
        else if( AmIAllowedToSuicideWhenStuck() )
        {
            //`log(self$" killed itself because it was stuck and couldn't teleport anywhere!!!");
            //ScreenMessagePlayer(self$" killed itself because it was stuck and couldn't teleport anywhere!!!");
        	StuckSuicide();
        }
    	else
    	{
    	   //`log(self$" stuck but can't teleport to spawn or nav or suicide!!!");
    	   //ScreenMessagePlayer(self$" stuck but can't teleport to spawn or nav or suicide!!!");
    	}
    }
}

/** Kill this zed because it is stuck */
function StuckSuicide()
{
    // Add back to the spawn queue!
	if ( MyKFGameInfo != None && MyKFGameInfo.SpawnManager != none )
	{
        MyKFGameInfo.NumAISpawnsQueued -= 1;
        MyKFGameInfo.MyKFGRI.AIRemaining++;
        MyKFGameInfo.SpawnManager.LeftoverSpawnSquad[MyKFGameInfo.SpawnManager.LeftoverSpawnSquad.Length] = class<KFPawn_Monster>(Pawn.Class);
	}

    Pawn.Died( self,                    //Controller Killer,
			   class'DmgType_Suicided', // class<DamageType> damageType,
			   Pawn.Location);          // vector HitLocation);
}

/** Teleport this zed to a spawn volume because it is stuck */
function bool StuckTeleportToSpawnVolume()
{
    local array< class<KFPawn_Monster> > AIToTeleport;
    local KFSpawnVolume KFSV;
    local KFAISpawnManager SpawnManager;
    local vector TeleportLocation;

	AIToTeleport[AIToTeleport.Length] = MyKFPawn.Class;

    SpawnManager = MyKFGameInfo.SpawnManager;
    if ( SpawnManager != none )
    {
    	SpawnManager.DesiredSquadType = MyKFPawn.default.MinSpawnSquadSizeType;

        if( Enemy != none && Enemy.Controller != none )
        {
            KFSV = SpawnManager.GetBestSpawnVolume(AIToTeleport, Enemy.Controller,, True );
        }
        else
        {
            KFSV = SpawnManager.GetBestSpawnVolume(AIToTeleport,,, True );
        }

    	if( KFSV != None )
    	{
            TeleportLocation = KFSV.FindTeleportLocation( MyKFPawn.Class );

        	if( !IsZero( TeleportLocation ) )
        	{
        	   if( TeleportToLocation(TeleportLocation, Pawn.Rotation, false) )
        	   {
        	       KFSV.HandleTeleportedTo();
            	   //`log(self$" teleported to spawn volume "$KFSV$" because it was stuck!!!");
            	   return true;
        	   }
        	}
    	}
    }

    return false;
}

/** Teleport this zed to a path node because it is stuck */
function bool StuckTeleportToPathNode(optional float CheckRadius=512)
{
	local NavigationPoint ResNav;

	`AILog( GetFuncName() );

	ResNav = class'KFPathnode'.static.GetNearestValidFloorNavWithinRadiusToPawn(Pawn, CheckRadius);
	if( ResNav != none && TeleportToLocation(Resnav.Location, Pawn.Rotation) )
	{
		return true;
	}
	return false;
}

/** Teleport to a spawn volume closer to the enemy */
function RelocateTeleport()
{
    local array< class<KFPawn_Monster> > AIToTeleport;
    local KFSpawnVolume KFSV;
    local KFAISpawnManager SpawnManager;
    local vector TeleportLocation;
    local float DistToEnemySquared;

	AIToTeleport[AIToTeleport.Length] = MyKFPawn.Class;

    SpawnManager = MyKFGameInfo.SpawnManager;
    if ( SpawnManager != none )
    {
    	SpawnManager.DesiredSquadType = MyKFPawn.default.MinSpawnSquadSizeType;

        if( Enemy != none && Enemy.Controller != none )
        {
            DistToEnemySquared = VSizeSq(Pawn.Location - Enemy.Location);

            KFSV = SpawnManager.GetBestSpawnVolume(AIToTeleport, Enemy.Controller,, True, DistToEnemySquared );
        }
//        else
//        {
//            KFSV = SpawnManager.GetBestSpawnVolume(AIToTeleport,, True );
//        }

    	if( KFSV != None )
    	{
            TeleportLocation = KFSV.FindTeleportLocation( MyKFPawn.Class );

        	if( !IsZero( TeleportLocation ) )
        	{
        	   if( TeleportToLocation(TeleportLocation, Pawn.Rotation, false) )
        	   {
        	       KFSV.HandleTeleportedTo();
        	       LastTeleportTime = WorldInfo.TimeSeconds;
            	   //`log(self$" teleported to spawn volume "$KFSV$" because it hadn't seen an enemy for a while!!!");
            	   return;
        	   }
        	}
    	}
    }
}

/** Return true if we should reduce zed on zed collision on bump when navigating */
function bool ShouldReduceZedOnZedCollisionOnBumpForNavigating()
{
    local float DistToEnemySquared;

    // Don't reduce zed on zed collision if we're close to an enemy
    if( Enemy != none )
    {
        DistToEnemySquared = VSizeSq(Enemy.Location - Pawn.Location);

        if( bEnemyIsVisible )
        {
            if( DistToEnemySquared <  NavigationBumpTeamCollisionThreshholdSquared )
            {
                return false;
            }
        }
    }

    if( MyKFPawn != none )
    {
        // If noone can see us, reduce collision
        if( MyKFPawn.IsUsingSuperSpeed() )
        {
            return true;
        }

        // If we think we may be stuck, reduce collision
        if( StuckPossiblity > (StuckPossiblityThreshhold * 0.5) )
        {
            return true;
        }
    }

    return false;
}

simulated function SpecialBumpHandling( float DeltaTime )
{
	local float delta;
	local Vector upvect;

	if( MyKFPawn.CurrentChokePointTrigger == none && !ShouldReduceZedOnZedCollisionOnBumpForNavigating() )
	{
		if( MyKFPawn.bReducedZedOnZedPinchPointCollisionStateActive )
		{
			`AiLog( GetFuncName() @ " does not have a CurrentChokePointTrigger so turning turn collision on", 'SpecialBumpHandling' );
			RestoreCollisionCylinderReducedPercentForSameTeamIgnoreBlockingBy();
		}
	}
	else
	{
		//decay bump val
		if( bBumpedThisFrame )
		{
			delta = fMax(0.7,abs( BumpThreshold - CurBumpVal ));
			CurBumpVal = FInterpTo( CurBumpVal, BumpThreshold * 5.01f, DeltaTime, BumpGrowthRate / delta );
			if(CurBumpVal > 0.3f)
			{
				//MessagePlayer(GetFuncname()@"HIT THRESHOLD! TURNING OFF COLLISION ZOMG");
				`AiLog( GetFuncName() @ " CurBumpVal: " @ CurBumpVal @ " Has Gotten High enough to turn collision off - lastbumper: " @ lastbumper, 'SpecialBumpHandling' );

				if( MyKFPawn.CurrentChokePointTrigger != none && MyKFPawn.CurrentChokePointTrigger.PartialReduceTeammateCollision() )
                {
				    ReduceCollisionCylinderReducedPercentForSameTeamIgnoreBlockingBy(true);
				}
				else
				{
				    ReduceCollisionCylinderReducedPercentForSameTeamIgnoreBlockingBy();
				}
			}
			bBumpedThisFrame=false;
		}
		else
		{
			if(CurBumpVal > 0.01)
			{
				CurBumpVal = FInterpTo( CurBumpVal, 0.f, DeltaTime, BumpDecayRate / fMax(CurBumpVal,0.1) );
			}
			else if( MyKFPawn.bReducedZedOnZedPinchPointCollisionStateActive )
			{
				`AiLog( GetFuncName() @ " CurBumpVal: " @ CurBumpVal @ " Has Gotten low enough to turn collision on - LastBumper: " @ LastBumper, 'SpecialBumpHandling' );
				RestoreCollisionCylinderReducedPercentForSameTeamIgnoreBlockingBy();
			}
		}
	}

	if( bShowCollisionRadiusForReducedZedOnZedPinchPointCollisionState && MyKFPawn != none )
	{
		upvect.X = 0.0;
		upvect.Y = 0.0;
		upvect.Z = MyKFPawn.CylinderComponent.CollisionHeight;

		if( MyKFPawn.bReducedZedOnZedPinchPointCollisionStateActive )
		{
			DrawDebugCylinder(  MyKFPawn.Location + upvect,
								MyKFPawn.Location - upvect,
								MyKFPawn.CylinderComponent.CollisionRadius * MyKFPawn.TeammateCollisionRadiusPercent,
								10,
								ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOn.R,
								ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOn.G,
								ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOn.B,
								false );
		}
		else
		{
			DrawDebugCylinder(  MyKFPawn.Location + upvect,
								MyKFPawn.Location - upvect,
								MyKFPawn.CylinderComponent.CollisionRadius * MyKFPawn.TeammateCollisionRadiusPercent,
								10,
								ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOff.R,
								ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOff.G,
								ColorForCollisionRadiusForReducedZedOnZedPinchPointCollisionStateOff.B,
								false );
		}

	}

}

/** Only used if bSpecialBumpHandling is true in .ini file */
function ReduceCollisionCylinderReducedPercentForSameTeamIgnoreBlockingBy(optional bool bPartialReduction)
{
	if( MyKFPawn != None && MyKFPawn.Health > 0 )
	{
		//MyKFPawn.SetCollision(,false);
		if( !MyKFPawn.bReducedZedOnZedPinchPointCollisionStateActive )
		{
            // Only make it a little smaller
            if( bPartialReduction )
            {
                MyKFPawn.TeammateCollisionRadiusPercent =  0.4;
            }
            else
            {
                MyKFPawn.TeammateCollisionRadiusPercent =  MyKFPawn.TeammateCollisionRadiusPercent / MyKFPawn.CylinderComponent.CollisionRadius;
            }

			`AiLog( GetFuncName() @ " - CollisionRadiusBeforeReducedZedOnZedPinchPointCollisionState: " @ MyKFPawn.default.TeammateCollisionRadiusPercent @ " - CollisionCylinderReducedPercentForSameTeamCollision: " @ MyKFPawn.TeammateCollisionRadiusPercent, 'CollisionToggle' );

			MyKFPawn.bReducedZedOnZedPinchPointCollisionStateActive = true;
		}
	}
}

/** Only used if bSpecialBumpHandling is true in .ini file */
function RestoreCollisionCylinderReducedPercentForSameTeamIgnoreBlockingBy()
{
	if( MyKFPawn != None && MyKFPawn.Health > 0 )
	{
		//MyKFPawn.SetCollision(,true);
		MyKFPawn.TeammateCollisionRadiusPercent = MyKFPawn.default.TeammateCollisionRadiusPercent;
		MyKFPawn.bReducedZedOnZedPinchPointCollisionStateActive = false;

		`AiLog( GetFuncName() @ " - CollisionRadiusBeforeReducedZedOnZedPinchPointCollisionState: " @ MyKFPawn.default.TeammateCollisionRadiusPercent @ " - CollisionCylinderReducedPercentForSameTeamIgnoreBlockingBy: " @ MyKFPawn.TeammateCollisionRadiusPercent, 'CollisionToggle' );
	}
	else
	{
		`AiLog( GetFuncName() @ " MyKFPawn == None || MyKFPawn.Health <= 0 ", 'CollisionToggle' );
	}
}

/** NPC has seen a player - use SeeMonster for similar notifications about seeing any pawns (currently not in use) */
event SeePlayer( Pawn Seen )
{
    local float DistToEnemy, DistToSeen;

// 	if( bHasDebugCommand && AICommand_Debug(GetActiveCommand()).GetStateName() == 'DebugVision' )
// 	{
// 		AICommand(CommandList).NotifyEnemyBecameVisible( Seen );
// 		Enemy = Seen;
// 		Enable( 'EnemyNotVisible' );
// 		return;
// 	}

    // Store the time this AI first saw a player
    if( TimeFirstSawPlayer == 0 )
    {
        TimeFirstSawPlayer = Worldinfo.TimeSeconds;
    }

	if( MyKFPawn != none )
	{
		if( !MyKFPawn.IsAliveAndWell() )
		{
			// Disable SeePlayer indefinitely
			DisableSeePlayer(0.f);
		}
		else if( MyKFPawn.IsDoingSpecialMove(SM_Emerge) )
		{
			DisableSeePlayer( 0.f );
			return;
		}
	}
	if ( Enemy == Seen )
	{
		CachedVisibleEnemy = Enemy;
		EnemyVisibilityTime = WorldInfo.TimeSeconds;
		bEnemyIsVisible = true;
		EnableEnemyNotVisible();

		if( MyKFPawn != none && MyKFPawn.IsAliveAndWell() )
		{
			`DialogManager.CheckSpotMonsterDialog( Enemy, MyKFPawn );
			// Store the last time we saw the enemy
			if( Enemy == Seen )
			{
				if( LastEnemySightedTime == 0 || `TimeSince(LastEnemySightedTime) > RepeatWalkingTauntTime )
				{
					if( MyKFPawn.CanDoSpecialMove(SM_WalkingTaunt) )
					{
						MyKFPawn.DoSpecialMove(SM_WalkingTaunt);
					}
				}
				LastEnemySightedTime = WorldInfo.TimeSeconds;
			}
		}

		return;
	}

    if( Enemy != none && Enemy != Seen )
	{
		//`log( self$" I already have an enemy: "$Enemy$" Visible? "$bEnemyIsVisible$" LOS to Seen? "$LineOfSightTo(Seen)$" CanSee Seen? "$CanSee(Seen) );
		//`log( self$" Dist from Enemy: "$VSize(Enemy.Location - Pawn.Location)$" vs  "$VSize( Seen.Location - Pawn.Location ) );
		if( KFPawn(Seen) != none && KFPawn(Seen).IsDoingSpecialMove(SM_GrappleVictim) && NumberOfZedsTargetingPawn(Seen) <= 3 && !bEnemyIsVisible )
		{
			SetEnemy( Seen );
		}
		else if( LineOfSightTo(Seen) && !bEnemyIsVisible )
		{
			SetEnemy( Seen );
		}
		else if( CanSee(Seen) )
		{
			DistToEnemy = VSize(Enemy.Location - Pawn.Location);
            DistToSeen = VSize(Seen.Location - Pawn.Location);

            if( DistToEnemy > StrikeRange * 1.5 && DistToEnemy > 1.7 * DistToSeen )
			{
				SetEnemy( Seen );
			}
		}
	}
	else
	{
		SetEnemy( Seen );
	}

    // Store the last time we saw the enemy if we just switched to that enemy
    if( Enemy == Seen )
    {
        LastEnemySightedTime = WorldInfo.TimeSeconds;
    }

	// Notify the AI command that we saw an enemy
	if( CachedAICommandList != none )
	{
		`AILog( "SeePlayer: "$Seen$" - while I'm moving to goal, notifying "$CommandList$" and letting it handle this event", 'SeePlayer' );
		CachedAICommandList.NotifyPlayerBecameVisible( Seen );
	}
}

/** NPC has lost sight of current enemy */
event EnemyNotVisible()
{
// 	if( bHasDebugCommand && AICommand_Debug(GetActiveCommand()).GetStateName() == 'DebugVision' )
// 	{
// 		msg( "I CANNOT SEE YOU!" );
// 		AICommand(CommandList).NotifyEnemyNotVisible();
// 		return;
// 	}
	// Let the command, if any, handle this
	if( CommandList != none )
	{
		`AILog( GetFuncName()$"() - notifying "$CommandList$" and letting it handle this event", 'EnemyNotVisible' );
		AICommand(CommandList).NotifyEnemyNotVisible();
	}
	if( Enemy != none && MyKFPawn != none )
	{
		MyKFPawn.ClearHeadTrackTarget( Enemy );
	}

    if( bEnemyIsVisible )
    {
    	// Evalulate if we should switch enemies if we lose site of our current enemy
    	FindNewEnemy();
    }

	bEnemyIsVisible = false;
	DisableEnemyNotVisible();
	EnableSeePlayer();

	bWasVisibleToEnemy = bIsVisibleToEnemy;
	bIsVisibleToEnemy = false;
}

/** NPC has "heard" a noise (instigated by MakeNoise()) */
event HearNoise( float Loudness, Actor NoiseMaker, optional Name NoiseType )
{
	return;

	DisableHearNoise();

	if( CachedAICommandList != none )// && Enemy == Seen )
	{
		//`AILog( "HearNoise: "$Other$" - notifying "$CommandList$" and letting it handle this event", 'BumpEvent' );
		if( CachedAICommandList.NotifyHearNoise( Loudness, NoiseMaker, NoiseType ) )
		{
			return;
		}
	}
	// Respond to MakeNoise from nearby player reloading
// 	if( NoiseType == 'PlayerReload' && FRand() < 0.75f && VSize(KFWeapon(NoiseMaker).Instigator.Location - Pawn.Location) < 1024.f )
// 	{
// 		`AILog( "HearNoise aborting movement commands", 'Command_MoveToGoal' );
// 		AbortMovementCommands();
//
// 		SetEnemy( KFWeapon(NoiseMaker).Instigator );
// 	}
// 	else
// 	{
// 		super.HearNoise( Loudness, NoiseMaker, NoiseType );
// 	}
	`AILog( self$" HearNoise event, Loudness: "$Loudness$" NoiseMaker: "$NoiseMaker$" Type: "$NoiseType$" Dist: "$VSize( NoiseMaker.Location - Pawn.Location )$"... Disabling HearNoise", 'HearNoise' );

	// Disable noise hearing, it will be re-enabled later.
	DisableHearNoise();
}

event bool NotifyBump( Actor Other, vector HitNormal )
{
	local AICommand_HeadlessWander HeadlessWander;
	local KFPawn_Monster KFPM;
	local bool bInPartialCollisionReductionTrigger;
	local actor HitActor;

	if( MyKFPawn != none && MyKFPawn.IsDoingSpecialMove(SM_Emerge) )
	{
		DisableBump( 0.25f );
		return true;
	}

	KFPM = KFPawn_Monster( Other );
	if( bSpecialBumpHandling )
	{
		if( MyKFPawn != none && KFPM != none && KFPM.Health > 0 )
		{
			MyKFPawn.HandleMonsterBump( KFPM, HitNormal );
			if( !KFPM.IsDoingSpecialMove(SM_MeleeAttack) && KFPM.MyKFAIC != none && KFPM.MyKFAIC.DoorEnemy == none && !IsZero(KFPM.Acceleration) )
			{
				bInPartialCollisionReductionTrigger = MyKFPawn.CurrentChokePointTrigger != none && MyKFPawn.CurrentChokePointTrigger.PartialReduceTeammateCollision();

	            // Reduce the collision with other zeds if noone is watching, or we are in a choke point that allows it
	            if(  MyKFPawn.CurrentChokePointTrigger != none
	                && (MyKFPawn.CurrentChokePointTrigger.CanReduceTeammateCollision()
	                || bInPartialCollisionReductionTrigger
	                || ShouldReduceZedOnZedCollisionOnBumpForNavigating()) )
				{
	                if( bInPartialCollisionReductionTrigger && Enemy != none )
	                {
	                    // If this line doesn't hit our enemy, go ahead and let this bump count to reduce collision if we're standing in the trigger of a welded door!
	                    HitActor = ActorBlockTest( Pawn, Enemy.Location + vect(0,0,1) * Enemy.BaseEyeHeight, MyKFPawn.Location + vect(0,0,1) * MyKFPawn.BaseEyeHeight,, true );
	                }

	                if( !IsWithinAttackRange() || (bInPartialCollisionReductionTrigger && (HitActor == none || HitActor != Enemy))  )
					{
						bBumpedThisFrame = true;
						lastbumper = KFPM;
						//msg( "BUMP! "$CurBumpVal );
						return true;
						//MessagePlayer(GetFuncname()@"BUMP! -"@CurBumpVal);
					}
					else
					{
						`AiLog( GetFuncName() @ " Bumped: " @ KFPM @ " but IsWithinAttackRange so not going to care about SpecialBumpHandling right now!!!", 'SpecialBumpHandling' );
					}
				}
				else
				{
					`AiLog( GetFuncName() @ " Bumped: " @ KFPM @ " but not in a door trigger so not going to care about SpecialBumpHandling right now!!!", 'SpecialBumpHandling' );
				}
			}
		}
	}
	DisableBump( 0.25f );
	if (MyKFPawn != none && MyKFPawn.Physics == PHYS_Falling)
	{
		return false;
	}

	`RecordAIBump( `StatID(AI_BUMP), self, Pawn.Location, Pawn.Rotation, Other, "SSpeed: "$MyKFPawn != none ? MyKFPawn.IsUsingSuperSpeed() : False );
	`AILog( "NotifyBump() into "$Other$" HitNormal: "$HitNormal$" MoveTarget: "$MoveTarget!=none?string(MoveTarget):"none", 'BumpEvent' );
	DisableBump( 0.25f );
	LastBumpedPawn = Pawn(Other);

	if( MyKFPawn != none && MyKFPawn.bPlayShambling && LastBumpedPawn != none && LastBumpedPawn.IsAliveAndWell() )
	{
		HeadlessWander = AICommand_HeadlessWander(GetActiveCommand());
		DisableBump( 0.3f );

		if( HeadlessWander != none && !MyKFPawn.IsDoingSpecialMove() && `TimeSince( HeadlessWander.LastHeadlessAttackTime ) > 2.5f )
		{
			UpdatePendingStrike();
			DoStrike();
		}
	}

	if (Role == ROLE_Authority && bCanDoHeavyBump)
	{
		DoHeavyZedBump(Other, HitNormal);
		return true;
	}

	//      if( IgnoreNotifies() )
	//      {
	//           `AILog( "Bump ignoring notifies for "$GetActiveCommand(), 'BumpEvent' );
	//           return false;
	//      }
	// Let any interested AICommands deal with this
	if( CachedAICommandList != none )// && Enemy == Seen )
	{
		`AILog( "Bump: "$Other$" - notifying "$CommandList$" and letting it handle this event", 'BumpEvent' );
		if( CachedAICommandList.NotifyBump(Other, HitNormal) )
		{
			return true;
		}
	}

	if( KfMovementPlugin != none )
	{
		//if( KfMovementPlugin.NotifyBump(Other, HitNormal) )
		//{
		//	return true;
		//}
	}

	if( LastBumpedPawn == none || Pawn.IsSameTeam(LastBumpedPawn) || !LastBumpedPawn.IsAliveAndWell() || (Enemy != none && Enemy == Other) )
	{
		return false;
	}

	// From KF1
	if( SetEnemy(LastBumpedPawn) )
	{
		return false;
	}

	return false;
}

function DrawFireAttackDebug()
{
	//BallisticProjectileFireBehavior.DrawFireAttackDebug();
	DirectProjectileFireBehavior.DrawFireAttackDebug();
	LeapBehavior.DrawFireAttackDebug();
}

/** Called when we have dealt melee damage */
function NotifyMeleeDamageDealt();


/*********************************************************************************************
* SpecialMoves
********************************************************************************************* */

// Stub function
function SpecialMoveTimeout();

function NotifySpecialMoveEnded(KFSpecialMove SM)
{
	local LatentActionObserver ObserverInterface;

	`AILog(SM@"finished", 'SpecialMove');

	// notify observers
	ObserverInterface = LatentActionObserver(SM.AISpecialOwner);
	if (ObserverInterface != none)
	{
		ObserverInterface.OnLatentFinished(self, SM, BTR_Success);
	}

	LastSpecialMoveEndTime = WorldInfo.TimeSeconds;
}

function NotifySpecialMoveStarted(KFSpecialMove SM);

/*********************************************************************************************
 Steering related
 ********************************************************************************************* */

// Timer called after possession
simulated function StartSteering()
{
	if( Steering != none )
	{
		`AILog( GetFuncName()$"() turning on separation steering, separating from class KFPawn_Monster", 'AISteering' );
		Steering.SeparationOn( class'KFPawn_Monster' );
	}
}

/*********************************************************************************************
* Debugging related functions
* For NPC Overhead debug text, see:
* To display a message to players, see: event msg()
* To set PlayersOnly and display a message to players, see: event PauseAndShowMsg()
* To edit AILog output, see: event AILog_Internal() and Globals.uci
* To set up a debug mode when NPC spawns, see: SetUpDebug()
*
*
********************************************************************************************* */

/*---------------------------------------------------------
  Native function declarations
---------------------------------------------------------*/

/** Outputs the AICommand history array to the log file */
native function DumpCommandHistory();
native static function DrawDebugText( HUD HUD, String Text, optional color TextColor );

function DrawDebugTextToHud( HUD HUD, String Text, optional color TextColor )
{
	DrawDebugText( HUD, Text, TextColor );
}

/** Assorted debug options - uncomment to enable */
function SetupDebug()
{
	local KFAIDirector Director;

	if( MyKFGameInfo != none )
	{
		Director = MyKFGameInfo.GetAIDirector();

		if( Director != none )
		{
			bDebug_PostRenderInfo = (bDebug_DrawOverheadInfo || Director.bShowAINames) || bDebug_DrawAttackAnimInfo || bDebug_DrawAIDebug || (MyKFPawn != none && MyKFPawn.bDebug_DrawSprintingOverheadInfo);
			if( Director.bShowAINames )
			{
				bDebug_DrawOverheadInfo = true;
				MyKFPawn.SetDebugTextRendering(true);
				//bDebug_DrawAIDebug = true;
				//SetPostRendering( bDebug_PostRenderInfo );
			}
		}
	}

//`if(`__TW_AIDEBUGGING_)
	if( !IsTimerActive(nameof(Debug_CheckRecentMoveTime)) )
	{
		// Tracking stuck NPCs
		SetTimer( 20.f + FRand(), true, nameof(Debug_CheckRecentMoveTime) );
	}
//`endif
}

/** Is the AI currently in debug mode? (i.e, using AICommand_Debug) */
function bool IsInDebugMode()
{
	local GameAICommand Cmd;
	local AICommand_Debug DebugCommand;

	for( Cmd = CommandList; Cmd != None; Cmd = Cmd.ChildCommand )
	{
		DebugCommand = AICommand_Debug(Cmd);
		if( DebugCommand != none )
		{
			return true;
		}
	}

	return false;
}

/*---------------------------------------------------------
  Logging / Screen Messages
---------------------------------------------------------*/

/** Used to update RecentActionInfo string, which is contoniually displayed on-screen in some debug modes */
event SetRecentActionInfo( string Info )
{
	RecentActionInfo = "["$GetStateName()$"]["$Info$"]";
}

simulated function OnDestroy(SeqAct_Destroy Action)
{
	if (Pawn != None)
	{
		Pawn.OnDestroy(Action);
	}
	Super.OnDestroy(Action);
}

/** Sends message to local players using ClientMessage and log the text */
event Msg( string MsgTxt, optional bool bOutputToLog=true, optional name MessageType, optional float MessageDuration )
{
	if( MyKFPawn != none )
	{
		MyKFPawn.KFMessagePlayer( MsgTxt, MessageType, MessageDuration );
		if( bOutputToLog )
		{
			`AILog( MsgTxt, 'Msg' );
		}
	}
}

/** Main AI related logging function usually called from macros `AILog & `AILog_Ext or from native code */
event AILog_Internal( coerce string LogText, optional Name LogCategory, optional bool bForce, optional bool BugIt, optional bool bSkipExtraInfo )
{
`if(`notdefined(ShippingPC))
	local AICommand ActiveCommand;
	local int Idx, FileNameLength;
	local String ActionStr, BorderStr, FinalStr, StatusStr, FileName, GoString, LocString;
	local Engine Eng;
	local KFGameReplicationInfo KFGRI;

	if( MyKFPawn == none || MyKFPawn.Health <= 0 )
	{
		return;
	}

	Eng = class'Engine'.static.GetEngine();

	if( (!bForce && !bAILogging) || Eng.bDisableAILogging )
	{
		return;
	}

	if( LogCategory == 'AICommand' || LogCategory == 'InitAICommand' || LogCategory == 'Command_Base' )
	{
		bSkipExtraInfo = true;
	}

	ActiveCommand = AICommand( GetActiveCommand() );

	if( !bForce )
	{
		if( ActiveCommand != none &&  ActiveCommand.OverrideLogCategory != "" )
		{
			LogCategory = name( ActiveCommand.OverrideLogCategory );
		}

		for( Idx = 0; Idx < AILogFilter.Length; Idx++ )
		{
			if( AILogFilter[Idx] == LogCategory || (LogCategory == '' && AILogFilter[Idx] == 'Default') )
			{
				return;
			}
		}
	}
	BorderStr = "--------------------------------------------------------------------------------------------------";
	if( MyKFPawn != none )
	{
		if( bUseUniqueAILogFile && AILogFile == None )
		{
			AILogFile = Spawn(class'FileLog');
			FileName = string( MyKFPawn );
			FileName = Repl(FileName,"KFPawn_","",false);
			FileName = Repl(FileName,"Zed","",false);
			if( WorldInfo.GRI != none )
			{
				KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
				FileName = "w"$KFGRI.WaveNum$"_"$FileName;
			}
			// Include the file extension in determining the length
			FileNameLength = Len(Filename) + 6;
			// make sure file name isn't too long for consoles
			if(FileNameLength > 40)
			{
				// Make sure there is room for the .ailog part too
				FileName = Right(Filename,34);
			}
			`log( "Created log file "$AILogFile$" name: "$FileName );
			AILogFile.bKillDuringLevelTransition = true;
			AILogFile.bFlushEachWrite = bFlushAILogEachLine;
			// Use async unless flushing was requested
			AILogFile.bWantsAsyncWrites = !bFlushAILogEachLine;
			AILogFile.OpenLog(FileName,".ailog");
			AILogFile.Logf( "========================================================================================================" );
			AILogFile.Logf( "Log file for "$MyKFPawn$" created: ["$MyKFPawn.CreationTime$"] "$self$" Controlling "$MyKFPawn );
			AILogFile.Logf( " " );
			AILogFile.Logf( "Spawn Location Info: " );
			AIBugItStringCreator( MyKFPawn.Location, MyKFPawn.Rotation, GoString, LocString );
			AILogFile.Logf( GoString );
			AILogFile.Logf( LocString );
			AILogFile.Logf( "Difficulty:"$MyKFGameInfo.GetModifiedGameDifficulty());
			AILogFile.Logf( "Original Health:"$MyKFPawn.HealthMax$" Adjusted Health:"$MyKFPawn.Health );
			AILogFile.Logf( "Original GroundSpeed:"$MyKFPawn.default.GroundSpeed$" Adjusted GroundSpeed:"$MyKFPawn.GroundSpeed );
			AILogFile.Logf( "Original SprintSpeed:"$MyKFPawn.default.SprintSpeed$" Adjusted SprintSpeed:"$MyKFPawn.SprintSpeed );
			AILogFile.Logf( "Original HiddenSpeed:"$MyKFPawn.default.HiddenGroundSpeed$" Adjusted HiddenSpeed:"$MyKFPawn.HiddenGroundSpeed );
			if( MyKFPawn.PawnAnimInfo != none )
			{
				AILogFile.Logf( "WeakAttackChance:"$MyKFPawn.PawnAnimInfo.WeakAttackChance );
				AILogFile.Logf( "MediumAttackChance:"$MyKFPawn.PawnAnimInfo.MediumAttackChance );
				AILogFile.Logf( "HardAttackChance:"$MyKFPawn.PawnAnimInfo.HardAttackChance );
			}
			AILogFile.Logf( "========================================================================================================" );
			AILogFile.Logf( " " );
		}
	}
	//ActionStr = String(GetStateName());

	if( !bSkipExtraInfo )
	{
		if( ActiveCommand != none )
		{
			ActionStr = string( ActiveCommand.Name ); //$":"$String( ActiveCommand.GetStateName() );
		}

		if( MyKFPawn != none )
		{
			StatusStr = "   [Phys:"$MyKFPawn.GetPhysicsName()$"][Velocity:"$VSize(MyKFPawn.Velocity)$"]";
			if( bPreparingMove )
			{
				StatusStr = StatusStr$"[bPreparingMove:TRUE]";
			}
			if( MyKFPawn.Anchor != none )
			{
				StatusStr = StatusStr$"[Anchor:"$MyKFPawn.Anchor$"]";
			}
			if( MyKFPawn.IsUsingSuperSpeed() )
			{
				StatusStr = StatusStr$"[SUPERSPEED]";
			}
			if( Enemy != none )
			{
				StatusStr = StatusStr$"[EnemyDist:"$VSize(Enemy.Location - MyKFPawn.Location)$"]";
			}
			if( MyKFPawn.IsDoingSpecialMove() )
			{
				StatusStr = StatusStr$"[SM:"$MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove]$"]";
			}
		}
		else
		{
			FinalStr = "[NO PAWN]";
		}
		if( MyKFPawn.bCrawler && MyKFPawn.Base != none )
		{
			StatusStr = StatusStr$"[BASE:"$MyKFPawn.Base$"]";
		}
		if( PendingDoor != none )
		{
			StatusStr = StatusStr$"[PENDING DOOR:"$PendingDoor$"]";
		}
		if( DoorEnemy != none )
		{
			StatusStr = StatusStr$"[DOORENEMY:"$DoorEnemy$"]";
		}
		FinalStr = "["$WorldInfo.TimeSeconds$"]["$ActionStr$"]"$FinalStr;
	}
	else
	{
		FinalStr = "["$WorldInfo.TimeSeconds$"]"; //["$self$"]";
	}

	if( bDebug_LogToProfiler )
	{
		LogToProfiler( LogText, LogCategory );
	}
	if( AILogFile != none && bUseUniqueAILogFile )
	{
		if( !bSkipExtraInfo )
		{
			AILogFile.Logf( BorderStr );
			AILogFile.Logf( FinalStr );
			AILogFile.Logf( StatusStr );
			AILogFile.Logf( LogText );
			AILogFile.Logf( BorderStr );
		}
		else
		{
			AILogFile.Logf( FinalStr@LogText );
		}
		if( BugIt )
		{
			AIBugItStringCreator( MyKFPawn.Location, MyKFPawn.Rotation, GoString, LocString );
			AILogFile.Logf( "BUGIT: "$GoString );
		}
		AILogFile.Logf( " " );
	}
	else
	{
		if( !bSkipExtraInfo )
		{
			`log( BorderStr );
		}
		`log( FinalStr );
		`log( StatusStr );
		`log( LogText );
		if( !bSkipExtraInfo )
		{
			`log( BorderStr );
		}
		if( BugIt && AILogFile != none )
		{
			AIBugItStringCreator( MyKFPawn.Location, MyKFPawn.Rotation, GoString, LocString );
			AILogFile.Logf( "BUGIT: "$GoString );
		}
		`log( " " );
	}
	//else
	//{
	//     `AILog( Pawn@"["$WorldInfo.TimeSeconds$"]"@ActionStr$":"@LogText );
	//}

    `Log( Pawn@"["$WorldInfo.TimeSeconds$"]"@FinalStr$":"@LogText, bAILogToWindow );

	`endif //`notdefined(ShippingPC)
}

function AIBugItStringCreator( const out Vector ViewLocation, const out Rotator ViewRotation, out String GoString, out String LocString )
{
	GoString = "BugItGo " $ ViewLocation.X $ " " $ ViewLocation.Y $ " " $ ViewLocation.Z $ " " $ ViewRotation.Pitch $ " " $ ViewRotation.Yaw $ " " $ ViewRotation.Roll;
	//`AILog( GoString, 'BugIt' );

	LocString = "?BugLoc=" $ string(ViewLocation) $ "?BugRot=" $ string(ViewRotation);
	//`AILog( LocString, 'BugIt' );
}

/** Debug event which will initiate PlayersOnly pause mode and display MsgTxt to player(s) */
event PauseAndShowMsg( optional string MsgTxt, optional vector TeleportToLocation )
{
	local PlayerController PC;
	local DebugCameraController DCC;

	foreach WorldInfo.AllControllers( class'PlayerController', PC )
	{
		PC.ClientMessage( MsgTxt );
		if( !WorldInfo.bPlayersOnly && !WorldInfo.bPlayersOnlyPending )
		{
			PC.CheatManager.PlayersOnly();
			break;
		}
	}

	if( TeleportToLocation != vect(0,0,0) )
	{
		foreach WorldInfo.AllControllers( class'DebugCameraController', DCC )
		{
			DCC.SetLocation( TeleportToLocation );
		}
	}
}

function ScreenMessagePlayer( coerce String Msg )
{
`if(`notdefined(FINAL_RELEASE))
	local PlayerController PC;

	foreach LocalPlayerControllers(class'PlayerController', PC)
	{
		PC.ClientMessage( Msg );
	}
`endif
}


/*********************************************************************************************
* KFDebugLines & Path rendering in-game
********************************************************************************************* */

function KFDebugLines GetDebugLines()
{
	return class'KFDebugLines'.static.GetDebugLines();
}

function KFDebug_ClearLines( optional int ID )
{
	class'KFDebugLines'.static.KFDebug_ClearLines( name, ID );
}

function KFDebug_ClearSpheres( optional int ID )
{
	class'KFDebugLines'.static.KFDebug_ClearSpheres( name, ID );
}

function KFDebug_ClearDebugText( optional int ID )
{
	class'KFDebugLines'.static.KFDebug_ClearText( name, ID );
}

function KFDebug_DrawPath( optional int ID )
{
	local KFDebugLines KFDL;

	return;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.AddDebugLineFromOwner( name, MoveTarget.Location, 0, 255, 0, false, 20, ID );
		KFDL.AddDebugSphere( MoveTarget.Location, 16, 8, 0, 100, 100, false, 20, name, ID );
	}
}

function KFDebug_DrawMyPath()
{
	local KFDebugLines KFDL;
	local int i;

	KFDL = GetDebugLines();
	if( KFDL != none )
	{
		KFDL.RemoveOwnedDebugLines(name);
		KFDL.RemoveOwnedDebugSpheres(name);
		KFDL.RemoveOwnedDebugText3D(name);
		for( i = 0; i < RouteCache.Length; i++ )
		{
			if( i < (RouteCache.Length - 1) )
			{
				KFDL.AddDebugLine( RouteCache[i].Location, RouteCache[i+1].Location, 113, 167, 207, false, 20, name, i );
			}
			KFDL.AddDebugSphere( RouteCache[i].Location, 24, 8, 113, 167, 207, true,, name, i );
			KFDL.AddDebugText3D( RouteCache[i].Location + vect(0,0,32), string(RouteCache[i]), true, 113, 167, 207, true,,,, name, i );
		}
	}
}

function KFDebug_DrawPathTo( Actor A, optional int ID, optional int SecondaryID, optional int TextID )
{
	local KFDebugLines KFDL;

	if( bDebug_DrawPath )
	{
		KFDL = GetDebugLines();

		if( KFDL != none )
		{
			KFDL.AddDebugLineFromOwner( name, A.Location, 113,167,207, false, 45, ID );
			//KFDL.AddDebugLine( Pawn.Location, MoveTarget.Location, 0, 255, 0, false, 45, name, ID );
			KFDL.AddDebugSphere( A.Location, 16, 8, 113,167,207, false, 45, name, ID );
			KFDL.AddDebugLineFromOwner( name, MoveGoal.Location, 126,250,85, false, 45, SecondaryID );
			KFDL.AddDebugSphere( MoveGoal.Location, 16, 8, 125, 250, 85, false, 45, name, SecondaryID );
			KFDL.AddDebugText3D( A.Location + vect(0,0,32), string(A), true, 113, 167, 207, false, 45, A,, name, ID );
		}
	}
}

function KFDebug_DrawPathGoal( optional int ID )
{
	local KFDebugLines KFDL;

	return;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.AddDebugLineFromOwner( name, MoveGoal.Location, 0, 255, 0, false, 45, ID );
		//KFDL.AddDebugLine( Pawn.Location, MoveTarget.Location, 0, 255, 0, false, 45, name, ID );
		KFDL.AddDebugSphere( MoveGoal.Location, 16, 8, 0, 100, 100, false, 45, name, ID );
	}
}

/** Logs text/category to file readable by AIProfiler */
native function LogToProfiler( string Text, name Category );

/**
 *
 *
 */
function ShowStuckNpcsToggle()
{
	// start timer to check update

	if( IsTimerActive(nameof(Debug_CheckStuckTimer)) )
	{
		ClearTimer( nameof(Debug_CheckStuckTimer) );
	}
	else
	{
		// record location at debug start
		LocationAtStartOfStuckCheck = MyKFPawn.Location;
		LocationAtLastStuckCheck = MyKFPawn.Location;

		// Tracking stuck NPCs
		SetTimer( 1.0f, true, nameof(Debug_CheckStuckTimer) );
	}
}

function Debug_CheckStuckTimer()
{
	local Vector displacementFromStartOfCheck;
	local float distanceFromStartOfCheck;
	local Vector displacementFromLastStuckUpdate;
	local float distanceFromLastStuckUpdate;

	displacementFromStartOfCheck = MyKFPawn.Location - LocationAtStartOfStuckCheck;
	distanceFromStartOfCheck = VSize(displacementFromStartOfCheck);

	displacementFromLastStuckUpdate = MyKFPawn.Location - LocationAtLastStuckCheck;
	distanceFromLastStuckUpdate = VSize(displacementFromLastStuckUpdate);

	LocationAtLastStuckCheck = MyKFPawn.Location;

	if( distanceFromStartOfCheck < 1.0f )
	{
		DrawDebugLine( MyKFPawn.Location, Enemy.Location , 255, 0, 0, true );
	}
	else if( distanceFromLastStuckUpdate < 1.0f )
	{
		DrawDebugLine( MyKFPawn.Location, Enemy.Location , 255, 255, 0, true );
	}
}


function float GetMaxTimeAllowedToStayStuckBasedOnStuckType( MOVE_FAILURE_TYPE TypeOfFailure )
{
	local float maxTime;

	if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_NO_NAV_MESH_PATH )
	{
		maxTime = NoNavMeshPathMaxTimeAllowedToStayStuckBeforeSuicide;
	}
	else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMES )
	{
		maxTime = SameIntermediatePointToManyTimesMaxTimeAllowedToStayStuckBeforeSuicide;
	}
	else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_TARGET_OFF_NAV_MESH_AND_CAN_NOT_FIND_LOCAITON_NEAR_THEM_I_CAN_MOVE_TO )
	{
		maxTime = TargetOffNavMeshAndCanNotFindLocaitonNearThemICanMoveTooMaxTimeAllowedToStayStuckBeforeSuicide;
	}
	else
	{
		maxTime = DefaultMaxTimeAllowedToStayStuckBeforeSuicide;
	}

	return maxTime;
}

/**
 *
 *
 */
function ToggleHardCoreStuckNpcs( AICommand CmdTriggering, AITickablePlugin PlugInTriggering )
{
	// start timer to check update
	local float timeToTrip;

	if( IsTimerActive(nameof(HardCoreCheckStuckTimer)) )
	{
		ClearTimer( nameof(HardCoreCheckStuckTimer) );

		CmdTriggeringHardCoreStuckChecking = none;
		PlugInTriggeringTriggeringHardCoreStuckChecking = none;
	}
	else if( MyKFPawn != none )
	{
		// record location at debug start
		LocationAtStartOfStuckCheck = MyKFPawn.Location;
		LocationAtLastStuckCheck = MyKFPawn.Location;

		CmdTriggeringHardCoreStuckChecking = CmdTriggering;
		PlugInTriggeringTriggeringHardCoreStuckChecking = PlugInTriggering;

		timeToTrip = GetMaxTimeAllowedToStayStuckBasedOnStuckType( TypeOfMovementStuckOn );

		// Tracking stuck NPCs
		SetTimer( timeToTrip, true, nameof(HardCoreCheckStuckTimer) );
	}
}

function float GetMinDistaceToHaveToMoveToBeConcideredStuckByStuckType( MOVE_FAILURE_TYPE TypeOfFailure )
{
	local float minDistance;

	if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_NO_NAV_MESH_PATH )
	{
		minDistance = NoNavMeshPathMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide;
	}
	else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMES )
	{
		minDistance = SameIntermediatePointToManyTimesMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide;
	}
	else
	{
		minDistance = DefaultMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide;
	}

	return minDistance;
}

function HardCoreCheckStuckTimer()
{
	local Vector displacementFromStartOfCheck;
	local float distanceFromStartOfCheck;
	local Vector displacementFromLastStuckUpdate;
	local float distanceFromLastStuckUpdate;
	local color stuckLineColor;
	local float minDistanceToMove;

	displacementFromStartOfCheck = MyKFPawn.Location - LocationAtStartOfStuckCheck;
	distanceFromStartOfCheck = VSize(displacementFromStartOfCheck);

	displacementFromLastStuckUpdate = MyKFPawn.Location - LocationAtLastStuckCheck;
	distanceFromLastStuckUpdate = VSize(displacementFromLastStuckUpdate);

	LocationAtLastStuckCheck = MyKFPawn.Location;

	minDistanceToMove = GetMinDistaceToHaveToMoveToBeConcideredStuckByStuckType( TypeOfMovementStuckOn );

	if( distanceFromStartOfCheck <= minDistanceToMove )
	{
		if( bShowVisualStuckZedDebugInfo )
		{
			if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_NO_NAV_MESH_PATH )
			{
				stuckLineColor = Move_failure_type_no_nav_mesh_path_color;
			}
			else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMES )
			{
				stuckLineColor = Move_failure_type_same_intermediate_point_too_many_times_color;
			}
			else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_TARGET_OFF_NAV_MESH_AND_CAN_NOT_FIND_LOCAITON_NEAR_THEM_I_CAN_MOVE_TO )
			{
				stuckLineColor = MoveFailureTypeTargetOffNavMeshAndCanNotFindLocaitonNearThemICanMoveTo;
			}
			else
			{
				stuckLineColor = Move_failure_type_none_color;
			}

			DrawDebugLine( MyKFPawn.Location, Enemy.Location , stuckLineColor.R, stuckLineColor.G, stuckLineColor.B, true );
		}

		if( CmdTriggeringHardCoreStuckChecking != none )
		{
			CmdTriggeringHardCoreStuckChecking.NotifyNpcTerminallyStuck();
		}
		else if( PlugInTriggeringTriggeringHardCoreStuckChecking != none )
		{
			PlugInTriggeringTriggeringHardCoreStuckChecking.NotifyNpcTerminallyStuck();
		}

	}
	else if( distanceFromLastStuckUpdate <= minDistanceToMove )
	{
		if( bShowVisualStuckZedDebugInfo )
		{
			DrawDebugLine( MyKFPawn.Location, Enemy.Location , 255, 255, 0, true );
		}

		if( CmdTriggeringHardCoreStuckChecking != none )
		{
			CmdTriggeringHardCoreStuckChecking.NotifyNpcInGrannyMode();
		}
		else if( PlugInTriggeringTriggeringHardCoreStuckChecking != none )
		{
			PlugInTriggeringTriggeringHardCoreStuckChecking.NotifyNpcInGrannyMode();
		}
	}

}

function bool AmIAllowedToSuicideWhenStuck()
{
	return true;
}

function bool AmIAllowedToStillUsePathNodes()
{
	return false;
}

//`if(`__TW_AIDEBUGGING_)
/** Timer that's tracking stuck NPCs */
function Debug_CheckRecentMoveTime()
{
// 	local float TimeSinceLastMove;
// 	local float TimerRate;

// 	TimeSinceLastMove = `TimeSince(LastMoveFinishTime);
// 	TimerRate = GetTimerRate(nameof(Debug_CheckRecentMoveTime));
//
// 	if( TimeSinceLastMove > TimerRate )
// 	{
// 		`AILog( "** WARNING ** "$self$" hasn't moved in over "$TimeSinceLastMove$" seconds! Dumping CommandStack and CommandHistory:", 'Critical' );
// 		DumpCommandStack();
// 		DumpCommandHistory();
// 	}
}
//`endif

/** Called from native code when AI is paused */
event Debug_AIPaused( bool bNewPause )
{
	if( bNewPause )
	{
		AbortMovementCommands();
		AbortMovementPlugIns();
		Pawn.ZeroMovementVariables();
		StopAllLatentMovement();
	}
}

/** Dump AI command stack to the log file */
function DumpStack()
{
	DumpCommandStack();
}

/** Adds self to Player HUD PostRenderedActors list. Actors in the list will have PostRenderFor() called. */
function SetPostRendering( bool bOn )
{
	local PlayerController KFPC;
	local KFHUDBase KFHUD;

	foreach LocalPlayerControllers(class'PlayerController', KFPC)
	{
		KFHUD = KFHUDBase(KFPC.myHUD);

		if( KFHUD != none )
		{
			if( bOn )
			{
				bPostRenderIfNotVisible = true;
				KFHUD.SetShowOverlays( true );
				KFHUD.AddPostRenderedActor(self);
			}
			else
			{
				bPostRenderIfNotVisible = default.bPostRenderIfNotVisible;
				//KFHUD.SetShowOverlays( false );
				KFHUD.RemovePostRenderedActor(self);
			}
		}
	}
}

/**
Script function called by NativePostRenderFor().
*/
simulated event PostRenderFor(PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir)
{
	if( MyKFPawn != none )
	{
		MyKFPawn.PostRenderFor(PC, Canvas, CameraPosition, CameraDir);
	}
}


function DrawAttackInfo( KFHUDBase HUD )
{
	local Canvas C;
	local int i, x;
	local string DisplayString;
	local KFPawnAnimInfo KFPAG;
	local name CurrentSeq, InRangeTag;

	if( !bDebug_DrawAttackAnimInfo || MyKFPawn == none || MyKFPawn.PawnAnimInfo == none || Enemy == none )
	{
		return;
	}

	if( MyKFPawn.PawnAnimInfo == none )
	{
		return;
	}

	C = HUD.Canvas;
	C.Font =  class'Engine'.Static.GetTinyFont();
	C.SetDrawColor( 255, 255, 255 );
	C.SetPos( C.SizeX * 0.05f, C.SizeY * 0.22f );

	DrawDebugText( HUD, "ATTACK ANIMATION INFO FOR "$Pawn.Name$" (Controller: "$self$")" );
	C.SetDrawColor( 0, 0, 255, 255 );
	DrawDebugText( HUD, "--------------------------------------------------------------------------" );
	DrawDebugText( HUD, " " );

	KFPAG = MyKFPawn.PawnAnimInfo;

	if( MyKFPawn.InAnyAttackTagRange(Enemy.Location, InRangeTag) )
	{
		C.SetDrawColor( 255, 25, 0, 255 );
		DrawDebugText( HUD, "Distance From Enemy: "$VSize(Pawn.Location - Enemy.Location)$"uu [WITHIN ATTACK RANGE]" );
		C.SetDrawColor( 0, 255, 50, 255 );
	}
	else
	{
		C.SetDrawColor( 0, 255, 50, 255 );
		DrawDebugText( HUD, "Distance From Enemy: "$VSize(Pawn.Location - Enemy.Location)$"uu" );
	}

	if( MyKFPawn.IsDoingSpecialMove() )
	{
		C.SetDrawColor( 255, 25, 50, 255 );
		DrawDebugText( HUD,"[Doing Special Move: "$MyKFPawn.SpecialMove$"]" );
	}

	C.SetDrawColor( 0, 255, 50, 255 );

	if( GetActiveCommand() != none )
	{
		DisplayString = "[Active Command: "$GetActiveCommand()$"]";
	}
	if( CommandList != none )
	{
		DisplayString = DisplayString$" [CommandList: "$CommandList$"]";
		if( CommandList.ChildCommand != none )
		{
			DisplayString = DisplayString$" [ChildCommand: "$CommandList.ChildCommand$"]";
			if( CommandList.ChildStatus != '' )
			{
				DisplayString = DisplayString$" [ChildStatus: "$CommandList.ChildStatus$"]";
			}
		}
	}
	if( DisplayString != "" )
	{
		DrawDebugText( HUD, DisplayString );
		DisplayString = "";
	}
	CurrentSeq = MyKFPawn.BodyStanceNodes[EAS_FullBody].GetPlayedAnimation();
	if( CurrentSeq != '' )
	{
		for( i = 0; i < KFPAG.Attacks.Length; i++ )
		{
			for( x = 0; x < KFPAG.Attacks[i].Anims.Length; x++ )
			{
				if( CurrentSeq == KFPAg.Attacks[i].Anims[x] )
				{
					DisplayString = "[FULLBODY] Playing "$string(CurrentSeq)$" [Tag "$KFPAG.Attacks[i].Tag$"] [Min: "$KFPAG.Attacks[i].MinDistance$"uu Max: "$KFPAG.Attacks[i].MaxDistance$"uu]";
					break;
				}
				if( DisplayString != "" )
				{
					break;
				}
			}
		}

		if( DisplayString != "" )
		{
			DrawDebugText( HUD, DisplayString );
			DisplayString = "";
		}
	}
}

/*********************************************************************************************
* Overhead Debug Text
********************************************************************************************* */

function bool IsDebugTextCategoryEnabled( name CategoryName )
{
	return( EnabledDebugTextCategories.Find('All') != -1 || EnabledDebugTextCategories.Find(CategoryName) != -1 );
}

simulated function DrawDebug( KFHUDBase HUD, name Category )
{
	local int CmdCnt;
	local Canvas C;
	local GameAICommand Cmd;
	//local String Text;
	local AICmdHistoryItem Item;
	local bool bDrawDebugCommandStack, bDrawDebugCommandHistory;
	local bool bDrawDebugAllPlugins, bDrawDebugPlugInHistory;
	local string AddTxt, NullTxt;
	local AICommand AC;

	//local float Aggression;
	bDrawDebugCommandStack = false;
	bDrawDebugCommandHistory = false;
	bDrawDebugAllPlugins = false;

	if( Category == 'Default' || Category == 'All' || Category == 'PlugIns' )
	{
		bDrawDebugAllPlugins = true;
		bDrawDebugPlugInHistory = true;
	}


// 	if( Category == 'Default' || Category == 'All' || Category == 'OverheadNames' )
// 	{
// 		bDrawDebugCommandStack = false;
// 		bDrawDebugCommandHistory = false;
// 		Icon = Texture2D'ENG_EditorResources_TEX.AI.S_AI';
// 		DrawIconOverhead(HUD, Icon);
// 		return;
// 	}
// 	if( bDebug_ShowViewCone )
// 	{
// 		if( MyKFPawn != None )
// 		{
// 			tmp = MyKFPawn.GetPawnViewLocation();
// 			rot = MyKFPawn.GetBaseAimRotation();
// 		}
// 		DrawDebugCone(tmp ,vector( rot),Pawn .SightRadius, Acos(Pawn .PeripheralVision), Acos(Pawn .PeripheralVision),16,MakeColor(255,0,0,255));
// 	}

	//return;
	NullTxt = "None";
	// Draw list of commands down the side of the screen
	if( Pawn != None && Category == 'All' )
	{
		C = HUD.Canvas;
		C.SetOrigin(0,0);
		C.Font = class'Engine'.Static.GetSmallFont();
		C.SetPos(C.SizeX * 0.05f, C.SizeY * 0.25f);

		if( bEnemyIsVisible )
		{
			DrawDebugText( HUD, "bEnemyIsVisible: "$bEnemyIsVisible, MakeColor(0,255,0,255) );
		}
		else
		{
			DrawDebugText( HUD, "bEnemyIsVisible: "$bEnemyIsVisible );
		}
	//	C.SetDrawColor(0, 255, 0, 255);

// 		if( InLatentExecution( LATENT_MOVETOWARD ) )
// 		{
// 			C.SetDrawColor(225, 255, 0, 255);
// 			DrawDebugText( HUD, String(self)$" IN LATENT MOVETOWARD" );
// 			C.SetDrawColor(225, 0, 0, 255);
// 		}
		if( bDrawDebugCommandStack )
		{
			// WRITE OUT COMMAND STACK
			C.SetDrawColor(255, 255, 255, 255);
			DrawDebugText( HUD, "************************************************************" );
			C.SetDrawColor(0, 0, 255, 255);
			DrawDebugText( HUD, "COMMAND STACK" );
			foreach AllCommands( class'GameAICommand', Cmd )
			{
				if( Cmd.ChildCommand == None )
				{
					C.SetDrawColor(225, 0, 0, 255);
				}
				else
				{
					C.SetDrawColor(0, 255, 0, 255);
				}
				DrawDebugText( HUD, String(Cmd.Name)@":"@Cmd.GetStateName() );
// 				Text = Cmd.GetDebugVerboseText();
// 				if( Len(Text) > 0 )
// 				{
// 					DrawDebugText( HUD, ".........."@Text );
// 				}
				CmdCnt++;
			}
			if( CmdCnt == 0 )
			{
				DrawDebugText( HUD, "NO COMMANDS ACTIVE" );
			}
		}
		if( bDrawDebugCommandHistory )
		{
			// WRITE OUT COMMAND HISTORY
		//	C.SetDrawColor(255, 255, 255, 255);
			DrawDebugText( HUD, "************************************************************" );
			//C.SetDrawColor(0, 0, 255, 255);
			DrawDebugText( HUD, "COMMAND HISTORY (Count:"@CommandHistoryNum$")" );
			CmdCnt = 0;
			foreach CommandHistory( Item )
			{
				CmdCnt++;
		//		C.SetDrawColor(255, 0, 0, 255);
				DrawDebugText( HUD, "Cmd"@CmdCnt$":"@String(Item.CmdClass)@"Time:"@Item.TimeStamp);
				if( Len(Item.VerboseString) > 0 )
				{
			//		C.SetDrawColor(255, 64, 64, 255);
					DrawDebugText( HUD, ".............."@Item.VerboseString );
				}
			}
		}
		C.Font = class'Engine'.Static.GetSmallFont();
		if( MyKFPawn != none )
		{
			//C.SetDrawColor(0, 255, 0, 255);
			DrawDebugText( HUD, string(Pawn) );//, MakeColor(0,255,0,255) );
			AddTxt = "ActiveCommand: ";
			if( CachedAICommandList != None )
			{
				AC = CachedAICommandList;
				if( AC != none )
				{
					AddTxt = AddTxt@AC;
					if( AC.CachedChildCommand != none )
					{
						AddTxt = AddTxt@"Child1: "$AC.CachedChildCommand;
						if( AC.CachedChildCommand.CachedChildCommand != none )
						{
							AddTxt = AddTxt@"Child2: "$AC.CachedChildCommand.CachedChildCommand;
						}
					}
				}
			}
			else
			{
				AddTxt = AddTxt@NullTxt;
			}
			DrawDebugText( HUD, AddTxt );
			if( IsDoingLatentMove() )
			{
				DrawDebugText( HUD, "Latent Action: MOVE", MakeColor(200,0,0) );
			}
			else
			{
				DrawDebugText( HUD, "Latent Action: None" );
			}
			DrawDebugText( HUD, AddTxt );
			DrawDebugText( HUD, "Floor: "$Pawn.Floor$" DesiredRot: "$Pawn.DesiredRotation$" PawnRot: "$Pawn.Rotation$" KFAIC Rot: "$Rotation );
			DrawDebugText( HUD, "Velocity: "$VSize(Pawn.Velocity)$" Accel: "$VSize(Pawn.Acceleration)$" Physics: "$Pawn.GetPhysicsName() );
			DrawDebugText( HUD, "Direct Path: "$bDirectMoveToGoal$" bPreparingMove: "$bPreparingMove$" GroundSpeed: "$Pawn.GroundSpeed );
			DrawDebugText( HUD, "bPreciseDest: "$bPreciseDestination$" bForceMaxAccel: "$MyKFPawn.bForceMaxAccel$" MoveOffset: "$MoveOffset );
			AddTxt = "Anchor:";
			if( Pawn.Anchor != none )
			{
				AddTxt = AddTxt@MyKFPawn.Anchor;
			}
			else
			{
				AddTxt = AddTxt@"None";
			}
			if( RouteCache.Length > 0 )
			{
				AddTxt = AddTxt@" RouteCache[0]:"$RouteCache[0];
			}

			AddTxt = "SpecialMove:";
			if( MyKFPawn.IsDoingSpecialmove() )
			{
				AddTxt = AddTxt@MyKFPawn.SpecialMoves[MyKFPawn.SpecialMove];
			}
			else
			{
				AddTxt =  AddTxt@NullTxt;
			}
			AddTxt = AddTxt@"MoveTarget:";
			if( MoveTarget != none )
			{
				AddTxt = AddTxt@MoveTarget;
			}
			else
			{
				AddTxt = AddTxt@NullTxt;
			}
			AddTxt = AddTxt@"Enemy:";
			if( Enemy != none )
			{
				AddTxt = AddTxt@Enemy;
			}
			else
			{
				AddTxt = AddTxt@NullTxt;
			}
			DrawDebugText( HUD, AddTxt );

			AddTxt = "Sprinting: "$MyKFPawn.bIsSprinting$" FocalPoint: "$GetFocalPoint()$" Focus:";
			if( Focus != none )
			{
				AddTxt = AddTxt@Focus;
			}
			else
			{
				AddTxt = AddTxt@NullTxt;
			}

			AddTxt = AddTxt@":";
			if( MyKFPawn.bIsHeadTrackingActive && MyKFPawn.MyLookAtInfo.LookAtTarget != none )
			{
				AddTxt = AddTxt@MyKFPawn.MyLookAtInfo.LookAtTarget;
			}
			else
			{
				AddTxt = AddTxt@NullTxt;
			}
			DrawDebugText( HUD, AddTxt );
			if( Enemy != none )
			{
				DrawDebugText( HUD, "EnemyDist: "$VSize(Enemy.Location - Pawn.Location)$" RouteCache: "$RouteCache.Length$" DestinationOffset: "$Pawn.DestinationOffset );
				DrawDebugText( HUD, "MeleeEvents Enabled: "$bIsProbingMeleeRangeEvents$" Within Melee Range ["$StrikeRange$"]" );
				DrawDebugText( HUD, "DotToEnemy: "$Normal(MyKFPawn.Location - Enemy.Location) dot vector(Enemy.Rotation) );
			}
			if( Pawn.IsDesiredRotationInUse() )
			{
				DrawDebugText( HUD, "DesiredRotation In Use: TRUE", MakeColor(255,0,0,255) );
			}
			if( Pawn.IsDesiredRotationLocked() )
			{
				DrawDebugText( HUD, "DesiredRotation is locked", MakeColor(255,0,0,255) );
			}

			if( bHasDebugCommand )
			{
				FindCommandOfClass(class'AICommand_Debug').DrawDebug( HUD, Category );
			}
		}
	}

	if( bDrawDebugAllPlugins )
	{
        if( KfMovementPlugin != none )
        {
            KfMovementPlugin.DrawDebugToHud( Hud, Category );
		}
        if( KfLeapPlugin != none )
        {
            KfLeapPlugin.DrawDebugToHud( Hud, Category );
		}
        if( KfMovementPlugin != none )
        {
            KfStuckFixPlugin.DrawDebugToHud( Hud, Category );
		}
	}

	if( bDrawDebugPlugInHistory )
	{
		MyAiPlugInHistory.DrawDebugToHud( Hud, Category );
	}
}

function BeginDebugCommand()
{
	AbortCommand( None, class'AICommand' );
	class'AICommand_Debug'.static.Debug( self );
}

function DoDebugTurnInPlace( KFPlayerController KFPC, optional bool bAllowMelee=false )
{
	AbortCommand( None, class'AICommand' );
	class'AICommand_DebugTurn'.static.DebugTurnInPlace( self, bAllowMelee, KFPC );
}

/*********************************************************************************************
* TakeDamage
********************************************************************************************* */

/** To override in subclasses */
function bool IsAggroEnemySwitchAllowed()
{
	if( LastEnemySwitchTime > 0.f && `TimeSince(LastEnemySwitchTime) < AggroEnemySwitchWaitTime )
	{
		return false;
	}

	return true;
}

/**
 *
 * @param	HUD	Player HUD
 */
function DrawDebugOverheadMovementPhaseData( KFHUDBase HUD, Out Vector2d ScreenPos )
{
	local Texture2D			Icon;
	local PlayerController	PC;
	local Canvas			Canvas;
	local Vector			CameraLoc, ScreenLoc;
	local Rotator			CameraRot;
	local float				X, Y;
	local float				DOT;

	if( MyKFPawn == none || MyKFPawn.Health <= 0 )
	{
		return;
	}

	if( HUD.ShouldDisplayDebug('AIPathing') || HUD.ShouldDisplayDebug('AllVerbose'))
	{
		HUD.DrawRoute(MyKFPawn);
	}

	Canvas = HUD.Canvas;
	ScreenLoc = Canvas.Project( Pawn.Location + vect(0,0,1) * Pawn.GetCollisionHeight() * 1.5f );
	if( ScreenLoc.X < 0 || ScreenLoc.X >= HUD.Canvas.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= HUD.Canvas.ClipY )
	{
		return;
	}

	PC = HUD.PlayerOwner;
	Canvas.SetDrawColor(255,255,255);

	PC.GetPlayerViewPoint( CameraLoc, CameraRot );
	Dot = vector( CameraRot ) dot ( Pawn.Location - CameraLoc );
	if( Dot < 0.5f )
	{
		return;
	}

	if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_PATHNODE_NORMAL_MOVE_TO )
	{
		Icon = MovementPhaseTypePathNodeNormalMoveToIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_PATHNODE_DELAY_MOVE )
	{
		Icon = MovementPhaseTypePathNodeDelayMoveIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_PATHNODE_POINT_MOVE_TO )
	{
		Icon = MovementPhaseTypePathNodeMoveToPointIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_PATHNODE_ROTATE_TO_FOCUS )
	{
		Icon = MovementPhaseTypePathNodeRotateToFocusIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_PATHNODE_FAILED_MOVE )
	{
		Icon = MovementPhaseTypePathNodeMoveFailedIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_NAV_MESH_NORMAL_MOVE_TO )
	{
		Icon = MovementPhaseTypeNavMeshNormalMoveToIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_FINAL_DEST_MOVE_TOWARDS )
	{
		Icon = MovementPhaseTypeFinalDestMoveTowardsIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_EMT_LOS_MOVE_TOWARDS )
	{
		Icon = MovementPhaseTypeEMT_LOS_MoveTowardsIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_MOVE_TOO_MESH_USING_PATH_NODES )
	{
		Icon = MovementPhaseTypeMovingToNavMeshUsingPathNodesIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_FALLBACK_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POS )
	{
		Icon = MovementPhaseTypeFALLBACK_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POSIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_FALLBACK_REFUSED_TO_BE_EXPLOTIED_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POS )
	{
		Icon = MovementPhaseTypeFALLBACK_REFUSED_TO_BE_EXPLOTIED_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POSIcon;
	}
	else if( CurrentMovementPhase == MOVEMENT_PHASE_TYPE_STUCK )
	{
		if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_NO_NAV_MESH_PATH )
		{
			Icon = TypeOfMovementStuckOnMOVE_FAILURE_TYPE_NO_NAV_MESH_PATHIcon;
		}
		else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMES )
		{
			Icon = TypeOfMovementStuckOnMOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMESIcon;
		}
		else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_TARGET_OFF_NAV_MESH_AND_CAN_NOT_FIND_LOCAITON_NEAR_THEM_I_CAN_MOVE_TO )
		{
			Icon = TypeOfMovementStuckOnMOVE_FAILURE_TYPE_TARGET_OFF_NAV_MESH_AND_CAN_NOT_FIND_LOCAITON_NEAR_THEM_I_CAN_MOVE_TOIcon;
		}
		else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_LOOKING_FOR_BETTER_INTERMEDIATE_LOCATION )
		{
			Icon = TypeOfMovementStuckOnLookingForBetterIntermediateLoc;
		}
		else if( TypeOfMovementStuckOn == MOVE_FAILURE_TYPE_MOVING_TO_BETTER_INTERMEDIATE_LOCATION )
		{
			Icon = TypeOfMovementStuckOnMoveToBetterIntermediate;
		}
		else
		{
			Icon = TypeOfMovementStuckOnUnknownWhyIcon;
		}
	}
	else
	{
		Icon = MovementPhaseTypeUnknownIcon;
	}

	if (Icon != None)
	{
		Canvas.SetPos( ScreenLoc.X - Icon.SizeX / 2, ScreenLoc.Y - Icon.SizeY / 2, ScreenLoc.Z );
		Canvas.DrawTexture( Icon, 1.f );
		X = ScreenLoc.X + Icon.SizeX/2 + 5;
		Y = ScreenLoc.Y - Icon.SizeY/2;
	}
	else
	{
		X = ScreenLoc.X;
		Y = ScreenLoc.Y;
	}
	Canvas.SetPos( X, Y );

	ScreenPos.X = Canvas.CurX;
	ScreenPos.Y = Canvas.CurY;

	//Str = "#"$GetRightMost(self);
	Canvas.Font = class'Engine'.Static.GetSmallFont();

    if( KfMovementPlugin != none )
    {
        KfMovementPlugin.DrawDebugToHud( HUD, 'Recast' );
	}
    if( KfStuckFixPlugin != none )
    {
        KfStuckFixPlugin.DrawDebugToHud( HUD, 'Recast' );
	}
    if( KfLeapPlugin != none )
    {
        KfLeapPlugin.DrawDebugToHud( HUD, 'Recast' );
    }
}

simulated function DrawBehaviorTreeIconOverhead(KFHUDBase HUD)
{
	//@deprecated with __TW_BASEAI_LEAN_
}

/*********************************************************************************************
* Evade / Evasion / Blocking
**********************************************************************************************/

/** Returns a reaction delay only if the projectile/weapon can be evaded */
function bool GetDangerEvadeDelay( Name InstigatorClassName, out float ReactionDelay, out byte ForcedEvadeDir, out byte bShouldBlock )
{
	local int Index, D;
	local sBlockInfo BlockSettings;

	Index = DangerEvadeSettings.Find( 'ClassName', InstigatorClassName );

	if( Index != INDEX_NONE )
	{
		bShouldBlock = 0;

		// Cache difficulty
		D = WorldInfo.Game.GetModifiedGameDifficulty();

		// Check cooldown
		if( DangerEvadeSettings[Index].LastEvadeTime > 0.f
			&& `TimeSince(DangerEvadeSettings[Index].LastEvadeTime) < DangerEvadeSettings[Index].Cooldowns[D] )
		{
			return false;
		}

		// Check evade chance
		if( D >= DangerEvadeSettings[Index].EvadeChances.Length
			|| fRand() > DangerEvadeSettings[Index].EvadeChances[D]	* (WorldInfo.Game.NumPlayers == 1 ? DangerEvadeSettings[Index].SoloChanceMultiplier : 1.f) )
		{
			// Check block chance
			if( D < DangerEvadeSettings[Index].BlockChances.Length )
			{
				BlockSettings = MyKFPawn.GetBlockSettings();
				if( `TimeSince(MyKFPawn.LastBlockTime) >= BlockSettings.Cooldown
					&& fRand() < DangerEvadeSettings[Index].BlockChances[D] * (WorldInfo.Game.NumPlayers == 1 ? BlockSettings.SoloChanceMultiplier : 1.f) )
				{
					// We are blocking
					bShouldBlock = 1;
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

		// Check forced evade chances
		if( bShouldBlock == 0 )
		{
			ForcedEvadeDir = DIR_None;
			if( DangerEvadeSettings[Index].ForcedEvadeChances.Length > D )
			{
				if( fRand() < DangerEvadeSettings[Index].ForcedEvadeChances[D].FL )
				{
					ForcedEvadeDir = DIR_ForwardLeft;
				}
				else if( fRand() < DangerEvadeSettings[Index].ForcedEvadeChances[D].FR )
				{
					ForcedEvadeDir = DIR_ForwardRight;
				}
			}

			// Set our delay
			ReactionDelay = RandRange( DangerEvadeSettings[Index].ReactionDelayRanges[D].X, DangerEvadeSettings[Index].ReactionDelayRanges[D].Y );
		}

		// Set our evade time for cooldowns
		DangerEvadeSettings[Index].LastEvadeTime = WorldInfo.TimeSeconds;

		return true;
	}

	return false;
}

/** Receives a melee warning including direction of attack and direction from pawn to attacker */
function ReceiveMeleeWarning( EPawnOctant MeleeDir, vector ProjectionToAttacker, Pawn Attacker )
{
	local vector NormalDir;
	local EPawnOctant AttackerDir;
	local byte BestDir;

	// Early out if blocking isn't possible
	if( !MyKFPawn.CanBlock() )
	{
		return;
	}

	NormalDir = Normal( ProjectionToAttacker );

	// No blocking attacks from behind
	if( vector(MyKFPawn.Rotation) dot NormalDir < MyKFPawn.GetMinBlockFOV() )
	{
		return;
	}

	BestDir = DIR_None;

	// Start with which direction attack is coming from
	AttackerDir = class'KFPawn'.static.CalcQuadRegion( MyKFPawn.Rotation, NormalDir );
	if( AttackerDir == DIR_Left || AttackerDir == DIR_Right )
	{
		BestDir = AttackerDir;
	}
	else if( AttackerDir == DIR_Forward )
	{
		// If we're being attacked from the front, use melee direction to determine block
		BestDir = MeleeDir == DIR_Left ? DIR_Right : DIR_Left;
	}

	if( BestDir != DIR_None )
	{
		MyKFPawn.DoSpecialMove( SM_Block, MyKFPawn.bIsBlocking,, class'KFSM_Block'.static.PackBlockSMFlags(BestDir) );
	}
}

/** Deprecated, doesn't work well for our purposes */
function ReceiveProjectileWarning( Projectile Proj );

/** Warns the AI that it needs to evade from a particular location */
function ReceiveLocationalWarning( vector DangerPoint, vector DangerInstigatorLocation, optional Object EvadeCauser )
{
	local byte BestDir;
	local float ReactionDelay;
	local byte bWantsBlock;

	if( MyKFPawn == none )
	{
		return;
	}

	if( CanEvade() || MyKFPawn.CanDoSpecialMove(SM_Block) )
	{
		// Make sure we're not evading something we can't even see
		if( vector(MyKFPawn.Rotation) dot Normal(DangerInstigatorLocation - MyKFPawn.Location) < 0.1f )
		{
			return;
		}

		// Attempt to look up our danger evade settings
		if( EvadeCauser != none )
		{
			// Returns false if it has no entry, is on cooldown, or it failed the evade chance check
			if( !GetDangerEvadeDelay(EvadeCauser.class.name, ReactionDelay, BestDir, bWantsBlock) )
			{
				return;
			}
		}
		else
		{
			// Make sure we always have a valid reaction delay
			ReactionDelay = RandRange( 0.f, 0.2f );
		}

		// Do blocks first
		if( bWantsBlock == 1 )
		{
			BestDir = class'KFPawn'.static.CalcQuadRegion( MyKFPawn.Rotation, DangerPoint - MyKFPawn.Location );
			if( BestDir != DIR_None )
			{
				MyKFPawn.DoSpecialMove( SM_Block, MyKFPawn.bIsBlocking,, class'KFSM_Block'.static.PackBlockSMFlags(BestDir) );
			}
			return;
		}

		// Calculate evade direction if there was no forced direction
		if( BestDir == DIR_None )
		{
			BestDir = GetBestEvadeDir( DangerPoint,, true );
		}

		if( BestDir != DIR_None )
		{
			DoEvade( BestDir,, DangerInstigatorLocation, ReactionDelay, true );
		}
	}
}

function NotifyTakeHit( Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum )
{
	local sBlockInfo BlockSettings;
	local byte BestDir;

	super.NotifyTakeHit( InstigatedBy, HitLocation, Damage, damageType, Momentum );

	if( MyKFPawn == none )
	{
		return;
	}

	UpdateLasDamageTime();

	// See if we should trigger our block
	if( !MyKFPawn.bIsBlocking )
	{
		BlockSettings = MyKFPawn.GetBlockSettings();

		// If there's no blocking chance, early out
		if( BlockSettings.Chance > 0.f )
		{
			AccumulatedBlockDamage += Damage;

			// If accumulated damage has reached or exceeded the threshold, attempt to trigger a block
			if( AccumulatedBlockDamage >= MyKFPawn.HealthMax * BlockSettings.DamagedHealthPctToTrigger
				&& MyKFPawn.Physics == PHYS_Walking
				&& MyKFPawn.IsCombatCapable()
				&& MyKFPawn.CanBlock() )
			{
				AccumulatedBlockDamage = 0;

				// Get direction we should block
				BestDir = class'KFPawn'.static.CalcQuadRegion( MyKFPawn.Rotation, Momentum );
				MyKFPawn.DoSpecialMove( SM_Block, MyKFPawn.bIsBlocking,, class'KFSM_Block'.static.PackBlockSMFlags(BestDir) );
				return;
			}
		}
	}

	// See if we should trigger our evade
	if( EvadeOnDamageSettings.Chance > 0.f )
	{
		AccumulatedEvadeDamage += Damage;

		// If accumulated damage has reached or exceeded the threshold, attempt to trigger an evade
		if( AccumulatedEvadeDamage >= MyKFPawn.HealthMax * EvadeOnDamageSettings.DamagedHealthPctToTrigger
			&& fRand() < EvadeOnDamageSettings.Chance
			&& CanEvade() )
		{
			AccumulatedEvadeDamage = 0;

			// Get direction we should evade
			BestDir = DIR_None;
			if( EvadeOnDamageSettings.ForcedEvadeChance.FL > 0.f && fRand() < EvadeOnDamageSettings.ForcedEvadeChance.FL )
			{
				BestDir = DIR_ForwardLeft;
			}
			else if( EvadeOnDamageSettings.ForcedEvadeChance.FR > 0.f && fRand() < EvadeOnDamageSettings.ForcedEvadeChance.FR )
			{
				BestDir = DIR_ForwardRight;
			}

			// If we don't have a forced evade direction, pick one based on the hit location
			if( BestDir == DIR_None )
			{
				BestDir = GetBestEvadeDir( HitLocation,, true );
			}

			if( BestDir != DIR_None )
			{
				DoEvade( BestDir,, (InstigatedBy != none && InstigatedBy.Pawn != none) ? InstigatedBy.Pawn.Location : vect(0,0,0), RandRange(0.f, 0.2f), true );
			}
		}
	}
}

function UpdateLasDamageTime()
{
	LastDamageTime_Taken = WorldInfo.TimeSeconds;
}

/** Notification that we've been damaged by a friendly AI */
function NotifyFriendlyAIDamageTaken( Controller DamagerController, int Damage, Actor DamageCauser, class<KFDamageType> DamageType )
{
	local int Idx;
	local Pawn BlockerPawn;

	if (DamageType == none || DamageType.default.bIgnoreAggroOnDamage)
	{
		return;
	}
	// Retrieves the index and, if necessary, creates a new entry
	Idx = UpdateFriendlyDamageHistory( DamagerController, Damage );
	if( Idx == INDEX_NONE )
	{
		return;
	}

	if( IsAggroEnemySwitchAllowed()
		&& DoorEnemy == none
		&& PendingDoor == none
		&& DamagerController.Pawn != Enemy
		&& FriendlyDamageHistory[Idx].Damage >= float(Pawn.HealthMax) * AggroZedHealthPercentage  )
	{
		BlockerPawn = GetPawnBlockingPathTo( DamagerController.Pawn );
		if( BlockerPawn == none )
		{
			SetEnemyToZed( DamagerController.Pawn );
		}
	}
}

/** Updates our friendly damage history, and returns the index in the damage history array  */
native function int UpdateFriendlyDamageHistory( Controller DamagerController, int Damage );

/** Called from KFProjectile after certain impact criteria is met, to warn AI of a pending explosion */
function DoProjectileWarning( KFProjectile KFProj )
{
	if( MyKFPawn == none || MyKFPawn.Health <= 0 || (!MyKFPawn.CanDoSpecialMove(SM_Evade) && !MyKFPawn.CanDoSpecialMove(SM_Evade_Fear)) )
	{
		return;
	}

	HandleProjectileWarning( KFProj );
}

function HandleProjectileWarning( Projectile Proj )
{
	if( MyKFPawn == none || MyKFPawn.Health <= 0 || (!MyKFPawn.CanDoSpecialMove(SM_Evade) && !MyKFPawn.CanDoSpecialMove(SM_Evade_Fear)) )
	{
		return;
	}

	if(CanEvadeGrenade() && Proj.IsA('KFProj_Grenade'))
	{
		// if we're looking in that direction and skilled enough, try an evasive maneuver. TODO: Add KFProjectile flag to check instead of IsA.
		if ( !IsTimerActive(nameof(Timer_DoProjectileEvade)) &&
			(vector(Pawn.Rotation) dot Normal(Proj.Instigator.Location - Pawn.Location) > 0.7) )
		{
			//TimeToImpact = Proj.GetTimeToLocation(Pawn.Location);
			PendingEvadeProjectile = Proj;
			MyKFPawn.SetHeadTrackTarget( PendingEvadeProjectile,, 1.f );
			SetTimer( (0.265 + FRand() * 0.12f), false, nameof(Timer_DoProjectileEvade) );
		}
	}
}

function bool CanEvadeGrenade()
{
	return (FRand() < EvadeGrenadeChance);
}

/** triggers an evade from the PendingEvadeProjectile, if possible and it's still on target */
final function Timer_DoProjectileEvade()
{
	local byte BestDir;

	/** When evading projectiles, headtracking is very briefly enabled when this timer is started, and ended here within
		 the timer.  This helps to make the NPC reaction look a little more realistic, turning its head toward the threat right
		 before responding to it. */
	MyKFPawn.SetHeadTrackTarget( none );
	if( MyKFPawn != none && (MyKFPawn.CanDoSpecialMove(SM_Evade) || MyKFPawn.CanDoSpecialMove(SM_Evade_Fear)) && PendingEvadeProjectile != none && !PendingEvadeProjectile.bDeleteMe
		&& !IsZero(PendingEvadeProjectile.Velocity) && CanEvade() )
	{
		/** Find the safest direction to evade in - away from the threat and hopefully not into a larger threat or obstruction. */
		BestDir = GetBestEvadeDir( PendingEvadeProjectile.Location, PendingEvadeProjectile.Instigator );
		if( BestDir != DIR_None )
		{
			DoEvade( BestDir, PendingEvadeProjectile,, 0.1f + FRand() * 0.2f, true );
		}
	}
	PendingEvadeProjectile = None;
}

/** Returns true if my pawn is permitted to evade away from something. */
function bool CanEvade( optional bool bOverrideSpecialMove )
{
	return MyKFPawn.Physics == PHYS_Walking
			&& (MyKFPawn.CanDoSpecialMove(SM_Evade) || MyKFPawn.CanDoSpecialMove(SM_Evade_Fear))
			&& (bOverrideSpecialMove || !MyKFPawn.IsDoingSpecialMove())
			&& MyKFPawn.IsCombatCapable();
}

/** Pick best direction to evade */
final function byte GetBestEvadeDir( Vector DangerPoint, optional Pawn ThreatPawn, optional bool bUseFastTrace=true, optional bool bCross )
{
	local vector	   X, Y, Z, VectToDanger, Offset, EvadeLocation, Extent;
	local bool		   bLeftOpen, bRightOpen, bFrontOpen, bBackOpen;
	local float		   DotX, CheckHeight;
	local EPawnOctant  EvadeDir;

	if( bCross )
	{
		EvadeDir = class'KFPawn'.static.CalcOctagonRegion( MyKFPawn.GetViewRotation(), (Normal(ThreatPawn.Location - Pawn.Location) Cross vect(0,0,1)) );
		return EvadeDir;
	}
	// Figure out which directions we can evade(Normal(IncomingKFP.Location - Pawn.Location) Cross vect(0,0,1))
	EvadeDir = class'KFPawn'.static.CalcOctagonRegion( MyKFPawn.GetViewRotation(), normal(MyKFPawn.Location - DangerPoint) );
	GetAxes( Pawn.Rotation, X, Y, Z );

	switch( EvadeDir )
	{
	case DIR_ForwardLeft:
		return DIR_ForwardLeft;
	case DIR_ForwardRight:
		return DIR_ForwardRight;
	case DIR_BackwardLeft:
		return DIR_BackwardLeft;
	case DIR_BackwardRight:
		return DIR_BackwardRight;

	case DIR_Forward:
		if( !bUseFastTrace || FastActorTrace( Pawn, Pawn.Location + 256.f * X, Pawn.Location, Pawn.GetCollisionExtent() * 0.5f ) )
		{
			return DIR_Forward;
		}
		break;
	case DIR_Backward:
		if( !bUseFastTrace || FastActorTrace( Pawn, Pawn.Location - 256.f * X, Pawn.Location, Pawn.GetCollisionExtent() * 0.5f ) )
		{
			return DIR_Backward;
		}
		break;
	case DIR_Left:
		if( !bUseFastTrace || FastActorTrace( Pawn, Pawn.Location - 256.f * Y, Pawn.Location, Pawn.GetCollisionExtent() * 0.5f ) )
		{
			return DIR_Left;
		}
		break;
	case DIR_Right:
		if( !bUseFastTrace || FastActorTrace( Pawn, Pawn.Location + 256.f * Y, Pawn.Location, Pawn.GetCollisionExtent() * 0.5f ) )
		{
			return DIR_Right;
		}
		break;
	}

	if( EvadeDir == DIR_None && ThreatPawn != none )
	{
		CheckHeight = (MyKFPawn.GetCollisionHeight() * 0.5) + MyKFPawn.MaxStepHeight;
		GetAxes( MyKFPawn.Rotation, X, Y, Z );
		VectToDanger = Normal(DangerPoint-Pawn.Location);
		DotX = X DOT VectToDanger;
		//DotY = Y DOT VectToDanger;
		Extent = Pawn.GetCollisionExtent() * 0.5f;
		// If dot is mostly forward or backward
		if( DotX >= 0.7071f || DotX <= -0.7071f )
		{

			Offset = X * 300.f;
			EvadeLocation = Pawn.Location - Offset;
			bBackOpen = CanReachEvadeLocation( EvadeLocation, CheckHeight, Extent );

			if( bBackOpen && DotX >= 0.7071 )
			{
				return DIR_Backward;
			}

			EvadeLocation = Pawn.Location + Offset;
			bFrontOpen = CanReachEvadeLocation( EvadeLocation, CheckHeight, Extent );
			if( bFrontOpen && DotX <= -0.7071 )
			{
				return DIR_Forward;
			}
		}
		else
		{
			Offset = Y * 300.0f;
			EvadeLocation = Pawn.Location + Offset;
			bRightOpen = CanReachEvadeLocation( EvadeLocation, CheckHeight, Extent );
			if( bRightOpen )
			{
				return DIR_Right;
			}

			EvadeLocation = Pawn.Location - Offset;
			bLeftOpen = CanReachEvadeLocation( EvadeLocation, CheckHeight, Extent );
			if( bLeftOpen )
			{
				return DIR_Left;
			}
		}
	}
	return DIR_None;
}

/** Checks to see if a potential location to evade to is obstructed */
function bool CanReachEvadeLocation( vector EvadeLocation, float CheckHeight, vector Extent )
{
	if( `FastTracePhysX(EvadeLocation, Pawn.Location)
		&& !FastTrace(EvadeLocation + (vect(0,0,-1) * CheckHeight), EvadeLocation, Extent) )
	{
		if( !IsPawnBlockingLine(Pawn.Location, EvadeLocation) )
		{
			return true;
		}
	}
	return false;
}

/*********************************************************************************************
* Door handling (attacking, passing through)
********************************************************************************************* */

/** Notification that NPC needs to stop moving and wait for door */
event WaitForDoor( KFDoorActor Door )
{
	`RecordAIDoor(`StatID(AI_WAITFORDOOR), self,Pawn.Location, Door, "Waiting at "$WorldInfo.TimeSeconds);
	`AILog( GetFuncName()$"() Waiting for door "$Door$" to open or be destroyed", 'Doors' );
	SetTimer( 5.f, true, nameof(Timer_WaitingForDoor) );
	DoorEnemy = none;
	PendingDoor = Door;
	Door.bMonitorDoor = true;
	bPreparingMove = true;
	//MoveTimer = -1.0f;  // To be enabled
	StopAllLatentMovement(); // To be enabled
	Pawn.Acceleration = vect(0,0,0);
// 	if( GetActiveCommand().IsA('AICommand_MoveToGoal') )
// 	{
// 		ForcePauseAndRepath();
// 	}
}

/** Debug timer set when NPC begins waiting for a door. Timer is cleared by DoorFinished(). Currently only
	in use to find any NPCs who might become stuck indefinitely while waiting for a door to finish opening,
	which hasn't been an issue lately. */
function Timer_WaitingForDoor()
{
	`AILog( "** WARNING ** ["$GetFuncName()$"] I've been waiting for at least 10 seconds for door "$PendingDoor$" bPreparingMove: "$bPreparingMove$" (Command: "$CachedAICommandList$")", 'Doors' );
    DoorFinished();
}

/** Door has finished opening, let the NPC move through - notification comes from the door itself if my
	bMonitorDoor flag is true. */
function bool DoorFinished()
{
	`AILog( GetFuncName()$"() door has finished opening or is destroyed!", 'Doors' );
	if( Pawn == None || PendingDoor.MyMarker == None || PendingDoor.MyMarker.ProceedWithMove(Pawn) )
	{
		`RecordAIDoor(`StatID(AI_FINISHEDWAITFORDOOR), self,Pawn.Location, PendingDoor, "Waiting at "$WorldInfo.TimeSeconds);
		`AILog( GetFuncName()$"() setting pending door to none, bPreparingMove to false. Proceeding with move.", 'Doors' );
		PendingDoor = None;

		// Notify command list that door is open
		if( CachedAICommandList != None )
		{
			CachedAICommandList.NotifyDoorOpened();
		}

		ClearTimer( nameof(Timer_WaitingForDoor) );
		return true;
	}
	`AILog( GetFuncName()$"() *** WARNING *** I received DoorFinished event but returned false! "$CachedAICommandList, 'Doors' );
	return false;
}

/*********************************************************************************************
* ATTACKING DOORS/ACTORS INSTEAD OF PAWNS
* "Enemy" is a Pawn, so we also have "DoorEnemy" and "ActorEnemy".
*
* TODO: Get rid of DoorEnemy, and and replace it with ActorEnemy for attacking doors
**********************************************************************************************/

/** Notification that NPC needs to attack this door */
function NotifyAttackDoor( KFDoorActor Door )
{
	local KFDoorMarker DoorMarker;
	local int AttackerCount, QueuedCount;
	local byte SMFlags;

	DoorMarker = KFDoorMarker(Door.MyMarker);
	if( DoorMarker != none )
	{
		Door.GetQueuedDoorAICounts( AttackerCount, QueuedCount );

		// Force a repath if there are too many zeds queued at this door
		if( AttackerCount + QueuedCount > 8 && DoorEnemy != Door )
		{
			DoorEnemy = none;
			PendingDoor = none;

			if( Enemy != none && Focus != Enemy )
			{
				Focus = none;
			}

			if( Enemy == none )
			{
				ChangeEnemy( GetClosestEnemy(), false );
			}

			// Update the cost of this door marker based on the number queued
			DoorMarker.UpdatePathingCost( AttackerCount, QueuedCount );

			// Tell our move commands that we're leaving
			NotifyNeedRepath();

			return;
		}
		else
		{
			// Update the cost of this door marker based on the number queued
			DoorMarker.UpdatePathingCost( AttackerCount + (DoorEnemy != Door ? 1 : 0), QueuedCount );
		}
	}

	`AILog( GetFuncName()$"() initializing AICommand_Attack_Melee, MoveTarget: "$MoveTarget$" Dist: "$VSize( Door.MyMarker.Location - Pawn.Location ), 'Doors' );

	/** Sets the pending door for reference */
	PendingDoor		  = Door;
	/** DoorEnemy is used by attack code */
	DoorEnemy		  = Door;
	/** When opened (or destroyed), a KFDoorActor will notify any AIControllers (with "bMonitorDoor" true) that it's opened/closed status has changed */
	Door.bMonitorDoor = true;
	/** Prevents any latent movement while true */
	bPreparingMove	  = true;

	/** Stop moving and face the door */
	StopAllLatentMovement();
	AIZeroMovementVariables();
	Focus = Door;

	SMFlags = 255;
	/** Try to get a valid door attack from my pawn's AnimInfo */
	SMFlags = class'KFSM_DoorMeleeAttack'.static.PackSMFlags( MyKFPawn );
	if( SMFlags != 255 )
	{
		class'AICommand_Attack_Melee'.static.Melee( self, Door, SMFlags );
	}
	else
	{
		class'AICommand_Attack_Melee'.static.Melee( self, Door );
	}
}

/** Can be called to initiate a melee attack on a non-pawn attack target, like a destructible actor.
	Currently called from FleshPound's Bump() if the bumped-into actor is destructible. */
function NotifyAttackActor( Actor A )
{
	if( !MyKFPawn.IsDoingSpecialMove() )
	{
		ActorEnemy = A;
		StopAllLatentMovement();
		AIZeroMovementVariables();

		bPreparingMove = true;
		Focus = A;
		class'AICommand_Attack_Melee'.static.Melee( self, A );
	}
}

function bool CanAttackDestructibles()
{
	return bCanDoHeavyBump;
}

/*********************************************************************************************
* Dead State
**********************************************************************************************/

State Dead
{
	ignores SeePlayer, HearNoise, KilledBy;

	function BeginState( name PreviousStateName )
	{
		`AILog( "DEAD", 'Damage' );
		super.BeginState( PreviousStateName );
	}
}

/*********************************************************************************************
*   DebugState - Add "`DEBUGSTATE" to state declaration to make that state descend from
*		this, which will then log any related state transitions for it, assuming you're
*		calling the super version if you override any of these functions/events in your own
*		state.
********************************************************************************************* */

state DebugState
{
	function BeginState( Name PreviousStateName )
	{
		`AILog( "BEGINSTATE"@PreviousStateName, 'State' );
	}

	function EndState( Name NextStateName )
	{
		`AILog( "ENDSTATE"@NextStateName, 'State' );
	}

	function PushedState()
	{
		`AILog( "PUSHED", 'State' );
	}

	function PoppedState()
	{
		`AILog( "POPPED", 'State' );
	}

	function ContinuedState()
	{
		`AILog( "CONTINUED", 'State' );
	}

	function PausedState()
	{
		`AILog( "PAUSED", 'State' );
	}
}

/** Log the NPC's routecache (list of navigation points to traverse for current path, if any) */
final function DebugLogRoute()
{
`if(`notdefined(ShippingPC))
	local String RouteString;
	local int i;

	for( i = 0; i < RouteCache.Length; i++ )
	{
		RouteString = "DebugLogRoute()";
		if( Pawn.Anchor != none )
		{
			RouteString = RouteString$" [Anchor:"$Pawn.Anchor$"][Dist:"$VSize(Pawn.Anchor.Location - Pawn.Location)$"]";
		}
		RouteString = RouteString$"[RC "$i$":"$RouteCache[i]$"]";
		if( i + 1 < RouteCache.Length )
		{
			RouteString = RouteString$",";
		}
	}
	if( RouteCache.Length == 0 )
	{
		RouteString = "Empty Route";
	}
	else
	{
		`AILog( "DebugLogRoute(): "$RouteString, 'PathWarning',,, true );
	}
`endif
}

/*********************************************************************************************
*  Action_Idle State - default state this controller uses while pawn is active
********************************************************************************************* */

state Action_Idle `DEBUGSTATE
{
	event BeginState(Name PreviousStateName)
	{
		Super.BeginState( PreviousStateName );

		Enable( 'SeePlayer' );
		`AILog( "Entering Action_Idle() state, previous state was "$PreviousStateName, 'Action_Idle' );

		if( Pawn != none )
		{
			`AILog( "Action_Idle BeginState() calling Pawn.ZeroMovementVariables()", 'Action_Idle' );
			AIZeroMovementVariables();
		}
	}

	function ContinuedState()
	{
		Super.ContinuedState();

		if( Pawn != none )
		{
			`AILog( "Action_Idle ContinuedState() calling Pawn.ZeroMovementVariables()", 'Action_Idle' );
			AIZeroMovementVariables();
		}
	}

	event EndState( name NextStateName )
	{
		Super.EndState( NextStateName );

		`AILog( "Ending Action_Idle state and going to "$NextStateName, 'Action_Idle' );
	}

Begin:
	Sleep(0.f);
	// Wait until Emerge SpecialMove is complete before beginning state code
	// 8/5/14: Wait for all special moves! (fixes knockdown bug)
	// @todo: Needs AI review. Setting PHYS_Walking below is unsafe and causing
	//	special move errors. Doing this wait before WaitForLanding is also unsafe
	if( MyKFPawn == none || MyKFPawn.Health <= 0 || MyKFPawn.IsDoingSpecialMove() )
	{
		Sleep( 0.1f );
		Goto( 'Begin' );
	}
	`AILog( self$" -- Begin Label", 'Action_Idle' );
	if( Pawn != none && Pawn.Physics == PHYS_Falling )
	{
		AIActionStatus = "Falling";
		WaitForLanding();
	}
	if( !MyKFPawn.bCrawler || !bSpawnedByEmergeSpecialMove )
	{
		Pawn.SetPhysics( PHYS_Walking );
	}

	// Begins the debug command (can be customized) if flag is set.
	if( bForceDebugCommand )
	{
		BeginDebugCommand();
		// Stop state code execution here so that no other commands will be loaded.
		Stop;
	}

	// Auto-acquire an enemy even if it's not visible to my pawn. This also will
	// start up the MoveToEnemy command if a valid enemy is found.
    Goto('IdleMoveToNearestEnemy');

IdleMoveToNearestEnemy:
	if( bIdleMoveToNearestEnemy )
	{
		if( Physics == PHYS_Falling )
		{
			WaitForLanding();
		}

		//SetEnemy( GetClosestEnemy() );
		if( !FindNewEnemy() )
		{
			// Fallback
			SetEnemy( GetClosestEnemy() );
		}

		if( Enemy != none )
		{
			`AILog( self$" -- GetClosestEnemy() returned "$Enemy, 'Action_Idle' );
			AIActionStatus = "Starting to hunt";
			BeginCombatCommand( GetDefaultCommand(), "Initial aggressive move" );
			Stop;
		}
		else
		{
			`AILog( self$" Pausing and going back to begin label - haven't found an enemy yet.", 'Action_Idle' );
			AIActionStatus = "Can't find an enemy!";
// 			if( bSpawnedByEmergeSpecialMove || MySpawnVolume != none )
// 			{
// 				// Only sleep for a frame if spawned using Emerge special move
// 				Sleep( 0.f );
// 			}
// 			else
// 			{
				Sleep( 0.5f + FRand() * 1.5f );
//			}
		}
	}
	else
	{
		`AILog( self$" Not moving yet because bIdleMoveToNearestEnemy is false", 'Action_Idle' );
		Sleep( 0.25f + FRand() * 0.5f );
	}
	Goto('Begin');
}

function float GetMinDistanceToAnyPlayer()
{
	local PlayerController PC;
	local float MinRange;
	local float CurRange;

	MinRange = -1.f;
	if( Pawn == none )
	{
		return -1.f;
	}

	ForEach WorldInfo.AllControllers( class'PlayerController', PC )
	{
		if ( PC != none && PC.ViewTarget != None )
		{
			CurRange = VSizeSq( PC.ViewTarget.Location - Pawn.Location );
			if( CurRange < MinRange || MinRange < 0.f )
			{
				MinRange = CurRange;
			}
		}
	}

	return sqrt( MinRange );
}

function NotifyEnRaged( bool bEnraged );

//If this function returns true, use the AI controller's spawn enrage.
//      If this is false, recommended to use the direct call into the pawn.
function bool SpawnEnraged()
{
    return false;
}

function ResetKFAIC()
{
	if( MyKFPawn != none && MyKFPawn.IsDoingSpecialMove() )
	{
		MyKFPawn.EndSPecialMove();
		SetTimer( 0.1, false, nameof(ResetKFAIC), self );
		return;
	}
	AIZeroMovementVariables();
	StopLatentExecution();
	StopAllLatentMovement();

	Enemy					 = none;
	DoorEnemy				 = none;
	CachedVisibleEnemy		 = none;
	MeleeTarget				 = none;
	MoveTarget				 = none;
	MoveGoal				 = none;
	LastHitWall				 = none;
	PendingDoor				 = none;
	RouteGoal				 = none;
	MoveFailureCount		 = 0;
	FailedMoveToEnemyCount	 = 0;
	HitWallCount			 = 0;
	RouteCache.Length		 = 0;
	LastTauntTime			 = 0.f;
	LastNotifyHitWallTime	 = 0.f;
	LastBumpTime			 = 0.f;
	LastObstructionTime		 = 0.f;
	MoveTimer				 = -1.f;
	bHasDebugCommand		 = false;
	bPreparingMove			 = false;
	bAdjusting				 = false;
	bReevaluatePath			 = false;
	IsRotationLocked		 = false;
	bEnemyIsVisible			 = false;
	bReachedLatentMoveGoal	 = false;
	LockedRotation			 = rot(0,0,0);

	// Init AI Steering object in 1-3 seconds
	SetTimer( RandRange(1, 3), false, nameof(StartSteering) );
	BeginCombatCommand( None, "Reset" );
}

/*********************************************************************************************
*  Victory
********************************************************************************************* */

/** Enter this state when the match is over and the zeds have won */
state ZedVictory
{
	function bool GetIsInZedVictoryState()
	{
		return true;
	}

	function bool CanDoStrike()
	{
		return false;
	}

	event bool CanGrabAttack()
	{
		return false;
	}

	Begin:
	DisableMeleeRangeEventProbing();
	if(FRand() <= 0.6f)
	{
		if(FRand() <= 0.5f)
		{
        	class'AICommand_TauntEnemy'.static.Taunt(self, none, TAUNT_EnemyKilled );
		}
		else
		{
			class'AICommand_TauntEnemy'.static.Taunt( self, none, TAUNT_Standard );
		}
	}
	else
	{
		DoWander( Pawn,, true );
	}

	Sleep(0.f);
	if( MyKFPawn == none || MyKFPawn.Health <= 0 || MyKFPawn.IsDoingSpecialMove() )
	{
		Sleep( 0.1f );
		Goto( 'Begin' );
	}
	if( Pawn != none && Pawn.Physics == PHYS_Falling )
	{
		AIActionStatus = "Falling";
		WaitForLanding();
	}

    Goto('Begin');
}

function bool GetIsInZedVictoryState()
{
	return false;
}

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

	GotoState( 'ZedVictory' , 'Begin');
}

/*********************************************************************************************
 View and Rotation related functions
********************************************************************************************* */

// Use where the bot is actually looking from
simulated event GetPlayerViewPoint(out vector out_Location, out Rotator out_Rotation)
{
	GetActorEyesViewPoint( out_Location, out_Rotation );
}

/*********************************************************************************************
* Enemy Threat Evaluations [EXPERIMENTAL, has not been in use, but if we want more intelligent
* NPC decisions regarding threat evaluation, the below two functions are worth trying out.
********************************************************************************************* */

/** Experimental - scores potential new enemy based on many conditions:
	Distance
	Is CheckPawn moving toward or away from me?
	Am I currently visible to CheckPawn?
	Have I recently taken damage from CheckPawn? */
event float EvaluateThreatFrom( Pawn CheckPawn, optional float EarlyOutScore )
{
	local KFPawn Threat;
	local float DistToThreat, ThreatScore;
	local int RecentDamageFromThreat; //ZedsTargetingThreat;
	local string outmsg;
	local float modscore, Dot;
	local vector Loc;
	local rotator Rot;
	local float DistScore;
	local float ClosestDist;
	local float Time;

	Threat = KFPawn(CheckPawn);

	RecentDamageFromThreat = MyKFPawn.RecentDamageFrom(Threat);
	DistToThreat = VSize( Threat.Location - Pawn.Location );
	// Count # of Zeds who are currently targeting CheckPawn and closer to CheckPawn than I am
	//ZedsTargetingThreat = NumberOfZedsTargetingPawn( Threat, true, DistToThreat * 1.75f );

	if( CheckPawn.IsHumanControlled() && CheckPawn.PlayerReplicationInfo != none )
	{
		outmsg = "["$CheckPawn.PlayerReplicationInfo.PlayerName$"] THREATSCORE";
	}
	else
	{
		outmsg = "["$CheckPawn$"] THREATSCORE";
	}

	if( DistToThreat < 2500.f )
	{
		ThreatScore += (2500.f - DistToThreat)/2500.f;
		DistScore = ThreatScore;
	}

	if( MyKFPawn.IsPawnMovingTowardMe(Threat, 300.f) )
	{
		modscore = 0.12f * DistScore;
		outmsg = outmsg$" [MOVING TOWARD ME SCORE: "$modscore$"]";
		ThreatScore += 0.12f * DistScore;
		GetClosestTimeAndDistToPawn(Threat, Time, ClosestDist);
		if( Time > 0.f && Time < 2.5f && ClosestDist < 250.f )
		{
			modscore = (2.5f - Time)/2.5f;
			ThreatScore += modscore;
			outmsg = outmsg$" [TIME TO ENEMY: "$modscore$" TIME: "$Time$"]";
		}
	}
	else if( MyKFPawn.IsPawnMovingAwayFromMe(Threat, 300.f) )
	{
		modscore = -0.15f * (1/DistScore);
		outmsg = outmsg$" [MOVING AWAY SCORE: "$modscore$"]";
		ThreatScore -= 0.15f * (1/DistScore);
	}
	if( Threat.Controller.CanSee(Pawn) )
	{
		Threat.Controller.GetPlayerViewPoint( Loc, Rot );
		Dot = Normal( Pawn.Location - Loc ) dot vector(Rot);
		if( Dot > 0.7f )
		{
			//modscore = 1.f - Dot;
			modscore += Dot * DistScore;
			ThreatScore += Dot * DistScore;
		}
		else
		{
			modscore = 0.1f;
			ThreatScore -= 0.1f;
		}
		//msg( "[Dot: "$Dot$"] TEST: "$modscore$" versus further scaled "$modscore * (DistScore * 0.88f)$"... dist score was "$DistScore$" Dist: "$DistToThreat );
		outmsg = outmsg$" [DOT: "$DOT$" AIMING AT SCORE: "$modscore$"]";
	}
	else
	{
		ThreatScore -= 0.12f * ( 1/DistScore );
		modscore = 0.12f * (1/DistScore);
		outmsg = outmsg$" [CANT SEE YOU PENALTY:"$modscore$" DIST SCORE WAS "$DistScore$"]";
	}
	if( RecentDamageFromThreat > 0 )
	{
		modscore = float(RecentDamageFromThreat)/float(MyKFPawn.HealthMax);
		outmsg = outmsg$" [RECENT DAMAGE:"$RecentDamageFromThreat$" SCORE: "$modscore$"]";
		ThreatScore += float(RecentDamageFromThreat)/float(MyKFPawn.HealthMax);
	}
	//VSize(Pawn.Velocity) > 0.f &&

	//FLOAT DistanceRating = 1 - ActorToLookAt->LastKnownDistance/LookAtActorRadiusSq;
	outmsg = "FINAL SCORE: "$ThreatScore$"..."$outmsg;
	msg( Threat.PlayerReplicationInfo.PlayerName$": "$outmsg );
	return ThreatScore;
}

/** if bDebug_ShowStrikeRange is true, draw the range of every zed around its pawn */
event DrawStrikeRanges()
{
	local KFPawnAnimInfo KFPAI;
	local byte i;

	if( MyKFPawn != none && MyKFPawn.PawnAnimInfo != none )
	{
		KFPAI = MyKFPawn.PawnAnimInfo;

		// Draw inactive ranges first
		for( i = 0; i < MyKFPawn.PawnAnimInfo.Attacks.length; i++ )
		{
			if( i != PendingAnimStrikeIndex &&
				(bDebug_ShowAllStrikeRange || KFPAI.AllowAttackByDifficulty(i) && KFPAI.AllowAttackByMovement( i, MyKFPawn )) )
			{
				// Give different colors for the different unused attacks
				DrawStrikeRange(i, KFPAI, MakeColor(255 - i * 20, 0, i * 20, 255 ));
			}
		}

		// Draw pending attack range
		if( PendingAnimStrikeIndex != 255)
		{
			DrawStrikeRange(PendingAnimStrikeIndex, KFPAI, MakeColor(255,255,0,255));
		}

        // Draw the StrikeRange in black. This is the range between min and max multiplied by the StrikeRangePercentage
		DrawStrikeRangeLines( MyKFPawn.Location, MyKFPawn.Rotation, 1.57, 0, StrikeRange, MakeColor(0,0,0,255) );
		DrawStrikeRangeLines( MyKFPawn.Location, MyKFPawn.Rotation, 0, 1.57, StrikeRange, MakeColor(0,0,0,255) );

		// Draw Current Attack
		if( MyKFPawn != none && MyKFPawn.IsDoingSpecialMove(SM_MeleeAttack))
		{
			DrawStrikeRange(DebugCurrentStrikeIndex, KFPAI, MakeColor(0,255,0,255));
		}

        // Draw a line for the max hit range
		DrawMaxHitRange(MakeColor(0,255,0,255));
	}
}

function DrawStrikeRange( byte Index, KFPawnAnimInfo KFPAI, Color ZoneColor )
{
	local float MinDistance, MaxDistance, AverageDistance, CollisionRadius;
	local string TagString;

	CollisionRadius = MyKFPawn.CylinderComponent.CollisionRadius;

	MinDistance = ( KFPAI.Attacks[Index].MinDistance < CollisionRadius ) ? CollisionRadius : KFPAI.Attacks[Index].MinDistance;
	MaxDistance = KFPAI.Attacks[Index].MaxDistance;
	AverageDistance = KFPAI.GetMedianStrikeRange(Index, 0.5f, CollisionRadius);

	TagString = String(KFPAI.Attacks[Index].Tag);

	// Draws backwards
	DrawStrikeRangeLines( MyKFPawn.Location, MyKFPawn.Rotation, 1.57, 0, MaxDistance, ZoneColor );
	DrawStrikeRangeLines( MyKFPawn.Location, MyKFPawn.Rotation, 1.57, 0, MinDistance, ZoneColor );
	// Draws forwards
	DrawStrikeRangeLines( MyKFPawn.Location, MyKFPawn.Rotation, 0, 1.57, MaxDistance, ZoneColor );
	DrawStrikeRangeLines( MyKFPawn.Location, MyKFPawn.Rotation, 0, 1.57, MinDistance, ZoneColor );

	DrawAttackRangeText( Index, 40960, 2048, AverageDistance, TagString, ZoneColor);
}

event DrawStrikeRangeLines( Vector OrginOfStrikeZone,
						 Rotator RotOrginOfZone,
						 float StartAngleInRads,
						 float EndAngleInRads,
						 float RangeOfZone,
						 Color ZoneColor )
{
	local Vector arcRightInnerLineEnd;
	local Vector arcMidRightLineEnd;
	local Vector arcFarRightLineEnd;

	local Vector arcLeftInnerLineEnd;
	local Vector arcMidLeftLineEnd;
	local Vector arcFarLeftLineEnd;

	local Rotator arcRightInnerEdge;
	local Rotator arcMidRightEdge;
	local Rotator arcFarRightEdge;

	local Rotator arcLeftInnerEdge;
	local Rotator arcMidLeftEdge;
	local Rotator arcFarLeftEdge;

	local int innerHorArcInUU;
	local int farHorArcInUU;
	local int midHorArcInUU;

	local float verticalShiftForZoneLines;

	verticalShiftForZoneLines = MyKFPawn.CylinderComponent.CollisionHeight;
	OrginOfStrikeZone.Z = OrginOfStrikeZone.Z - verticalShiftForZoneLines;

	innerHorArcInUU = StartAngleInRads * 10430.2192;
	farHorArcInUU = EndAngleInRads * 10430.2192;
	midHorArcInUU = ((farHorArcInUU - innerHorArcInUU) * 0.5) + innerHorArcInUU;

	//
	// Inner Right Edge
	//
	arcRightInnerEdge = MakeRotator(0, RotOrginOfZone.Yaw + innerHorArcInUU, 0);
	arcRightInnerLineEnd = OrginOfStrikeZone+ Vector(arcRightInnerEdge) * RangeOfZone;

	//
	// far right edge
	//
	if( farHorArcInUU > 0 )
	{
		arcFarRightEdge = MakeRotator(0, RotOrginOfZone.Yaw + farHorArcInUU, 0);
		arcFarRightLineEnd = OrginOfStrikeZone + Vector(arcFarRightEdge) * RangeOfZone;
		//MyKFPawn.DrawDebugLine(OrginOfStrikeZone , arcFarRightLineEnd, ZoneColor.R, ZoneColor.G, ZoneColor.B );
	}
	else
	{
		midHorArcInUU = ( ( 32767 - innerHorArcInUU)  * 0.5) + innerHorArcInUU;
		arcFarRightEdge = MakeRotator(0, RotOrginOfZone.Yaw + 32767, 0);
		arcFarRightLineEnd = OrginOfStrikeZone + Vector(arcFarRightEdge) * RangeOfZone;
	}

	//
	// Mid right edge
	//
	arcMidRightEdge = MakeRotator(0, RotOrginOfZone.Yaw + midHorArcInUU, 0);
	arcMidRightLineEnd = OrginOfStrikeZone + Vector(arcMidRightEdge) * RangeOfZone;

	//
	// Inner left Edge
	//
	arcLeftInnerEdge = MakeRotator(0, RotOrginOfZone.Yaw - innerHorArcInUU, 0);
	arcLeftInnerLineEnd = OrginOfStrikeZone+ Vector(arcLeftInnerEdge) * RangeOfZone;

	//
	// Far left edge line
	//
	if( farHorArcInUU > 0 )
	{
		arcFarLeftEdge = MakeRotator(0, RotOrginOfZone.Yaw - farHorArcInUU, 0);
		arcFarLeftLineEnd = OrginOfStrikeZone + Vector(arcFarLeftEdge) * RangeOfZone;
		//MyKFPawn.DrawDebugLine( OrginOfStrikeZone , arcFarLeftLineEnd, ZoneColor.R, ZoneColor.G, ZoneColor.B );
	}
	else
	{
		arcFarLeftEdge = MakeRotator(0, RotOrginOfZone.Yaw - 32767, 0);
		arcFarLeftLineEnd = OrginOfStrikeZone + Vector(arcFarLeftEdge) * RangeOfZone;
	}

	//
	// Mid left edge line
	//
	arcMidLeftEdge = MakeRotator(0, RotOrginOfZone.Yaw - MidHorArcInUU, 0);
	arcMidLeftLineEnd = OrginOfStrikeZone + Vector(arcMidLeftEdge) * RangeOfZone;

	//
	// connect far right to middle right to inner right
	//
	MyKFPawn.DrawDebugLine( arcFarRightLineEnd, arcMidRightLineEnd, ZoneColor.R, ZoneColor.G, ZoneColor.B );
	MyKFPawn.DrawDebugLine( arcRightInnerLineEnd, arcMidRightLineEnd, ZoneColor.R, ZoneColor.G, ZoneColor.B );


	//
	// connect far left to middle left to inner left
	//
	MyKFPawn.DrawDebugLine( arcFarLeftLineEnd, arcMidLeftLineEnd, ZoneColor.R, ZoneColor.G, ZoneColor.B );
	MyKFPawn.DrawDebugLine( arcLeftInnerLineEnd, arcMidLeftLineEnd, ZoneColor.R, ZoneColor.G, ZoneColor.B );
}

function DrawAttackRangeText( byte Index, float StartingAngle, float RotationInterval, float MedianMeleeRange, string Text, Color TextColor )
{
	local Vector TextLocation;
	local Rotator DrawDirection;
	local int RotationOffset;

	RotationOffset = RotationInterval * Index ;

	StartingAngle = MyKFPawn.Rotation.Yaw - StartingAngle + RotationOffset;
	DrawDirection = MakeRotator(0, StartingAngle, 0);

	TextLocation = MyKFPawn.Location + Vector(DrawDirection) * MedianMeleeRange;
	TextLocation.Z -= MyKFPawn.CylinderComponent.CollisionHeight;

	// Draw the textfield in world
	GetALocalPlayerController().AddDebugText(Text, WorldInfo, 0.02 * WorldInfo.TimeDilation, TextLocation, TextLocation, TextColor, true, true);
}

function DrawMaxHitRange( Color LineColor )
{
	local Rotator ZedRotation;
	local Vector LineStart, LineEnd;

	// Draw the MeleeHitRange also
	ZedRotation = MakeRotator(0, MyKFPawn.Rotation.Yaw, 0);
	LineStart = MyKFPawn.Location;
	LineStart.Z -= MyKFPawn.CylinderComponent.CollisionHeight;
	LineEnd = LineStart + Vector(ZedRotation) * MyKFPawn.MeleeAttackHelper.GetMeleeRange();

	MyKFPawn.DrawDebugLine( LineStart , LineEnd, LineColor.R, LineColor.G, LineColor.B );
}

/** Shows this KFAIController's AICommand stack on screen (see ShowAIInfo cheat) */
function GetCommandStack( HUD Hud, out array<string> OverheadTexts, out array<Color> OverheadColors )
{
	local int			CmdCnt;
	local GameAICommand	Cmd;
	local String CommandText;
	local bool bShowCommands, bShowMovement;
	local int i;
	local string T;
    local AICommand_Wander WanderCommand;

	if( HUD.ShouldDisplayDebug('AllVerbose') )
	{
		bShowCommands = true;
        bShowMovement = true;
	}

	if( HUD.ShouldDisplayDebug('All') )
	{
		bShowCommands = true;
        bShowMovement = true;
	}

	if( HUD.ShouldDisplayDebug('AICommands') )
	{
		bShowCommands = true;
	}

	if( HUD.ShouldDisplayDebug('AIMovement') || HUD.ShouldDisplayDebug('AIPathing') )
	{
		bShowMovement = true;
	}

	if( MyKFPawn == none )
	{
		return;
	}

	if ( bShowMovement || HUD.ShouldDisplayDebug('AI') || HUD.ShouldDisplayDebug('AIMovementVerbose') )
	{
		CommandText = "---------- AI General ----------\n";

		if ( Enemy != None )
		{
			 CommandText = CommandText@"STATE: "$GetStateName()$" Enemy "$Enemy.GetHumanReadableName()$"\n";
		}
		else
		{
			CommandText = CommandText@"STATE: "$GetStateName()$" NO Enemy "$"\n";
		}

        if( HUD.ShouldDisplayDebug('AI') || HUD.ShouldDisplayDebug('AIMovementVerbose') )
        {
    		CommandText = CommandText@"Anchor: "$Pawn.Anchor$" Serpentine Dist: "$Pawn.SerpentineDist$" Time: "$Pawn.SerpentineTime$"\n";

    		if ( (Pawn != None) && (MoveTarget != None) && Pawn.ReachedDestination(MoveTarget) )
    		{
                CommandText = CommandText@"Skill: "$Skill$" NAVIGATION MoveTarget: "$GetItemName(String(MoveTarget))$"(REACHED) MoveTimer: "$MoveTimer$"\n";
    		}
    		else
    		{
                CommandText = CommandText@"Skill: "$Skill$" NAVIGATION MoveTarget: "$GetItemName(String(MoveTarget))$" MoveTimer: "$MoveTimer$"\n";
            }

    		CommandText = CommandText@"Destination: "$GetDestinationPosition()$" Focus: "$GetItemName(string(Focus))$" Preparing Move: "$bPreparingMove$"\n";

    		CommandText = CommandText@"RouteGoal: "$GetItemName(string(RouteGoal))$" RouteDist: "$RouteDist$"\n";

    		for ( i=0; i<RouteCache.Length; i++ )
    		{
    			if ( RouteCache[i] == None )
    			{
    				if ( i > 5 )
    					T = T$"--"$GetItemName(string(RouteCache[i-1]));
    				break;
    			}
    			else if ( i < 5 )
    				T = T$GetItemName(string(RouteCache[i]))$"-";
    		}

            CommandText = CommandText@"RouteCache: "$T$"\n";
        }

        OverheadTexts[OverheadTexts.Length] = CommandText;
        OverheadColors[OverheadTexts.Length - 1] = MakeColor(0,200,50);
        CommandText = "";
	}

    if( bShowMovement )
    {
    	CommandText = "---------- AI MOVEMENT ----------\n";
        if( IntermediateMoveGoal != none )
    	{
    		CommandText = CommandText@"IntermediateMoveGoal:"$IntermediateMoveGoal$"\n";
    	}

    	if( MoveTarget != none )
    	{
    		CommandText = CommandText@"MoveTarget:"$MoveTarget$"\n";
    	}

        WanderCommand = FindCommandOfClass(class'AICommand_Wander');

        if( WanderCommand != none )
        {
            CommandText = CommandText@"AIC Wander Timer:"$GetRemainingTimeForTimer('Timer_WanderDurationExpired', WanderCommand)$"\n";
        }

        OverheadTexts[OverheadTexts.Length] = CommandText;
	}

    if( bShowCommands )
    {
        CommandText = "---------- AI Commands ----------\n";
    	if( AIActionStatus != "" )
    	{
    		CommandText = CommandText@"Status:"$AIActionStatus$"\n";
    	}
	}

    if(  bShowMovement || bShowCommands )
    {
    	if( MyKFPawn.SpecialMove != SM_None )
    	{
    		CommandText = CommandText@"SpecialMove:"$MyKFPawn.SpecialMove$"\n";
    	}
    	else
    	{
    		CommandText = CommandText@"SpecialMove: NONE \n";
    	}
	}

	OverheadTexts[OverheadTexts.Length] = CommandText;
	OverheadColors[OverheadTexts.Length - 1] = MakeColor(0,200,50);

    if( bShowCommands )
	{
        CommandText = "-- AICommand History --";
        OverheadTexts[OverheadTexts.Length] = CommandText;
        OverheadColors[OverheadTexts.Length - 1] = MakeColor(0,255,0);

    	foreach AllCommands( class'GameAICommand', Cmd )
    	{
    		if( Cmd.ChildCommand == None )
    		{
                CommandText = String(Cmd.Name)@":"@Cmd.GetStateName();
                OverheadTexts[OverheadTexts.Length] = CommandText;
                OverheadColors[OverheadTexts.Length - 1] = MakeColor(0,255,0);
    		}
    		else
    		{
                CommandText = String(Cmd.Name)@":"@Cmd.GetStateName();
                OverheadTexts[OverheadTexts.Length] = CommandText;
                OverheadColors[OverheadTexts.Length - 1] = MakeColor(255,128,0);
    		}
    		CmdCnt++;
    	}
    	if( CmdCnt == 0 )
    	{
            CommandText = "No Active Command";
            OverheadTexts[OverheadTexts.Length] = CommandText;
            OverheadColors[OverheadTexts.Length - 1] = MakeColor(0,200,50);
    	}
	}
}

DefaultProperties
{
	// ---------------------------------------------
	// Combat
	MeleeCommandClass=class'KFGame.AICommand_Base_Zed'
	bAllowCombatTransitions=true
	bIdleMoveToNearestEnemy=true
	MinTimeBetweenEnemyChanges=5f
	DoorMeleeDistance=200.f
	MaxMeleeHeightAngle=0.64f
	MaxGetStrikeTime=0.25f
	MinDistanceToAggroZed=1500
	PendingAnimStrikeIndex=255
	bCanDoHeavyBump=false
	ZedBumpEffectThreshold=270
	ZedBumpObliterationEffectChance=0.4
	AIRemainingTeleportThreshold=12.0
	FrustrationThreshold=5.f
	FrustrationDelay=2.5f
	LastFrustrationCheckTime=0.f
	LowIntensityAttackCooldown=2.0
	//bUseOldAttackDecisions=true
	CanForceEnemy=true
	ForcedEnemy=none
	LastForcedEnemy=none
	ForcedEnemyLastTime=0.f
	DamageRatioToChangeForcedEnemy=0.5f
	TimeCanRestartForcedEnemy=10.f
	TimeCannotChangeFromForcedEnemy=10.f

	// ---------------------------------------------
	// AI / Navigation
	MaxBlockedPathDuration=30.f
	bCanDoSpecial=true
	InUseNodeCostMultiplier=3.f
	bProbeNotifyOnAddToRouteCache=false // 7/1/14
	DirectPathExtentModifier=1.f
	DirectPathCheckFrequency_Min=0.1f
	DirectPathCheckFrequency_Max=0.3f
	bDisablePartialPaths=false
	RepeatWalkingTauntTime=15
	EvadeGrenadeChance=1.0f

	// ---------------------------------------------
	// Movement
	RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)
	MaxStepAsideDist=128.0
//   	Begin Object Class=KFAISteering Name=Steering0
//   		End Object
//   	Steering=Steering0
	RotationRateMultiplier=1.f
	bIgnoreStepAside=true // 3.1.2014
	MinTimeBetweenLOSChecks=4.f
	//bNotifyApex=true

	// optimization - simplify LineOfSight/SeePlayer line traces
	bSkipExtraLOSChecks=true
	bDumpCommandHistoryOnExit=false
	bUseDesiredRotationForMelee=true
	BumpThreshold=10f
	BumpDecayRate=0.5f
	BumpGrowthRate=10.0f
	bNotifyFallingHitWall=true

    // No navigation handle right now since we are doing path nodes
	NavigationHandleClass=none//class'KFNavigationHandle'

	CurrentMovementPhase = MOVEMENT_PHASE_TYPE_NONE;

	//bGoToEnemiesOutsideNavmesh=true
	//MovementPluginClass="KFAIPluginMovement_Recast"
	//LeapPluginClass="KFAIPluginLeap"
	//StuckFixPluginClass="KFAIPluginStuckFix"
	KfWallWalkingPlugIn=None

	//============================================
	//  Movement/Path Paramaters
	//============================================
	bAlwaysAcceptPartialPaths=true
	bShouldUsePathLanes=true
	bShouldOffsetCorners=false
	//bDebugDisableSprinting=false
	DistanceToCheckForClearPathOnNavMeshLocWhenOffNavMesh=512
	DistanceToCheckForNonExploitedOnNavMeshLocWhenOffNavMesh=2056
	DistanceToCheckForNonExploitedOnNavMeshLocWhenOnDeadEndOfNavMesh=512
	DistanceToCheckForClearPathOnNavMeshLocWhenEnemyIsOffNavMesh=200
	DistanceToCheckForNonExploitedOnNavMeshLocWhenEnemyIsOffNavMesh=500
	GeneralGoalDistanceForMovingToDoor=256
	RecastEnemyRepathDistance=512

	DropEdgeLeapVelocity=(X=400,Y=0,Z=400)
	MaxRangeToDropEdgeAllowedToLeadFrom=100
	DistanceDownRangeToFocusForDropEdgeLeap=1000

	//============================================
	//  General AI System Paramaters
	//============================================

	DefaultMaxTimeAllowedToStayStuckBeforeSuicide=5.0
	NoNavMeshPathMaxTimeAllowedToStayStuckBeforeSuicide=1.0
	SameIntermediatePointToManyTimesMaxTimeAllowedToStayStuckBeforeSuicide=5.0
	TargetOffNavMeshAndCanNotFindLocaitonNearThemICanMoveTooMaxTimeAllowedToStayStuckBeforeSuicide=5.0
	SameIntermediatePointToManyTimesDurationAfterStartedMovingAgaintToStopStuckCheck=10.0
	DefaultMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide=5.0
	NoNavMeshPathMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide=1.0
	SameIntermediatePointToManyTimesMinDistaceToHaveToMoveToBeConcideredStuckBeforeSuicide=200.0
	GoalDistanceWhenMovingToLocationForMeleeStrikeWhenEnemyIsOffNavMesh=0

	bSpecialBumpHandling=true
	bUseNavMesh=false
	bUsePluginsForMovement=false

	//
	/////
	//

	MovementPhaseTypeUnknownIcon=Texture2D'AI_Debug_Helpers.UnknownMovementPhase'

    MovementPhaseTypePathNodeNormalMoveToIcon=Texture2D'AI_Debug_Helpers.MapIcon_PathNodeMoveTo'
    MovementPhaseTypePathNodeMoveFailedIcon=Texture2D'AI_Debug_Helpers.MapIcon_FailedMove'
    MovementPhaseTypePathNodeMoveToPointIcon=Texture2D'AI_Debug_Helpers.MapIcon_MoveToAPoint'
    MovementPhaseTypePathNodeRotateToFocusIcon=Texture2D'AI_Debug_Helpers.MapIcon_RotateToFocus'
    MovementPhaseTypePathNodeDelayMoveIcon=Texture2D'AI_Debug_Helpers.MapIcon_AIDelay'

	MovementPhaseTypeNavMeshNormalMoveToIcon=Texture2D'AI_Debug_Helpers.NavMeshMoveTo'
	MovementPhaseTypeFinalDestMoveTowardsIcon=Texture2D'AI_Debug_Helpers.FinalDestMoveTowards'
	MovementPhaseTypeEMT_LOS_MoveTowardsIcon=Texture2D'AI_Debug_Helpers.LOS_MoveTowards'
	MovementPhaseTypeMovingToNavMeshUsingPathNodesIcon=Texture2D'AI_Debug_Helpers.WallToNavMesh'
	MovementPhaseTypeFALLBACK_REFUSED_TO_BE_EXPLOTIED_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POSIcon=Texture2D'AI_Debug_Helpers.FindNearbyMeshPointRefusedToBeExplotied'
	MovementPhaseTypeFALLBACK_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POSIcon=Texture2D'AI_Debug_Helpers.FindNearbyMeshPoint'

	TypeOfMovementStuckOnUnknownWhyIcon=Texture2D'AI_Debug_Helpers.StuckUnknown'
	TypeOfMovementStuckOnMOVE_FAILURE_TYPE_NO_NAV_MESH_PATHIcon=Texture2D'AI_Debug_Helpers.NoNavStuck'
	TypeOfMovementStuckOnMOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMESIcon=Texture2D'AI_Debug_Helpers.TriskelionStuck'
	TypeOfMovementStuckOnMOVE_FAILURE_TYPE_TARGET_OFF_NAV_MESH_AND_CAN_NOT_FIND_LOCAITON_NEAR_THEM_I_CAN_MOVE_TOIcon=Texture2D'AI_Debug_Helpers.EnemyOffNavMeshAndCanDoNothing'
	TypeOfMovementStuckOnLookingForBetterIntermediateLoc=Texture2D'AI_Debug_Helpers.LookingForBetterInter'
	TypeOfMovementStuckOnMoveToBetterIntermediate=Texture2D'AI_Debug_Helpers.MoveToBetterIntermediate'

	Role=ROLE_Authority

    // Settings this to true so the base KFAIController gets a PRI, etc
	bIsPlayer=true

	// ---------------------------------------------
	// Behaviors
	BaseShapeOfProjectileForCalc=(X=1,Y=1,Z=1)
	AggroPlayerHealthPercentage=0.1
	AggroPlayerResetTime=10
	AggroZedResetTime=30
	AggroZedHealthPercentage=0.15
	AggroEnemySwitchWaitTime=5.f

	// Don't always assign an enemy in the BaseAIController native code. Let the script code handle it!!!
	bAlwaysAssignEnemy=false


	StuckCheckInterval=0.5
	StuckVelocityThreshholdSquared=625 //(25 UUS)
	StuckPossiblityThreshhold=5.0
	XYMoveStuckThresholdSquared=625 //(25 UUS)
	StuckCheckEnemyDistThreshholdSquared=1000000 // 10 meters
	NavigationBumpTeamCollisionThreshholdSquared=1000000 // 10 meters

	bCanTeleportCloser=true
	TeleportCheckInterval=1.0
	TeleportCooldown=7.0
	HiddenRelocateTeleportThreshold=5.0
	PostSpawnRelocateTeleportCooldown=10

	StrikeRangePercentage=0.85
}
