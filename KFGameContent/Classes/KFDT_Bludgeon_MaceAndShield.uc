//=============================================================================
// KFDT_Bludgeon_MaceAndShield
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Bludgeon_MaceAndShield extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	EffectGroup=FXG_MetalMace
	
	//Light Attack
	KDamageImpulse=4000 //1500  //3000 //6000
	KDeathUpKick=700 //0 //1000
	KDeathVel=575 //375
	
	KnockdownPower=50
	StunPower=0
	StumblePower=300
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_MaceAndShield'

	ModifierPerkList(0)=class'KFPerk_Berserker'
}