//=============================================================================
// KFProj_Mac10Splash
//=============================================================================
// Projectile class for trench gun splash.  Handles a few overrides.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFProj_Mac10Splash extends KFProj_FlareGunSplash;

defaultproperties
{
    Begin Object Name=ExploTemplate0
        MyDamageType=class'KFDT_Fire_Mac10DoT'
    End Object

    AssociatedPerkClass=class'KFPerk_Firebug'
}