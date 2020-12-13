//=============================================================================
// KFDT_Ballistic_Rifle
//=============================================================================
// Container class for rifle damage types
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 11/22/2013
//=============================================================================

class KFDT_Ballistic_Rifle extends KFDT_Ballistic
	abstract
	hidedropdown;

defaultproperties
{
	GoreDamageGroup=DGT_Rifle
	
	StumblePower=5
	GunHitPower=10
}
