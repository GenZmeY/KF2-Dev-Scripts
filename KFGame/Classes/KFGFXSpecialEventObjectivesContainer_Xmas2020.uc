class KFGFXSpecialEventObjectivesContainer_Xmas2020 extends KFGFxSpecialEventObjectivesContainer;

function Initialize(KFGFxObject_Menu NewParentMenu)
{
    super.Initialize(NewParentMenu);
}

DefaultProperties
{
	ObjectiveIconURLs[0] = "Xmas_UI.UI_Objectives_Christmas2020_FrozenRoses"			// Collect 3 roses in Elysium
	ObjectiveIconURLs[1] = "Xmas_UI.UI_Objectives_Christmas2020_FourDifferentTales"		// Collect 4 tomes in Elysium
	ObjectiveIconURLs[2] = "Xmas_UI.UI_Objectives_Christmas2020_UnderTheMistletoe"		// Complete one wave in Elysium's Botanica arena
	ObjectiveIconURLs[3] = "Xmas_UI.UI_Objectives_Christmas2020_AChristmasCarol"		// Complete one wave in Elysium's Loremaster Sanctum arena
	ObjectiveIconURLs[4] = "Xmas_UI.UI_Objectives_Christmas2020_EverlastingWinter"		// Complete wave 15 on Endless Hard or higher difficulty on Elysium

	//defaults
	AllCompleteRewardIconURL="CHR_CosmeticSet_XMAS_04_Item_TEX.tacticalelfpack.tacticalelfpack_precious_large"
    ChanceDropIconURLs[0]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket"
    ChanceDropIconURLs[1]="CHR_Cosmetic_XMAS_Item_TEX.Tickets.Krampus_Ticket_Golden"
	IconURL="Xmas_UI.KF2_Christmas_ChristmasCrackdown_SmallLogo"

	UsesProgressList[0] = true
	UsesProgressList[1] = true
	UsesProgressList[2] = false
	UsesProgressList[3] = false
	UsesProgressList[4] = false
}