class KFGFxSpecialEventObjectivesContainer_Spring2020 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Spring_UI.UI_Objectives_Spring_1500ZEDs"		// Kill 1500 zeds on any map
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"			// Complete the weekly on Biolapse
	ObjectiveIconURLs[2] = "Spring_UI.UI_Objectives_Spring_BloodBlender"	// Use the blood blender to kill 20 zeds on Biolapse
	ObjectiveIconURLs[3] = "Spring_UI.UI_Objectives_Spring_TrapDoor"		// Use the trap doors to kill 20 zeds on Biolapse
	ObjectiveIconURLs[4] = "Spring_UI.UI_Objectives_Spring_BiolapseBoss"	// Defeat any boss on Survival Hard or higher difficulty on Biolapse

	//defaults
	AllCompleteRewardIconURL="WEP_SkinSet28_Item_TEX.dynamic_aa12.AA12_JaegerDynamic_Mint_large"
    ChanceDropIconURLs[0]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL="Spring_UI.KF2_Spring_NeonNightmares_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}