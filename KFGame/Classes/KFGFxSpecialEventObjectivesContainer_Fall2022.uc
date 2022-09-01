class KFGFXSpecialEventObjectivesContainer_Fall2022 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Halloween2022_UI.UI_Objectives_Halloween2022_CreaturesInDarkness"  // Kill 15 Bosses on any map or mode
	ObjectiveIconURLs[1] = "Spring_UI.UI_Objectives_Spring_Weekly"							   // Complete the Weekly on BarmwichTown
	ObjectiveIconURLs[2] = "Halloween2022_UI.UI_Objetives_Halloween2022_ElementalMedallions"   // Open the Weapon Room
	ObjectiveIconURLs[3] = "Halloween2022_UI.UI_Objectives_Halloween2022_ZedOnFire"			   // Make 50 Zeds to pass through the bonfires of Barmwitch Town
	ObjectiveIconURLs[4] = "Halloween2022_UI.UI_Objetives_Halloween2022_LongNightofWitches"	   // Complete wave 15 on Endless Hard or higher difficulty on Barmwitch Town

	//defaults
	AllCompleteRewardIconURL="CHR_PlagueDoctorUniform_Item_TEX.potionbackpack.plaguedoctorbackpack_precious_large"
    ChanceDropIconURLs[0]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket"
    ChanceDropIconURLs[1]="CHR_CosmeticSet14_Item_TEX.Tickets.CyberPunk_ticket_golden"
	IconURL="halloween2022_ui.KF2_Halloween_BloodandBonfires_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = false
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}