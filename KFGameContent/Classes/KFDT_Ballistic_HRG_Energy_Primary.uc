//=============================================================================
// KFDT_Ballistic_HRG_Energy_Primary
//=============================================================================
// HRG Energy Gun Damage Type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Energy_Primary extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=15
	GunHitPower=175

	WeaponDef=class'KFWeapDef_HRG_Energy'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Gunslinger'

	EffectGroup=FXG_Energy_Yellow
}
