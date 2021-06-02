//=============================================================================
// KFWeapDef_ThermiteBore
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeapDef_ThermiteBore extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_RocketLauncher_ThermiteBore"

	BuyPrice=1500
	AmmoPricePerMag=78
	ImagePath="WEP_UI_Thermite_TEX.UI_WeaponSelect_Thermite"

	EffectiveRange=78

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_Thermite
}
