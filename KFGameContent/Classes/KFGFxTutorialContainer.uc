//=============================================================================
// KFGFxTutorialContainer
//=============================================================================
// This is the UC representation for the GFxObject in the Tutorial Movie Player
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Zane Gholson 4/21/2016
//=============================================================================

class KFGFxTutorialContainer extends KFGFxObject_Menu
	dependson(KFTutorialSectionInfo);
var const string ControllerStringPrefix;
var localized string BackString;
var localized string NextString;
var localized string DoneString;
var localized string SkipString;
var KFTutorialSectionInfo TutorialArch;
var string KeyReplaceString;

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
}

function UpdateUsingGamePad(bool bValue)
{
	SetBool("bUsingGamepad", bValue);
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("back", 					BackString); 
	LocalizedObject.SetString("next", 					NextString); 
	LocalizedObject.SetString("done", 					DoneString); 
	LocalizedObject.SetString("skip", 					SkipString); 

	SetObject("localizedText", LocalizedObject);
}

function SetPopUpData(const out Array<STutorialSlide> TutorialArray)
{
	local GFxObject DataObject;
	local GFxObject DataProvider;
	local int i, j;
	local string DescriptionString;
	local KeyBind BoundKey;
	local array<string> KeyStrings;

	DataProvider = CreateArray();

	for (i = 0; i < TutorialArray.length; i++)
	{
		DescriptionString = Localize("KFTutorial", TutorialArray[i].DescriptionKey, "KFGameContent");

		if(KFPI != none)
		{
			// For each %x% relace with a variable length key name from KeyGBAs
			for (j = 0; j < TutorialArray[i].KeyGBAs.Length; ++j)
			{
				// If we have multiple GBA's iterate for each
				KFPI.GetKeyBindFromCommand(BoundKey, TutorialArray[i].KeyGBAs[j], false);
				KeyStrings[j] = KFPI.GetBindDisplayName(BoundKey);
				if(class'Actor'.static.Len(KeyStrings[j]) - class'Actor'.static.Len(ControllerStringPrefix) > 1)
				{
					//Image Replacing a string in AS3 cannot take a substring larger than 15 characters.  We remove the prefix for controllers
					//because these are common accross all controller inputs.  
					class'Actor'.static.ReplaceText(KeyStrings[j], ControllerStringPrefix, "" );
				}
			}

			ReplaceTextArray(DescriptionString, KeyReplaceString, KeyStrings);
		}
		
		DataObject = CreateObject("Object");

		DataObject.SetString("title", Localize("KFTutorial", TutorialArray[i].TitleKey, "KFGameContent") );
		DataObject.SetString("description", DescriptionString);
		if(TutorialArray[i].UIImage != none)
		{
			DataObject.SetString("image", "img://" $PathName(TutorialArray[i].UIImage));
		}

		DataProvider.SetElementObject(i, DataObject);
	}

	SetObject("data",DataProvider);	
}

/** Like replace text, but takes an array of "with" strings */
static function ReplaceTextArray(out string Text, string Replace, array<string> With)
{
	local int i, j;
	local string Input;

	Input = Text;
	Text = "";
	i = InStr(Input, Replace);
	while(i != -1)
	{
		Text = Text $ Left(Input, i) $ With[j];
		if ( j < (With.Length - 1) )
			j++;
		Input = Mid(Input, i + Len(Replace));
		i = InStr(Input, Replace);
	}
	Text = Text $ Input;
}

DefaultProperties
{
	KeyReplaceString="%x%"
	ControllerStringPrefix="XboxTypeS_"
}