//=============================================================================
// KFDT_Ballistic_HRG_BarrierRifle
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_HRG_BarrierRifle extends KFDT_Ballistic_AssaultRifle
	abstract
	hidedropdown;

defaultproperties
{
    KDamageImpulse=900
	KDeathUpKick=-300
	KDeathVel=100
	
	StumblePower=20
	GunHitPower=20

	WeaponDef=class'KFWeapDef_HRG_BarrierRifle'

	//Perk
	ModifierPerkList(0)=class'KFPerk_SWAT'
}