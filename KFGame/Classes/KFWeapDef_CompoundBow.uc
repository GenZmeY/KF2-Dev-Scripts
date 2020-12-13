//=============================================================================
// KFWeapDef_CompoundBow
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFWeapDef_CompoundBow extends KFWeaponDefinition
	abstract;

defaultproperties
{
	WeaponClassPath="KFGameContent.KFWeap_Bow_CompoundBow"

	BuyPrice=2000

	AmmoPricePerMag=16

	ImagePath="WEP_UI_CompoundBow_TEX.UI_WeaponSelect_Compound_Bow"

	EffectiveRange=80

	SharedUnlockId=SCU_CompoundBow
}

