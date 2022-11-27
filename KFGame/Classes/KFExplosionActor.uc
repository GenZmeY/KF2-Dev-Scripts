//=============================================================================
// KFExplosionActor
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFExplosionActor extends GameExplosionActor
    dependson(KFImpactEffectInfo)
    dependson(KFLightPool);

/** Stores the ImpactEffect based on the PhysicalMaterial **/
var MaterialImpactEffect MyImpactEffect;

var byte NumPawnsKilled;

/** If < 1.f, reduces damage when stacked with other explosives of the same type */
var const float DamageScalePerStack;

/** Priority of this explosion's light in the pool */
var const LightPoolPriority ExplosionLightPriority;

/**
 * @todo break this up into the same methods that <Game>Weapon uses (SpawnImpactEffects, SpawnImpactSounds, SpawnImpactDecal) as they are all
 * orthogonal and so indiv subclasses can choose to have base functionality or override
 *
 * @param Direction     For bDirectionalExplosion=true explosions, this is the forward direction of the blast.
 * Overridden to add the ability to spawn fragments from the explosion
 **/
simulated function Explode(GameExplosion NewExplosionTemplate, optional vector Direction)
{
	local ParticleSystem ParticleTemplateOverride;
	local KFGameExplosion TemplateExplosion;

	TemplateExplosion = KFGameExplosion(NewExplosionTemplate);

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
    	// If we're not doing per material fx, grab the default
        if( !NewExplosionTemplate.bAllowPerMaterialFX && TemplateExplosion != none && TemplateExplosion.ExplosionEffects != none )
    	{
			ParticleTemplateOverride = TemplateExplosion.ExplosionEffects.DefaultImpactEffect.ParticleTemplate;
			if ( ParticleTemplateOverride != None )
			{
				NewExplosionTemplate.ParticleEmitterTemplate = ParticleTemplateOverride;
			}
    	}
	}

    super.Explode(NewExplosionTemplate, Direction);

    if( TemplateExplosion != none && TemplateExplosion.NumShards > 0 && TemplateExplosion.ShardClass != none )
    {
        SpawnShards(NewExplosionTemplate, TemplateExplosion.NumShards, TemplateExplosion.ShardClass);
    }

    // Register explosion light with lightpool
    if( ExplosionLight != none && ExplosionLight.bAttached && ExplosionLight.bEnabled )
    {
    	`LightPool.RegisterPointLight( ExplosionLight, ExplosionLightPriority );
    }
}

/** During explosion, spawn additional shard/shrapnel projectiles */
simulated function SpawnShards(GameExplosion NewExplosionTemplate, int NumShards, class<Projectile> ShardClass, optional int PitchShardMin=10, optional int PitchShardMax=35)
{
	local vector SpawnPos;
	local actor HitActor;
	local rotator rot;
	local int i;
	local Projectile NewChunk;
	local vector HitLocation, HitNormal;
	local int YawShardPosition;
	local int YawShardIncrement;

	// Disperse NumShards across 360 degrees, YawShardPosition is increased by this amount with each shard
	YawShardIncrement = 360 / NumShards;	 

	SpawnPos = NewExplosionTemplate.HitLocation + 10 * NewExplosionTemplate.HitNormal;

	HitActor = Trace(HitLocation, HitNormal, SpawnPos, NewExplosionTemplate.HitLocation, false);
	if (HitActor != None)
	{
		SpawnPos = HitLocation;
	}
	else
	{
		HitNormal = NewExplosionTemplate.HitNormal;
	}

	// Spawn the shards only on the server
	if ( Instigator != none && Instigator.Role == ROLE_Authority )
	{
		if(bDrawDebug)
		{
			DrawDebugLine(SpawnPos,SpawnPos + HitNormal * 1000.0,0,255,0,TRUE);
		}

		// Spawn the number of shards we need
		for (i = 0; i < NumShards; i++)
		{
			rot.Pitch = RandRange( PitchShardMin, PitchShardMax ) * DegToUnrRot;			
			YawShardPosition += YawShardIncrement;
			rot.Yaw = YawShardPosition * DegToUnrRot;
			
			NewChunk = Spawn(ShardClass,Instigator != none ? Instigator.Weapon : self,, SpawnPos, rot);

			if(bDrawDebug)
			{
				DrawDebugLine(SpawnPos,SpawnPos + normal(vector(rot)) * 500.0,255,0,0,TRUE);
			}

			if (NewChunk != None)
			{
				NewChunk.Init(vector(rot));
			}
		}
	}
}

/**
 * Internal.  Extract what data we can from the physical material-based effects system
 * and stuff it into the ExplosionTemplate.
 * Data in the physical material will take precedence.
 *
 * We are also going to be checking for relevance here as when any of these params are "none" / invalid we do not
 * play those effects in Explode().  So this way we avoid any work on looking things up in the physmaterial
 *
 */
simulated protected function UpdateExplosionTemplateWithPerMaterialFX(PhysicalMaterial PhysMaterial)
{
	// Set a default impact effect if there isn't a physical material
    if( PhysMaterial == none )
	{
        MyImpactEffect = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect;
	}
    else if( WorldInfo.MyImpactEffectManager != none ) // none on dedicated server
    {
        `ImpactEffectManager.GetImpactEffect(PhysMaterial, MyImpactEffect,KFGameExplosion(ExplosionTemplate).ExplosionEffects);
    }

    if( MyImpactEffect.ParticleTemplate != none )
    {
        ExplosionTemplate.ParticleEmitterTemplate = MyImpactEffect.ParticleTemplate;
    }
}

simulated function SpawnExplosionParticleSystem(ParticleSystem Template)
{
	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX && Template == none )
	{
	   Template = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect.ParticleTemplate;
	}

    WorldInfo.MyEmitterPool.SpawnEmitter(Template, Location, rotator(ExplosionTemplate.HitNormal), None);
}

simulated function SetSyncToMuzzleLocation(bool bSync)
{
	//empty in this class
}

simulated function SpawnExplosionDecal()
{
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalMaterialsLength;
	local float DecalSize, DecalThickness;
	local KFGameExplosion KFExplosionTemplate;

	if( WorldInfo.bDropDetail )
	{
		return;
	}

	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX )
	{
		KFExplosionTemplate = KFGameExplosion(ExplosionTemplate);
		if( KFExplosionTemplate == none || KFExplosionTemplate.ExplosionEffects == none )
		{
			return;
		}
		
	   	MyImpactEffect = KFExplosionTemplate.ExplosionEffects.DefaultImpactEffect;
	}

	// if we have a decal to spawn on impact
	DecalMaterialsLength = MyImpactEffect.DecalMaterials.length;
	if( DecalMaterialsLength > 0 )
	{
		MI = MyImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
		if( MI != None )
		{
			DecalSize = RandRange(MyImpactEffect.DecalMinSize, MyImpactEffect.DecalMaxSize);
            
            //Always extend decal thickness for explosions
            DecalThickness = DecalSize * 2.f;

			if( MaterialInstanceTimeVarying(MI) != none )
			{
					MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
					MITV_Decal.SetParent( MI );

            		WorldInfo.ExplosionDecalManager.SpawnDecal(MITV_Decal, ExplosionTemplate.HitLocation, rotator(-ExplosionTemplate.HitNormal), DecalSize, DecalSize, DecalThickness, FALSE,(MyImpactEffect.bNoDecalRotation) ? 0.f : (FRand() * 360.0) );
            		//here we need to see if we are an MITV and then set the burn out times to occur
            		MITV_Decal.SetScalarStartTime( MyImpactEffect.DecalDissolveParamName, MyImpactEffect.DecalDuration );
			}
			else
			{
				WorldInfo.ExplosionDecalManager.SpawnDecal( MI, ExplosionTemplate.HitLocation, rotator(-ExplosionTemplate.HitNormal), DecalSize, DecalSize, DecalThickness, true,
                    (MyImpactEffect.bNoDecalRotation) ? 0.f : (FRand() * 360.0),,,,,,, MyImpactEffect.DecalDuration );
			}
		}
	}
}

/**
  * Handle making pawns ignite, cringe or fall down from nearby explosions.  Server only.
  */
protected function SpecialPawnEffectsFor(GamePawn VictimPawn, float VictimDist)
{
	//local KFPawn_Monster KFM;
	//local class<KFDamageType> KFDT;
	local KFPawn_Human HumanVictim;
	local KFGameExplosion KFExplosionTemplate;

	// Victim may have just been killed by damage - if so don't cringe
	if (VictimPawn.bRespondToExplosions && VictimPawn.Health > 0)
	{
		// Disabled for now.  All effects are played via the AfflictionHandler
	}

	if ( VictimPawn != none )
	{
		if ( VictimPawn.bPlayedDeath && KFPawn( VictimPawn ).TimeOfDeath == WorldInfo.TimeSeconds )
		{
			NumPawnsKilled++;
		}
	}

	// support for healing humans on explosion impact
	HumanVictim = KFPawn_Human(VictimPawn);
	KFExplosionTemplate = KFGameExplosion(ExplosionTemplate);
	if (HumanVictim != none && KFExplosionTemplate != none && KFExplosionTemplate.HealingAmount > 0)
	{
		HumanVictim.HealDamage(KFExplosionTemplate.HealingAmount, InstigatorController, KFExplosionTemplate.HealingDamageType);
	}
}

protected function bool KnockdownPawn(BaseAiPawn Victim, float DistFromExplosion)
{
	local KFPawn KFP;

	KFP = KFPawn(Victim);
	if (KFP != None)
	{
		// Note we double the Radius.  This ensures the applied force at the furthest possible
		// knockdown is 50% of the KnockdownStrength.  Going ragdoll with zero explosion force tends to feel odd.
		KFP.LastHitBy = InstigatorController; // so proper kill credit is given if this knocks the Pawn outside the world
		KFP.Knockdown(, vect(1,1,1), Location, ExplosionTemplate.DamageRadius * 2.0, ExplosionTemplate.KnockDownStrength);
	}

	return (Victim.Physics == PHYS_RigidBody);
}

protected function bool StumblePawn(BaseAiPawn Victim, float DistFromExplosion)
{
	local KFPawn KFP;

	KFP = KFPawn(Victim);
	if (KFP != None)
	{
		KFP.DoSpecialMove(SM_Stumble,,, class'KFSM_Stumble'.static.PackBodyHitSMFlags(KFP, Normal(KFP.Location - ExplosionTemplate.HitLocation)));
		return KFP.IsDoingSpecialMove(SM_Stumble);
	}

	return false;
}

protected simulated function bool DoExplosionDamage(bool bCauseDamage, bool bCauseEffects)
{
	local bool bReturn;

	NumPawnsKilled = 0;
	bReturn = super.DoExplosionDamage( bCauseDamage, bCauseEffects );

	// Maybe trigger a dramatic event for multi kills with explosives
	if( Role == ROLE_Authority && KFGameInfo(WorldInfo.Game) != none )
	{
		if( NumPawnsKilled >= 4 )
		{
			KFGameInfo(WorldInfo.Game).DramaticEvent(0.05);
		}
        else if ( NumPawnsKilled >= 2 )
        {
            KFGameInfo(WorldInfo.Game).DramaticEvent(0.03);
        }
	}
	return bReturn;
}

simulated function DrawDebug()
{
	local Color C;
	local float Angle;
	local float ClotKillRadius, HalfFalloffRadius;
	local float SafeDamage, SafeDamageFallOffExponent;

    FlushPersistentDebugLines();

	// debug spheres
	if (ExplosionTemplate.bDirectionalExplosion)
	{
		C.R = 255;
		C.G = 128;
		C.B = 16;
		C.A = 255;
		Angle = ExplosionTemplate.DirectionalExplosionAngleDeg * DegToRad;

		DrawDebugCone(Location, ExplosionDirection, ExplosionTemplate.DamageRadius, Angle, Angle, 8, C, TRUE);
	}
	else
	{
		SafeDamage = ExplosionTemplate.Damage > 0.f ? ExplosionTemplate.Damage : 1.f;
		SafeDamageFallOffExponent = ExplosionTemplate.DamageFalloffExponent > 0.f ? ExplosionTemplate.DamageFalloffExponent : 1.f;

		DrawDebugSphere(Location, ExplosionTemplate.DamageRadius, 10, 255, 128, 16, TRUE);

		ClotKillRadius = ExplosionTemplate.DamageRadius * (1.f - FClamp((100 / SafeDamage) ** (1 / SafeDamageFallOffExponent), 0.f, 1.f));

		DrawDebugSphere(Location, ClotKillRadius, 10, 255, 0, 0, TRUE);

		HalfFalloffRadius = ExplosionTemplate.DamageRadius * (1.f - FClamp((0.5 ** (1.f / SafeDamageFallOffExponent)), 0.f, 1.f));
		
		DrawDebugSphere( Location, HalfFalloffRadius, 10, 255, 63, 0, true );
	}
}

/** Add number of stacks and return damage scale between 0-1 */
simulated function float CalcStackingDamageScale(KFPawn Victim, float MinDamageInterval)
{
	local int i, ExistingIdx;
	local float DamageMod;
	local GameExplosionActor OtherExplosion;
	local ExplosiveStackInfo NewStackInfo;

	if ( DamageScalePerStack >= 1.f || Victim == None )
	{
		return 1.f; // no modifier
	}

	DamageMod = 1.f;
	ExistingIdx = INDEX_NONE;

	for (i = Victim.RecentExplosiveStacks.Length-1; i >= 0; --i)
	{
		OtherExplosion = Victim.RecentExplosiveStacks[i].Explosion;

		// If self, keep index for later
		if ( OtherExplosion == self )
		{
			ExistingIdx = i;
		}
		
		if ( OtherExplosion == None )
		{
			// cleanup destroyed actors
			Victim.RecentExplosiveStacks.Remove(i, 1);

			// We need to decrement ExistingIdx if it was a higher index than the one we just removed
			if( ExistingIdx != INDEX_NONE && ExistingIdx > i )
			{
				--ExistingIdx;
			}
		}
		else if ( OtherExplosion.ExplosionTemplate.MyDamageType == ExplosionTemplate.MyDamageType 
			&& `TimeSince(Victim.RecentExplosiveStacks[i].LastHitTime) < MinDamageInterval )
		{
			// found match!
			DamageMod *= DamageScalePerStack;
		}
	}

	// If damage mod is non-zero add a stack
	if ( DamageMod > 0.f )
	{
		if ( ExistingIdx != INDEX_NONE )
		{
			Victim.RecentExplosiveStacks[ExistingIdx].LastHitTime = WorldInfo.TimeSeconds;
		}
		else
		{
			NewStackInfo.Explosion = self;
			NewStackInfo.LastHitTime = WorldInfo.TimeSeconds;
			Victim.RecentExplosiveStacks.AddItem(NewStackInfo);
		}
	}

	return DamageMod;
}

/** Improved cone collision for pawns */
simulated protected function bool IsBehindExplosion(Actor A)
{
	local KFPawn P;
	local vector TorsoLoc;

	if (ExplosionTemplate.bDirectionalExplosion && !IsZero(ExplosionDirection))
	{
		if ( !Super.IsBehindExplosion(A) )
		{
			return FALSE;
		}

		// Extra collision cone at torso
		P = KFPawn(A);
		if ( P != None && P.TorsoBoneName != '' )
		{
			TorsoLoc = P.Mesh.GetBoneLocation(P.TorsoBoneName);
			return (ExplosionDirection dot Normal(TorsoLoc - Location)) < DirectionalExplosionMinDot;
		}
	}

	return FALSE;
}

/** Level was reset without reloading */
function Reset()
{
	Destroy();
}

defaultproperties
{
	//DurationOfDecal=24.0
	//DecalDissolveParamName="DissolveAmount"

	//ExplosionDecal=MaterialInstanceConstant'FX_Impacts_MAT.FX_Grenade_Impact_DM'

	// Disable the RadialImpulseComponent.  Collision detection is hit & miss
	// and it fights with KFPawn Impulse system [aladenberger 1/24/2014]
	ExplosionLightPriority=LPP_High
	RadialImpulseComponent=None
	Components.Remove(ImpulseComponent0)

	DamageScalePerStack=1.f
}
