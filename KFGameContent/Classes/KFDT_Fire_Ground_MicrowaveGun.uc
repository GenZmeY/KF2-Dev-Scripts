//=============================================================================
// KFDT_Fire_Ground_MicrowaveGun
//=============================================================================
// A damage type for KFProj_GroundFire for the Flamethrower
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Fire_Ground_MicrowaveGun extends KFDT_Fire_Ground
	abstract;

defaultproperties
{
	WeaponDef=class'KFWeapDef_MicrowaveGun'

	BurnPower=7.5
}