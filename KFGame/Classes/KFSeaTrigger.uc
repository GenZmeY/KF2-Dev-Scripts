//=============================================================================
// KFSeaTrigger
//=============================================================================
// Simple trigger used for sea to bypass kismet
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//
//=============================================================================
class KFSeaTrigger extends Trigger_PawnsOnly
	placeable
	native;

// This class is totally dummy, it is used to place the trigger on the Scene
// Then on KFPlayerController we detect this exists and do the logic for Zeds falling to the sea

cpptext
{
#if WITH_EDITOR
	virtual void CheckForErrors();	// Skip 'Trigger is not referenced' warning
#endif
}

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
}

event UnTouch(Actor Other)
{
}

DefaultProperties
{
	Begin Object NAME=CollisionCylinder
		CollisionRadius=+00200.000000
		CollisionHeight=+00100.000000
	End Object

	bProjTarget=false
	bStatic=true
}