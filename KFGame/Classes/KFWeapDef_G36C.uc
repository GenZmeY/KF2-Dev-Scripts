//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_G36C extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_AssaultRifle_G36C"

	BuyPrice=1600
	AmmoPricePerMag=36
	ImagePath="wep_ui_g36c_tex.UI_WeaponSelect_G36C" 

	EffectiveRange=70

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_G36C

}
