//=============================================================================
// KFWeapAttach_HuskCannon
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_HuskCannon extends KFWeaponAttachment;

var transient ParticleSystemComponent ChargingPSC;
var ParticleSystem ChargingEffect;
var ParticleSystem ChargedEffect;
var bool bIsCharging;
var bool bIsFullyCharged;

var float StartFireTime;

var int ChargeLevel;

var const ParticleSystem MuzzleFlashEffectL1;
var const ParticleSystem MuzzleFlashEffectL2;
var const ParticleSystem MuzzleFlashEffectL3;

simulated function StartFire()
{
	StartFireTime = WorldInfo.TimeSeconds;
	bIsCharging = true;

	if (ChargingPSC == none)
	{
		ChargingPSC = new(self) class'ParticleSystemComponent';

		if (WeapMesh != none)
		{
			WeapMesh.AttachComponentToSocket(ChargingPSC, 'MuzzleFlash');
		}
		else
		{
			AttachComponent(ChargingPSC);
		}
	}
	else
	{
		ChargingPSC.ActivateSystem();
	}

	if (ChargingPSC != none)
	{
		ChargingPSC.SetTemplate(ChargingEffect);
	}
}

simulated event Tick(float DeltaTime)
{
	local float ChargeRTPC;

	if(bIsCharging && !bIsFullyCharged)
	{
		ChargeRTPC = FMin(class'KFWeap_HuskCannon'.default.MaxChargeTime, WorldInfo.TimeSeconds - StartFireTime) / class'KFWeap_HuskCannon'.default.MaxChargeTime;

		if (ChargeRTPC >= 1.f)
		{
			bIsFullyCharged = true;
			ChargingPSC.SetTemplate(ChargedEffect);
		}
	}

	Super.Tick(DeltaTime);
}

simulated function FirstPersonFireEffects(Weapon W, vector HitLocation)
{
	super.FirstPersonFireEffects(W, HitLocation);

	if (ChargingPSC != none)
	{
		ChargingPSC.DeactivateSystem();
	}
}

simulated function bool ThirdPersonFireEffects(vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte)
{
	bIsCharging = false;
	bIsFullyCharged = false;

	ChargeLevel = GetChargeFXLevel();

	if (ChargingPSC != none)
	{
		ChargingPSC.DeactivateSystem();
	}

	return Super.ThirdPersonFireEffects(HitLocation, P, ThirdPersonAnimRateByte);
}

simulated function CauseMuzzleFlash(byte FiringMode)
{
	if (MuzzleFlash == None && MuzzleFlashTemplate != None)
	{
		AttachMuzzleFlash();
	}

	switch (ChargeLevel)
	{
	case 1:
		MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = MuzzleFlashEffectL1;
		MuzzleFlash.MuzzleFlash.PSC.SetTemplate(MuzzleFlashEffectL1);
		break;
	case 2:
		MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = MuzzleFlashEffectL2;
		MuzzleFlash.MuzzleFlash.PSC.SetTemplate(MuzzleFlashEffectL2);
		break;
	case 3:
		MuzzleFlash.MuzzleFlash.ParticleSystemTemplate = MuzzleFlashEffectL3;
		MuzzleFlash.MuzzleFlash.PSC.SetTemplate(MuzzleFlashEffectL3);
		break;
	}

	Super.CauseMuzzleFlash(FiringMode);
}

// Should generally match up with KFWeap_HuskCannon::GetChargeFXLevel
function int GetChargeFXLevel()
{
	local int MaxCharges;
	local int Charges;

	MaxCharges = int(class'KFWeap_HuskCannon'.default.MaxChargeTime / class'KFWeap_HuskCannon'.default.ValueIncreaseTime);
	Charges = Min((WorldInfo.TimeSeconds - StartFireTime) / class'KFWeap_HuskCannon'.default.ValueIncreaseTime, MaxCharges);

	if (Charges <= 1)
	{
		return 1;
	}
	else if (Charges < MaxCharges)
	{
		return 2;
	}
	else
	{
		return 3;
	}
}

defaultproperties
{
	MuzzleFlashTemplate=KFMuzzleFlash'WEP_HuskCannon_ARCH.Wep_HuskCannon_MuzzleFlash_3P'

	MuzzleFlashEffectL1=ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_MuzzleFlash_L1_3P'
	MuzzleFlashEffectL2=ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_MuzzleFlash_L2_3P'
	MuzzleFlashEffectL3=ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_MuzzleFlash_L3_3P'

	ChargingEffect=ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_Charging_01'
	ChargedEffect=ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_Charged_01'
}
