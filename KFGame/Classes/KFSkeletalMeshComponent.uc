//=============================================================================
// KFSkeletalMeshComponent
//=============================================================================
// SMC with FOV settings
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Based on UDKSkeletalMeshComponent Copyright 1998-2012 Epic Games, Inc.
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFSkeletalMeshComponent extends SkeletalMeshComponent
	native;

cpptext
{
	/** Creates a FKFSkeletalMeshSceneProxy (defined in UTWeapon.cpp) */
	virtual FPrimitiveSceneProxy* CreateSceneProxy() override;

	/** Default tick. */
	virtual void Tick(FLOAT DeltaTime) override;

	/** The KFSkeletalMesh ticks during async as well as post async, performing different work. */
	void TickPostAsync(FLOAT DeltaTime);

	/** Overridden ProcessRootMotion so that we can defer root motion until post asycn work. */
	virtual void ProcessRootMotion( FLOAT DeltaTime, FBoneAtom& ExtractedRootMotionDelta, INT& bHasRootMotion ) override;

#if __TW_HEADSCALE_
    virtual float GetHeadBoneScale() override { return HeadBoneScale; }
#endif
}


/** This variable is set during async tick so that we have the cached value when we tick physics calls in the post tick. */
var BoneAtom CachedExtractedRootMotionDelta;

/** This variable is set during async tick so that we have the cached value when we tick physics calls in the post tick. */
var int bCachedHasRootMotion;

/** This variable is set during async tick so that we have the cached value when we tick physics calls in the post tick. */
var bool bNeedsProcessRootMotion;

/** This changes the FOV used for rendering the skeletal mesh component. A value of 0 means to use the default. */
var() const float FOV;

/** whether textures are currently forced loaded */
var		bool		bForceLoadTextures;

/** When this component is ticking in async time, we need to know if there is pending work that needs to be ticked in post async
 * because we actually switch during ragdoll to post async and don't want to perform deferred tick work.
 */
var 	bool		bPendingDeferredWork;

/** when to clear forced streaming */
var		float		ClearStreamingTime;

/**
 * If > 0, ensure the DeltaTime does not go above this value.
 * Useful when issuing tick notifies (e.g. Hitbox collision) is critical
 */
var() float MinTickTimeStep;

/** Scale to use when doing line traces against the head bone */
var() float HeadBoneScale;

/**
  * Force streamed textures to be loaded.  Used to get MIPS streamed in before weapon comes up
  * @PARAM bForcePreload if true causes streamed textures to be force loaded, if false, clears force loading
  */
simulated event PreloadTextures(bool bForcePreload, float ClearTime)
{
	local int idx;

	bForceLoadTextures = bForcePreload;
	ClearStreamingTime = ClearTime;

	for (Idx = 0; Idx < Materials.Length; Idx++)
	{
		if (Materials[Idx] != None)
		{
			Materials[Idx].SetForceMipLevelsToBeResident(true, bForcePreload, -1.0f);
		}
	}
}

/** changes the value of FOV */
native final function SetFOV(float NewFOV);

/**
* Called by AnimNotify_PlayParticleEffect
* Looks for a socket name first then bone name
*
* @param AnimNotifyData The AnimNotify_PlayParticleEffect which will have all of the various params on it
*/
event bool PlayParticleEffect( const AnimNotify_PlayParticleEffect AnimNotifyData )
{
	local KFParticleSystemComponent PSC;

	// Assign 1st person particles to match depth and FOV
	// abridged version (only attached, non-extreme content) from Super()
	if ( DepthPriorityGroup == SDPG_Foreground
		&& AnimNotifyData.bAttach
		&& !AnimNotifyData.bIsExtremeContent )
	{
		PSC = new(self) class'KFParticleSystemComponent';  // move this to the object pool once it can support attached to bone/socket and relative translation/rotation
		PSC.SetTemplate( AnimNotifyData.PSTemplate );
		PSC.SetDepthPriorityGroup(SDPG_Foreground);
		PSC.SetFOV(FOV);
		if (AnimNotifyData.bUsePostUpdateWorkTickGroup)
		{
			PSC.SetTickGroup(TG_PostUpdateWork);
		}

		if( AnimNotifyData.SocketName != '' )
		{
			//`log( "attaching AnimNotifyData.SocketName" );
			AttachComponentToSocket( PSC, AnimNotifyData.SocketName );
		}
		else if( AnimNotifyData.BoneName != '' )
		{
			//`log( "attaching AnimNotifyData.BoneName" );
			AttachComponent( PSC, AnimNotifyData.BoneName );
		}

		PSC.ActivateSystem(true);
		PSC.OnSystemFinished = SkelMeshCompOnParticleSystemFinished;

		// We use this to keep track of particle systems spawned by animations
		if( PSC != none && Owner != none )
		{
			Owner.OnAnimNotifyParticleSystemSpawned( AnimNotifyData, PSC );
		}

		return true;
	}

	return Super.PlayParticleEffect(AnimNotifyData);
}

/** Returns the duration (in seconds) for a named AnimSequence. Returns 0.f if no animation. */
final function float GetAnimInterruptTime(Name AnimSeqName)
{
	return GetAnimNotifyTime(AnimSeqName, class'KFAnimNotify_Interrupt');
}

/** Returns the duration (in seconds) for a named AnimSequence. Returns 0.f if no animation. */
final function float GetReloadAmmoTime(Name AnimSeqName)
{
	return GetAnimNotifyTime(AnimSeqName, class'KFAnimNotify_ReloadAmmo');
}

/** Returns the duration (in seconds) for a named AnimSequence. Returns 0.f if no animation. */
final function float GetAnimNotifyTime(Name AnimSeqName, class<AnimNotify> NotifyClass)
{
	local int i;
	local AnimSequence AnimSeq;

	AnimSeq = FindAnimSequence(AnimSeqName);
	if( AnimSeq == None || AnimSeq.RateScale <= 0.f )
	{
		return 0.f;
	}

	for(i=0; i<AnimSeq.Notifies.length; i++)
	{
		if( AnimSeq.Notifies[i].Notify == none )
		{
			continue;
		}

		if(ClassIsChildOf(AnimSeq.Notifies[i].Notify.Class, NotifyClass))
		{
			return (AnimSeq.Notifies[i].Time / AnimSeq.RateScale);
		}
	}

	// see SkeletalMeshComponent::GetAnimLength
	return (AnimSeq.SequenceLength / AnimSeq.RateScale);
}

DefaultProperties
{
	FOV=0.0
    HeadBoneScale=1.0
}
