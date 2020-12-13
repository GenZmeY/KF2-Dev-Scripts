//=============================================================================
// KFDT_Fire_Ground_CaulkNBurn
//=============================================================================
// A damage type for KFProj_GroundFire for the Caulk N Burn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Fire_Ground_CaulkNBurn extends KFDT_Fire_Ground
	abstract;

defaultproperties
{
	WeaponDef=class'KFWeapDef_CaulkBurn'

	BurnPower=10.5 //2.5
}
