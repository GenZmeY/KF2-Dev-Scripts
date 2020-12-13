//=============================================================================
// KFWeapDef_Crovel
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_SW500 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Revolver_SW500"

	BuyPrice=750
	AmmoPricePerMag=25
	ImagePath="WEP_UI_SW_500_TEX.UI_WeaponSelect_SW500"

	EffectiveRange=50

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
