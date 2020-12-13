//=============================================================================
// KFPowerUp
//=============================================================================
// Base class for the KF2 power ups
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPowerUp extends ReplicationInfo
	config(game);

/** Localized name of the power up */
var	localized 	string 	PowerUpName;

/** Duration of the power up */
var float PowerUpDuration;

/** Current time remaining until the power up ends */
var transient float RemainingDuration;

/** Is the power up active */
var bool bPowerUpActive;

/** Can the player pawn be healed with the power up active */
var bool CanBeHealedWhilePowerUpIsActive;

/*********************************************************************************************
* Secondary Damage
********************************************************************************************* */

/** Damage type to use for the burning DOT */
var class<KFDamageType> SecondaryDamageType;

/** Damage value to use for the burning DOT */
var int SecondaryDamage;

/*********************************************************************************************
* Caching
********************************************************************************************* */

var 		KFPlayerController		OwnerPC;
var 		KFPawn_Human			OwnerPawn;

/*********************************************************************************************
* Effects and sounds
********************************************************************************************* */

/** The name of the screen material to update when the power up is active */
var name ScreenMaterialName;

/** Camera lens emitter effects when a pawn has this power up */
var class<EmitterCameraLensEffectBase> CameraLensEffectTemplate;

/** 3rd person effect attached to the pawn for the power up */
var ParticleSystem PowerUpEffect;

/** Audio loop for first person */
var AKEvent AudioLoopFirstPerson;

/** Audio loop for third person */
var AKEvent AudioLoopThirdPerson;

/** Audio triggered at the end of the loop for first person */
var AKEvent AudioLoopThirdPersonStop;

/** Audio triggered at the end of the loop for third person */
var AKEvent AudioLoopFirstPersonStop;

function ActivatePowerUp()
{
	if(Role == Role_Authority)
	{
		RemainingDuration = PowerUpDuration;
		bPowerUpActive = true;
		OwnerPawn.UpdateGroundSpeed();
		OwnerPawn.SetPowerUpAmbientSound(AudioLoopThirdPerson, AudioLoopFirstPerson);
		SetTimer(0.05f, false, nameof(PlayPowerUp));
	}
}

function ReactivatePowerUp()
{
	if(Role == Role_Authority && bPowerUpActive && RemainingDuration > 0)
	{
		RemainingDuration = PowerUpDuration;
		OwnerPawn.UpdateGroundSpeed();
		OwnerPawn.StopPowerUp(class);
		SetTimer(0.05f, false, nameof(PlayPowerUp));
	}
}

function PlayPowerUp()
{
	OwnerPawn.PlayPowerUp(class);
}

function DeactivatePowerUp()
{	
	if(Role == Role_Authority)
	{
		bPowerUpActive = false;
		RemainingDuration = 0;

		if(OwnerPC != none)
		{
			OwnerPawn.StopPowerUp(class);
			OwnerPawn.SetPowerUpAmbientSound(none, none, AudioLoopThirdPersonStop, AudioLoopFirstPersonStop);
			OwnerPC.CurrentPowerUp = none;
			OwnerPC.CurrentPowerUpClass = none;
			OwnerPC.ClientUpdatePowerUp(none);
		}

		OwnerPawn.UpdateGroundSpeed();

		self.Destroy();
	}
}

simulated function ModifySpeed( out float Speed );
simulated function ModifySprintSpeed( out float Speed ){ ModifySpeed( Speed ); }
function FinalizeSpeedVariables();

function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx );
function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy );

function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy );

function bool CanBeHealed(){ return CanBeHealedWhilePowerUpIsActive; }

static function PlayEffects( KFPawn_Human P )
{
	local ParticleSystemComponent ParticleEffect;

	if( default.PowerUpEffect != none )
	{
		ParticleEffect = P.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(default.PowerUpEffect, P.Mesh, 'Hips', false);
		P.CurrentPowerUpEffect.PowerUpType = default.class;
		P.CurrentPowerUpEffect.ParticleEffect = ParticleEffect;
	}
}

simulated event Tick(float DeltaTime)
{
	if(Role == Role_Authority)
	{
		if(bPowerUpActive)
		{
			RemainingDuration -= DeltaTime;
			if(RemainingDuration <= 0)
			{
				DeactivatePowerUp();
			}
		}
	}
}

event Destroyed()
{	
	if(bPowerUpActive)
	{
		DeactivatePowerUp();
	}
	super.Destroyed();
}

simulated function PlayerDied()
{
	DeactivatePowerUp();
}

DefaultProperties
{
	PowerUpDuration=0.5f
	CanBeHealedWhilePowerUpIsActive=true

	bTickIsDisabled=False

	// network
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=1.0
	bAlwaysRelevant=True
	bOnlyRelevantToOwner=true
}
