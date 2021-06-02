class KFGFxSpecialEventObjectivesContainer_Summer2021 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Summer2021_UI.UI_Objective_Summer2021_Kicked"		        // Stomp on 50 Zeds
	ObjectiveIconURLs[1] = "Spring2021_UI.UI_Objectives_Spring2021_Weekly_Hack"			// Complete the Weekly on Moonbase
	ObjectiveIconURLs[2] = "Summer2021_UI.UI_Objective_Summer2021_ShckingMoonlight"	    // Use the laser trap to kill 20 Zeds on Moonbase
	ObjectiveIconURLs[3] = "Summer2021_UI.UI_Objective_Summer2021_WeightlessSklls"	    // Kill 300 Zeds while jumping in the air on Moonbase
	ObjectiveIconURLs[4] = "Summer2021_UI.UI_Objective_Summer2021_InfiniteVoid"			// Complete wave 15 on Endless Hard or higher difficulty on Moonbase

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet_SS_02_ItemTex.astronaut_companionbackpack.astronautcompanionbackpack_precious"
    ChanceDropIconURLs[0]="CHR_CosmeticSet_SS_01_ItemTex.SideshowPremiumTicket_Small"
    ChanceDropIconURLs[1]="CHR_CosmeticSet_SS_01_ItemTex.SideshowGoldenTicket_Small"
	IconURL="Summer2021_UI.KF2_Summer_InterstellarInsanity_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}