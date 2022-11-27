class KFGFXSpecialEventObjectivesContainer_Xmas2022 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Xmas2022_UI.UI_Objectives_Xmas_2022_Frozen_Hearts"	 		// Freeze 500 Zeds using ice arsenal
	ObjectiveIconURLs[1] = "Xmas2022_UI.Black_Weekly"							 		// Complete the Weekly on Crash
	ObjectiveIconURLs[2] = "Xmas2022_UI.UI_Objective_Xmas_2022_Shotgun_Jump"	 		// Use 4 Boomstick Jumps in a same match on Crash
	ObjectiveIconURLs[3] = "Xmas2022_UI.UI_Objective_Xmas_2022_Not_a_Snowball"	 		// Hit 3 Zeds with a shot of HRG Ballistic Bouncer (15 times)
	ObjectiveIconURLs[4] = "Xmas2022_UI.UI_Objective_Xmas_2022_Withstand_the_Tempest"	// Complete wave 15 on Endless Hard or higher difficulty on Crash

	//defaults
	AllCompleteRewardIconURL="CHR_TrainConductorUniform_Item_TEX.trainbackpack.trainconductorbackpack_precious"
    ChanceDropIconURLs[0]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket"
    ChanceDropIconURLs[1]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket_Golden"
	IconURL="Xmas2022_UI.Polar_distress_small_logo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}