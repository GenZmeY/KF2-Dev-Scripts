//=============================================================================
// KFProj_GroundIce
//=============================================================================
// Projectile class for ground ice from freeze thrower, etc
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFProj_GroundIce extends KFProjectile;

var() float DamageInterval;

/** Warns AI that this projectile has been fired */
function WarnAI( vector Direction )
{
	local KFPawn_Monster KFPM;
	local vector DangerPoint;

	DangerPoint = Location;

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM )
	{
        if( KFPM.MyKFAIC != none && KFPM.IsAliveAndWell() )
        {
        	// Distance check
 			if( VSizeSQ(KFPM.Location - Location) > 90000.f )
 			{
 				continue;
 			}

 			// Visibility check
 			if( `FastTracePhysX(Location, KFPM.Location) )
 			{
	        	// Scale danger point up to pawn's Z location
	        	DangerPoint.Z = KFPM.Location.Z;

		        // Tell the zed to evade away from the DangerPoint
		        KFPM.MyKFAIC.ReceiveLocationalWarning( DangerPoint, Location, self );
		    }
	    }
	}
}

simulated event ReplicatedEvent( name VarName )
{
	if( VarName == nameof( bHasExploded ) )
	{
		return; // This would trigger another explosion, we don't need to do it for the groundfire.
	}
	else
	{
		super.ReplicatedEvent( VarName );
	}
}

/**
 * Set the initial velocity and cook time
 */
simulated function PostBeginPlay()
{
	local KFPlayerReplicationInfo InstigatorPRI;

	// Checks if we want to swap the explosion effects
	if( AltExploEffects != none )
	{
		InstigatorPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
		if( InstigatorPRI != none )
		{
			bAltExploEffects = InstigatorPRI.bSplashActive;
		}
	}
	else
	{
		bAltExploEffects = false;
	}

	TriggerExplosion( Location, vector(Rotation), None );

	Super.PostBeginPlay();
}

/*********************************************************************************************
* Collision
********************************************************************************************* */
simulated event Touch( Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal )
{
	//Super(Projectile).Touch(Other, OtherComp, HitLocation, HitNormal);
}

simulated protected function PrepareExplosionActor(GameExplosionActor GEA)
{
	local KFExplosionActorLingering KFE_GroundFire;

	KFE_GroundFire = KFExplosionActorLingering( GEA );
	if( KFE_GroundFire != none )
	{
		KFE_GroundFire.Interval = DamageInterval;
	}
}

/**
 * Force the fire not to burn the instigator, since setting it in the default props is not working for some reason - Ramm
 */
simulated protected function PrepareExplosionTemplate()
{
	ExplosionTemplate.bIgnoreInstigator=true;

	// Swap the ExplosionTemplate's effect if necessary
	if( bAltExploEffects )
	{
		ExplosionTemplate.ExplosionEffects = AltExploEffects;
	}
}

defaultproperties
{
	PostExplosionLifetime=2.5

	bStopAmbientSoundOnExplode=false
    bAutoStartAmbientSound=true
    bAmbientSoundZedTimeOnly=false

	ExplosionActorClass=class'KFExplosion_GroundIce'

	AltExploEffects=none//KFImpactEffectInfo'WEP_Flamethrower_ARCH.GroundFire_Splash_Impacts'

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=5
		DamageRadius=180
		DamageFalloffExponent=1.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Freeze_Ground'
		// Don't freeze the guy with the freezethrower
        bIgnoreInstigator=true

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
	    ExplosionEffects=KFImpactEffectInfo'WEP_CryoGun_ARCH.GroundCryo_Impacts'
		ExplosionSound=none
		MomentumTransferScale=0
		bAllowPerMaterialFX=true

		// Camera Shake
		CamShake=none
	End Object
	ExplosionTemplate=ExploTemplate0

	DamageInterval=0.25f

	RemoteRole=ROLE_None
}