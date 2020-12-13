//=============================================================================
// KFWeapAttach_PowerGloves
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_PowerGloves extends KFWeapAttach_DualBase;

/** Overrides to prevent weapon animation */
simulated function PlayWeaponFireAnim();
simulated function PlayWeaponMeshAnim(name AnimName, AnimNodeSlot SyncNode, bool bLoop);

defaultproperties
{
}
