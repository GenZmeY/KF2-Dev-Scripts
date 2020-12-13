//=============================================================================
// KFSM_Husk_FireBallAttack
//=============================================================================
// Player-controlled Husk fireball attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerHusk_FireBallAttack extends KFSM_PlaySingleAnim;

/** Cached reference to pawn */
var KFPawn_ZedHusk_Versus MyHuskPawn;

/** Time when the special move started */
var float HoldStartTime;

/** Set to true when wind up anim ahs finished */
var bool bReadyToFire;

/** Anims */
var name WindUpAnimName;
var name FireHeldAnimName;

/** VFX */
var ParticleSystem LoopingMuzzleEffect;
var ParticleSystemComponent MuzzlePSC;
var name MuzzleFXSocketName;

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );	

	MyHuskPawn = KFPawn_ZedHusk_Versus( KFPOwner );

	HoldStartTime = MyHuskPawn.WorldInfo.TimeSeconds;
	bReadyToFire = false;
	
	// Spawn and attach our muzzle FX
	if( MyHuskPawn.WorldInfo.MyEmitterPool != none )
	{
		MuzzlePSC = MyHuskPawn.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( LoopingMuzzleEffect, MyHuskPawn.Mesh, MuzzleFXSocketName, true );
	}

	PlayWindUpAnimation();
}

/** Overridden to do nothing */
function PlayAnimation() {}

/** Plays our wind up anim, starts the barrel spin skel controller */
function PlayWindUpAnimation()
{
	bUseRootMotion = false;
	PlaySpecialMoveAnim( WindUpAnimName, AnimStance, BlendInTime, BlendOutTime, 1.f );
}

/** Plays our looping hold animation */
function PlayFireHeldAnimation()
{
	bReadyToFire = true;
	PlaySpecialMoveAnim( FireHeldAnimName, AnimStance, BlendInTime, BlendOutTime, 1.f, true );

	if( MyHuskPawn != none )
	{
		MyHuskPawn.SetFireLightEnabled( true );
	}	
}

/** Plays the fire animation */
function PlayFireAnimation()
{
	bReadyToFire = false;
	bPendingStopFire = false;

	PlaySpecialMoveAnim( AnimName, AnimStance, BlendInTime, BlendOutTime, 1.f, false );
}

/** Plays subsequent animations in the barrage */
function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	switch( SeqNode.AnimSeqName )
	{
		case WindUpAnimName:
			if( bPendingStopFire )
			{
				PlayFireAnimation();
			}
			else
			{
				PlayFireHeldAnimation();
			}
			break;

		case AnimName:
			KFPOwner.EndSpecialMove();
			break;
	}
}

/** Update looping muzzle effect size */
simulated function Tick( float DeltaTime )
{
	local float Strength;
	local vector2d StrengthRange;

	super.Tick( DeltaTime );

	if( MuzzlePSC != none )
	{
		StrengthRange = MyHuskPawn.GetFireballStrengthRange();
		Strength = fClamp( (MyHuskPawn.WorldInfo.TimeSeconds - HoldStartTime) * MyHuskPawn.GetFireballStrengthPerSecond(), StrengthRange.X, StrengthRange.Y );
		MuzzlePSC.SetFloatParameter( 'FX_Size', 1.f * (Strength / StrengthRange.Y) );
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	if( MuzzlePSC != none && MuzzlePSC.bIsActive )
	{
		MuzzlePSC.DeactivateSystem();
	}

	super.SpecialMoveEnded( PrevMove, NextMove );
}

/** Wait for a button release and fire */
function SpecialMoveFlagsUpdated()
{
	if( KFPOwner.SpecialMoveFlags == FLAG_SpecialMoveButtonReleased )
	{
		bPendingStopFire = true;
		if( bReadyToFire )
		{
			PlayFireAnimation();
		}
	}
	else if( KFPOwner.SpecialMoveFlags == FLAG_SpecialMoveButtonPressed )
	{
		bPendingStopFire = false;
	}
	else
	{
		super.SpecialMoveFlagsUpdated();
	}
}

/* Called on some player-controlled moves when a firemode input has been pressed */
function SpecialMoveButtonRetriggered()
{
	KFPOwner.DoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonPressed );
	if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.ServerDoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonPressed );
	}
}

/** Called on some player-controlled moves when a firemode input has been released */
function SpecialMoveButtonReleased()
{
	KFPOwner.DoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonReleased );
	if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.ServerDoSpecialMove( KFPOwner.SpecialMove, true,, FLAG_SpecialMoveButtonReleased );
	}
}

DefaultProperties
{
	// SpecialMove
	Handle=KFSM_PlayerHusk_FireBallAttack
	bDisableSteering=false
	bDisableMovement=true
	bDisableTurnInPlace=true
   	bCanBeInterrupted=true
   	CustomTurnInPlaceAnimRate=2.f

   	// Animation
	WindUpAnimName=Player_Shoot_Start
	FireHeldAnimName=Player_Shoot_Loop
	AnimName=Player_Shoot_End
	AnimStance=EAS_FullBody
	bUseRootMotion=false

	// VFX
	LoopingMuzzleEffect=ParticleSystem'ZED_Husk_EMIT.FX_Husk_muzzleflash_Loop_01'
	MuzzleFXSocketName=EMPDisruptSocket

	// Camera
	bUseCustomThirdPersonViewOffset=true
	CustomThirdPersonViewOffset={(
		OffsetHigh=(X=-135,Y=75,Z=40),
		OffsetLow=(X=-180,Y=75,Z=50),
		OffsetMid=(X=-120,Y=60,Z=0),
		)}
	ViewOffsetInterpTime=0.3f
	CustomCameraFOV=60.f
	CameraFOVTransitionTime=0.4f
}