//=============================================================================
// KFDT_Mine_Reconstructor_BileExplosionDoT
//=============================================================================
// Damage caused by burning from being hit by a Mine_Reconstructor bile ball
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
// fferrando@saber3d
//=============================================================================

class KFDT_Mine_Reconstructor_BileExplosionDoT extends KFDamageType
	abstract
	hidedropdown;


defaultproperties
{
	DoT_Type=DOT_Toxic
	DoT_Duration=4.0 //5.0 //1.0
	DoT_Interval=0.5
	DoT_DamageScale=0.1 //1.0

	MicrowavePower=15
	PoisonPower=60

	EffectGroup=FXG_Toxic
	
	bHasToSpawnMicrowaveFire=false;

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_Mine_Reconstructor'
}

