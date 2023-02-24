//=============================================================================
// KFWeapDef_HRG_SonicGun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_SonicGun extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_SonicGun"

	BuyPrice=1100
	AmmoPricePerMag=65 //75
	ImagePath="WEP_UI_HRG_SonicGun_TEX.UI_WeaponSelect_HRG_SonicGun"

	IsPlayGoHidden=true;
	
	EffectiveRange=70

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}
