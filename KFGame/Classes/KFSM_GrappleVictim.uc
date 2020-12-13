//=============================================================================
// KFSM_GrappleVictim
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_GrappleVictim extends KFSM_InteractionPawnFollower;

var transient KFPlayerController OwnerController;

var AkEvent GrabbedSoundModeStartEvent;
var AkEvent GrabbedSoundModeEndEvent;

/** Recently grabbed targets get a repreive */
var float GrabVictimCooldownTime;

/** Notification called when Special Move starts */
function SpecialMoveStarted(bool bForced, Name PrevMove )
{
	local KFPawn_Human KFPH;
	local KFGameInfo KFGI;
	local KFInventoryManager KFIM;

	super.SpecialMoveStarted( bForced, PrevMove );

	OwnerController = KFPlayerController( PawnOwner.Controller );

	if( OwnerController != none)
	{
		SetGrabEffect(OwnerController, true);
		if( OwnerController.IsLocalController() )
		{
			OwnerController.PostAkEvent(GrabbedSoundModeStartEvent,,,true);

			if ( bDisableLook || !OwnerController.bSkipNonCriticalForceLookAt )
			{
				OwnerController.SetForceLookAtPawn(Leader);
			}
		}
	}

	KFPH = KFPawn_Human(PawnOwner);
	if (KFPH != none)
	{
		if (PawnOwner.Role == ROLE_Authority)
		{
			KFGI = KFGameInfo(KFPH.WorldInfo.Game);
			if (KFGI != none && KFGI.DialogManager != none)
			{
				KFGI.DialogManager.PlayPlayerGrabbedDialog(KFPH);
			}
		}

		if (KFPOwner.WorldInfo.NetMode != NM_DedicatedServer)
		{
			KFIM = KFInventoryManager(KFPH.InvManager);
			if (KFIM != none && KFPH.MyKFWeapon != none && KFPH.MyKFWeapon.IsA('KFWeap_Welder'))
			{
				KFIM.SwitchToLastWeapon();
			}
		}
	}

	KFPOwner.ShouldCrouch( false );
	if( KFPOwner.bIsCrouched )
	{
		KFPOwner.ForceUnCrouch();
	}
	KFPOwner.bCanCrouch = false;
	KFPOwner.bCanJump = false;
	KFPOwner.bJumpCapable = false;
}

function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	super.SpecialMoveEnded( PrevMove, NextMove );

	if( OwnerController != none )
	{
        // Clear the force look at from being grabbed
        OwnerController.SetForceLookAtPawn(None);

		SetGrabEffect(OwnerController, false);
		if( OwnerController.IsLocalController() )
		{
			OwnerController.PostAkEvent(GrabbedSoundModeEndEvent);
		}
	}

	if ( PawnOwner.Role == ROLE_Authority )
	{
		KFPOwner.SetWeakGrabCoolDown(GrabVictimCooldownTime);
	}

	KFPOwner.bCanCrouch = KFPOwner.default.bCanCrouch;
	KFPOwner.bCanJump = KFPOwner.default.bCanJump;
	KFPOwner.bJumpCapable = KFPOwner.default.bJumpCapable;
}

function SetGrabEffect( KFPlayerController KFPC, bool bValue )
{
	KFPC.SetGrabEffect(bValue, (Leader != none && Leader.IsHumanControlled()) );
}

DefaultProperties
{
	// ---------------------------------------------
	// SpecialMove
	Handle=SM_GrappleVictim
	bDisableMovement=true
	bLockPawnRotation=false
	bDisableLook=false

	// KFSpecialMove
	bAllowThirdPersonWeaponAnims=true

	// Audio
	GrabbedSoundModeStartEvent=AkEvent'WW_UI_PlayerCharacter.Play_Grab_Start'
	GrabbedSoundModeEndEvent=AkEvent'WW_UI_PlayerCharacter.Play_Grab_Stop'

	GrabVictimCooldownTime=5.f
}