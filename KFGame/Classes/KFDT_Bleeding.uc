//=============================================================================
// KFDT_Bleeding
//=============================================================================
// Damage caused by bleeding over time
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFDT_Bleeding extends KFDamageType
	abstract
	hidedropdown;

defaultproperties
{	
	DoT_Type=DOT_Bleeding
	DoT_Duration=15.0
	DoT_Interval=1.0
	DoT_DamageScale=1.0

	KDamageImpulse=0
}