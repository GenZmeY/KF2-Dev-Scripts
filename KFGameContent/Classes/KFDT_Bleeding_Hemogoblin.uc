//=============================================================================
// KFDT_Bleeding_Hemogoblin
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bleeding_Hemogoblin extends KFDT_Bleeding
	abstract
	hidedropdown;

defaultproperties
{
	//physics
	KDamageImpulse=0
    KDeathUpKick=0
    KDeathVel=0

    //Afflictions
    BleedPower=150

    //Damage Over Time Components
	DoT_Type=DOT_Bleeding
	DoT_Duration=5.0 //10
    DoT_Interval=1.0 //1.0
    DoT_DamageScale=0.1 //0.5
	bStackDoT=true
}