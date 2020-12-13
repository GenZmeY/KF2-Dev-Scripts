//=============================================================================
// KFDT_Bludgeon_HRG_Vampire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_HRG_Vampire extends KFDT_Bludgeon_RifleButt
	abstract
	hidedropdown;

DefaultProperties
{
	StumblePower=200
	MeleeHitPower=100

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_HRG_Vampire'
}