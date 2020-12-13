//=============================================================================
// KFSeqAct_DrawLocalizedText
//=============================================================================
// Kismet node to draw localized texts in the HUD
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_DrawLocalizedText extends SequenceAction
	dependson(HUD)
	native;
	
var int SecondaryIDValue;

enum ELocalizedID
{
	LID_0,
	LID_1,	LID_2,	LID_3,	LID_4,	LID_5,	LID_6,	LID_7,	LID_8,	LID_9,	LID_10,
	LID_11,	LID_12,	LID_13,	LID_14,	LID_15,	LID_16,	LID_17,	LID_18,	LID_19,	LID_20,
	LID_21,	LID_22,	LID_23,	LID_24,	LID_25,	LID_26,	LID_27,	LID_28,	LID_29,	LID_30,
	LID_31,	LID_32,	LID_33,	LID_34,	LID_35,	LID_36,	LID_37,	LID_38,	LID_39,	LID_40,
	LID_41,	LID_42,	LID_43,	LID_44,	LID_45,	LID_46,	LID_47,	LID_48,	LID_49,	LID_MAX,
};

var(Message) ELocalizedID MessageLocalizedID;
var(Message) array<ELocalizedID> SecondaryMessageLocalizedIDList;

var(Message) bool bUseSecondaryMessage;
var(Message) string TextForReplace;

var() class<KFKismetMapLocalization> MapLocalizationClass;

var() float DisplayTimeSeconds;

var() vector2d	MessageFontScale;
var() vector2d	MessageOffset;
var() Color		MessageColor;

var bool bDisplayOnObject;

cpptext
{
	UBOOL UpdateOp(FLOAT deltaTime);
	virtual void Activated();
};

var HUD.KismetDrawTextInfo DrawTextInfo;

/**
* Return the version number for this class.  Child classes should increment this method by calling Super then adding
* a individual class version to the result.  When a class is first created, the number should be 0; each time one of the
* link arrays is modified (VariableLinks, OutputLinks, InputLinks, etc.), the number that is added to the result of
* Super.GetObjClassVersion() should be incremented by 1.
*
* @return	the version number for this specific class.
*/
static event int GetObjClassVersion()
{
	return Super.GetObjClassVersion() + 2;
}

event Initialize()
{
	DrawTextInfo.MessageText = GetLocalizationText();
	DrawTextInfo.MessageFont = GetFontText();
	DrawTextInfo.MessageFontScale = MessageFontScale;
	DrawTextInfo.MessageOffset = MessageOffset;
	DrawTextInfo.MessageColor = MessageColor;
}

simulated function string GetLocalizationText()
{
	Local string finalText;
	Local string secondaryText;

	finalText = MapLocalizationClass.static.GetLocalization(MessageLocalizedID);
	`log("bUseSecondaryMessage"@bUseSecondaryMessage);
	if(bUseSecondaryMessage)
	{
		`log("SecondaryIDValue"@SecondaryIDValue);
		secondaryText = MapLocalizationClass.static.GetLocalization(SecondaryMessageLocalizedIDList[SecondaryIDValue]);
        class'Actor'.static.ReplaceText(finalText, TextForReplace, secondaryText);
	}
	return finalText;
}

simulated function Font GetFontText()
{
	return MapLocalizationClass.static.GetFont();
}

defaultproperties
{
	ObjName="Draw Localized Text"
	ObjCategory="Killing Floor"

	DisplayTimeSeconds=-1

	MessageFontScale=(X=1,Y=1)
	MessageOffset=(X=0,Y=0)
	MessageColor=(R=255,G=255,B=255,A=255)

	InputLinks(0)=(LinkDesc="Show")
	InputLinks(1)=(LinkDesc="Hide")

	VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="String",MinVars=0,bHidden=TRUE)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Int',LinkDesc="SecondaryIDValue",MinVars=0,bHidden=TRUE,bWriteable=true,PropertyName=SecondaryIDValue)

	bLatentExecution=TRUE
	bAutoActivateOutputLinks=FALSE
}
