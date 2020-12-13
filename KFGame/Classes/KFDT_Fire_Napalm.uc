//=============================================================================
// KFDT_Fire_Napalm
//=============================================================================
// Damage caused by heat and combustion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_Napalm extends KFDT_Fire
	abstract;

`include(KFGameDialog.uci)

defaultproperties
{
	DoT_Type=DOT_Fire
	DoT_Duration=5.0
	DoT_Interval=1.0
	DoT_DamageScale=0.4
	bIgnoreSelfInflictedScale=true
}