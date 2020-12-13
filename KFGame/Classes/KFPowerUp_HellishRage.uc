//=============================================================================
// KFPowerUp_HellishRage
//=============================================================================
// Base class for the hellish rage power up
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPowerUp_HellishRage extends KFPowerUp;

/** Health removed from the player when the power up is activated */
var int HealthCost;

/** Damage cost applied when the power up is activated */
var class<KFDamageType> PowerUpCostDamageType;

/** Damage modifier for all damage done by the owner of this power up */
var float DamageModifier;

/** Speed modifier for run speed by the owner of this power up */
var float SpeedModifier;

/** Speed modifier for sprint speed by the owner of this power up */
var float SprintSpeedModifier;

function ActivatePowerUp()
{
	super.ActivatePowerUp();
	if(Role == Role_Authority && bPowerUpActive)
	{
		ApplyPowerUpCost();
	}
}

function ReactivatePowerUp()
{
	super.ReactivatePowerUp();
	if(Role == Role_Authority && bPowerUpActive)
	{
		ApplyPowerUpCost();
	}
}

function ApplyPowerUpCost()
{
	OwnerPawn.TakeDamage(HealthCost, OwnerPC, vect(0,0,0), vect(0,0,0), PowerUpCostDamageType);
}

function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
	local float TempDamage;
	TempDamage = InDamage;

	if( DamageCauser != none )
	{
		TempDamage += InDamage * DamageModifier;
	}

	InDamage = Round( TempDamage );
}

simulated function ModifySpeed( out float Speed )
{
	Speed += Speed * SpeedModifier;
}

simulated function ModifySprintSpeed( out float Speed )
{
	Speed += Speed * SprintSpeedModifier;
}

function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{
	if( Victim != none && Victim != OwnerPawn )
	{
		Victim.ApplyDamageOverTime(SecondaryDamage, InstigatedBy, default.SecondaryDamageType);
	}
}

DefaultProperties
{
	PowerUpCostDamageType=class'KFDT_HellishRageCost'
	HealthCost=20 //25

	PowerUpDuration=20.f //15.f
	CanBeHealedWhilePowerUpIsActive=false

	DamageModifier=0.5f
	SpeedModifier=0.25f
	SprintSpeedModifier=0.25f

	AudioLoopFirstPerson=AkEvent'WW_ENV_HellmarkStation.Play_HellishRage_1P'
	AudioLoopThirdPerson=AkEvent'WW_ENV_HellmarkStation.Play_HellishRage_3P'
	AudioLoopFirstPersonStop=AkEvent'WW_ENV_HellmarkStation.Stop_HellishRage_1P'
	AudioLoopThirdPersonStop=AkEvent'WW_ENV_HellmarkStation.Stop_HellishRage_3P'

	SecondaryDamageType=class'KFDT_Fire_HellishRage'
	SecondaryDamage=50

	ScreenMaterialName=Effect_PowerUp_HellishRage
	CameraLensEffectTemplate=class'KFCameraLensEmit_PowerUp_HellishRage'

	PowerUpEffect=ParticleSystem'FX_Gameplay_EMIT.FX_Char_PowerUp_HellishRage'
}
