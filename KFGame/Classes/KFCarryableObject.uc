//=============================================================================
// KFCarryableObject
//=============================================================================
// A carried object that forces the player to equip it and prevents the player
// from switching to a different inventory item, though it can be dropped.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFCarryableObject extends KFWeap_MeleeBase
	abstract;

reliable client function ClientWeaponSet(bool bOptionalSet, optional bool bDoNotActivate)
{
	Super.ClientWeaponSet(false);
}

simulated function float GetWeaponRating()
{
	return 1000;
}

defaultproperties
{
	bHasIronSights=false
	AssociatedPerkClasses(0)=none
	WeaponDryFireSnd(DEFAULT_FIREMODE)=none
}