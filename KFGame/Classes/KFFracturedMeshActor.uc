//=============================================================================
// KFFracturedMeshActor
//=============================================================================
// A custom FracturedStaticMeshActor with basic replication support, so
// these actors can have blocking collision turned on/off in multiplayer 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFFracturedMeshActor extends FracturedStaticMeshActor
	native(Effect)
	showcategories(Navigation);

/** type of networking to use */
var() EDestructibleRepType ReplicationMode;

/** Amount of damage this actor can take before fully collapsing */
var()			int		TotalHealth;
var transient 	int 	DefaultTotalHealth;

/** Light brightness material parameter for this subobject */
var()  MaterialLightParamMod			MaterialLightParams;

/** When health reaches zero, should spawn FracturedMeshParts */
var() bool bSpawnPartsWhenDestroyed;

/** These damage types do increase damage */
var const array< class<DamageType> > VulnerableDamageType;
/** The amount to scale damage if vulnerable */
var const byte VulnerableMultiplier;

var repnotify	transient bool	bHasBeenDestroyed;
var repnotify	transient bool	bHasLostChunk;

replication
{
	if ( bNetDirty )
		bHasBeenDestroyed, bHasLostChunk;
}

/** Called when a variable with the property flag "RepNotify" is replicated */
simulated event ReplicatedEvent(name VarName)
{
	if ( VarName == nameof(bHasBeenDestroyed) )
	{
		if( bHasBeenDestroyed )
		{
			BreakOffAllFragments();
		}
	}
	else if ( VarName == nameof(bHasLostChunk) )
	{
		if( bHasLostChunk )
		{
			SetLoseChunkReplacementMaterial();
		}
	}
}

/*
 * Set network role based on type setting
 */
simulated event PreBeginPlay()
{
	if (WorldInfo.NetMode == NM_Client)
	{
		// on the client, set role to Authority if we're a clientside only KActor
		Role = (ReplicationMode == RT_ClientSide) ? ROLE_Authority : ROLE_SimulatedProxy;
	}
	else
	{
		// on the server, set role to SimulatedProxy (i.e. replicate it) only if not clientside
		RemoteRole = (ReplicationMode == RT_ClientSide) ? ROLE_None : ROLE_SimulatedProxy;
	}

	DefaultTotalHealth = TotalHealth;

	Super.PreBeginPlay();
}

/** TakeDamage will hide/spawn chunks when they get shot. */
simulated event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local vector HitDir;
	local vector HitNormal;

	if ( bHasBeenDestroyed )
	{
		return;
	}

	if ( HitInfo.HitComponent == None || HitInfo.Item == INDEX_None )
	{
		// Perform trace to retrieve hit info
		if ( Momentum == vect(0,0,0) )
		{
			Momentum = Location - HitLocation;
		}
		// push trace line in both directions to fix projectiles missing [aladenberger 2/5/2014]
		HitDir = Normal(Momentum);
		TraceComponent(HitLocation, HitNormal, FracturedStaticMeshComponent, HitLocation+50*HitDir, HitLocation-50*HitDir,, HitInfo, true);
	}

	if ( IsVulnerableTo(DamageType) )
	{
		Damage *= VulnerableMultiplier;
	}

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	if ( Role == ROLE_Authority )
	{
		TotalHealth -= Damage;
		if ( TotalHealth <= 0 )
		{
			BreakOffAllFragments();
		}
	}
}

/** If returns true, the destructible is vulnerable to this damage type damage */
function bool IsVulnerableTo(class<DamageType> DT)
{
	local int Idx;

	for (Idx = 0; Idx < VulnerableDamageType.length; ++Idx)
	{
		if ( ClassIsChildOf(DT, VulnerableDamageType[Idx]) )
		{
			return true;
		}
	}

	return false;
}

/** Overriden for replicated FractureMeshes and bHasLostChunk */
simulated function bool FractureEffectIsRelevant( bool bForceDedicated, Pawn EffectInstigator, out byte bWantPhysChunksAndParticles )
{
	local bool bResult;

	// If this is a replicated FractureMesh set bForceDedicated (works on dedicated/listen)
	// This will force bHasLostChunk to be properly updated when the actor takes damage
	if ( RemoteRole == ROLE_SimulatedProxy && !bHasLostChunk )
	{
		bResult = Super.FractureEffectIsRelevant(true, EffectInstigator, bWantPhysChunksAndParticles);

		// Update bWantPhysChunksAndParticles since super won't do this when bForceDedicated is set
		if( bResult && `TimeSince(LastRenderTime) > 0.5 )
		{
			bWantPhysChunksAndParticles = 0;
		}

		return bResult;
	}

	return Super.FractureEffectIsRelevant(bForceDedicated, EffectInstigator, bWantPhysChunksAndParticles);
}

/** Override for replication */
simulated event SetLoseChunkReplacementMaterial()
{
	Super.SetLoseChunkReplacementMaterial();

	if( !bHasLostChunk )
	{
		bHasLostChunk = true;

		if( WorldInfo.NetMode != NM_Client )
		{
			bNetDirty = true;
			bForceNetUpdate = true;
		}
	}
}

/** Break off all pieces in one go.  Also, handles network play (e.g. collision) */
simulated function BreakOffAllFragments(optional vector InVelocity)
{
	local array<byte> FragmentVis;
	local int i, NumPartsHidden;
	local vector SpawnDir;
	local FracturedStaticMesh FracMesh;
	local FracturedStaticMeshPart FracPart;
	local float PartScale;
	local bool bWantPhysChunksAndParticles;

	// Dirty actor for reset
	bHasBeenDirtied = true;

	// network
	bHasBeenDestroyed = true;
	bForceNetUpdate = true;

	// turn off all collision at once - only do this if actor is replicated!
	if ( ReplicationMode != RT_ClientSide )
	{
		SetCollision(,false);
	}
	// also disable rigid body collision
	FracturedStaticMeshComponent.SetBlockRigidBody(false);

	bWantPhysChunksAndParticles = bSpawnPartsWhenDestroyed && ActorEffectIsRelevant(None, false);
	FracMesh = FracturedStaticMesh(FracturedStaticMeshComponent.StaticMesh);

	// Iterate over all visible fragments spawning them
	FragmentVis = FracturedStaticMeshComponent.GetVisibleFragments();
	for(i=0; i<FragmentVis.length; i++)
	{
		// If this is a currently-visible, non-core fragment, spawn it off.
		if((FragmentVis[i] != 0) && (i != FracturedStaticMeshComponent.GetCoreFragmentIndex()) && FracturedStaticMeshComponent.IsFragmentDestroyable(i))
		{
			if ( bWantPhysChunksAndParticles && FracMesh.bSpawnPhysicsChunks && WorldInfo.GetDetailMode() > DM_Low && !WorldInfo.bDropDetail )
			{
				SpawnDir = FracturedStaticMeshComponent.GetFragmentAverageExteriorNormal(i);
				PartScale = FracMesh.ExplosionPhysicsChunkScaleMin + FRand() * (FracMesh.ExplosionPhysicsChunkScaleMax - FracMesh.ExplosionPhysicsChunkScaleMin);
				// Spawn part- inherit this actors velocity
				FracPart = SpawnPart(i, (0.5 * SpawnDir * FracMesh.ChunkLinVel) + Velocity + InVelocity, 0.5 * VRand() * FracMesh.ChunkAngVel, PartScale, TRUE);

				if(FracPart != None)
				{
					// When something explodes we disallow collisions between all those parts.
					FracPart.FracturedStaticMeshComponent.SetRBCollidesWithChannel(RBCC_FracturedMeshPart, FALSE);
				}
			}

			NumPartsHidden++;
			FragmentVis[i] = 0;
		}
	}

	// switch to lose chunk material if we haven't already
	SetLoseChunkReplacementMaterial();

	if ( bWantPhysChunksAndParticles && NumPartsHidden > 0 )
	{
		PlayBreakOffAllParticles(FracMesh);
	}

	// Update the visibility of the actor being spawned off of
	FracturedStaticMeshComponent.SetVisibleFragments(FragmentVis);

	if( ExplosionFractureSound != none )
	{
		PlaySoundBase( ExplosionFractureSound );
	}
}

/** Make sure that when pieces break off the lost chunk material is applied */
simulated event BreakOffPartsInRadius( vector Origin, float Radius, float RBStrength, bool bWantPhysChunksAndParticles )
{
	super.BreakOffPartsInRadius( Origin, Radius, RBStrength, bWantPhysChunksAndParticles );

	SetLoseChunkReplacementMaterial();
}

/** Play effects - copied from Super.TakeDamage */
simulated function PlayBreakOffAllParticles(FracturedStaticMesh FracMesh)
{
	local ParticleSystem EffectPSys;
	local Box MeshBox;

	// Look for override first
	if(OverrideFragmentDestroyEffects.length > 0)
	{
		// Pick randomly
		EffectPSys = OverrideFragmentDestroyEffects[Rand(OverrideFragmentDestroyEffects.length)];
	}
	// No override array, try the mesh
	else if(FracMesh.FragmentDestroyEffects.length > 0)
	{
		EffectPSys = FracMesh.FragmentDestroyEffects[Rand(FracMesh.FragmentDestroyEffects.length)];
	}

	// If we have an effect and a manager - spawn it
	if(EffectPSys != None && WorldInfo.MyFractureManager != None)
	{
		MeshBox.Min = (FracturedStaticMeshComponent.Bounds.Origin - FracturedStaticMeshComponent.Bounds.BoxExtent);
		MeshBox.Max = (FracturedStaticMeshComponent.Bounds.Origin + FracturedStaticMeshComponent.Bounds.BoxExtent);
		WorldInfo.MyFractureManager.SpawnChunkDestroyEffect(EffectPSys, MeshBox, vect(0,0,0), FracMesh.FragmentDestroyEffectScale, FracturedStaticMeshComponent);
	}
}

/** Called on client when a PlayImpactEffects trace from another player hits this FracturedMesh */
simulated function SimulateRemoteHit(vector HitLocation, vector Momentum, const out TraceHitInfo HitInfo)
{
	// If !bHasLostChunk then the server probably didn't do any damage (e.g. Medic Dart) and therefore we shouldn't
	// switch to LoseChunkReplacementMaterial.  If it's already cracked knocking out an extra chunk is harmless
	if ( bHasLostChunk )
	{
		TakeDamage(0, None, HitLocation, Momentum, class'KFDamageType', HitInfo);
	}
}

/** Level was reset without reloading */
simulated function Reset()
{
	if( !bHasBeenDirtied )
	{
		return;
	}

	super.Reset();

	// Network
	bHasBeenDestroyed = false;
	bHasLostChunk = false;
	bForceNetUpdate = true;
	bNetDirty = true;

	// Re-enable collision
	if ( ReplicationMode != RT_ClientSide )
	{
		SetCollision( ,true );
	}

	// Reset total health (health for total destruction)
	TotalHealth = DefaultTotalHealth;
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.Ambientcreatures'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	RemoteRole=ROLE_None

	// network
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=true
	NetUpdateFrequency=0.1

	TotalHealth=5000
	bSpawnPartsWhenDestroyed=true

	// Suppress sound warning
	bHasShownMissingSoundWarning=true

	// Default multiplier if we are vulnerable to any damage types
	VulnerableMultiplier=6

	// We want chunks to disappear no matter where you are in the map
	FractureCullMaxDistance=100000.0
}
