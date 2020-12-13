//=============================================================================
// KFDT_Ballistic_Handgun
//=============================================================================
// Container class for handgun damage types
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 11/22/2013
//=============================================================================

class KFDT_Ballistic_Handgun extends KFDT_Ballistic
	abstract
	hidedropdown;

defaultproperties
{
	GoreDamageGroup=DGT_Handgun

	StumblePower=4
	LegStumblePower=6
	GunHitPower=10
}
