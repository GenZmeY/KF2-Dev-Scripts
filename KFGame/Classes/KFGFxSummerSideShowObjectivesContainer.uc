class KFGFxSummerSideShowObjectivesContainer extends KFGFxSpecialEventObjectivesContainer;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
}

DefaultProperties
{
	ObjectiveIconURLs[0]="SummerSideShow_UI.UI_Objectives_SS_Steampunk_RepairEngine"
    ObjectiveIconURLs[1]="Objectives_UI.UI_Objectives_Xmas_DefendObj"
    ObjectiveIconURLs[2]="SummerSideShow_UI.UI_Objectives_SS_Generator"
    ObjectiveIconURLs[3]="SummerSideShow_UI.UI_Objectives_SS_Steampunk_Water"
    ObjectiveIconURLs[4]="SummerSideShow_UI.UI_Objectives_SS_Steampunk_Difficulty"

    //defaults
    AllCompleteRewardIconURL="CHR_Steampunk_Item_TEX.UniformBundle_Steampunk"
    ChanceDropIconURLs[0]="CHR_CosmeticSet_SS_01_ItemTex.Sideshow_Prize_Ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet_SS_01_ItemTex.SideshowGoldenTicket_Small"
	IconURL="SummerSideShow_UI.KF2_SummerSideshow_Logo_Small"
}