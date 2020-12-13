class KFGFxSpecialEventObjectivesContainer_Summer2020 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	// TODO: Change temporal assets for the right ones

	ObjectiveIconURLs[0] = "Texture2D'Xmas_UI.UI_Objectives_Xmas_25Bosses'"						// Kill 15 Bosses on any map or mode
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"								// Complete the weekly on Desolation
	ObjectiveIconURLs[2] = "Summer2020_UI.UI_Objectives_Sumer2020_LightUp"						// Activate the power generator on Desolation
	ObjectiveIconURLs[3] = "Summer2020_UI.UI_Objectives_Summer2020_FullDoublons"				// Earn 75,000 Dosh through kills, rewards and healing on Desolation
	ObjectiveIconURLs[4] = "Summer2020_UI.UI_Objectives_Summer20_EndlessPlunder"				// Complete wave 15 on Endless Hard or higher difficulty on Desolation

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet24_Item_TEX.spacepiratespacemonkeybackpack.SpacePirateSpaceMonkeyBackPack_Precious_large"
    ChanceDropIconURLs[0]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL="Summer2020_UI.KF2_Summer_PerilousPlunder_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = false
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}