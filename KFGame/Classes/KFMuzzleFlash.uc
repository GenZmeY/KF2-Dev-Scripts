//=============================================================================
// KFMuzzleFlash
//=============================================================================
// Muzzle flash effects used for 1st and 3rd person
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFMuzzleFlash extends Object
	hidecategories(Object)
	native(Effect)
	config(Game);

/** Owning Actor used for handling timers */
var transient Actor Owner;

/*********************************************************************************************
 Muzzle Flash Fire Effects
********************************************************************************************* */

struct native MuzzleEffectInfo
{
/** Dynamic light component */
	var() KFExplosionLight		LightTemplate;

	/** Muzzle flash PSC and Templates */
	var() ParticleSystem		ParticleSystemTemplate;
	var() bool					bPSCLoops<EditCondition=!bIgnoreStopFire>;
	/** If set, do not deactivate when weapon stops firing (only works with bPSCLoops=FALSE) */
	var() bool  				bIgnoreStopFire<EditCondition=!bPSCLoops>;

	/** Sets LifeSpan of PSC (iff bMuzzleFlashPSCLoops=FALSE) and light */
	var() float					Duration;

	/** The default socket name to attach to */
	var() name					SocketName;

	var() ESceneDepthPriorityGroup FirstPersonDepthPriorityGroup;

	var const name				TimerName;

	/** Transient vars used by muzzle flash instances */
	var transient KFParticleSystemComponent	PSC;
	var transient KFExplosionLightComponent LightComponent;
	var transient bool						bIsActive;

	structdefaultproperties
	{
		SocketName=MuzzleFlash
		Duration=0.33f
		FirstPersonDepthPriorityGroup=SDPG_Foreground
	}
};

var() MuzzleEffectInfo MuzzleFlash;

/** If set, creates a second set of muzzle flash data used for alt firemode */
var() bool bEnableSecondaryMuzzleFlash;
var() MuzzleEffectInfo MuzzleFlashAlt<EditCondition=bEnableSecondaryMuzzleFlash>;

/*********************************************************************************************
 * Advanced settings
********************************************************************************************* */

/** Set this to a fire mode when you want them to alternate between the primary muzzle flash, and alternate when using this fire mode */
var(Advanced) byte		FireModeAlternateBothEffects;
/** Set this to a fire mode when you want them to fire both the primary muzzle flash when using that firemode. Set to 254 to always fire both primary and secondary flashes */
var(Advanced) byte		FireModeFireBothEffects;
/** Used to track which effect was last used when FireModeAlternateBothEffects is used */
var transient bool      bLastWasPrimary;

/*********************************************************************************************
 Shell Eject
********************************************************************************************* */

/** Muzzle flash PSC and Templates */
var(ShellEject) ParticleSystem		ShellEjectPSCTemplate;

/** The default socket name to attach to */
var(ShellEject) name				ShellEjectSocketName;

/** If set, the shell eject will automatically trigger with the muzzle flash */
var(ShellEject) bool				bAutoActivateShellEject;

/** Transient vars used by muzzle flash instances */
var transient KFParticleSystemComponent	ShellEjectPSC;

/** Life time */
var globalconfig float 				ShellEjectLifetime;

/*********************************************************************************************
 * Functions
********************************************************************************************* */

cpptext
{
	void StartMuzzleFlash(struct FMuzzleEffectInfo& Effect);
	void StopMuzzleFlash(struct FMuzzleEffectInfo& Effect, UBOOL bForce);
}

/** Activate the muzzle flash effects from the owning actor */
native function CauseMuzzleFlash(optional byte FiringMode);
native function StopMuzzleFlash(optional bool bForce);
native function MuzzleFlashTimer();
native function MuzzleFlashAltTimer();

function AttachMuzzleFlash(SkeletalMeshComponent OwnerMesh, optional name SocketNameOverride, optional name ShellEjectSocketOverride)
{
	local float OwnerMeshFOV;

	// Allow code to override attachment socket
	if ( SocketNameOverride != 'None' )
	{
		MuzzleFlash.SocketName = SocketNameOverride;
	}

	// Attach the primary muzzle flash
    if( MuzzleFlash.ParticleSystemTemplate != none )
	{
        // Attach MuzzleFlashPSC to owner
        OwnerMesh.AttachComponentToSocket(MuzzleFlash.PSC, MuzzleFlash.SocketName);
		MuzzleFlash.PSC.SetTemplate(MuzzleFlash.ParticleSystemTemplate);
	}

	// Initialize and attach the muzzle flash light
	if ( MuzzleFlash.LightTemplate != None )
	{
		MuzzleFlash.LightComponent = new(self) class'KFExplosionLightComponent';
		MuzzleFlash.LightComponent.SetTemplate(MuzzleFlash.LightTemplate);
		MuzzleFlash.LightComponent.SetEnabled(false);
		OwnerMesh.AttachComponentToSocket(MuzzleFlash.LightComponent, MuzzleFlash.SocketName);
	}

	if ( bEnableSecondaryMuzzleFlash )
	{
		// Attach the alt fire muzzle flash
		if( MuzzleFlashAlt.ParticleSystemTemplate != none )
		{
			// Attach MuzzleFlashAltPSC to owner
			OwnerMesh.AttachComponentToSocket(MuzzleFlashAlt.PSC, MuzzleFlashAlt.SocketName);
			MuzzleFlashAlt.PSC.SetTemplate(MuzzleFlashAlt.ParticleSystemTemplate);
		}

		// Initialize and attach the muzzle flash light
		if ( MuzzleFlashAlt.LightTemplate != None )
		{
			MuzzleFlashAlt.LightComponent = new(self) class'KFExplosionLightComponent';
			MuzzleFlashAlt.LightComponent.SetTemplate(MuzzleFlashAlt.LightTemplate);
			MuzzleFlashAlt.LightComponent.SetEnabled(false);
			OwnerMesh.AttachComponentToSocket(MuzzleFlashAlt.LightComponent, MuzzleFlashAlt.SocketName);
		}
	}

	// Initialize and attach the shell eject psc
	if ( ShellEjectPSCTemplate != None )
	{
		if ( ShellEjectSocketOverride != 'None' )
		{
			ShellEjectSocketName = ShellEjectSocketOverride;
		}
		ShellEjectPSC = new(self) class'KFParticleSystemComponent';
		ShellEjectPSC.bAutoActivate = false;
		ShellEjectPSC.SetTemplate(ShellEjectPSCTemplate);
		ShellEjectPSC.SetFloatParameter('LifetimeParam', ShellEjectLifetime);
		OwnerMesh.AttachComponentToSocket(ShellEjectPSC, ShellEjectSocketName);
	}

	// If attaching to a foreground (1st person) mesh
	if ( OwnerMesh.DepthPriorityGroup == SDPG_Foreground )
	{
		// No MuzzleFlashPSC foreground adjustment for now
		//MuzzleFlash.PSC.bDepthTestEnabled=false;
		//MuzzleFlashAlt.PSC.bDepthTestEnabled=false;

		if( MuzzleFlash.PSC != none )
		{
			MuzzleFlash.PSC.SetDepthPriorityGroup( MuzzleFlash.FirstPersonDepthPriorityGroup );
			MuzzleFlash.PSC.bDepthTestEnabled = MuzzleFlash.FirstPersonDepthPriorityGroup == SDPG_Foreground;
		}
		if( MuzzleFlashAlt.PSC != none )
		{
			MuzzleFlashAlt.PSC.SetDepthPriorityGroup( MuzzleFlashAlt.FirstPersonDepthPriorityGroup );
			MuzzleFlashAlt.PSC.bDepthTestEnabled = MuzzleFlashAlt.FirstPersonDepthPriorityGroup == SDPG_Foreground;
		}

		//if( ShellEjectPSC != none )
		//{
			//ShellEjectPSC.SetDepthPriorityGroup( SDPG_Foreground );
			//ShellEjectPSC.bDepthTestEnabled = true;
		//}
	}

	// If attaching to a mesh with a custom FOV
	if (OwnerMesh.IsA('KFSkeletalMeshComponent'))
	{
		OwnerMeshFOV = KFSkeletalMeshComponent(OwnerMesh).FOV;
		SetFOV(OwnerMeshFOV);
	}

	Owner = OwnerMesh.Owner;
}

/**
 * Adjust the FOV for the first person weapon and arms.
 */
simulated event SetFOV( float NewFOV )
{
	MuzzleFlash.PSC.SetFOV(NewFOV);

	if ( MuzzleFlashAlt.PSC != None )
	{
		MuzzleFlashAlt.PSC.SetFOV(NewFOV);
	}
}

function DetachMuzzleFlash(SkeletalMeshComponent OwnerMesh)
{
	OwnerMesh.DetachComponent(MuzzleFlash.PSC);
	OwnerMesh.DetachComponent(MuzzleFlashAlt.PSC);
	if ( MuzzleFlash.LightComponent != None )
	{
		OwnerMesh.DetachComponent(MuzzleFlash.LightComponent);
	}
	if ( MuzzleFlashAlt.LightComponent != None )
	{
		OwnerMesh.DetachComponent(MuzzleFlashAlt.LightComponent);
	}
	if ( ShellEjectPSC != None )
	{
		OwnerMesh.DetachComponent(ShellEjectPSC);
	}
}

/** Returns a socket name used by the primary muzzle flash effect */
function name GetSocketName()
{
	return MuzzleFlash.SocketName;
}

/** Returns a socket name used by the secondary muzzle flash effect */
function name GetAltSocketName()
{
	return MuzzleFlashAlt.SocketName;
}

function CauseShellEject()
{
	if ( !Owner.WorldInfo.bDropDetail && ShellEjectPSC != none )
	{
		ShellEjectPSC.ActivateSystem();
	}
}

function SetShellEjectLife(float NewLifetime=8.f)
{
	if ( ShellEjectPSCTemplate != None )
	{
		ShellEjectPSC.SetFloatParameter('LifetimeParam', NewLifetime);
	}
}

defaultproperties
{
	Begin Object Class=KFParticleSystemComponent Name=ParticleSystemComponent0
		bAutoActivate=FALSE
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=ParticleSystemComponent1
		bAutoActivate=FALSE
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=ParticleSystemComponent2
		bAutoActivate=FALSE
		TickGroup=TG_PostUpdateWork
	End Object

	MuzzleFlash=(PSC=ParticleSystemComponent0, TimerName=MuzzleFlashTimer)
	MuzzleFlashAlt=(PSC=ParticleSystemComponent1, TimerName=MuzzleFlashAltTimer)
	ShellEjectSocketName=ShellEject
	bAutoActivateShellEject=true

	FireModeAlternateBothEffects=255
	FireModeFireBothEffects=255
}
