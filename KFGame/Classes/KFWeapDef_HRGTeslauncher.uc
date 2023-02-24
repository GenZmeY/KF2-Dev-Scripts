//=============================================================================
// KFWeapDef_HRGTeslauncher
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//	-Brooks Butler
//=============================================================================
class KFWeapDef_HRGTeslauncher extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_AssaultRifle_HRGTeslauncher"
	
	BuyPrice=1500
	AmmoPricePerMag=62 //30
	ImagePath="WEP_UI_HRG_Teslauncher_TEX.UI_WeaponSelect_HRG_Teslauncher"

	IsPlayGoHidden=true;

	EffectiveRange=68

	SecondaryAmmoMagSize=1
	SecondaryAmmoMagPrice=15 //13

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
