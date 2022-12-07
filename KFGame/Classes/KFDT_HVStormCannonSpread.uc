//=============================================================================
// KFDT_HVStormCannonSpread
//=============================================================================
// Damage caused by HV Storm Cannon Spread
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_HVStormCannonSpread extends KFDamageType
	abstract;

defaultproperties
{
    bCausedByWorld=false
	bArmorStops=false

    KnockdownPower=20
	StunPower=25
	StumblePower=85
	GunHitPower=80
	EMPPower=25

	WeaponDef=class'KFWeapDef_HVStormCannon'
}