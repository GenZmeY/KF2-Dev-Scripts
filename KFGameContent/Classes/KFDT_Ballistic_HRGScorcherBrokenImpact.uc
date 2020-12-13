//=============================================================================
// KFDT_Ballistic_HRGScorcherBrokenImpact
//=============================================================================
// Damage caused by heat and combustion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
// Roberto Moreno (Saber Interactive)
//=============================================================================
class KFDT_Ballistic_HRGScorcherBrokenImpact extends KFDT_Ballistic_Handgun
	abstract;

defaultproperties
{
	WeaponDef=class'KFWeapDef_HRGScorcher'
	ModifierPerkList(0)=class'KFPerk_Firebug'

	EffectGroup=FXG_Flare
	CameraLensEffectTemplate=class'KFCameraLensEmit_Fire'

	KDamageImpulse=1000
	KDeathUpKick=120
	KDeathVel=10

	BurnPower=20
	StumblePower=200 //150
	GunHitPower=150 //100
}