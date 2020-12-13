//=============================================================================
// KFWeapDef_MosinNagant
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_MosinNagant extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Rifle_MosinNagant"

	BuyPrice=1100
	AmmoPricePerMag=42
	ImagePath="wep_ui_mosin_tex.UI_WeaponSelect_MosinNagant"

	EffectiveRange=90

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650

	SharedUnlockId=SCU_MosinNagant
}
