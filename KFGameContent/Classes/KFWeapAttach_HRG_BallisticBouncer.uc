//=============================================================================
// KFWeapAttach_HRG_BallisticBouncer
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_HRG_BallisticBouncer extends KFWeaponAttachment;

var() StaticMesh ChargeStaticMesh;
var transient StaticMeshComponent ChargeAttachment; 
var transient MaterialInstanceConstant ChargeMIC;

var float MinProjPlaceholderScale;
var float MaxProjPlaceHolderScale;

var bool bIsCharging;
var bool bIsFullyCharged;

var repnotify float StartFireTime;

var int ChargeLevel;

var float ChargeRTPC;

simulated function StartFire()
{
	StartFireTime = WorldInfo.TimeSeconds;
	bIsCharging = true;
	
	if (ChargeAttachment == none)
	{
        ChargeAttachment = new (self) class'StaticMeshComponent';
        ChargeAttachment.SetStaticMesh(ChargeStaticMesh);

		if (WeapMesh != none)
		{
			WeapMesh.AttachComponentToSocket(ChargeAttachment, 'MuzzleFlash');
		}
		else
		{
			AttachComponent(ChargeAttachment);
		}
        
	}

	if (ChargeAttachment != none)
	{
        ChargeAttachment.SetScale(MinProjPlaceholderScale);
        ChargeAttachment.SetHidden(false);
	}
}

simulated event Tick(float DeltaTime)
{
    local float ChargeValue;

	if(bIsCharging && !bIsFullyCharged)
	{
		ChargeValue = FMin(class'KFWeap_HRG_BallisticBouncer'.default.MaxChargeTime, WorldInfo.TimeSeconds - StartFireTime) / class'KFWeap_HRG_BallisticBouncer'.default.MaxChargeTime;

        if (ChargeValue >= 1.0f)
        {
            bIsFullyCharged = true;
            ChargeValue = 1.0f;
        }

		if( ChargeAttachment != none)
		{
            ChargeAttachment.SetScale(MinProjPlaceholderScale + (MaxProjPlaceHolderScale - MinProjPlaceholderScale) * ChargeValue);
		}
	}

	Super.Tick(DeltaTime);
}

simulated function FirstPersonFireEffects(Weapon W, vector HitLocation)
{
	super.FirstPersonFireEffects(W, HitLocation);
	if (ChargeAttachment != none)
	{
		ChargeAttachment.SetHidden(true);
	}
}

simulated function bool ThirdPersonFireEffects(vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte)
{
	bIsCharging = false;
	bIsFullyCharged = false;
	ChargeRTPC=0;

	if (ChargeAttachment != none)
	{
		ChargeAttachment.SetHidden(true);
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

	ChargeStaticMesh = StaticMesh'WEP_HRG_BallisticBouncer_EMIT.HRG_BallisticBouncer_ball_MESH'
	MinProjPlaceholderScale = 2.0f;
	MaxProjPlaceholderScale = 3.0f;
}
