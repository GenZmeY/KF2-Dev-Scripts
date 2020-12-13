//=============================================================================
// KFTrigger_MinigameCash
//=============================================================================
// Trigger variant used to start triggerable minigames specifically with cash.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFTrigger_MinigameCash extends KFTrigger_MinigameButton
    native;

cpptext
{
    virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags);
};

simulated function bool GetIsUsable(Pawn User)
{
    return false;
}

/** HUD */
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local KFDroppedPickup_Cash Cash;
    super.Touch(Other, OtherComp, HitLocation, HitNormal);
    
    //Since this is only usable if cash hits it, we assume things are fine if
    //      the base implementation treats the game as valid for activation.
    Cash = KFDroppedPickup_Cash(Other);
    if (Cash != none && ReadyToActivate())
    {
        UsedBy(Cash.Instigator);
        Cash.Destroy();
    }
}
