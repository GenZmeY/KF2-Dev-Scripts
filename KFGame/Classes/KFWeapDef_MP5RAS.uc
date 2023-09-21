//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_MP5RAS extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_SMG_MP5RAS"

	BuyPrice=650
	AmmoPricePerMag=25 // 28 //22 //33
	ImagePath="WEP_UI_MP5RAS_TEX.UI_WeaponSelect_MP5RAS"

	EffectiveRange=70

	UpgradePrice[0]=600
	UpgradePrice[1]=700
	UpgradePrice[2]=1500

	UpgradeSellPrice[0]=450
	UpgradeSellPrice[1]=975
	UpgradeSellPrice[2]=2100
}