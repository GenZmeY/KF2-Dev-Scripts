//=============================================================================
// KFWeapDef_HRG_Locust
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_Locust extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_Locust"

	BuyPrice=900
	AmmoPricePerMag=40
	ImagePath="wep_ui_hrg_locust_tex.UI_WeaponSelect_HRG_Locust"

	EffectiveRange=100

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}