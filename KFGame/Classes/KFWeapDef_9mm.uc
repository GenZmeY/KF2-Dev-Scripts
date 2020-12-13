//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_9mm extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_9mm"

	BuyPrice=0
	AmmoPricePerMag=12 //8
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_9mm"

	EffectiveRange=50

	UpgradePrice[0]=200
	UpgradePrice[1]=500
	UpgradePrice[2]=600
	UpgradePrice[3]=700
	UpgradePrice[4]=1500

	//The 9MM cannot be sold
	//UpgradeSellPrice[0]=150
	//UpgradeSellPrice[1]=337
	//UpgradeSellPrice[2]=412
	//UpgradeSellPrice[3]=450
	//UpgradeSellPrice[4]=750
}
