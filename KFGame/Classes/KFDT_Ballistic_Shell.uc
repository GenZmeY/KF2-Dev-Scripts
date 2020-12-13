//=============================================================================
// KFDT_Ballistic_Shell
//=============================================================================
// Impact from a fast moving shell that is not designed to penetrate
// (e.g. grenade launchers)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 11/22/2013
//=============================================================================

class KFDT_Ballistic_Shell extends KFDT_Ballistic
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
		case 'lthigh':
		case 'rthigh':
		case 'chest':
		case 'heart':
	 		return true;
	}
	return false;
}

defaultproperties
{
	GoreDamageGroup=DGT_Handgun
	EffectGroup=FXG_UnexplodedGrenade
}


