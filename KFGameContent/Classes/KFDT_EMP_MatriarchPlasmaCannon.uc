//=============================================================================
// KFDT_EMP_MatriarchPlasmaCannon
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDT_EMP_MatriarchPlasmaCannon extends KFDT_Fire
	abstract
	hidedropdown;

defaultproperties
{
    bArmorStops=true

	bShouldSpawnPersistentBlood=false

	DoT_Duration=0
	DoT_Interval=0
	DoT_DamageScale=0

	RadialDamageImpulse=2000
	KDeathUpKick=500
	KDeathVel=300

	BurnPower=11

	DeathMaterialEffectDuration=2.f
	DeathMaterialEffectParamName=scalar_burnt

	bAllowAIDoorDestruction=true
}