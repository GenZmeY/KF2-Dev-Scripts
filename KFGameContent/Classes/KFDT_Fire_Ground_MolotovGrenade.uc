//=============================================================================
// KFDT_Fire_Ground_MolotovGrenade
//=============================================================================
// Damage type class for molotov grenade ground fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
// Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFDT_Fire_Ground_MolotovGrenade extends KFDT_Fire_Ground
	abstract
	hidedropdown;

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

	WeaponDef=class'KFWeapDef_Grenade_Firebug'
}