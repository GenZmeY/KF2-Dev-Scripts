//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Grenade_Gunslinger extends KFWeaponDefinition
	abstract
	hidedropdown;

DefaultProperties
{
	/*

	BuyPrice=0
	AmmoPricePerMag=10*/
	WeaponClassPath="KFGameContent.KFProj_NailBombGrenade"
	ImagePath="Wep_UI_Nailbomb_TEX.UI_WeaponSelect_GunslingerGrenade"
}
