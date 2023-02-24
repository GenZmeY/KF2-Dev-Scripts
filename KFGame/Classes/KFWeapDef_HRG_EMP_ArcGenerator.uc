//=============================================================================
// KFWeapDef_MicrowaveRifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_EMP_ArcGenerator extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_EMP_ArcGenerator"

	BuyPrice=1500 //2000
	AmmoPricePerMag=110 //66
	ImagePath="WEP_UI_HRG_ArcGenerator_TEX.UI_WeaponSelect_HRG_ArcGenerator"

	IsPlayGoHidden=true;
	
	EffectiveRange=70

	UpgradePrice[0]=1500
	UpgradeSellPrice[0]=1125
}
