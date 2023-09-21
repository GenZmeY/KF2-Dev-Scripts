//=============================================================================
// KFDT_Dart_Toxic
//=============================================================================
// Toxic Dart DamageType
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Dart_Toxic extends KFDT_Toxic
	abstract
	hidedropdown;

/** Called when damage is dealt to apply additional instant damage */
static function ModifyInstantDamage( KFPawn Victim, out int DamageTaken, optional Controller InstigatedBy )
{
    class'KFDT_Dart_Toxic'.static.GetMedicToxicDmgType( DamageTaken, InstigatedBy );
}

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{
    local class<KFDamageType> ToxicDT;

    ToxicDT = class'KFDT_Dart_Toxic'.static.GetMedicToxicDmgType( DamageTaken, InstigatedBy );
    if ( ToxicDT != None )
    {
        Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, ToxicDT);
    }
}

/**
 * Allows medic perk to add poison damage 
*/

static function class<KFDamageType> GetMedicToxicDmgType( out int out_Damage, optional Controller InstigatedBy ) 
{
	local KFPerk InstigatorPerk;

	InstigatorPerk = KFPlayerController(InstigatedBy).GetPerk();
	if( InstigatorPerk == none || (!InstigatorPerk.IsToxicDmgActive() && !InstigatorPerk.IsZedativeActive()) )
	{
		return None;
	}	

	InstigatorPerk.ModifyToxicDmg( out_Damage );

	return InstigatorPerk.GetToxicDmgTypeClass();
}

defaultproperties
{
	WeaponDef=class'KFWeapDef_Healer'

	DoT_Type=DOT_None
	DoT_Duration=0.0
	DoT_Interval=0.0
	DoT_DamageScale=0.0

	PoisonPower=0.f
}
