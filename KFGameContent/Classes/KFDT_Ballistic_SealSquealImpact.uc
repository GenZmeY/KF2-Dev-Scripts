//=============================================================================
// KFDT_Ballistic_SealSquealImpact
//=============================================================================
// Rocket impact damage type for the SealSqueal rocket launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_SealSquealImpact extends KFDT_Ballistic_Shell
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

	StumblePower=340
	GunHitPower=275

	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	WeaponDef=class'KFWeapDef_SealSqueal'
}
