//=============================================================================
// KFDT_Toxic_ParasiteSeedExplosion
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Toxic_ParasiteSeedExplosion extends KFDT_Toxic_MedicGrenade
	abstract
	hidedropdown;

defaultproperties
{
	DoT_Type=DOT_Toxic
	DoT_Duration=6.5 //3.0
	DoT_Interval=0.5
	DoT_DamageScale=0.1

	KnockdownPower=30
	StumblePower=200
	GunHitPower=100
	PoisonPower=80.f

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	ModifierPerkList(1)=class'KFPerk_SharpShooter'

	WeaponDef=class'KFWeapDef_ParasiteImplanter'
}
