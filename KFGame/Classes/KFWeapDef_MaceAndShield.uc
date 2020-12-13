//=============================================================================
// KFWeapDef_MaceAndShield
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_MaceAndShield extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Blunt_MaceAndShield"
	
	BuyPrice=1600
	ImagePath="WEP_UI_Shield_Melee_TEX.UI_WeaponSelect_MaceShield"
	EffectiveRange=3

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}