//=============================================================================
// KFProj_HuskGroundFire
//=============================================================================
// Ground fires made by the husks flamethrower
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Greg Felber
//=============================================================================

class KFProj_HuskGroundFire extends KFProj_GroundFire
	hidedropdown;

DefaultProperties
{
	// explosion
	Begin Object Name=ExploTemplate0
		Damage=6
		MyDamageType=class'KFDT_Fire_ZedGround'
	End Object

	DamageInterval=0.25f
}