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
	StunPower=50
	StumblePower=200
	GunHitPower=150
	MeleeHitPower=100
	EMPPower=50

	WeaponDef=class'KFWeapDef_HVStormCannon'
}