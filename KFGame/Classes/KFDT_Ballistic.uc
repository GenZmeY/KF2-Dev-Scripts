//=============================================================================
// KFDT_Ballistic
//=============================================================================
// Various bullets/projectiles of different calibers or mm
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic extends KFDamageType
	abstract;

`include(KFGameDialog.uci)

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	switch ( InHitZoneName )
	{
	 	case 'lhand':
		case 'rhand':
		case 'lfoot':
		case 'rfoot':
		case 'lforearm':
		case 'rforearm':
		case 'lcalf':
		case 'rcalf':
		case 'lthigh':
		case 'rthigh':
	 		return true;
	}

	return false;
}

/** Returns ID of dialog event for killer to speak after killing a zed using this damage type */
static function int GetKillerDialogID()
{
	return `KILL_Ballistic;
}

/** Returns ID of dialog event for damager to speak after damaging a zed using this damage type */
static function int GetDamageeDialogID()
{
	return `DAMP_Ballistic;
}

defaultproperties
{
	bShouldSpawnBloodSplat=true
	bShouldSpawnPersistentBlood=true
	BodyWoundDecalMaterials[0]=MaterialInstanceConstant'FX_Gore_MAT.FX_CH_Wound_01_Mic'

	KDamageImpulse=300

	GoreDamageGroup=DGT_Handgun
	EffectGroup=FXG_Ballistic
}
