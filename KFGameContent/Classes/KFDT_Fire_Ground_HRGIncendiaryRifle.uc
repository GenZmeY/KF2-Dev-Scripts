//=============================================================================
// KFDT_Fire_Ground_HRGIncendiaryRifle
//=============================================================================
// Damage type class for the ground fire and the residual flames from the
// HRG Incendiary Rifle Grenade
// =============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_Ground_HRGIncendiaryRifle extends KFDT_Fire_Ground
	abstract;

defaultproperties
{
	WeaponDef=class'KFWeapDef_HRGIncendiaryRifle'

	DoT_Type = DOT_Fire
	DoT_Duration=3.0
	DoT_Interval=0.5
	DoT_DamageScale=0.5

	BurnPower=10
	
	// Ground fire does NOT damage the instigator
	bNoInstigatorDamage=true
}
