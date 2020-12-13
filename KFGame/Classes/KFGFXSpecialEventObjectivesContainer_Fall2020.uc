class KFGFXSpecialEventObjectivesContainer_Fall2020 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Halloween_UI.UI_Objectives_Halloween2020_InfernalLegion"		// Kill 2000 Zeds on any map or mode
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"							// Complete Weekly on Hellmark Station
	ObjectiveIconURLs[2] = "Halloween_UI.UI_Objectives_Halloween2020_AtAnyCost"				// Get the Hellish Rage from a Hellmark Station Obelisk 10 times
	ObjectiveIconURLs[3] = "Halloween_UI.UI_Objectives_Halloween2020_DemonSlayer"			// Decapitate 600 Zeds on Hellmark Station
	ObjectiveIconURLs[4] = "Halloween_UI.UI_Objectives_Halloween2020_InexhaustibleChaos"	// Complete wave 15 on Endless Hard or higher difficulty on Hellmark Station

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet_Halloween_04_Item_TEX.halloweenvoodoobackpack.halloweenvoodoobackpack_precious_large"
    ChanceDropIconURLs[0]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL="Halloween_UI.KF2_Halloween_InfernalInsurrection_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}