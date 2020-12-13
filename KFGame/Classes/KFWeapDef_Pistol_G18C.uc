//=============================================================================
// KFWeapDef_Pistol_G18C
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
// Fernando Ferrando @ Saber Interactive
//=============================================================================
class KFWeapDef_Pistol_G18C extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_G18C"

	BuyPrice=750 //Weapon Price
	AmmoPricePerMag=38//24

	EffectiveRange=30 //70 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) range

	ImagePath="WEP_UI_G18C_TEX.UI_WeaponSelect_G18C"

	UpgradePrice[0]=1500
	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_G18C
}