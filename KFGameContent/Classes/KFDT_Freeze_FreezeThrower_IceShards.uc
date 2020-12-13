//=============================================================================
// KFDT_Freeze_Ground_FreezeThrower
//=============================================================================
// A damage type for KFProj_FreezeThrower_IceShards
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Freeze_FreezeThrower_IceShards extends KFDT_Freeze
	abstract;

defaultproperties
{
	WeaponDef=class'KFWeapDef_FreezeThrower'
	FreezePower=0
	StumblePower=25
}