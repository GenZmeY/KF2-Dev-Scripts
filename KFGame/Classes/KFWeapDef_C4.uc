//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_C4 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Thrown_C4"

	BuyPrice=300
	AmmoPricePerMag=50 // 27
	ImagePath="WEP_UI_C4_TEX.UI_WeaponSelect_C4"

	EffectiveRange=10

	//UpgradePrice[0]=600
	//UpgradePrice[1]=700
	//UpgradePrice[2]=1500

	//UpgradeSellPrice[0]=450
	//UpgradeSellPrice[1]=975
	//UpgradeSellPrice[2]=2100
}
