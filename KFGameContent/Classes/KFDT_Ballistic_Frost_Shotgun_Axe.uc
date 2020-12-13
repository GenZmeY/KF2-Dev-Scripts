//=============================================================================
// KFDT_Ballistic_Frost_Shotgun_Axe
//=============================================================================
// Ballistic damage with light impact energy, but stronger hit reactions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_Frost_Shotgun_Axe extends KFDT_Ballistic_Shotgun
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
	KDamageImpulse=2500 //2750
	KDeathUpKick=800
	KDeathVel=650

	// Afflictions
	StumblePower =20 //40 
	GunHitPower =20
	FreezePower =11 //17

	WeaponDef=class'KFWeapDef_Rifle_FrostShotgunAxe'

	ModifierPerkList(0)=class'KFPerk_Support'
	ModifierPerkList(1)=class'KFPerk_Berserker'

	EffectGroup=FXG_Freeze
}
