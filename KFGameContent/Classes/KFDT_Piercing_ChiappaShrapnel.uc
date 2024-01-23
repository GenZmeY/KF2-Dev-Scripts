//=============================================================================
// KFDT_Piercing_ChiappaShrapnel
//=============================================================================
// Shrapnel damage type for the Chiappa Rhino pistol
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_ChiappaShrapnel extends KFDT_Piercing
    abstract
    hidedropdown;

defaultproperties
{
    KDamageImpulse=2000
    KDeathUpKick=-500
    KDeathVel=500

    GunHitPower=300

    WeaponDef=class'KFWeapDef_ChiappaRhino'

    ModifierPerkList(0)=class'KFPerk_Gunslinger'

    bAnyPerk = true
}
