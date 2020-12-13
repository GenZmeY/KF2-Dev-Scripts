//=============================================================================
// KFDT_Bludgeon_PowerGlovesHeavy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_PowerGlovesHeavy extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3500 //1500
	KDeathUpKick=800
	KDeathVel=575 //400

	KnockdownPower=90//150
	StunPower=0
	StumblePower=150
	MeleeHitPower=100
    EMPPower=45 //49

	WeaponDef=class'KFWeapDef_PowerGloves'
	ModifierPerkList(0)=class'KFPerk_Berserker'

	OverrideImpactEffect=ParticleSystem'WEP_Static_Strikers_EMIT.FX_Static_Strikers_Impact'
}
