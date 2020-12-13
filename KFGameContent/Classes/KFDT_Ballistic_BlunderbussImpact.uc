//=============================================================================
// KFDT_Ballistic_BlunderbussImpact
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive
//=============================================================================

class KFDT_Ballistic_BlunderbussImpact extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2000
	KDeathUpKick=750
	KDeathVel=1500

	StumblePower=400
	KnockdownPower=200
	GunHitPower=300

	WeaponDef=class'KFWeapDef_Blunderbuss'

	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}

