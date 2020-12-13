//=============================================================================
// KFExplosion_PlayerBloatPukeMine
//=============================================================================
// Explosion info for player-controlled bloat puke mine
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFExplosion_PlayerBloatPukeMine extends KFExplosionActor;

simulated function SpawnExplosionParticleSystem( ParticleSystem Template )
{
	local ParticleSystemComponent PSC;

	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX && Template == none )
	{
	   Template = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect.ParticleTemplate;
	}

    PSC = WorldInfo.MyEmitterPool.SpawnEmitter(Template, Location, rotator(ExplosionTemplate.HitNormal), None);

    // Show the crater effect if we're not in midair
    if( PSC != none )
    {
    	if( FastTrace(Location - vect(0,0,50), Location,, true) )
    	{
    		// Turn off
	    	PSC.SetFloatParameter( 'FX_Crater', 0.f );
    	}
    	else
    	{
    		// Turn on
	    	PSC.SetFloatParameter( 'FX_Crater', 1.0f );
    	}
    }
}

defaultproperties
{
}