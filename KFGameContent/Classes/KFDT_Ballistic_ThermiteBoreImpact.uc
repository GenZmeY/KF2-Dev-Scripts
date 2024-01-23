//=============================================================================
// KFDT_Ballistic_ThermiteBoreImpact
//=============================================================================
// Rocket impact damage type for the Thermite rocket launcher
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_ThermiteBoreImpact extends KFDT_Ballistic_Shell
	abstract
	hidedropdown;

// Damage type to use for the burning damage over time
var class<KFDamageType> BurnDamageType;

static simulated function bool CanDismemberHitZone(name InHitZoneName)
{
	return false;
}

static simulated function bool CanDismemberHitZoneWhileAlive(name InHitZoneName)
{
    return false;
}

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{	
	// Overriden to specific a different damage type to do the burn damage over
	// time. We do this so we don't get shotgun pellet impact sounds/fx during
	// the DOT burning.
    if ( default.BurnDamageType.default.DoT_Type != DOT_None )
    {
        Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.BurnDamageType);
    }
}

defaultproperties
{
	KDamageImpulse=0
	KDeathUpKick=0
	KDeathVel=0

	BurnPower=50
	KnockdownPower=50
	StumblePower=350
	GunHitPower=300

	BurnDamageType=class'KFDT_Fire_ThermiteImpactDoT'

	SelfDamageReductionValue=0.05f //0.25f

	ModifierPerkList(0)=class'KFPerk_FireBug'

	WeaponDef=class'KFWeapDef_ThermiteBore'
}
