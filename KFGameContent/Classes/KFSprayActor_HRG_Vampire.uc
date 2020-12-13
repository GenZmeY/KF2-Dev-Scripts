//=============================================================================
// KFSprayActor_HRG_Vampire
//=============================================================================
// Base class for spray actor that sucks enemies blood
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSprayActor_HRG_Vampire extends KFSprayActor
    hidecategories(Object, Movement, Display, Attachment, Collision, Physics, Advanced, Debug, Mobile)
	placeable;


/** Transient PSCs to workaround issue with setting the BonePSC in an archetype */
var transient array<KFParticleSystemComponent> BoneChainComponents;
var transient array<KFParticleSystemComponent> BoneChainComponents_1stP;

/** Firebug Perk can modify the flame length, we need an alternative anim for that */
var(SprayMesh) AnimSet 	AltSprayAnimSet;

var(SuckerConfig) int MaxNumberOfZedsZapped;
var(SuckerConfig) int MaxDistanceToBeZapped;
var(SuckerConfig) float ZapInterval;
var(SuckerConfig) int ChainDamage;

var KFWeap_HRG_Vampire OwnerWeapon;

/***************************************

	INHERITED FROM SPRAY AND NOT MODIFIED

 ***************************************/

event PreBeginPlay()
{
	super.PreBeginPlay();
	SetBoneChainComponents();
}

/**
 * Set (or create) PSC's for the BoneChain.  Use this when creating an archetype template spray
 * effect to workaround an issue where assigning a transient default BoneChain PSC doesn't work.
 */
simulated function SetBoneChainComponents()
{
	local int Idx;

	for (Idx = 0; Idx < BoneChain.length; ++Idx)
	{
		if ( Idx < BoneChainComponents.Length )
		{
			BoneChain[Idx].BonePSC0 = BoneChainComponents[Idx];
		}
		if ( Idx < BoneChainComponents_1stP.Length )
		{
			BoneChain[Idx].BonePSC1 = BoneChainComponents_1stP[Idx];
		}
	}
}



simulated function BeginSpray()
{
	local KFPerk InstigatorPerk;

	if( bDeleteMe )
	{
		return;
	}

	super.BeginSpray();

	if( OwningKFPawn != none )
	{
		InstigatorPerk = OwningKFPawn.GetPerk();
		if( InstigatorPerk != none )
		{
			SplashDamage = default.SplashDamage;
		}

		//SetSprayLength();
	}
}

/***************************************

	END INHERITED FROM SPRAY AND NOT MODIFIED

 ***************************************/


/**
 * Overridden to handle the rotation sound pitching for the flamethrower sound
 */
simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);
	
    // Set the rotation speed for the flamethrower sound
	if( !bDetached && OwningKFPawn != none && WorldInfo.NetMode != NM_DedicatedServer )
	{
        OwningKFPawn.SetWeaponComponentRTPCValue( "FlamethrowerRotation", RotationSpeed);
	}
}

simulated function CleanupEndFire()
{
	super.CleanupEndFire();
	SprayMeshExitCollision();
}


simulated event SprayMeshHit(Actor _TouchActor)
{
	local KFPawn_Monster TouchActor;
	//if (Role == ROLE_Authority)
	//{
		//`Warn("TOUCHED IN: "$_TouchActor.Location$"");
		//if the sprayed actor is a monster, then we start zapping enemies

			if(_TouchActor.IsA('KFPawn_Monster'))
			{
				TouchActor = KFPawn_Monster(_TouchActor);
				if(OwnerWeapon != none && TouchActor != OwnerWeapon.oZedCurrentlyBeingSprayed)
				{
					OwnerWeapon.SetCurrentSprayedZed(TouchActor);
				}
			}
			else
			{
				SprayMeshExitCollision();
			}
		
	//}
		/*if (!CheckRecentlyZapped(_TouchActor))
		{
			NewActorInfo.HitActor = _TouchActor;
			NewActorInfo.HitTime = WorldInfo.TimeSeconds;
			vRecentlyZappedActors.AddItem(NewActorInfo);
		}*/

	super.SprayMeshHit(_TouchActor);
}



simulated event SprayMeshExitCollision()
{
	if (OwnerWeapon == none)
	{
		return;
	}
	OwnerWeapon.SetCurrentSprayedZed(none);
}
/**
 * @brief Changes the flame's length if the Firebug's Range skill is selected
 * 
 * @param InstigatorPerk Instigator's current perk
 */
/*simulated function SetSprayLength()
{
	local AnimSet TempAnimSet;
	local KFPlayerReplicationInfo OwningPawnPRI;

	if ( default.AltSprayAnimSet == None )
	{
		return; // only once length available
	}

	// Firebug range skill can affect the flame weapons range
	OwningPawnPRI = KFPlayerReplicationInfo(OwningKFPawn.PlayerReplicationInfo);
	if( OwningPawnPRI != none )
	{
		TempAnimSet = OwningPawnPRI.bExtraFireRange ? default.AltSprayAnimSet : default.SprayAnimSet;
	}
	
	// Don't set the anim set to nothing if the archetype is screwed up
	// Don't set the anim set and tree if they do not need to be changed
	if( TempAnimSet == none || TempAnimSet == SkeletalSprayMesh.AnimSets[0] )	
	{
		return;
	}

	SkeletalSprayMesh.AnimSets[0] = TempAnimSet;
	SkeletalSprayMesh.UpdateAnimations();
	SetupFX();	
}*/

DefaultProperties
{
    Physics=PHYS_Interpolating
	TickGroup=TG_PostAsyncWork
	bStatic=false
	bCollideActors=TRUE
	bBlockActors=false
	bWorldGeometry=false
	// This must not be bCollideWorld or it will get pushed around in FarMoveActor
	bCollideWorld=false
	bProjTarget=false
	bIgnoreEncroachers=FALSE
	bNoEncroachCheck=TRUE
	RemoteRole=ROLE_None
	GravityScaleRange=(X=0.f,Y=-15.f)
	GravityScaleInTime=0.5f
	MomentumScale=0.15f
	MyDamageType=class'KFDT_EMP'

	// ---------------------------------------------
	// Splash damage
	SplashGlancingDotLimit=-0.9f
	SplashRotInterpSpeed=8.f
	SplashLocInterpSpeed=40.f
	bDoCollideComplex=TRUE
	SprayDamageScaleDistRange=(X=300,Y=300)
	SprayDamage=(X=10,Y=10)
	SplashDamageRadius=300.f
	SplashDamage=10
	SplashDamageFalloffExponent=1.f

	// ---------------------------------------------
	// Per-bone Fire FX
	PerBoneSprayFXGlobalScale=1.f
	bDoPerBoneSprayFX=TRUE

	// ---------------------------------------------
	// Material params
	MaterialHeatRampTime=0.65f
	MaterialHeatRange=(X=0.f,Y=0.8f)
	MaterialFadeOutTime=0.2f
	MaterialCurrentFadeVal=1.f
	MatFadePow=2.f

	// ---------------------------------------------
	// Content
    Begin Object Class=KFSkeletalMeshComponent Name=FlameCore0
        CollideActors=true
        BlockActors=false
        BlockZeroExtent=true
        BlockNonZeroExtent=true
        bUpdateSkelWhenNotRendered=TRUE
        bIgnoreControllersWhenNotRendered=FALSE
        bOverrideAttachmentOwnerVisibility=TRUE
        CastShadow=FALSE
        bAcceptsStaticDecals=FALSE
        bAcceptsDynamicDecals=FALSE
        Rotation=(Roll=-16384)
		SkeletalMesh=SkeletalMesh'FX_Flamethrower_MESH.WEP_Flamethrower_Flame_A'
		AnimTreeTemplate=AnimTree'FX_Flamethrower_ANIM.WEP_Flamethrower_Flame_AT'
		AnimSets(0)=AnimSet'FX_Flamethrower_ANIM.WEP_Flamethrower_Flame_Anim'
    End Object
    SkeletalSprayMesh=FlameCore0
    CollisionComponent=FlameCore0
    Components.Add(FlameCore0)

    SkelMesh=SkeletalMesh'FX_Flamethrower_MESH.WEP_Flamethrower_Flame_A'
    SprayAnimSet=AnimSet'FX_Flamethrower_ANIM.WEP_Flamethrower_Flame_Anim'
    SprayAnimTreeTemplate=AnimTree'FX_Flamethrower_ANIM.WEP_Flamethrower_Flame_AT'

    AltSprayAnimSet=AnimSet'FX_Flamethrower_ANIM.Wep_Caulk_Flame_Anim'

//	bLeaveStickyFire=FALSE
// 	StickyFireMinTimeBetweenSpawns=0.25f
// 	StickyFireOwnerSafeRadius=64
// 	StickyFireInitialDelay=0.5f
// 	StickyFireTestLocInterpSpeed=5.f
// 	StickyFireTestLocThreshold=64.f

    ImpactEffects=KFImpactEffectInfo'WEP_Flamethrower_ARCH.Flame_Impacts'

    SprayEndEffect=ParticleSystem'WEP_Flamethrower_EMIT.FX_End_muzzleflash_01'
    SprayStartEffect=ParticleSystem'WEP_Flamethrower_EMIT.FX_Start_muzzleflash'

    SplashGlancingEffect=ParticleSystem'WEP_Flamethrower_EMIT.FX_flame_deflect_01'
	Begin Object Class=KFParticleSystemComponent Name=SplashGlancingPSC0
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	SplashGlancingPSC=SplashGlancingPSC0
	Components.Add(SplashGlancingPSC0)

	SplashDirectEffect=ParticleSystem'WEP_Flamethrower_EMIT.FX_Flame_impact_01'
    Begin Object Class=KFParticleSystemComponent Name=SplashDirectPSC0
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	SplashDirectPSC=SplashDirectPSC0
	Components.Add(SplashDirectPSC0)

	SplashPawnEffect=ParticleSystem'WEP_Flamethrower_EMIT.FX_Flame_impact_player_01'
    Begin Object Class=KFParticleSystemComponent Name=SplashPawnPSC0
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	SplashPawnPSC=SplashPawnPSC0
	Components.Add(SplashPawnPSC0)

	Begin Object Class=KFParticleSystemComponent Name=SplashMaterialBasedPSC0
		bAutoActivate=FALSE
		Template=None		// filled in by the code based on what was hit
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	SplashMaterialBasedPSC=SplashMaterialBasedPSC0
	Components.Add(SplashMaterialBasedPSC0)

	// per-bone fire fx
	LastBoneChainIndexThatCanSpawnSplashEffects=11

	// bone01
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone01_PSC0
    	bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		Rotation=(Yaw=32768)
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
    // first person
	Begin Object Class=KFParticleSystemComponent Name=Bone01_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		Rotation=(Yaw=32768)
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone02
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone02_PSC0
		bOwnerNoSee=TRUE
        bAutoActivate=FALSE
		Rotation=(Yaw=32768)
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
    // first person
	Begin Object Class=KFParticleSystemComponent Name=Bone02_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		Rotation=(Yaw=32768)
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone03
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone03_PSC0
		bOwnerNoSee=TRUE
        bAutoActivate=FALSE
        Rotation=(Yaw=32768)
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
    // first person
	Begin Object Class=KFParticleSystemComponent Name=Bone03_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		Rotation=(Yaw=32768)
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone04
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone04_PSC0
		bOwnerNoSee=TRUE
        bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
    // first person
	Begin Object Class=KFParticleSystemComponent Name=Bone04_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone05
	Begin Object Class=KFParticleSystemComponent Name=Bone05_PSC0
		bOwnerNoSee=TRUE
        bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
    // first person
	Begin Object Class=KFParticleSystemComponent Name=Bone05_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone06
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone06_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
    // first person
	Begin Object Class=KFParticleSystemComponent Name=Bone06_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone07
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone07_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
    // first person
	Begin Object Class=KFParticleSystemComponent Name=Bone07_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone08
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone08_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	// first person
	Begin Object Class=KFParticleSystemComponent Name=Bone08_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone09
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone09_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	// first person
    Begin Object Class=KFParticleSystemComponent Name=Bone09_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone10
	// 3rd person
    Begin Object Class=KFParticleSystemComponent Name=Bone10_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	// first person
    Begin Object Class=KFParticleSystemComponent Name=Bone10_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone11
	// 3rd person
    Begin Object Class=KFParticleSystemComponent Name=Bone11_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	// first person
    Begin Object Class=KFParticleSystemComponent Name=Bone11_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone12
	// 3rd person
    Begin Object Class=KFParticleSystemComponent Name=Bone12_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	// first person
    Begin Object Class=KFParticleSystemComponent Name=Bone12_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	// bone13
	// 3rd person
	Begin Object Class=KFParticleSystemComponent Name=Bone13_PSC0
		bOwnerNoSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object
	// first person
    Begin Object Class=KFParticleSystemComponent Name=Bone13_PSC1
		bOnlyOwnerSee=TRUE
		bAutoActivate=FALSE
		TranslucencySortPriority=1
		SecondsBeforeInactive=0
	End Object

	BoneChain(0)={(BoneName=Bone01,
                MaterialParam=0.0,
                BoneScale=1.f,
                EffectScale=1.0f,
                ParticleSystemTemplate=none,
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_Initial_spawn_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone01_PSC0,
                BonePSC1=Bone01_PSC1)}
	BoneChain(1)={(BoneName=Bone02,
                MaterialParam=0.04,
                BoneScale=1.f,
                EffectScale=1.0f,
                ParticleSystemTemplate=none,
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_Initial_spawn_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone01_PSC0,
                BonePSC1=Bone01_PSC1)}
	BoneChain(2)={(BoneName=Bone03,
                MaterialParam=0.080000,
                BoneScale=1.f,
                EffectScale=0.250000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_reverse_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_reverse_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone02_PSC0,
                BonePSC1=Bone02_PSC1)}
	BoneChain(3)={(BoneName=Bone04,
                MaterialParam=0.130000,
                BoneScale=1.f,
                EffectScale=0.250000,
                ParticleSystemTemplate=None,
                ParticleSystemTemplate1P=None,
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone03_PSC0,
                BonePSC1=Bone03_PSC1)}
	BoneChain(4)={(BoneName=Bone05,
                MaterialParam=0.190000,
                BoneScale=1.f,
                EffectScale=0.500000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone04_PSC0,
                BonePSC1=Bone04_PSC1)}
	BoneChain(5)={(BoneName=Bone06,
                MaterialParam=0.240000,
                BoneScale=1.f,
                EffectScale=0.500000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone05_PSC0,
                BonePSC1=Bone05_PSC1)}
	BoneChain(6)={(BoneName=Bone07,
                MaterialParam=0.310000,
                BoneScale=1.f,
                EffectScale=1.800000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone06_PSC0,
                BonePSC1=Bone06_PSC1)}
	BoneChain(7)={(BoneName=Bone08,
                MaterialParam=0.370000,
                BoneScale=1.f,
                EffectScale=0.500000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone07_PSC0,
                BonePSC1=Bone07_PSC1)}
	BoneChain(8)={(BoneName=Bone09,
                MaterialParam=0.440000,
                BoneScale=1.f,
                EffectScale=1.000000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone08_PSC0,
                BonePSC1=Bone08_PSC1)}
	BoneChain(9)={(BoneName=Bone10,
                MaterialParam=0.500000,
                BoneScale=1.f,
                EffectScale=1.000000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone09_PSC0,
                BonePSC1=Bone09_PSC1)}
	BoneChain(10)={(BoneName=Bone11,
                MaterialParam=0.560000,
                BoneScale=1.f,
                EffectScale=1.000000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone10_PSC0,
                BonePSC1=Bone10_PSC1)}
	BoneChain(11)={(BoneName=Bone12,
                MaterialParam=0.620000,
                BoneScale=1.f,
                EffectScale=1.000000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone11_PSC0,
                BonePSC1=Bone11_PSC1)}
	BoneChain(12)={(BoneName=Bone13,
                MaterialParam=0.690000,
                BoneScale=1.f,
                EffectScale=1.000000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone12_PSC0,
                BonePSC1=Bone12_PSC1)}
	BoneChain(13)={(BoneName=Bone14,
                MaterialParam=0.760000,
                BoneScale=1.f,
                EffectScale=1.000000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_End_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f,
                BonePSC0=Bone13_PSC0,
                BonePSC1=Bone13_PSC1)}
	BoneChain(14)={(BoneName=Bone15,
                MaterialParam=0.820000,
                BoneScale=0.f,
                EffectScale=1.000000,
                ParticleSystemTemplate=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_End_01_3P',
                ParticleSystemTemplate1P=ParticleSystem'WEP_Flamethrower_EMIT.Materials.FX_Flamethrower_BSpawns_01_1P',
                ParticleActivationDelay=0.0f)}

	BoneChainComponents={(Bone01_PSC0, Bone01_PSC0, Bone02_PSC0, Bone03_PSC0, Bone04_PSC0, Bone05_PSC0, Bone06_PSC0,
						Bone07_PSC0, Bone08_PSC0, Bone09_PSC0, Bone10_PSC0, Bone11_PSC0, Bone12_PSC0, Bone13_PSC0)}
	BoneChainComponents_1stP={(Bone01_PSC1, Bone01_PSC1, Bone02_PSC1, Bone03_PSC1, Bone04_PSC1, Bone05_PSC1, Bone06_PSC1,
						Bone07_PSC1, Bone08_PSC1, Bone09_PSC1, Bone10_PSC1, Bone11_PSC1, Bone12_PSC1, Bone13_PSC1)}

	// pointlight at far end of spray
	Begin Object Class=PointLightComponent Name=FlamePointLight2
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=4.f
		Radius=500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// Muzzle Flash point light
	// want this light to illuminate characters only, so Marcus gets the glow
    Begin Object Class=PointLightComponent Name=FlamePointLight0
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=6.0f
		FalloffExponent=10.f
		Radius=750.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	SprayLights(0)=(Light=FlamePointLight0,BoneChainIndex=1,FlickerIntensity=5.f,FlickerInterpSpeed=15.f)
	SprayLights(1)=(Light=FlamePointLight2,BoneChainIndex=9,FlickerIntensity=5.f,FlickerInterpSpeed=15.f)

// 	MaterialHeatRampTime=0.65f
// 	MaterialHeatRange=(X=0.f,Y=0.8f)
// 	MaterialFadeOutTime=0.2f
// 	MaterialCurrentFadeVal=1.f
// 	MatFadePow=2.f
// 	Begin Object Class=AudioComponent Name=SplashMaterialBasedAC0
// 		// cue will be filled in from physicalmaterial data
// 		SoundCue=None
// 		bStopWhenOwnerDestroyed=TRUE
// 		bUseOwnerLocation=FALSE
// 	End Object
// 	SplashMaterialBasedAC=SplashMaterialBasedAC0

	// Splash audio
    Begin Object Class=AkComponent name=CurrentSplashAkSoundComponent
    	bStopWhenOwnerDestroyed=true
    	bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.2;
    End Object
    CurrentSplashAKC=CurrentSplashAkSoundComponent
    Components.Add(CurrentSplashAkSoundComponent)

    SplashPawnAKEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Impact_Flesh'
    SplashDirectAKEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Impact_Default'
    SplashGlancingAKEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Impact_Default'

    SplashPawnStopAKEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Impact_Flesh_Loop'
    SplashDirectStopAKEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Impact_Default_Loop'
    SplashGlancingStopAKEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Impact_Default_Loop'

 	Begin Object Class=KFParticleSystemComponent Name=StartFirePSC0
 		bAutoActivate=TRUE
 		TickGroup=TG_PostUpdateWork
 	End Object
 	SprayStartPSC=StartFirePSC0

	SeedSprayVel=10000.f//5000.f
	SeedDecel=28000.f//13000.f
	SeedMaxAge=0.4f
	SeedMinChainLength=0.f
	SeedSimFreq=60.f
	SeedWarmupTime=0.25f
	VelocityScaleZ=0.3f//0.15f

	bUseExtentTracing=true
	SpraySocketName=MuzzleFlash

	//ImpactProjectileClass=class'KFProj_GroundFire'

	ImpactProjectileInterval=0.099


}