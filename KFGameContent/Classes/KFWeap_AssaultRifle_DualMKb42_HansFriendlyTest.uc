//=============================================================================
// KFWeap_AssaultRifle_DualMKb42_HansFriendlyTest
//=============================================================================
// Dual MKb42 assault rifles for the Hans Boss character - pumped up for fighting zeds to test
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_AssaultRifle_DualMKb42_HansFriendlyTest extends KFWeap_AssaultRifle_DualMKb42_Hans;

defaultproperties
{
	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	FireInterval(DEFAULT_FIREMODE)=+0.05 // 1200 RPM
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HansAK12'
	Spread(DEFAULT_FIREMODE)=0.025
	InstantHitDamage(DEFAULT_FIREMODE)=35.0
	FireOffset=(X=32,Y=4.0,Z=-5)
}


