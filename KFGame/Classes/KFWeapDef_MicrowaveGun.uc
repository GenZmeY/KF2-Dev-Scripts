//=============================================================================
// KFWeapDef_Crovel
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_MicrowaveGun extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Beam_Microwave"

	BuyPrice=1500
	AmmoPricePerMag=100
	ImagePath="WEP_UI_Microwave_Gun_TEX.UI_WeaponSelect_MicrowaveGun"

	EffectiveRange=12

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
}
