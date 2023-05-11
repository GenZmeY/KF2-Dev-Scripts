//=============================================================================
// KFDT_Explosive_Shotgun_S12
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_Shotgun_S12 extends KFDT_EMP
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000 //5000 //20000
	GibImpulseScale=0.15
	KDeathUpKick=1000
	KDeathVel=300

	// unreal physics momentum
	bExtraMomentumZ=True

	bCanGib=true

	KnockdownPower=100
	StunPower=25
	StumblePower=200
	EMPPower=100

	//Perk
	ModifierPerkList(0)=class'KFPerk_Support'
	
	WeaponDef=class'KFWeapDef_Shotgun_S12'

	bCanApplyRadialCalculationtoAffliction=false
}
