//=============================================================================
// KFWeap_RifleBase
//=============================================================================
// Base class for rifles
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeap_RifleBase extends KFWeapon
	abstract;

/*********************************************************************************************
 * @name	Trader
 *********************************************************************************************/

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	if( default.FiringStatesArray[DEFAULT_FIREMODE] == 'WeaponFiring' || default.FiringStatesArray[DEFAULT_FIREMODE] == 'WeaponBurstFiring' )
	{
		return FT_Assault;
	}
	else // if( FiringStatesArray[DEFAULT_FIREMODE] == 'WeaponSingleFiring')
	{
		return FT_Rifle;
	}
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
	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=25.0 //15
	
	// Aim Assist
	AimCorrectionSize=40.f
}
