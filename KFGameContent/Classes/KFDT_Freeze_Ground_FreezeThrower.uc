//=============================================================================
// KFDT_Freeze_Ground_FreezeThrower
//=============================================================================
// A damage type for KFProj_GroundIce
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Freeze_Ground_FreezeThrower extends KFDT_Freeze_Ground
	abstract;

defaultproperties
{
	WeaponDef=class'KFWeapDef_FreezeThrower'
	FreezePower=6.25
	DoT_DamageScale=0.5
}