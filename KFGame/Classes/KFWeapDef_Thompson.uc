//=============================================================================
// KFWeapDef_Thompson
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Thompson extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_AssaultRifle_Thompson"

	BuyPrice=650 //650
	AmmoPricePerMag=45 // 50
	ImagePath="WEP_UI_TommyGun_TEX.UI_WeaponSelect_TommyGun"


	EffectiveRange=50

	UpgradePrice[0]=600
	UpgradePrice[1]=700
	UpgradePrice[2]=1500

	UpgradeSellPrice[0]=450
	UpgradeSellPrice[1]=975
	UpgradeSellPrice[2]=2100
}
