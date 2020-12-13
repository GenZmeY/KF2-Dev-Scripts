//=============================================================================
// KFSM_Player_Emote
//=============================================================================
// Play a emote animation sequence
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFSM_Player_Emote extends KFSM_PlaySingleAnim;

`include(KFGame/KFGameDialog.uci)

/** Camera animation */
var CameraAnim CameraAnim;

/** Stores the last camera mode for restoration after move ends */
var Name LastCameraMode;

/** Camera fades */
var color FadeInColor, FadeOutColor;
var float FadeInTime, FadeOutTime;

var rotator InitialRotation;

/** Time from the end of an emote until the next emote can be done */
var protected const float EmoteCooldownTime;

/** Last time an emote was executed */
var protected float LastEmoteTime;

/** Contains a list of particle systems spawned during the move */
var protected array<ParticleSystemComponent> AnimParticles;

/** Checks to see if this Special Move can be done */
protected function bool InternalCanDoSpecialMove()
{
	if( KFPOwner == none
		|| KFPOwner.Physics == PHYS_Falling
		||  `TimeSinceEx(KFPOwner, LastEmoteTime) < EmoteCooldownTime )
	{
		return false;
	}

	return super.InternalCanDoSpecialMove();
}

/** Disable crosshair */
function bool CanDrawCrosshair()
{
	return false;
}

static function byte PackFlagsBase( KFPawn P )
{
	return class'KFEmoteList'.static.GetEmoteIndex( class'KFEmoteList'.static.GetEquippedEmoteId() );
}

function SpecialMoveStarted( bool bForced, Name PrevMove )
{
	// Clear our anim particles array just in case
	ClearSMParticles();

	super.SpecialMoveStarted( bForced, PrevMove );

	// This ensures the emote animation is always using the correct root bone axis option
	// since it is possible that the previous pooled anim node sequence has not been cleared
	// KFPOwner.BodyStanceNodes[EAS_FullBody].SetRootBoneAxisOption(RBA_Default, RBA_Default, RBA_Default);

	// Cache off starting rotation. Instead of snapping the pawn to the new camera direction, we'll set the camera back
	// to this so that it smoothly blends out of the move.
	InitialRotation = KFPOwner.Rotation;

	// Force weapon to stop playing FX
	if (KFPOwner.WeaponAttachment != none)
	{
		KFPOwner.WeaponAttachment.StopThirdPersonFireEffects(true);
	}
}

function PlayAnimation()
{
	AnimName = class'KFEmoteList'.static.GetEmoteFromIndex( KFPOwner.SpecialMoveFlags );

	PlaySpecialMoveAnim( AnimName, AnimStance, BlendInTime, BlendOutTime, 1.f );

	if( KFPOwner.Role == ROLE_Authority )
	{
		KFGameInfo(KFPOwner.WorldInfo.Game).DialogManager.PlayDialogEvent( KFPOwner, `ACT_DoshTrain );
	}

	// Store camera mode for restoration after move ends
	LastCameraMode = 'FirstPerson';
	if( PCOwner != none && PCOwner.PlayerCamera != none )
	{
		LastCameraMode = PCOwner.PlayerCamera.CameraStyle;
	}

	// Set camera to emote third person camera
	if( PCOwner == none || !PawnOwner.IsLocallyControlled() )
	{
		KFPOwner.SetWeaponAttachmentVisibility( false );
		return;
	}

	if( PCOwner.CanViewCinematics() )
	{
		PCOwner.ClientSetCameraFade( true, FadeInColor, vect2d(1.f, 0.f), FadeInTime, true );
		PCOwner.PlayerCamera.CameraStyle = 'Emote';

		// Switch camera modes immediately in single player or on client
		if( PCOwner.WorldInfo.NetMode != NM_DedicatedServer )
		{
			PCOwner.ClientSetCameraMode( 'Emote' );
		}

		KFPOwner.SetWeaponAttachmentVisibility( false );
	}
}

/** Clears the array of particle systems that were created while this animation was playing */
function ClearSMParticles()
{
	if( AnimParticles.Length > 0 )
	{
		AnimParticles.Remove( 0, AnimParticles.Length );
	}
}

function SetParticlesVisible( bool bWasPlayingCustomAnim )
{
	local PlayerController LocalPC;
	local ParticleSystemComponent PSC;
	local vector Loc;
	local rotator Rot;

	LocalPC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();

	// Stop our animnotify-created particle systems early if we have any
	foreach AnimParticles( PSC )
	{
		if( PSC == none || !PSC.bAttached )
		{
			continue;
		}

		// This allows the player to see the particle FX from their emote after the move is over.
		// Only reattach particle systems that were actually attached to the pawn. Some may not
		// be attached, in which case their owner will be an Emitter.
		if( LocalPC != none && PSC.Owner == KFPOwner )
		{
			Loc = PSC.GetPosition();
			Rot = PSC.GetRotation();

			// Attach to a player controller and set position/rotation
		    LocalPC.AttachComponent( PSC );
			PSC.SetAbsolute( true, true, true );
			PSC.SetTranslation( Loc );
			PSC.SetRotation( Rot );

			// Playercontrollers are always hidden, so we need to ignore that
			PSC.SetIgnoreOwnerHidden( true );
		}

		if( bWasPlayingCustomAnim && PSC.bIsActive )
		{
			PSC.DeactivateSystem();
		}
	}
}

/** Called from KFPawn::OnAnimNotifyParticleSystemSpawned() */
function OnAnimNotifyParticleSystemSpawned( const AnimNotify_PlayParticleEffect AnimNotifyData, ParticleSystemComponent PSC )
{
	local AnimSequence AnimSeq;

	if( AnimNotifyData.Outer != none )
	{
		AnimSeq = AnimSequence( AnimNotifyData.Outer );
		if( AnimSeq != none && string(AnimSeq.SequenceName) ~= string(AnimName) ) // string conversion so we don't have case mismatches
		{
			PSC.bUseAsOccluder = true;
			AnimParticles.AddItem( PSC );
		}
	}
}

/** Constantly apply rotation while move is active */
function Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( KFPOwner != none )
	{
		// If we're no longer on the ground, we need to kill the special move
		if( KFPOwner.Role == ROLE_Authority && KFPOwner.Physics == PHYS_Falling && KFPOwner.SpecialMoves[KFPOwner.SpecialMove] == self )
		{
			KFPOwner.EndSpecialMove();
		}

		if( KFPOwner.Role != ROLE_SimulatedProxy )
		{
			KFPOwner.SetRotation( InitialRotation );
		}
	}
}

function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	local bool bWasPlayingCustomAnim;

	// abort animation if something ended the emote early
 	if( KFPOwner.BodyStanceNodes[AnimStance].bIsPlayingCustomAnim )
 	{
		KFPOwner.StopBodyAnim( AnimStance, 0.2 );
		bWasPlayingCustomAnim = true;
	}

	// Don't change attachment visibility if another camera mode has already been set
	KFPOwner.SetWeaponAttachmentVisibility( PCOwner == none || PCOwner.IsEmoteCameraMode() );

	if( PCOwner == none || !KFPOwner.IsLocallyControlled() )
	{
		// Make sure camera settings on the server match
		if( PCOwner != none && PCOwner.IsEmoteCameraMode() )
		{
			PCOwner.SetRotation( InitialRotation );
			PCOwner.PlayerCamera.CameraStyle = LastCameraMode;
		}

		SetParticlesVisible( bWasPlayingCustomAnim );
		ClearSMParticles();

		Super.SpecialMoveEnded( PrevMove, NextMove );
		return;
	}

	// Set our last used emote time so we can enforce a cooldown
	LastEmoteTime = KFPOwner.WorldInfo.TimeSeconds;

	// Stop the camera anim
	if( CameraAnim != none )
	{
		PCOwner.ClientStopCameraAnim( CameraAnim );
	}

	SetParticlesVisible( bWasPlayingCustomAnim );
	ClearSMParticles();

	// Return the camera to the player
	if( PCOwner.IsEmoteCameraMode() )
	{
		PCOwner.ClientSetCameraFade( true, FadeOutColor, vect2d(1.f, 0.f), FadeOutTime, true );
		PCOwner.SetRotation( InitialRotation );
        //Reset camera in case this was a gun fire.  This will resume normal updates next frame for 1st person mode
        PCOwner.PlayerCamera.CameraCache.POV.Rotation = InitialRotation;

		// Switch camera modes immediately in single player or on client
		if( PCOwner.WorldInfo.NetMode != NM_DedicatedServer )
		{
			PCOwner.ClientSetCameraMode( LastCameraMode );
		}
	}

	Super.SpecialMoveEnded( PrevMove, NextMove );
}

/** Make sure aim rotation is the same as our original aim rot */
function bool GetSMAimRotation( out rotator AimRot )
{
	AimRot = InitialRotation;
	return true;
}

DefaultProperties
{
	// ---------------------------------------------
	// SpecialMove
	Handle=KFSM_Player_Emote
	bDisableMovement=true
	bDisablesWeaponFiring=false
	bDisableSteering=true
	bLockPawnRotation=true

	// ---------------------------------------------
	// Animation
	BlendOutTime=0.15f

	// ---------------------------------------------
	// Camera fade
	FadeInColor=(R=0,G=0,B=0)
	FadeInTime=1.5f
	FadeOutColor=(R=0,G=0,B=0)
	FadeOutTime=0.6f

	// ---------------------------------------------
	// KFSM_Player_Emote
	EmoteCooldownTime=6.f
}