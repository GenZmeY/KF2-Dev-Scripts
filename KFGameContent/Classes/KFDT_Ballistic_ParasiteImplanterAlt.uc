//=============================================================================
// KFDT_Ballistic_ParasiteImplanterAlt
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_ParasiteImplanterAlt extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	KnockdownPower=30
	StumblePower=200
	GunHitPower=100
	PoisonPower=0 //80

	WeaponDef=class'KFWeapDef_ParasiteImplanter'
	
	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	ModifierPerkList(1)=class'KFPerk_Sharpshooter'
}
