/**
 *
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */


/** contains game-specific map data, attached to the WorldInfo */
class MapInfo extends Object
	native
	abstract
	editinlinenew;

`if(`__TW_)
/** The default lighting channel to use for dynamically spawned actors.
	NOTE - This is in the engine class because it is accessed by engine 
	code inside of UnShadowmap.cpp
 */
var bool bDefaultPawnsToOutdoor;	
`endif

// NVCHANGE_BEGIN: RLS - PhysX Triangle Collision
/** Enable automatic triangle collision. */
var(Flex)		bool						bUseFlexTriangleCollision;

cpptext
{
#if WITH_EDITOR
	virtual void CheckForErrors() 
	{
		if (bUseFlexTriangleCollision == FALSE)
			GWarn->MapCheck_Add( MCTYPE_NOTE, NULL, *FString( LocalizeUnrealEd( "MapCheck_FlexCollision" ) ), TEXT( "FlexTriangleCollision" ) );
	}
#endif
}

DefaultProperties
{
	bUseFlexTriangleCollision=TRUE
}
// NVCHANGE_END: RLS - PhysX Triangle Collision
