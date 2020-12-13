//=============================================================================
// KFDT_Ballistic_HK_UMP
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HK_UMP extends KFDT_Ballistic_Submachinegun
    abstract
    hidedropdown;

defaultproperties
{
    KDamageImpulse=900
    KDeathUpKick=-300
    KDeathVel=100

    StumblePower=16
    GunHitPower=16

    WeaponDef=class'KFGame.KFWeapDef_HK_UMP'
    ModifierPerkList(0)=class'KFPerk_SWAT'
}
