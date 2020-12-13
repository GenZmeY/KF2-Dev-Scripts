//=============================================================================
// KFWeapAttach_FlameBase
//=============================================================================
// Base weapon attachment class for weapons that shoot fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================
class KFWeapAttach_SprayBase extends KFWeaponAttachment;

/** Internal.  TRUE if fire is spewing, false otherwise. */
var protected transient bool        bFireSpraying;

var protected transient int         NextFlamePoolIdx;
/** A pool of fire spray actors to use for this attachment. Needed because if you fire quickly blending between the two looks better */
var protected transient KFSprayActor  	FlamePool[2];

/** The spray actor we are associated with, if currently firing. */
var transient protected KFSprayActor	ActiveFlameSpray;

/** The Archetype to spawn for our fire spray actors. */
var() protected const KFSprayActor 		FlameSprayArchetype;

/** Whether TurnOnPilot has already been called */
var protected bool                  bPilotLightOn;

/** Pilot light sound play event */
var AkEvent                         PilotLightPlayEvent;

/** Pilot light sound stop event */
var AkEvent	                        PilotLightStopEvent;

/** Effect for the pilot light. */
var protected KFParticleSystemComponent	PSC_PilotLight;
/** Socket to attach the pilot light to. */
var name PilotLightSocketName;

/** Dynamic light component */
var() KFExplosionLight		PilotLightTemplate;

var transient KFExplosionLightComponent PilotLightComponent;

/** Emitter to play when firing stops. */
var() const ParticleSystemComponent PSC_EndSpray;

/** How hot the Barrel Currently is */
var float                           BarrelHeat;

/** How hot the Barrel was last frame */
var float                           LastBarrelHeat;

/*********************************************************************************************
* Optional dynamic pilot lights
********************************************************************************************* */
struct PilotLight
{
	var() PointLightComponent  Light;
	var() name                 LightAttachBone;
	var() float                FlickerIntensity;
	var() float                FlickerInterpSpeed;
	var() float                LastLightBrightness;
};
var(PilotLights) transient array<PilotLight> PilotLights;

/*********************************************************************************************
 * @name Debugging
 *********************************************************************************************/

simulated function SetFlameDebugDamage(bool bDebugDirectDamage, bool bDebugSplashDamage, bool bDebugShowSplashRadius, bool bDebugShowCollision)
{
 `if(`notdefined(ShippingPC))
    FlamePool[0].bDebugDirectDamage = bDebugDirectDamage;
	FlamePool[0].bDebugSplashDamage = bDebugSplashDamage;
	FlamePool[0].bDebugShowSplashRadius = bDebugShowSplashRadius;
	FlamePool[0].bDebugShowCollision = bDebugShowCollision;
	FlamePool[1].bDebugDirectDamage = bDebugDirectDamage;
	FlamePool[1].bDebugSplashDamage = bDebugSplashDamage;
	FlamePool[1].bDebugShowSplashRadius = bDebugShowSplashRadius;
	FlamePool[1].bDebugShowCollision = bDebugShowCollision;
`endif
}

simulated function SetFlameDebugFX(bool bDebugShowSeeds, bool bDebugShowBones, bool bDebugForceNonPlayerParticles)
{
 `if(`notdefined(ShippingPC))
    FlamePool[0].bDebugShowSeeds = bDebugShowSeeds;
	FlamePool[0].bDebugShowBones = bDebugShowBones;
    FlamePool[0].bDebugForceNonPlayerParticles = bDebugForceNonPlayerParticles;
    FlamePool[1].bDebugShowSeeds = bDebugShowSeeds;
    FlamePool[1].bDebugShowBones = bDebugShowBones;
    FlamePool[1].bDebugForceNonPlayerParticles = bDebugForceNonPlayerParticles;
`endif
}

/**
 * Called immediately before gameplay begins.
 */
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	if ( WeaponMIC == None && WeapMesh != None )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(0);
	}
}

simulated protected function TurnOnPilot()
{
	local vector MuzzleLoc;
	local rotator Aim;
	local int Idx;

	if (bPilotLightOn)
		return;

	// start looping sound
	StartPilotSound();

	// Attach and start up the pilot light
	if( PSC_PilotLight != None )
	{
		WeapMesh.AttachComponentToSocket( PSC_PilotLight, PilotLightSocketName );

		PSC_PilotLight.ActivateSystem();

		// Turn on the low flame, turn off the high flame
		PSC_PilotLight.SetFloatParameter('Pilotlow', 1.0);
		PSC_PilotLight.SetFloatParameter('Pilothigh', 0.0);
	}

	if( class'KFWeap_FlameBase'.default.bArePilotLightsAllowed )
	{
		// Attach the dynamic pilot lights
		for( Idx = 0; Idx < PilotLights.length; ++Idx )
		{
			WeapMesh.AttachComponentToSocket( PilotLights[Idx].Light, PilotLights[Idx].LightAttachBone );
		}
	}
	else
	{
		PilotLights.Remove(0, PilotLights.length);
	}

	SetPilotDynamicLightEnabled(true);

	GetFlameSocketLocAndRot(MuzzleLoc, Aim);

	if( FlamePool[0] == None )
	{
        FlamePool[0] = Spawn(FlameSprayArchetype.Class, Instigator,, MuzzleLoc, Aim, FlameSprayArchetype, TRUE);
	}
	if( FlamePool[1] == None )
	{
		FlamePool[1] = Spawn(FlameSprayArchetype.Class, Instigator,, MuzzleLoc, Aim, FlameSprayArchetype, TRUE);
	}

	// attach flamesprays here too, so they are hooked up before firing
	FlamePool[0].AttachToMesh(Self, WeapMesh, FlamePool[0].SpraySocketName);
	FlamePool[1].AttachToMesh(Self, WeapMesh, FlamePool[1].SpraySocketName);

    // Set these to be visual only as we do the damage on the first person versions
	FlamePool[0].bVisualOnly=true;
	FlamePool[1].bVisualOnly=true;

	if( PSC_EndSpray != None )
	{
    	PSC_EndSpray.SetTemplate(FlamePool[0].SprayEndEffect);
        WeapMesh.AttachComponentToSocket( PSC_EndSpray, FlamePool[0].SpraySocketName );
	}

	bPilotLightOn = TRUE;
}

simulated function GetFlameSocketLocAndRot(out Vector out_Loc, out Rotator out_Rot)
{
	if( WeapMesh != none && FlameSprayArchetype.Class.default.SpraySocketName != '' )
	{
		WeapMesh.GetSocketWorldLocationAndRotation(FlameSprayArchetype.Class.default.SpraySocketName, out_Loc, out_Rot);
	}
	else
	{
		out_Loc = Instigator.Location;
		out_Rot = Instigator.Rotation;
	}
}

simulated protected function TurnOffPilot()
{
//	if (AC_PilotLoop != None)
//	{
//		AC_PilotLoop.FadeOut(0.2f, 0.f);
//		AC_PilotLoop = None;
//
//		if (PilotLightExtinguishSound != None)
//		{
//			WeaponPlaySound(PilotLightExtinguishSound);
//		}
//	}

	if( PSC_PilotLight != None )
	{
		PSC_PilotLight.DeActivateSystem();
	}

    StopPilotSound();

	// turn off lights
    SetPilotDynamicLightEnabled( false );

	bPilotLightOn = FALSE;
}


simulated protected function KFSprayActor GetFlameSprayFromPool()
{
	local KFSprayActor Ret;
	Ret = FlamePool[NextFlamePoolIdx];

	NextFlamePoolIdx++;
	if (NextFlamePoolIdx >= ArrayCount(FlamePool))
	{
		NextFlamePoolIdx = 0;
	}

	return Ret;
}

/**
 * Starts playing looping Pilot light sound
 */
simulated function StartPilotSound()
{
	if( Instigator != none && !Instigator.IsFirstPerson() )
	{
		if ( PilotLightPlayEvent != None )
		{
        	Instigator.PlaySoundBase(PilotLightPlayEvent, true, true, true,, true);
		}
    }
}

/**
 * Stops playing looping Pilot light sound
 */
simulated function StopPilotSound()
{
	if ( PilotLightStopEvent != None )
	{
    	Instigator.PlaySoundBase(PilotLightStopEvent, true, true, true,, true);
    }
}

/**
 * Toggle the dynamic pilot lights
 */
simulated function SetPilotDynamicLightEnabled( bool bLightEnabled )
{
    local int Idx;

    // Don't turn these on if we're not in third person
    if( bLightEnabled && (Instigator != none && Instigator.IsFirstPerson()) )
    {
        return;
    }

	// turn off lights
	for (Idx=0; Idx<PilotLights.length; ++Idx)
	{
		PilotLights[Idx].Light.SetEnabled(bLightEnabled);
	}
}

simulated protected function TurnOnFireSpray()
{
	//local GearGRI GRI;

	if (!bDeleteMe && !bFireSpraying)
	{
		// spawn flame actor
		ActiveFlameSpray = GetFlameSprayFromPool();
		if (ActiveFlameSpray != None)
		{
			ActiveFlameSpray.BeginSpray();
		}
		else
		{
			`Warn(GetFuncName() @ "ActiveFlameSpray is NONE!!!");
		}

        StopPilotSound();
        SetPilotDynamicLightEnabled(false);

//		if( PSC_UnignitedFuel != None )
//		{
//			PSC_UnignitedFuel.ActivateSystem();
//		}

		bFireSpraying = TRUE;
	}
}

simulated protected function TurnOffFireSpray()
{
	// play end-of-firing poof.  will stop itself.
	if( PSC_EndSpray != None )
	{
		PSC_EndSpray.ActivateSystem();
	}

	if (ActiveFlameSpray != None)
	{
		ActiveFlameSpray.DetachAndFinish();
	}

	if( !bDeleteMe )
	{
		StartPilotSound();
		SetPilotDynamicLightEnabled(true);
	}

//
//	if( PSC_UnignitedFuel != None )
//	{
//		PSC_UnignitedFuel.DeactivateSystem();
//	}

	bFireSpraying = FALSE;
}

/**
 * Spawn all of the effects that will be seen in behindview/remote clients.  This
 * function is called from the pawn, and should only be called when on a remote client or
 * if the local client is in a 3rd person mode.
*/
simulated function bool ThirdPersonFireEffects(vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local bool bResult;

	bResult = Super.ThirdPersonFireEffects(HitLocation,P,ThirdPersonAnimRateByte);

	// Wider effect distances for fire spray. Called on Instigator to go beyond the weapon mesh cull distance
	if ( P.FiringMode != 1 && P.ActorEffectIsRelevant(P, false, 15000, 2000) )
	{
		TurnOnFireSpray();
		bResult = true;
	}

    return bResult;
}

simulated function StopThirdPersonFireEffects(optional bool bForce)
{
    TurnOffFireSpray();

    Super.StopThirdPersonFireEffects(bForce);
}

/** Attach weapon to owner's skeletal mesh */
simulated function AttachTo(KFPawn P)
{
    Super.AttachTo(P);

    TurnOnPilot();
}

/** Detach weapon from owner's skeletal mesh */
simulated function DetachFrom(KFPawn P)
{
	if( bFireSpraying )
	{
	    TurnOffFireSpray();
	}

    TurnOffPilot();

    Super.DetachFrom(P);
}

simulated function Destroyed()
{
	local int Idx;

	if (bFireSpraying)
	{
		// make sure to clean up spray effects
		TurnOffFireSpray();
	}

	for (Idx = 0; Idx < ArrayCount(FlamePool); ++Idx)
	{
		if (FlamePool[Idx] != None)
		{
			FlamePool[Idx].Destroy();
			FlamePool[Idx] = None;
		}
	}

	StopPilotSound();

	super.Destroyed();
}

/**
 * Get the value to flicker the lights at
 */
simulated function FLOAT GetFlickerVal(FLOAT BaseVal, FLOAT Intensity, FLOAT Last, FLOAT DeltaTime, FLOAT InterpSpeed)
{
	local FLOAT GoalVal;

    GoalVal = BaseVal + RandRange(-Intensity, Intensity);
	return FInterpTo(Last, GoalVal, DeltaTime, InterpSpeed);
}

/**
 * Overridden to handle the dynamic flickering lights
 */
simulated event Tick(float DeltaTime)
{
	local int Idx;
	local float FlameHeat;

	super.Tick(DeltaTime);

	if( WorldInfo.NetMode != NM_DedicatedServer && WeaponMIC != None )
	{
        if( bFireSpraying && ActiveFlameSpray != None)
    	{
        	FlameHeat = GetRangeValueByPct(ActiveFlameSpray.MaterialHeatRange, FMin(ActiveFlameSpray.CurrentAge / ActiveFlameSpray.MaterialHeatRampTime, 1.f)) * 3.5;

            // Blend the heat in
            if( BarrelHeat < FlameHeat )
            {
                BarrelHeat += DeltaTime * 2.0;
            }
            else
            {
                BarrelHeat = FlameHeat;
            }
    	}
        else
        {
            if( BarrelHeat > 0 )
            {
                // Cool the barrel down when not shooting
                BarrelHeat -= DeltaTime * 0.5;
                if( BarrelHeat < 0 )
                {
                    BarrelHeat = 0;
                }
            }
        }

		ChangeMaterial();
        LastBarrelHeat = BarrelHeat;
	}

	// hacky flicker for lights.
 	for (Idx=0; Idx<PilotLights.Length; ++Idx)
 	{
 		if (PilotLights[Idx].Light != none)
 		{
 			PilotLights[Idx].LastLightBrightness = FMax( 0.f, GetFlickerVal(Default.PilotLights[Idx].Light.Brightness, PilotLights[Idx].FlickerIntensity, PilotLights[Idx].LastLightBrightness, DeltaTime, PilotLights[Idx].FlickerInterpSpeed) );
 			PilotLights[Idx].Light.SetLightProperties( PilotLights[Idx].LastLightBrightness, PilotLights[Idx].Light.LightColor, PilotLights[Idx].Light.Function );
 		}
 	}
}

simulated function ChangeMaterial()
{
	if( BarrelHeat != LastBarrelHeat )
	{
	    WeaponMIC.SetScalarParameterValue('Glow_Intensity', BarrelHeat);
	}
}

simulated event ChangeVisibility(bool bIsVisible)
{
	super.ChangeVisibility(bIsVisible);

	if (bIsVisible)
	{
		TurnOnPilot();
	}
	else
	{
		TurnOffPilot();
	}
}

defaultproperties
{
	Begin Object Class=ParticleSystemComponent Name=FlameEndSpray0
		bAutoActivate=FALSE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_EndSpray=FlameEndSpray0

	Begin Object Class=KFParticleSystemComponent Name=PilotLight0
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_PilotLight=PilotLight0
}


