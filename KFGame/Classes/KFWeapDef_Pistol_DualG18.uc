//=============================================================================
// KFWeapDef_Pistol_DualG18
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
// Fernando Ferrando @ Saber Interactive
//=============================================================================
class KFWeapDef_Pistol_DualG18 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_DualG18"

	BuyPrice=1500 //Weapon Price
	AmmoPricePerMag=76//48

	EffectiveRange=30 //70 //Default Firemode (Automatic) & Altfire Firemode (Single Fire) range

	ImagePath="WEP_UI_Dual_G18C_TEX.UI_WeaponSelect_Dual_G18C"

	UpgradePrice[0]=1500
	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_G18C
}