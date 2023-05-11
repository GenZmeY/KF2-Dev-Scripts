class KFGFXSpecialEventObjectivesContainer_Summer2023 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Summer2023_UI.UI_Objetives_Summer2023_TheBoomestofBuddies"	 		// Kill 1500 Zeds with HRG Bombardier
	ObjectiveIconURLs[1] = "Xmas2022_UI.Black_Weekly"							 		        // Complete the Weekly on Subduction
	ObjectiveIconURLs[2] = "Summer2023_UI.UI_Objectives_Summer2023_ClassicWaterShockCombo"	 	// Stun 2500 Zeds with EMP affliction
	ObjectiveIconURLs[3] = "Summer2023_UI.UI_Objectives_Summer2023_DeepWaterareNotStill"	 	// Complete 25 Stand your Ground objectives
	ObjectiveIconURLs[4] = "Summer2023_UI.UI_Objectives_Summer2023_SomewhereBeyondtheZ"			// Complete wave 15 on Endless Hard or higher difficulty on Subduction

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet39_Item_TEX.sharkjaw.sharkjaw_precious"
    ChanceDropIconURLs[0]="CHR_CosmeticSet_SS_01_ItemTex.Sideshow_Prize_Ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet_SS_01_ItemTex.SideshowGoldenTicket_Small"
	IconURL="Summer2023_UI.KF2_Summer_2023_DeepBlueZ"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}