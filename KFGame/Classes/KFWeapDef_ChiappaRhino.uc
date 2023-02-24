//=============================================================================
// KFWeapDef_ChiappaRhino
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_ChiappaRhino extends KFWeaponDefinition
    abstract;

DefaultProperties
{
    WeaponClassPath="KFGameContent.KFWeap_Pistol_ChiappaRhino"

    BuyPrice=550
    AmmoPricePerMag=17
    ImagePath="wep_ui_chiapparhino_tex.UI_WeaponSelect_ChiappaRhinos"

	IsPlayGoHidden=true;


    EffectiveRange=50

    UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650

	SharedUnlockId=SCU_ChiappaRhino
}
