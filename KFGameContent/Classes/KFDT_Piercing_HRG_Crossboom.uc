//=============================================================================
// KFDT_Piercing_HRG_Crossboom
//=============================================================================
// Damage type for HRG_Crossboom
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_HRG_Crossboom extends KFDT_Piercing
	abstract
	hidedropdown;

static simulated function bool CanDismemberHitZone(name InHitZoneName)
{
	return false;
}

static simulated function bool CanDismemberHitZoneWhileAlive(name InHitZoneName)
{
    return false;
}

defaultproperties
{
	KDamageImpulse=0
	KDeathUpKick=0
	KDeathVel=0

	StumblePower=250
	GunHitPower=100

	ModifierPerkList(0)=class'KFPerk_Demolitionist'
	WeaponDef=class'KFWeapDef_HRG_Crossboom'
}
