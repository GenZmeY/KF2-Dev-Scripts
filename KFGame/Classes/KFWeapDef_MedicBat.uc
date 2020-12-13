//=============================================================================
// KFWeapDef_MedicBat
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_MedicBat extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Blunt_MedicBat"

	BuyPrice=1200
	AmmoPricePerMag=85
	ImagePath="WEP_UI_Medic_Bat_TEX.UI_WeaponSelect_MedicBat"

	EffectiveRange=3

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}