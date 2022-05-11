class KFGFxSpecialEventObjectivesContainer_Summer2022 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Summer2022_UI.UI_Objectives_Summer2022_Not_the_best_tourists" // Kill 1500 Zeds on any map or mode
	ObjectiveIconURLs[1] = "Summer2022_UI.UI_Objectives_Summer2022_Splashdown"			  // Complete the Weekly on Rig
	ObjectiveIconURLs[2] = "Summer2022_UI.UI_Objectives_Summer2022_Top_Surfer"	          // Complete 100 waves on Rig
	ObjectiveIconURLs[3] = "Summer2022_UI.UI_Objectives_Summer2022_Overboard"	          // Throw 50 Zeds to the sea on Rig
	ObjectiveIconURLs[4] = "Summer2022_UI.UI_Objectives_Summer2022_Wide_wide_sea"		  // Complete wave 15 on Endless Hard or higher difficulty on Rig

	//defaults
	AllCompleteRewardIconURL="CHR_DeepSeaUniform_Item_TEX.trident.deepseatrident_precious"
    ChanceDropIconURLs[0]="CHR_CosmeticSet_SS_01_ItemTex.Sideshow_Prize_Ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet_SS_01_ItemTex.SideshowGoldenTicket_Small"
	IconURL="Summer2022_UI.KF2_Summer_2022_Tidal_Terror"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}