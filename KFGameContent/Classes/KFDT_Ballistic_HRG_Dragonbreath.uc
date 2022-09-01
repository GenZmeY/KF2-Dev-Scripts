//=============================================================================
// KFDT_Ballistic_HRG_Dragonbreath
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Ballistic_HRG_Dragonbreath extends KFDT_Ballistic_Shotgun
	abstract
	hidedropdown;

// Damage type to use for the burning damage over time
var class<KFDamageType> BurnDamageType;

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	if( super.CanDismemberHitZone( InHitZoneName ) )
	{
		return true;
	}

	switch ( InHitZoneName )
	{
		case 'lupperarm':
		case 'rupperarm':
		case 'chest':
		case 'heart':
	 		return true;
	}

	return false;
}

/** Play damage type specific impact effects when taking damage */
static function PlayImpactHitEffects( KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator )
{
	// Play burn effect when dead
	if( P.bPlayedDeath && P.WorldInfo.TimeSeconds > P.TimeOfDeath )
	{
		default.BurnDamageType.static.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
		return;
	}

	super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
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
	GoreDamageGroup=DGT_Shotgun
	BloodSpread=0.4
	BloodScale=0.6

	KDamageImpulse=3500
	KDeathUpKick=800
	KDeathVel=650
	GibImpulseScale=1.0

	BurnPower=40
    StumblePower=40
	GunHitPower=50
	
	WeaponDef=class'KFWeapDef_HRG_Dragonbreath'

	BurnDamageType=class'KFDT_Fire_HRG_DragonsBreathDoT'

	EffectGroup=FXG_IncendiaryRound

	ModifierPerkList(0)=class'KFPerk_Firebug'
}
