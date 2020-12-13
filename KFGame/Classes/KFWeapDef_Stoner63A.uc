//=============================================================================
// KFWeapDef_Stoner63A
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Stoner63A extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_LMG_Stoner63A"

	BuyPrice=1500
	AmmoPricePerMag=70 //70
	ImagePath="wep_ui_stoner63a_tex.UI_WeaponSelect_Stoner"

	EffectiveRange=68

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}