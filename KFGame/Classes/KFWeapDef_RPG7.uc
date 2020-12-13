//=============================================================================
// KFWeapDef_Crovel
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_RPG7 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_RocketLauncher_RPG7"

	BuyPrice=1500
	AmmoPricePerMag=30
	ImagePath="WEP_UI_RPG7_TEX.UI_WeaponSelect_RPG7"

	EffectiveRange=100

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
