//=============================================================================
// KFRepairableActorTrigger
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFRepairableActorTrigger extends Trigger_PawnsOnly
	placeable
	native
	implements(KFInterface_Usable);

var() KFRepairableActor RepairableActor;

cpptext
{
#if WITH_EDITOR
	virtual void CheckForErrors();	// Skip 'Trigger is not referenced' warning
#endif
}

simulated event PostBeginPlay()
{
	if (RepairableActor != none)
	{
		RepairableActor.RepairTrigger = self;
	}

	super.PostBeginPlay();
}

simulated event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	Super.Touch(Other, OtherComp, HitLocation, HitNormal);
	if (Role == ROLE_Authority)
	{
		class'KFPlayerController'.static.UpdateInteractionMessages(Other);
	}
}

simulated event UnTouch(Actor Other)
{
	super.UnTouch(Other);
	if (Role == ROLE_Authority)
	{
		class'KFPlayerController'.static.UpdateInteractionMessages(Other);
	}
}

function OnDestroyOrReset()
{
	local KFPawn_Human P;

	foreach TouchingActors(class'KFPawn_Human', P)
	{
		class'KFPlayerController'.static.UpdateInteractionMessages(P);
	}
}

simulated function bool GetIsUsable(Pawn User)
{
	if (RepairableActor != none)
	{
		return RepairableActor.WeldIntegrity < RepairableActor.MaxWeldIntegrity;
	}
	return false;
}

function int GetInteractionIndex(Pawn User)
{
	if (RepairableActor != none && RepairableActor.WeldIntegrity < RepairableActor.MaxWeldIntegrity)
	{
		if (User.Weapon != none && User.Weapon.Class.Name == 'KFWeap_Welder')
		{
			return INDEX_NONE;
		}
		return IMT_UseDoorWelded;
	}
	return IMT_UseDoor;
}

defaultproperties
{
	Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
		CollisionRadius=+00200.000000
		CollisionHeight=+00100.000000
	End Object

	bProjTarget=false
}
