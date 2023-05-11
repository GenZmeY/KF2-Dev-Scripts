//=============================================================================
// KFWeapDef_HRGWarthog
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_Warthog extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_Warthog"

	BuyPrice=500
	AmmoPricePerMag=60 // 27
	ImagePath="WEP_UI_HRG_Warthog_TEX.UI_WeaponSelect_HRG_Warthog"

	IsPlayGoHidden=true;

	EffectiveRange=18

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}
