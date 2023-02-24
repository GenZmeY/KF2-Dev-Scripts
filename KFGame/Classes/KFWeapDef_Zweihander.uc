//=============================================================================
// KFWeapDef_Crovel
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Zweihander extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Edged_Zweihander"
	
	BuyPrice=1300	
	ImagePath="WEP_UI_Zweihander_TEX.UI_WeaponSelect_Zweihander"

	IsPlayGoHidden=true;

	EffectiveRange=3

	SharedUnlockId=SCU_Zweihander

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650
}
