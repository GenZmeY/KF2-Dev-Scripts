//=============================================================================
// KFDT_EMP_ArcGenerator_Beam
//=============================================================================
// Damage caused by the HRG_ArcGenerator gun primary fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Fernando Ferrando @ saber3d
//=============================================================================

class KFDT_EMP_ArcGenerator_Beam extends KFDT_EMP
	abstract;

defaultproperties
{
	WeaponDef=class'KFWeapDef_HRG_EMP_ArcGenerator'

	// physics impact
	RadialDamageImpulse=750
	KDeathUpKick=750
	KDeathVel=349
    KDamageImpulse=2000

	StumblePower=30
	EMPPower=8 //8//12
	GunHitPower=5

	GoreDamageGroup=DGT_EMP
	EffectGroup=FXG_Electricity

	bCanObliterate=false
	bCanGib=false
	ModifierPerkList(0)=class'KFPerk_Survivalist'
}

