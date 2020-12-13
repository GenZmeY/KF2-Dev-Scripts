//=============================================================================
// KFSM_PlayerSpecial_Slasher
//=============================================================================
// Player controlled stalker attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerSlasher_Roll extends KFSM_Evade;

var rotator InitialRotation;

/** Notification called when Special Move starts */
function SpecialMoveStarted( bool bForced, Name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );

	InitialRotation = KFPOwner.Rotation;
}

/**
 * Checks to see if this Special Move can be done.
 */
protected function bool InternalCanDoSpecialMove()
{
	return KFPOwner != none && KFPOwner.Physics == PHYS_Walking && super.InternalCanDoSpecialMove();
}

static function byte PackFlagsBase(KFPawn P)
{
	return class'KFSM_PlayerMeleeBase'.static.GetFourWayMoveDirection(P);
}

/** Constantly apply velocity while move is active */
function Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( KFPOwner != none && KFPOwner.Role != ROLE_SimulatedProxy )
	{
		KFPOwner.SetRotation( InitialRotation );
	}
}

defaultproperties
{
	bUseRootMotion=true
	bDisableSteering=true
	bLockPawnRotation=true
	EvadeAnims.Empty
	EvadeAnims(DIR_Forward)=(Anims=(Player_Roll_F))
	EvadeAnims(DIR_Backward)=(Anims=(Player_Roll_B))
	EvadeAnims(DIR_Left)=(Anims=(Player_Roll_L))
	EvadeAnims(DIR_Right)=(Anims=(Player_Roll_R))

	// ---------------------------------------------
	// Camera
	bUseCustomThirdPersonViewOffset=true
	CustomThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=50,Z=-80),
		OffsetLow=(X=-220,Y=50,Z=-80),
		OffsetMid=(X=-145,Y=50,Z=-90),
		)}
	ViewOffsetInterpTime=0.3f
	CustomCameraFOV=80.f
	CameraFOVTransitionTime=0.3f		
}