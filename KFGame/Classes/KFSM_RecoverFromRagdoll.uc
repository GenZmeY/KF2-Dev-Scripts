//=============================================================================
// KFSM_RecoverFromRagdoll
//=============================================================================
// Recover from rigid body physics knockdown effects
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GSM_RecoverFromRagdoll
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFSM_RecoverFromRagdoll extends KFSpecialMove
	native(SpecialMoves);
	
// Recovery anims
var() Name GetUpFrontAnim;
var() Name GetUpBackAnim;

// Blend out physics
var		bool	bBlendToGetUp;
var		float	GetUpBlendStartTime;
var()	float	GetUpBlendTime;

// GetUp orientation
var()	Name	UpDownBoneName;
var()	EAxis	UpDownAxis;
var()	bool	bInvertUpDownBoneAxis;
var()	Name	OrientationBoneName;
var()	EAxis	OrientationAxis;
var()	INT		GetUpFromBackYawOffset;

/** If TRUE, ignore pawns when looking for a spot to get up */
var()	bool	bIgnorePawnsOnRecover;

/** enable debugging */
var()   bool	bDebugSpecialMove;

// C++ functions
cpptext
{
	virtual void TickSpecialMove(FLOAT DeltaTime);
}

protected function bool InternalCanDoSpecialMove()
{
	return (PawnOwner.Physics == PHYS_RigidBody);
}

function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	local vector	HitLocation, HitNormal, TraceStart, TraceEnd, Extent;
	local vector	HeightVec;
	local Actor		HitActor;

	Super.SpecialMoveStarted(bForced,PrevMove);

	// Stop updating the physics bones to match the animation
	PawnOwner.Mesh.bUpdateKinematicBonesFromAnimation = FALSE;
	PawnOwner.Mesh.PhysicsWeight = 1.f;

	// Restore physics update settings
	PawnOwner.Mesh.MinDistFactorForKinematicUpdate = PawnOwner.default.Mesh.MinDistFactorForKinematicUpdate;

	// Restore tick group
	PawnOwner.Mesh.SetTickGroup(PawnOwner.Default.Mesh.TickGroup);
	PawnOwner.SetTickGroup(TG_PreAsyncWork);

	// This will fix all bones, and stop Actor location being changed.
	PawnOwner.SetPhysics(PHYS_None);

	// Figure out Actor Rotation and Recovery animation to play
	PlayRecoveryAnim();

	// Move Pawn off walls
	Extent = vect(0,0,0);
	// Trace down to floor level
	HeightVec	= vect(0,0,1) * PawnOwner.CylinderComponent.CollisionHeight;
	TraceStart	= PawnOwner.Location + HeightVec * 1.1f;	// Don't go to high, so we don't start trace inside a ceiling.
	TraceEnd	= PawnOwner.Location - HeightVec * 3.f;

	if(bIgnorePawnsOnRecover)
	{
		//HitActor = TraceNoPawns(PawnOwner, TraceEnd, TraceStart, HitLocation);
		HitActor = PawnOwner.Trace(HitLocation, HitNormal, TraceEnd, TraceStart, FALSE, Extent);
	}
	else
	{
		HitActor = PawnOwner.Trace(HitLocation, HitNormal, TraceEnd, TraceStart, TRUE, Extent);
	}

	if( HitActor != None )
	{
		MoveOffGeometry(HitLocation, HeightVec, Extent);
	}
	else if ( bDebugSpecialMove )
	{
		`log(class @ "Failed trace");
		PawnOwner.DrawDebugCylinder(TraceStart + vect(0,0,1) * Extent.Z, TraceEnd - vect(0,0,1) * Extent.Z, Extent.X, 4, 0, 255, 0, TRUE);
		PawnOwner.DrawDebugLine(TraceStart, TraceEnd, 0, 0, 255, TRUE);
	}

	// Start changing PhysicsWeight from 1.f (showing ragdoll position) to 0.f (showing first frame of get up anim)
	bBlendToGetUp = TRUE;
	GetUpBlendStartTime = PawnOwner.WorldInfo.TimeSeconds;

	// Skip BlendToGetUp if Pawn was using partial kinamatics for gore (e.g. Headless)
	if ( KFPOwner.bHasBrokenConstraints && KFPOwner.HasInjuredHitZones() )
	{
		PawnOwner.Mesh.PhysicsWeight = 0.f;
		FinishedBlendToGetUp();
	}
}

/** Trace, but ignore volumes and triggers */
simulated function Actor TraceNoPawns(Pawn TraceOwner, vector End, vector Start, out vector HitLocation)
{
	local Actor HitActor;
	local vector HitLoc, HitNorm;

	// Iterate over each actor along trace...
	foreach TraceOwner.TraceActors(class'Actor', HitActor, HitLoc, HitNorm, End, Start, vect(0,0,0))
	{
		// .. if it's not a pawn, use it!
		if(Pawn(HitActor) == None)
		{
			HitLocation = HitLoc;
			return HitActor;
		}
	}
	return None;
}

// Move off geometry by collision extent.
simulated function MoveOffGeometry(vector HitLocation, vector HeightVec, vector Extent)
{
	local PrimitiveComponent    BackupCollisionComponent;

	HitLocation += HeightVec - vect(0,0,1) * Extent.Z + vect(0,0,1); // nudge by one unit up.
	Extent = Vect(1,1,0) * PawnOwner.CylinderComponent.CollisionRadius + HeightVec;

	if ( bDebugSpecialMove )
	{
		PawnOwner.DrawDebugSphere(HitLocation, 16, 8, 255, 0, 0, TRUE);
		PawnOwner.DrawDebugBox(HitLocation, Extent, 255, 0, 0, TRUE);
	}

	if( PawnOwner.FindSpot(Extent, HitLocation) )
	{
		if ( bDebugSpecialMove )
		{
			PawnOwner.DrawDebugSphere(HitLocation, 16, 8, 0, 255, 0, TRUE);
			PawnOwner.DrawDebugBox(HitLocation, Extent, 0, 255, 0, TRUE);
		}

		// Restore collision component just for the SetLocation call.
		BackupCollisionComponent = PawnOwner.CollisionComponent;
		PawnOwner.CollisionComponent = PawnOwner.CylinderComponent;
		if( !PawnOwner.SetLocation(HitLocation) )
		{
			`warn(class @ "SetLocation failed!!!!!!!!!!", bDebugSpecialMove);
		}
		PawnOwner.CollisionComponent = BackupCollisionComponent;

		if ( bDebugSpecialMove )
		{
			PawnOwner.DrawDebugSphere(PawnOwner.Location, 16, 8, 0, 0, 255, TRUE);
			PawnOwner.DrawDebugBox(PawnOwner.Location, Extent, 0, 0, 255, TRUE);
		}
	}
	else
	{
		PawnOwner.SetLocation(HitLocation);
		if ( bDebugSpecialMove )
		{
			`log(class @ "Failed findspot");
			PawnOwner.DrawDebugCylinder(PawnOwner.Location - HeightVec, PawnOwner.Location + HeightVec, PawnOwner.CylinderComponent.CollisionRadius, 12, 255, 0, 0, TRUE);
		}
	}
}

/**
 * Figure out what the Actor's Rotation should be.
 * And which recovery animation should be played.
 */
function PlayRecoveryAnim()
{
	local Rotator NewRotation;
	local int OrientationBodyIndex, UpDownBodyIndex;
	local matrix BodyTM;
	local bool bGetUpFromBack;

	bGetUpFromBack = FALSE;

	// Make sure we have a bone set to do these things.
	OrientationBodyIndex = PawnOwner.Mesh.PhysicsAsset.FindBodyIndex(OrientationBoneName);
	if( OrientationBodyIndex != INDEX_NONE )
	{
		// force rotation to match the body's direction so the blend to the getup animation looks more natural
		BodyTM = PawnOwner.Mesh.PhysicsAssetInstance.Bodies[OrientationBodyIndex].GetUnrealWorldTM();
		NewRotation.Yaw = rotator(MatrixGetAxis(BodyTM, OrientationAxis)).Yaw;
		//PawnOwner.DrawDebugCoordinateSystem(MatrixGetOrigin(BodyTM), MatrixGetRotator(BodyTM), 5.f, TRUE);

		UpDownBodyIndex = PawnOwner.Mesh.PhysicsAsset.FindBodyIndex(UpDownBoneName);

		if( UpDownBodyIndex != INDEX_NONE )
		{
			BodyTM = PawnOwner.Mesh.PhysicsAssetInstance.Bodies[UpDownBodyIndex].GetUnrealWorldTM();
			bGetUpFromBack = (MatrixGetAxis(BodyTM, UpDownAxis).Z > 0.f);
			//PawnOwner.DrawDebugCoordinateSystem(MatrixGetOrigin(BodyTM), MatrixGetRotator(BodyTM), 5.f, TRUE);
			if( bInvertUpDownBoneAxis )
			{
				bGetUpFromBack = !bGetUpFromBack;
			}
		}

		// flip it around if the head is facing upwards, since the animation for that makes the character
		// end up facing in the opposite direction that its body is pointing on the ground
		if( bGetUpFromBack )
		{
			NewRotation.Yaw += GetUpFromBackYawOffset;
			NewRotation = Normalize(NewRotation);
		}
		PawnOwner.SetRotation(NewRotation);
 		//PawnOwner.DrawDebugCoordinateSystem(PawnOwner.Location, PawnOwner.Rotation, 50.f, TRUE);
	}
	else
	{
		NewRotation.Yaw = PawnOwner.Rotation.Yaw;
		PawnOwner.SetRotation(NewRotation);
	}

	// Choose correct get-up animation and rewind get up animation to start
	// The play rate is zero - we just want it frozen on the first frame.
	PlaySpecialMoveAnim(GetRecoveryAnim(bGetUpFromBack), EAS_FullBody, 0.f, 0.33f, 1.f);

	// Enable Root Motion
	EnableRootMotion();
}

/** Helper for PlayRecoveryAnim */
function name GetRecoveryAnim(bool bGetUpFromBack)
{
	return (bGetUpFromBack) ? GetUpBackAnim : GetUpFrontAnim;
}

/**
 *	Done with blend, start updating physics bones again, and show result.
 *	Bones should all be fixed at this point.
 */
simulated event FinishedBlendToGetUp()
{
	bBlendToGetUp = FALSE;
	class'KFSM_RagdollKnockdown'.static.TermKnockdownRagdoll(KFPOwner);
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	if (bBlendToGetUp)
	{
		FinishedBlendToGetUp();
	}

	bBlendToGetUp = FALSE;

	DisableRootMotion();

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

defaultproperties
{
	Handle=KFSM_RecoverFromRagdoll

	// ---------------------------------------------
	// Animations
	GetUpFrontAnim=Getup_F_V1
	GetUpBackAnim=Getup_B_V1

	UpDownBoneName="Spine1"
	UpDownAxis=AXIS_Y
	bInvertUpDownBoneAxis=TRUE
	OrientationBoneName="Spine1"
	OrientationAxis=AXIS_X
	GetUpFromBackYawOffset=+32768
	GetUpBlendTime=0.42f
	bIgnorePawnsOnRecover=TRUE

	// ---------------------------------------------
	// SpecialMove
	bDisableMovement=TRUE
	bLockPawnRotation=TRUE
    bDisablesWeaponFiring=true
	bCanOnlyWanderAtEnd=true    
}