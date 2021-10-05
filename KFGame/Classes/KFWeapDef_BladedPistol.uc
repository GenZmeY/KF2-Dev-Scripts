//=============================================================================
// KFWeapDef_BladedPistol
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_BladedPistol extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_Bladed"

	BuyPrice=600
	AmmoPricePerMag=32
	ImagePath="WEP_UI_BladedPistol_TEX.UI_WeaponSelect_BladedPistol"

	EffectiveRange=25

	UpgradePrice[0]=700
	UpgradePrice[1]=1500
    UpgradeSellPrice[0]=550
	UpgradeSellPrice[1]=1650
}
