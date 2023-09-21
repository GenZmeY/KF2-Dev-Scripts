//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_93R extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_93R"

	BuyPrice=0
	AmmoPricePerMag=10 //8
	ImagePath="wep_ui_hrg_93r_pistol_tex.UI_WeaponSelect_HRG_93R"

	EffectiveRange=50

	UpgradePrice[0]=200
	UpgradePrice[1]=500
	UpgradePrice[2]=600
	UpgradePrice[3]=700
	UpgradePrice[4]=1500

	// Cannot be sold
	//UpgradeSellPrice[0]=150
	//UpgradeSellPrice[1]=337
	//UpgradeSellPrice[2]=412
	//UpgradeSellPrice[3]=450
	//UpgradeSellPrice[4]=750
}
