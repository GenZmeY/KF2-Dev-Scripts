//=============================================================================
// KFWeapDef_HRG_MedicMissile
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_MedicMissile extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_MedicMissile"

	BuyPrice=1600
	AmmoPricePerMag=25
	ImagePath="WEP_UI_HRG_MedicMissile_TEX.UI_WeaponSelect_HRG_MedicMissile"  

	IsPlayGoHidden=true;
	
	EffectiveRange=100

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}