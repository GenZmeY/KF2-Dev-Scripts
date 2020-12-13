//=============================================================================
// KFSeqAct_DrawCountText
//=============================================================================
// Kismet node to draw texts in the counter container of the HUD
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_DrawCountText extends SequenceAction
	dependson(HUD)
	native;
	
var(Message) string Message;

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
	DrawTextInfo.MessageText = Message;
	DrawTextInfo.MessageFont = GetFontText();
	DrawTextInfo.MessageFontScale = MessageFontScale;
	DrawTextInfo.MessageOffset = MessageOffset;
	DrawTextInfo.MessageColor = MessageColor;
}

simulated function Font GetFontText()
{
	return MapLocalizationClass.static.GetFont();
}

defaultproperties
{
	ObjName="Draw Count Text"
	ObjCategory="Killing Floor"

	DisplayTimeSeconds=-1

	MessageFontScale=(X=1,Y=1)
	MessageOffset=(X=0,Y=0)
	MessageColor=(R=255,G=255,B=255,A=255)

	InputLinks(0)=(LinkDesc="Show")
	InputLinks(1)=(LinkDesc="Hide")

	VariableLinks(1)=(ExpectedType=class'SeqVar_String',LinkDesc="String",MinVars=0,bHidden=TRUE)

	bLatentExecution=TRUE
	bAutoActivateOutputLinks=FALSE
}
