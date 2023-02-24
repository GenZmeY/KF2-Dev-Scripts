//=============================================================================
// KFWeapDef_G18
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_G18 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_SMG_G18"

	BuyPrice=1500
	AmmoPricePerMag=24
	ImagePath="WEP_UI_RiotShield_TEX.UI_WeaponSelect_RiotShield"

	IsPlayGoHidden=true;

	EffectiveRange=70

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_G18RiotShield
}