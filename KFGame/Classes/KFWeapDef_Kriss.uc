//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Kriss extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_SMG_Kriss"

	BuyPrice=1500
	AmmoPricePerMag=31 //35
	ImagePath="WEP_UI_KRISS_TEX.UI_WeaponSelect_KRISS"

	EffectiveRange=70

    UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}