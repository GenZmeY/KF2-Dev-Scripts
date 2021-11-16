//=============================================================================
// KFDT_Ballistic_HRG_Stunner_Alt
//=============================================================================
// Damage type class for the HRG Stunner alt fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Stunner_Alt extends KFDT_Ballistic_Submachinegun
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

    StumblePower=0 //200
    GunHitPower=0 //150
	
	//Perk
	ModifierPerkList(0)=class'KFPerk_SWAT'	
    WeaponDef=class'KFWeapDef_HRG_Stunner'
}
