class KFGFxSpring2019ObjectivesContainer extends KFGFxSpecialEventObjectivesContainer;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Xmas_UI.UI_Objectives_Xmas_25Bosses"
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"
	ObjectiveIconURLs[2] = "Spring_UI.UI_Objectives_Spring_1500ZEDs"
	ObjectiveIconURLs[3] = "Spring_UI.UI_Objectives_Spring_SpillwayEndless"
	ObjectiveIconURLs[4] = "Spring_UI.UI_Objectives_Spring_SpillwayBoss"

	//defaults
	AllCompleteRewardIconURL = "CHR_Cyberpunk_Item_TEX.Uniform_Cyberpunk"
	ChanceDropIconURLs[0] = "CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
	ChanceDropIconURLs[1] = "CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL = "Spring_UI.KF2_CyberRevolt_Logo_Small"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = false
	UsesProgressList[4] = false
}