//=============================================================================
// KFSeqAction_DoshVault
//=============================================================================
// Called when we need to start filling the dosh vault
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================

class KFSeqAction_DoshVault extends SequenceAction;

event Activated()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

    iF(KFPC != none && KFPC.MyGFxManager != none && KFPC.MyGFxManager.DoshVaultMenu != none)
    {
    	KFPC.MyGFxManager.DoshVaultMenu.DelayedInit();
    }
}


defaultproperties
{
    ObjName = "Dosh Vault Action"
    ObjCategory = "Dosh Vault"

    InputLinks.Empty()
    InputLinks(0) = (LinkDesc = "Activate")

    VariableLinks.Empty
}