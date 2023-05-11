//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Shotgun_S12 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Shotgun_S12"

	BuyPrice=1500
	AmmoPricePerMag=40 //110 //82
	ImagePath="WEP_UI_Saiga12_TEX.UI_WeaponSelect_Saiga12"

	IsPlayGoHidden=true;

	SecondaryAmmoMagSize=1
  	SecondaryAmmoMagPrice=30 //13
	

	EffectiveRange=30

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_Saiga12

}
