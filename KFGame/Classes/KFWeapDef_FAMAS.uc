//=============================================================================
// KFWeapDef_FAMAS
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeapDef_FAMAS extends KFWeaponDefinition
	abstract;

defaultproperties
{
	WeaponClassPath="KFGameContent.KFWeap_AssaultRifle_FAMAS"

	BuyPrice=1200

	AmmoPricePerMag=25
	SecondaryAmmoMagPrice=15 //13
	SecondaryAmmoMagSize=6 // Num of bullets given (not magazines)

	ImagePath="WEP_UI_Famas_TEX.UI_WeaponSelect_Famas"

	EffectiveRange=67 // @TODO: ¿?¿?¿?

	UpgradePrice[0]=700
	UpgradePrice[1]=1500

	UpgradeSellPrice[0]=525
	UpgradeSellPrice[1]=1650

	SharedUnlockId=SCU_FAMAS
}
