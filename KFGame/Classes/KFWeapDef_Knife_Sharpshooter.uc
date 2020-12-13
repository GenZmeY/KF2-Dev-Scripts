//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients). 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Knife_SharpShooter extends KFweapDef_Knife_Base
	abstract
	hidedropdown;

DefaultProperties
{
	WeaponClassPath="KFGameContent.KFWeap_Knife_Sharpshooter"
	ImagePath="WEP_UI_Sharpshooter_Knife_TEX.UI_WeaponSelect_SharpshooterKnife"
}
