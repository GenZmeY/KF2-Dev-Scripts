//=============================================================================
// KFExplosionActorReplicated
//=============================================================================
// Explosion actor that can spawned serverside and replicated
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFExplosionActorReplicated extends KFExplosionActor
	notplaceable;

/** Should be a serializable object, like in the level or something (as is the case for kismet actions). */
var transient private repnotify GameExplosion		ExploTemplateRef;

/** Overrides ExplosionTemplate.bIgnoreInstigator */
var bool bIgnoreInstigator;

/** Does a trace to find hitactor, hitlocation, hitnormal for directional explosions */
var bool bTraceForHitActorWhenDirectionalExplosion;

/** If true, spawn particle system at the weapon muzzle even actor location is not */
var bool bSyncParticlesToMuzzle;

/** Which type of projectile explosion we will emulate. */
//var transient private repnotify class<GearProj_ExplosiveBase>	ProjExploToEmulate;

replication
{
	if (bNetDirty)
		ExploTemplateRef, bTraceForHitActorWhenDirectionalExplosion, bSyncParticlesToMuzzle;
}

simulated event ReplicatedEvent(Name VarName)
{
	if (VarName == 'ExploTemplateRef')
	{
		Explode(ExploTemplateRef, ExplosionDirection);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function Explode(GameExplosion NewExplosionTemplate, optional vector ExploDirection)
{
	local vector MyHitLocation, MyHitNormal;
	local vector TraceStart, TraceDest;
	Local Actor MyHitActor;

    // Trace to find where the directional blast would hit for applying effects
    if( NewExplosionTemplate.bDirectionalExplosion && bTraceForHitActorWhenDirectionalExplosion )
    {
    	TraceStart = Location;
    	TraceDest = Location + (ExploDirection * NewExplosionTemplate.DamageRadius);

    	MyHitActor = Trace(MyHitLocation, MyHitNormal, TraceDest, TraceStart, TRUE,,, TRACEFLAG_Bullet);

        if( MyHitActor != none )
        {
            NewExplosionTemplate.HitLocation = MyHitLocation;
            NewExplosionTemplate.HitNormal = MyHitNormal;
        }
    }

	if (Role == ROLE_Authority)
	{
		ExploTemplateRef = NewExplosionTemplate;
	}

	if ( bIgnoreInstigator )
	{
		NewExplosionTemplate.bIgnoreInstigator = true;
	}

	super.Explode(NewExplosionTemplate, ExploDirection);

	LifeSpan = FMax(LifeSpan, 1.0);
}

/** Use actor rotation instead of HitNormal! */
simulated function SpawnExplosionParticleSystem(ParticleSystem Template)
{
	if ( bSyncParticlesToMuzzle )
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(Template, GetMuzzleEffectLocation(), Rotation, None);
	}
	else
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(Template, Location, Rotation, None);
	}
}

simulated function SetSyncToMuzzleLocation(bool bSync)
{
	bSyncParticlesToMuzzle = bSync;
}

/** 
 * Get muzzle location for currently equipped weapon
 * This is visual only! Damage is done from ExplosionActor location
 */
simulated function vector GetMuzzleEffectLocation()
{
	local KFPawn KFP;

	if ( WorldInfo.NetMode != NM_DedicatedServer && Instigator != None )
	{
		// Try third person attachment
	    if( !Instigator.IsFirstPerson() )
	    {
	    	KFP = KFPawn(Instigator);
	    	if ( KFP != None && KFP.WeaponAttachment != None )
	    	{
	        	return KFP.WeaponAttachment.GetMuzzleLocation(0);
	        }
	    }
		// Otherwise use first person muzzle
	    else if ( Instigator.Weapon != None )
	    {
	        return Instigator.Weapon.GetMuzzleLoc();
	    }
	}

	return Location;
}

defaultproperties
{
	bNetTemporary=true
	bAlwaysRelevant=TRUE
	RemoteRole=ROLE_SimulatedProxy
	bNetInitialRotation=TRUE

	bIgnoreInstigator=true
}
