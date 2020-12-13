//=============================================================================
// KFDT_Bludgeon_ChainBat
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_ChainBat extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=800
	KDeathVel=400

	KnockdownPower=0
	StunPower=0
	StumblePower=30
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_ChainBat'
	ModifierPerkList(0)=class'KFPerk_Berserker'

	EffectGroup=FXG_Bludgeon_Chains
}
