//=============================================================================
// KFDT_Ballistic_G18C
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_G18C extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=12 //afflictions Default Firemode (Automatic)  & Altfire Firemode (Single Fire)
	GunHitPower=12 //afflictions Bash Firemode

	WeaponDef=class'KFWeapDef_Pistol_G18C'
	ModifierPerkList(0)=class'KFPerk_Gunslinger'
}
