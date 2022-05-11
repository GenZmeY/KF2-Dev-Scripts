//=============================================================================
// KFDT_Poison_HRG_CranialPopper
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Poison_HRG_CranialPopper extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	//physics
	KDamageImpulse=0
    KDeathUpKick=0
    KDeathVel=0

    //Damage Over Time Components
	DoT_Type=DOT_None	//DOT_Toxic
	DoT_Duration=5.0
    DoT_Interval=1.0
    DoT_DamageScale=0.1
	bStackDoT=true

    WeaponDef=class'KFWeapDef_HRG_CranialPopper'
}