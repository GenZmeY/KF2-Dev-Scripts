//=============================================================================
// KFWeaponDefintion
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HRG_Stunner extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_HRG_Stunner"

	BuyPrice=1500
	AmmoPricePerMag=36 
    ImagePath="ui_weaponselect_tex.UI_WeaponSelect_AA12"

	IsPlayGoHidden=true;
	
	EffectiveRange=70

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
