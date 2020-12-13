//=============================================================================
// KFWeapDef_Seeker6
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Seeker6 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_RocketLauncher_Seeker6"

	BuyPrice=1500
	AmmoPricePerMag=55 //40
	ImagePath="WEP_UI_SeekerSix_TEX.UI_WeaponSelect_SeekerSix"

	EffectiveRange=100

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}