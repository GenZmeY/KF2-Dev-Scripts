//=============================================================================
// KFDT_Bludgeon_BlastBrawlers
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_BlastBrawlers extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2500 
	KDeathUpKick=500
	KDeathVel=400

	MeleeHitPower=100
	StunPower=0
	StumblePower=0

	WeaponDef=class'KFWeapDef_HRG_BlastBrawlers'
	ModifierPerkList(0)=class'KFPerk_Support'
}
