//=============================================================================
// KFDT_Toxic_MineReconstructorImpact
//=============================================================================
// Toxic damage type for the Mine reconstructor direct hit when high charge percentage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// fferrando@saber3d
//=============================================================================

class KFDT_Toxic_MineReconstructorImpactHeavy extends KFDT_Ballistic_Shell
    abstract
    hidedropdown;

static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	return false;
}

defaultproperties
{
	//override dot as the impact has no dot
	DoT_Type=DOT_NONE

	EffectGroup=FXG_Toxic

	MicrowavePower=50;
	PoisonPower=60;
	StumblePower=340;
	KnockdownPower=190;
	GunHitPower=275;
	//EMPPower=200;
	
	bHasToSpawnMicrowaveFire=false;

	// physics impact
	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_Mine_Reconstructor'
}
 