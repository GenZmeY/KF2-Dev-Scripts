//=============================================================================
// KFDT_Bludgeon_CrovelHeavy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_Crovel extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=800
	KDeathVel=400

	KnockdownPower=0
	StunPower=0
	StumblePower=100
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_Crovel'
	ModifierPerkList(0)=class'KFPerk_Berserker'
}
