//=============================================================================
// KFWeapDef_Crovel
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_MedicSMG extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_SMG_Medic"

	BuyPrice=650
	AmmoPricePerMag=19 // 21
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_MedicSMG"

	EffectiveRange=70

	UpgradePrice[0]=600
	UpgradePrice[1]=700
	UpgradePrice[2]=1500

	UpgradeSellPrice[0]=450
	UpgradeSellPrice[1]=975
	UpgradeSellPrice[2]=2100
}
