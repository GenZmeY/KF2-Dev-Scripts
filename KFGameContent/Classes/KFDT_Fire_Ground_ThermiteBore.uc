//=============================================================================
// KFDT_Fire_Ground_ThermiteBore
//=============================================================================
// Damage type class for the thermite bore ground fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_Ground_ThermiteBore extends KFDT_Fire_Ground
	abstract;

defaultproperties
{
	bShouldSpawnPersistentBlood=false

	// physics impact
	RadialDamageImpulse=0
	KDeathUpKick=0
	KDeathVel=0

	KnockdownPower=0
	StumblePower=100
	BurnPower=10

	// DOT
	DoT_Duration=3.0 //5.0
	DoT_Interval=0.5
	DoT_DamageScale=0.5 //0.2
	bIgnoreSelfInflictedScale=false

	WeaponDef=class'KFWeapDef_ThermiteBore'
}