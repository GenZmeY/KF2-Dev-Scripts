//=============================================================================
// KFProj_HansHEGrenade_Halloween
//=============================================================================
// Halloween variant of Hans' explosive grenade
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFProj_HansHEGrenade_Halloween extends KFProj_HansHEGrenade;

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'Halloween_ZED_Hans_EMIT.FX_HHans_Grenade_Explosive_Proj_01' 

	// explosion
	Begin Object Name=ExploTemplate0
		ExplosionEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.Ghost_Grenade_Explosion'
	End Object
}