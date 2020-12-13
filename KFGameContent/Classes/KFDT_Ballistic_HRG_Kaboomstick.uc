//=============================================================================
// KFDT_Ballistic_HRG_Kaboomstick
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
// Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Ballistic_HRG_Kaboomstick extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3500
	KDeathUpKick=800 //600
	KDeathVel=650 //450

    StumblePower=75
	GunHitPower=45
	
	WeaponDef=class'KFWeapDef_HRG_Kaboomstick'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}
