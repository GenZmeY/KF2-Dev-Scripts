//=============================================================================
// KFDT_Ballistic_Shotgun
//=============================================================================
// Container class for shotgun damage types
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 11/22/2013
//=============================================================================

class KFDT_Ballistic_Shotgun extends KFDT_Ballistic
	abstract
	hidedropdown;





defaultproperties
{
	GoreDamageGroup=DGT_Shotgun
	ModifierPerkList(0)=class'KFPerk_Support'
	HeadDestructionDamageScale=7.0
	HeadDestructionImpulseForceScale=7.0
}
