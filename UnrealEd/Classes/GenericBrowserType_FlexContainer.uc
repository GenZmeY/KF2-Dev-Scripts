/**
 *
 * Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
 */

class GenericBrowserType_FlexContainer
	extends GenericBrowserType
	native;

cpptext
{
	virtual void Init();
	virtual UBOOL ShowObjectEditor(UObject *InObject);
}

defaultproperties
{
  	Description = "Flex Container"

}
