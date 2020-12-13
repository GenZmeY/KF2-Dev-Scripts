//=============================================================================
// KFDT_Ballistic_LazerCutter
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_LazerCutter extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	StumblePower=15

	EMPPower=8

	WeaponDef=class'KFWeapDef_LazerCutter'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Survivalist'

	EffectGroup=FXG_Electricity
}
