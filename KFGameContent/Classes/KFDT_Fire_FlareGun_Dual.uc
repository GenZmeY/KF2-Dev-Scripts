//=============================================================================
// KFDT_Fire_FlareGun
//=============================================================================
// Damage caused by heat and combustion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDT_Fire_FlareGun_Dual extends KFDT_Fire_FlareGun
	abstract;

defaultproperties
{
	ModifierPerkList.Empty
	ModifierPerkList(0)=class'KFPerk_Firebug'
    ModifierPerkList(1)=class'KFPerk_Gunslinger'
}