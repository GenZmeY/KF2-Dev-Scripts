//=============================================================================
// KFDT_Shrink_ShrinkRayGun
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_Shrink_ShrinkRayGun extends KFDT_EMP
	abstract;

defaultproperties
{
	ShrinkPower=100 // Apply always
	MeleeHitPower=20
	EMPPower=0
	KDeathVel=300

	DoT_Type=DOT_Fire
	DoT_Duration=INDEX_NONE //5.0//1.0
	DoT_Interval=INDEX_NONE//0.5
	DoT_DamageScale=0.0//0.1
	bIgnoreSelfInflictedScale=false

	bCanObliterate=false
	bCanGib=false
	
	WeaponDef=class'KFWeapDef_ShrinkRayGun'
	ModifierPerkList(0)=class'KFPerk_Survivalist'
}