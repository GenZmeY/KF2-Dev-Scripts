//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_AA12 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Shotgun_AA12"

	BuyPrice=1500
	AmmoPricePerMag=82 //110 //82
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_AA12"

	EffectiveRange=30

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
