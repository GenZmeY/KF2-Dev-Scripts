//=============================================================================
// KFSM_PlayerAlpha_Rally
//=============================================================================
// Player controlled alpha clot rally special move
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerAlpha_Rally extends KFSM_AlphaRally;

protected function bool InternalCanDoSpecialMove()
{
    return !KFPOwner.IsHeadless() && KFPOwner.IsAliveAndWell() && super.InternalCanDoSpecialMove();
}

static function byte PackFlagsBase( KFPawn P )
{
    return class'KFSM_AlphaRally'.static.PackRallyFlags();
}

defaultproperties
{
    bDisableSteering=true
    bDisableMovement=true
    bRallySelf=true
}