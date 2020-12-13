//=============================================================================
// KFWeapDef_HRGScorcher
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
// - Roberto Moreno (Saber Interactive)
//=============================================================================
class KFWeapDef_HRGScorcher extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_HRGScorcher"

	BuyPrice=1000 //1100 //750
	AmmoPricePerMag= 12 //14
	ImagePath="WEP_UI_HRGScorcher_Pistol_TEX.UI_WeaponSelect_HRGScorcher"

	EffectiveRange=100 // Based on comment Slightly less than  M79 Grenade Launcher

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}
