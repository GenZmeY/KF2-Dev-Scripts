class KFGFxSpecialEventObjectivesContainer_Xmas2019 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Xmas_UI.UI_Objectives_Xmas_BossKill02"		// Defeat any boss on Survival Hard or higher difficulty on Sanitarium
	ObjectiveIconURLs[1] = "Xmas_UI.UI_Objectives_Xmas_TentacleWhip"	// Use Tentacle Whip trap to kill 20 zeds on Sanitarium
	ObjectiveIconURLs[2] = "Xmas_UI.UI_Objectives_Xmas_SuctionTrap"		// Use Suction Trap to kill 20 zeds on Sanitarium
	ObjectiveIconURLs[3] = "Xmas_UI.UI_Objectives_Xmas_Matriarch"		// Kill the Matriarch 10 times on any map or mode
	ObjectiveIconURLs[4] = "Xmas_UI.UI_Objectives_Xmas_BioticsObj"		// Complete Biotics Lab on Objective Hard or higher difficulty

	//defaults
	AllCompleteRewardIconURL="WEP_SkinSet27_Item_TEX.fnfal_dynamic.FNFAL_JaegerDynamic_Mint_large"
    ChanceDropIconURLs[0]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket"
    ChanceDropIconURLs[1]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket_Golden"
	IconURL="Xmas_UI.KF2_Xmas_YuletideHorror_Logo_Small"

	UsesProgressList[0] = false
	UsesProgressList[1] = true
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}