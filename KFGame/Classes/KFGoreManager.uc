//=============================================================================
// KFGoreManager
//=============================================================================
// Manager class for gore related effects
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 12/3/2012
//=============================================================================

class KFGoreManager extends Actor
	native(Effect)
	config(Game);

`include(KFProfileSettings.uci);

/**
 * Predefined values
 */
 `define BLOOD_SPLATTER_TRACE_LENGTH 500.f
 `define BLOOD_POOL_TRACE_LENGTH 250.f
 `define WOUND_DECAL_GORE_LEVEL 1
 `define BLOOD_SPLATTER_GORE_LEVEL 1
 `define BLOOD_POOL_GORE_LEVEL 1
 `define MUTILATION_GORE_LEVEL 0
 `define HEADLESS_GORE_LEVEL 2
 `define GIB_SPLAT_COOLDOWN 0.08

/**
 *  Transient Values managed outside of class
 */
 var transient int DesiredGoreLevel;

/**
 * Effect Lifetimes
 */
var globalconfig float GoreFXLifetimeMultiplier;
var globalconfig float BodyWoundDecalLifetime;
var globalconfig float BloodSplatterLifetime;
var globalconfig float BloodPoolLifetime;
var globalconfig float GibletLifetime;

/**
 * Effect Dimensions
 */
var globalconfig float BloodSplatSize;
var globalconfig float BloodPoolSize;

/**
 * Decal Limits
 */
var globalconfig int MaxBodyWoundDecals;
var globalconfig int MaxBloodSplatterDecals;
var globalconfig int MaxBloodPoolDecals;
var globalconfig bool bAllowBloodSplatterDecals;

/**
 * Decal managers
 */
var transient DecalManager BodyWoundDecalManager;
var transient DecalManager BloodSplatterDecalManager;
var transient DecalManager BloodPoolDecalManager;

/**
 * Emitter Limits
 */
var globalconfig int MaxBloodEffects;
var globalconfig int MaxGoreEffects;

/**
 * Emitter Pools
 */
 var transient EmitterPool BloodFXEmitterPool;
 var transient EmitterPool MiscGoreFXEmitterPool;

/**
 * Dead Pawns
 */
var array<KFPawn>	 CorpsePool;
var globalconfig int MaxDeadBodies;
var float			 MaxCorpseOffscreenTime;
var float			 MaxCorpseOffscreenDistance;

/**
 * Persistent Splatters
 */
var globalconfig float PersistentSplatTraceLength;
var globalconfig int MaxPersistentSplatsPerFrame;

struct native PersistentSplatInfo
{
 	var vector Location;
 	var vector Normal;
 	var float Scale;
 	var bool bRandomize;
	var float TraceLength;

 	structcpptext
 	{
 		FPersistentSplatInfo() {}

	 	FPersistentSplatInfo(FVector InLocation, FVector InNormal, FLOAT InScale, UBOOL InRandomize, FLOAT TraceLength) :
 			Location(InLocation),
 			Normal(InNormal),
 			Scale(InScale),
 			bRandomize(InRandomize),
			TraceLength(TraceLength) {}

 	}
};

/* Cyclic buffer that contains the persistent splat generators for this frame */
var transient array<PersistentSplatInfo> CurrentSplats;
var transient int CurrentSplatIdx;

var transient array<TWSplatterMapTexture2D> CachedSplattermaps;

/**
 * Debugging
 */
var bool bShowPersistentBloodTraces; 	// Set to TRUE if you want to see the line traces
var bool bLogGore;

event PostBeginPlay()
{
	local KFGameEngine KFGE;
	local KFProfileSettings KFPS;
	Super.PostBeginPlay();

	if(!class'WorldInfo'.static.IsConsoleBuild())
	{
		// Legacy support
		DesiredGoreLevel = class'GameInfo'.default.GoreLevel;
	}
	else
	{
		KFGE = KFGameEngine(class'Engine'.static.GetEngine());
		KFPS = KFProfileSettings(KFGE.OnlineSubsystem.PlayerInterface.GetProfileSettings(KFGE.GamePlayers[0].ControllerId));

		DesiredGoreLevel = KFPS.GetProfileInt(KFID_GoreLevel);
		`QAlog(`location@`showvar(KFGE)@`showvar(KFPS)@`showvar(DesiredGoreLevel), true);
	}

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// Wound decal manager
		BodyWoundDecalManager = Spawn(class'DecalManager', self,, vect(0,0,0), rot(0,0,0));
		BodyWoundDecalManager.MaxActiveDecals = MaxBodyWoundDecals;

		// Blood splatter decal manager
		BloodSplatterDecalManager = Spawn(class'DecalManager', self,, vect(0,0,0), rot(0,0,0));
		BloodSplatterDecalManager.MaxActiveDecals = MaxBloodSplatterDecals;

		// Blood pool decal manager
		BloodPoolDecalManager = Spawn(class'DecalManager', self,, vect(0,0,0), rot(0,0,0));
		BloodPoolDecalManager.MaxActiveDecals = MaxBloodPoolDecals;

		// Emitter pool for blood FX such as jets, trails, etc.
		// Note : Blood spray is handled as part of the impact effect system. See PlayImpactParticleEffect()
		BloodFXEmitterPool = Spawn(class'EmitterPool', self,, vect(0,0,0), rot(0,0,0));
		BloodFXEmitterPool.MaxActiveEffects = MaxBloodEffects;

		// Emitter pool for misc gore FX such as obliteration, custom dismemberment FX, etc.
		MiscGoreFXEmitterPool = Spawn(class'EmitterPool', self,, vect(0,0,0), rot(0,0,0));
		MiscGoreFXEmitterPool.MaxActiveEffects = MaxGoreEffects;

		// clamp settings
		MaxDeadBodies = Max(MaxDeadBodies, 4);
	}
}

/*********************************************************************************************
 * Body Wound
 *********************************************************************************************/

simulated function LeaveABodyWoundDecal(KFpawn InPawn, vector InHitLocation, vector InHitDirection, name InHitZone, name InHitBone, class<KFDamageType> DmgType)
{
	local vector HitDirection;
	local vector DecalProjLocation;
	local rotator DecalOrientation;
	local DecalComponent WoundDecal;
	local MaterialInterface WoundMIC;
	local SkeletalMeshComponent HitComponent;
	local float BodyWoundDecalWidth, BodyWoundDecalHeight;

 	if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.bDropDetail )
		return;

    if( DesiredGoreLevel <= `WOUND_DECAL_GORE_LEVEL )
	{
		if ( DmgType != None && DmgType.default.BodyWoundDecalMaterials.length > 0 )
		{
			WoundMIC = DmgType.default.BodyWoundDecalMaterials[rand(DmgType.default.BodyWoundDecalMaterials.length)];
			BodyWoundDecalWidth = DmgType.default.BodyWoundDecalWidth;
			BodyWoundDecalHeight = DmgType.default.BodyWoundDecalHeight;
		}

		if( WoundMIC != None )
		{
			HitDirection = Normal(InHitDirection);
	    	DecalProjLocation = InHitLocation - 10*HitDirection;		// Move the projection location slightly away from the actual impact location
	    	DecalOrientation = rotator(-HitDirection);

			// Pick the right mesh basedon the hit zone
			if( (InHitZone == 'head' || InHitZone == 'neck') &&
			 	InPawn.ThirdPersonHeadMeshComponent != none )
			{
				HitComponent = InPawn.ThirdPersonHeadMeshComponent;
			}
			else
			{
				HitComponent = InPawn.Mesh;
			}

			WoundDecal = BodyWoundDecalManager.SpawnDecal(
							WoundMIC,
	                    	DecalProjLocation, DecalOrientation,
							BodyWoundDecalWidth, BodyWoundDecalHeight, 50.0f,
							false,, HitComponent,
							false, true, InHitBone,
							,, BodyWoundDecalLifetime * GoreFXLifetimeMultiplier);

			WoundDecal.bNoClip = true;
		}
	}
}



/*********************************************************************************************
 * Blood Splatter
 *********************************************************************************************/

/** Leaves a persistent blood splat on level geometry
	bForceUpdate will force immediate update instead of queueing it up in the cyclic buffer
 */
simulated native final function LeaveAPersistentBloodSplat(vector HitLoc, vector HitNorm, optional float BloodScale = 1.0, optional bool bRandomizeBloodScale = true, optional bool bForceUpdate = false, optional float TraceLength = PersistentSplatTraceLength);

/** Helper function for LeaveAPersistentBloodSplat. Traces agains geometry and updates the splattermaps */
simulated native final function PerformTraceAndUpdateSplattermap(const out PersistentSplatInfo InSplat);

/** Clears all persistent blood splats in the world. The splats are automatically cleared on map reload.
	Use this function only if you want to clear them during the match. */
native final function ClearPersistentBloodSplats();

/** Cache the splattermaps currently used by the level */
native final function CacheCurrentSplattermaps();

/** Perform traces and update splattermap textures */
native final function FlushPersistentBloodSplats();

/** Spawn persistent blood effects */
simulated function CausePersistentBlood(KFPawn_Monster InPawn, class<KFDamageType> InDmgType, vector InHitLocation, vector InHitDirection, int InHitZoneIndex, bool bIsDismeberingHit, bool bWasObliterated)
{
	local array<vector> HitSpread;
	local float BloodScale;
	local int i;

	//If we have an invalid hit zone, don't spawn blood
	if (InHitZoneIndex > InPawn.HitZones.Length)
	{
		return;
	}

	//Allow damage type to add more spread to the hit direction based its type.
	HitSpread.Remove(0, HitSpread.length);
	InDmgType.static.AddBloodSpread(InPawn, InHitDirection, HitSpread, bIsDismeberingHit, bWasObliterated);

	// Allow damage type to modify the blood scale to be applied
	// (taking into account the damage scale of the hit zone)
	// Note: if we need more control over the scale we can decouple it from
	// damage scale and use a custom "BloodScale" for each hit zone.
	BloodScale = InDmgType.static.GetBloodScale(InHitZoneIndex != 255 ? InPawn.HitZones[InHitZoneIndex].DmgScale : 1.f, bIsDismeberingHit, bWasObliterated);

	for( i=0; i<HitSpread.length; i++ )
	{
		LeaveAPersistentBloodSplat(InHitLocation, HitSpread[i], BloodScale);
	}
}

/** Leaves a temporary blood decal on level geometry */
simulated function LeaveABloodSplatterDecal(KFPawn InPawn, vector HitLoc, vector HitNorm )
{
	local Actor TraceActor;
	local vector TraceHitLoc, TraceHitNorm;
	local vector TraceDest, TraceStart;
	local vector TraceExtent;
	local TraceHitInfo HitInfo;
	local int DecalScaler;

	if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.bDropDetail || !bAllowBloodSplatterDecals )
		return;

	if( DesiredGoreLevel <= `BLOOD_SPLATTER_GORE_LEVEL )
	{
		TraceStart = HitLoc;
		TraceDest =  HitLoc  + normal(HitNorm) * `BLOOD_SPLATTER_TRACE_LENGTH;

		TraceActor = Trace(TraceHitLoc, TraceHitNorm, TraceDest, TraceStart, false, TraceExtent, HitInfo, TRACEFLAG_PhysicsVolumes );

		// START DEBUG
		// DrawDebugLine(TraceDest, TraceStart, 255, 0, 0, true);
		// DrawDebugSphere(TraceStart, 5, 20, 0, 255, 0, true);
		// DrawDebugSphere(TraceDest, 5, 20, 0, 0, 255, true);
		// END DEBUG

		if (TraceActor != None && Pawn(TraceActor) == None)
		{
			DecalScaler = Rand(50);
			BloodSplatterDecalManager.SpawnDecal(
				InPawn.BloodSplatterDecalMaterials[Rand(InPawn.BloodSplatterDecalMaterials.Length)],
				TraceHitLoc, rotator(-TraceHitNorm),
				BloodSplatSize + DecalScaler, BloodSplatSize + DecalScaler, 50,
				false,,,,,,,,
				BloodSplatterLifetime * GoreFXLifetimeMultiplier);
		}
	}
}

simulated function float GetTimeBetweenGibBloodSplats()
{
	return `GIB_SPLAT_COOLDOWN;
}

/*********************************************************************************************
 * Blood Pool
 *********************************************************************************************/

simulated function LeaveABloodPoolDecal(KFPawn InPawn)
{
	local Actor TraceActor;
	local vector TraceHitLocation, TraceHitNormal;
	local vector TraceDest, TraceStart;
	local TraceHitInfo HitInfo;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalScaler;
	local name OriginBone;

	if( WorldInfo.bDropDetail )
	{
		return;
	}

    if( DesiredGoreLevel <= `BLOOD_POOL_GORE_LEVEL )
	{
		// If given bone is valid, trace from its world space location. Otherwise, trace from root bone
		OriginBone = InPawn.CharacterArch.BloodPoolOriginBoneName;
		if( OriginBone != '' && InPawn.mesh.MatchRefBone(OriginBone) != INDEX_NONE )
		{
			TraceStart = InPawn.mesh.GetBoneLocation(OriginBone);
		}
		else
		{
			TraceStart = InPawn.mesh.GetBoneLocation(InPawn.mesh.GetBoneName(0));
		}

		TraceDest = TraceStart + `BLOOD_POOL_TRACE_LENGTH * vect(0,0,-1);

		TraceActor = Trace(TraceHitLocation, TraceHitNormal, TraceDest, TraceStart, false,, HitInfo, TRACEFLAG_PhysicsVolumes);

		if( TraceActor != none && Pawn(TraceActor) == none )
		{
			MITV_Decal = new(Outer) class'MaterialInstanceTimeVarying';
			MITV_Decal.SetParent(InPawn.BloodPoolDecalMaterials[Rand(InPawn.BloodPoolDecalMaterials.Length)]);
			MITV_Decal.SetDuration(BloodPoolLifetime * GoreFXLifetimeMultiplier);

			DecalScaler = Rand(25);
			BloodPoolDecalManager.SpawnDecal(
				MITV_Decal,
				TraceHitLocation, rotator(-TraceHitNormal),
				BloodPoolSize + DecalScaler, BloodPoolSize + DecalScaler, 32,
				false,,,true,false,,,,
				BloodPoolLifetime * GoreFXLifetimeMultiplier);
		}
	}
}

/*********************************************************************************************
 * Dismemberment
 *********************************************************************************************/
simulated final function bool AllowMutilation()
{
	return DesiredGoreLevel <= `MUTILATION_GORE_LEVEL;
}

simulated final function bool AllowHeadless()
{
	return DesiredGoreLevel <= `HEADLESS_GORE_LEVEL;
}

/** Spawns blood effects due to limb dismemberment or gibbing
	@InPawn 			Affected pawn
	@DismemberedBone	Bone used to calculate attachment transform, etc.
	@BloodJets			Species the blood jet behavior
	@BloodTrails		Species the blood trail behavior
	@BloodMICParams		Species the blood overlay behavior
 */
simulated final function AttachMutilationBloodEffects(
	KFPawn_Monster InPawn,
	Name DismemberedBone,
	optional array<BloodJetSettings> BloodJets,
	optional array<BloodTrailSettings> BloodTrails,
	optional array<name> BloodMICParams)
{
	local name ParentBone;
	local int ParentBoneIndex, DismemberedBoneIndex, BloodParamIndex, BloodJetIndex, BloodTrailIndex, MICIndex;
	local SkeletalMeshComponent SkelMesh;
	local vector OffsetFromParentBone, TranslationFromParentBone, ParentBoneFaceDir;
	local bool bOppositeFacing;
	local KFCharacterInfo_Monster MonsterInfo;

	if( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	if( InPawn != none && InPawn.mesh != none )
	{
        MICIndex = 0;
        if (InPawn.CharacterMICs.Length > InPawn.GetCharacterInfo().GoreFXMICIdx)
        {
            MICIndex = InPawn.GetCharacterInfo().GoreFXMICIdx;
        }

		//
		// Activate the blood splat on the body MIC
		// NOTE: 0.f activates the blood 1.f deactivates it
		//
		for( BloodParamIndex = 0; BloodParamIndex < BloodMICParams.length; BloodParamIndex++ )
		{
			InPawn.CharacterMICs[MICIndex].SetScalarParameterValue(BloodMICParams[BloodParamIndex], 0.f);
		}

		if ( WorldInfo.bDropDetail )
		{
			return; // MIC params only
		}

		SkelMesh = InPawn.mesh;
		ParentBone = SkelMesh.GetParentBone(DismemberedBone);
		DismemberedBoneIndex  = SkelMesh.MatchRefBone(DismemberedBone);
		ParentBoneIndex = SkelMesh.MatchRefBone(ParentBone);
		MonsterInfo = InPawn.GetCharacterMonsterInfo();

		if( DismemberedBoneIndex != INDEX_None && ParentBoneIndex != INDEX_NONE && MonsterInfo != none )
		{
			// Get the offset of the dismembered bone from the parent bone. We need to attach
			// the blood to the parent bone but offset to the position where the dismembered bone was.
			OffsetFromParentBone = SkelMesh.LocalAtoms[DismemberedBoneIndex].Translation;

			// Because the bones on the left and right side of the character are flipped in direction
			// we need to procedurally figure out which way the parent bone is facing. If the parent bone
			// is facing away from the dismembered bone, we need to flip the rotation of the attached jet.
			TranslationFromParentBone = SkelMesh.SpaceBases[DismemberedBoneIndex].Translation - SkelMesh.SpaceBases[ParentBoneIndex].Translation;
			ParentBoneFaceDir = SkelMesh.GetBoneAxis(ParentBone, AXIS_X);
			bOppositeFacing = normal(TranslationFromParentBone) dot ParentBoneFaceDir < 0.f ? true : false;

			//
			// Attach blood jets
			//
			for( BloodJetIndex = 0; BloodJetIndex < BloodJets.length; BloodJetIndex++ )
			{
				if( BloodJets[BloodJetIndex].bAttachToSocket )
				{
					BloodFXEmitterPool.SpawnEmitterMeshAttachment(
						BloodJets[BloodJetIndex].ParticleSystemTemplate,
						SkelMesh,
						BloodJets[BloodJetIndex].SocketName,
						true);
				}
				else
				{
					BloodFXEmitterPool.SpawnEmitterMeshAttachment(
						BloodJets[BloodJetIndex].ParticleSystemTemplate,
						SkelMesh, ParentBone, false,
						OffsetFromParentBone,
						bOppositeFacing ? rot(0,32768,0) : rot(0,0,0));
				}
			}

			//
			// Attach blood trail to dismembered bone
			//
			for( BloodTrailIndex = 0; BloodTrailIndex < BloodTrails.length; BloodTrailIndex++ )
			{
				if( BloodTrails[BloodTrailIndex].bAttachToSocket )
				{
					BloodFXEmitterPool.SpawnEmitterMeshAttachment(
						BloodTrails[BloodTrailIndex].ParticleSystemTemplate,
						SkelMesh,
						BloodTrails[BloodTrailIndex].SocketName,
						true);
				}
				else
				{
					BloodFXEmitterPool.SpawnEmitterMeshAttachment(
						BloodTrails[BloodTrailIndex].ParticleSystemTemplate,
						SkelMesh, DismemberedBone, false,,
						bOppositeFacing ? rot(0,0,0) : rot(0,32768,0));
				}
			}
		}
	}
}

/** Breaks off a joint in the physics asset of the pawn's mesh
	@return true if successful, or false if the constraint cannot be broken or is already broken
 */
simulated final function bool BreakConstraint(
	KFPawn_Monster InPawn,
	Name InBoneName,
	optional class<KFDamageType> InDmgType,
	optional bool bToggleWeightsOnly = false)
{
	local int JointIndex, DependencyIdx, DependentBoneIdx;
	local DependentBreakSettings CurrentBreakDependency;
	local KFCharacterInfo_Monster MonsterInfo;
	local ParticleSystemComponent PSC;

	if( WorldInfo.NetMode == NM_DedicatedServer )
		return false;

	if( InPawn.mesh == none )
	{
`if(`notdefined(ShippingPC))
		`warn(WorldInfo.TimeSeconds @ self @ GetFuncName() @ "Tried to dismember a mesh with no gore skeleton!!");
		ScriptTrace();
`endif
		return false;
	}

	MonsterInfo = InPawn.GetCharacterMonsterInfo();

	if( InPawn != none &&
		!InPawn.Mesh.IsBrokenConstraint(InBoneName) &&
		MonsterInfo != none  )
	{
		// Keep track that broke at least one constraint off this gore mesh.
		InPawn.bHasBrokenConstraints = TRUE;

		if( bToggleWeightsOnly )
		{
			// switch to alternate weights only
			InPawn.Mesh.ToggleAlternateBoneWeights(InBoneName);
		}
		else
		{
			// break primary constraint and switch to alternate weights
			InPawn.Mesh.BreakConstraint(InBoneName);
		}

		// Attach a gore chunk if specified
		InPawn.HandleGoreChunkAttachments(InBoneName);

		if ( InDmgType != None )
		{
			for( JointIndex = 0; JointIndex < MonsterInfo.GoreJointSettings.length; JointIndex++ )
			{
				if( MonsterInfo.GoreJointSettings[JointIndex].HitBoneName == InBoneName )
				{
					for( DependencyIdx = 0;
						 DependencyIdx < MonsterInfo.GoreJointSettings[JointIndex].DependentBreakGore.length;
						 DependencyIdx++ )
					{
                    	CurrentBreakDependency = MonsterInfo.GoreJointSettings[JointIndex].DependentBreakGore[DependencyIdx];

                        // If the dependancy is either not constrained to any damage types or
						// has the damage type in the list of constraints
                    	if( (CurrentBreakDependency.ConstrainToDamageGroups.length == 0 ||
							 CurrentBreakDependency.ConstrainToDamageGroups.Find(DGT_None) != INDEX_None ||
							 CurrentBreakDependency.ConstrainToDamageGroups.Find(InDmgType.default.GoreDamageGroup) != INDEX_None))
						{
							for( DependentBoneIdx = 0;
								 DependentBoneIdx < CurrentBreakDependency.DependentBones.length;
								 DependentBoneIdx++)
							{
								//`log(GetFuncName()@"Breaking "@CurrentBreakDependency.DependentBones[DependentBoneIdx].BoneName@"because"@InBoneName@"was broken!");
								InPawn.Mesh.BreakConstraint(CurrentBreakDependency.DependentBones[DependentBoneIdx].BoneName);

								// Blood effects
								AttachMutilationBloodEffects(
									InPawn,
									CurrentBreakDependency.DependentBones[DependentBoneIdx].BoneName,
									CurrentBreakDependency.DependentBones[DependentBoneIdx].BloodJets,
									CurrentBreakDependency.DependentBones[DependentBoneIdx].BloodTrails,
									CurrentBreakDependency.DependentBones[DependentBoneIdx].BloodMICParamName);

								// Spawn additional effect if specified
								if( CurrentBreakDependency.DependentBones[DependentBoneIdx].ParticleSystemTemplate != none )
								{
									// NVCHANGE_BEGIN: JCAO - Apply the lightingChannel for the particle from the pawn
									PSC = MiscGoreFXEmitterPool.SpawnEmitter(
										CurrentBreakDependency.DependentBones[DependentBoneIdx].ParticleSystemTemplate,
										InPawn.mesh.GetBoneLocation(
											CurrentBreakDependency.DependentBones[DependentBoneIdx].BoneName)
											);
									PSC.SetLightingChannels(InPawn.PawnLightingChannel);
									// NVCHANGE_END: JCAO - Apply the lightingChannel for the particle from the pawn
								}

								// Attach a gore chunk if specified
								InPawn.HandleGoreChunkAttachments(CurrentBreakDependency.DependentBones[DependentBoneIdx].BoneName);
							}
						}
					}
				}
			}
		}

		return true;
	}

	return false;
}



/** Break-off, hide bone, and play associated effects */
simulated function CrushBone(KFPawn_Monster InPawn, name InHitBoneName)
{
	if ( AllowMutilation() )
	{
		// For simplicity, just call the 'conditional' version with bForceApply=true
		ConditionalApplyPartialGore(InPawn, none, InPawn.mesh.GetBoneLocation(InHitBoneName), vect(0,0,0), InHitBoneName, true);
	}
	else
	{
		// shrink bone without gore FX
		if( BreakConstraint(InPawn, InHitBoneName,,true) )
		{
			InPawn.mesh.HideBoneByName(InHitBoneName, PBO_Term);
		}
	}
}

/** Check if partial gore can be applied on the hit bone for the specified damage type.
	If yes, then apply by chipping one or more of the partial break bones.
	@return true if partial gore was successfully applied
 */
simulated function bool ConditionalApplyPartialGore(
	KFPawn_Monster InPawn,
	class<KFDamageType> InDmgType,
	vector InHitLocation,
	vector InHitDirection,
	name InHitBoneName,
    optional bool bForceApply)
{
	local int i, JointIndex, PartialBreakIndex, ClosestBoneIndex;
	local name ClosestBone;
	local array<name> ClosestBoneList;
	local KFCharacterInfo_Monster MonsterInfo;
	local PartialBreakSettings CurrentPartialBreak;
	local array<name> SearchBoneList;
	local ParticleSystemComponent PSC;

	MonsterInfo = InPawn.GetCharacterMonsterInfo();

	// Find the gore joint settings corresponding to the hit bone
	for( JointIndex = 0; JointIndex < MonsterInfo.GoreJointSettings.length; JointIndex++ )
	{
		if( MonsterInfo.GoreJointSettings[JointIndex].HitBoneName == InHitBoneName )
		{
			// Check all the partial breaks of the hit bone
			for( PartialBreakIndex = 0;
				 PartialBreakIndex < MonsterInfo.GoreJointSettings[JointIndex].BoneShrinkGore.length;
				 PartialBreakIndex++ )
			{
				// Cache current partial break (for sanity)
				CurrentPartialBreak = MonsterInfo.GoreJointSettings[JointIndex].BoneShrinkGore[PartialBreakIndex];

				// If the particular partial break supports the specific damage type
				if(	bForceApply ||
                    (CurrentPartialBreak.ConstrainToDamageGroups.length == 0 ||
					 CurrentPartialBreak.ConstrainToDamageGroups.Find(DGT_None) != INDEX_None ||
					 CurrentPartialBreak.ConstrainToDamageGroups.Find(InDmgType.default.GoreDamageGroup) != INDEX_None
					 ) ||
					 // This is the killing blow, and the killing blow damage type causes this partial break
					( InPawn.TimeOfDeath == WorldInfo.TimeSeconds &&
					 	( CurrentPartialBreak.KillingBlowDamageGroups.length == 0 ||
					   	  CurrentPartialBreak.KillingBlowDamageGroups.Find(DGT_None) != INDEX_None ||
					   	  CurrentPartialBreak.KillingBlowDamageGroups.Find(InDmgType.default.GoreDamageGroup) != INDEX_None
						)
					 )
				   )
				{

                    // Add all partial break bones for the hit bone to the proximity search list
					for( i=0; i < CurrentPartialBreak.PartialBreakBones.length; i++ )
					{
						// Only add the hit bone to the list for the head if it isn't already
						// broken or if the pawn will allow it. That way multiple shots to the
                        // head will chunk off different head chunks with every shot.
                        if( InHitBoneName != 'head' || (!InPawn.HeadBoneAlreadyBroken(CurrentPartialBreak.PartialBreakBones[i].BoneName)
                            && InPawn.ShouldAllowHeadBoneToBreak(CurrentPartialBreak.PartialBreakBones[i].BoneName)) )
						{
                            SearchBoneList.AddItem(CurrentPartialBreak.PartialBreakBones[i].BoneName);
                        }
					}

					// Find closest bone to hit location in the search list
					InPawn.mesh.FindClosestBones(InHitLocation, 1, ClosestBoneList, SearchBoneList, 0.f);

					if( ClosestBoneList.length > 0 )
					{
						// Retrieve the closest bone and it's index in the PartialBreakBones array
						ClosestBone = ClosestBoneList[0];
						ClosestBoneIndex = CurrentPartialBreak.PartialBreakBones.Find('BoneName', ClosestBone);

						if( ClosestBoneIndex >= 0 )
						{
							// Don't let this head bone to break if the pawn won't allow it
							if( InHitBoneName == 'head' && !InPawn.ShouldAllowHeadBoneToBreak(ClosestBone))
							{
								return false;
							}

							// Note: Not checking for bNonBreakableJoint here because the partial
							// gore bones are manually added and hence should support broken constraints.
							if( BreakConstraint(InPawn, ClosestBone,,true) )
							{
								// Shrink bone
								InPawn.mesh.HideBoneByName(ClosestBone, PBO_Term);

								if( InHitBoneName == 'head' )
								{
									InPawn.AddBrokenHeadBone(ClosestBone);
								}

								// Play jet effect if specified
								AttachMutilationBloodEffects(
									InPawn, ClosestBone,
									CurrentPartialBreak.PartialBreakBones[ClosestBoneIndex].BloodJets,
									,
									CurrentPartialBreak.PartialBreakBones[ClosestBoneIndex].BloodMICParamName);

								// Play additional particle effect if specified
								// @note: ignore bDropDetail for CrushBone() (aka bForceApply=TRUE) particle
								if( CurrentPartialBreak.PartialBreakBones[ClosestBoneIndex].ParticleSystemTemplate != none
									&& (!WorldInfo.bDropDetail || bForceApply) )
								{
									// NVCHANGE_BEGIN: JCAO - Apply the lightingChannel for the particle from the pawn
									PSC = MiscGoreFXEmitterPool.SpawnEmitter(
										CurrentPartialBreak.PartialBreakBones[ClosestBoneIndex].ParticleSystemTemplate,
										InHitLocation);
									PSC.SetLightingChannels(InPawn.PawnLightingChannel);
									// NVCHANGE_END: JCAO - Apply the lightingChannel for the particle from the pawn
								}
							}
						}
						else
						{
							`log("ConditionalApplyPartialGore -- On Pawn: " $ InPawn @ " Trying to Work on a bone out of the array, ClosestBone: " $ ClosestBone $ " - InHitBoneName: " $ InHitBoneName, bLogGore);
						}
					}

					return true;
				}
			}
		}
	}

	return false;
}

/** Dismemberment gore effects */
simulated function CauseDismemberment(KFPawn_Monster InPawn, name InHitBoneName, class<KFDamageType> InDmgType)
{
	local int JointIndex, EffectIdx;
	local KFCharacterInfo_Monster MonsterInfo;
	local DismembermentEffect CurrentEffect;
	local ParticleSystemComponent PSC;

	MonsterInfo = InPawn.GetCharacterMonsterInfo();

	for( JointIndex = 0; JointIndex < MonsterInfo.GoreJointSettings.length; JointIndex++ )
	{
		if( MonsterInfo.GoreJointSettings[JointIndex].HitBoneName == InHitBoneName &&
			!MonsterInfo.GoreJointSettings[JointIndex].bNonBreakableJoint )
		{
			if( BreakConstraint(InPawn, InHitBoneName, InDmgType) )
			{
				// Play blood effects
				AttachMutilationBloodEffects(
					InPawn, InHitBoneName,
					MonsterInfo.GoreJointSettings[JointIndex].BloodJets,
					MonsterInfo.GoreJointSettings[JointIndex].BloodTrails,
					MonsterInfo.GoreJointSettings[JointIndex].BloodMICParamName);

				// Spawn any effects if specified
				for( EffectIdx = 0;
					 EffectIdx < MonsterInfo.GoreJointSettings[JointIndex].DismembermentEffects.length;
					 EffectIdx++)
				{
					CurrentEffect = MonsterInfo.GoreJointSettings[JointIndex].DismembermentEffects[EffectIdx];

					if( (CurrentEffect.ConstrainToDamageGroups.length == 0 ||
						CurrentEffect.ConstrainToDamageGroups.Find(DGT_None) != INDEX_None ||
						CurrentEffect.ConstrainToDamageGroups.Find(InDmgType.default.GoreDamageGroup) != INDEX_None) && !WorldInfo.bDropDetail )
					{
						// NVCHANGE_BEGIN: JCAO - Apply the lightingChannel for the particle from the pawn
						PSC = MiscGoreFXEmitterPool.SpawnEmitter(
							CurrentEffect.ParticleSystemTemplate,
							InPawn.mesh.GetBoneLocation(InHitBoneName));
						PSC.SetLightingChannels(InPawn.PawnLightingChannel);
						// NVCHANGE_END: JCAO - Apply the lightingChannel for the particle from the pawn
					}
				}
			}
		}
	}
}

/** Gib gore effects - Explosive Damage Only */
simulated function CauseGibsAndApplyImpulse(
	KFPawn_Monster InPawn,
	class<KFDamageType> InDmgType,
	vector InExplosionOrigin,
	array<name> InGibBoneList,
	ParticleSystem ExplosionEffect,
	vector ExplosionEffectLocation,
	optional name HitBoneName = 'None')
{
	local vector Impulse, BoneLocation;
	local int GibIdx, JointIndex, ExplosionBreakIdx, BoneIdx;
	local Name GibBoneName;
	local bool bBrokenConstraint, bPlayedBloodEffects;
	local KFCharacterInfo_Monster MonsterInfo;
	local ExplosionBreakBone ExplosiveBreakBone;
	local name RBBoneName;
	local ParticleSystemComponent PSC;
	local int NumGibs;
	local float ModifiedImpulseLerpValue;
	local float ModifiedImpulse;
	local float GibImpulseMin, GibImpulseMax;

	MonsterInfo = InPawn.GetCharacterMonsterInfo();

	// We need to scale the impule values based on the # of gibs to disconnect otherwise their impulses are way
	// to high and limbs go flying really far. We perform a linear interpolation
	GibImpulseMax = InDmgType.default.GibImpulseScale;
	GibImpulseMin = GibImpulseMax/2.0f;
	NumGibs = InGibBoneList.Length;
	ModifiedImpulseLerpValue = 1.0f - numGibs/ MonsterInfo.GoreJointSettings.length;
	ModifiedImpulse = lerp(GibImpulseMin, GibImpulseMax, ModifiedImpulseLerpValue);

    for( GibIdx=0; GibIdx<InGibBoneList.length; GibIdx++ )
    {
    	GibBoneName = InGibBoneList[GibIdx];

    	BoneLocation = InPawn.mesh.GetBoneLocation(GibBoneName);
		Impulse =  InDmgType.default.RadialDamageImpulse * InDmgType.default.bPointImpulseTowardsOrigin
					? Normal((InPawn.Location - InExplosionOrigin) + (vect(0,0,1) * InDmgType.default.ImpulseOriginLift))
					: Normal(BoneLocation - InExplosionOrigin);
		Impulse *= MonsterInfo.ExplosionImpulseScale*ModifiedImpulse;

		for( JointIndex = 0; JointIndex < MonsterInfo.GoreJointSettings.length; JointIndex++ )
		{
        	if( MonsterInfo.GoreJointSettings[JointIndex].HitBoneName == GibBoneName &&
				!MonsterInfo.GoreJointSettings[JointIndex].bNonBreakableJoint )
	    	{
	    		// Play blood effects only if the joint was successfully broken
				if( BreakConstraint(InPawn, GibBoneName, InDmgType) )
				{
					bBrokenConstraint = true;

					// If this explosion is not triggered by a hit explosion joint (e.g. grenade explosion)
					// then use settings blood effect settings from the joint's primary dismemberment
					if( HitBoneName == 'None' ||
						HitBoneName == '' )
					{
						AttachMutilationBloodEffects(
							InPawn, GibBoneName,
							MonsterInfo.GoreJointSettings[JointIndex].BloodJets,
							MonsterInfo.GoreJointSettings[JointIndex].BloodTrails,
							MonsterInfo.GoreJointSettings[JointIndex].BloodMICParamName);
					}
					else
					{
					    bPlayedBloodEffects = false;

						// Look for the HitBoneName in the GoreJointSettings list
						for( JointIndex = 0;
							 !bPlayedBloodEffects && JointIndex < MonsterInfo.GoreJointSettings.length;
							 JointIndex++ )
						{
							if( MonsterInfo.GoreJointSettings[JointIndex].HitBoneName == HitBoneName )
							{
								// Go through each hit explosion break for the specified hit bone name and try
								// to find the GibBoneName in the list. Take blood effect settings from the first
								// entry that matches the gib bone.
      							for( ExplosionBreakIdx = 0;
							 		 !bPlayedBloodEffects && ExplosionBreakIdx < MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore.length;
									 ExplosionBreakIdx++ )
								{
							    	for( BoneIdx = 0;
							    		 BoneIdx < MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].BreakBones.length;
							    		 BoneIdx++ )
							    	{
							    		ExplosiveBreakBone = MonsterInfo.GoreJointSettings[JointIndex].HitExplosionGore[ExplosionBreakIdx].BreakBones[BoneIdx];
							    		if( ExplosiveBreakBone.BoneName == GibBoneName )
							    		{
							    			AttachMutilationBloodEffects(
												InPawn, GibBoneName,
												ExplosiveBreakBone.BloodJets,
												ExplosiveBreakBone.BloodTrails,
												ExplosiveBreakBone.BloodMICParamName);

											bPlayedBloodEffects = true;
											break;
							    		}
							    	}
								}
							}
						}
					}
				}
			}
		}

		// Get the rigidbody bone that matches the hit bone name
		RBBoneName = InPawn.GetRBBoneFromBoneName(GibBoneName);
		// Apply impulse after trying to break the constraint
		InPawn.mesh.AddImpulse(Impulse, BoneLocation, RBBoneName);
    }

	// If an explosion effect has been specified, spawn it now.
	// Do not spawn effect if no constraints were broken or if the effect has already been played.
    if( bBrokenConstraint && !InPawn.bPlayedExplosionEffect && ExplosionEffect != none )
    {
		// NVCHANGE_BEGIN: JCAO - Apply the lightingChannel for the particle from the pawn
    	PSC = MiscGoreFXEmitterPool.SpawnEmitter(ExplosionEffect, ExplosionEffectLocation);
		PSC.SetLightingChannels(InPawn.PawnLightingChannel);
		// NVCHANGE_END: JCAO - Apply the lightingChannel for the particle from the pawn
    	InPawn.bPlayedExplosionEffect = true;
    }
}

/** Spawn a giblet caused by obliteration */
simulated function KFGiblet SpawnGiblet(vector GibLocation, rotator GibRotation, float MomentumScale, KFGibletInfo InGibInfo, vector InDamageOrigin, optional class<KFDamageType> InDamageType)
{
	local KFGiblet Gib;
	local bool bSpinGib;
	local vector ImpluseDir, ModifiedImpulseDir;

 	if( WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.bDropDetail || WorldInfo.GetDetailMode() == DM_Low )
	{
		return None;
	}

	// Spawn gib at the location of the pawn
	Gib = Spawn(class'KFGame.KFGiblet', self, , GibLocation, GibRotation);
	Gib.SetMesh(InGibInfo);

	if ( Gib != None )
	{
		// Take input impulse dir and modify it to face upwards -->
		// Halfway between input and WorldUp. Divide by 2 is irrelevant for normal vector
		ImpluseDir = Normal(Gib.Location - InDamageOrigin);
		ModifiedImpulseDir = Normal(ImpluseDir + vect(0,0,1));

		// START DEBUG
		// DrawDebugLine(PawnLocation, PawnLocation + 200.f*ImpluseDir, 255, 0, 0, TRUE);
		// DrawDebugLine(PawnLocation, PawnLocation + 200.f*ModifiedImpulseDir, 255, 255, 255, TRUE);
		// END DEBUG

		// add initial impulse
		if ( InDamageType != None )
		{
			Gib.Velocity = ModifiedImpulseDir * FMin(InDamageType.default.RadialDamageImpulse, InGibInfo.GibletMaxSpeed);
		}

		// Randomize gib velocity +/- 10%;
        Gib.Velocity = (Gib.Velocity + Gib.Velocity * 0.2) - (FRand() * Gib.Velocity * 0.2);

        // Scale the velocity by the momentum scale from the explosion or damage
        Gib.Velocity *= MomentumScale;

		Gib.GibMeshComp.WakeRigidBody();
		Gib.GibMeshComp.SetRBLinearVelocity(Gib.Velocity, false);

		// Random chance to spin gibs
		bSpinGib = FRand() > 0.5;
		if ( bSpinGib )
		{
			Gib.GibMeshComp.SetRBAngularVelocity(VRand() * 500, false);
		}

		// Auto-destruct after sometime
		Gib.SetTimer(GibletLifetime * GoreFXLifetimeMultiplier, false, 'LifespanTimer');
	}

	return Gib;
}

/** Obliteration effects */
simulated function SpawnObliterationBloodEffect(KFPawn InPawn)
{
	local ParticleSystemComponent PSC;
	local KFCHaracterInfo_Monster MonsterInfo;
	local vector ParticleLocation;

	// Play obliteration sound
	InPawn.SoundGroupArch.PlayObliterationSound(InPawn);

	MonsterInfo = KFCharacterInfo_Monster(InPawn.GetCharacterInfo());
	// Particle location is the spine. If no spine, then it will be the pawn's location.
	ParticleLocation = InPawn.Mesh.GetBoneLocation('Spine');
	if( IsZero(ParticleLocation) )
	{
		ParticleLocation = InPawn.Location;
	}
	PSC = MiscGoreFXEmitterPool.SpawnEmitter(MonsterInfo.ObliterationEffectTemplate, ParticleLocation);
	PSC.SetLightingChannels(InPawn.PawnLightingChannel);
}

/** @deprecated Obliteration effects */
simulated function CauseObliteration(KFPawn InPawn, vector InDamageOrigin, class<KFDamageType> InDamageType, optional float MomentumScale = 1.f)
{
	local KFCharacterInfo_Monster MonsterInfo;
	local int GibletIndex, BoneIndex;
	local vector PawnLocation;
	local KFPawnSoundGroup PawnSoundGroup;
	local KFGiblet Gib;
	local vector Loc;
	local rotator Rot;
	local Quat BoneQuat;
	local bool bSpawnedAGibForThisIndex;

	// Cache the pawn's location
	PawnLocation = InPawn.Location;
	PawnSoundGroup = InPawn.SoundGroupArch;

	// Play obliteration sound
	PawnSoundGroup.PlayObliterationSound(InPawn);

	// Destroy the pawn
	InPawn.Mesh.SetHidden(TRUE);

	// Remove the pawn from the corse pool
	// NOTE: By the time obliteration happens, the corpse has already been added to the corpse pool becase PlayDying is handled earler.
	RemoveAndDeleteCorpse(CorpsePool.Find(InPawn));

	MonsterInfo = KFCharacterInfo_Monster(InPawn.GetCharacterInfo());
	if ( MonsterInfo != None )
	{
        SpawnObliterationBloodEffect(InPawn);

		// Spawn giblets - limbs, soft bodies, etc.
		for( GibletIndex = 0; GibletIndex < MonsterInfo.GibletSettings.length; GibletIndex++ )
		{
        	bSpawnedAGibForThisIndex=false;

            if( MonsterInfo.GibletSettings[GibletIndex].GibletBones.length > 0 )
        	{
                for( BoneIndex = 0; BoneIndex < MonsterInfo.GibletSettings[GibletIndex].GibletBones.length; BoneIndex++ )
            	{
                    // Randomly skip some of the gibs so we don't always spawn the exact same set
                    if( MonsterInfo.GibletSettings[GibletIndex].GibletBones.length > 1 && (BoneIndex < (MonsterInfo.GibletSettings[GibletIndex].GibletBones.length - 1)
                    || bSpawnedAGibForThisIndex ) )
                    {
                        if( FRand() < 0.35 )
                        {
                            continue;
                        }
                    }

                    // Find the location/roation of the bones where this gib should spawn at
                    Loc = InPawn.Mesh.GetBoneLocation(MonsterInfo.GibletSettings[GibletIndex].GibletBones[BoneIndex]);
                	BoneQuat = InPawn.Mesh.GetBoneQuaternion(MonsterInfo.GibletSettings[GibletIndex].GibletBones[BoneIndex]);
                	Rot = QuatToRotator(BoneQuat);

        			Gib = SpawnGiblet(Loc, Rot, MomentumScale, MonsterInfo.GibletSettings[GibletIndex], InDamageOrigin, InDamageType);
        			bSpawnedAGibForThisIndex=true;
        			if ( Gib != None )
        			{
        				Gib.SoundGroup = PawnSoundGroup;
        			}
        		}
        	}
        	else
        	{
                // Fallback to spawning at the pawn location if the info isn't set for the bones in the archetype
                Loc = PawnLocation;
    			Gib = SpawnGiblet(Loc, Rot, MomentumScale, MonsterInfo.GibletSettings[GibletIndex], InDamageOrigin, InDamageType);
    			bSpawnedAGibForThisIndex=true;
    			if ( Gib != None )
    			{
    				Gib.SoundGroup = PawnSoundGroup;
    			}
			}
		}
	}
}

/*********************************************************************************************
 * Ragdoll
 *********************************************************************************************/

/** Remove at least one corpse from the pool to make room for a fresh body */
native function bool	MakeRoomForCorpse(KFPawn InCorpse);
/** Rate a corpse priority based on last render time and other parameters */
native function	float	RateCorpse(KFPawn InCorpse);
/** Cleanup */
native function bool	RemoveAndDeleteCorpse(int PoolIdx);
native function bool	DeleteCorpse(KFPawn InCorpse);

/** Add pawn to the dead body pool */
simulated function AddCorpse(KFPawn NewCorpse)
{
	// if the pool is full try to remove something first
	if ( CorpsePool.Length >= MaxDeadBodies )
	{
		MakeRoomForCorpse(NewCorpse);
	}

	if ( CorpsePool.Length < MaxDeadBodies )
	{
		// If there is room, disable lifespan and add to the pool
		NewCorpse.LifeSpan = 0.f;
		CorpsePool.AddItem(NewCorpse);
	}
	else
	{
		// If there is still no room, delete the new corpse
		DeleteCorpse(NewCorpse);
	}
}

/** Partial Reset */
function ResetPersistantGore(optional bool bOnRespawn)
{
	local int i;

	if ( bOnRespawn )
	{
		// remove all humans from the corpse pool during respawn
		for (i = CorpsePool.Length-1; i >= 0; i--)
		{
			if ( CorpsePool[i].IsA('KFPawn_Human') )
			{
				RemoveAndDeleteCorpse(i);
			}
		}
	}
}

/** Level was reset without reloading */
event Reset()
{
	local int i;

	for (i = 0; i < CorpsePool.Length; i++)
	{
		CorpsePool[i].Destroy();
	}
	CorpsePool.Remove(0, CorpsePool.Length);

	ClearPersistentBloodSplats();
}

cpptext
{
	virtual UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
}

defaultproperties
{
	TickGroup=TG_PreAsyncWork
	// Actor
	bTickIsDisabled=false

	// Corpse Pool
	MaxCorpseOffscreenTime=60.f
	MaxCorpseOffscreenDistance=5000.f;

	// Persistent splats
	CurrentSplatIdx=0

	// Debugging
	bShowPersistentBloodTraces=false
}
