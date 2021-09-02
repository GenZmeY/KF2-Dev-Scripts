class KFGFXSpecialEventObjectivesContainer_Fall2021 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Xmas_UI.UI_Objectives_Xmas_BossKill02"								// Kill 15 Bosses on any map or mode
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"								// Complete the Weekly on Netherhold
	ObjectiveIconURLs[2] = "halloween2021_ui.UI_Objective_Halloween_2021_Im_hearing_heartbeats"	// Find the nether heart
	ObjectiveIconURLs[3] = "halloween2021_ui.UI_Objective_Halloween_2021_Purple_Miasma"			// Unlock the chapel and the dining hall doors
	ObjectiveIconURLs[4] = "halloween2021_ui.UI_Objective_Halloween_2021_Eternal_Punishment"	// Complete wave 15 on Endless Hard or higher difficulty on Netherhold

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet_Halloween_05_Item_TEX.muertos_companion.diadelosmuertoscompanion_precious"
    ChanceDropIconURLs[0]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL="Halloween2021_UI.KF2_Halloween_DayOfTheZED_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = false
	UsesProgressList[3] = false
	UsesProgressList[4] = false
}