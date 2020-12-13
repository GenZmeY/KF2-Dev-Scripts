//=============================================================================
// KFSM_Siren_Scream
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_Siren_Scream extends KFSM_ScreamBase;

/** Cached pawn reference */
var KFPawn_ZedSiren MySirenPawn;

/**
 * Can a new special move override this one before it is finished?
 * This is only if CanDoSpecialMove() == TRUE && !bForce when starting it.
 */
function bool CanOverrideMoveWith( Name NewMove )
{
	if ( bCanBeInterrupted && (NewMove == 'KFSM_Stunned' || NewMove == 'KFSM_Stumble' || NewMove == 'KFSM_Knockdown' || NewMove == 'KFSM_Frozen') )
	{
		return TRUE;
	}
	return FALSE;
}

/**
 * Can the special move be chained after the current one finishes?
 */
function bool CanChainMove( Name NextMove )
{
	if( NextMove == 'KFSM_MeleeAttack' )
	{
		return true;
	}

	return super.CanChainMove( NextMove );
}

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );

	if (MySirenPawn == none)
	{
		MySirenPawn = KFPawn_ZedSiren(KFPOwner);
	}
}

/** Create and initialize projectile shield */
function SpawnProjectileShield()
{
	super.SpawnProjectileShield();

	// Flicker neck light as a visual cue
	if ( MySirenPawn != none )
	{
		MySirenPawn.EnableScreamFlicker( true );
	}
}

/** Destroys the projectile shield based on position in animation */
function Timer_DestroyProjectileShield()
{
	DestroyProjectileShield();
}

/** Destroy and clear proectile shield */
function DestroyProjectileShield()
{
	super.DestroyProjectileShield();

	// Turn off flicker when projectile shield goes down
	if( MySirenPawn != none )
	{
		MySirenPawn.EnableScreamFlicker( false );
	}
}

DefaultProperties
{
	// SpecialMove
	ProjectileShieldLifetime=2.2 // 0.52

	AnimName=Atk_Combo1_V1
	Handle=KFSM_Siren_Scream
	bDisableSteering=false
	bDisableMovement=false
   	AnimStance=EAS_UpperBody
   	bCanBeInterrupted=true

	ScreamDamage=15
	ScreamDamageFrequency=0.5f //1.0
	ScreamInterruptSound=AkEvent'WW_ZED_Siren.Stop_Siren_Scream'

   	bDrawProjectileShield=false
	bDrawWaveRadius=false

	ExplosionActorClass=class'KFExplosion_SirenScream'

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		//Damage=15	@NOTE: This is now set using the ScreamDamage variable -MattF
		DamageRadius=600 //800
		DamageFalloffExponent=1f
		DamageDelay=0.f

		MomentumTransferScale=100//-100000 Reactivate this to add siren pull

		ActorClassToIgnoreForDamage=class'KFPawn_Monster'

		// Damage Effects
		MyDamageType=class'KFDT_Sonic'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=none
		ExplosionSound=none

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.SirenScream'
		CamShakeInnerRadius=450
		CamShakeOuterRadius=700 //900
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0
}