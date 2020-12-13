//=============================================================================
// KFDT_Piercing_KnifeStab_FieldMedic
//=============================================================================
// Stabbing damage type for Medic knife
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Piercing_KnifeStab_FieldMedic extends KFDT_Piercing_KnifeStab
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
	ModifierPerkList(0)=class'KFPerk_FieldMedic'
}