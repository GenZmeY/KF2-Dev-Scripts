//=============================================================================
// KFDT_Fire
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_FireTrap extends KFDT_Fire;

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
	bIsTrapDamage=true
}
