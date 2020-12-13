//=============================================================================
// KFDT_Ballistic_MosinNagant
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_MosinNagant extends KFDT_Ballistic_Rifle
	abstract
	hidedropdown;

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	if( super.CanDismemberHitZone( InHitZoneName ) )
	{
		return true;
	}

	switch ( InHitZoneName )
	{
		case 'lupperarm':
		case 'rupperarm':
	 		return true;
	}

	return false;
}

defaultproperties
{
	// Physics
	KDamageImpulse=2750
	KDeathUpKick=750
	KDeathVel=450

	// Afflictions
    KnockdownPower=30
	StunPower=40
	StumblePower=50
	GunHitPower=150

	WeaponDef=class'KFWeapDef_MosinNagant'

	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
}
