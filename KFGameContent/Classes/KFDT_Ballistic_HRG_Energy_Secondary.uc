//=============================================================================
// KFDT_Ballistic_HRG_Energy_Secondary
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Energy_Secondary extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{

	StumblePower=100
	KnockdownPower=20
	GunHitPower=250
	EMPPower=60

	WeaponDef=class'KFWeapDef_HRG_Energy'

	//Perk
	ModifierPerkList(2)=class'KFPerk_Gunslinger'

	EffectGroup=FXG_Energy_Magenta
}
