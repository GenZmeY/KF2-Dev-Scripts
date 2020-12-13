//=============================================================================
// KFDT_Ballistic_HRG_Vampire_BloodBallImpact
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Vampire_BloodBallImpact extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	return false;
}

defaultproperties
{
	DoT_Type=DOT_NONE

	EffectGroup=FXG_Toxic

	PoisonPower=10 //20
	StumblePower=40 //100
	KnockdownPower=0 //25
	GunHitPower=40 //100

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_HRG_Vampire'
}
