//=============================================================================
// KFWeapDef_RailGun
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_RailGun extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Rifle_RailGun"

	BuyPrice=1500
	AmmoPricePerMag=20 //25
	ImagePath="WEP_UI_RailGun_TEX.UI_WeaponSelect_Railgun"

	EffectiveRange=100

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
