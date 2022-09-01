//=============================================================================
// KFDT_Ballistic_HRG_Locust
//=============================================================================
// HRG Locust bullet impact
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_HRG_Locust extends KFDamageType
	abstract
	hidedropdown;

defaultproperties
{
	ModifierPerkList(0)=class'KFPerk_Survivalist'

	WeaponDef=class'KFWeapDef_HRG_Locust'
}
