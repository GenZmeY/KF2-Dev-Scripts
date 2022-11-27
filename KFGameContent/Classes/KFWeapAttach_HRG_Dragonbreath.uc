//=============================================================================
// KFWeapAttach_HRG_Dragonbreath
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_HRG_Dragonbreath extends KFWeaponAttachment;

`define HRGDRAGONBREATH_MIC_BARREL_INDEX 0

var transient float BarrelHeatPerProjectile;
var transient float MaxBarrelHeat;
var transient float BarrelCooldownRate;
var transient float CurrentBarrelHeat;
var transient float LastBarrelHeat;
var transient int NumPelletsDefault;
var transient int NumPelletsAlt;

simulated event PreBeginPlay()
{
    Super.PreBeginPlay();

    BarrelHeatPerProjectile = class'KFWeap_HRG_Dragonbreath'.default.BarrelHeatPerProjectile;
    MaxBarrelHeat           = class'KFWeap_HRG_Dragonbreath'.default.MaxBarrelHeat;
    BarrelCooldownRate      = class'KFWeap_HRG_Dragonbreath'.default.BarrelCooldownRate;
    NumPelletsDefault       = class'KFWeap_HRG_Dragonbreath'.default.NumPellets[0];
    NumPelletsAlt           = class'KFWeap_HRG_Dragonbreath'.default.NumPellets[1];
}

simulated event PostBeginPlay()
{
    Super.PostBeginPlay();
    
    // Force start with "Glow_Intensity" of 0.0f
	LastBarrelHeat = MaxBarrelHeat;
	ChangeBarrelMaterial();
}

simulated function ChangeBarrelMaterial()
{
    if( CurrentBarrelHeat != LastBarrelHeat )
    {
        if ( WeaponMIC == None && WeapMesh != None )
        {
            WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`HRGDRAGONBREATH_MIC_BARREL_INDEX);
        }
    
        WeaponMIC.SetScalarParameterValue('Barrel_intensity', CurrentBarrelHeat);
    }
}

simulated function Tick(float Delta)
{
	Super.Tick(Delta);

	CurrentBarrelHeat = fmax(CurrentBarrelHeat - BarrelCooldownRate * Delta, 0.0f);
	ChangeBarrelMaterial();
}

/** Override to update emissive in weapon's barrel after firing */
simulated function PlayWeaponFireAnim()
{
    local float BarrelHeatPerShot;
    local KFPawn OwnerPawn;

	Super.PlayWeaponFireAnim();

	OwnerPawn = KFPawn(Owner);

    BarrelHeatPerShot = BarrelHeatPerProjectile * (OwnerPawn.FiringMode == 0 ? NumPelletsDefault : NumPelletsAlt);
    CurrentBarrelHeat = fmin(CurrentBarrelHeat + BarrelHeatPerShot, MaxBarrelHeat);
}

defaultproperties
{
	CurrentBarrelHeat=0.0f
	LastBarrelHeat=0.0f
    NumPelletsDefault=0
    NumPelletsAlt=0
}