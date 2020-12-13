//=============================================================================
// KFAnimNotify_SpawnKActor
//=============================================================================
// Spawns a KActor at a given mesh location (e.g. discarded magazines)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnimNotify_SpawnKActor extends AnimNotify_Scripted;

/** Mesh to spawn physics for */
var() const StaticMesh RigidBodyMesh;

/** Lower bound of random initial linear vel */
var() vector					MinLinearVel;
/** Upper bound of random initial linear vel */
var() vector					MaxLinearVel;

/** Lower bound of random initial angular vel */
var() vector					MinAngularVel;
/** Upper bound of random initial angular vel */
var() vector					MaxAngularVel;

/** Mesh translation */
var() vector MeshTranslation;

/** Mesh rotation */
var() rotator MeshRotation;

/** Bone to spawn this actor on */
var() name BoneName;

/** If set, hide the bone when spawning the new mesh */
var() bool bShouldHideBone;

/** If > 0, when spawned in first person the mesh is hidden for a short time */
var() float FirstPersonUnhideDelay;

/** If true, calls ANIMNOTIFY_SpawnedKActor on KFPawn, allowing access to the spawned KActor */
var() bool bNotifyPawnOwner;

/** If true, do not run on dedicated server */
var() bool bClientOnly;

/** If true, always spawn regardless of effect relevancy or detail */
var() bool bIgnoreEffectRelevancy;

/** Spwans a magazine KActor from the weapon's magazine bone */
event Notify( Actor Owner, AnimNodeSequence AnimSeqInstigator )
{
	local KFKActorSpawnable NewKActor;
	local SkeletalMeshComponent SkelComp;
	local vector Loc, LinearVel, AngularVel;
	local rotator Rot;
	local Quat BoneQuat;
	local KFPawn P;

	// Skip if this is a dedicated server and notify is clientside-only
	if( bClientOnly && Owner.WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	SkelComp = AnimSeqInstigator.SkelComponent;

	if ( RigidBodyMesh == None || SkelComp == None )
		return;

	if ( bShouldHideBone )
	{
		// hide the magazine bone until the reload is finished
		SkelComp.HideBoneByName(BoneName, PBO_None);
	}

	// Skip physics in dropdetail
	if ( !bIgnoreEffectRelevancy && (Owner.WorldInfo.bDropDetail || !Owner.ActorEffectIsRelevant(None, false)) )
		return;

	Loc = SkelComp.GetBoneLocation(BoneName);
	BoneQuat = SkelComp.GetBoneQuaternion(BoneName);
	Rot = QuatToRotator(BoneQuat);

	NewKActor = Owner.Spawn( class'KFKActorSpawnable', Owner,, Loc, Rot + MeshRotation);
	if ( NewKActor != None )
	{
		NewKActor.StaticMeshComponent.SetStaticMesh(RigidBodyMesh);
		NewKActor.StaticMeshComponent.SetTranslation(MeshTranslation);
		NewKActor.LifeSpan = 30.f * FClamp(Owner.WorldInfo.DestructionLifetimeScale, 0.1f, 2.f);		

		// Set initial linear velocity
		LinearVel.X = RandRange(MinLinearVel.X, MaxLinearVel.X);
		LinearVel.Y = RandRange(MinLinearVel.Y, MaxLinearVel.Y);
		LinearVel.Z = RandRange(MinLinearVel.Z, MaxLinearVel.Z);
		NewKActor.StaticMeshComponent.SetRBLinearVelocity( Owner.Velocity + QuatRotateVector(BoneQuat, LinearVel) );

		// Set initial angular velocity
		AngularVel.X = RandRange(MinAngularVel.X, MaxAngularVel.X);
		AngularVel.Y = RandRange(MinAngularVel.Y, MaxAngularVel.Y);
		AngularVel.Z = RandRange(MinAngularVel.Z, MaxAngularVel.Z);
		NewKActor.StaticMeshComponent.SetRBAngularVelocity( QuatRotateVector(BoneQuat, AngularVel) );
		NewKActor.StaticMeshComponent.WakeRigidBody();

		if ( bNotifyPawnOwner || (SkelComp.bOwnerNoSee && FirstPersonUnhideDelay > 0) )
		{
			P = KFPawn(Owner);
			
			// Notify owner
			if( bNotifyPawnOwner )
			{
				P.ANIMNOTIFY_SpawnedKActor( NewKactor, AnimSeqInstigator );
			}

			// If bOwnerNoSee, this may be a third person effect so handle FirstPersonUnhideDelay
			if ( SkelComp.bOwnerNoSee && FirstPersonUnhideDelay > 0 && P.IsFirstPerson() )
			{
				NewKActor.HideForInterval(FirstPersonUnhideDelay);
			}
		}
	}
}

defaultproperties
{
	NotifyColor=(R=255,G=0,B=255)
	BoneName=RW_Magazine1
	FirstPersonUnhideDelay=0.15
}