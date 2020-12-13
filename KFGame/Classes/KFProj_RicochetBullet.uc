//=============================================================================
// KFProj_RicochetBullet
//=============================================================================
// Class for projectiles that can ricochet off the environment
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================

class KFProj_RicochetBullet extends KFProj_Bullet
	abstract;

var int                 BouncesLeft;
var float               DampingFactor;
var KFImpactEffectInfo  RicochetEffects;

/** return true if projectile actually bounced / was allowed to bounce */
simulated function bool Bounce( vector HitNormal, Actor BouncedOff )
{
    if( BouncesLeft > 0 )
    {
        Velocity = DampingFactor * (Velocity - 2.0*HitNormal*(Velocity dot HitNormal));
        BouncesLeft = BouncesLeft - 1;

        if( WorldInfo.NetMode != NM_DedicatedServer )
        {
            // do the impact effects
            `ImpactEffectManager.PlayImpactEffects(Location, Instigator, HitNormal, RicochetEffects, true );
        }

        // also done from ProcessDestructibleTouchOnBounce. update LastBounced to solve problem with bouncing rapidly between world/non-world geometry
        LastBounced.Actor = BouncedOff;
        LastBounced.Time = WorldInfo.TimeSeconds;

        return true;
    }

    return false;
}

defaultproperties
{
	bBounce=true
    bPushedByEncroachers=false

	// some reasonable defaults
	BouncesLeft=2
    DampingFactor=0.65
}
