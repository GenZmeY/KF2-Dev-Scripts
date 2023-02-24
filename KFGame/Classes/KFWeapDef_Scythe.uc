//=============================================================================
// KFWeapDef_Scythe
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Scythe extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Edged_Scythe"

	BuyPrice=1500
	ImagePath="WEP_UI_Scythe_TEX.UI_WeaponSelect_Scythe"

	IsPlayGoHidden=true;

	EffectiveRange=5
	
	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125
	
	SharedUnlockId=SCU_Scythe

}
