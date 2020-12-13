//=============================================================================
// KFDT_Ballistic_HRGTeslauncherGrenadeImpact
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRGTeslauncherGrenadeImpact extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2000
	KDeathUpKick=750
	KDeathVel=350

	KnockdownPower=125
	StumblePower=200
	GunHitPower=275

	WeaponDef=class'KFWeapDef_HRGTeslauncher'

	ModifierPerkList(0)=class'KFPerk_Berserker'
	//ModifierPerkList(1)=class'KFPerk_Survivalist'
}
