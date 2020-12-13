//=============================================================================
// KFExplosionActorPlaceable
//=============================================================================
// Explosion actor that can be placed in the map
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFExplosionActorPlaceable extends KFExplosionActor
	placeable;

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=ArrowComponent Name=Arrow
		ArrowColor=(R=0,G=255,B=128)
		ArrowSize=1.5
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		bTreatAsASprite=True
	End Object
	Components.Add(Arrow)

	bNoDelete=true
	RemoteRole=ROLE_SimulatedProxy
	bGameRelevant=true
}
