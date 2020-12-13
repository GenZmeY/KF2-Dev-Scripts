//=============================================================================
// KFAiBehaviorTypes.uc
//=============================================================================
// KFDoorEdge for Macro Pathing
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAiBehaviorTypes extends Object
	native(AI);


enum MOVE_FAILURE_TYPE
{
	MOVE_FAILURE_TYPE_NONE,
	MOVE_FAILURE_TYPE_NO_NAV_MESH_PATH,
	MOVE_FAILURE_TYPE_SAME_INTERMEDIATE_POINT_TOO_MANY_TIMES,
	MOVE_FAILURE_TYPE_TARGET_OFF_NAV_MESH_AND_CAN_NOT_FIND_LOCAITON_NEAR_THEM_I_CAN_MOVE_TO,
	MOVE_FAILURE_TYPE_LOOKING_FOR_BETTER_INTERMEDIATE_LOCATION,
	MOVE_FAILURE_TYPE_MOVING_TO_BETTER_INTERMEDIATE_LOCATION
};

enum MOVEMENT_PHASE_TYPE
{
	MOVEMENT_PHASE_TYPE_NONE,
	MOVEMENT_PHASE_TYPE_NAV_MESH_NORMAL_MOVE_TO,
	MOVEMENT_PHASE_TYPE_PATHNODE_NORMAL_MOVE_TO,
	MOVEMENT_PHASE_TYPE_PATHNODE_POINT_MOVE_TO,
	MOVEMENT_PHASE_TYPE_PATHNODE_DELAY_MOVE,
	MOVEMENT_PHASE_TYPE_PATHNODE_ROTATE_TO_FOCUS,
	MOVEMENT_PHASE_TYPE_PATHNODE_FAILED_MOVE,
	MOVEMENT_PHASE_TYPE_FINAL_DEST_MOVE_TOWARDS,
	MOVEMENT_PHASE_TYPE_EMT_LOS_MOVE_TOWARDS,
	MOVEMENT_PHASE_TYPE_MOVE_TOO_MESH_USING_PATH_NODES,
	MOVEMENT_PHASE_TYPE_FALLBACK_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POS,
	MOVEMENT_PHASE_TYPE_FALLBACK_REFUSED_TO_BE_EXPLOTIED_FIND_NEARBY_MESH_POINT_MOVE_TO_DIRECT_NON_PATH_POS,
	MOVEMENT_PHASE_TYPE_STUCK
};

struct native KFNavMeshMovementStepData
{
	var ENavMeshEdgeType EdgeType;
	var vector EdgeCenter;
	var vector Poly0Center;
	var vector Poly1Center;
	var vector MovementPoint;
	var vector EdgePos1;
	var vector EdgePos2;
	var Color EdgeColor;
};

struct native KFCombatMovementHistoryData
{
	var vector MyPosition;
	var vector EnemyPosition;
	var vector EnemyDisplacement;
	var vector Velocity;
	var vector Acceleration;
	var vector Heading;
	var float DistanceToEnemy;
	var float UpdateTime;
};

enum PATH_FIND_STATUS
{
	PATH_FIND_STATUS_NO_SEARCH,
	PATH_FIND_STATUS_NO_PATH,
	PATH_FIND_STATUS_FOUND_PATH,
};

struct native PathingFlags
{
	var PATH_FIND_STATUS PathToEnemiesLocationStatus;
	var PATH_FIND_STATUS PathToLocationNearEnemyStatus;

	var bool             bLastLatentMoveReportedMoveToLocationUnreachable;

	var bool             bCanNotGetToEnemyLocationBecasuseOfMoveIteruption;
	var bool             bCanNotGetToIntermediateLocationBecasuseOfMoveIteruption;

	var bool             bIamOffNavMesh;
	var bool             bMyEnemyIsOffNavMesh;

	var float            TimeMyEnemyWasLastSetToOffNavMesh;
	var float            TimeIWasLastSetToOffNavMesh;

	var bool             bStuckFixPlugInWantsForceLosMove;
};

//
// Behavior Tree thingys
//

enum EBTGoal
{
	BTG_None,
	BTG_Hide,
	BTG_Guard,
	BTG_Banzai,
	BTG_Support,
};

enum EBodyStance
{
	BS_FullBody,
	BS_FullBody_AI,
	BS_UpperBody,
	BS_Nor_Stopped,
	BS_Nor_Arms,
	BS_Crd_Stopped,
	BS_Crd_Arms,
	BS_Std_Cov_InCover,
	BS_Std_LCov_InCover,
	BS_Mid_Cov_InCover,
	BS_Mid_LCov_InCover,
	BS_Std_Cov_Arms,
	BS_Std_LCov_Arms,
	BS_Mid_Cov_Arms,
	BS_Mid_LCov_Arms,
	BS_Additive_Hits,
};

enum EThrowType
{
	THROW_None,
	THROW_Scripted,
	THROW_Death,
	THROW_Explosion,
	THROW_RBCollision,

	// weapons
	THROW_MeleeHit,
	THROW_HitReaction,
	THROW_Lavagun,
	THROW_Flailgun,
	THROW_Flaregun,
	THROW_Driller,
	THROW_DrillerOvercharge,
	THROW_Shotgun,
	THROW_ShotgunOvercharge,
	THROW_SniperRifle,
	THROW_SniperRifleOvercharge,

	// powers
	THROW_Thumper,
	THROW_ThumperHorizontal,
	THROW_Leash,
	THROW_Kick,
	THROW_Slide,

	// special
	THROW_Any,
};

struct native ThrowInfo
{
	var byte ID;
	var bool bInAir;
	var bool bDeadlyImpact;
	var bool bThrowAttracted;
	var EThrowType ThrowType;
	var EThrowType PreviousThrowType;
	var KFPawn PawnInstigator;
	var KFPawn PreviousThrowInstigator;
	var vector ThrowDirection;
	var Name ThrowBone;
	var float ThrowTime;
	var int LastImpulseNr;
	var Actor ThrowCauser;
	var class<KFDamageType> DamageTypeOnHit;
};

enum EThrowImpulseType
{
	TIT_Impulse,
	TIT_Spin,
};
/** Impulses added to thrown actors, to improve their movement in air */
struct native ThrowImpulse
{
	/** Name of the bone, to which the impulse will be added */
	var name BoneName;
	/** Impulse to add */
	var vector Impulse;
	/** Time after which the next impulse will be executed (if it exists), 0 - next impulse will be added simultaneously with current one */
	var float TimeToNextImpulse;
	/** Whether it is a linear impulse or an angular velocity change */
	var EThrowImpulseType ImpulseType;
};

/** Multipliers applied to throw impulses */
struct native ThrowImpulseMultiplier
{
	/** Name of bone for which the impulses will be multiplied */
	var name BoneName;

	/** Impulse multiplier */
	var float Multiplier;
};

struct native ThrowImpulseDataForKActors
{
	var float ImpulseStrength;
	var bool OverrideDirZ;
	var float DirZ;
};

struct native ThrowAttractInfo
{
	var Actor Attractor;
	var MeshComponent AttractToMesh;
	var Name BoneOrSocketName;
};


static function string DebugDumpPathingFlags( out PathingFlags Flags2Dump )
{
	return "PathToEnemiesLocationStatus: " @ Flags2Dump.PathToEnemiesLocationStatus @ " - PathToLocationNearEnemyStatus: " @ Flags2Dump.PathToLocationNearEnemyStatus @ " - bLastLatentMoveReportedMoveToLocationUnreachable: " @ Flags2Dump.bLastLatentMoveReportedMoveToLocationUnreachable @
		" bCanNotGetToEnemyLocationBecasuseOfMoveIteruption: " @ Flags2Dump.bCanNotGetToEnemyLocationBecasuseOfMoveIteruption @ " bCanNotGetToIntermediateLocationBecasuseOfMoveIteruption: " @ Flags2Dump.bCanNotGetToIntermediateLocationBecasuseOfMoveIteruption @
		" - bIamOffNavMesh: " @ Flags2Dump.bIamOffNavMesh @ " - bMyEnemyIsOffNavMesh: " @ Flags2Dump.bMyEnemyIsOffNavMesh;
}

DefaultProperties
{
}

