//=============================================================================
// KFDT_Explosive_HRG_Locust
//=============================================================================
// Explosive damage type for the HRG Locust
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFDT_Explosive_HRG_Locust extends KFDT_Explosive
	abstract
	hidedropdown;

// Damage type to use for the damage over time effect
var class<KFDamageType> DoTDamageType;

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage(KFPawn Victim, int DamageTaken, optional Controller InstigatedBy)
{
    if (Victim.Controller == InstigatedBy)
	{
        return;
	}

	if (default.DoTDamageType.default.DoT_Type != DOT_None)
	{
		Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.DoTDamageType);
	}
}

defaultproperties
{
	//Perk
	ModifierPerkList(0)=class'KFPerk_Survivalist'
	WeaponDef=class'KFWeapDef_HRG_Locust'

    DoTDamageType=class'KFDT_Toxic_HRG_Locust'

	bCausesFracture=false
	bCanPlayDeadHitEffects=false
}
