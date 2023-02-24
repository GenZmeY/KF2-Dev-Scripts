//=============================================================================
// KFWeapDef_HRGWinterbite
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRGWinterbite extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_HRGWinterbite"

	BuyPrice=325
	AmmoPricePerMag=13 //12
	ImagePath="WEP_UI_HRG_Winterbite_Item_TEX.UI_WeaponSelect_HRG_Winterbite"

	IsPlayGoHidden=true;
	
	EffectiveRange=50

	UpgradePrice[0]=600
	UpgradePrice[1]=700
	UpgradePrice[2]=1500

	UpgradeSellPrice[0]=450
	UpgradeSellPrice[1]=975
	UpgradeSellPrice[2]=2100
}
