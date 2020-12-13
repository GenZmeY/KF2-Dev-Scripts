//=============================================================================
// KFDT_LazerCutter_Beam
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDT_LazerCutter_Beam extends KFDT_Microwave
	abstract
	hidedropdown;

/** Test obliterate conditions when taking damage */
static function bool CheckObliterate(Pawn P, int Damage)
{
	return default.bCanObliterate;
}

defaultproperties
{
	// physics impact
	RadialDamageImpulse = 750
	KDeathUpKick = 750
	KDeathVel = 350
	KDamageImpulse = 2000

	GunHitPower=150
	EMPPower = 10
	WeaponDef = class'KFWeapDef_LazerCutter'
	EffectGroup = 255 //None
	bCanObliterate = true
	bCanGib = true

	//Perk
	ModifierPerkList(0) = class'KFPerk_Survivalist'
}