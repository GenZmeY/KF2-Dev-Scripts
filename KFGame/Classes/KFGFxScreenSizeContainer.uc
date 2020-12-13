//=============================================================================
// KFGFxTutorialContainer
//=============================================================================
// This is the UC representation for the GFxObject in the Tutorial Movie Player
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Zane Gholson 2/24/2017
//=============================================================================

class KFGFxScreenSizeContainer extends KFGFxObject_Menu;

var localized string TitleString;
var localized string DescriptionString;
var localized string EnlargeString;
var localized string ShrinkString;

var KFPlayerInput KFPI;

function InitMenu( )
{
	KFPI = KFPlayerInput(GetPC().PlayerInput);
	LocalizeText();
	if(GetPC().WorldInfo.IsConsoleBuild())
	{
		UpdateUsingGamePad(true);
	}
	else if(KFPI != none)
	{
		UpdateUsingGamePad(KFPI.bUsingGamepad);
	}
	LocalizeText();
	HideButtonsThatWeDoNotWantForNow();
}

//doing this for now just in case it comes back
function HideButtonsThatWeDoNotWantForNow()
{
	local GFxObject cancelButton, cancelTextfield;

	cancelButton = GetObject("backButtonIcon");
	cancelTextfield = GetObject("cancelTextField");

	if(cancelButton != none)
	{
		cancelButton.SetVisible(false);
	}

	if(cancelTextfield != none)
	{
		cancelTextfield.SetVisible(false);
	}
}

function UpdateUsingGamePad(bool bValue)
{
	SetBool("bUsingGamepad", bValue);
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("title",			TitleString);
	LocalizedObject.SetString("description", 	DescriptionString);
	LocalizedObject.SetString("enlarge", 		EnlargeString);
	LocalizedObject.SetString("shrink", 		ShrinkString);
	LocalizedObject.SetString("confirm", 		class'KFCommon_LocalizedStrings'.default.ConfirmString);
	LocalizedObject.SetString("cancel", 		class'KFCommon_LocalizedStrings'.default.CancelString);

	SetObject("localizedText", LocalizedObject);
}

DefaultProperties
{
	
}