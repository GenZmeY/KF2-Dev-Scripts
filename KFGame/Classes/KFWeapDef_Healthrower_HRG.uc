//=============================================================================
// KFWeapDef_Healthrower_HRG
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Healthrower_HRG extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_Healthrower"

	BuyPrice=1000
	AmmoPricePerMag=70
	ImagePath="Wep_UI_HRG_Healthrower_TEX.UI_WeaponSelect_HRG_Healthrower"

	EffectiveRange=17

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}
