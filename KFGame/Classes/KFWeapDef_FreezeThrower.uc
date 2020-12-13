//=============================================================================
// KFWeapDef_FreezeThrower
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_FreezeThrower extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Ice_FreezeThrower"

	BuyPrice=1100
	AmmoPricePerMag=45
	ImagePath="wep_ui_cryogun_tex.UI_WeaponSelect_Cryogun"

	EffectiveRange=17

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}