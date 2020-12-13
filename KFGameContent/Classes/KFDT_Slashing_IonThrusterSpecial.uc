//=============================================================================
// KFDT_Slashing_IonThrusterSpecial
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_IonThrusterSpecial extends KFDT_Slashing_IonThruster
	abstract
	hidedropdown;

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	if( super.CanDismemberHitZone( InHitZoneName ) )
	{
		return true;
	}

	switch ( InHitZoneName )
	{
		case 'lupperarm':
		case 'rupperarm':
	 		return true;
	}

	return false;
}

defaultproperties
{
	// Physics
	KDamageImpulse=5000
	KDeathUpKick=2000
	KDeathVel=3750

	// Afflictions
	KnockdownPower=500
	StumblePower=500
	MeleeHitPower=500
	BurnPower=150
	BurnDamageType = class'KFDT_Fire_IonThrusterDoT'

	EffectGroup=FXG_Slashing_Ion
	GoreDamageGroup=DGT_Fire

	WeaponDef=class'KFWeapDef_IonThruster'

	ModifierPerkList(0)=class'KFPerk_Berserker'
}