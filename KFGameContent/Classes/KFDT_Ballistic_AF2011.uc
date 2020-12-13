//=============================================================================
// KFDT_Ballistic_AF2011
//=============================================================================
// Pistol damage type for the AF2011 pistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_AF2011 extends KFDT_Ballistic_Handgun
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
	KDamageImpulse=1500 //2500
	KDeathUpKick=-450   //-500
	KDeathVel=200       //250

	KnockdownPower=15 //20
	StumblePower=20 //30
	GunHitPower=100 //150

	WeaponDef=class'KFWeapDef_AF2011'

	ModifierPerkList(0)=class'KFPerk_Gunslinger'
}
