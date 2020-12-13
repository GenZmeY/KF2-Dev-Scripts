//=============================================================================
// KFGibSkeletalMeshComponent
//=============================================================================
// Skeletal mesh component for a giblet mesh
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 8/14/2014
//=============================================================================

class KFGibSkeletalMeshComponent extends SkeletalMeshComponent;

defaultproperties
{
	MaxDrawDistance=2500
	BlockActors=FALSE
	CollideActors=TRUE
	BlockRigidBody=TRUE
	CastShadow=FALSE
	bCastDynamicShadow=FALSE
	bNotifyRigidBodyCollision=FALSE
	ScriptRigidBodyCollisionThreshold=5.0
	bUseCompartment=FALSE
	RBChannel=RBCC_EffectPhysics
	RBCollideWithChannels=(Default=TRUE,Pawn=TRUE,Vehicle=TRUE,DeadPawn=TRUE)
	bUpdateSkelWhenNotRendered=FALSE
	bHasPhysicsAssetInstance=FALSE
	PhysicsWeight=1.0
	bAcceptsDynamicDecals=FALSE
	Scale=1.0
	//bSkipAllUpdateWhenPhysicsAsleep=TRUE
}

