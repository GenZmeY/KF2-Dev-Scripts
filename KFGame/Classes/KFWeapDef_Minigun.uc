//=============================================================================
// KFWeapDef_Minigun
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Minigun extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Minigun"

	BuyPrice=2000 //2500
	AmmoPricePerMag= 120//125 //175 //250
	ImagePath="WEP_UI_Minigun_TEX.UI_WeaponSelect_Minigun"

	IsPlayGoHidden=true;

	EffectiveRange=68 // Stoner63A Range

	SharedUnlockId=SCU_Minigun
}
