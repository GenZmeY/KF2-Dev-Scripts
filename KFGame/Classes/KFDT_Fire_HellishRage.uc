//=============================================================================
// KFDT_Fire_HellishRage
//=============================================================================
// Damage caused by hellish rage power up
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDT_Fire_HellishRage extends KFDT_Fire
	abstract;

defaultproperties
{
	DoT_Type=DOT_Fire
	DoT_Duration=3.0
	DoT_Interval=0.5
	DoT_DamageScale=1.0
	bIgnoreSelfInflictedScale=true

	KDamageImpulse=0
	EffectGroup=FXG_Fire
	GoreDamageGroup=DGT_Fire
	BurnPower=35
}