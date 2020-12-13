class KFGFxFall2019ObjectivesContainer extends KFGFxSpecialEventObjectivesContainer;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Halloween_UI.UI_Objectives_Halloween_BossKill"			// Defeat any boss on Survival Hard or higher difficulty on Asylum
	ObjectiveIconURLs[1] = "Halloween_UI.UI_Objectives_Halloween_AsylumEndless"		// Complete wave 15 on Endless Hard or higher difficulty on Asylum
	ObjectiveIconURLs[2] = "Spring_UI.UI_Objectives_Spring_Weekly"					// Complete the Weekly on Asylum
	ObjectiveIconURLs[3] = "Halloween_UI.UI_Objectives_Halloween_1500ZEDs"			// Kill 1500 Zeds on Asylum
	ObjectiveIconURLs[4] = "Halloween_UI.UI_Objectives_Halloween_NukedObj"			// Complete Nuked on Objective Hard or higher difficulty

	//defaults
	AllCompleteRewardIconURL="WEP_SkinSet26_Item_TEX.kriss_spaceelite.Kriss_BeyondHorizonPrecious_Mint"
    ChanceDropIconURLs[0]="CHR_CosmeticSet_Halloween_01_Item_TEX.hllwn_treat_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet_Halloween_01_Item_TEX.hllwn_treat_ticket_precious"
	IconURL="Halloween_UI.KF2_Halloween_GrimTreatments_Logo_Small"

	UsesProgressList[0] = false
	UsesProgressList[1] = false
	UsesProgressList[2] = false
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}