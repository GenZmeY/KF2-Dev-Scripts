//=============================================================================
// KFTrigger_BloatKingGorge
//=============================================================================
// Spawned during gorge attack, triggers pawn to start checking on attached
//      pawns for whether or not they're are pullable.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFTrigger_BloatKingGorge extends Trigger;

var KFPawn_ZedBloatKing Bloat;

event BaseChange()
{
    Super.BaseChange();

    Bloat = KFPawn_ZedBloatKing(Base);
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
    super.Touch(Other, OtherComp, HitLocation, HitNormal);
}

defaultproperties
{
    bStatic=false
    bNoDelete=false
	bProjTarget=false

    Begin Object Name=CollisionCylinder
        CollisionRadius=700
        CollisionHeight=120.0
    End Object
}