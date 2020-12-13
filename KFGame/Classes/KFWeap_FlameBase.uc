//=============================================================================
// KFWeap_FlameBase
//=============================================================================
// Base weapon class used for flame weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KFWeap_FlameBase extends KFWeapon
	abstract
	config(game);

/** Internal.  TRUE if fire is spewing, false otherwise. */
var protected transient bool        bFireSpraying;

var protected transient int         NextFlamePoolIdx;
/** A pool of fire spray actors to use for this attachment. Needed because if you fire quickly blending between the two looks better */
var protected transient KFSprayActor  FlamePool[2];

/** The spray actor we are associated with, if currently firing. */
var transient protected KFSprayActor  ActiveFlameSpray;

/** The Archetype to spawn for our fire spray actors. */
var protected const KFSprayActor 	  FlameSprayArchetype;

/** Whether TurnOnPilot has already been called */
var protected bool                  bPilotLightOn;

/** Pilot light sound play event */
var AkEvent                         PilotLightPlayEvent;

/** Pilot light sound stop event */
var AkEvent	                        PilotLightStopEvent;

/** Effect for the pilot light. */
var() protected KFParticleSystemComponent	PSC_PilotLight;
/** Socket to attach the pilot light to. */
var() name PilotLightSocketName;

/** How hot the Barrel Currently is */
var float                           BarrelHeat;

/** How hot the Barrel was last frame */
var float                           LastBarrelHeat;

/** Whether this weapon should warn AI when it fires */
var() const bool					bWarnAIWhenFiring;

/*********************************************************************************************
* @name Optional dynamic pilot lights
********************************************************************************************* */
struct PilotLight
{
	var() PointLightComponent  Light;
	var() name                 LightAttachBone;
	var() float                FlickerIntensity;
	var() float                FlickerInterpSpeed;
	var() float                LastLightBrightness;
};
var(PilotLights) array<PilotLight> PilotLights;


/** Emitter to play when firing stops. */
var() const KFParticleSystemComponent PSC_EndSpray;

/** The shortest amount of time this weapon can fire */
//var() protected float               MinFireDuration;

/** The minimum amount of ammo that must be consumed before this weapon can stop firing */
var() protected byte 			MinAmmoConsumed;

/** How much ammo we've consumed since firing began */
var protected byte 				AmmoConsumed;

/** Whether pilot lights are allowed or not */
var globalconfig bool bArePilotLightsAllowed;

/*********************************************************************************************
 * @name Debugging
 *********************************************************************************************/

simulated function SetFlameComplex(bool bDoCollideComplex)
{
 `if(`notdefined(ShippingPC))
    FlamePool[0].bDoCollideComplex = bDoCollideComplex;
    FlamePool[1].bDoCollideComplex = bDoCollideComplex;
`endif
}

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

/*********************************************************************************************
 * @name Actor
 *********************************************************************************************/

/**
 * Overridden to handle the dynamic flickering lights
 */
simulated event Tick(float DeltaTime)
{
	local int Idx;
	local float FlameHeat;

	super.Tick(DeltaTime);

	if( WorldInfo.NetMode != NM_DedicatedServer && WeaponMICs.Length > 0 &&
        Instigator != None && Instigator.IsLocallyControlled() && Instigator.IsHumanControlled() )
	{
        if( bFireSpraying && ActiveFlameSpray != None)
    	{
        	FlameHeat = FlameHeatCalc();

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


simulated function float FlameHeatCalc()
{
	return GetRangeValueByPct(ActiveFlameSpray.MaterialHeatRange, FMin(ActiveFlameSpray.CurrentAge / ActiveFlameSpray.MaterialHeatRampTime, 1.f)) * 3.5;
}

simulated function ChangeMaterial()
{
	local int i;

    if( BarrelHeat != LastBarrelHeat )
    {
    	for( i = 0; i < WeaponMICs.Length; ++i )
    	{
    		if( WeaponMICs[i] != none )
    		{
				WeaponMICs[i].SetScalarParameterValue('Glow_Intensity', BarrelHeat);
			}
		}
    }
}

/** Overridden to clean up spray actors */
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

	super.Destroyed();
}

/*********************************************************************************************
 * @name Pilot light
 *********************************************************************************************/

simulated protected function TurnOnPilot()
{
	local vector MuzzleLoc;
	local rotator Aim;
	local float OwnerMeshFOV;
	local int Idx;

	if (bPilotLightOn)
		return;

	// start looping sound
	StartPilotSound();

    OwnerMeshFOV = MySkelMesh.FOV;

	// Attach and start up the pilot light
	if( PSC_PilotLight != None )
	{
		MySkelMesh.AttachComponentToSocket( PSC_PilotLight, PilotLightSocketName );

		PSC_PilotLight.ActivateSystem();

		// Turn on the low flame, turn off the high flame
		PSC_PilotLight.SetFloatParameter('Pilotlow', 1.0);
		PSC_PilotLight.SetFloatParameter('Pilothigh', 0.0);

		PSC_PilotLight.SetFOV(OwnerMeshFOV);
	}

	if( bArePilotLightsAllowed )
	{
		// Attach the dynamic pilot lights
		for( Idx = 0; Idx < PilotLights.length; ++Idx )
		{
			MySkelMesh.AttachComponentToSocket( PilotLights[Idx].Light, PilotLights[Idx].LightAttachBone );
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
	FlamePool[0].AttachToMesh(Self, MySkelMesh,FlamePool[0].SpraySocketName);
	FlamePool[1].AttachToMesh(Self, MySkelMesh, FlamePool[1].SpraySocketName);

	FlamePool[0].bDoFirstPersonFX = true;
	FlamePool[1].bDoFirstPersonFX = true;
	// Set the damage interval of the flame to the fireinterval of the weapon
	FlamePool[0].DamageInterval = FireInterval[DEFAULT_FIREMODE];
	FlamePool[1].DamageInterval = FireInterval[DEFAULT_FIREMODE];

    // Handle setting the FOV for the flame mesh and emitters
	FlamePool[0].SetFOV(OwnerMeshFOV);
	FlamePool[1].SetFOV(OwnerMeshFOV);

	// only allow owner to see 1p mesh
	FlamePool[0].SkeletalSprayMesh.SetOnlyOwnerSee( true );
	FlamePool[1].SkeletalSprayMesh.SetOnlyOwnerSee( true );

	if( PSC_EndSpray != None )
	{
   		PSC_EndSpray.SetTemplate(FlamePool[0].SprayEndEffect);
        MySkelMesh.AttachComponentToSocket( PSC_EndSpray, FlamePool[0].SpraySocketName );
	}

	bPilotLightOn = TRUE;
}

simulated function GetFlameSocketLocAndRot(out Vector out_Loc, out Rotator out_Rot)
{
	if( MySkelMesh != none && FlameSprayArchetype.Class.default.SpraySocketName != '' )
	{
		MySkelMesh.GetSocketWorldLocationAndRotation(FlameSprayArchetype.Class.default.SpraySocketName, out_Loc, out_Rot);
	}
	else
	{
		out_Loc = Instigator.Location;
		out_Rot = Instigator.Rotation;
	}
}

simulated protected function TurnOffPilot()
{
    StopPilotSound();

	if( PSC_PilotLight != None )
	{
		PSC_PilotLight.DeActivateSystem();
	}

	// turn off lights
    SetPilotDynamicLightEnabled( false );

	bPilotLightOn = FALSE;
}

/*********************************************************************************************
 * @name Effects (lights, sounds)
 *********************************************************************************************/

/**
 * Toggle the dynamic pilot lights
 */
simulated function SetPilotDynamicLightEnabled( bool bLightEnabled )
{
    local int Idx;

    // Don't turn these on if we're not the local playercontroller
    if( bLightEnabled && (Instigator == none || !Instigator.IsLocallyControlled() || !Instigator.IsFirstPerson()) )
    {
        return;
    }

	// turn off lights
	for (Idx=0; Idx<PilotLights.length; ++Idx)
	{
		PilotLights[Idx].Light.SetEnabled(bLightEnabled);
	}
}

/**
 * Starts playing looping Pilot light sound
 */
simulated function StartPilotSound()
{
	if( Instigator != none && Instigator.IsLocallyControlled() && Instigator.IsFirstPerson() )
	{
        PostAkEventOnBone(PilotLightPlayEvent, PilotLightSocketName, false, false);
    }
}

/**
 * Stops playing looping Pilot light sound
 */
simulated function StopPilotSound()
{
    PostAkEventOnBone(PilotLightStopEvent, PilotLightSocketName, false, false);
}

/**
 * Starts playing looping FireAnim and FireSnd
 */
simulated function StartLoopingFireEffects(byte FireModeNum, optional bool bForceAnim)
{
    StopPilotSound();
    SetPilotDynamicLightEnabled(false);
    super.StartLoopingFireEffects(FireModeNum, bForceAnim);
}

/**
 * Stops playing looping FireAnim and FireSnd
 */
simulated function StopLoopingFireEffects(byte FireModeNum)
{
    super.StopLoopingFireEffects(FireModeNum);
    StartPilotSound();
    SetPilotDynamicLightEnabled(true);
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

/*********************************************************************************************
 * @name Flame spray
 *********************************************************************************************/

/** Retrieves one of the spray actors FlamePool (cycles between 2 to allow animations to finish playing) */
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

simulated protected function TurnOnFireSpray()
{
	local KFSprayActor PrevFlameSpray;

	if (!bFireSpraying)
	{
		PrevFlameSpray = ActiveFlameSpray;

		// spawn flame actor
		ActiveFlameSpray = GetFlameSprayFromPool();
		if (ActiveFlameSpray != None)
		{
			if( Role == ROLE_Authority )
			{
				ActiveFlameSpray.bVisualOnly = false;
				ActiveFlameSpray.DamageModifier = GetUpgradeDamageMod();
			}

			ActiveFlameSpray.BeginSpray();

			// Disable damage from the other flame spray actor, we just want it to finish its animations
			if( Role == ROLE_Authority && PrevFlameSpray != none && PrevFlameSpray != ActiveFlameSpray )
			{
				PrevFlameSpray.bVisualOnly = true;
			}
		}
		else
		{
			`Warn(GetFuncName() @ "ActiveFlameSpray is NONE!!!");
		}

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

		if (Role == ROLE_Authority)
		{
			ActiveFlameSpray.DamageModifier = 1.f;
		}
	}

	bFireSpraying = FALSE;
}

/*********************************************************************************************
 * state SprayingFire
 * This is the default Firing State for flame weapons.
 *********************************************************************************************/

/** Runs on a loop when firing to determine if AI should be warned */
function Timer_CheckForAIWarning();

simulated state SprayingFire extends WeaponFiring
{
	simulated function BeginState( Name PreviousStateName )
	{
		AmmoConsumed = 0;
		TurnOnFireSpray();

		// Start timer to warn AI
		if( bWarnAIWhenFiring )
		{
			Timer_CheckForAIWarning();
			SetTimer( 0.5f, true, nameOf(Timer_CheckForAIWarning) );
		}

		super.BeginState(PreviousStateName);
	}

	/** Leaving state, shut everything down. */
	simulated function EndState(Name NextStateName)
	{
		if (bFireSpraying)
		{
			TurnOffFireSpray();
		}
		ClearFlashLocation();
		ClearTimer('RefireCheckTimer');
		ClearPendingFire(0);

		// Clear AI warning timer
		if( bWarnAIWhenFiring )
		{
			ClearTimer( nameOf(Timer_CheckForAIWarning) );
		}

		super.EndState(NextStateName);
	}

	/** Overriden here to enforce a minimum amount of ammo consumed (to make sure the flame stays on a minimum duration) */
	simulated function ConsumeAmmo( byte FireMode )
	{
		global.ConsumeAmmo(FireMode);

		AmmoConsumed++;
	}

	/**
	 * Check if current fire mode can/should keep on firing.
	 * This is called from a firing state after each shot is fired
	 * to decide if the weapon should fire again, or stop and go to the active state.
	 * The default behavior, implemented here, is keep on firing while player presses fire
	 * and there is enough ammo. (Auto Fire).
	 *
	 * @return	true to fire again, false to stop firing and return to Active State.
	 */
	simulated function bool ShouldRefire()
	{
		// if doesn't have ammo to keep on firing, then stop
		if( !HasAmmo( CurrentFireMode ) )
		{
			return false;
		}

		// refire if owner is still willing to fire or if we've matched or surpassed minimum
		// amount of ammo consumed
		return ( StillFiring(CurrentFireMode) || AmmoConsumed < MinAmmoConsumed );
	}

	/** Runs on a loop when firing to determine if AI should be warned */
	function Timer_CheckForAIWarning()
	{
		local vector Direction, DangerPoint;
		local vector TraceStart, Projection;
		local Pawn P;
		local KFPawn_Monster HitMonster;

		TraceStart = Instigator.GetWeaponStartTraceLocation();
		Direction = vector( GetAdjustedAim(TraceStart) );

	    // Warn all zeds within range
	    foreach WorldInfo.AllPawns( class'Pawn', P )
	    {
	        if( P.GetTeamNum() != Instigator.GetTeamNum() && !P.IsHumanControlled() && P.IsAliveAndWell() )
	        {
	            // Determine if AI is within range as well as within our field of view
	            Projection = P.Location - TraceStart;
	            if( VSizeSQ(Projection) < MaxAIWarningDistSQ )
	            {
	                PointDistToLine( P.Location, Direction, TraceStart, DangerPoint );

		            if( VSizeSQ(DangerPoint - P.Location) < MaxAIWarningDistFromPointSQ )
		            {
		                // Tell the AI to evade away from the DangerPoint
		                HitMonster = KFPawn_Monster( P );
		                if( HitMonster != none && HitMonster.MyKFAIC != None )
		                {
		                    HitMonster.MyKFAIC.ReceiveLocationalWarning( DangerPoint, TraceStart, self );
		                }
		            }
		        }
	        }
	    }
	}

	simulated function bool IsFiring()
	{
		return TRUE;
	}

	simulated function bool TryPutDown()
	{
		bWeaponPutDown = TRUE;
		return FALSE;
	}
};

/*********************************************************************************************
 * State WeaponEquipping
 * The Weapon is in this state while transitioning from Inactive to Active state.
 * Typically, the weapon will remain in this state while its selection animation is being played.
 * While in this state, the weapon cannot be fired.
*********************************************************************************************/

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
        TurnOnPilot();
	}
}

/*********************************************************************************************
 * State WeaponPuttingDown
 * Putting down weapon in favor of a new one.
 * Weapon is transitioning to the Inactive state.
*********************************************************************************************/

simulated state WeaponPuttingDown
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		TurnOffPilot();
	}
}

/*********************************************************************************************
* State WeaponAbortEquip
* Special PuttingDown state used when WeaponEquipping is interrupted.  Must come after
* WeaponPuttingDown definition or this willextend the super version.
*********************************************************************************************/

simulated state WeaponAbortEquip
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		TurnOffPilot();
	}
}

/*********************************************************************************************
 * state Inactive
 * This state is the default state.  It needs to make sure Zooming is reset when entering/leaving
 *********************************************************************************************/

auto simulated state Inactive
{
	simulated function BeginState(name PreviousStateName)
	{
		Super.BeginState(PreviousStateName);
		TurnOffPilot();
	}
}

/*********************************************************************************************
 * @name Parent overrides
 *********************************************************************************************/

/**
 * Detach weapon from skeletal mesh
 *
 * @param	SkeletalMeshComponent weapon is attached to.
 */
simulated function DetachWeapon()
{
    TurnOffPilot();
    Super.DetachWeapon();
}

simulated function CustomFire()
{
	// tell remote clients that we fired, to trigger effects
	if ( CurrentFireMode != GRENADE_FIREMODE )
	{
		IncrementFlashCount();
	}

	super.CustomFire();
}

/**
 * This function is called from the pawn when the visibility of the weapon changes
 */
simulated function ChangeVisibility(bool bIsVisible)
{
    Super.ChangeVisibility(bIsVisible);

    if( bIsVisible && !bFireSpraying )
    {
    	FlamePool[0].SetHidden(true);
    	FlamePool[1].SetHidden(true);

    	FlamePool[0].SkeletalSprayMesh.SetHidden(true);
    	FlamePool[1].SkeletalSprayMesh.SetHidden(true);
    }
    else
    {
    	FlamePool[0].SetHidden(!bIsVisible);
    	FlamePool[1].SetHidden(!bIsVisible);

    	FlamePool[0].SkeletalSprayMesh.SetHidden(!bIsVisible);
    	FlamePool[1].SkeletalSprayMesh.SetHidden(!bIsVisible);
    }

	if (bIsVisible)
	{
		TurnOnPilot();
	}
	else
	{
		TurnOffPilot();
	}
}

/**
 * Adjust the FOV for the first person weapon and arms.
 */
simulated event SetFOV( float NewFOV )
{
    Super.SetFOV(NewFOV);

    // Set the emitters to the same FOV as the weapon mesh
    if( MySkelMesh != none )
    {
        // Handle setting the FOV for the flame mesh and emitters
    	if( FlamePool[0] != none )
        {
            FlamePool[0].SetFOV(MySkelMesh.FOV);
        }
    	if( FlamePool[1] != none )
        {
            FlamePool[0].SetFOV(MySkelMesh.FOV);
        }

        if( PSC_PilotLight != none )
        {
            PSC_PilotLight.SetFOV(MySkelMesh.FOV);
        }

        if( PSC_EndSpray != none )
        {
            PSC_EndSpray.SetFOV(MySkelMesh.FOV);
        }
    }
}

/*********************************************************************************************
 * Trader
 ********************************************************************************************/

/** Allows weapon to calculate its own damage for display in trader.
  * Overridden to use spray actor damage / damage type.
  */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float BaseDamage, DoTDamage;
	local class<KFDamageType> DamageType;

	BaseDamage = default.FlameSprayArchetype.SprayDamage.X;

	DamageType = default.FlameSprayArchetype.MyDamageType;
	if( DamageType != none && DamageType.default.DoT_Type != DOT_None )
	{
		DoTDamage = (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (BaseDamage * DamageType.default.DoT_DamageScale);
	}

	return BaseDamage + DoTDamage;
}

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Flame;
}

defaultproperties
{
	Begin Object Class=KFParticleSystemComponent Name=FlameEndSpray0
		bAutoActivate=FALSE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_EndSpray=FlameEndSpray0

	Begin Object Class=KFParticleSystemComponent Name=PilotLight0
        DepthPriorityGroup=SDPG_Foreground
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_PilotLight=PilotLight0

	bWeaponNeedsServerPosition=true

	// Aim Assist
	AimCorrectionSize=0.f

 	// AI Warning
    MaxAIWarningDistSQ=1000000
    MaxAIWarningDistFromPointSQ=40000
}