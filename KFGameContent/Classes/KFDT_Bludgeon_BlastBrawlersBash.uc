//=============================================================================
// KFDT_Bludgeon_BlastBrawlersBash
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_BlastBrawlersBash extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3500
	KDeathUpKick=800
	KDeathVel=575

	KnockdownPower=0
	StunPower=0
    StumblePower=200
    MeleeHitPower=100

    WeaponDef=class'KFWeapDef_HRG_BlastBrawlers'
	ModifierPerkList(0)=class'KFPerk_Support'
}
