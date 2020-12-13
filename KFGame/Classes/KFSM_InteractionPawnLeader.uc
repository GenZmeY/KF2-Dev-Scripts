//=============================================================================
// KFSM_InteractionPawnLeader
//=============================================================================
// Base class for Pawn to Pawn Interactions.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GSM_InteractionPawnLeader_Base
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFSM_InteractionPawnLeader extends KFSpecialMove
	native(SpecialMoves)
	abstract;

var transient protected CameraAnimInst ExecutionCameraAnimInst_Leader;
var transient protected CameraAnimInst ExecutionCameraAnimInst_Follower;

/** Pointer to Follower. */
var KFPawn			Follower;
/** if other than SM_None, then force InteractionPawn into this special move. */
var ESpecialMove	FollowerSpecialMove;
/** Max time to wait for Interaction to start. If it can't be made, special move will be aborted. */
var float			InteractionStartTimeOut;

/** If TRUE, Pawns will be aligned with each other. */
var bool			bAlignPawns;
/** Desired distance to align both pawns. */
var	float			AlignDistance;
/** Checks 2D dist between the pawns versus this threshold when determining if they are close enough */
var float			AlignDistanceThreshold;
/** Should leader be aligned as well as follower */
var bool 			bAlignLeaderLocation;
/** If TRUE, align the Z position of follower as well */
var bool 			bAlignFollowerZ;
/** Should Follower look in same dir as me? */
var bool			bAlignFollowerLookSameDirAsMe;
/** If Rotations should automatically be aligned */
var bool            bAlignLeaderRotation;
var bool            bAlignFollowerRotation;
var bool			bStopAlignFollowerRotationAtGoal;
/** If human controlled controller's Rotations should automatically be aligned as well */
var bool            bAlignHumanFollowerControllerRotation;
/** Used by RInterpTo, multiplied by 4096.f (see GOW3 UGearSpecialMove::MoveTo which is similar) */
var float			AlignFollowerInterpSpeed;
var INT             LeaderRelativeYawOffset;
/** Time it takes to pull the pawns together */
var float			AlignSpeedModifier;

/** (NEW) Test interaction collision to detect when pawns get too far apart. */
var bool			bRetryCollisionCheck;

// C++ functions
cpptext
{
	virtual void PrePerformPhysics(FLOAT DeltaTime);
}

/**
 * Trace to see if it will hit from current location to +targetrelativeoffset
 * If so, it will return vector from target location to hit location
 */
native function vector GetClipSafeMeshTranslation(out vector TargetRelativeOffset);

function SpecialMoveStarted(bool bForced, Name PrevMove)
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	// Reset variables
	Follower = None;
	bAlignFollowerLookSameDirAsMe = default.bAlignFollowerLookSameDirAsMe;
	bAlignPawns = default.bAlignPawns;
	bAlignFollowerRotation = default.bAlignFollowerRotation;

	// Set up a safety net in case interaction cannot be started
	PawnOwner.SetTimer( InteractionStartTimeOut, FALSE, nameof(self.InteractionStartTimedOut), self );

	// See if we can start interaction right now. If we can't, keep trying until we can.
	CheckReadyToStartInteraction();
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	local KFSM_InteractionPawnFollower FollowerSM;

	// Clear timers
	PawnOwner.ClearTimer(nameof(CheckReadyToStartInteraction), Self);
	PawnOwner.ClearTimer(nameof(InteractionStartTimedOut), self);
	PawnOwner.ClearTimer(nameof(RetryCollisionTimer), self);

	// If the special move was ended while bAlignPawns was on, velocity may get stuck on clients
	if( bAlignPawns && !KFPOwner.IsHumanControlled() )
	{
		PawnOwner.ZeroMovementVariables();
		if( Follower != None)
		{
			Follower.ZeroMovementVariables();
		}
	}

	// If the leader is leaving the special move, notify the follower
	if( Follower != None && Follower.IsDoingSpecialMove(FollowerSpecialMove) )
	{
		FollowerSM = KFSM_InteractionPawnFollower(Follower.SpecialMoves[FollowerSpecialMove]);
		FollowerSM.OnLeaderLeavingSpecialMove();
	}

	// Clear reference to Interaction Pawn.
	Follower = None;

	if (ExecutionCameraAnimInst_Leader != None)
	{
		if (PCOwner != None)
		{
			PCOwner.PlayerCamera.StopCameraAnim(ExecutionCameraAnimInst_Leader);
		}
		ExecutionCameraAnimInst_Leader = None;
	}
	if (ExecutionCameraAnimInst_Follower != None)
	{
		if (PCOwner != None)
		{
			PCOwner.PlayerCamera.StopCameraAnim(ExecutionCameraAnimInst_Follower);
		}
		ExecutionCameraAnimInst_Follower = None;
	}

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

/** Safety net in case Interaction cannot be started. Abort special move. */
function InteractionStartTimedOut()
{
	local KFPawn KFP;

	KFP = KFPawn(PawnOwner);

	if (KFP.SpecialMoves[KFP.SpecialMove] == self)
	{
		`Warn(KFP.WorldInfo.TimeSeconds @ KFP @ class @ GetFuncName() @ "InteractionStartTimeOut hit!! Aborting move." @ Follower @ Follower.SpecialMove );

		KFP.EndSpecialMove(, true);
	}
}

/** Checks if Interaction is ready to be started, and starts if it is. */
final function CheckReadyToStartInteraction()
{
	local KFSM_InteractionPawnFollower FollowerSM;

	// Make sure we have an InteractionPawn, this is a requirement for these types of special moves
	if( KFPOwner.InteractionPawn != None )
	{
		// Save variable here for ease of use.
		Follower = KFPOwner.InteractionPawn;
		// If net owner, start Follower special move if not already done.
		if( PawnOwner.WorldInfo.NetMode != NM_Client )
		{
			// Make sure we have a valid Pawn to work with
			if( Follower != None && Follower.Health > 0 )
			{
				if( !Follower.IsDoingSpecialMove(FollowerSpecialMove) )
				{
					Follower.DoSpecialMove(FollowerSpecialMove, TRUE, PawnOwner);
				}
			}
			else
			{
				// Our Pawn is never going to go in his special move... pop an error, and exit move.
				`Warn(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "Follower not gameplay relevant, Interaction cannot be started!!!" @ Follower @ Follower.SpecialMove, KFPOwner.bLogSpecialMove);
				KFPOwner.EndSpecialMove(KFPOwner.SpecialMove);
				return;
			}
		}
	}

	// If not ready, then set timer to try again next tick.
	if( !IsReadyToStartInteraction() )
	{
		if( Follower == None )
		{
			`log(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "Not ready to StartInteraction, delay... Follower:" @ Follower, KFPOwner.bLogSpecialMove,'SpecialMoves');
		}
		else
		{
			`log(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "Not ready to StartInteraction, delay... Follower:" @ Follower @ "Follower.SpecialMove:" @ Follower.SpecialMove, KFPOwner.bLogSpecialMove ,'SpecialMoves');
		}

		// Retry next frame...
		PawnOwner.SetTimer( PawnOwner.WorldInfo.DeltaSeconds, FALSE, nameof(self.CheckReadyToStartInteraction), self );
	}
	// otherwise, start interaction now!
	else
	{
		`log(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "StartInteraction. Follower:" @ Follower @ "Follower.SpecialMove:" @ Follower.SpecialMove, KFPOwner.bLogSpecialMove ,'SpecialMoves');

		PawnOwner.ClearTimer(nameof(CheckReadyToStartInteraction), Self);
		// Clear timeout timer
		PawnOwner.ClearTimer(nameof(InteractionStartTimedOut), Self);
		// Notify follower that we're about to start.
		FollowerSM = KFSM_InteractionPawnFollower(Follower.SpecialMoves[FollowerSpecialMove]);
		FollowerSM.InteractionStarted();
		// And start interaction!
		StartInteraction();
	}
}

/**
 * Conditions to determine if interaction is ready to be started.
 * - Need an InteractionPawn
 * - InteractionPawn needs to be doing his InteractionPawnSpecialMove if it is other than SM_None.
 */
function bool IsReadyToStartInteraction()
{
	return (Follower != None && Follower.IsDoingSpecialMove(FollowerSpecialMove));
}

/** StartInteraction */
function StartInteraction()
{
	if ( bRetryCollisionCheck && PawnOwner.Role == ROLE_Authority )
	{
		PawnOwner.SetTimer(0.5f, true, nameof(RetryCollisionTimer), self);
	}
}

/** Called on an interval to detect when pawns get too far apart or are seperated by a door */
function RetryCollisionTimer()
{
	// Test for vertical melee range (e.g. Follower fell off a ledge) & reachabilty (doors etc.)
	// This started happening after PHYS_Falling handling was added to PrePerformPhysics
	if ( (Abs(Follower.Location.Z - PawnOwner.Location.Z) > PawnOwner.CylinderComponent.CollisionHeight * 1.5) ||
	 	 !IsFollowerReachable() )
	{
		//`log("rejected outside of vertical melee range");
		KFPOwner.EndSpecialMove();
	}
}

/**
 * @brief Checks if the "follower" can stil be reached, mostly for doors
 *
 * @return true if we can physically reach the "follower"
 */
function bool IsFollowerReachable()
{
	// Trace from the WorldInfo, since open doors can ignore traces from zeds
	return ( IsPawnPathClear(KFPOwner.WorldInfo, Follower, Follower.Location, KFPOwner.Location, vect(2,2,2), true, true)
			&& IsPawnPathClear(KFPOwner.WorldInfo, Follower, Follower.Location, KFPOwner.Location,, true, true) );
}

/** Messages sent to this special move */
function bool MessageEvent(Name EventName, Object Sender)
{
	if( EventName == 'FollowerLeavingSpecialMove' )
	{
		OnFollowerLeavingSpecialMove();
		return TRUE;
	}

	return Super.MessageEvent(EventName, Sender);
}

/** Notification when Follower is leaving his FollowerSpecialMove */
function OnFollowerLeavingSpecialMove()
{
	if( KFPOwner != none && KFPOwner.Role == ROLE_Authority )
	{
		KFPOwner.EndSpecialMove();
	}
}

/**
 * Dump relative location of a Bone to PawnOwner
 * For debugging purposes
 */
function DebugSocketRelativeLocation(name InSocketName)
{
	local Vector MarkerLoc;
`if(`notdefined(ShippingPC))
	local Vector RelativeLoc;
`endif
	local Rotator MarkerRot;

	// Get position of marker
	//MarkerLoc = PawnOwner.Mesh.GetBoneLocation(BoneName);
	PawnOwner.Mesh.GetSocketWorldLocationAndRotation(InSocketName, MarkerLoc, MarkerRot);

	// Dump a little debug info to display the location we got:
	PawnOwner.DrawDebugSphere(MarkerLoc, 4, 8, 255, 0, 255, TRUE);

`if(`notdefined(ShippingPC))
	// Transform marker location to be relative to Leader location and rotation.
	RelativeLoc = WorldToRelativeOffset(PawnOwner.Rotation, MarkerLoc - PawnOwner.Location);

	`log(GetFuncName() @ "RelativeLoc:" @ RelativeLoc);
`endif
}

/**
 * Special Execution version.
 * Test to play same animation on victim.
 * WARNING: * ForcePitchCentering not reset for Follower
 *			* Follower's ViewTarget is set to the Leader.
 *
 * @param InCameraAnims - the list of anims to choose from
 *
 * @param LeaderAnimInst - a reference to the anim played on the leader
 *
 * @param bViewFromLeaderPOV - true to make followers see the execution from the leader's perspective, false otherwise
 *
 * @return True if it played an anim, false otherwise.
 */
function bool PlayExecutionCameraAnim(out const array<CameraAnim> InCameraAnims, optional out CameraAnimInst LeaderAnimInst, optional float BlendInTime=0.25f, optional float BlendOutTime=0.25f)
{
	local KFPlayerController	FollowerPC;
	local int					AnimIdx;
	local CameraAnimInst		FollowerAnimInst;
	local ViewTargetTransitionParams TransitionParams;

	FollowerPC = KFPlayerController(Follower.Controller);

	if( PCOwner != None )
	{
		AnimIdx = FollowerPC.ChooseRandomCameraAnim(InCameraAnims);
	}

	if (PawnOwner.IsLocallyControlled() && AnimIdx != INDEX_NONE)
	{
		LeaderAnimInst = PlayCameraAnim(PawnOwner, InCameraAnims[AnimIdx],,, BlendInTime, BlendOutTime);
		ExecutionCameraAnimInst_Leader = LeaderAnimInst;
	}

	// If Follower is human controlled, have him spectate his death from the killer's perspective
	if( FollowerPC != None && Follower.IsHumanControlled() )
	{
		if (FollowerPC.GetViewTarget() != PawnOwner)
		{
			TransitionParams.BlendTime = 0;
			FollowerPC.SetViewTarget(PawnOwner, TransitionParams);
		}

		AnimIdx = FollowerPC.ChooseRandomCameraAnim(InCameraAnims);

		// Also play the death camera
		if( Follower.IsLocallyControlled() )
		{
			FollowerAnimInst = PlayCameraAnim(Follower, InCameraAnims[AnimIdx],,, BlendInTime, BlendOutTime);
			ExecutionCameraAnimInst_Follower = FollowerAnimInst;
		}
	}

	return (FollowerAnimInst != None) || (LeaderAnimInst != None);
}

/** Attach Follower to Leader */
function AttachFollowerToLeader(Name SocketName, optional Vector AttachLocation, optional Rotator AttachRotation)
{
	local SkeletalMeshSocket	Socket;

	// Force replication update.
	Follower.bForceNetUpdate = TRUE;

	Follower.SetBase(None);
	Follower.SetPhysics(PHYS_None);
	Follower.SetHardAttach(TRUE);

	Follower.SetCollision(TRUE, FALSE);
	Follower.bCollideWorld = FALSE;

	// Make sure kidnapper has his attachment bone defined.
	Socket = PawnOwner.Mesh.GetSocketByName(SocketName);
	if( Socket != None )
	{
		Follower.SetBase(PawnOwner,, PawnOwner.Mesh, Socket.BoneName);
		Follower.SetRelativeLocation( Socket.RelativeLocation - Follower.default.Mesh.Translation );
		//Follower.SetRelativeRotation( Socket.RelativeRotation );
		//Follower.UpdateMeshTranslationOffset( vect(0,0,0), true );
		//Follower.Mesh.SetTranslation( vect(0,0,0) );
	}
	// check if bone exists with tht name
	else if ( PawnOwner.Mesh.MatchRefBone(SocketName) != INDEX_NONE )
	{
		Follower.SetBase(PawnOwner,, PawnOwner.Mesh, SocketName);
		Follower.SetRelativeLocation( AttachLocation );
		Follower.SetRelativeRotation( AttachRotation );
		//Follower.UpdateMeshTranslationOffset( vect(0,0,0) );
	}
	else
	{
		`Warn(PawnOwner.WorldInfo.TimeSeconds @ class @ GetFuncName() @ "Leader" @ PawnOwner.class @ "Has no attachment socket" @ SocketName @ "!!!!");

		if( AttachRotation != rot(0,0,0) )
		{
			Follower.SetRotation(AttachRotation);
		}
		else
		{
			Follower.SetRotation(PawnOwner.Rotation);
		}

		// b_MF_Attach doesn't exist on all Pawns!!
		if( AttachLocation != vect(0,0,0) )
		{
			Follower.SetLocation(AttachLocation);
		}
		else
		{
			Follower.SetLocation(PawnOwner.Location);
		}
		Follower.SetBase(PawnOwner);
	}

	// need to set PHYS_None again, because SetBase() changes physics to PHYS_Falling
	Follower.SetPhysics(PHYS_None);

	// This needs to be set AFTER Follower.UpdateMeshTranslationOffset( vect(0,0,0) );
	//Follower.bDisableMeshTranslationChanges = TRUE;

	// Log all debug information.
	`log(PawnOwner.WorldInfo.TimeSeconds @ PawnOwner @ class @ GetFuncName() @ "Attached Follower:" @ Follower
		@ "BaseSkelComponent:" @ Follower.BaseSkelComponent
		@ "SocketName:" @ SocketName
		@ "BaseBoneName:" @ Follower.BaseBoneName
		@ "RelativeLocation:" @ Follower.RelativeLocation
		@ "RelativeRotation:" @ Follower.RelativeRotation
		@ "bHardAttach:" @ Follower.bHardAttach
		@ "bIgnoreBaseRotation:" @ Follower.bIgnoreBaseRotation, KFPOwner.bLogSpecialMove,'SpecialMoves');

	//REMOVED - Perf difference should be minimal and there is still an issue when the parent is not in shadow, but the child should be.
	//Shadow parent, to render only one shadow for both.
	//Follower.Mesh.SetShadowParent(PawnOwner.Mesh);
}

/**
 * Detaches a based Pawn from the Leader.
 *
 * @param APawn - the Pawn to detach
 */
function DetachPawn(Pawn APawn)
{
	DetachPawnHelper(APawn);
}

/**
 * Detach the pawn and turn collision back on.
 * Static so other classes (like GSM_Hostage) can reuse this detach code.
 *
 * @param APawn - the Pawn to detach
 */
static function DetachPawnHelper(Pawn APawn)
{
	APawn.SetBase(None);
	APawn.SetHardAttach(false);
	APawn.SetPhysics(PHYS_Falling);
	//APawn.bDisableMeshTranslationChanges = FALSE;

	if (!APawn.bTearOff)
	{
		APawn.SetCollision(true, true);
	}
	APawn.bCollideWorld = true;

	// Clear Shadow parent
	APawn.Mesh.SetShadowParent(None);
}

/**
 * Used for Pawn to Pawn interactions.
 * Return TRUE if we can perform an Interaction with this Pawn.
 */
function bool CanInteractWithPawn(KFPawn OtherPawn)
{
	return TRUE;
}

DefaultProperties
{
	bAlignLeaderLocation=true
	bAlignLeaderRotation=TRUE
	bAlignFollowerRotation=true
	bAlignFollowerZ=false
	AlignFollowerInterpSpeed=8.f
	AlignDistanceThreshold=0.3f
	InteractionStartTimeOut=4.f
	FollowerSpecialMove=SM_None

	bRetryCollisionCheck=true
	AlignSpeedModifier=0.5f
}
