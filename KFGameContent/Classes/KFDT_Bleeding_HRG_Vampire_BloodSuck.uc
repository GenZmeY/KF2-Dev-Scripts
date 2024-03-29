//=============================================================================
// KFDT_Bleeding_HRG_Vampire_BloodSuck
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bleeding_HRG_Vampire_BloodSuck extends KFDT_Bleeding
	abstract;

defaultproperties
{
	//physics
	KDamageImpulse=0
	KDeathUpKick=350
	KDeathVel=350

    //Afflictions
    BleedPower=50 //50
	StumblePower=0 //20
	GunHitPower=5

    //Damage Over Time Components
	DoT_Type=DOT_Bleeding
	DoT_Duration=0.5 //5.0
    DoT_Interval=0.5 //1.0
    DoT_DamageScale=0.1
	bStackDoT=true

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_HRG_Vampire'
}