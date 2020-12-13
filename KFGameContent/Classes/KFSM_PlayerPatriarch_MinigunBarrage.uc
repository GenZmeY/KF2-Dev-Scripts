//=============================================================================
// KFSM_PlayerPatriarch_MinigunBarrage
//=============================================================================
// Player-controlled Patriarch's minigun barrage attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerPatriarch_MinigunBarrage extends KFSM_Patriarch_MinigunBarrage;

var bool bAnimCanBeInterrupted;

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	bAnimCanBeInterrupted = false;
	bPendingStopFire = false;

	super.SpecialMoveStarted( bForced, PrevMove );
}

/** Plays our fire animation, starts weapon fire */
function PlayFireAnim()
{
	if( bInterrupted || bObstructed )
	{
		return;
	}

	super.PlayFireAnim();

	if( KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.SetTimer( KFSkeletalMeshComponent(KFPOwner.Mesh).GetAnimInterruptTime(AnimName), false, nameOf(Timer_AnimInterrupt), self );
	}
}

/** Overridden to restore camera settings */
function PlayWindDownAnim()
{
	super.PlayWindDownAnim();

	RestoreCameraDefaults();
}

/** Called on animations that can be interrupted */
function Timer_AnimInterrupt()
{
	bAnimCanBeInterrupted = true;

	if( bPendingStopFire )
	{
		SpecialMoveButtonReleased();
	}
}

function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	// Reset special move flags
	if( KFPOwner != none )
	{
		KFPOwner.SpecialMoveFlags = 255;
	}

	super.SpecialMoveEnded( PrevMove, NextMove );
}

/** When the grapple animation ends, continue it with a different grapple anim */
function SpecialMoveFlagsUpdated()
{
	if( KFPOwner.SpecialMoveFlags == FLAG_SpecialMoveButtonReleased )
	{
    	bInterrupted = true;
        if( !bIsFanFire )
        {
        	MyPatPawn.StopBodyAnim( EAS_UpperBody, 0.1f );
	    }
   		PlayWindDownAnim();
	}
	else
	{
		super.SpecialMoveFlagsUpdated();
	}
}

/* Called on some player-controlled moves when a firemode input has been pressed */
function SpecialMoveButtonRetriggered()
{
	bPendingStopFire = false;
}

/** Called on some player-controlled moves when a firemode input has been released */
function SpecialMoveButtonReleased()
{
	bPendingStopFire = true;

	if( !bAnimCanBeInterrupted )
	{
		return;
	}

	KFPOwner.DoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonReleased );
	if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.ServerDoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonReleased );
	}
}

defaultproperties
{
	Handle=KFSM_PlayerPatriarch_MinigunBarrage
	//WindUpAnimName=Gun_TO_Load
	//WindDownAnimName=Gun_TO_Idle
	//AnimName=Gun_Idle	

	bUseCustomThirdPersonViewOffset=true
	CustomThirdPersonViewOffset={(
		OffsetHigh=(X=-140,Y=90,Z=45),
		OffsetLow=(X=-160,Y=130,Z=55),
		OffsetMid=(X=-125,Y=110,Z=45),
		)}
	ViewOffsetInterpTime=0.4f
	CustomCameraFOV=60.f
	CameraFOVTransitionTime=0.5f
}