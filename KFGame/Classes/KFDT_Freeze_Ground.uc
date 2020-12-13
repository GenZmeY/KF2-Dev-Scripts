//=============================================================================
// KFDT_Freeze_Ground
//=============================================================================
// A damage type for KFProj_GroundIce
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Freeze_Ground extends KFDT_Freeze
	abstract
	hidedropdown;

defaultproperties
{
	FreezePower=6.25// 5.0  increased 25% last test felt to hard to freeze
	SnarePower=20.0//10
	DoT_DamageScale=0.5
}