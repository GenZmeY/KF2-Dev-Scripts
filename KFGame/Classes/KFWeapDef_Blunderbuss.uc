//=============================================================================
// KFWeapDef_Blunderbuss
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFWeapDef_Blunderbuss extends KFWeaponDefinition
	abstract;

defaultproperties
{
	WeaponClassPath="KFGameContent.KFWeap_Pistol_Blunderbuss"

	BuyPrice=1500

	AmmoPricePerMag=39

	ImagePath="WEP_UI_Blunderbuss_TEX.UI_WeaponSelect_BlunderBluss"

	EffectiveRange=95 // Based on comment Slightly less than  M79 Grenade Launcher

	UpgradePrice[0]=1500

	UpgradeSellPrice[0]=1125

	SharedUnlockId=SCU_Blunderbuss
}

