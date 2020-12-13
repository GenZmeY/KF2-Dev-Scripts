//=============================================================================
// KFSpecialMoveHandler
//=============================================================================
// Manages starting and stopping special moves for pawns
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFSpecialMove extends GameSpecialMove
	native(SpecialMoves)
	abstract;

/** Owner of this special move */
var KFPawn				KFPOwner;
var KFPlayerController	PCOwner;
var KFAIController		AIOwner;
var transient Object AISpecialOwner;
var transient ESpecialMove SMIndex;

/*********************************************************************************************
 * Animation
 *********************************************************************************************/

/** Cached reference to the current AnimNodeSlot used for cleanup */
var AnimNodeSlot ActiveSlotNode;

/** If set, this special move will override the value for Pawn::MaxSpeedModifier() */
var bool bOverridePawnSpeedModifier;

/** If set, hit reactions will still play while special move is active */
var bool bAllowHitReactions;
/** If set, HandleMomentum is skipped when taking damage */
var bool bAllowMomentumPush;
/** If set, never interrupt this move for a wander. Instead try to wander at the end of the move 
*   NOTE: this variable could potentially be replaced with bDisableMovement. This is not currently
*   done in case it breaks other special moves */
var bool bCanOnlyWanderAtEnd;
/** If set, allow weapon anims to be played for third-person pawns (weapon attachment) */
var bool bAllowThirdPersonWeaponAnims;
/** If set, sets Pawn.RotationRate to CustomRotationRate for the duration of the move */
var bool bUseCustomRotationRate;
var rotator CustomRotationRate;
/** Used when deferring special move animations till post sync due to physics calls. */
var name DeferredSeqName;

/** Default root motion mode to be used for this move */
var ERootMotionMode SMRootMotionMode;

/** When TRUE, tells our physics smoothing code to use a higher threshold when in root motion. */
var bool bUseHigherMeshSmoothingThreshold;

/*********************************************************************************************
 * Weapon firing
 *********************************************************************************************/

/** Weapon firing should cease/be disabled while this special move is being performed */
var bool bDisablesWeaponFiring;

/**
* For SpecialMove interactions. Only InteractionPawn allowed to damage me.
* Note: this is reset to FALSE in SpecialMoveStarted.
*/
var bool bOnlyInteractionPawnCanDamageMe;
/** Can change InteractionPawn before execution (InternalCanDoSpecialMove) */
var bool bCanModifyInteractionPawn;

/** Can be used by input functions */
var bool bPendingStopFire;

/** Flags used by button-activated special moves */
const FLAG_SpecialMoveButtonPressed = 253;
const FLAG_SpecialMoveButtonReleased = 254;

/** Sets a custom interpolated 3rd person view offset if we've got a third person camera */
var bool bUseCustomThirdPersonViewOffset;
var ViewOffsetData CustomThirdPersonViewOffset;
var float ViewOffsetInterpTime;
var bool bRestoredCameraDefaults;

/** Custom interpolated camera FOV */
var float CustomCameraFOV;
var float CameraFOVTransitionTime;

/*********************************************************************************************
 * GearSpecialMove
 *********************************************************************************************/

/** Flag to allow/disallow headtracking while in this special move. */
var const           bool    bDisableHeadTracking;
/** AI should ignore notifications */
var	const			bool	bDisableAI;
/** Disable movement (but doesn't necessarily stop physics, just blocks inputs). */
var					bool	bDisableMovement;
var             	bool	bMovementDisabled;
/** Lock Pawn Rotation, prevent it from being affects by Controller.Rotation */
var	const			bool	bLockPawnRotation;
var     			bool	bPawnRotationLocked;
var                 bool    bDisableLook;
/** Weapon goes down and can't shoot, be switched, can't quick heal, etc */
var                 bool    bDisableWeaponInteraction;
/** if > 0.0 after this many seconds the AI's command is popped and the special move is aborted */
var					float	AITimeout;
var					bool	bDisableAIAttackRangeChecks;
var					bool	bDisableSteering;
/** If TRUE, disables turning in place animations & code. Pawn will always face his rotation. */
var const			bool	bDisableTurnInPlace;
/** If set to anything above 0, scales the turn in place anim rate by its value */
var const 			float 	CustomTurnInPlaceAnimRate;
var	const			bool	bDisablePhysics;
/** If TRUE, disables physics adjustments on the clients. Where drastic velocity changes are needed, this can help with rubberbanding */
var const 			bool 	bServerOnlyPhysics;
var 				bool 	bAllowFireAnims;
var					bool	bShouldDeferToPostTick;
var	AICommand_PushedBySM	AICommand;
/** Default AICommand to push on AI when SpecialMove starts */
var class<AICommand_PushedBySM>	DefaultAICommandClass;

cpptext
{
	/** Affect pawn owner movement speed */
	virtual FLOAT GetMovementSpeedModifier() {return 1.f;}
	/** Using cpptext since GameSpecialMove's version is a final function. */
	virtual void ForcePawnRotation( APawn* P, FRotator NewRotation,UBOOL bIgnoreHumanController=FALSE  );
}

/*********************************************************************************************
 * Functions
 *********************************************************************************************/

/** Uses traceflags identical to pawn moves, checks to see if the path is clear for pawns to move through */
native static function bool IsPawnPathClear( Actor TraceInstigator, Pawn TraceToPawn, vector TraceEnd, vector TraceStart, optional vector TraceExtent, optional bool bIgnorePawns, optional bool bTraceComplex );

/** Generic PackFlags to be implemented by subclasses.  (see also PackSMFlags for advanced moves) */
static function byte PackFlagsBase(KFPawn P);

/** Overridden to lock desired rotation (see GOW3) */
//native function ForcePawnRotation(Pawn P, Rotator NewRotation);

function bool NotifyBump(Actor Other, vector HitNormal);
/** Called when the interaction pawn is updated after the special move has started */
function InteractionPawnUpdated(); 
/** Called on some player-controlled moves when a firemode input has been pressed */
function SpecialMoveButtonRetriggered();
/** Called on some player-controlled moves when a firemode input has been released */
function SpecialMoveButtonReleased();

/**
 * Checks to see if this Special Move can be done.
 */
protected function bool InternalCanDoSpecialMove()
{
	return (PawnOwner.Physics != PHYS_RigidBody);
}

function InitSpecialMove( Pawn InPawn, Name InHandle )
{
	PawnOwner = InPawn;

	KFPOwner = KFPawn(InPawn);
	if ( PawnOwner.Controller != none )
	{
		PCOwner = KFPlayerController(PawnOwner.Controller);
		if( PCOwner == none )
		{
			AIOwner = KFAIController(PawnOwner.Controller);
		}
	}

	bPendingStopFire = false;
}

function SpecialMoveStarted( bool bForced, Name PrevMove )
{
	local AICommand AIOwnerActiveCommand;
	local KFWeapon KFW;

	// Make sure we're taken out of ironsights
	if( PCOwner != none && KFPOwner.Weapon != none )
	{
		KFW = KFWeapon( KFPOwner.Weapon );
		if( KFW != none )
		{
			KFW.SetIronSights( false );
		}
	}

	SMIndex = KFPOwner.SpecialMove;

	// Push AICommand if it is defined.
	if( AIOwner != None )
	{
		if( DefaultAICommandClass != None && AIOwner.MyKFPawn != None )
		{
			AIOwnerActiveCommand == AICommand(AIOwner.GetActiveCommand());

			if(( AIOwnerActiveCommand == none || AIOwnerActiveCommand.AllowPushOfDefaultCommandForSpecialMove(KFPOwner.SpecialMove)))
			{
				AICommand = DefaultAICommandClass.static.PushSpecialMoveCommand(AIOwner);
			}
		}

		AIOwner.NotifySpecialMoveStarted( self );
	}

	if( PCOwner != None )
	{
		if( bDisableLook )
		{
			PCOwner.IgnoreLookInput(TRUE);
		}

		// Set camera offset
		if( bUseCustomThirdPersonViewOffset && PCOwner.PlayerCamera != none && PCOwner.PlayerCamera.CameraStyle == 'ThirdPerson' )
		{
			KFThirdPersonCamera(KFPlayerCamera(PCOwner.PlayerCamera).ThirdPersonCam).SetViewOffset( CustomThirdPersonViewOffset, true, ViewOffsetInterpTime );
		}

		// Set camera FOV
		if( CustomCameraFOV > 0.f )
		{
			PCOwner.HandleTransitionFOV( CustomCameraFOV, CameraFOVTransitionTime );
		}

		bRestoredCameraDefaults = false;
	}

	if( bDisableWeaponInteraction && KFPOwner.Weapon != none && KFWeapon(KFPOwner.Weapon) != none )
	{
        KFWeapon(KFPOwner.Weapon).SetSimplePutDown(true);
	}

	if( bDisableTurnInPlace )
	{
		KFPOwner.bDisableTurnInPlace = TRUE;
	}

	if( bDisableMovement )
	{
		SetMovementLock(TRUE);
	}

	// If Pawn rotation should be locked, make sure it is.
	if( bLockPawnRotation )
	{
		SetLockPawnRotation(TRUE);
	}

	if( bDisablePhysics )
	{
		PawnOwner.ZeroMovementVariables();
		if (PawnOwner.Role == ROLE_Authority || PawnOwner.IsLocallyControlled())
		{
			PawnOwner.SetPhysics(PHYS_None);
		}
	}

	if( bUseCustomRotationRate )
	{
		PawnOwner.RotationRate = CustomRotationRate;
	}

	if( CustomTurnInPlaceAnimRate > 0.f )
	{
		KFPOwner.TurnInPlaceAnimRate = CustomTurnInPlaceAnimRate;
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	// Clear pending stop fire flag
	bPendingStopFire = false;

	// Clear timers.
	PawnOwner.ClearTimer(nameof(AbortSpecialMove), Self);

	// AI set special move command.
	if( AIOwner != None && DefaultAICommandClass != None && AICommand != None )
	{
		if( AIOwner.GetActiveCommand() == AICommand )
		{
			AICommand.Status = 'Success';
			AIOwner.PopCommand(AICommand);
		}
		// Clear reference.
		AICommand = None;
	}

	if( PCOwner != None )
	{
		if( bDisableLook )
		{
			PCOwner.IgnoreLookInput(FALSE);
		}

		RestoreCameraDefaults();
	}

	if( KFPOwner != none )
	{
		KFPOwner.NotifySpecialMoveEnded( self, SMIndex );
	
		if( bUseCustomRotationRate )
		{
			KFPOwner.RotationRate = KFPOwner.default.RotationRate;
		}

		if( KFPOwner.TurnInPlaceAnimRate != KFPOwner.default.TurnInPlaceAnimRate )
		{
			KFPOwner.TurnInPlaceAnimRate = KFPOwner.default.TurnInPlaceAnimRate;
		}

		if( bDisableTurnInPlace )
		{
			KFPOwner.bDisableTurnInPlace = KFPOwner.default.bDisableTurnInPlace;
		}

		if( bDisableWeaponInteraction && KFPOwner.Weapon != none && KFWeapon(KFPOwner.Weapon) != none )
		{
	        KFWeapon(KFPOwner.Weapon).SetSimplePutDown(false);
		}

		// If we are in a state that should have left us wandering, begin wandering at the end of this move
		if( bCanOnlyWanderAtEnd && KFPOwner != none )
		{
			if( AIOwner != none && KFPOwner.IsHeadless() )
			{
				AIOwner.DoHeadlessWander();
			}
			else if(KFPOwner.ShouldBeWandering())
			{
				KFPOwner.CausePanicWander();	
			}
		}		
	}

	if ( bDisablePhysics && (PawnOwner.Role == ROLE_Authority || PawnOwner.IsLocallyControlled()) )
	{
		PawnOwner.SetPhysics(PHYS_Falling);
	}

	// If movement was disabled, toggle it back on
	if( bMovementDisabled )
	{
		SetMovementLock(FALSE);
	}

	if (AIOwner != none)
	{
		AIOwner.NotifySpecialMoveEnded(self);
	}
	AISpecialOwner = none;

	// If Pawn rotation was locked in default properties, unlock it.
	// Otherwise we're in manual mode, so let the special subclass handle everything.
	if( bPawnRotationLocked )
	{
		SetLockPawnRotation(FALSE);
	}

	// Disable end of animation notification, so it doesn't interfere with future special moves
	// using that same animation channel.
	if ( ActiveSlotNode != None )
	{
		ActiveSlotNode.SetActorAnimEndNotification( FALSE );
		ActiveSlotNode = None;
	}
}

/** Restores camera to its previous values */
function RestoreCameraDefaults()
{
	if( bRestoredCameraDefaults || PCOwner == none )
	{
		return;
	}

	if( bUseCustomThirdPersonViewOffset && PCOwner.PlayerCamera != none && PCOwner.PlayerCamera.CameraStyle == 'ThirdPerson' )
	{
		if( KFPawn_Monster(KFPOwner) != none )
		{
			KFThirdPersonCamera(KFPlayerCamera(PCOwner.PlayerCamera).ThirdPersonCam).SetViewOffset( KFPawn_Monster(KFPOwner).ThirdPersonViewOffset, true, ViewOffsetInterpTime );
		}
	}

	// Return camera fov to default
	if( CustomCameraFOV > 0.f )
	{
		PCOwner.HandleTransitionFOV( PCOwner.DefaultFOV, CameraFOVTransitionTime );
	}

	bRestoredCameraDefaults = true;
}

/** Locks or Unlocks Pawn movement */
final function SetMovementLock(bool bEnable)
{
	if( bMovementDisabled != bEnable )
	{
		bMovementDisabled = bEnable;

		if (PCOwner != None)
		{
			PCOwner.IgnoreMoveInput(bEnable);
			// we might be in between the input reading and PlayerMove(), so we need to zero the inputs
			// to make sure a stray tick of motion doesn't get in
			if (PCOwner.PlayerInput != None)
			{
				PCOwner.PlayerInput.aForward = 0.f;
				PCOwner.PlayerInput.aStrafe = 0.f;
				PCOwner.PlayerInput.aUp = 0.f;
			}
		}
		else if( AIOwner != none )
		{
			AIOwner.bPreparingMove = bEnable;
		}

		// Set acceleration to zero
		if( bEnable )
		{
			PawnOwner.Acceleration = Vect(0,0,0);
		}
	}
}

/**
 * Can be overridden to modify sprint speed when the move is running. Must be implemented in subclasses (see KFSM_Block)!
 * Network: SERVER
 */
function float GetSprintSpeedModifier() 
{
	return 1.0f;
};

function EnableRootMotion()
{
	// Turn on root motion on animation node
	KFPOwner.BodyStanceNodes[EAS_FullBody].SetRootBoneAxisOption( RBA_Translate, RBA_Translate, RBA_Translate );

	// Turn on Root motion on mesh.
	KFPOwner.Mesh.RootMotionMode = SMRootMotionMode;
}

function DisableRootMotion()
{
	// Restore default root motion mode
	KFPOwner.Mesh.RootMotionMode = PawnOwner.Mesh.default.RootMotionMode;

	// Turn off Root motion on animation node
	KFPOwner.BodyStanceNodes[EAS_FullBody].SetRootBoneAxisOption(RBA_Discard, RBA_Discard, RBA_Discard);
}

/** Overridden to restrict movement when on the ground */
function Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( bMovementDisabled && KFPOwner != none && KFPOwner.Role == ROLE_Authority && KFPOwner.Physics == PHYS_Walking )
	{
		KFPOwner.Velocity.X = 0.f;
		KFPOwner.Velocity.Y = 0.f;
		KFPOwner.Acceleration = vect(0,0,0);
	}
}

/**
 * Locks or UnLocks Pawn rotation.
 * When Pawn rotation is locked, Pawn will stop rotating to match the controller's Yaw.
 */
final function SetLockPawnRotation(bool bLock)
{
	if( bPawnRotationLocked != bLock )
	{
		bPawnRotationLocked = bLock;

		// If we were locked, then interpolate back to new (unlocked) rotation
		if( !bLock )
		{
			//PawnOwner.InterpolatePawnRotation();
		}
	}
}

/** Allows special moves to alter view rotation */
function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot );

/** Play a CameraAnim */
function CameraAnimInst PlayCameraAnim
(
	Pawn			PawnToPlay,
	CameraAnim		InCameraAnim,
	optional float	Rate=1.f,
	optional float	Scale=1.f,
	optional float	BlendInTime,
	optional float	BlendOutTime,
	optional bool	bLoop,
	optional bool	bRandomStartTime,
	optional float	Duration,
	optional bool	bSingleInstance,
	optional bool	bSkipSpaceCheck
)
{
	local KFPlayerController	KFPC;

	KFPC = KFPlayerController(PawnToPlay.Controller);

	// Only play camera animations on local human players
	if (KFPC == None || !PawnToPlay.IsLocallyControlled() || KFPC.PlayerCamera == None || InCameraAnim == None)
	{
		return None;
	}

	if (!bSkipSpaceCheck && !KFPC.CameraAnimHasEnoughSpace(InCameraAnim, Scale))
	{
		`log("PlayCameraAnim failed CameraAnimHasEnoughSpace:" @ KFPC.CameraAnimHasEnoughSpace(InCameraAnim, Scale));
		return None;
	}

	if (PawnOwner != None && PawnOwner.WorldInfo.GRI.bMatchIsOver)
	{
		return None;
	}

	// Play camera animation
	return KFPC.PlayerCamera.PlayCameraAnim(InCameraAnim, Rate, Scale, BlendInTime, BlendOutTime, bLoop, bRandomStartTime, Duration, bSingleInstance);
}

/* Play a custom animation by name */
simulated function float PlaySpecialMoveAnim( name AnimName,
											  EAnimSlotStance AnimStance,
											  optional float BlendInTime=0.2f,
											  optional float BlendOutTime=0.2f,
											  optional float Rate=1.f,
											  optional bool	bLooping )
{
	local float Duration;

	`log("PlaySpecialMoveAnim '"$AnimName$"' on"@KFPOwner@" SM="$self, KFPOwner.bLogCustomAnim);

	Duration = KFPOwner.PlayBodyAnim(AnimName, AnimStance, Rate, BlendInTime, BlendOutTime, bLooping);

	// Make sure animation is valid (otherwise this move could break)
	if ( Duration <= 0 && KFPOwner.IsDoingSpecialMove() )
	{
		// Failed to play animation, fall back to just setting a timer to exit the special move.
		`warn("Failed to play" @ AnimName @ "on special move" @ Self @ "on Pawn" @ PawnOwner);
		PawnOwner.SetTimer(0.25f, FALSE, nameof(AbortSpecialMove), Self);
		return 0;
	}

	// Enable OnAnimEnd notification (auto-reset by the slot node)
	if ( !bLooping )
	{
		ActiveSlotNode = KFPOwner.BodyStanceNodes[AnimStance];
		ActiveSlotNode.SetActorAnimEndNotification( TRUE );
	}

	return Duration;
}

/** Timer used to exist gracefully if something has gone wrong */
function AbortSpecialMove()
{
	KFPOwner.EndSpecialMove();
}

/**
 * Notification called when body stance animation finished playing.
 * @param	SeqNode		- Node that finished playing. You can get to the SkeletalMeshComponent by looking at SeqNode->SkelComponent
 * @param	PlayedTime	- Time played on this animation. (play rate independant).
 * @param	ExcessTime	- how much time overlapped beyond end of animation. (play rate independant).
 */
function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	// By default end this special move.
	KFPOwner.EndSpecialMove();
}

/**
 * This is a callback function that will be kicked off from KFPawn.uc OnAnimEnd. Some animations cause
 * physics to happen when they end so we defer certain end animations till post tick.
 */
function DeferOnAnimEnd()
{
	if( KFPOwner.SpecialMoves[KFPOwner.SpecialMove] == self)
	{
		AnimEndNotify(None, 0, 0);
	}
}

/** Called from KFPawn::OnAnimNotifyParticleSystemSpawned() */
function OnAnimNotifyParticleSystemSpawned( const AnimNotify_PlayParticleEffect AnimNotifyData, ParticleSystemComponent PSC );

/*********************************************************************************************
 * Gameplay notications/hooks
 *********************************************************************************************/

/** Called by owning AI Command when AI behavior decides to stop this attack */
function AbortedByAICommand();

/** Notification from the pawn that damage was taken during move */
function NotifyOwnerTakeHit(class<KFDamageType> DamageType, vector HitLoc, vector HitDir, Controller InstigatedBy);

/** Notification from the pawn that a medium (aka gun) or heavy (aka melee) affliction has been activated */
function NotifyHitReactionInterrupt();

/** Called when owning pawn has damage parried during this move */
function bool CanInterruptWithParry();

/** Called when owner swaps to gore mesh during this move */
function OnGoreMeshSwap();

/** Server notification that the pawn has been EMP disrupted */
function OnEMPDisrupted()
{
	if( KFPOwner != none && KFPOwner.IsHumanControlled() )
	{
		KFPOwner.EndSpecialMove();
	}
}

/** Used for changing attack target (non claimable, switch to other enemy) */
event ModifyInteractionPawn(out KFPawn OtherPawn);

/** Allows special moves to control the crosshair */
function bool CanDrawCrosshair() { return true; }

/** Allows special move to alter aim rotation */
function bool GetSMAimRotation( out rotator AimRot );

defaultproperties
{
	Handle=KFSpecialMove
	SMRootMotionMode=RMM_Accel
	bDisableSteering=true
	bDisableAIAttackRangeChecks=true
	bAllowHitReactions=false
	bCanOnlyWanderAtEnd=false
	bShouldDeferToPostTick=false
	bUseHigherMeshSmoothingThreshold=false
	CustomTurnInPlaceAnimRate=0.f

	// Camera view offset/FOV
	bUseCustomThirdPersonViewOffset=false
	CustomCameraFOV=0.f
	CameraFOVTransitionTime=1.f
}