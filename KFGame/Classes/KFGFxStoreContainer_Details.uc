//=============================================================================
// KFGFxStoreContainer_Details
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 9/18/2015
//=============================================================================

class KFGFxStoreContainer_Details extends KFGFxObject_Container;

var localized string AddToCartString;
var localized string PreviewString;
var localized string LookUpOnMarketString;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	
	LocalizeText();
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("cancel", 					Class'KFCommon_LocalizedStrings'.default.BackString); 
	LocalizedObject.SetString("preview", 					PreviewString); 
	LocalizedObject.SetString("addToCart", 					AddToCartString); 
	 		
	SetObject("localizedText", LocalizedObject);
}