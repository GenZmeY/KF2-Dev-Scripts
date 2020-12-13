//=============================================================================
// KFWeapDef_Rifle_FrostShotgunAxe
//=============================================================================

//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Rifle_FrostShotgunAxe extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Rifle_FrostShotgunAxe"

	BuyPrice=1300 //1200
	AmmoPricePerMag=39 //36
	ImagePath="WEP_UI_Frost_Shotgun_Axe_TEX.UI_WeaponSelect_FrostGun"

	EffectiveRange=35

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650

	SharedUnlockId=SCU_FrostFang
}
