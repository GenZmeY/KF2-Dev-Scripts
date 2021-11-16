//=============================================================================
// KFDT_Ballistic_HRG_Stunner
//=============================================================================
// Damage type class for the HRG Stunner
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Stunner extends KFDT_Ballistic_Submachinegun
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

	KDamageImpulse=1500 //900
	KDeathUpKick=-1000 //-500
	KDeathVel=600 //350
	GibImpulseScale=1.0

    StumblePower=35
    KnockdownPower=25
    GunHitPower=25
	
	//Perk
	ModifierPerkList(0)=class'KFPerk_SWAT'	
    WeaponDef=class'KFWeapDef_HRG_Stunner'
}
