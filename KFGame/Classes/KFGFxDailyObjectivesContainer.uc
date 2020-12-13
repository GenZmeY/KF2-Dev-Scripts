class KFGFxDailyObjectivesContainer extends KFGFxObject_Container
dependson (KFOnlineStatsWrite);

var localized string TitleString;
var localized string OverviewString;
var localized string SubtitleString;

var localized string KnifeString;

var string IconURL;

var KFPlayerController KFPC;

var array<string>ObjectiveIconURLs;

var const int NUM_OF_DAILIES;

enum E_DailyIcon
{
	DI_Character,
	DI_Map,
	DI_PerkXP,
	DI_Versus,
	DI_Weapon,
	DI_ZED
};

struct ObjectiveProgress
{
	var bool bComplete;
	var int NumericValue;

	structdefaultproperties
	{
		NumericValue = INDEX_NONE;
	}
};

var array<ObjectiveProgress> ObjectiveStatusList;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );

    KFPC = KFPlayerController(GetPC());
    
    LocalizeMenu(); 
    PopulateData();
}

function LocalizeMenu()
{
    local GFxObject TextObject;
    TextObject = CreateObject("Object");
    // Localize static text
    TextObject.SetString("title",			default.TitleString);  
    TextObject.SetString("overview",			default.OverviewString);  
    TextObject.SetString("subtitle",			default.SubtitleString);  
   	
    SetObject("localizedText", TextObject);
}


function bool PopulateData(optional bool bForceRefresh)
{
	local GFxObject DataObject;
    local GFxObject DataProvider; //array containing the data objects 
    local int i;

    DataProvider = CreateArray();

    for (i = 0; i < NUM_OF_DAILIES; i++)
    {
    	DataObject = CreateObject("Object");
    	if(DataObject != none)  //somehow this is none on Xbone
    	{
			MakeDailyDataObject(KFPC.GetDailyObjective(i), i, KFPC, DataObject);
			if (DataObject == none)
			{
				continue;
			}
	    	DataProvider.SetElementObject(i, DataObject);
    	}
    }

    SetObject("dailyObjectiveData", DataProvider);

    return HasObjectiveStatusChanged();
}

static function GFxObject MakeDailyDataObject(DailyEventInformation EventInfo, int Index, KFPlayerController MyKFPC, out GFxObject RefDataObject)
{
	local bool bProgressObjective;

	bProgressObjective =  IsProgressObjective(EventInfo);
	
    RefDataObject.SetString("label", FormTitleForObjective( EventInfo));
    RefDataObject.SetString("description",  FormDescriptionForObjective( EventInfo));
    RefDataObject.SetString("iconPath", GetIconForObjective( EventInfo));
    RefDataObject.SetBool("complete",  MyKFPC.IsDailyObjectiveComplete(Index));     


    RefDataObject.SetBool("showProgress", bProgressObjective);
    if(bProgressObjective)
    {
    	RefDataObject.SetFloat("progress", FClamp(Float(MyKFPC.GetCurrentDailyValue(Index)) / Float(MyKFPC.GetMaxDailyValue(Index)), 0, 1) );
    	RefDataObject.SetString("textValue", MyKFPC.GetCurrentDailyValue(Index) $"/" $MyKFPC.GetMaxDailyValue(Index));   
		if (MyKFPC.GetCurrentDailyValue(Index) == INDEX_NONE || MyKFPC.GetMaxDailyValue(Index) == INDEX_NONE)
		{
			return none;
		}
    }
    else
    {
    	RefDataObject.SetFloat("progress", 0);
    	RefDataObject.SetString("textValue", "");   
    }

    RefDataObject.SetString("rewardText", class'KFMission_LocalizedStrings'.default.RewardString);
    RefDataObject.SetInt("reward", class'KFOnlineStatsWrite'.static.GetDailyEventReward());

    return RefDataObject;    
}

function static string GetIconForObjective( DailyEventInformation EventInfo )
{
	switch (EventInfo.ObjectiveType)
	{
		case DOT_WeaponDamage:
			return "img://"$default.ObjectiveIconURLs[DI_Weapon];
		case DOT_PerkXP:
			switch (EventInfo.SecondaryType)
			{
				case DOST_KillZeds:
					return "img://"$default.ObjectiveIconURLs[DI_ZED];
				case DOST_PlayPerk:
					return "img://"$default.ObjectiveIconURLs[DI_PerkXP];
				case DOST_KillBoss:
					return "img://"$default.ObjectiveIconURLs[DI_ZED];
			}
			break;		
		case DOT_Maps:

			switch (EventInfo.SecondaryType)
			{
				case DOST_VersusDamage:
				return "img://"$default.ObjectiveIconURLs[DI_Versus];
				case DOST_VersusKills:
					return "img://"$default.ObjectiveIconURLs[DI_Versus];
					
				case DOST_MapCompletion:
					return "img://"$default.ObjectiveIconURLs[DI_Map];
				case DOST_CharacterCompletion:
					return "img://"$default.ObjectiveIconURLs[DI_Character];
			}
			
			break;				
	}
	return "";
}

function static bool IsProgressObjective( DailyEventInformation EventInfo )
{
	switch (EventInfo.ObjectiveType)
	{
		case DOT_WeaponDamage:
			return true;
		case DOT_PerkXP:
			switch (EventInfo.SecondaryType)
			{
				case DOST_KillZeds:
				case DOST_PlayPerk:
					return true;
			}
			break;		
		case DOT_Maps:

			switch (EventInfo.SecondaryType)
			{
				case DOST_VersusDamage:
				case DOST_VersusKills:
					return true;
					
				case DOST_MapCompletion:
				case DOST_CharacterCompletion:
					return false;
			}
			
			break;			
	}

	return false;
}

function static string FormTitleForObjective( DailyEventInformation EventInfo )
{
	local string NewString;

	switch (EventInfo.ObjectiveType)
	{
		case DOT_WeaponDamage:
			NewString = class'KFMission_LocalizedStrings'.default.DealDamageString;
			break;
		case DOT_PerkXP:
			switch (EventInfo.SecondaryType)
			{
				case DOST_KillZeds:
					NewString = class'KFMission_LocalizedStrings'.default.KillZedsString;
					break;
				case DOST_PlayPerk:
					NewString = class'KFMission_LocalizedStrings'.default.EarnXPString;
					break;
				case DOST_KillBoss:
					NewString = class'KFMission_LocalizedStrings'.default.KillBossString;
					break;
			}
			break;		
		case DOT_Maps:

			switch (EventInfo.SecondaryType)
			{
				case DOST_MapCompletion:
					NewString = class'KFMission_LocalizedStrings'.default.CompleteMapString;
					break;
			
				case DOST_VersusDamage:
					NewString = class'KFMission_LocalizedStrings'.default.DealVersusDamageString;
					break;				
				case DOST_VersusKills:
					NewString = class'KFMission_LocalizedStrings'.default.VersusKillsString;
					break;
				case DOST_CharacterCompletion:
					NewString = class'KFMission_LocalizedStrings'.default.VersusCompletionString;
					break;
			}
			
			break;			
	}

	return NewString;
}

function static string FormDescriptionForObjective( DailyEventInformation EventInfo )
{
	local string DescriptionString;

	switch (EventInfo.ObjectiveType)
	{
		case DOT_WeaponDamage:
			DescriptionString = GetWeaponStringForDT(EventInfo.ObjectiveClasses[0]);
			break;
		case DOT_PerkXP:
			switch (EventInfo.SecondaryType)
			{
				case DOST_KillBoss:
					DescriptionString = class'KFMission_LocalizedStrings'.default.KillBossDescriptionString;
					break;
				case DOST_KillZeds:
					DescriptionString = GetKillsString(EventInfo.ObjectiveClasses[0]);	
					break;
				case DOST_PlayPerk:
					DescriptionString = GetPerkString(EventInfo.ObjectiveClasses[0]);	
					break;
			}
			break;		
		case DOT_Maps:

			switch (EventInfo.SecondaryType)
			{
				case DOST_MapCompletion:
					DescriptionString = GetMapString(EventInfo);
					break;
			
				case DOST_VersusDamage:
					DescriptionString = GetVersusDamageString(EventInfo);
					break;				
				case DOST_VersusKills:
					DescriptionString = GetVersusKillsString(EventInfo);
					break;
			
				case DOST_CharacterCompletion:
					DescriptionString = GetVersusCompleteString(EventInfo);
					break;
			}
			
			break;			
	}

	return DescriptionString;	
}

function static string GetWeaponStringForDT(name WeaponName)
{
	local string MyString;
	
	if(WeaponName == 'KFWeap_Edged_Knife')
	{
		MyString = default.KnifeString;
	}
	else
	{
		MyString = Localize(string(WeaponName), "ItemName", "KFGameContent");
	}	

	return MyString;
}

function static string GetPerkString(name PerkClassName)
{
	local string MyString;
	
	MyString = Localize(string(PerkClassName), "PerkName", "KFGame");

	return MyString;
}

function static string GetKillsString(name ZedClassName)
{
	local string MyString;

	MyString = Localize("Zeds", String(ZedClassName), "KFGame");

	return MyString;
}

//map and difficulty
function static string GetMapString(DailyEventInformation EventInfo)
{
	local string MyString;
	
	MyString = class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(string(EventInfo.ObjectiveClasses[0]) )
	@"-" @class'KFCommon_LocalizedStrings'.static.GetDifficultyString( EventInfo.CompletionAmount );

	return MyString;
}

function static string GetVersusDamageString(DailyEventInformation EventInfo)
{
	local string MyString;
	
	MyString = Localize("Zeds", String(EventInfo.ObjectiveClasses[0]), "KFGame");;

	return MyString;	
}

function static string GetVersusKillsString(DailyEventInformation EventInfo)
{
	local string MyString;
	
	MyString = Localize("Zeds", String(EventInfo.ObjectiveClasses[0]), "KFGame");

	return MyString;	
}

function static string GetVersusCompleteString(DailyEventInformation EventInfo)
{
	local string MyString;
	
	MyString = Localize(string(EventInfo.ObjectiveClasses[0]), "CharacterName", "KFCharacterInfo");

	return MyString;	
}

function bool HasObjectiveStatusChanged()
{
    local int i;
    local bool bHasChanged;
    local bool bTempStatus;
    local int tempNumericValue;
    

    if(KFPC == none)
    {
    	return false;
    }

    if(!KFPC.HasReadStats())
    {
    	return true;
    }

    if(NUM_OF_DAILIES != ObjectiveStatusList.length)
    {
        ObjectiveStatusList.length = NUM_OF_DAILIES;
        for (i = 0; i < NUM_OF_DAILIES; i++)
        {
            ObjectiveStatusList[i].bComplete = KFPC.IsDailyObjectiveComplete(i);
            ObjectiveStatusList[i].numericValue = KFPC.GetCurrentDailyValue(i);
        }
        bHasChanged = true;
    }
    else
    {
        for (i = 0; i < NUM_OF_DAILIES; i++)
        {
            bTempStatus = KFPC.IsDailyObjectiveComplete(i);
            tempNumericValue = KFPC.GetCurrentDailyValue(i);

            if(ObjectiveStatusList[i].bComplete != bTempStatus || tempNumericValue != ObjectiveStatusList[i].numericValue)
            {
                bHasChanged = true;
                ObjectiveStatusList[i].bComplete = bTempStatus;
             	ObjectiveStatusList[i].numericValue = tempNumericValue;   
            }
        }
    }

    return bHasChanged;
}


DefaultProperties
{
	NUM_OF_DAILIES = 3

	ObjectiveIconURLs(DI_Character)="DailyObjective_UI.KF2_Dailies_Icon_Character"
	ObjectiveIconURLs(DI_Map)="DailyObjective_UI.KF2_Dailies_Icon_Map"
	ObjectiveIconURLs(DI_PerkXP)="DailyObjective_UI.KF2_Dailies_Icon_PerkLvl"
	ObjectiveIconURLs(DI_Versus)="DailyObjective_UI.KF2_Dailies_Icon_VS"
	ObjectiveIconURLs(DI_Weapon)="DailyObjective_UI.KF2_Dailies_Icon_Weapon"
	ObjectiveIconURLs(DI_ZED)= "UI_PerkIcons_TEX.UI_PerkIcon_ZED"
	
	IconURL="UI_PerkIcons_TEX.UI_PerkIcon_Berserker"
}