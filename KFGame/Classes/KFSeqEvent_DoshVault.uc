//=============================================================================
// KFSeqEvent_DoshVault
//=============================================================================
// Called when we need to start filling the dosh vault
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================

class KFSeqEvent_DoshVault extends SequenceEvent;

var int DoshTier;

enum EDoshVaultEvent
{
    DVE_Idle,
    DVE_IdleNoDosh,
    DVE_FillComplete,
    DVE_PauseFill,
    DVE_ResumeFill,
    DVE_Abort,
};

function NotifyIdle(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;

    ActiveIndices[0] = 0;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

function NotifyIdleNoDosh(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;
	
    ActiveIndices[0] = 1;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

function NotifyFillComplete(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;

    ActiveIndices[0] = 2;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

function NotifyAbort(Actor InInstigator, Actor InTrigger)
{
    local array<int> ActiveIndices;

    ActiveIndices[0] = 3;
    CheckActivate(InInstigator, InTrigger, false, ActiveIndices);
}

function SetDoshTier(int TierValue)
{
	DoshTier = TierValue;
}

defaultproperties
{
    ObjCategory = "Dosh Vault"
    ObjName = "Dosh Vault State Change"

    OutputLinks.Empty
    
    OutputLinks(DVE_Idle) = (LinkDesc = "Idle")
    OutputLinks(DVE_IdleNoDosh) = (LinkDesc = "IdleNoDosh")
    OutputLinks(DVE_FillComplete) = (LinkDesc = "FillComplete")
    OutputLinks(DVE_PauseFill) = (LinkDesc = "Pause Fill")
    OutputLinks(DVE_ResumeFill) = (LinkDesc = "Resume Fill")
    OutputLinks(DVE_Abort) = (LinkDesc = "Abort")
    

    VariableLinks.Empty
    VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Tier Value",bWriteable=true,PropertyName=DoshTier)

    MaxTriggerCount=0
    ReTriggerDelay=0.0
}