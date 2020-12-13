class KFGFxSummer2019ObjectivesContainer extends KFGFxSpecialEventObjectivesContainer;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "SummerSideShow_UI.UI_Objectives_Summer_SteamFObj"
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"
	ObjectiveIconURLs[2] = "SummerSideShow_UI.UI_Objectives_Summer_SteamFEndless"
	ObjectiveIconURLs[3] = "SummerSideShow_UI.UI_Objectives_Summer_ZedLObj"
	ObjectiveIconURLs[4] = "SummerSideShow_UI.UI_Objectives_Summer_OutpostObj"

	//defaults
	AllCompleteRewardIconURL = "wep_skinset25_item_tex.m99_royal.M99_SteampunkPrecious_Mint"
	ChanceDropIconURLs[0] = "CHR_CosmeticSet_SS_01_ItemTex.Sideshow_Prize_Ticket"
	ChanceDropIconURLs[1] = "CHR_CosmeticSet_SS_01_ItemTex.SideshowGoldenTicket_Small"
	IconURL = "SummerSideShow_UI.KF2_KickingBrass_Logo_Small"

	UsesProgressList[0] = false
	UsesProgressList[1] = false
	UsesProgressList[2] = false
	UsesProgressList[3] = false
	UsesProgressList[4] = false
}