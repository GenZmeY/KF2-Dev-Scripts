//=============================================================================
// KFWeapDef_DualBladed
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_DualBladed extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_DualBladed"

	BuyPrice=1200
	AmmoPricePerMag=76 //64
	ImagePath="WEP_UI_Dual_BladedPistol_TEX.UI_WeaponSelect_Dual_BladedPistol"

	EffectiveRange=50

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650

	SharedUnlockId=SCU_BladedPistol
}
