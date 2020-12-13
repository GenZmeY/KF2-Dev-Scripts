//=============================================================================
// KFDT_EMP_ArcGeneratorSphereImpact
//=============================================================================
// EMP Damage for KFDT_EMP_ArcGenerator_Beam direct hit
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// fferrando@saber3d
//=============================================================================

class KFDT_EMP_ArcGeneratorSphereImpact extends KFDT_EMP
	abstract
	hidedropdown;

defaultproperties
{

    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	GunHitPower=150
	StumblePower=300 //120
	EMPPower=50 //50

	
	GoreDamageGroup=DGT_EMP
	EffectGroup=FXG_Electricity

	WeaponDef=class'KFWeapDef_HRG_EMP_ArcGenerator'

	ModifierPerkList(0)=class'KFPerk_Survivalist'

}