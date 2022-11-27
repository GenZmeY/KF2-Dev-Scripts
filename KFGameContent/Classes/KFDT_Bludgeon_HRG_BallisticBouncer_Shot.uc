//=============================================================================
// KFDT_Bludgeon_HRG_BallisticBouncer_Shot
//=============================================================================
// Balls hit hard
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_HRG_BallisticBouncer_Shot extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=400
	GunHitPower=300
	MeleeHitPower=150
	KnockdownPower=100
	
	WeaponDef=class'KFWeapDef_HRG_BallisticBouncer'
}
