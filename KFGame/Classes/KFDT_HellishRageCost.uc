//=============================================================================
// KFDT_HellishRageCost
//=============================================================================
// Damage caused by hellish rage power up
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDT_HellishRageCost extends KFDamageType
	abstract;

defaultproperties
{
	bNonLethalDamage=true
	bArmorStops=false
	bIgnoreSelfInflictedScale=true

	KDamageImpulse=0
	CameraLensEffectTemplate=class'KFCameraLensEmit_BloodBase'
	EffectGroup=FXG_Bludgeon
	GoreDamageGroup=DGT_None
}