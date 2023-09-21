class KFGFXSpecialEventObjectivesContainer_Fall2023 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Halloween2023_UI.UI_Objective_Halloween2023_ICouldDoThisAllDay"			// Kill Hans Volter in 10 different maps
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"									// Complete the Weekly on Castle Volter
	ObjectiveIconURLs[2] = "Halloween2023_UI.UI_Objective_Halloween2023_LuckilyTheyreNotClones"		// Find all Castle Volter’s Collectibles
	ObjectiveIconURLs[3] = "Halloween2023_UI.UI_Objective_Halloween2023_ThisBelongToAMuseum"		// Unlock all exhibits from Castle Volter’s trophy room ( TODO )
	ObjectiveIconURLs[4] = "Halloween2023_UI.UI_Objective_Halloween2023_AFineDayAtTheMountains"		// Complete wave 15 on Endless Hard or higher difficulty on Castle Volter

	//defaults
	AllCompleteRewardIconURL="WEP_SkinSet81_Item_TEX.mkb42_hans.VolterMKB42Precious_Mint"
    ChanceDropIconURLs[0]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL="Halloween2023_UI.UI_Halloween2023_EventLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = false
	UsesProgressList[4] = false
}