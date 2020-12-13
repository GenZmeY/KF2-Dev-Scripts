//=============================================================================
// KFMGVolume_DoshToss
//=============================================================================
// Volume to sit inside the dosh game bounds. On touch w/ an appropriate 
//      dropped pickup, the pickup will be flagged to run the rigid body sim on
//      client only.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMGVolume_DoshToss extends Volume
    placeable;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);

    if (Role == ROLE_Authority && KFDroppedPickup(Other) != none)
    {
        KFDroppedPickup(Other).DisableAuthorityRBSim();
    }
}