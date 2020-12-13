//=============================================================================
// KFSM_DeathAnim
//=============================================================================
// Plays a partial ragdoll anim after TearOff & PlayDying (Client-side only)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFSM_DeathAnim extends KFSpecialMove;

/** Chaining death anims */
var float NextDeathAnim_ActorTime;
var byte NumChainedDeathAnims;
var byte MaxChainedDeathAnims;

/** motors flag to make sure it always get disabled */
var bool bHasDeathMotorsActive;

static function byte PackSMFlags(KFPawn P, vector HitDir)
{
	// @todo
	return 0;
}

/** Restrictions for doing Death Animation. */
protected function bool InternalCanDoSpecialMove()
{
	if( PawnOwner.Physics == PHYS_RigidBody && KFPOwner != None
		&& KFPOwner.PawnAnimInfo.bCanPlayDeathAnimations )
	{
		return TRUE;
	}

	return FALSE;
}

/**
 * Play a death animation followed by rag doll physics.
 * Return TRUE if successful, FALSE if couldn't find an animation and wants to go into ragdoll.
 */
function bool PlayDeathAnimation(class<DamageType> DamageType, vector HitDirection, optional name HitBoneName)
{
	local name DeathAnim;
	local float Duration;

	DeathAnim = KFPOwner.PawnAnimInfo.ChooseDeathAnimation(KFPOwner, DamageType, HitDirection, HitBoneName);

	if( DeathAnim != '' )
	{
		// Play one shot death animation
		Duration = PlaySpecialMoveAnim(DeathAnim, EAS_FullBody, 0.2, -1.f);
	}

	// If animation failed to play, end special move now
	if ( Duration <= 0.f )
	{
		// Do rag doll death instead.
		KFPOwner.EndSpecialMove();
		return FALSE;
	}

	// TRUE = blend to physics/motors. FALSE = plain animation, no physics used. Used for debugging.
	if( TRUE )
	{
		StartDeathAnimMotors();
	}
	else
	{
		KFPOwner.EndSpecialMove();
	}

	`log("PlayDeathAnimation success DamageType:"$DamageType@"BoneName:"$HitBoneName, KFPOwner.bLogCustomAnim);

	return TRUE;
}

/** Calculate direction and pick death animation from anim group list */
function bool GetDeathAnimation(class<DamageType> DamageType, vector HitDirection, optional name HitBoneName)
{
	// CalcOctagonRegion()
	// Check HitBoneName
	// Check High impact
}

/**
 * Notification called when body stance animation finished playing.
 * @param	SeqNode		- Node that finished playing. You can get to the SkeletalMeshComponent by looking at SeqNode->SkelComponent
 * @param	PlayedTime	- Time played on this animation. (play rate independant).
 * @param	ExcessTime	- how much time overlapped beyond end of animation. (play rate independant).
 */
function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	StopDeathAnimMotors();
	KFPOwner.EndSpecialMove();
}

/** Event called when Special Move is finished. */
function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	// If move was ended by something else (aka AbortSpecialMove), cleanup motors
	if ( bHasDeathMotorsActive )
	{
		StopDeathAnimMotors();
	}

	KFPOwner.StopAllAnimations();

	`log("DeathAnimation finished ChainCount:"$NumChainedDeathAnims, KFPOwner.bLogCustomAnim);
}

/*********************************************************************************************
 * Internal
 *********************************************************************************************/

function StartDeathAnimMotors()
{
	// Turn on bone springs
	//SetSpringForBone(PawnOwner.PelvisBoneName, TRUE);
	//SetSpringForBone(PawnOwner.RightHandBoneName, TRUE);
	//SetSpringForBone(PawnOwner.LeftHandBoneName, TRUE);
	//SetSpringForBone(PawnOwner.LeftFootBoneName, TRUE);
	//SetSpringForBone(PawnOwner.RightFootBoneName, TRUE);

	// Disable animation tree SkelControls
	PawnOwner.Mesh.bIgnoreControllers = 1;

	// Set physics to be updated from Kinematic data
	PawnOwner.Mesh.bUpdateJointsFromAnimation = TRUE;
	PawnOwner.Mesh.bUpdateKinematicBonesFromAnimation = TRUE;

	// Turn on motors
	if ( PawnOwner.Mesh.PhysicsAssetInstance != None )
	{
		//PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularDriveParams(5000.f, 250.f, 0.f, PawnOwner.Mesh, TRUE);
		PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularDriveParams(KFPOwner.PawnAnimInfo.DeathPhysMotorStrength.X, KFPOwner.PawnAnimInfo.DeathPhysMotorStrength.Y, 0.f, PawnOwner.Mesh, TRUE);
		PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(TRUE, TRUE, PawnOwner.Mesh, TRUE);
	}

	// If Pawn had broken constraints, then we need to make sure child bodies and joints are not turned back into kinematic state
	if ( KFPOwner.bHasBrokenConstraints )
	{
		PawnOwner.Mesh.UpdateMeshForBrokenConstraints();
	}

	bHasDeathMotorsActive = true;
}

function StopDeathAnimMotors()
{
	// Turn off bone springs
	//SetSpringForBone(PawnOwner.PelvisBoneName, FALSE);
	//SetSpringForBone(PawnOwner.RightHandBoneName, FALSE);
	//SetSpringForBone(PawnOwner.LeftHandBoneName, FALSE);
	//SetSpringForBone(PawnOwner.LeftFootBoneName, FALSE);
	//SetSpringForBone(PawnOwner.RightFootBoneName, FALSE);

	// Kinematic data can now be ignored (we're not using velocity motors)
	PawnOwner.Mesh.bUpdateJointsFromAnimation = FALSE;
	PawnOwner.Mesh.bUpdateKinematicBonesFromAnimation = FALSE;

	if (PawnOwner.Mesh.PhysicsAssetInstance != None)
	{
		// Turn off position motors
		PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(FALSE, FALSE, PawnOwner.Mesh, TRUE);

		// Turn on velocity motors, to add some joint friction
		//PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularDriveParams(0.f, 0.f, 0.02f, PawnOwner.Mesh, TRUE);
		//PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularVelocityDrive(TRUE, TRUE, PawnOwner.Mesh, TRUE);
	}

	bHasDeathMotorsActive = false;
}

/**
 * Creates a spring between physics representation of bone and animated position.
 * To have physics match animation.
 */
final function SetSpringForBone(Name InBoneName, bool bEnable)
{
	local int				BoneIndex;
	local matrix			BoneMatrix;
	local RB_BodyInstance	BoneBody;

	// Filter through sockets and bones. Make sure we have a valid bone name to use.
	InBoneName = PawnOwner.Mesh.GetSocketBoneName(InBoneName);

	if( InBoneName == '' )
	{
		`Warn(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "Has non existing Bone or Socket named:" @ InBoneName @ "Unable to create HipBodyInstance!");
		return;
	}

	BoneIndex = PawnOwner.Mesh.MatchRefBone(InBoneName);
	if( BoneIndex != INDEX_NONE )
	{
		BoneMatrix = PawnOwner.Mesh.GetBoneMatrix(BoneIndex);
		BoneBody = PawnOwner.Mesh.FindBodyInstanceNamed(InBoneName);

		if( BoneBody != None )
		{
			BoneBody.EnableBoneSpring(bEnable, bEnable, BoneMatrix);
			if( bEnable )
			{
				BoneBody.OverextensionThreshold	= 50.f;
				BoneBody.SetBoneSpringParams(10000.f, 500.f, 10000.f, 500.f);
				BoneBody.bDisableOnOverExtension = TRUE;
			}
		}
		else
		{
			`Warn(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "BodyInstance not found for BoneName:" @ InBoneName);
			ScriptTrace();
		}
	}
	else
	{
		`Warn(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "Has non existing Index for BoneName:" @ InBoneName @ "Unable to create BodyInstance!");
	}
}

/** Notification forwarded from RB_BodyInstance, when a spring is over extended and disabled. */
function OnRigidBodySpringOverextension(RB_BodyInstance BodyInstance)
{
	local Name				PelvisBoneName;
	local RB_BodyInstance	PelvisBodyInstance;

	// Make sure we have correct bone name if this is a socket.
	PelvisBoneName = PawnOwner.Mesh.GetSocketBoneName(KFPOwner.PelvisBoneName);
	PelvisBodyInstance = PawnOwner.Mesh.FindBodyInstanceNamed(PelvisBoneName);

	// If Pelvis spring was broken, we can't keep the other limbs (hands & legs) under spring influence, it would look too bad.
	// So we just turn them off and force the Pawn into rag doll.
	if( PelvisBodyInstance == BodyInstance )
	{
		StopDeathAnimMotors();
	}
}

/*********************************************************************************************
 * Death Anim Chanining
 *********************************************************************************************/

/** Handle death animation chaining */
function NotifyOwnerTakeHit(class<KFDamageType> DamageType, vector HitLoc, vector HitDir, Controller InstigatedBy)
{
	local TraceHitInfo HitInfo;
	local name DeathAnim;

	// Since the pawn is torn off, the chaining effect will only play for locally controlled players
	if ( NumChainedDeathAnims < MaxChainedDeathAnims && PawnOwner.ActorTimeSince(NextDeathAnim_ActorTime) > 0 )
	{
		// don't double process the initial impact (possible on the server)
		if ( NumChainedDeathAnims == 0 && PawnOwner.WorldInfo.TimeSeconds == KFPOwner.TimeOfDeath )
		{
			return;
		}

		KFPOwner.CheckHitInfo(HitInfo, KFPOwner.Mesh, HitDir, HitLoc);

		DeathAnim = KFPOwner.PawnAnimInfo.ChooseDeathAnimation(KFPOwner, DamageType, HitDir, HitInfo.BoneName);
		if( DeathAnim != '' )
		{
			PlaySpecialMoveAnim(DeathAnim, EAS_FullBody, 0.2, -1.f);
		}

		NumChainedDeathAnims++;
		NextDeathAnim_ActorTime = PawnOwner.GetActorTimeSeconds() + RandRange(0.15f, 0.33f);
	}
}

defaultproperties
{
	MaxChainedDeathAnims=5
	bDisablesWeaponFiring=true
}
