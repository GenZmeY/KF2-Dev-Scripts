//=============================================================================
// KFDT_Piercing_HRG_Vampire_CrystalSpike
//=============================================================================
// Damage type for crystal spike (alternate fire) of HRG Vampire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_HRG_Vampire_CrystalSpike extends KFDT_Piercing
	abstract
	hidedropdown;

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{
	local class<KFDamageType> ToxicDT;

	ToxicDT = class'KFDT_Ballistic_Assault_Medic'.static.GetMedicToxicDmgType( DamageTaken, InstigatedBy );
  	if ( ToxicDT != None )
    {
        Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, ToxicDT);
    }
}

defaultproperties
{
	KDamageImpulse=1500
	KDeathUpKick=250
	KDeathVel=150

	StumblePower=250
	GunHitPower=100

	ModifierPerkList(0)=class'KFPerk_FieldMedic'
	WeaponDef=class'KFWeapDef_HRG_Vampire'
}
