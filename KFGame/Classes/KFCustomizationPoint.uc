//=============================================================================
// KFCustomizationPoint
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 1/21/2014
//=============================================================================

class KFCustomizationPoint extends NavigationPoint
	placeable;

event PreBeginPlay()
{
	super.PreBeginPlay();

	if ( KFGameInfo( WorldInfo.Game ) != none )
	{
		KFGameInfo( WorldInfo.Game ).CustomizationPointsInitialized();
	}
}

defaultproperties
{
	Begin Object NAME=CollisionCylinder
		CollisionRadius=+0036.000000
		CollisionHeight=+00086.000000
	End Object

	Begin Object NAME=Sprite LegacyClassName=PlayerStart_PlayerStartSprite_Class
		Sprite=Texture2D'EditorResources.S_Pawn'
		SpriteCategoryName="PlayerStart"
	End Object
	bAllowPathConnections=false
	bNoAutoConnect=true
}
