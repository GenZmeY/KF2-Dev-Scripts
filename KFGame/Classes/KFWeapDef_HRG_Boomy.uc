//=============================================================================
// KFWeapDef_HRG_Boomy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_Boomy extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_Boomy"

	BuyPrice=650
	AmmoPricePerMag=30 //50
	ImagePath="WEP_UI_HRG_Boomy_TEX.UI_WeaponSelect_HRG_Boomy"

	IsPlayGoHidden=true;

	EffectiveRange=50

	UpgradePrice[0]=600
	UpgradePrice[1]=700
	UpgradePrice[2]=1500

	UpgradeSellPrice[0]=450
	UpgradeSellPrice[1]=975
	UpgradeSellPrice[2]=2100
}

