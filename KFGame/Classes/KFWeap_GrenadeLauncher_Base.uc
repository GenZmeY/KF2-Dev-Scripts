//=============================================================================
// KFWeap_GrenadeLauncher_Base
//=============================================================================
// Base for grenade launchers
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_GrenadeLauncher_Base extends KFWeapon
	native;

/** How long to wait after firing to force reload */
var()			float		ForceReloadTime;

/*********************************************************************************************
 * @name	Trader Stats
 *********************************************************************************************/

/** Allows weapon to calculate its own damage for display in trader */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float CalculatedDamage;
	local class<KFDamageType> DamageType;
	local GameExplosion ExplosionInstance;

	ExplosionInstance = class<KFProjectile>(default.WeaponProjectiles[DEFAULT_FIREMODE]).default.ExplosionTemplate;

	CalculatedDamage = default.InstantHitDamage[DEFAULT_FIREMODE] + ExplosionInstance.Damage;

	DamageType = class<KFDamageType>(ExplosionInstance.MyDamageType);
	if( DamageType != none && DamageType.default.DoT_Type != DOT_None )
	{
		CalculatedDamage += (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (CalculatedDamage * DamageType.default.DoT_DamageScale);
	}

	return CalculatedDamage;
}

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Explosive;
}

simulated function float GetForceReloadDelay()
{
	return fMax( ForceReloadTime - FireInterval[CurrentFireMode], 0.f );
}

/** Return true if this weapon should play the fire last animation for this shoot animation */
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
    if( SpareAmmoCount[GetAmmoType(FireModeNum)] == 0 )
    {
        return true;
    }

    return false;
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName( bool bTacticalReload )
{
	if ( AmmoCount[0] > 0 )
	{
		// Disable half-reloads for now.  This can happen if server gets out
		// of sync, but choosing the wrong animation will just make it worse!
		`warn("Grenade launcher reloading with non-empty mag");
	}

	return bTacticalReload ? ReloadEmptyMagEliteAnim : ReloadEmptyMagAnim;
}

/**
 * See Pawn.ProcessInstantHit
 * @param DamageReduction: Custom KF parameter to handle penetration damage reduction
 */
simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum )
{
	local KFPerk InstigatorPerk;

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.UpdatePerkHeadShots( Impact, InstantHitDamageTypes[FiringMode], ImpactNum );
	}
	
	super.ProcessInstantHitEx( FiringMode, Impact, NumHits, out_PenetrationVal, ImpactNum );
}

DefaultProperties
{
	ForceReloadTime=0.3
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFireAndReload

	// Doesn't use CSHD so FALSE is needed to avoid some rare, but tricky sync issues.
	// Since these weapons have a mag size of 1 client ammo is not that useful anyway.
	bAllowClientAmmoTracking=true

	// Aim Assist
	AimCorrectionSize=0.f
}
