//=============================================================================
// KFWeapDef_SW500Dual_HRG
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_SW500Dual_HRG extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_Revolver_DualBuckshot"

	BuyPrice=1100
	AmmoPricePerMag=42
	ImagePath="WEP_UI_Dual_HRG_SW_500_TEX.UI_WeaponSelect_HRG_DualSW500"

	IsPlayGoHidden=true;

	EffectiveRange=15

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}
