//=============================================================================
// KFDestructibleActor
//=============================================================================
// Base class for all placeable destructibles
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFDestructibleActor extends Actor
	placeable
	//implements(Interface_NavMeshPathObject)
	native
	hidecategories(Physics, Debug, Object, Mobile)
	showcategories(Navigation);

/*********************************************************************************************
* Network
 ********************************************************************************************* */

enum EDestructibleRepType
{
	/** Normal (unique net channel) server-side replication */
	RT_ServerDefault,
	/** Use a single net channel to replicate many destructible actors */
	RT_ServerOptimized,
	/** Client-only, no blocking collision */
	RT_ClientSide,
};

var() EDestructibleRepType ReplicationMode;

struct native ReplicatedDamageModInfo
{
	var byte ObjIdx;
	var byte ModIdx;
	var bool bPartial;

	structdefaultproperties
	{
		ObjIdx=255
		ModIdx=255
	}
};

/** Packed dmg mod info for replication */
var repnotify ReplicatedDamageModInfo	ReplicatedDamageMods[16];

/** True if the destructible is fully shut down */
var repnotify bool  bShutDown;

/** simplified network damage state */
var transient byte	ReplicatedDamageFlags;

/*********************************************************************************************
* Damage
 ********************************************************************************************* */
/** The damage needed for a hit to be considered instakill */
var protected const int INSTAKILL_DAMAGE;
/** List of damage types that instantly destroy this object */
var() array<class<DamageType> >	InstaKillDamageType<AllowAbstract>;
/** List of damage types to always ignore */
var() array<class<DamageType> >	IgnoreDamageType<AllowAbstract>;
/** These damage types do increase damage */
var const array< class<DamageType> > VulnerableDamageType;
/** The amount to scale damage if vulnerable */
var const byte VulnerableMultiplier;

/** If true, ignores all damage */
var() protected bool            bIgnoreAllDamage;

/** If true, will ignore all damage done by players */
var() protected bool			bIgnorePlayerDamage;

/** If true, will take bump damage from AI, in addition to just players */
var() protected bool			bAllowBumpDamageFromAI;
var transient float				LastBumpCheckTime;

/** If bSelfDestructAll == TRUE for a damage mod, the object will be killed after this delay */
var() const float               SelfDestructAllDelay;

/** When destroyed, disable collision on this blocking volume (MUST have bSelfDestructAll=TRUE) */
var() const BlockingVolume		BlockingVolumeToDisable;

/** Force destroy these actors on SelfDestructAll.  Useful if we have nearby destructibles and need more precision than ExplosionMod */
var() const array<Actor>		DamageOtherActors<DisplayName=ActorsToDamageOnDestruct>;

/** Used to attach all of the components only once */
var transient bool				bComponentsSetUp;
/** Used to update physics bodies only once */
var transient bool				bInitRBPhysCalled;
/** If set, TakeRadiusDamage is being executed */
var transient bool				bIsRadiusDamage;
/** Used by reset code to determine if actor is dirtied */
var transient bool bAnyDamageModApplied;

/*********************************************************************************************
* Nav Mesh (DEPRECATED)
 ********************************************************************************************* */

//enum ENavMeshObjectState
//{
//	ENavMeshObjectState_None,
//	ENavMeshObjectState_ObstacleOnly,
//	ENavMeshObjectState_PathObjectOnly,
//	ENavMeshObjectState_BothObstacleAndPathObject,
//};
//
//var(Navigation) KFNavMeshObstacle_Destructible MyNavMeshObstacle;
//var(Navigation) KFNavMeshPathObject_Destructible MyNavMeshPathObject;
//
//var (Navigation) ENavMeshObjectState NavMeshObjectState;

/*********************************************************************************************
* Material Mods
 ********************************************************************************************* */

struct native MaterialReplaceMod
{
	var()	MaterialInterface	NewMaterial;

	/** Index in the Materials array to replace with NewMaterial when this action is activated. */
	var()	int					MaterialIndex;
};

struct native MaterialScalarParamMod
{
	var() MaterialInstanceConstant	MatInst;
	var() Name						ParamName;
	var() float						ScalarVal;
};

struct native MaterialTexParamMod
{
	var() MaterialInstanceConstant	MatInst;
	var() Name						ParamName;
	var() Texture					NewTexture;
};

struct native MaterialVectorParamMod
{
	var() MaterialInstanceConstant	MatInst;
	var() Name						ParamName;
	var() LinearColor				VectorVal;
};

struct native MaterialLightParamMod
{
	var() int						MatID;
	var() Name						ParamName;
	var() Light						LightActor;

	structdefaultproperties
	{
		ParamName=BrightnessMultiplier
	}
};

/*********************************************************************************************
* Physics actors (fragments)
 ********************************************************************************************* */

/** Parameters to define an actor spawn. */
struct native ActorSpawnParams
{
	/** Static mesh to use for physics object */
	var() StaticMesh				RigidBodyMesh;

	/** Lower bound of random initial linear vel */
	var() vector					MinLinearVel;
	/** Upper bound of random initial linear vel */
	var() vector					MaxLinearVel;

	/** Lower bound of random initial angular vel */
	var() vector					MinAngularVel;
	/** Upper bound of random initial angular vel */
	var() vector					MaxAngularVel;

	/** Collision type to use for spawned rigid body */
	var() ECollisionType			CollisionType;

	/** RBChannel to use for collision */
	var() ERBCollisionChannel		RBChannel;

	/** Positional offset for actor spawn loc.  Note this is relative to the subobject */
	var() vector					RelativeOffset;
	/** Rotational offset for actor spawn loc.  Note this is relative to the subobject  */
	var() rotator					RelativeRotation;
	/** How long before we forcibly destroy the spawned actor, in seconds.  <= 0 means don't destroy. */
	var() float						LifeTimeSeconds;
	/** Do not spawn if no local players are within this range */
	var() float                     MaxSpawnDist<EditCondition=!bReplicated>;

	/** (PERF WARNING) If set, the spawned KActor is network replicated */
	var() bool									bReplicated;
	/** Material changes */
	var() const array<MaterialReplaceMod>		MaterialReplacements;

	structdefaultproperties
	{
		LifeTimeSeconds=30.0f
		MaxSpawnDist=1500.f

		CollisionType=COLLIDE_NoCollision
		RBChannel=RBCC_EffectPhysics
	}
};

/*********************************************************************************************
* Effects
 ********************************************************************************************* */

struct native DestroyedEffectParams
{
	/** Emitters to spawn */
	var() ParticleSystem		ParticleEffect;
	/** Position offset for detroyed effect.  Note this is relative to the subobject  */
	var() vector				RelativeOffset;
	/** Rotational offset for destroyed effect.  Note this is relative to the subobject */
	var() rotator				RelativeRotation;
	/** Do not spawn if no local players are within this range */
	var() float                 MaxSpawnDist;

	/** reference to the spawned particle system */
	var transient ParticleSystemComponent PSC;

	structdefaultproperties
	{
		MaxSpawnDist=4000.f
	}
};

/** Contains data for an explosion to spawn upon damage */
struct native ExplosionMod
{
	/** Explosion archetype to spawn */
	var() KFGameExplosion		ExplosionTemplate;
	/** Explosion damage */
	var float                   Damage;
	/** Explosion damage radius */
	var float                   DamageRadius;
	/** Translation offset */
	var() vector                RelativeLocation;
	/** Rotation offset */
	var() rotator				RelativeRotation;
	/** The actor class to ignore for damage from this explosion **/
	var class<Actor>			ActorClassToIgnoreForDamage;

	structdefaultproperties
	{
		RelativeLocation=(Z=10)
	}
};

struct native SplashDamageParams
{
	var() float				BaseDamage;
	var() float				DamageRadius;
	var() class<DamageType>	DamageType<AllowAbstract>;
	/** Translation offset - useful when other sub objects are in the way */
	var() vector            RelativeLocation;

	structdefaultproperties
	{
		DamageType=class'KFDT_Explosive'
		RelativeLocation=(Z=10)
	}
};

/** describes a dependency of one subobject on a modification to another */
struct native ObjDamageModifierDependency
{
	/** which subobject we're talking about */
	var() Name			DependentSubObjName;

	/** If dependent subobject is above this health, it will be damaged to this level */
	var() int			MaxHealthToAllow;

	/** Optimization to avoid searches.  Gets filled in on PostBeginPlay() */
	var transient int	DependentSubObjIdx;

	structdefaultproperties
	{
		DependentSubObjIdx=-1
	}
};

/** Contains data for an explosion to spawn upon damage */
struct native LightDamageParams
{
	/** Placed light actors to recieve this mod */
	var() Light						Light<DisplayName=LightActor>;

	/** New light animation settings */
	var() const float				MaxBrightness<UIMin=0.0|ClampMin=0.0>;
	var() const float				MinBrightness<UIMin=0.0|ClampMin=0.0>;
	var() ELightAnimationTechnique	AnimationType;
	var() float						AnimationFrequency<UIMin=0.01|ClampMin=0.01|UIMax=20.0|ClampMax=20.0>;

	/** If set, this light should be disabled */
	var() bool bDisabled;

	structdefaultproperties
	{
	}
};

/** A modification to be applied to a subobject after a certain damage threshold is reached. */
struct native ObjectDamageModifier
{
	/** Name that can use used to descriptively identify this mod. */
	var() const Name							DamageModName;

	/** apply this Modifier at or below this health */
	var() const float							HealthThreshold;

	/** New static mesh to swap to, or None */
	var() StaticMesh							NewMesh;

	/** Material changes */
	var() const array<MaterialReplaceMod>		MaterialReplacements;
	var() const array<MaterialScalarParamMod>	MaterialScalarParams;
	var() const array<MaterialTexParamMod>		MaterialTexParams;
	var() const array<MaterialVectorParamMod>	MaterialVectorParams;

	/** Sounds to play when applying this modifier */
	var() const array<AkBaseSoundObject>       	Sounds;

	/** TRUE to kill the subobject at this stage */
	var() const bool							bSelfDestruct;

	/** TRUE to kill the object (all subobjects) at this stage */
	var() const bool							bSelfDestructAll;

	/** TRUE to stop any attached ambient sound */
	var() const bool							bStopAmbientSound;

	// maybe use this?  ParticleSystem'Effects_Level_SP_5.SP_Hospital.Effects.P_Wooden_Barrier_Split'
	var() array<DestroyedEffectParams>			ParticleEffects;

	/** Potential splash damage (if the subj explodes or something) */
	var() const SplashDamageParams				SplashDamage;

	/** actors that will be spawned */
	var() const array<ActorSpawnParams>			ActorsToSpawn;

	/** list of subobjects that are also affected by this modifier */
	var() const array<ObjDamageModifierDependency>	DependentSubObjs;

	/** true when this stage has been applied */
	var transient bool							bApplied;

	/** index of the next actor to be spawned from ActorsToSpawn array */
	var transient int                           NextSpawnActorIdx;

	/** Explosion archetype to spawn */
	var() ExplosionMod                          ExploMod<DisplayName=ExplosionMod>;

	/** Temporarily allow CanBecomeDynamic (bNeverBecomeDynamic=FALSE) on these actors */
	var deprecated array<StaticMeshActor>				BecomeDynamicActors;

	/** light actors that are effected by this damage mod */
	var() const array<LightDamageParams>		LightParams;

	/** Whether this mod should apply actor blocking or not. @NOTE: Only used by undo mod */
	var transient bool bMeshBlockActors;
};

/** This sound is played all of the time the object is in the world.  (good for radios and such) **/
var() protected AkBaseSoundObject   AmbientSoundCue;
var protected AkComponent           AmbientSoundComponent;

/** Cached squared distance of nearest local player */
var transient float ClosestLocalPlayerSqDist;

/*********************************************************************************************
* Sub-objects
 ********************************************************************************************* */

struct native DestructibleSubobject
{
	/** name of the subobject.  should be unique, but not currently enforced */
	var() Name								SubObjName;

	/** the mesh */
	var() StaticMeshComponent				Mesh;

	/** mods that can be applied to this subobject */
	var() array<ObjectDamageModifier>		DamageMods;

	/** hit points this subobject has by default */
	var() float								DefaultHealth;

	/** Light brightness material parameter for this subobject */
	var()  array<MaterialLightParamMod>		MaterialLightParams;

	/**
	* This is a modifier that is autogenerated at initialization time which represents how to
	* get back to our original state
	* Used in MP to "heal" WDOs between rounds.
	*/
	var transient ObjectDamageModifier		UndoMod;

	/** Index of damage mod that is currently spawning effects / actors */
	var transient int	                    ActiveDamageModIdx;

	/** Most recent damage type this subobject was hit with */
	var transient class<DamageType>         LastHitDamageType;

	/** Cached MICs that are generated for material params */
	var transient array<MaterialInstanceConstant> MICs;

	/** Current health of this SubObject (non-transient) */
	var int	Health;

	structdefaultproperties
	{
		Health=50
		DefaultHealth=50
		ActiveDamageModIdx=-1
	}
};

/** Array of objects that comprise this destructible object (MAX: 8) */
var(SubObjects) array<DestructibleSubobject> SubObjects;

/** Tick optimization -- store all damaged mods in a single-dimensional array */
var native private const init array<pointer> DamagedSubObjects{FDestructibleSubobject};

/** SubObject array size limit based on ReplicationMode */
var(SubObjects) const editconst byte SubObjectLimit;
/** SubObject array size limit based on ReplicationMode */
var(SubObjects) const editconst byte DamageModLimit;

/** Helper object to display RelativeLocation and RelativeRotation */
var(SubObjects) editoronly transient Actor 		PreviewOffsetActor;
/** Last value from PreviewOffsetActor */
var(SubObjects) editoronly transient vector 	PreviewRelativeLocation;
var(SubObjects) editoronly transient rotator 	PreviewRelativeRotation;

cpptext
{
private:
	/** Attaches all of the subojects' components */
	void AttachSubobjectComponents(void);
	void SetupHealthVars();
	void GenerateUndo();
	void GenerateSubObjUndo(FDestructibleSubobject* SubObj);
	void UpdateDamageMods();
	void SetupComplexityLimits();
	void UpdateLightMatParams();

	/** handle MICs for any material params */
	UMaterialInstanceConstant* GetSubObjMIC(FDestructibleSubobject* SubObj, INT ElementIndex);
	void ClearSubObjMICs(INT ObjIdx);

public:
	virtual void PostLoad();
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);

	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags);
	virtual void TickSpecial(FLOAT DeltaSeconds);
	virtual UBOOL Tick(FLOAT DeltaTime, enum ELevelTick TickType);

    /* Overridden to setup collision for damage meshes that will eventually exist */
	virtual void InitRBPhys();

#if WITH_EDITOR
	virtual void CheckForErrors();
#endif

#if WITH_EDITOR
	virtual INT AddMyMarker(AActor *S);
#endif
}

/*********************************************************************************************
 * Replication
********************************************************************************************* */

replication
{
	if (Role == ROLE_Authority)
		ReplicatedDamageMods, bShutDown;
}

simulated event ReplicatedEvent(name VarName)
{
	local int Idx, ObjIdx, ModIdx;

	if (VarName == nameof(ReplicatedDamageMods))
	{
		// look for unprocessed replicated damage mods
		for (Idx = 0; Idx < ArrayCount(ReplicatedDamageMods); Idx++)
		{
			if ( ReplicatedDamageMods[Idx].ObjIdx != 255 )
			{
				ObjIdx = ReplicatedDamageMods[Idx].ObjIdx;
				ModIdx = ReplicatedDamageMods[Idx].ModIdx;
				if ( !SubObjects[ObjIdx].DamageMods[ModIdx].bApplied )
				{
					ApplyDamageMod(ObjIdx, ModIdx, ReplicatedDamageMods[Idx].bPartial);
				}
			}
		}
	}
	else if (VarName == nameof(bShutDown))
	{
		if (bShutDown)
		{
			ShutDownObject();
		}
		else
		{
			UnShutDownObject();
		}
	}
}

/**
 * Fills in an empty slot in the replicated damage mod array to be
 * sent to the clients for simulation.
 */
event ReplicateDamageMod(int ObjIdx, int ModIdx, bool bPartial)
{
	local int Idx;

	if ( (ObjIdx < 0) || (ObjIdx > 255)
		|| (ModIdx < 0) || (ModIdx > 255) )
	{
		`warn(self$" replicatedamagemod out of bounds "$ObjIdx@ModIdx);
		return;
	}

	// find first available
	for (Idx = 0; Idx < ArrayCount(ReplicatedDamageMods); Idx++)
	{
		if (ReplicatedDamageMods[Idx].ObjIdx == 255)
		{
			ReplicatedDamageMods[Idx].ObjIdx = ObjIdx;
			ReplicatedDamageMods[Idx].ModIdx = ModIdx;
			ReplicatedDamageMods[Idx].bPartial = bPartial;
			break;
		}
	}

	// immediate net update
	bForceNetUpdate = TRUE;
}

/** Pack damage mod into a byte for ReplicateDamageMod */
function byte PackDamageMod(int ObjIdx, int ModIdx, bool bPartial)
{
	// 1-4: ObjIdx, 5-6 ModIdx, 8 bPartial
	local byte DmgModFlags;
	DmgModFlags = ObjIdx + (ModIdx << 4);
	if ( bPartial )
	{
		DmgModFlags = DmgModFlags | 128;
	}
	return DmgModFlags;
}

/** Pack damage mod into a byte for ReplicateDamageMod */
simulated function UnPackDamageMod(byte DmgModFlags, out int ObjIdx, out int ModIdx, out byte bPartial)
{
	// 1-4: ObjIdx, 5-6 ModIdx, 8 bPartial
	ObjIdx = (DmgModFlags & 15);
	ModIdx = (DmgModFlags & 48);
	bPartial = (DmgModFlags & 128);
}

/*********************************************************************************************
 * Startup
********************************************************************************************* */

/** attach all subojects, generally get things ready for play */
simulated private native function SetupComponents();
/** one-time initializations.  basically intended to provide some native PostBeginPlay code. */
simulated native protected function OneTimeInit();

/**
 * This starts our ambient sound
 */
simulated event PostBeginPlay()
{
	OneTimeInit();

	// if we have and AmbientSoundCue we want to go ahead and start playing it.
	if( ( AmbientSoundCue != None ) && ( AmbientSoundComponent != None ) )
	{
	    AttachComponent( AmbientSoundComponent );
	    AmbientSoundComponent.OcclusionUpdateInterval = 0.2f;
	    AmbientSoundComponent.PlayEvent( AkEvent(AmbientSoundCue) );
	}

	switch (ReplicationMode)
	{
		case RT_ClientSide:
			// turn off BlockActors collision
			SetCollision(, false);
			if ( BlockingVolumeToDisable != None )
			{
				BlockingVolumeToDisable.SetCollision(false, false);
			}
			break;
	}

	if (WorldInfo.NetMode == NM_Client)
	{
		// on the client, set role to Authority if we're a clientside only KActor
		Role = (ReplicationMode == RT_ClientSide) ? ROLE_Authority : ROLE_SimulatedProxy;
	}
	else
	{
		// on the server, set role to SimulatedProxy (i.e. replicate it) only if not clientside
		RemoteRole = (ReplicationMode == RT_ClientSide) ? ROLE_None : ROLE_SimulatedProxy;
		//InitNavigationHandle();
	}
}

/*********************************************************************************************
 * Damage
********************************************************************************************* */

/** Apply damage to a subobject */
protected native function DamageSubObject(int ObjIdx, int Damage, Controller EventInstigator, class<DamageType> DamType);

/** Returns TRUE if any subobject has health > 0.  Should only be used on the server as a
 * catch-all for destructibles that don't have a damage mod with bSelfDestructAll set
 */
native function bool HasAnyHealth();

native function float GetCurrentHealth();
native function float GetMaxHealth();

/** Network: Server */
simulated function TakeRadiusDamage
(
	Controller			InstigatedBy,
	float				BaseDamage,
	float				DamageRadius,
	class<DamageType>	DamageType,
	float				Momentum,
	vector				HurtOrigin,
	bool				bFullDamage,
	Actor				DamageCauser,
	optional float      DamageFalloffExponent=1.f,
	optional bool		bAdjustRadiusDamage=true
)
{
	bIsRadiusDamage = true;
	Super.TakeRadiusDamage(InstigatedBy, BaseDamage, DamageRadius, DamageType, Momentum, HurtOrigin, bFullDamage, DamageCauser, DamageFalloffExponent, bAdjustRadiusDamage);
	bIsRadiusDamage = false;
}

/** Network: Server */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int Idx;

	// Modify the damage based on the damage type
	AdjustDamage(Damage, EventInstigator, DamageType);

	// Bail if there is no damage
	if( Damage <= 0 )
	{
		return;
	}

	// If this damage type should instakill, don't bother finding a HitIdx
	if ( Damage >= INSTAKILL_DAMAGE || bIsRadiusDamage )
	{
		// no specific hit subobject, so hit them all equally
		for (Idx=0; Idx<SubObjects.Length; ++Idx)
		{
			if (Damage > 0.f)
			{
				DamageSubObject(Idx, Damage, EventInstigator, DamageType);
			}
		}
	}
	else if ( ValidateHitComponent(EventInstigator, HitInfo, HitLocation, Momentum) )
	{
		// Search and find which subobject got hit
		for (Idx=0; Idx<SubObjects.Length; ++Idx)
		{
			if (SubObjects[Idx].Mesh != HitInfo.HitComponent)
				continue;

			if (SubObjects[Idx].Health > 0.f)
			{
				// hit a subobject, damage it
				DamageSubObject(Idx, Damage, EventInstigator, DamageType);
			}

			//`log("Got Subobject!");
			break;
		}
	}

	// If object is dead, unregister with navmesh
	if ( Role == ROLE_Authority && !HasAnyHealth() )
	{
		// @todo: pathfinding
		//TurnOffNavigationObstacle();
	}

	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
}

/** Adjust damage based on inventory, other attributes */
function AdjustDamage(out int InDamage, Controller EventInstigator, class<DamageType> DamageType)
{
	local int Idx;
	local KFAIController KFAIInstigator;

    if (bIgnoreAllDamage)
    {
        InDamage = 0;
        return;
    }

	// Check if this damage should instakill
	for ( Idx = 0; Idx < InstaKillDamageType.length; ++Idx )
	{
		if ( (DamageType == InstaKillDamageType[Idx]) || ClassIsChildOf(DamageType, InstaKillDamageType[Idx]) )
		{
			InDamage = INSTAKILL_DAMAGE;
			return;
		}
	}

	// Check if this damage should be ignored completely
	for (Idx = 0; Idx < IgnoreDamageType.length; ++Idx)
	{
		if ( (DamageType == IgnoreDamageType[Idx]) || ClassIsChildOf(DamageType, IgnoreDamageType[Idx]) )
		{
			InDamage = 0;
			return;
		}
	}

	// special case handling for players and zeds
	if ( EventInstigator != None )
	{
		// The check below allows NPCs who are set to attack the destructible (see NotifyAttackTarget() in
		// KFAIController), insta-kill the destructible if their ActorEnemy matches the destructible. This
		// avoids the previous issue where damage was applied immediately on Bump, which resulted in the
		// destructible breaking before the NPC's attack animtaion sequence actually began.
		if( bAllowBumpDamageFromAI && !EventInstigator.bIsPlayer )
		{
			KFAIInstigator = KFAIController(EventInstigator);
			if( KFAIInstigator != none && KFAIInstigator.ActorEnemy == self )
			{
				InDamage = INSTAKILL_DAMAGE;
				return;
			}
		}

		// Check if this damage should be ignored completely (update: human team only)
		if ( bIgnorePlayerDamage && EventInstigator.bIsPlayer && EventInstigator.GetTeamNum() == 0)
		{
			InDamage = 0;
			return;
		}
	}

	if( bIsRadiusDamage && IsVulnerableTo(DamageType) )
	{
		InDamage *= VulnerableMultiplier;
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

/** Called from UKFReachSpec::PrepareForMove when DestructibleActor is ahead on NPC's path */
event bool InstaKillFromLargeNPCBumpDamage()
{
	return ( InstaKillDamageType.Find(class'KFDT_NPCBump_Large') != INDEX_NONE );
}

/** Called from UKFReachSpec::PrepareForMove when DestructibleActor is ahead on NPC's path */
event bool InstaKillFromStandardNPCBumpDamage()
{
	return ( InstaKillDamageType.Find(class'KFDT_NPCBump') != INDEX_NONE );
}

/** If we don't have a valid hit component (e.g. CSHD) trace to retrieve */
function bool ValidateHitComponent( Controller EventInstigator, out TraceHitInfo HitInfo, vector HitLocation, vector Momentum )
{
	local Actor TraceInstigator;
	local vector NewHitLocation, HitNormal;
	local vector Offset;

	if ( HitInfo.HitComponent == None )
	{
		// Perform trace to retrieve hit info
		if ( Momentum == vect(0,0,0) )
		{
			Momentum = Location - HitLocation;
		}
		Offset = 8.f * Normal(Momentum);

		if( EventInstigator != none )
		{
			TraceInstigator = (EventInstigator.Pawn != none && EventInstigator.Pawn.Weapon != none) ? EventInstigator.Pawn.Weapon : EventInstigator.Pawn;
		}
		if( TraceInstigator == none )
		{
			TraceInstigator = WorldInfo;
		}

		TraceInstigator.Trace( NewHitLocation, HitNormal, HitLocation + Offset, HitLocation - Offset, true,, HitInfo, TRACEFLAG_Bullet );
	}

	return HitInfo.HitComponent != None;
}

event ApplySplashDamage(const out vector Origin, const out SplashDamageParams DamageParams)
{
	// DEPRECATED. Use ExplosionTemplate instead
	//if (Role == ROLE_Authority)
	//{
	//	HurtRadius(DamageParams.BaseDamage, DamageParams.DamageRadius, DamageParams.DamageType, 1.f, Origin + DamageParams.RelativeLocation, self);
	//}
}

/** Fire the Destroyed kismet event, called when all subobjects are dead */
delegate OnDestroyed(KFDestructibleActor DActor);
protected event TriggerDestroyedEvent(Controller EventInstigator)
{
	//@note: This will always be called, unlike DelayedShutDownObject/ShutDownObject which is only called if bSelfDestructAll==TRUE

	OnDestroyed(self);
	TriggerEventClass(class'SeqEvent_Destroyed', EventInstigator);
}

function BumpedByMonster( KFPawn_Monster P, vector HitNormal )
{
	if( bAllowBumpDamageFromAI )
	{
		if ( `TimeSince(LastBumpCheckTime) < 0.5f )
		{
			return;
		}
		LastBumpCheckTime = WorldInfo.TimeSeconds;

		if( P.Controller != none )
		{
			// Call TakeDamage with 0 because we only want to take bump damage if it is in the array of InstaKillDamageTypes
			TakeDamage( 0, P.Controller, P.Location, vect(0,0,0), P.BumpDamageType,, P );
		}
	}
}

function int GetInstaKillDamage()
{
	return INSTAKILL_DAMAGE;
}

/*********************************************************************************************
 * Effects
********************************************************************************************* */

/** Change the static mesh to one stored in a DamageMod
 *
 * @param ObjIdx	index of subobject getting the mod
 * @param ModIdx	index into mod array indicating which mod to apply
 */
simulated native protected function SetSubObjectStaticMesh(int ObjIdx, int ModIdx);

/**
 * Apply one of the stored damage mods to this object.
 *
 * @param ObjIdx	index of subobject getting the mod
 * @param ModIdx	index into mod array indicating which mod to apply
 * @param bPartial	TRUE for partial application, used if more than one mod triggers
 *					in a frame.  Only 1 mod will be fully applied (to prevent overlapping
 *					sounds and whatnot.
 */
simulated native protected function ApplyDamageMod(int ObjIdx, int ModIdx, bool bPartial, optional Controller DamageInstigator);

/**
 * This function will remove all of the currently attached decals from the object.
 * Basically, we want to have decals attach to these objects and then on state change (due to damage usually), we will
 * just detach them all with the big particle effect that occurs it should not be noticeable.
 **/
simulated native protected function RemoveDecals();

/** Spawns the explosion associated with the passed in damage mod */
simulated event Explosion(const out DestructibleSubobject SubObj, const out ObjectDamageModifier Mod)
{
	local vector EffectLoc;
	local rotator EffectRot;
	local GameExplosionActor ExplosionActor;
	local GameExplosion ExplosionTemplate;
	//local StaticMeshActor SMActor;
	//local bool bOldNeverBecomeDynamic;

	// Temporarily enable CanBecomeDynamic and activate these actors.  This is useful
	// for tables and other destructibles with objects stacked on top.
	//foreach Mod.BecomeDynamicActors(SMActor)
	//{
	//	bOldNeverBecomeDynamic = SMActor.StaticMeshComponent.bNeverBecomeDynamic;
	//	SMActor.StaticMeshComponent.bNeverBecomeDynamic = false;
	//	class'KActorFromStatic'.Static.MakeDynamic(SMActor.StaticMeshComponent);
	//	SMActor.StaticMeshComponent.bNeverBecomeDynamic = bOldNeverBecomeDynamic;
	//}

	if( Mod.ExploMod.ExplosionTemplate != None )
	{
		EffectLoc = Location + (Mod.ExploMod.RelativeLocation >> Rotation);
		EffectRot = Rotation + RelativeRotation;

		ExplosionActor = Spawn(class'KFExplosionActor', self,, EffectLoc, EffectRot);
		ExplosionTemplate = Mod.ExploMod.ExplosionTemplate;

		if (ExplosionActor != None)
		{
			// override explosion template
			/*
			ExplosionTemplate = new class'KFGameExplosion'(Mod.ExploMod.ExplosionTemplate);
			ExplosionTemplate.Damage = Mod.ExploMod.Damage;
			ExplosionTemplate.DamageRadius = Mod.ExploMod.DamageRadius;
			ExplosionTemplate.DamageFalloffExponent = 1.0f;
			ExplosionTemplate.ActorClassToIgnoreForDamage = Mod.ExploMod.ActorClassToIgnoreForDamage;
			ExplosionTemplate.ActorToIgnoreForDamage = self;
			ExplosionTemplate.DamageDelay = 0.01f;
			*/

			// Detect environment template and skip line check and damage falloff
			//if ( ExplosionTemplate.DamageFalloffExponent == 0.f
			//	&& ExplosionTemplate.ActorClassToIgnoreForDamage == class'Pawn'
			//	&& ExplosionTemplate.MyDamageType == class'KFDT_Environment_KActorImpulse' )
			//{
			//	ExplosionActor.bAlwaysDoFullDamage = true;
			//}

			ExplosionActor.Explode(ExplosionTemplate);
		}
	}
}

/*********************************************************************************************
 * Destroy / UnDestroy
********************************************************************************************* */

/** Restores to it's pristine state. */
simulated native function UnDestroy();

/** "Turn off" this entire object after a delay */
simulated protected event DelayedShutDownObject()
{
	local Actor Other;
	local StaticMeshActor OtherSM;

	SetCollision(false, false, bIgnoreEncroachers);

	// Disable associated blocking volume.  Called when bSelfDestructAll is set
	// @note invalid if this is a clientside destructible
	if ( ReplicationMode != RT_ClientSide && BlockingVolumeToDisable != None )
	{
		BlockingVolumeToDisable.SetCollision(false, false);
	}

	// Process DamageOtherActors
	foreach DamageOtherActors(Other)
	{
		if ( Other.bStatic && Other.bWorldGeometry )
		{
			OtherSM = StaticMeshActor(Other);
			if ( OtherSM != None )
			{
				// override bNeverBecomeDynamic on this StaticMeshComp
				OtherSM.StaticMeshComponent.bNeverBecomeDynamic = false;
				if ( OtherSM.StaticMeshComponent.CanBecomeDynamic() )
				{
					Other = class'KActorFromStatic'.Static.MakeDynamic(OtherSM.StaticMeshComponent);
					if ( Other == None )
					{
						// make dynamic failed, move on to next actor
						continue;
					}
				}
			}
		}

		Other.TakeRadiusDamage(None, 1000, 1000, class'KFDT_Environment_KActorImpulse', 1, Location, true, self);
	}

	SetTimer(0.2f, false, nameof(ShutDownObject));
}

/** "Turn off" this entire object */
simulated function ShutDownObject()
{
	local int Idx;

	bShutDown = true;

	// shut down all subobjects
	for (Idx=0; Idx<SubObjects.Length; ++Idx)
	{
		SubObjects[Idx].Mesh.SetHidden(TRUE);
		SubObjects[Idx].Mesh.SetTraceBlocking(FALSE, FALSE);
		SubObjects[Idx].Mesh.SetActorCollision(FALSE, FALSE);
		SubObjects[Idx].Mesh.SetBlockRigidBody(FALSE);
	}

	// note actor collision is already disabled (see DelayedShutDownObject)
}

/** "Turn off" a subobject, no mesh, no collision, nothing left */
simulated protected event ShutDownSubObject(const out DestructibleSubobject SubObj)
{
	SubObj.Mesh.SetHidden(TRUE);
	SubObj.Mesh.SetTraceBlocking(FALSE, FALSE);
	SubObj.Mesh.SetActorCollision(FALSE, FALSE);
	SubObj.Mesh.SetBlockRigidBody(FALSE);
}

/** Reset all objects after TurnOff has been called */
simulated protected event UnShutDownObject()
{
	local int SubObjIdx, DamageModIdx;

	bShutDown = false;

	// Reset collision
	SetCollision(default.bCollideActors, default.bBlockActors, bIgnoreEncroachers);

	// @fixme: better to store original vals here instead of assuming
	// true across the board, in case that assumption is inaccurate
	for (SubObjIdx = 0; SubObjIdx < SubObjects.Length; ++SubObjIdx)
	{
		SubObjects[SubObjIdx].Mesh.SetHidden(FALSE);
		SubObjects[SubObjIdx].Mesh.SetTraceBlocking(TRUE, TRUE);
		SubObjects[SubObjIdx].Mesh.SetActorCollision( TRUE, SubObjects[SubObjIdx].Mesh.BlockActors ); // BlockActors is determined by the undo object
		SubObjects[SubObjIdx].Mesh.SetBlockRigidBody(TRUE);

		// Reset vars for tracking damage mods
		SubObjects[SubObjIdx].ActiveDamageModIdx = -1;
		for (DamageModIdx = 0; DamageModIdx < SubObjects[SubObjIdx].DamageMods.length; ++DamageModIdx)
		{
			SubObjects[SubObjIdx].DamageMods[DamageModIdx].NextSpawnActorIdx = 0;
		}
	}

	// If a pawn is inside of this actor now, teleport it
	if( Role == ROLE_Authority )
	{
		SetTimer(0.01, false, nameof(MoveCollidingPawns));
	}
}

/** Moves pawns that are standing on destroyed actor when it is reset */
function MoveCollidingPawns()
{
	// @todo
}

/**
 * Level was reset without reloading
 * Network: ALL. Called on clients to avoid issues that could arise from players joining in progress
 * and thinking they need to reset this actor when they don't.
 */
simulated function Reset()
{
    local int SubObjIdx;

    //Undo shutdown if necessary
    if (bShutDown)
    {
        UnShutDownObject();
    }

    //Reset health
    for (SubObjIdx = 0; SubObjIdx < SubObjects.Length; ++SubObjIdx)
    {
        SubObjects[SubObjIdx].Health = SubObjects[SubObjIdx].DefaultHealth;
    }

	if( !bAnyDamageModApplied )
	{
		return;
	}

	RemoveDecals();
	UnDestroy();
	bForceNetUpdate = true;
}

function ToggleAllDamage(bool bDamageOn)
{
    bIgnoreAllDamage = !bDamageOn;
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.S_Actor'
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
	End Object
	Components.Add(Sprite)

	Begin Object Class=AkComponent Name=AmbientSoundComponent0
	    bStopWhenOwnerDestroyed=TRUE
	    bForceOcclusionUpdateInterval=true
	    // OcclusionCheckInterval set in PostBeginPlay
	End Object
	AmbientSoundComponent=AmbientSoundComponent0

	VulnerableMultiplier=6
	VulnerableDamageType(0)=class'KFDT_Sonic'

	// no physics by default
	Physics=PHYS_None
	bMovable=FALSE

	// many of these properties are pulled in from KActor
	// since this class was originally derived from KActor
	bStatic=false
	bCollideWorld=false
	bProjTarget=true
	bBlockActors=true
	bWorldGeometry=true
	bNoDelete=true
	bCollideActors=true
	bNoEncroachCheck=true
	bBlocksTeleport=true
	bBlocksNavigation=true

	bEdShouldSnap=true
	bGameRelevant=true
	bPathColliding=false

	// Without this explosions won't do damage to them because they are world geometry
	bCanBeDamaged=true
    bIgnoreAllDamage=false

	// network - see EDestructibleRepType
	RemoteRole=ROLE_None
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=true
	NetUpdateFrequency=0.1
	bIgnoreNetRelevancyCollision=true

	SelfDestructAllDelay=0.2f
	bAllowBumpDamageFromAI=true
	INSTAKILL_DAMAGE=100000
	//NavMeshObjectState=ENavMeshObjectState_None
}