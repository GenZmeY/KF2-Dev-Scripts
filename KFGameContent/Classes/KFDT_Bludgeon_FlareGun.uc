//=============================================================================
// KFDT_Bludgeon_Colt1911
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_FlareGun extends KFDT_Bludgeon_RifleButt
	abstract
	hidedropdown;

DefaultProperties
{
	WeaponDef=class'KFWeapDef_FlareGun'
    ModifierPerkList(1)=class'KFPerk_Gunslinger'
	ModifierPerkList(2)=class'KFPerk_Sharpshooter'
}