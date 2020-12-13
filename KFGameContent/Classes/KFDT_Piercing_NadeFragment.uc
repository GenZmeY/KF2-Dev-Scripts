//=============================================================================
// KFDT_Piercing_NadeFragment
//=============================================================================
// Piercing grenade fragment damage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Piercing_NadeFragment extends KFDT_Piercing
	abstract
	hidedropdown;

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

defaultproperties
{
	bShouldSpawnBloodSplat=true
	bShouldSpawnPersistentBlood=true
	BodyWoundDecalMaterials[0]=MaterialInstanceConstant'FX_Gore_MAT.FX_CH_Wound_01_Mic'

	// It's like a bullet, but we use piercing so that it hurts the fleshpound more
    GoreDamageGroup=DGT_Handgun
	EffectGroup=FXG_Ballistic

	BloodSpread=0.4
	BloodScale=0.6

	KDamageImpulse=400
	KDeathUpKick=250

	StumblePower=1000
	GunHitPower=0
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_Grenade_Support'

	ModifierPerkList(0)=class'KFPerk_Support'
}
