/*=============================================================================
	FlexForceFieldActor.uc: Flex force field actor integration.
	Copyright 2008-2011 NVIDIA Corporation.
=============================================================================*/

class FlexForceFieldActor extends Actor
	native(Physics)
	placeable
	dependson(FlexForceFieldComponent);

var() FlexForceFieldComponent ForceFieldComponent;

/** Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle inAction)
{
	if (inAction.InputLinks[0].bHasImpulse)
	{
		ForceFieldComponent.setEnabled(TRUE);
	}
	else if (inAction.InputLinks[1].bHasImpulse)
	{
		ForceFieldComponent.setEnabled(FALSE);
	}
	else if (inAction.InputLinks[2].bHasImpulse)
	{
		ForceFieldComponent.setEnabled(!ForceFieldComponent.bEnabled);
	}
}

defaultproperties
{
	TickGroup=TG_PreAsyncWork

	Begin Object Class=FlexForceFieldComponent Name=NewFlexForceFieldComponent
	End Object
	ForceFieldComponent = NewFlexForceFieldComponent
	Components.Add(NewFlexForceFieldComponent)

	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_RadForce'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	bEdShouldSnap=True
	bStatic=false
	bNoDelete=false
}
