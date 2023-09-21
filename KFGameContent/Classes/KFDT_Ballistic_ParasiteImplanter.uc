//=============================================================================
// KFDT_Ballistic_ParasiteImplanter
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_ParasiteImplanter extends KFDT_Ballistic_Rifle
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
	KDamageImpulse=2000
	KDeathUpKick=400
	KDeathVel=250

    KnockdownPower=25
	//StunPower=20 //25
	StumblePower=80
	GunHitPower=160
	//MeleeHitPower=0

	WeaponDef=class'KFWeapDef_ParasiteImplanter'
	
	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	ModifierPerkList(1)=class'KFPerk_Sharpshooter'
}
