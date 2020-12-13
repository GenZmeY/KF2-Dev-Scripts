//=============================================================================
// KFDT_Ballistic_AA12Shotgun
//=============================================================================
// Damage type class for the AA12 shotgun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Ballistic_AA12Shotgun extends KFDT_Ballistic_Shotgun
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
		case 'chest':
		case 'heart':
	 		return true;
	}

	return false;
}

defaultproperties
{
	BloodSpread=0.4
	BloodScale=0.6


	KDamageImpulse=900
	KDeathUpKick=-500
	KDeathVel=350
	//KDamageImpulse=350 
	//KDeathUpKick=120
	//KDeathVel=10

    StumblePower=5
	GunHitPower=0

	WeaponDef=class'KFWeapDef_AA12'
}
