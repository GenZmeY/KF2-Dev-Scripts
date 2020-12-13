class KFGFxEndlessDARObjectivesContainer extends KFGFxSpecialEventObjectivesContainer;

var array<string> EndlessRewardIconPaths;
var array<int> WaveTierValues;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
	SetBool("isTieredEvent", true);
	super.Initialize(NewParentMenu);
}


function LocalizeMenu()
{
	local GFxObject TextObject;
	TextObject = CreateObject("Object");
	// Localize static text
	TextObject.SetString("title", default.CurrentSpecialEventString);
    TextObject.SetString("description", default.CurrentSpecialEventDescriptionString);
	TextObject.SetString("reward", "");
	TextObject.SetString("granted", "");
	TextObject.SetString("chanceOfDrop", "");
	SetObject("localizedText", TextObject);
}

function bool PopulateData()
{
	local GFxObject DataObject;
	local GFxObject DataProvider; //array containing the data objects 
	local int i;

	if (HasObjectiveStatusChanged())
	{
		DataProvider = CreateArray();
		
		for (i = 0; i < SpecialEventObjectiveInfoList.length; i++)
		{
			DataObject = CreateObject("Object");

			DataObject.SetString("label", default.SpecialEventObjectiveInfoList[i].TitleString);
			DataObject.SetString("description", default.SpecialEventObjectiveInfoList[i].DescriptionString);
			DataObject.SetString("rewardName", default.SpecialEventObjectiveInfoList[i].TierEventRewardName);
			DataObject.SetString("rewardPath", "img://"$default.EndlessRewardIconPaths[i]);
			DataObject.SetString("iconPath", "img://"$default.ObjectiveIconURLs[i]);
			DataObject.SetBool("complete", ObjectiveStatusList[i].bComplete);
			DataObject.SetInt("rewardValue", ObjectiveStatusList[i].NumericValue);
			DataObject.SetBool("showProgres", false);
			DataObject.SetFloat("progress", 0);
			DataObject.SetString("textValue", "");
			DataObject.SetInt("waveNum", default.WaveTierValues[i]);
			DataObject.SetInt("tierNum", i);

			DataProvider.SetElementObject(i, DataObject); //add it to the array
		}

		SetObject("objectives", DataProvider);

		return true;
	}

	return false;
}


function PopulateChanceDrops()
{
	//no chance drops in DAR event
}

function PopulateReward()
{
	//rewards are part of the objective renderers
}

DefaultProperties
{
	ObjectiveIconURLs[0]="Spring_UI.UI_Objectives_Spring_DAR01"
	ObjectiveIconURLs[1]="Spring_UI.UI_Objectives_Spring_DAR02"
	ObjectiveIconURLs[2]="Spring_UI.UI_Objectives_Spring_DAR03"
	ObjectiveIconURLs[3]="Spring_UI.UI_Objectives_Spring_DAR04"
	ObjectiveIconURLs[4]="Spring_UI.UI_Objectives_Spring_DAR05"
	//defaults
	AllCompleteRewardIconURL = "CHR_Pajama_Item_TEX.Uniform_PajamaObjective"
	ChanceDropIconURLs[0] = "CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket"
	ChanceDropIconURLs[1] = "CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket_Golden"
	IconURL = "Xmas_UI.KF2_KrampusChristmas_UILogo_Small"

	EndlessRewardIconPaths[0]="Spring_UI.UI_Objectives_Spring_DAR01"
	EndlessRewardIconPaths[1]="Spring_UI.UI_Objectives_Spring_DAR02"
	EndlessRewardIconPaths[2]="Spring_UI.UI_Objectives_Spring_DAR03"
	EndlessRewardIconPaths[3]="Spring_UI.UI_Objectives_Spring_DAR04"
	EndlessRewardIconPaths[4]="Spring_UI.UI_Objectives_Spring_DAR05"

	WaveTierValues[0]=5
	WaveTierValues[1]=10
	WaveTierValues[2]=15
	WaveTierValues[3]=20
	WaveTierValues[4]=25

}