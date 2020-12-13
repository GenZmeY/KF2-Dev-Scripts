//=============================================================================
// KFDT_Ballistic_FNFal
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_FNFal extends KFDT_Ballistic_Rifle
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
	KDamageImpulse=2250
	KDeathUpKick=-400
	KDeathVel=250

    KnockdownPower=20
	StunPower=10 //40 //8
	StumblePower=18
	GunHitPower=50 //50
	MeleeHitPower=0

	WeaponDef=class'KFWeapDef_FNFal'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
	ModifierPerkList(1)=class'KFPerk_Commando'
}
