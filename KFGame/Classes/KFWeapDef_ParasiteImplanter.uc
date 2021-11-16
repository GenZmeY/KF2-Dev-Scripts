//=============================================================================
// KFWeapDef_ParasiteImplanter
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_ParasiteImplanter extends KFWeaponDefinition
	abstract;

defaultproperties
{
	WeaponClassPath="KFGameContent.KFWeap_Rifle_ParasiteImplanter"
	ImagePath="wep_ui_parasiteimplanter_tex.UI_WeaponSelect_ParasiteImplanter"

	BuyPrice=1500
	AmmoPricePerMag=42
	EffectiveRange=90 

	UpgradePrice[0]=1500
	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_ParasiteImplanter
}
