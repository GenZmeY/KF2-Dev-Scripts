//=============================================================================
// KFDT_EMP_ArcGenerator_AltFiremodeZapDamage
//=============================================================================
// EMP Damage for KFDT_EMP_ArcGeneratorSphereImpact zap
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// fferrando@saber3d
//=============================================================================

class KFDT_EMP_ArcGenerator_AltFiremodeZapDamage extends KFDT_EMP
	abstract
	hidedropdown;

defaultproperties
{

    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100

	//StumblePower=15
	EMPPower=8 //5
	GunHitPower=5
	
	GoreDamageGroup=DGT_EMP
	EffectGroup=FXG_Electricity

	WeaponDef=class'KFWeapDef_HRG_EMP_ArcGenerator'

	ModifierPerkList(0)=class'KFPerk_Survivalist'

}