class KFGFXSpecialEventObjectivesContainer_Xmas2021 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Xmas2021_UI.Heads_For_Sale"									// Decapitate 1000 Zeds on any map or mode
	ObjectiveIconURLs[1] = "Xmas2021_UI.Black_Weekly"									// Complete the Weekly on Carillon Hamlet
	ObjectiveIconURLs[2] = "Xmas2021_UI.Filthy_Rich"									// Earn 75,000 Dosh through kills, rewards and healing on Carillon Hamlet
	ObjectiveIconURLs[3] = "Xmas2021_UI.Painful_Payments"								// Use the trader to purchase a total of 20 weapons that cost 1500 Dosh or more on Carrion Hamlet.
	ObjectiveIconURLs[4] = "Xmas2021_UI.Nonstop_Splurge"								// Complete wave 15 on Endless Hard or higher difficulty on Carillon Hamlet

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet_XMAS_05_Item_TEX.shopping_companion.holidayshoppingcompanion_precious"
    ChanceDropIconURLs[0]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket"
    ChanceDropIconURLs[1]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket_Golden"
	IconURL="Xmas2021_UI.KF2_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}