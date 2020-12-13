//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Eviscerator extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Eviscerator"

	BuyPrice=1600
	AmmoPricePerMag=75
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_SawbladeShooter"

	EffectiveRange=25

	SecondaryAmmoMagSize=10
	SecondaryAmmoMagPrice=10

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
