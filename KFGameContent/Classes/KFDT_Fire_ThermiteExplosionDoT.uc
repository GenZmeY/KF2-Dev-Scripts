//=============================================================================
// KFDT_Fire_ThermiteExplosionDoT
//=============================================================================
// Damage caused by burning from being hit by a thermite bore explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_ThermiteExplosionDoT extends KFDT_Fire
	abstract
	hidedropdown;

static function int GetKillerDialogID()
{
	return 86;//KILL_Fire
}

static function int GetDamagerDialogID()
{
	return 102;//DAMZ_Fire
}

static function int GetDamageeDialogID()
{
	return 116;//DAMP_Fire
}

defaultproperties
{
	WeaponDef=class'KFWeapDef_ThermiteBore'

	DoT_Type=DOT_Fire
	DoT_Duration=3.0
	DoT_Interval=0.5
	DoT_DamageScale=0.2

	BurnPower=10

	// Explosion DOT does not damage the instigator
	bNoInstigatorDamage=true
}