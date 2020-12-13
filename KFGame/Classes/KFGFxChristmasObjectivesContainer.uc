class KFGFxChristmasObjectivesContainer extends KFGFxSpecialEventObjectivesContainer;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
    super.Initialize( NewParentMenu );
}

DefaultProperties
{
	ObjectiveIconURLs[0]="Xmas_UI.UI_Objectives_Xmas_CartHP"
    ObjectiveIconURLs[1]="Xmas_UI.UI_Objectives_Xmas_ShoppingSpree"
    ObjectiveIconURLs[2]="Xmas_UI.UI_Objectives_Xmas_2kZEDs"
    ObjectiveIconURLs[3]="Xmas_UI.UI_Objectives_Xmas_25Bosses"
    ObjectiveIconURLs[4]="Xmas_UI.UI_Objectives_Xmas_SantasLair"
    //defaults
    AllCompleteRewardIconURL="WEP_SkinSet_Christmas_Item_TEX.BattleAxe_ChristmasPrecious_Mint"
    ChanceDropIconURLs[0]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket"
    ChanceDropIconURLs[1]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket_Golden"
	IconURL="Xmas_UI.KF2_TwistedChristmas_Logo_Small"

	UsesProgressList[0] = false
	UsesProgressList[1] = false
	UsesProgressList[2] = true
	UsesProgressList[3] = true
	UsesProgressList[4] = false
}