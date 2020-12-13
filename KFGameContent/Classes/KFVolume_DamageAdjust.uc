//=============================================================================
// KFVolume_DamageAdjust
//=============================================================================
// Volume that can be used to modify the final value coming out of
//      KFPawn.AdjustDamage.  Default is 1.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFVolume_DamageAdjust extends Volume
    placeable;

/** Damage scalar for all sources to actors touching this volume */
var() float DamageScale;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    local KFPawn TouchPawn;
    
    TouchPawn = KFPawn(Other);
    if (TouchPawn != none)
    {
        TouchPawn.VolumeDamageScale = DamageScale;
    }
}

event Untouch(Actor Other)
{
    local KFPawn UntouchPawn;

    UntouchPawn = KFPawn(Other);
    if (UntouchPawn != none)
    {
        UntouchPawn.VolumeDamageScale = UntouchPawn.default.VolumeDamageScale;
    }
}

defaultproperties
{
    bCollideActors=true
    SupportedEvents.Empty
    SupportedEvents(0)=class'SeqEvent_Touch'

    DamageScale=1.0
}