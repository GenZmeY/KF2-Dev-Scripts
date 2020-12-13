//=============================================================================
// KFWeap_SMGBase
//=============================================================================
// Base class for SMGs
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeap_SMGBase extends KFWeapon
	abstract;

/*********************************************************************************************
 * @name	Trader
 *********************************************************************************************/

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_SMG;
}

DefaultProperties
{
	// BASH_FIREMODE
	InstantHitDamage(BASH_FIREMODE)=15.0
	
	// Aim Assist
	AimCorrectionSize=40.f
}
