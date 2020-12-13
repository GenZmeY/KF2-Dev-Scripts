//=============================================================================
// KFWeapAttach_MineRec
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// fferrando@saber3d
//=============================================================================
class KFWeapAttach_Mine_Reconstructor extends KFWeaponAttachment;

var transient ParticleSystemComponent ChargingPSC;
var ParticleSystem ChargingEffect;
var ParticleSystem ChargedEffect;
var bool bIsCharging;
var bool bIsFullyCharged;

var repnotify float StartFireTime;

var int ChargeLevel;

var float FXScalingFactorByCharge;
var float ChargeRTPC;

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
	local vector vec;

	if(bIsCharging && !bIsFullyCharged)
	{
		ChargeRTPC = FMin(class'KFWeap_Mine_Reconstructor'.default.MaxChargeTime, WorldInfo.TimeSeconds - StartFireTime) / class'KFWeap_Mine_Reconstructor'.default.MaxChargeTime;

		if (ChargeRTPC >= 1.f)
		{

			bIsFullyCharged = true;
			vec.X = FMin(1.0f, ChargeRTPC);
			vec.Y = FMin(1.0f, ChargeRTPC);
			vec.Z = FMin(1.0f, ChargeRTPC);
			ChargingPSC.SetVectorParameter( name("BlobCharge"), vec);
			//ChargingPSC.SetTemplate(ChargedEffect);
		}

		if( ChargingPSC != none && !bIsFullyCharged)
		{
			//ChargingPSC.SetScale( FXScalingFactorByCharge );
			//FXScalingFactorByCharge = FMin(Lerp(class'KFWeap_Mine_Reconstructor'.default.MinScale, class'KFWeap_Mine_Reconstructor'.default.MaxScale, WorldInfo.TimeSeconds - StartFireTime / class'KFWeap_Mine_Reconstructor'.default.MaxChargeTime), class'KFWeap_Mine_Reconstructor'.default.MaxScale);
			vec.X =ChargeRTPC;
			vec.Y =ChargeRTPC;
			vec.Z =ChargeRTPC;
			ChargingPSC.SetVectorParameter( name("BlobCharge"), vec);
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
	ChargeRTPC=0;
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

	Super.CauseMuzzleFlash(FiringMode);
}

defaultproperties
{
	ChargeRTPC=0
	MuzzleFlashTemplate=KFMuzzleFlash'WEP_Mine_Reconstructor_Arch.Wep_Mine_Reconstructor_MuzzleFlash_3P'

	ChargingEffect=ParticleSystem'WEP_Mine_Reconstructor_EMIT.FX_Bile_BlobCharge_01'
	ChargedEffect=ParticleSystem'WEP_Mine_Reconstructor_EMIT.FX_Mine_Reconstructor_FullCharge'
}
