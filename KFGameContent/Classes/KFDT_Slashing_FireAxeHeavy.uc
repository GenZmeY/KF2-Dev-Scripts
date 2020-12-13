//=============================================================================
// KFDT_Slashing_FireAxeHeavy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_FireAxeHeavy extends KFDT_Slashing_FireAxe
	abstract
	hidedropdown;

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone(name InHitZoneName)
{
	if (super.CanDismemberHitZone(InHitZoneName))
	{
		return true;
	}

	switch (InHitZoneName)
	{
	case 'lupperarm':
	case 'rupperarm':
		return true;
	}

	return false;
}

defaultproperties
{
	KDamageImpulse=300
	KDeathUpKick=400

	StumblePower=75
	StunPower=75
	MeleeHitPower=100

	WeaponDef=class'KFWeapDef_FireAxe'

	ModifierPerkList(0)=class'KFPerk_Berserker'
}