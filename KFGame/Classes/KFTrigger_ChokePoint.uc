//=============================================================================
// KFChokePointTrigger
//=============================================================================
// A custom trigger used to mark bottleneck locations in the map for special
// special AI considerations.  KFDoorTriggers are also Chokepoints.
// DOES NOT currently support overlapping touch!
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFTrigger_ChokePoint extends Trigger_PawnsOnly
	placeable
	native(AI);

cpptext
{
#if WITH_EDITOR
	virtual void CheckForErrors();	// Skip 'Trigger is not referenced' warning
#endif
}

/** If true, larger enemies will have reduced collision while going through this choke point */
var() bool bReduceCollisionRadius;
/** If true, collision between all zeds will be reduced while attempting to go through this choke point */
var() bool bReduceTeammateCollision;

/** The reduced size of a zed going through a chokepiont */
var const float MaxCollisionRadius;

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local KFPawn_Monster KFPM;
	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	if( bReduceCollisionRadius )
	{
		KFPM = KFPawn_Monster(Other);
		if( KFPM != none )
		{
			KFPM.CurrentChokePointTrigger = self;
			if( KFPM.CylinderComponent != none && KFPM.CylinderComponent.CollisionRadius > MaxCollisionRadius )
			{
				KFPM.ChokePointTimer();
			}
		}
	}
}

simulated event UnTouch(Actor Other)
{
	local KFPawn_Monster KFPM;
	super.UnTouch( Other );

	KFPM = KFPawn_Monster(Other);
	if( KFPM != none )
	{
		KFPM.CurrentChokePointTrigger = none;
	}
}

simulated function bool CanRestoreChokeCollision(KFPawn_Monster KFPM)
{
	local KFPawn_Human TouchingHuman;

	// If a human is in this volume, restore our collision size
	ForEach TouchingActors(class'KFPawn_Human',TouchingHuman)
	{
		return true;
	}
	return false;
}

simulated function bool CanReduceTeammateCollision()
{
    return bReduceTeammateCollision;
}

simulated function bool PartialReduceTeammateCollision()
{
    return false;
}

DefaultProperties
{
	Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
		CollisionRadius=+00200.000000
		CollisionHeight=+00100.000000
	End Object

	bProjTarget=false
	bStatic=true

	bReduceCollisionRadius=true
	bReduceTeammateCollision=true
	MaxCollisionRadius=36
}
