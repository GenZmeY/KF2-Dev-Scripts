//=============================================================================
// KFProj_Bullet
//=============================================================================
// Base class for small arms projectiles
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet extends KFProjectile
    native
	abstract;

/** Store the current scale of the ProjEffects for procedurally ramping them up/down */
var float ProjEffectsScale;

cpptext
{
    virtual void TickSpecial( FLOAT DeltaTime );
}

/**
 * Initialize the Projectile
 */
function Init(vector Direction)
{
    super.Init( Direction );

    // Scale lifespan by time dilation
    if( LifeSpan == default.LifeSpan && WorldInfo.TimeDilation < 1.f )
    {
        LifeSpan *= WorldInfo.TimeDilation;
    }
}

/** Call ProcessBulletTouch */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
    local KFPawn KFP;
    local bool bPassThrough, bNoPenetrationDmgReduction;
	local KFPerk CurrentPerk;
	local InterpCurveFloat PenetrationCurve;
	local KFWeapon KFW;

	bPassThrough = false;

	if (Other != Instigator)
	{
		if(IgnoreTouchActor == Other)
		{
			return;
		}

		if (!Other.bStatic && DamageRadius == 0.0)
		{
			// check/ignore repeat touch events
			if( CheckRepeatingTouch(Other) )
			{
				return;
			}

			KFW = KFWeapon(Instigator.Weapon);
			// Keep going if we need to keep penetrating
			if (KFW == none || KFW.GetInitialPenetrationPower(Instigator.FiringMode) > 0.0f)
			{
				if (PenetrationPower > 0 || PassThroughDamage(Other))
				{
					if (KFW != none)
					{
						CurrentPerk = KFW.GetPerk();
						if (CurrentPerk != none)
						{
							bNoPenetrationDmgReduction = CurrentPerk.IgnoresPenetrationDmgReduction();
						}

						PenetrationCurve = KFW.PenetrationDamageReductionCurve[Instigator.FiringMode];
						if (!bNoPenetrationDmgReduction)
						{
							Damage *= EvalInterpCurveFloat(PenetrationCurve, PenetrationPower / KFW.GetInitialPenetrationPower(Instigator.FiringMode));
						}
					}

					ProcessBulletTouch(Other, HitLocation, HitNormal);

					// Reduce penetration power for every KFPawn penetrated
					KFP = KFPawn(Other);
					if (KFP != none)
					{
						PenetrationPower -= KFP.PenetrationResistance;
					}

					if (PenetrationPower > 0)
					{
						bPassThrough = TRUE;
					}
				}
			}
			else
			{
				ProcessBulletTouch(Other, HitLocation, HitNormal);
			}
		}
        // handle water pass through damage/hitfx
        else if ( DamageRadius == 0.f && !Other.bBlockActors && Other.IsA('KFWaterMeshActor') )
        {
            if ( WorldInfo.NetMode != NM_DedicatedServer )
            {
                `ImpactEffectManager.PlayImpactEffects(HitLocation, Instigator,, ImpactEffects);
            }
            bPassThrough = TRUE;
        }

        if ( !bPassThrough )
        {
    		Super.ProcessTouch(Other, HitLocation, HitNormal);
        }
	}
}

/** Damage without stopping the projectile (see also Weapon.PassThroughDamage)*/
simulated function bool PassThroughDamage(Actor HitActor)
{
    // Don't stop this projectile for interactive foliage
	if ( !HitActor.bBlockActors && HitActor.IsA('InteractiveFoliageActor') )
	{
		return true;
	}

	return FALSE;
}

/**
 * Explode this Projectile
 */
simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	// If there is an explosion template do the parent version
	if ( ExplosionTemplate != None )
	{
		Super.TriggerExplosion(HitLocation, HitNormal, HitActor);
		return;
	}

	// otherwise use the ImpactEffectManager for material based effects
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
        `ImpactEffectManager.PlayImpactEffects(HitLocation, Instigator,, ImpactEffects);
	}
}



defaultproperties
{
	// TEMP: Set the speed really high so it looks like a instant fire, but it won't replicate properly at
	// this speed.  With a high ping it will spawn/destroy on the server and never get bNetInitial on the client
	MaxSpeed=50000.0
	Speed=50000.0

	LifeSpan=4.0f

	Damage=10
	DamageRadius=0

	bWaitForEffects=true
	ProjEffectsFadeOutDuration=0.25
	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true
	bRotationFollowsVelocity=true
	bNoReplicationToInstigator=true
	bUseClientSideHitDetection=true

	bCollideComplex=TRUE	// Ignore simple collision on StaticMeshes, and collide per poly (same as InstantFire)

    bAutoStartAmbientSound=true
    bStopAmbientSoundOnExplode=true
    bAmbientSoundZedTimeOnly=true

    AmbientSoundPlayEvent=AkEvent'WW_WEP_Bullet_FlyBys.Play_WEP_Bullet_Flyby_Small'
    AmbientSoundStopEvent=AkEvent'WW_WEP_Bullet_FlyBys.Stop_WEP_Bullet_Flyby_Small'

    ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Light_bullet_impact'

    Begin Object Class=AkComponent name=AmbientAkSoundComponent
        bStopWhenOwnerDestroyed=true
        bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.1f
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

    TouchTimeThreshhold=0.15
    bDamageDestructiblesOnTouch=true
}


