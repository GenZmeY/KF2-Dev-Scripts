class KFGFxFallObjectivesContainer extends KFGFxSpecialEventObjectivesContainer;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
}

DefaultProperties
{
	
    ObjectiveIconURLs[0]="Halloween_UI.UI_Objectives_Halloween_Trap"
    ObjectiveIconURLs[1]="Halloween_UI.UI_Objectives_Halloween_Collectible"
    ObjectiveIconURLs[2]="Halloween_UI.UI_Objectives_Halloween_500ZEDs"
	ObjectiveIconURLs[3] = "Halloween_UI.UI_Objectives_Halloween_Wave25"
    ObjectiveIconURLs[4]="Halloween_UI.UI_Objectives_Halloween_HansKill"
	
    //defaults
	AllCompleteRewardIconURL="WEP_SkinSet_Halloween_Item_TEX.hans_mkb42h.MKB42_HalloweenPrecious_Mint"
    ChanceDropIconURLs[0]="CHR_CosmeticSet_Halloween_01_Item_TEX.hllwn_treat_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet_Halloween_01_Item_TEX.hllwn_treat_ticket_precious"
	IconURL="Halloween_UI.KF2_HalloweenHorrors2018_Logo_UIBanner"

	UsesProgressList[0] = false
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = false
	UsesProgressList[4] = false
}