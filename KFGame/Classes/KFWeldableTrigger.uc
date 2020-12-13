//=============================================================================
// KFWeldableTrigger
//=============================================================================
// Trigger that represents a weldable object (used with KFWeldableComponent)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFWeldableTrigger extends Trigger_PawnsOnly
	implements(KFInterface_Usable);

var transient KFWeldableComponent WeldableComponent;

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
		class'KFPlayerController'.static.UpdateInteractionMessages( Other );
	}
}

simulated function bool GetIsUsable(Pawn User)
{
	return WeldableComponent != none;
}

function int GetInteractionIndex(Pawn User)
{
	if (User.Weapon != none && User.Weapon.Class.Name == 'KFWeap_Welder')
	{
		return INDEX_NONE;
	}

	return IMT_UseDoorWelded;
}

defaultproperties
{
	Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
		CollisionRadius=+00200.000000
		CollisionHeight=+00100.000000
	End Object

	bProjTarget=false
	bStatic=false
	bNoDelete=false

	RemoteRole=ROLE_SimulatedProxy
}