//=============================================================================
// KFDT_Ballistic_Rem1858
//=============================================================================
// Remington 1858 damage type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Ballistic_Rem1858 extends KFDT_Ballistic_Handgun
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=2500
	KDeathUpKick=-500
	KDeathVel=200

	KnockdownPower=15
	StumblePower=50
	GunHitPower=150

	WeaponDef=class'KFWeapDef_Remington1858'

	ModifierPerkList(0)=class'KFPerk_Gunslinger'
	ModifierPerkList(1)=class'KFPerk_Sharpshooter'
}
