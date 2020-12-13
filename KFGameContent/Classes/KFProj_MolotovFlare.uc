//=============================================================================
// KFProj_MolotovFlare
//=============================================================================
// Flare that is dropped by molotov upon exploding if instigator has medic
// "Flaretov" ability set. It's basically just a light, and it's not actually a projectile.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================
class KFProj_MolotovFlare extends Actor; // NOTE: not actually a projectile

/** This is the effect that is played while in flight */
var ParticleSystemComponent	ProjEffects;
var(Projectile) ParticleSystem ProjFlightTemplate;

/** Point light and related params */
var PointLightComponent PointLight;
var float LightFadeStartTime;
var float LightFadeTime;
var transient float LightFadePerSecond;

/** Ambient sound to play */
var AkEvent FuseEvent;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( ProjFlightTemplate != None )
	    {
	        ProjEffects = WorldInfo.MyEmitterPool.SpawnEmitterCustomLifetime(ProjFlightTemplate);
			if( ProjEffects != none )
			{
		        ProjEffects.SetAbsolute(false, false, false);
				ProjEffects.SetLODLevel(WorldInfo.bDropDetail ? 1 : 0);
				ProjEffects.bUpdateComponentInTick = true;
				ProjEffects.SetTranslation( vect(0, 0, 2) );
				AttachComponent(ProjEffects);
	  		}
	    }

	    LightFadePerSecond = PointLight.Brightness / LightFadeTime;
	    PlaySoundBase( FuseEvent, true,, true );
	}
}

simulated event Tick( float DeltaTime )
{
	local float NewBrightness;

	super.Tick( DeltaTime );

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		return;
	}

	// gradually fade light
	if( LifeSpan < default.LifeSpan - LightFadeStartTime )
	{
		if( PointLight.Brightness > 0 )
		{
			NewBrightness = FMax( 0, PointLight.Brightness - (LightFadePerSecond * DeltaTime) );
			PointLight.SetLightProperties( NewBrightness );
		}
	}
}

defaultproperties
{
	Physics=PHYS_Falling

	bCollideComplex=TRUE	// Ignore simple collision on StaticMeshes, and collide per poly

	TickGroup=TG_PreAsyncWork

	bAlwaysRelevant=true
	bSkipActorPropertyReplication=true

	Begin Object Class=CylinderComponent Name=CollisionCylinder
		CollisionRadius=0
		CollisionHeight=0
		AlwaysLoadOnClient=True
		AlwaysLoadOnServer=True
	End Object
	CollisionComponent=CollisionCylinder
	Components.Add(CollisionCylinder)

	bCollideActors=true
	bCollideWorld=true
	bNetTemporary=true
	bReplicateInstigator=true
	NetPriority=+00002.500000
	RemoteRole=ROLE_SimulatedProxy
	LifeSpan=31

	Begin Object Class=PointLightComponent Name=PointLightComponent0
	    LightColor=(R=245,G=190,B=140,A=255)
		Brightness=3.f
		Radius=800.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=FALSE
		bCastPerObjectShadows=false
		bEnabled=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object
	PointLight=PointLightComponent0
	Components.Add(PointLightComponent0)

	LightFadeStartTime=27.5
	LightFadeTime=2.75

	ProjFlightTemplate=ParticleSystem'WEP_3P_Molotov_EMIT.FX_Flare_fire_01'
	FuseEvent=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Fuse_LP'
}