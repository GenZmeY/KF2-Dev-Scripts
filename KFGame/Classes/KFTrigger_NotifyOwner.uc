//=============================================================================
// KFTrigger_NotifyOwner
//=============================================================================
// Trigger that passes Touch and UnTouch notifications to its Owner
// (if its Owner is a KFInterface_TriggerOwner)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFTrigger_NotifyOwner extends Trigger_PawnsOnly;

event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local KFInterface_TriggerOwner KFOwner;

	super.Touch(Other, OtherComp, HitLocation, HitNormal);

	KFOwner = KFInterface_TriggerOwner(Owner);
	if (KFOwner != none)
	{
		KFOwner.NotifyTriggerTouch(self, Other, OtherComp, HitLocation, HitNormal);
	}
}

event UnTouch(Actor Other)
{
	local KFInterface_TriggerOwner KFOwner;

	super.UnTouch(Other);

	KFOwner = KFInterface_TriggerOwner(Owner);
	if (KFOwner != none)
	{
		KFOwner.NotifyTriggerUnTouch(self, Other);
	}
}

defaultproperties
{
	Begin Object NAME=CollisionCylinder
		CollisionRadius=+0100.000000
		CollisionHeight=+0050.000000
	End Object

	bProjTarget=false
	bStatic=false
	bNoDelete=false

	RemoteRole=ROLE_SimulatedProxy
}