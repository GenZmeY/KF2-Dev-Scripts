//=============================================================================
// KFDT_Ballistic_CenterfireMB464
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_CenterfireMB464 extends KFDT_Ballistic_Rifle
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

    KnockdownPower=20
	StunPower=25 //25
	StumblePower=85
	GunHitPower=80 //100
	MeleeHitPower=0

	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
    ModifierPerkList(1)=class'KFPerk_Gunslinger'
	WeaponDef=class'KFWeapDef_CenterfireMB464'
}
