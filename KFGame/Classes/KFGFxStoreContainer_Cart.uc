//=============================================================================
// KFGFxStoreContainer_Cart
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 9/18/2015
//=============================================================================

class KFGFxStoreContainer_Cart extends KFGFxObject_Container;

var localized string CartString;
var localized string TotalString;
var localized string CheckOutString;


function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	
	LocalizeText();
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("cancel", 					Class'KFCommon_LocalizedStrings'.default.CancelString); 
	LocalizedObject.SetString("cart",	 					CartString); 
	LocalizedObject.SetString("total",	 					TotalString); 
	LocalizedObject.SetString("checkOut", 					CheckOutString); 

	SetObject("localizedText", LocalizedObject);
}