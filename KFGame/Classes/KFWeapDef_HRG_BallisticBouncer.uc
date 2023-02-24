//=============================================================================
// KFWeapDef_HRG_BallisticBouncer
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_BallisticBouncer extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_BallisticBouncer"

	BuyPrice=900
	AmmoPricePerMag=40
	ImagePath="WEP_UI_HRG_BallisticBouncer_TEX.UI_WeaponSelect_HRG_BallisticBouncer"

	IsPlayGoHidden=true;

	EffectiveRange=70

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}