//=============================================================================
// KFWeapDef_HuskCannon
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_HuskCannon extends KFWeaponDefinition
    abstract;

DefaultProperties
{
    WeaponClassPath="KFGameContent.KFWeap_HuskCannon"

    BuyPrice=1500
    AmmoPricePerMag=125
    ImagePath="WEP_UI_HuskCannon_TEX.UI_WeaponSelect_HuskCannon"


    EffectiveRange=60

	UpgradePrice[0]=1500

    UpgradeSellPrice[0]=1125
}