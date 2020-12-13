//=============================================================================
// KFDT_Slashing_IonThrusterHeavy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_IonThrusterHeavy extends KFDT_Slashing_IonThruster
	abstract;

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
	KDamageImpulse=1600
	KDeathUpKick=200
	KDeathVel=500

	// Afflictions
	StumblePower=100 
	MeleeHitPower=125
	BurnPower=50
	BurnDamageType=class'KFDT_Fire_IonThrusterDoT'

	EffectGroup=FXG_Slashing_Ion
	GoreDamageGroup=DGT_Fire

	WeaponDef=class'KFWeapDef_IonThruster'

	ModifierPerkList(0)=class'KFPerk_Berserker'

	OverrideImpactEffect=ParticleSystem'WEP_Ion_Sword_EMIT.FX_Ion_Sword_Impact'
}