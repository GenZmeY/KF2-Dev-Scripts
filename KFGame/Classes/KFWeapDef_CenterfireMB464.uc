//=============================================================================
// KFWeapDef_CenterfireMB464
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_CenterfireMB464 extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Rifle_CenterfireMB464"

	BuyPrice=650
	AmmoPricePerMag=55 //50
	ImagePath="WEP_UI_Centerfire_TEX.UI_WeaponSelect_Centerfire"

	EffectiveRange=70

	UpgradePrice[0]=600
	UpgradePrice[1]=700
	UpgradePrice[2]=1500

	UpgradeSellPrice[0]=450
	UpgradeSellPrice[1]=975
	UpgradeSellPrice[2]=2100
}
