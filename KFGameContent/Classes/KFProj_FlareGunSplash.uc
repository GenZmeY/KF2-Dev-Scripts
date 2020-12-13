//=============================================================================
// KFProj_FlareGunSplash
//=============================================================================
// Projectile class for flare gun splash.  Handles a few overrides.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFProj_FlareGunSplash extends KFProj_MolotovSplash;

defaultproperties
{
    Begin Object Name=ExploTemplate0
        MyDamageType=class'KFDT_Fire_Ground_FlareGun'
    End Object

    AssociatedPerkClass=none
}