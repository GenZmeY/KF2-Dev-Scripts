//=============================================================================
// KFDT_Ballistic_MKB42
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_MKB42 extends KFDT_Ballistic_AssaultRifle
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
	KDamageImpulse=1000
	KDeathUpKick=-200
	KDeathVel=135
	
	StumblePower=25
	GunHitPower=0

	WeaponDef=class'KFWeapDef_MKB42'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Commando'
}
