//=============================================================================
// KFGFxWidget_LevelUpNotification
//=============================================================================
// HUD Widget that displays when a user levels up
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 09/10/2014
//=============================================================================

class KFGFxWidget_LevelUpNotification extends GFxObject;

var localized string LevelUpString;
var localized string TierUnlockedString;
var localized string ObjectiveCompleteString;

function InitializeHUD()
{
	
}

function SetLocalizedText()
{
	local GFxObject tempObj;
	tempObj = CreateObject("Object");
	tempObj.SetString("levelUpString", LevelUpString);
	tempObj.SetString("tierUnlockedString", TierUnlockedString);
	SetObject("localizeText", tempObj);
}

//Called from KFPlayerController::ClientFinishedSpecialEvent
function FinishedDailyEvent(int EventIndex)
{
	local KFPlayerController MyKFPC;
	local DailyEventInformation EventInfo;

	MyKFPC = KFPlayerController(GetPC());

	if(MyKFPC == none)
	{
		return;
	}

	EventInfo = MyKFPC.GetDailyObjective(EventIndex);
	ShowAchievementNotification(ObjectiveCompleteString, class'KFGFxDailyObjectivesContainer'.static.FormTitleForObjective( EventInfo ), class'KFGFxDailyObjectivesContainer'.static.FormDescriptionForObjective( EventInfo ), class'KFGFxDailyObjectivesContainer'.static.GetIconForObjective( EventInfo ), true);
	class'KFMusicStingerHelper'.static.PlayDailyCompleteStinger(GetPC());
}

//Called from KFPlayerController::ClientFinishedSpecialEvent
function FinishedSpecialEvent(int EventIndex, int ObjectiveIndex)
{
	local class<KFGFxSpecialeventObjectivesContainer> SpecialEventClass;

	//get the correctObjectives container
	SpecialEventClass = class'KFGFxMenu_StartGame'.static.GetSpecialEventClass(EventIndex);
	//get the objective info
	ShowObjectiveCompleteNotification(SpecialEventClass.default.SpecialEventObjectiveInfoList[ObjectiveIndex].TitleString, SpecialEventClass.default.SpecialEventObjectiveInfoList[ObjectiveIndex].DescriptionString, "img://"$SpecialEventClass.default.ObjectiveIconURLs[ObjectiveIndex]);
	class'KFMusicStingerHelper'.static.PlaySpecialEventObjectiveStinger(GetPC());
}

function ShowLevelUpNotification(Class<KFPerk> PerkClass, byte PerkLevel, bool bTierUnlocked)
{
	ShowAchievementNotification(LevelUpString, PerkClass.default.PerkName, TierUnlockedString, "img://"$PerkClass.static.GetPerkIconPath(), bTierUnlocked, PerkLevel);
}


function ShowObjectiveCompleteNotification(string ObjectiveName, string ObjectiveDescription, string ImagePath, optional bool bShowSecondary)
{
	ShowAchievementNotification(ObjectiveCompleteString, ObjectiveName, " ", ImagePath, bShowSecondary, INDEX_NONE);
}

function ShowAchievementNotification(string TitleString, string MainString, string SecondaryString, string ImagePath, bool bShowSecondary, optional int NumericValue = -1)
{
	local GFxObject tempObj;

	tempObj = CreateObject("Object");

	tempObj.SetString("titleString", TitleString);
	tempObj.SetString("mainString", MainString);
	tempObj.SetString("secondaryString", SecondaryString);
	tempObj.SetInt("newValue", NumericValue);
	tempObj.SetString("iconPath", ImagePath);
	tempObj.Setbool("bShowSecondary", bShowSecondary);

	SetObject("showAchievementPopUp", tempObj);
}