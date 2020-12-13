//=============================================================================
// KFDT_Fire
//=============================================================================
// Damage caused by heat and combustion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire extends KFDamageType
	abstract;

`include(KFGameDialog.uci)

/** Returns ID of dialog event for killer to speak after killing a zed using this damage type */
static function int GetKillerDialogID()
{
	return `KILL_Fire;
}

/** Returns ID of dialog event for damager to speak after damaging a zed using this damage type */
static function int GetDamagerDialogID()
{
	return `DAMZ_Fire;
}

/** Returns ID of dialog event for damagee to speak after getting damaged by a zed using this damage type */
static function int GetDamageeDialogID()
{
	return `DAMP_Fire;
}

defaultproperties
{
	DoT_Type=DOT_Fire
	DoT_Duration=5.0
	DoT_Interval=1.0
	DoT_DamageScale=1.5
	bIgnoreSelfInflictedScale=true

	KDamageImpulse=0
	EffectGroup=FXG_Fire
	GoreDamageGroup=DGT_Fire
	BurnPower=2.5

	CameraLensEffectTemplate=class'KFCameraLensEmit_Fire'

	ModifierPerkList(0)=class'KFPerk_Firebug'
}

