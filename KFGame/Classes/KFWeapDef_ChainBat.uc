//=============================================================================
// KFWeapDef_ChainBat
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_ChainBat extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Blunt_ChainBat"
	
	BuyPrice=850
	ImagePath="Wep_UI_ChainBat_TEX.UI_WeaponSelect_RRChainbat"

	EffectiveRange=2

	UpgradePrice[0]=600
	UpgradePrice[1]=700
	UpgradePrice[2]=1500

	UpgradeSellPrice[0]=450
	UpgradeSellPrice[1]=975
	UpgradeSellPrice[2]=2100

	SharedUnlockId=SCU_ChainBat
}
