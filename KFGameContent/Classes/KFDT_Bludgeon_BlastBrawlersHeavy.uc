//=============================================================================
// KFDT_Bludgeon_BlastBrawlersHeavy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_BlastBrawlersHeavy extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3500
	KDeathUpKick=800
	KDeathVel=575

	KnockdownPower=75
	StunPower=0
	StumblePower=150
	MeleeHitPower=150
    EMPPower=0

	WeaponDef=class'KFWeapDef_HRG_BlastBrawlers'
	ModifierPerkList(0)=class'KFPerk_Support'

	//OverrideImpactEffect=ParticleSystem'WEP_HRG_BlastBrawlers_EMIT.FX_Static_Strikers_Impact'
}
