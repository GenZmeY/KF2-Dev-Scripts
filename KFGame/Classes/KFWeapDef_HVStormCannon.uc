//=============================================================================
// KFWeapDef_HVStormCannon
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HVStormCannon extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HVStormCannon"

	BuyPrice=1400
	AmmoPricePerMag=40
	ImagePath="wep_ui_hvstormcannon_tex.UI_WeaponSelect_HVStormCannon"
	EffectiveRange=100

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_HVStormCannon
}