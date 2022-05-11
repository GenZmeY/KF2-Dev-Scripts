//=============================================================================
// KFImpactEffectManager
//=============================================================================
// Manages impact effects
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFImpactEffectManager extends Actor
	native(Effect)
	config(Game);

/** Information about hit effects for this class */
var KFImpactEffectInfo DefaultImpactEffects;

var float MaxImpactEffectDistance;
var float MaxDecalRangeSq;

var bool bAlignToSurfaceNormal;
var bool bSuppressSounds;

/** Decal Limits */
var globalconfig int MaxImpactEffectDecals;

/** Decal manager */
var transient DecalManager ImpactEffectDecalManager;

/** Data for most recent impact sound played (used to limit sounds) */
var transient AkEvent 	MostRecentImpactSound;
var transient vector 	MostRecentImpactLocation;
var transient float		MostRecentImpactTime;
var transient int		NumDuplicateImpactSounds;

/** Proximity within which to limit impact sounds */
var float MinRepeatImpactSoundDistanceSq;
/** Duration within which to limit impact sounds */
var float MinRepeatImpactSoundInterval;
/** Number of duplicate sounds to allow within time period and proximity */
var int MaxDuplicateImpactSounds;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Create decal managers
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// Wound decal manager
		ImpactEffectDecalManager = Spawn(class'DecalManager', self,, vect(0,0,0), rot(0,0,0));
		ImpactEffectDecalManager.MaxActiveDecals = MaxImpactEffectDecals;
	}
}

/**
 * Spawn any effects that occur at the impact point.  It's called from the pawn.
 */
simulated function PlayImpactEffects(const vector HitLocation, const Pawn EffectInstigator, optional vector HitNormal, optional KFImpactEffectInfo CustomImpactEffects, optional bool bWorldImpactsOnly)
{
	local vector NewHitLoc, FireDir, WaterHitNormal;
	local Actor HitActor;
	local TraceHitInfo HitInfo;
	local MaterialImpactEffect ImpactEffect;
    local KFImpactEffectInfo ImpactEffectInfo;
	local KFFracturedMeshActor FracturedMeshActor;
	local int i;
	local bool bIsWeaponHandlingEffects;

	// allow optional parameter to override impact effects
	ImpactEffectInfo = (CustomImpactEffects != None) ? CustomImpactEffects : DefaultImpactEffects;	

	if( IsZero(HitNormal) && EffectInstigator != none )
	{
	   HitNormal = Normal(EffectInstigator.Location - HitLocation);
	}
	FireDir = -1 * HitNormal;

	if ( ImpactEffectInfo.BulletWhipSnd != None )
	{
		CheckBulletWhip(FireDir, HitLocation, EffectInstigator, ImpactEffectInfo);
	}

	if ( EffectInstigator != None && ImpactEffectIsRelevant(EffectInstigator, HitLocation, false, MaxImpactEffectDistance) )
	{
		if ( ImpactEffectInfo.bMakeSplash && !WorldInfo.bDropDetail && EffectInstigator.IsPlayerPawn() && EffectInstigator.IsLocallyControlled() )
		{
			HitActor = Trace(NewHitLoc, WaterHitNormal, HitLocation, EffectInstigator.Location+EffectInstigator.eyeheight*vect(0,0,1), true,, HitInfo, TRACEFLAG_PhysicsVolumes | TRACEFLAG_Bullet);
			if ( WaterVolume(HitActor) != None )
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffectInfo.SplashEffectTemplate, NewHitLoc, rotator(vect(0,0,1)));
			}
		}

		bIsWeaponHandlingEffects = KFPawn(EffectInstigator).MyKFWeapon != none ? KFPawn(EffectInstigator).MyKFWeapon.bForceHandleImpacts : false;

		// Trace using the Instigator as the TraceOwner so that melee weapons don't collide with Instigator
		HitActor = EffectInstigator.Trace(NewHitLoc, HitNormal, (HitLocation - (HitNormal * 32)), HitLocation + (HitNormal * 32), !bWorldImpactsOnly,, HitInfo, TRACEFLAG_Bullet);
		if( HitActor != none && HitActor.bCanBeDamaged && HitActor.IsA('Pawn') && !bIsWeaponHandlingEffects )
		{
			return; // pawns impacts are handled by the pawn (see PlayTakeHitEffects)
		}

		// handle "partial" remote client simulation for fracture meshes
		if ( WorldInfo.NetMode == NM_Client && HitActor != none && HitActor.bCanBeDamaged && !EffectInstigator.IsLocallyControlled() )
		{
			FracturedMeshActor = KFFracturedMeshActor(HitActor);
			if ( FracturedMeshActor != None )
			{
				FracturedMeshActor.SimulateRemoteHit(HitLocation, HitNormal, HitInfo);
			}
		}

		// figure out the impact sound to use
		GetImpactEffect(HitInfo.PhysMaterial, ImpactEffect, ImpactEffectInfo);

		// Allow phys materials to override default impact effects
		if( ImpactEffect == ImpactEffectInfo.DefaultImpactEffect
			&& HitInfo.PhysMaterial != none )
		{
			// Impact effect override
			if( HitInfo.PhysMaterial.ImpactEffect != none )
			{
				ImpactEffect.ParticleTemplate = HitInfo.PhysMaterial.ImpactEffect;
			}				

			// Sound override
			if( HitInfo.PhysMaterial.ImpactSound != none )
			{
				ImpactEffect.Sound = HitInfo.PhysMaterial.ImpactSound;
			}
		}

		// Pawns handle their own hit effects
		if ( HitActor != None &&
			 ((Pawn(HitActor) == None || bIsWeaponHandlingEffects ) || Vehicle(HitActor) != None) &&
			 AllowImpactEffects(HitActor, HitLocation, HitNormal) )
		{
			if (ImpactEffect.ParticleTemplate != None)
			{
				if (!bAlignToSurfaceNormal)
				{
					HitNormal = normal(FireDir - ( 2 *  HitNormal * (FireDir dot HitNormal) ) ) ;
				}
				WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffect.ParticleTemplate, HitLocation, rotator(HitNormal), HitActor);
			}

			//Spawn any global emitters
			for (i = 0; i < ImpactEffectInfo.GlobalImpactEffectEffects.Length; ++i)
			{
				WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffectInfo.GlobalImpactEffectEffects[i], HitLocation, rotator(HitNormal), HitActor);
			}

			if ( !WorldInfo.bDropDetail
				&& (Pawn(HitActor) == None)
				&& (EffectInstigator != none && VSizeSQ(EffectInstigator.Location - HitLocation) < MaxDecalRangeSq)
				&& (((WorldInfo.GetDetailMode() != DM_Low) && !class'Engine'.static.IsSplitScreen()) || (EffectInstigator.IsLocallyControlled()
				&& EffectInstigator.IsHumanControlled())) )
			{
				SpawnImpactDecal(HitLocation, HitNormal, HitActor, ImpactEffect, HitInfo);
			}
		}

		if( ShouldPlayImpactSound(ImpactEffect.Sound, HitLocation) )
		{
			PlayImpactSound(EffectInstigator, HitLocation, FireDir, HitActor, ImpactEffect.Sound, ImpactEffectInfo);
		}
	}
}

/** Determines whether impact sound should be played or not, based on most recent impact */
simulated function bool ShouldPlayImpactSound( AkBaseSoundObject HitSound, vector HitLocation )
{
	if( HitSound == none || bSuppressSounds )
	{
		return false;
	}

	// limit the number of duplicate impact effects within a short period of time and close proximity
	if( (HitSound != MostRecentImpactSound) ||
		(VSizeSq(HitLocation - MostRecentImpactLocation) > MinRepeatImpactSoundDistanceSq) ||
		(`TimeSince(MostRecentImpactTime) > MinRepeatImpactSoundInterval) )
	{
		MostRecentImpactSound = AkEvent(HitSound);
		MostRecentImpactLocation = HitLocation;
		MostRecentImpactTime = WorldInfo.TimeSeconds;
		NumDuplicateImpactSounds = 0;

		return true;
	}

	if( NumDuplicateImpactSounds + 1 <= MaxDuplicateImpactSounds )
	{
		NumDuplicateImpactSounds += 1;
		return true;
	}

	return false;
}

/**
 * Play sound effect associated with this impact
 */
simulated function PlayImpactSound(Pawn EffectInstigator, vector HitLocation, vector FireDir, Actor HitActor, AkBaseSoundObject ImpactSound, KFImpactEffectInfo ImpactEffectInfo)
{
	local Vehicle V;

	V = Vehicle(HitActor);
	// if hit a vehicle controlled by the local player, always play it full volume
	if (V != None && V.IsLocallyControlled() && V.IsHumanControlled())
	{
		PlayerController(V.Controller).PlaySoundBase(ImpactSound, true);
	}
	else
	{
		PlaySoundBase(ImpactSound, true,,, HitLocation);
	}
}

simulated function CheckBulletWhip(vector FireDir, vector HitLocation, Pawn EffectInstigator, KFImpactEffectInfo ImpactEffectInfo)
{
	local KFPlayerController PC;

	ForEach LocalPlayerControllers(class'KFPlayerController', PC)
	{
		if ( !WorldInfo.GRI.OnSameTeam(Owner,PC) )
		{
			PC.CheckBulletWhip(ImpactEffectInfo.BulletWhipSnd, EffectInstigator.Location, FireDir, HitLocation, EffectInstigator);
		}
	}
}

/**
 * Play sound effect associated with this impact
 */
simulated function SpawnImpactDecal(vector HitLocation, vector HitNormal, Actor HitActor, const out MaterialImpactEffect ImpactEffect, optional TraceHitInfo HitInfo )
{
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalMaterialsLength;
	local float DecalSize, DecalThickness;

	// if we have a decal to spawn on impact
	DecalMaterialsLength = ImpactEffect.DecalMaterials.length;
	if( DecalMaterialsLength > 0 )
	{
		MI = ImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
		if( MI != None )
		{
			DecalSize = RandRange(ImpactEffect.DecalMinSize, ImpactEffect.DecalMaxSize);			
			if ( ShouldExtendDecalThickness(HitActor) ) 
			{
				DecalThickness = DecalSize * 2.2f;
			}
			else
			{
				DecalThickness = 10.f;
			}

			if( MaterialInstanceTimeVarying(MI) != none )
			{
				// hack, since they don't show up on terrain anyway
				if ( Terrain(HitActor) == None )
				{
					MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
					MITV_Decal.SetParent( MI );

					ImpactEffectDecalManager.SpawnDecal( MITV_Decal, HitLocation, rotator(-HitNormal), DecalSize,
						DecalSize, DecalThickness, false, (ImpactEffect.bNoDecalRotation) ? 0.f : (FRand() * 360.0), HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex );
					//here we need to see if we are an MITV and then set the burn out times to occur
					MITV_Decal.SetScalarStartTime( ImpactEffect.DecalDissolveParamName, ImpactEffect.DecalDuration );
				}
			}
			else
			{
				ImpactEffectDecalManager.SpawnDecal( MI, HitLocation, rotator(-HitNormal), DecalSize,
					DecalSize, DecalThickness, false, (ImpactEffect.bNoDecalRotation) ? 0.f : (FRand() * 360.0), HitInfo.HitComponent, true, false, HitInfo.BoneName, HitInfo.Item, HitInfo.LevelIndex, ImpactEffect.DecalDuration );
			}
		}
	}
}

/**
 * On landscape with certain non-uniform scale (e.g. Zed Landing) decals have clipping
 * issues.  Increasing the thickness, and therefore bounds, resolves the issue at a
 * small perf cost.
 */
static function bool ShouldExtendDecalThickness(Actor HitActor)
{
	// using actor flags to reject most actors before casting		
	if ( HitActor != None && !HitActor.bGameRelevant && HitActor.bStatic && HitActor.IsA('Landscape') ) 
	{
		return true;
	}

	return false;
}

/**
 * Returns the impact sound that should be used for hits on the given physical material
 * UnrealScript returns structs by value, so use an out param instead
*/
static simulated function GetImpactEffect(PhysicalMaterial HitMaterial, out MaterialImpactEffect out_ImpactEffect, KFImpactEffectInfo ImpactEffectInfo )
{
	local int i;
	local KFPhysicalMaterialProperty PhysicalProperty;

	if (HitMaterial != None)
	{
		PhysicalProperty = KFPhysicalMaterialProperty(HitMaterial.GetPhysicalMaterialProperty(class'KFPhysicalMaterialProperty'));
	}

	// @todo: add alt fire
    if (ImpactEffectInfo != none)
    {
        if (PhysicalProperty != None)
        {
            i = ImpactEffectInfo.ImpactEffects.Find('MaterialType', PhysicalProperty.MaterialType);
            if (i != -1)
            {
                out_ImpactEffect = ImpactEffectInfo.ImpactEffects[i];
                return;
            }
        }

        out_ImpactEffect = ImpactEffectInfo.DefaultImpactEffect;
    }
}

simulated function bool AllowImpactEffects(Actor HitActor, vector HitLocation, vector HitNormal)
{
	return !WorldInfo.bDropDetail && (PortalTeleporter(HitActor) == None);
}

/*********************************************************************************************
 * Melee impacts
 *********************************************************************************************/

/**
 * Called by ProcessMeleeHit to spawn effects
 * Network: Local Player and Server
 */
simulated function PlayMeleeImpact(ImpactInfo Impact, Pawn EffectInstigator, KFWeapon InstigatorWeap, AkEvent HitWorldSound, AkEvent HitPawnSound, CameraShake Shake)
{
	// @todo: implement this using per material settings (see PlayImpactEffects)
}

defaultproperties
{
	DefaultImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Light_bullet_impact'

	MaxImpactEffectDistance=4000.0
	bAlignToSurfaceNormal=true
	MaxDecalRangeSQ=400000000.0

	// Actor
	bTickIsDisabled=true

	MinRepeatImpactSoundDistanceSq=10000 // 1m
	MinRepeatImpactSoundInterval=0
	MaxDuplicateImpactSounds=0
}
