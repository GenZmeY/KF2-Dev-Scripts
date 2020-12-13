//=============================================================================
// KFWeapAttach_MaceAndShield
//=============================================================================
// Custom 3rd person weapon attachment for the Mace and Shield
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_MaceAndShield extends KFWeapAttach_DualBase;

/** Overrides to prevent weapon animation */
simulated function PlayWeaponFireAnim();
simulated function PlayWeaponMeshAnim( name AnimName, AnimNodeSlot SyncNode, bool bLoop );

defaultproperties
{
	//defaults
}