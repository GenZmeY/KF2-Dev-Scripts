//=============================================================================
// KFDT_Bludgeon_MaceAndShield_MaceHeavy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Bludgeon_MaceAndShield_MaceHeavy extends KFDT_Bludgeon_MaceAndShield
	abstract
	hidedropdown;

defaultproperties
{
	//Heavy Mace Attack
	KDamageImpulse=3500 //1500 //3000 //7000
	KDeathUpKick=700 //0 //1500
	KDeathVel=575 //375
	
	KnockdownPower=100
	StunPower=0
	StumblePower=400 //150
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_MaceAndShield'

	ModifierPerkList(0)=class'KFPerk_Berserker'
}