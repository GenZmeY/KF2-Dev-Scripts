//=============================================================================
// KFWeapAttach_HRG_BarrierRifle
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_HRG_BarrierRifle extends KFWeaponAttachment;

`define BARRIERRIFLE_MIC_SHIELD_INDEX 0

/** Indicates wheter we are activating/deactivating the shield fx */
var protected transient bool  bActivatingShield;
var protected transient float FXDelta;
var protected transient float ShieldFXDuration;
var protected transient float OverlayDelta;
var protected transient float OverlayMax;
var protected transient float OverlayMin;
var protected transient float ShieldBlockVFXDuration;

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

    ShieldFXDuration       = class'KFWeap_HRG_BarrierRifle'.default.ShieldFXDuration;
	OverlayMax             = class'KFWeap_HRG_BarrierRifle'.default.RedOverlayMax;
	OverlayMin             = class'KFWeap_HRG_BarrierRifle'.default.RedOverlayMin;
	ShieldBlockVFXDuration = class'KFWeap_HRG_BarrierRifle'.default.ShieldBlockVFXDuration;

    UpdateShieldFXValue(0.0f);
}

simulated function UpdateShieldFXValue(float Value)
{
	if ( WeaponMIC == None && WeapMesh != None )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`BARRIERRIFLE_MIC_SHIELD_INDEX);
	}
    
    WeaponMIC.SetScalarParameterValue('Opacity', Value);
}

unreliable client function SetShieldActive(bool bActive)
{
    bActivatingShield = bActive;
}

/** Special event added for weap attachments. Free for use */
function OnSpecialEvent(int Arg)
{
	if (Arg < 2)
	{
    	SetShieldActive(Arg == 1 ? True : False);
	}
	else if (Arg == 3)
	{
		UpdateShieldBlockVFX(OverlayMax);
		OverlayDelta = OverlayMax;
	}
}

simulated function UpdateShieldBlockVFX(float Value)
{
	if ( WeaponMIC == None && WeapMesh != None )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`BARRIERRIFLE_MIC_SHIELD_INDEX);
	}
	WeaponMIC.SetScalarParameterValue('RedOverlay', Value);
}

simulated event Tick(float DeltaTime)
{
	// Update Shield visuals
	if (bActivatingShield && FXDelta < class'KFWeap_HRG_BarrierRifle'.default.ShieldFXDuration)
	{
		FXDelta = FMin(FXDelta + DeltaTime, ShieldFXDuration);
		UpdateShieldFXValue(FXDelta / ShieldFXDuration);
	}
	else if (!bActivatingShield && FXDelta > 0.0f)
	{
		FXDelta = FMax(FXDelta - DeltaTime, 0.0f);
		UpdateShieldFXValue(FXDelta / ShieldFXDuration);
	}

	if (OverlayDelta > 0.0f)
	{
		OverlayDelta = FMax(OverlayDelta - DeltaTime, OverlayMin);
		UpdateShieldBlockVFX(OverlayMax * (OverlayDelta / ShieldBlockVFXDuration));
	}
}

defaultproperties
{
	OverlayDelta=0.0f
}
