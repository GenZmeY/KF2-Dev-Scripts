//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Grenade_Medic extends KFWeaponDefinition
	abstract
	hidedropdown;

DefaultProperties
{
	/*WeaponClassPath="KFGameContent.KFWeap_Pistol_9mm"

	BuyPrice=0
	AmmoPricePerMag=10*/
	WeaponClassPath="KFGameContent.KFProj_MedicGrenade"
	ImagePath="ui_weaponselect_tex.UI_WeaponSelect_MedicGrenade"
}
