//=============================================================================
// KFSM_DisabledGrappleVictim
//=============================================================================
// Victim class for victims of disabling grappels.  Handles movement changes 
//      while stuck in the interaction w/ parent.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFSM_DisabledGrappleVictim extends KFSM_GrappleVictim;

defaultproperties
{
    // SpecialMove
    Handle = SM_DisabledGrappleVictim
    bDisableMovement = true
    bLockPawnRotation = true
    bDisableLook = true
    bDisableWeaponInteraction = true

    // KFSpecialMove
    bAllowThirdPersonWeaponAnims = false
}