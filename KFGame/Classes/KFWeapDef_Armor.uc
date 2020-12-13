//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Armor extends KFWeaponDefinition
	abstract
	hidedropdown;

static function string GetItemLocalization(string KeyName)
{
	return Localize("Armor", KeyName, "KFGameContent");	
}

DefaultProperties
{
	//@todo: these can be set by the trader without needing a WeaponDef class
	AmmoPricePerMag=3
	ImagePath="UI_TraderMenu_TEX.UI_WeaponSelect_Armor"
}
