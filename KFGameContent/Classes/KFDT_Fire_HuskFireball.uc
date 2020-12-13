//=============================================================================
// KFDT_Fire_HuskFireball
//=============================================================================
// A damage type for KFProj_Husk_Fireball
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 11/20/2014
//=============================================================================

class KFDT_Fire_HuskFireball extends KFDT_Fire
	abstract
	hidedropdown;

defaultproperties
{
	// unreal physics momentum
	bExtraMomentumZ=True

	DoT_Duration=5.0
	DoT_Interval=1.0
	DoT_DamageScale=0.2f
	bShouldSpawnPersistentBlood=false

	// physics impact
	KDamageImpulse=250
	RadialDamageImpulse=1500.f
	KDeathUpKick=250.f
	KDeathVel=350

	KnockdownPower=0
	StumblePower=59

	DeathMaterialEffectDuration=2.f
	DeathMaterialEffectParamName=scalar_burnt

	bAllowAIDoorDestruction=true
}
