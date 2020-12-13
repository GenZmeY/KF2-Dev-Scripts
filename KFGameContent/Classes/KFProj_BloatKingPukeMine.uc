//=============================================================================
// KFProj_BloatKingPukeMine
//=============================================================================
// Projectile class for bloat king puke mine
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFProj_BloatKingPukeMine extends KFProj_BloatPukeMine;

/** Validates a touch */
simulated function bool ValidTouch(Pawn Other)
{
	// only detonated when touched by enemies
	if (Other.GetTeamNum() == TeamNum || !Other.IsAliveAndWell())
	{
		return false;
	}

	// only detonate after landing
	if (Physics != PHYS_None)
	{
		return false;
	}

	// Make sure not touching through wall
	return FastTrace(Other.Location, Location, , true);
}

/** Capture damage so that human players can destroy the mine */
singular event TakeDamage(int inDamage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	// Don't blow up when fading out and don't let mines blow each other up, no matter what team
	if (bFadingOut || DamageCauser.class == class || DamageType == ExplosionTemplate.MyDamageType || Physics != PHYS_None)
	{
		return;
	}

	// only if damaged by enemy or himself
	if (Health > 0 && inDamage > 0 && InstigatedBy != none && (InstigatedBy.GetTeamNum() != TeamNum || InstigatedBy == InstigatorController))
	{
		Health -= inDamage;

		if (Health <= 0)
		{
			TriggerExplosion(Location, vect(0, 0, 1), none);
		}
	}
}

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'ZED_BloatKing_EMIT.FX_BloatKing_projectile_01'
	GroundFXTemplate=ParticleSystem'ZED_BloatKing_EMIT.FX_Bloatking_Mine_01'
	Begin Object Name=ExploTemplate0
		ExplosionEffects=KFImpactEffectInfo'ZED_BloatKing_ARCH.Bloatking_Mine_Explosion'
		Damage=18 //45 //30 //15
		DamageRadius=200	//450
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_BloatKingPukeMine'
		bIgnoreInstigator=false
	End Object
}