//=============================================================================
// KFWeap_ShotgunBase
//=============================================================================
// Base class for a shotgun weapon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeap_ShotgunBase extends KFWeapon
	abstract;

/** Spawn projectile is called once for each shot pellet fired */
simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local KFPerk InstigatorPerk;

	if (CurrentFireMode == GRENADE_FIREMODE)
	{
		return Super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
	}

	InstigatorPerk = GetPerk();
	if (InstigatorPerk != none)
	{
		Spread[CurrentFireMode] = default.Spread[CurrentFireMode] * InstigatorPerk.GetTightChokeModifier();
	}

	return super.SpawnAllProjectiles(KFProjClass, RealStartLoc, AimDir);
}

simulated function ApplyKickMomentum(float Momentum, float FallingMomentumReduction)
{
	local vector UsedKickMomentum;

	if (Instigator != none )
	{
		UsedKickMomentum.X = -Momentum;

		if( Instigator.Physics == PHYS_Falling  )
		{
			UsedKickMomentum = UsedKickMomentum >> Instigator.GetViewRotation();
			UsedKickMomentum *= FallingMomentumReduction;

			NotifyShotgunJump();
		}
		else
		{
			UsedKickMomentum = UsedKickMomentum >> Instigator.Rotation;
			UsedKickMomentum.Z = 0;
		}

		Instigator.AddVelocity(UsedKickMomentum,Instigator.Location,none);
	}
}

simulated function NotifyShotgunJump()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Instigator.Controller);
	if (KFPC != none)
	{
		KFPC.SetShotgunJump(true);
	}
}

/*********************************************************************************************
 * @name	Trader
 *********************************************************************************************/

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Shotgun;
}

defaultproperties
{
	NumPellets(DEFAULT_FIREMODE)=7
	NumPellets(ALTFIRE_FIREMODE)=7

	Spread(DEFAULT_FIREMODE)=0.07
	Spread(ALTFIRE_FIREMODE)=0.07

	// BASH_FIREMODE - Waiting on animations
	InstantHitDamage(BASH_FIREMODE)=20.0

	// Animation
	bHasFireLastAnims=true

	// Aim Assist
	AimCorrectionSize=0.f
}


