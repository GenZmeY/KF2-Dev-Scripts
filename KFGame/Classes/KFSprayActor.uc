//=============================================================================
// KFSprayActor
//=============================================================================
// Based on GOW2-3 FlameSpray tech
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSprayActor extends Actor
	placeable
	native(Effect)
	config(Game);

/*********************************************************************************************
* Spray SkeltalMesh
********************************************************************************************* */

/** Editable SkeletalMesh set by the archetype */
var(SprayMesh) const SkeletalMesh SkelMesh;

/** Anim set to use for the spray anims */
var(SprayMesh) AnimSet SprayAnimSet;

/** Anim set to use for the spray anims */
var(SprayMesh) AnimTree SprayAnimTreeTemplate;

/** The skeletal mesh that represents the core of the spray effect */
var transient KFSkeletalMeshComponent SkeletalSprayMesh;

/** Whether to spawn dynamic lights for the spray actor */
var globalconfig bool bAllowSprayLights;

/** Socket to attach the spray actor to */
var(SprayMesh) name SpraySocketName;
/*********************************************************************************************
* Gravity Scaling
********************************************************************************************* */
/** Scales the gravity to apply to this object. X, Y define ramp-in range. */
var() const vector2D	GravityScaleRange;
/** How long it takes the gravity to fully ramp in. */
var() const float		GravityScaleInTime;

/*********************************************************************************************
* Per-bone info for the spray's bone chain
********************************************************************************************* */
struct native SprayBoneInfo
{
	var() name		BoneName;
	var int			BoneIndex;				// transient, filled in at startup
	var() float     MaterialParam;
	var() float     BoneScale;

	// per-bone effects info
	var() float EffectScale;

	/** General Particle System Template. If a first person template exists, it will be used for first person, otherwise this standard template will be used */
	var() ParticleSystem		ParticleSystemTemplate;
	/** First Person Particle System Template. If this is set it will override the standard ParticleSystemTemplate in first person */
	var() ParticleSystem		ParticleSystemTemplate1P;

	// First person and third person
    var transient KFParticleSystemComponent BonePSC0;
    // First person only
	var transient KFParticleSystemComponent BonePSC1;

	/** This denotes the location of this bone along the seed stream.  Filled in by the skel control when it aligns the bones to the seeds. */
	var transient float SeedChainLoc;
	var transient vector LastLoc;			// most recently known location

	var() float ParticleActivationDelay;
};
/** Defines the main bone chain.  Should be sorted front to back. */
var(SprayBoneChain) array<SprayBoneInfo> BoneChain;

/** True to spawn the per-bone FX, false to skip it. */
var(SprayBoneChain) bool        bDoPerBoneSprayFX;
/** Easy parameter for scaling all per-bone fx. */
var(SprayBoneChain) float		PerBoneSprayFXGlobalScale;

/** True to spawn the first person effects, false to spawn third person effects. */
var                 bool		bDoFirstPersonFX;

/*********************************************************************************************
* Splash and Impact Effects
********************************************************************************************* */
// Configurable partticle systems
/** Effect to play when the flame is deflecting off a surface */
var(SpraySplash)    ParticleSystem					SplashGlancingEffect;
/** Effect to play when the flame hitting a surface directly */
var(SpraySplash)    ParticleSystem					SplashDirectEffect;
/** Effect to play when the flame hitting a pawn */
var(SpraySplash)    ParticleSystem					SplashPawnEffect;

/** Impact info (sfx, vfx, etc.), so that each flame type can have different effects if desired */
var (SpraySplash)   KFImpactEffectInfo              ImpactEffects;

// Internal particle system components
var	transient       KFParticleSystemComponent		   CurrentSplashEffect;
var transient       KFParticleSystemComponent		   SplashGlancingPSC;
var transient       KFParticleSystemComponent		   SplashDirectPSC;
var transient       KFParticleSystemComponent		   SplashPawnPSC;
var transient       KFParticleSystemComponent		   SplashMaterialBasedPSC;

/** Looping sound to play when the spray hits a pawn. */
var(SpraySplash) AkEvent    SplashPawnAKEvent;
/** Looping sound to play when the spray hits direct. */
var(SpraySplash) AkEvent    SplashDirectAKEvent;
/** Looping sound to play when the spray hits a glancing shot. */
var(SpraySplash) AkEvent    SplashGlancingAKEvent;
/** Event to play to stop the splash pawn looping sound. */
var(SpraySplash) AkEvent    SplashPawnStopAKEvent;
/** Event to play to stop the splash direct looping sound. */
var(SpraySplash) AkEvent    SplashDirectStopAKEvent;
/** Event to play to stop the splash glancing looping sound. */
var(SpraySplash) AkEvent    SplashGlancingStopAKEvent;

/** Currently playing splash AKEvent sound */
var protected AkEvent           CurrentSplashAKEvent;
/** Audio Component for playing splash AKEvents */
var protected AkComponent       CurrentSplashAKC;

var(SpraySplash) float          SplashGlancingDotLimit;
var(SpraySplash) int            LastBoneChainIndexThatCanSpawnSplashEffects;

/** The maximum distance in Unreal Units that "scorched" decals will be drawm from this spray actor "burning" or hitting things */
var(SpraySplash) float          MaxDecalEffectDistance;

/** The maximum distance in Unreal Units that "scorched" decals will be drawm from this spray actor "burning" or hitting things */
var(SpraySplash) float          ImpactProjectileInterval;

/** Class to spawn at the ImpactProjectileInterval when the spray is impacting something. Used for things like fire on the ground/walls */
var(SpraySplash) class<KFProjectile>   ImpactProjectileClass;

/*********************************************************************************************
* Splash and Impact Effect Optimization
********************************************************************************************* */
const MAX_SPRAY_FX_INFOS = 20;

/** Information about when and where we have spawned impact projectiles */
struct native SprayFxInfo
{
	var vector Location;
	var float  TimeStamp;
};

/** used as circular array of infos */
var transient SprayFxInfo SprayFxInfos[MAX_SPRAY_FX_INFOS];

/** used as index into circular array */
var transient int CurrSprayFxLocIdx;

/*********************************************************************************************
* Splash orientation smoothing
********************************************************************************************* */
var(SpraySplash) float	SplashRotInterpSpeed;
var(SpraySplash) float	SplashLocInterpSpeed;
var transient rotator	LastSplashRot;
var transient vector	LastSplashLoc;

/*********************************************************************************************
* Optional spray lights
********************************************************************************************* */
struct native SprayLight
{
	var() PointLightComponent  Light;
	var() int                  BoneChainIndex;
	var() float                FlickerIntensity;
	var() float                FlickerInterpSpeed;
	var() float                LastLightBrightness;
};
var(SprayLights) array<SprayLight> SprayLights;

/*********************************************************************************************
* Materials
* Materials (index 1 & 2) in the mesh have a parameter named "Heat" which will ramp from
* MaterialHetRange.X to MaterialHeatRange.Y over MaterialHeatRampTime seconds.
********************************************************************************************* */
var MaterialInstanceConstant	MIC_SprayMat0;
var MaterialInstanceConstant	MIC_SprayMat1;
var MaterialInstanceConstant	MIC_SprayMat2;
var(SprayMaterials) vector2d    MaterialHeatRange;
var(SprayMaterials) float       MaterialHeatRampTime;

var(SprayMaterials) float       MatFadePow;

var(SprayMaterials) float       MaterialFadeOutTime;
var transient float				MaterialCurrentFadeVal;

/** This emitter is spawned when firing starts, and is attached to the front bone. */
var(SprayFX)    ParticleSystem	SprayStartEffect;

/** Internal particle system component for the Spray Start Effect. */
var transient   KFParticleSystemComponent   SprayStartPSC;

/** Effect to play when the stopping firing. Functionality to play this must be implemented in the actor that this flame is attached to, since the sprayactor itself gets detached when firing stops.  */
var(SprayFX)    ParticleSystem	SprayEndEffect;

/*********************************************************************************************
* Damage Handling
********************************************************************************************* */
/** How far the spray spawns should rotate */
var(SprayDamage) int		AimAdjustYaw;

/** How often to apply spray or splash damage */
var(SprayDamage) float  DamageInterval;

/** Damage amounts done at DamageInterval. X = damage closest to nozzle, Y = damage at far end of spray */
var(SprayDamage) vector2d	SprayDamage;
/** Range over which to scale the damage (see SprayDamageSec vars) */
var(SprayDamage) vector2d	SprayDamageScaleDistRange;

/** Damage type to deliver */
var(SprayDamage) class<KFDamageType>	MyDamageType<AllowAbstract>;

/** Radius within which to do splash damage */
var(SprayDamage) float	SplashDamageRadius;
/** Damage amount to do from splash damage */
var(SprayDamage) float	SplashDamage;
/** How much to reduce damage as you get farther away from the origin of where splash damage is occuring */
var(SprayDamage) float	SplashDamageFalloffExponent;
/** What percentage of splash damage should get applied to the instigator */
var(SprayDamage) float	SplashDamageInstigatorDamageScale;

/** The flame spray can touch/collide/hit teammates */
var(SprayDamage) bool  bCollideWithTeammates;

/** Scales the momentum for damage taken */
var(SprayDamage) float  MomentumScale;

/** How much damage will be modified based on current weapon upgrade */
var				 float  DamageModifier;

struct native DamagedActorInfo
{
    /** The Actor that was hit */
	var Actor HitActor;
	/** How much incremental damage that has accumulated that is less than a full integer of damage */
	var float RemainingDamage;
	/** When this actor was hit */
	var float HitTime;
};

/** Stores a list of recently damaged actors. */
var array<DamagedActorInfo> RecentlyDamagedActors;

/** This spray actor is for visuals only, so don't do any damage */
var(SprayDamage) bool   bVisualOnly;

/*********************************************************************************************
* Collision handling
********************************************************************************************* */
struct native SprayMeshContact
{
	/** ChainIndex of the bone that made contact. */
	var int					BoneChainIndex;
	var Actor				Actor;
	var vector				ContactPosition;
	var vector				ContactNormal;
	var PhysicalMaterial	PhysicalMaterial;
	var name BoneName;
};

/** This is the highest (i.e. in the bone hierarchy) contact of the Spray mesh. */
var private transient SprayMeshContact		HighestSprayMeshContactThisTick;
var private transient Actor		CurrentSprayedActor;
var private transient bool					bSprayMeshCollidedThisTick;
var private transient bool					bSprayMeshCollidedLastTick;
/** How long the Spray mesh has been touching something */
var transient float							bSprayMeshCollisionDuration;

/** Enables per-poly collision, instead of simplified. */
var(SprayCollision) bool bDoCollideComplex;

/** Will always trace with Extent traces for the flame mesh collision checks. Slower, but will hit the collision cylinder of pawns making them easier to hit */
var(SprayCollision) bool bUseExtentTracing;

var(SprayCollision) int MaxSprayMeshesCollided;

/*********************************************************************************************
* Animation nodes & Skeltal controls
********************************************************************************************* */
var transient AnimNodeBlendList	AnimBlendNode;
var transient AnimNodeSequence	StartSpraySeqNode;
var transient AnimNodeSequence	EndSpraySeqNode;
/** Ref to bone scaling skelcontrol */
var transient KFSkelControl_SprayScaling ScalingSkelControl;

/*********************************************************************************************
* Spray Seeds
* Seeds are spewed like particles from the spray's origin, and the spray skeletal mesh is
* fitted to this seed chain.
********************************************************************************************* */
struct native SpraySeed
{
	var vector	Location;
	var vector	Velocity;
	var float	Age;
};
var transient array<SpraySeed> Seeds;

/** How fast the seeds are traveling at spawn.  Higher speeds == stiffer feeling spray. */
var(SpraySeed) float	SeedSprayVel;
/** Seed deceleration as it travels.  Higher deceleration == softer spray at the far end. */
var(SpraySeed) float	SeedDecel;
/** Seeds expire after this time.  Keep as short as is reasonable for memory/efficiency reasons. */
var(SpraySeed) float	SeedMaxAge;
/** Don't expire any seeds if seed chain length is below this (set this to be longer than the Spray mesh). */
var(SpraySeed) float	SeedMinChainLength;
/** Fixed-timestep simulation frequency for updating seed chain*/
var(SpraySeed) float	SeedSimFreq;
/** Accumlator for simulation time, holds leftovers between updates. */
var transient float	SeedSimTimeRemaining;
var(SpraySeed) float    SeedWarmupTime;
/** Downward velocity if you want the spray to taper downward over a distance. */
var(SpraySeed) float    VelocityScaleZ;

/*********************************************************************************************
* Instigator Handling
********************************************************************************************* */
/** KFPawn who is firing us, or None if appropriate.  Use this instead of Instigator. */
var transient KFPawn		OwningKFPawn;
/** Actor that is firing when fired from dummy fire */
var transient Actor			DummyFireParent;
/** Controller of pawn who fired, in case pawn dies */
var transient Controller	InstigatorController;

/*********************************************************************************************
* Miscellaneous
********************************************************************************************* */
var transient bool	bWaitingToDestroy;
var transient bool	bDetached;
var transient float	CurrentAge;
var transient bool	bSkeletonHasBeenUpdated;
/** How fast the spray is rotating */
var transient float	RotationSpeed;
/** Rotation last tick.  Used to modulate pitch on looping audio. */
var private transient Rotator LastRotation;
var transient bool	bSplashActive;

/*********************************************************************************************
* Debugging
********************************************************************************************* */
/** Toggles bone rendering. For debugging. */
var(SprayDebug) bool bDebugShowBones;
/** Toggles collision rendering. For debugging. */
var(SprayDebug) bool bDebugShowCollision;
/** Toggles rendering of the splash damage radius. For debugging. */
var(SprayDebug) bool bDebugShowSplashRadius;
/** True to make player use third person particle systems. */
var(SprayDebug) bool bDebugForceNonPlayerParticles;
/** Toggles rendering of Spray seeds. For debugging. */
var(SprayDebug) bool bDebugShowSeeds;
 /** Log out direct damage information*/
var(SprayDebug) bool bDebugDirectDamage;
 /** Log out splash damage information*/
var(SprayDebug) bool bDebugSplashDamage;
 /** Log out light information*/
var(SprayDebug) bool bDebugSprayLights;

cpptext
{
public:
	virtual FLOAT GetGravityZ();
	virtual void TickSpecial( FLOAT DeltaSeconds );

	/** Returns the number of hits, if line misses this returns 0, will stop at MaxSprayMeshesCollided */
	INT SprayMeshLineCheck(const FVector& End, const FVector& Start, DWORD TraceFlags, const FVector& Extent, TArray<AActor*>& arrActorsHit, INT BoneChainIndex=INDEX_NONE, INT CurrentNumHit=0);
};

/*********************************************************************************************
* Native functions
********************************************************************************************* */
native final function UpdateSeeds( float DeltaTime );
/** Update Per Bone Fire FX information. */
native simulated function UpdatePerBoneSprayFX( float DeltaTime );
native simulated private final function UpdateSplashes( float DeltaTime );
simulated native private function DestroyIfAllEmittersFinished();
native simulated protected function SetBoneSpawnParticlesActive( ParticleSystemComponent PSC, bool bActive );
/** For debugging.  Renders boxes at the bone positions. */
simulated native final function DebugRenderBones();

/**
 * Calculate actual damage.
 * Server only.
 */
native function private float GetDamage(float HitDist, Actor HitActor);

event PreBeginPlay()
{
	if ( SkeletalSprayMesh != None )
	{
		if ( SprayAnimSet != None )
		{
			SkeletalSprayMesh.AnimSets[0] = SprayAnimSet;
		}

		if ( SkelMesh != none )
		{
			// set the skeletal mesh from our archetype to the WeaponAttachment
			SkeletalSprayMesh.SkeletalMesh = SkelMesh;
		}

        if( SprayAnimTreeTemplate != none )
        {
			// set the skeletal mesh from our archetype to the WeaponAttachment
			SkeletalSprayMesh.SetAnimTreeTemplate(SprayAnimTreeTemplate);
        }

		//WeapAnimNode = AnimNodeSequence(WeapMesh.Animations);
	}

 	super.PreBeginPlay();
}

simulated function PostBeginPlay()
{
	local bool bDebugDelayFX;

	super.PostBeginPlay();

	if( Instigator == none )
	{
		bDebugDelayFX = true;
	}
	// find owner pawn, handles boomer special case.
	OwningKFPawn = FindOwningKFPawn();
	if( OwningKFPawn != None)
	{
		InstigatorController = OwningKFPawn.Controller;
	}
	if( !bDebugDelayFX )
	{
		SetupFX();
	}
}

/** Notification that a direct impact has occurred. */
event ProcessDirectImpact()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(InstigatorController);

    if( KFPC != none )
    {
        KFPC.AddShotsHit(1);
    }
}

/**
 * Adjust the FOV when used in first person
 */
simulated function SetFOV( float NewFOV )
{
    local int Idx;

	// make sure fire particles got destroyed
	for (Idx = 0; Idx < BoneChain.length; ++Idx)
	{
		if( BoneChain[Idx].BonePSC0 != None)
		{
			BoneChain[Idx].BonePSC0.SetFOV(NewFOV);
		}
		if( BoneChain[Idx].BonePSC1 != None)
		{
			BoneChain[Idx].BonePSC1.SetFOV(NewFOV);
		}
	}

    SprayStartPSC.SetFOV(NewFOV);
    if( CurrentSplashEffect != none )
    {
        CurrentSplashEffect.SetFOV(NewFOV);
    }
    SplashGlancingPSC.SetFOV(NewFOV);
    SplashDirectPSC.SetFOV(NewFOV);
    SplashPawnPSC.SetFOV(NewFOV);
    SplashMaterialBasedPSC.SetFOV(NewFOV);
    SprayStartPSC.SetFOV(NewFOV);
    SkeletalSprayMesh.SetFOV(NewFOV);
}

simulated function SetupFX()
{
	local int ChainIdx, Idx;

	CacheAnimNodes();
	SetupPerBoneFireFX();

	// we want to set splash pos/rot in world space
	if( SplashDirectPSC != None)
	{
		SplashDirectPSC.SetTemplate(SplashDirectEffect);
		SplashDirectPSC.SetAbsolute( true, true, true );
	}
	if( SplashGlancingPSC != None)
	{
		SplashGlancingPSC.SetTemplate(SplashGlancingEffect);
        SplashGlancingPSC.SetAbsolute( true, true, true );
	}
	if( SplashPawnPSC != None)
	{
		SplashPawnPSC.SetTemplate(SplashPawnEffect);
        SplashPawnPSC.SetAbsolute( true, true, true );
	}
	if( SplashMaterialBasedPSC != None)
	{
		SplashMaterialBasedPSC.SetAbsolute( true, true, true );
	}

    // set up material parameters
	MIC_SprayMat0 = SkeletalSprayMesh.CreateAndSetMaterialInstanceConstant(0);
	MIC_SprayMat1 = SkeletalSprayMesh.CreateAndSetMaterialInstanceConstant(1);
	MIC_SprayMat2 = SkeletalSprayMesh.CreateAndSetMaterialInstanceConstant(2);

	// look up and cache bone indices
	for (ChainIdx=0; ChainIdx<BoneChain.length; ++ChainIdx)
	{
		BoneChain[ChainIdx].BoneIndex = SkeletalSprayMesh.MatchRefBone(BoneChain[ChainIdx].BoneName);
		if( BoneChain[ChainIdx].BoneIndex == INDEX_NONE)
		{
			`log("Warning!  Main chain bone"@BoneChain[ChainIdx].BoneName@"not found in FlameThrowerSpray skeletal mesh!  Bad things may happen.  Bad things.");
		}
	}

	// set up splash audio.  attach to last bone, bone scaling will take care of putting tbat bone
	// at the splash location.
// 	SkeletalSprayMesh.AttachComponent(SplashDirectAC,			BoneChain[BoneChain.Length-1].BoneName);
// 	SkeletalSprayMesh.AttachComponent(SplashPawnAC,				BoneChain[BoneChain.Length-1].BoneName);
// 	SkeletalSprayMesh.AttachComponent(SplashGlancingAC,			BoneChain[BoneChain.Length-1].BoneName);
// 	SkeletalSprayMesh.AttachComponent(SplashMaterialBasedAC,	BoneChain[BoneChain.Length-1].BoneName);

	// spawn starting emitter
	if( SprayStartPSC != None)
	{
		SprayStartPSC.SetTemplate(SprayStartEffect);
        SkeletalSprayMesh.AttachComponent(SprayStartPSC, 'bone15');
	}

	if( bAllowSprayLights )
	{
		// Attach the lights
		for( Idx = 0; Idx < SprayLights.length; ++Idx )
		{
			SkeletalSprayMesh.AttachComponent( SprayLights[Idx].Light, BoneChain[SprayLights[Idx].BoneChainIndex].BoneName );
		}
	}
	else
	{
		SprayLights.Remove(0, SprayLights.length);
	}
}

/** Internal.  Sets up references to AnimNodes we need to manipulate. */
simulated function CacheAnimNodes()
{
	StartSpraySeqNode	= AnimNodeSequence( SkeletalSprayMesh.FindAnimNode('StartSeqNode') );
	EndSpraySeqNode		= AnimNodeSequence( SkeletalSprayMesh.FindAnimNode('EndSeqNode') );
	AnimBlendNode		= AnimNodeBlendList( SkeletalSprayMesh.FindAnimNode('FlameBlendNode') );
	ScalingSkelControl	= KFSkelControl_SprayScaling( SkeletalSprayMesh.FindSkelControl('FlameScale') );

	ScalingSkelControl.SetSkelControlActive( false );
}

/** Internal.  Clears cached refs to AnimNodes that we stored earlier. */
simulated private function ClearAnimNodes()
{
	AnimBlendNode		= None;
	StartSpraySeqNode	= None;
	EndSpraySeqNode		= None;
}

simulated function BeginSpray()
{
	local int Idx;
	local float BlendTime;

	// if end node is still playing, stop and clean up before starting it again
	if( EndSpraySeqNode.bPlaying )
	{
		EndSpraySeqNode.bCauseActorAnimEnd = FALSE;
		CleanupEndFire();
	}

    // Don't spray if the actor firing this thing is hidden
    if( Base.bHidden )
    {
        return;
    }

 	SkeletalSprayMesh.SetHidden(FALSE);
 	SetHidden(FALSE);
	SetTickIsDisabled(false);
	bDetached = FALSE;
	bSkeletonHasBeenUpdated=FALSE;

	// reinit various transients
	MaterialCurrentFadeVal = default.MaterialCurrentFadeVal;
	MIC_SprayMat0.SetScalarParameterValue('Fade', MaterialCurrentFadeVal);
	MIC_SprayMat1.SetScalarParameterValue('Fade', MaterialCurrentFadeVal);
	MIC_SprayMat2.SetScalarParameterValue('Fade', MaterialCurrentFadeVal);
	bSplashActive = false;
	bSprayMeshCollidedThisTick = false;
	bSprayMeshCollidedLastTick = false;
	HighestSprayMeshContactThisTick.BoneChainIndex = INDEX_NONE;
	bSprayMeshCollisionDuration = 0.f;
	Seeds.Length = 0;
	SeedSimTimeRemaining = 0.f;
	bWaitingToDestroy = false;
	ClearTimer(nameof(DestroyIfAllEmittersFinished));

	BlendTime = 0.f;
	// if end node is still playing, blend into it
	if( EndSpraySeqNode.bPlaying )
	{
		BlendTime = 0.15;
	}

	// start animation
	StartSpraySeqNode.SetPosition(0.f, FALSE);
	// normal start anim
	StartSpraySeqNode.bPlaying = TRUE;
	AnimBlendNode.SetActiveChild(0, BlendTime);

	for (Idx=0; Idx<SprayLights.length; ++Idx)
	{
		SprayLights[Idx].Light.SetEnabled(TRUE);
	}

	if( SprayStartPSC != None)
	{
		SprayStartPSC.ActivateSystem(TRUE);
	}

    if( Role == ROLE_Authority && ImpactProjectileClass != none )
    {
	   SetTimer( ImpactProjectileInterval, TRUE, nameof(LeaveImpactProjectile) );
	}

	// get some seeds out there, if desired
	if( SeedWarmupTime > 0.f)
	{
		UpdateSeeds(SeedWarmupTime);
	}

	CurrentAge = 0.f;
}

simulated function Destroyed()
{
	local int Idx;

	// make sure fire particles got destroyed
	for (Idx = 0; Idx < BoneChain.length; ++Idx)
	{
		if( BoneChain[Idx].BonePSC0 != None)
		{
			BoneChain[Idx].BonePSC0.DeactivateSystem();
		}
		if( BoneChain[Idx].BonePSC1 != None)
		{
			BoneChain[Idx].BonePSC1.DeactivateSystem();
		}
	}

	if( SprayStartPSC != None )
	{
		SprayStartPSC.DeactivateSystem();
	}

	// Clear references to animations nodes
	ClearAnimNodes();
	Super.Destroyed();
}

simulated function DetachAndFinish()
{
	bDetached = TRUE;
	if (!bSprayMeshCollidedLastTick && !bSprayMeshCollidedThisTick)
	{
		HighestSprayMeshContactThisTick.BoneChainIndex = INDEX_NONE;
	}

	// start ending animation
	EndSpraySeqNode.bPlaying = TRUE;
	if ( StartSpraySeqNode.bPlaying )
	{
		// blend if start anim is playing as well
		AnimBlendNode.SetActiveChild(1, 0.15f);
	}
	else
	{
		AnimBlendNode.SetActiveChild(1, 0.f);
	}
	EndSpraySeqNode.bCauseActorAnimEnd = TRUE;				// we want the OnAnimEnd notify
}

simulated function CleanupEndFire()
{
	local int Idx;

	// turn off fire particles
	for (Idx=0; Idx<BoneChain.length; ++Idx)
	{
		if( BoneChain[Idx].BonePSC0 != None)
		{
			BoneChain[Idx].BonePSC0.DeactivateSystem();
		}
		if( BoneChain[Idx].BonePSC1 != None)
		{
			BoneChain[Idx].BonePSC1.DeactivateSystem();
		}
	}

	// start wait for systems to finish so we can destroy
	SetTimer(0.5f, TRUE, nameof(DestroyIfAllEmittersFinished));
	bWaitingToDestroy = TRUE;

	// deactivate any splashes
	if( CurrentSplashEffect != None)
	{
		CurrentSplashEffect.DeactivateSystem();
	}

	bSplashActive = FALSE;

	// turn off lights
	for (Idx=0; Idx<SprayLights.length; ++Idx)
	{
		SprayLights[Idx].Light.SetEnabled(FALSE);
	}

	// reset anims
	StartSpraySeqNode.SetPosition(0.f, FALSE);

	SkeletalSprayMesh.SetHidden(TRUE);
}

simulated event OnAnimEnd(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	if( SeqNode == EndSpraySeqNode)
	{
		CleanupEndFire();
	}

	super.OnAnimEnd(SeqNode, PlayedTime, ExcessTime);
}

/** Internal. */
simulated function SetupPerBoneFireFX()
{
	local int Idx, NumChainBones;

	if( bDoPerBoneSprayFX && (PerBoneSprayFXGlobalScale > 0.f) )
	{
		NumChainBones = BoneChain.Length;
		for (Idx=0; Idx<NumChainBones; ++Idx)
		{
			if(  (BoneChain[Idx].EffectScale > 0.f) && (BoneChain[Idx].BonePSC0 != None) )
			{
				SkeletalSprayMesh.AttachComponent(BoneChain[Idx].BonePSC0, BoneChain[Idx].BoneName);
				BoneChain[Idx].BonePSC0.SetTemplate(BoneChain[Idx].ParticleSystemTemplate);
				BoneChain[Idx].BonePSC0.SetFloatParameter('FlameScale', BoneChain[Idx].EffectScale*PerBoneSprayFXGlobalScale);
			}
			if(  (BoneChain[Idx].EffectScale > 0.f) && (BoneChain[Idx].BonePSC1 != None) )
			{
				SkeletalSprayMesh.AttachComponent(BoneChain[Idx].BonePSC1, BoneChain[Idx].BoneName);
				BoneChain[Idx].BonePSC1.SetTemplate(BoneChain[Idx].ParticleSystemTemplate1P);
				BoneChain[Idx].BonePSC1.SetFloatParameter('FlameScale', BoneChain[Idx].EffectScale*PerBoneSprayFXGlobalScale);
			}
		}
	}
}

simulated function TempCreatePSC()
{
}

/**
 * Attach the spray to a weapon
 *
 * @param Weap - the weapon to attach to
 *
 * @param SocketName - which socket should we attach to
 */
simulated function AttachToMesh(Actor BaseActor, SkeletalMeshComponent OwnerMesh, Name SocketName)
{
//	local float OwnerMeshFOV;

	// Allow code to override attachment socket
	if ( SocketName == 'None' )
	{
        return;
	}

    if( KFWeapon(BaseActor) != none )
    {
        SetBase(BaseActor,, OwnerMesh, SocketName);
    }
    else
    {
        SetBase(BaseActor.Owner,, OwnerMesh, SocketName);
    }

	// If attaching to a foreground (1st person) mesh
//	if ( OwnerMesh.DepthPriorityGroup == SDPG_Foreground )
//	{
//		// No MuzzleFlashPSC foreground adjustment for now
//	}

	// If attaching to a mesh with a custom FOV
//	if (OwnerMesh.IsA('KFSkeletalMeshComponent'))
//	{
//		OwnerMeshFOV = KFSkeletalMeshComponent(OwnerMesh).FOV;
//		SkeletalSprayMesh.SetFOV(OwnerMeshFOV);
//	}

}

/**
 * Get the impact effect particle and sounds for a given PhysicalMaterial
 *
 * @param PhysMaterial - The physical material to get FX for
 * @param ParticleSystem - The particle system to play
 * @param ImpactSound - The Impact Sound sound to play
 * @param ImpactSoundStopEvent - The event to stop the Impact Sound from playing
 */
simulated event GetImpactEffect(PhysicalMaterial PhysMaterial, out ParticleSystem PS, out AKEvent ImpactSound, out AKEvent ImpactSoundStopEvent)
{
    local MaterialImpactEffect ImpactEffect;

    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    `ImpactEffectManager.GetImpactEffect(PhysMaterial, ImpactEffect, ImpactEffects);
    PS = ImpactEffect.ParticleTemplate;
    ImpactSound = AKEvent(ImpactEffect.Sound);
    ImpactSoundStopEvent = AKEvent(ImpactEffect.StopSoundEvent);
}

/** Calls ResetParticles on all contained PSCs.  Good to call when expected to be inactive for some time, as it reduces memory footprint. */
simulated native function ParticleSystemCleanUp();
/** Figure out what the spray hit. */
native final function DoSprayCollisionDetection( float DeltaTime );

/** Internal. */
simulated protected function KFPawn FindOwningKFPawn()
{
	if( Instigator != none )
	{
		return KFPawn(Instigator);
	}

	return KFPawn(Owner);
}

/** Leave an impact projectile on the ground (like fire, etc) */
function LeaveImpactProjectile()
{
    local vector DecalStartTrace, DecalEndTrace;
	local vector NewHitLoc, HitNormal;
	local TraceHitInfo HitInfo;

 	if( bSprayMeshCollidedLastTick && (KFPawn(HighestSprayMeshContactThisTick.Actor) == None) )
 	{
    	DecalStartTrace = HighestSprayMeshContactThisTick.ContactPosition + HighestSprayMeshContactThisTick.ContactNormal * 4.f;
    	DecalEndTrace = DecalStartTrace - HighestSprayMeshContactThisTick.ContactNormal * 32.f;

        // Find where to put the decal
		if( Trace(NewHitLoc, HitNormal, DecalEndTrace, DecalStartTrace, false,, HitInfo, TRACEFLAG_Bullet) != none )
		{
        	SpawnImpactProjectile(NewHitLoc, HitNormal);
    	}
 	}
}

/** Spawn the impact projectile*/
function SpawnImpactProjectile(vector SpawnLocation, vector SpawnRotation)
{
	local KFProjectile	SpawnedProjectile;
	local int i;

	// make sure not to spawn an impact projectile on top of another one for performance's sake
	for( i = 0; i < MAX_SPRAY_FX_INFOS; ++i )
	{
		// if we haven't initialized it yet, allow it
		if( IsZero(SprayFxInfos[i].Location) )
		{
			continue;
		}

		// if enough time has passed since we used it, allow it
		if( `TimeSince(SprayFxInfos[i].TimeStamp) > 10.f )
		{
			continue;
		}

		// if it's far enough away, allow it
		if( VSizeSq(SpawnLocation - SprayFxInfos[i].Location) > 625.f ) // a quarter-meter
		{
			continue;
		}

		// otherwise, we're trying to spawn an impact projectile on top of another, so don't allow it
		return;
	}

	// keep track of a circular array of locations where we've spawned impact projectiles
	SprayFxInfos[CurrSprayFxLocIdx].Location = SpawnLocation;
	SprayFxInfos[CurrSprayFxLocIdx].TimeStamp = WorldInfo.TimeSeconds;
	CurrSprayFxLocIdx = (CurrSprayFxLocIdx + 1) % MAX_SPRAY_FX_INFOS;

	// Spawn projectile
	SpawnedProjectile = Spawn( ImpactProjectileClass, Self,, SpawnLocation, rotator(SpawnRotation),, true);
	if( SpawnedProjectile != none && !SpawnedProjectile.bDeleteMe )
	{
		// Set the penetration power for this projectile
        if( SpawnedProjectile != none )
        {
			SpawnedProjectile.ExplosionTemplate.ExplosionEffects = ImpactEffects;
        }

		SpawnedProjectile.Init( SpawnRotation );
	}
}

event float GetModifiedDamage()
{
	return SplashDamage * DamageModifier;
}

event SprayMeshExitCollision()
{
}

event SprayMeshHit(Actor TouchActor)
{
	local float Dmg, DistToHitActor;
	local vector Momentum;
	local int TruncDamage;
	local TraceHitInfo HitInfo;
	local Pawn TouchPawn;

	if (OwningKFPawn != none)
	{
		Momentum = TouchActor.Location - OwningKFPawn.Location;
	}
	else if (DummyFireParent != none)
	{
		Momentum = TouchActor.Location - DummyFireParent.Location;
	}
	DistToHitActor = VSize(Momentum);
	Momentum *= (MomentumScale / DistToHitActor);

	Dmg = GetDamage(DistToHitActor, TouchActor);
	TruncDamage = int(Dmg);
	if (TruncDamage > 0)
	{
		HitInfo.PhysMaterial = HighestSprayMeshContactThisTick.PhysicalMaterial;
		HitInfo.BoneName = HighestSprayMeshContactThisTick.BoneName;

		TouchPawn = Pawn(TouchActor);
		if (bDebugDirectDamage && TouchPawn != none)
		{
			`log("["$WorldInfo.TimeSeconds$"] Damaging "$TouchActor.Name$" for "$TruncDamage$", Dist: "$VSize(TouchActor.Location - OwningKFPawn.Location));
		}

		// Let script know that we hit something
		if (TouchPawn != none)
		{
			ProcessDirectImpact();
		}

		TouchActor.TakeDamage(TruncDamage, InstigatorController, TouchActor.Location, Momentum, MyDamageType, HitInfo, self);
	}
}

event SplashHit(Actor SplashTouchActor)
{
	local vector Momentum;
	local float Dmg;
	local bool bFoundHitActor, bDamagedRecently;
	local int i, RoundedDamage;
	local DamagedActorInfo NewDamage;
	local Pawn SplashTouchPawn;
	local TraceHitInfo TraceInfo;

	Dmg = GetModifiedDamage();  // base damage
	Dmg *= Clamp(1.f - VSize(SplashTouchActor.Location - LastSplashLoc) / SplashDamageRadius, 0.f, 1.f) ** SplashDamageFalloffExponent;   // scaled by dist

	// Scale the damage to the instigator by the SplashDamageInstigatorDamageScale
	if (OwningKFPawn != none && SplashTouchActor == OwningKFPawn)
	{
		Dmg *= SplashDamageInstigatorDamageScale;
	}

	// Find any actors that we've damaged recently so we can do their damage at the specified rate
	// Also clear out any actors from the array that have been around too long
	for (i = RecentlyDamagedActors.Length - 1; i >= 0; i--)
	{
		if ((WorldInfo.TimeSeconds - RecentlyDamagedActors[i].HitTime) > 1.f)
		{
			RecentlyDamagedActors.Remove(i, 1);
			continue;
		}

		if (!bFoundHitActor && RecentlyDamagedActors[i].HitActor == SplashTouchActor)
		{
			bFoundHitActor = TRUE;

			// Only damage at a specified rate, so return if it's too soon
			if ((WorldInfo.TimeSeconds - RecentlyDamagedActors[i].HitTime) < DamageInterval)
			{
				bDamagedRecently = TRUE;

				if (bDebugSplashDamage)
				{
					`log("UpdateSplashes() for "$SplashTouchActor.Name$", damaged too recently DamageInterval: "$DamageInterval$", Time Since Last Damage: "$(WorldInfo.TimeSeconds - RecentlyDamagedActors[i].HitTime));
				}
			}
		}
	}

	// Don't damage this actor again if it was damaged too recently
	if (!bDamagedRecently)
	{
		RoundedDamage = Round(Dmg);
		if (RoundedDamage > 0)
		{
			NewDamage.HitActor = SplashTouchActor;
			NewDamage.HitTime = WorldInfo.TimeSeconds;

			// Store any actors that get damage
			RecentlyDamagedActors.AddItem(NewDamage);

			if (OwningKFPawn != none)
			{
				Momentum = (SplashTouchActor == OwningKFPawn) ? vector(OwningKFPawn.Rotation) : Normal(SplashTouchActor.Location - OwningKFPawn.Location);
			}
			else
			{
				Momentum = Normal(SplashTouchActor.Location - Location);
			}
			Momentum *= MomentumScale;

			SplashTouchPawn = Pawn(SplashTouchActor);
			if (bDebugSplashDamage && SplashTouchPawn != none)
			{
				`log("["$WorldInfo.TimeSeconds$"] Splash Damaging "$SplashTouchActor.Name$" for "$RoundedDamage$", Dist: "$VSize(SplashTouchActor.Location - OwningKFPawn.Location));
			}
			SplashTouchActor.TakeDamage(RoundedDamage, InstigatorController, SplashTouchActor.Location, Momentum, MyDamageType, TraceInfo, self);
		}
	}
}

DefaultProperties
{
	bHidden=TRUE

    SprayDamageScaleDistRange=(X=300,Y=300)
	SeedSprayVel=5000.f
	SeedDecel=13000.f
	SeedMaxAge=0.4f
	SeedMinChainLength=0.f
	SeedSimFreq=60.f
	SeedWarmupTime=0.25f
	SplashDamageInstigatorDamageScale=1.0
	DamageInterval=0.07 // 857 RPM
	bUseExtentTracing=false
	bDebugShowCollision=false
	bDebugShowBones=false
	bDebugShowSeeds=false
	bDebugForceNonPlayerParticles=false
	bDebugSplashDamage=false
	bDebugDirectDamage=false
	bDebugShowSplashRadius=false
	bDebugSprayLights=false
	MaxDecalEffectDistance=5000
	ImpactProjectileInterval=0.2
	bCollideWithTeammates=false
	DamageModifier=1.f

	// call SetTickIsDisabled( false ) when we need to use this actor
	bTickIsDisabled=TRUE

	MaxSprayMeshesCollided=1;
}
