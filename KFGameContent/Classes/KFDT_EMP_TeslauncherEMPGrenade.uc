//=============================================================================
// KFDT_EMP_TeslauncherEMPGrenade
//=============================================================================
// EMP damage type for EMP grenades in teslauncher weapon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// FFerrando @ Saber3D
//=============================================================================

class KFDT_EMP_TeslauncherEMPGrenade extends KFDT_EMP
	abstract
	hidedropdown;

defaultproperties
{

		// physics impact
	RadialDamageImpulse=1000
	KDeathUpKick=500
	KDeathVel=50

	MeleeHitPower=100
	EMPPower=100
	
	WeaponDef=class'KFWeapDef_Grenade_Berserker'
}
