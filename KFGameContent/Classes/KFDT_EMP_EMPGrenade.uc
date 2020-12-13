//=============================================================================
// KFDT_EMP_EMPGrenade
//=============================================================================
// EMP damage type for EMP grenades
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_EMP_EMPGrenade extends KFDT_EMP
	abstract
	hidedropdown;

defaultproperties
{

		// physics impact
	RadialDamageImpulse=1000
	KDeathUpKick=500
	KDeathVel=50

	KnockdownPower=0
	MeleeHitPower=100
	EMPPower=100
	
	WeaponDef=class'KFWeapDef_Grenade_Berserker'
}
