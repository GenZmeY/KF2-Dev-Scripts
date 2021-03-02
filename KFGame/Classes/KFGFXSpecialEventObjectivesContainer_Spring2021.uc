class KFGFxSpecialEventObjectivesContainer_Spring2021 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Spring2021_UI.UI_Objectives_Spring2021_Cyber_Threat"		// Kill 15 Bosses on any map or mode
	ObjectiveIconURLs[1] = "Spring2021_UI.UI_Objectives_Spring2021_Weekly_Hack"			// Complete the Weekly on Dystopia 2029
	ObjectiveIconURLs[2] = "Spring2021_UI.UI_Objectives_Spring2021_AI_Out_of_Control"	// Kill 100 E.D.A.R.s on Dystopia 2029
	ObjectiveIconURLs[3] = "Spring2021_UI.UI_Objectives_Spring2021_Not_a_Simulation"	// Complete a wave without taking any damage 10 times on Dystopia 2029
	ObjectiveIconURLs[4] = "Spring2021_UI.UI_Objectives_Spring2021_Zed_World"			// Complete wave 15 on Endless Hard or higher difficulty on Dystopia 2029

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet_Spring_01_Item_TEX.cyborg_companionbackpack.cyborgcompanionbackpack_precious"
    ChanceDropIconURLs[0]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL="Spring2021_UI.KF2_Spring_DystopianDevastation_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}