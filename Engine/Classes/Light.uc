/**
 * Abstract Light
 *
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class Light extends Actor
	native(Light)
	ClassGroup( Lights );


var() editconst const LightComponent	LightComponent;

`if(`__TW_LIGHTING_MODIFICATIONS_) // Light Animation
/** Supported light animation types */
enum ELightAnimationTechnique
{
	/** No Animation */
	LightAnim_None,
	/** Random on/off */
	LightAnim_Flicker,
	/** Interpolate smoothly between on/off */
	LightAnim_Pulse,
	/** Like flicker, but the pattern is constant and repeating */
	LightAnim_Strobe,
	/** Light remains off mostly except when it flickers on */
	LightAnim_ChaoticFlicker,
	/** Light remains on mostly except when it flickers off */
	LightAnim_InverseChaoticFlicker
};

/** The maximum brightness value for this light. Default is 1.0 */
var(LightAnimation) const float MaxBrightness<UIMin=0.0|ClampMin=0.0>;

/** The minimum brightness override value for this light. If 0, it uses the
	global value for the light animation type specified in WorldInfo. */
var(LightAnimation) const float MinBrightness<UIMin=0.0|ClampMin=0.0>;

/** Light animation type used by this light */
var(LightAnimation) ELightAnimationTechnique AnimationType;

/** The rate at which the LightAnimation is played. Default is 1.0. Must be greater than 0 */
var(LightAnimation) float AnimationFrequency<UIMin=0.01|ClampMin=0.01|UIMax=20.0|ClampMax=20.0>;

/** Time offset into the LightAnimation. This is used to add variation so that
all the animations are not in perfect sync. default is 0.0.
Note: This value will not have any effect it is a multiple of the inverse of the AnimationFrequency.
Eg. If the AnimationFrequency is 0.5, AnimationTimeOffsets of 2, 4, 6 ... will have same effect at 0  */
var(LightAnimation) float AnimationTimeOffset;

/** The static mesh represtation of the light fixture */
var(LightAnimation) StaticMeshComponent LightMesh;

/** The MICs used by the light fixture that need modification */
var transient array<MaterialInstanceConstant> LightMeshMICs;

/** The MICs used by the base mesh (actor we're standing on) that need modification */
var transient array<MaterialInstanceConstant> BaseMeshMICs;

/** Lens flare component for the light */
var(LightAnimation)	LensFlareComponent LensFlareComp;

/** The MICs used by the lens flare that need modification */
var transient array<MaterialInstanceConstant> LensFlareMICs;

/** Animation output from previous frame */
var transient float CurveOutputValue;
`endif // Light Animation

cpptext
{
public:
	// AActor interface.
	/**
	 * Function that gets called from within Map_Check to allow this actor to check itself
	 * for any potential errors and register them with map check dialog.
	 */
#if WITH_EDITOR
	virtual void CheckForErrors();
#endif

	/**
	 * This will determine which icon should be displayed for this light.
	 **/
	virtual void DetermineAndSetEditorIcon();

	/**
	 * For this type of light, set the values which would make it affect Dynamic Primitives.
	 **/
	virtual void SetValuesForLight_DynamicAffecting();

	/**
	 * For this type of light, set the values which would make it affect Static Primitives.
	 **/
	virtual void SetValuesForLight_StaticAffecting();

	/**
	 * For this type of light, set the values which would make it affect Dynamic and Static Primitives.
	 **/
	virtual void SetValuesForLight_DynamicAndStaticAffecting();

	/**
	 * Returns true if the light supports being toggled off and on on-the-fly
	 *
	 * @return For 'toggleable' lights, returns true
	 */
	virtual UBOOL IsToggleable() const
	{
		// By default, lights are not toggleable.  You can override this in derived classes.
		return FALSE;
	}

    /** Invalidates lighting for a lighting rebuild. */
    void InvalidateLightingForRebuild(UBOOL bOnlyVisible = FALSE);

#if __TW_LIGHTING_MODIFICATIONS_  // Light Animation
	/** ticks the light
	 * @return TRUE if the actor was ticked, FALSE if it was aborted (e.g. because it's in stasis)
	 */
	virtual UBOOL 	Tick(FLOAT DeltaTime, enum ELevelTick TickType);

	/** Returns the material parameter value when synching with this light */
	FLOAT GetLightMICParamValue();

	virtual void PostLoad();
	/** Process change of property value for the light */
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
#endif
}


/** replicated copy of LightComponent's bEnabled property */
var repnotify bool bEnabled;

replication
{
	if (Role == ROLE_Authority)
		bEnabled;
}

`if(`__TW_LIGHTING_MODIFICATIONS_)
/** @return whether light volumetrics is supported */
native static final function bool IsVolumetricLightingSupported();
/** @return whether light functions are supported */
native static final function bool AreLightFunctionsSupported();
`endif

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'bEnabled')
	{
		LightComponent.SetEnabled(bEnabled);

`if(`__TW_LIGHTING_MODIFICATIONS_)
		// Update the state of the lens flare component attached to the light
		LensFlareComp.SetIsActive(bEnabled);
		LensFlareComp.LastRenderTime = WorldInfo.TimeSeconds;
`endif
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/* epic ===============================================
* ::OnToggle
*
* Scripted support for toggling a light, checks which
* operation to perform by looking at the action input.
*
* Input 1: turn on
* Input 2: turn off
* Input 3: toggle
*
* =====================================================
*/
simulated function OnToggle(SeqAct_Toggle action)
{
	if (!bStatic)
	{
		if (action.InputLinks[0].bHasImpulse)
		{
			// turn on
			LightComponent.SetEnabled(TRUE);
		`if(`__TW_LIGHTING_MODIFICATIONS_)
			LensFlareComp.SetIsActive(TRUE);
		`endif
		}
		else if (action.InputLinks[1].bHasImpulse)
		{
			// turn off
			LightComponent.SetEnabled(FALSE);
		`if(`__TW_LIGHTING_MODIFICATIONS_)
			LensFlareComp.SetIsActive(FALSE);
		`endif
		}
		else if (action.InputLinks[2].bHasImpulse)
		{
			// toggle
			LightComponent.SetEnabled(!LightComponent.bEnabled);
		`if(`__TW_LIGHTING_MODIFICATIONS_)
			LensFlareComp.SetIsActive(LightComponent.bEnabled);
		`endif
		}
		bEnabled = LightComponent.bEnabled;
		ForceNetRelevant();
		SetForcedInitialReplicatedProperty(Property'Engine.Light.bEnabled', (bEnabled == default.bEnabled));

	`if(`__TW_LIGHTING_MODIFICATIONS_)
		LensFlareComp.LastRenderTime = WorldInfo.TimeSeconds;
	`endif
	}
}

`if(`__TW_LIGHTING_MODIFICATIONS_) // Light Animation

/** returns true if the light mesh is a volumetric light cone */
native function bool HasVolumetricLightMesh();

event PostBeginPlay()
{
	local int i;
	local MaterialInterface ParentMat;
	local MaterialInstanceConstant NewMIC;
	local float DummyValue;
	local bool bVolumetricLightMesh;

	if (WorldInfo.NetMode == NM_DedicatedServer)
 	{
		SetTickIsDisabled(true);
		return;
 	}

	// Disable and destroy light if the light has a light function
	// and light functions are not supported
	if( !AreLightFunctionsSupported() && LightComponent.Function != none )
	{
		// disable tick must come first to ensure component reattach
		SetTickIsDisabled(true);
		LightComponent.SetEnabled(false);	
		return;
	}

	// Check to see if the light mesh attached is a volumetric light cone mesh
	// All the materials used by the light mesh need to be translucent for it to
	// be considered as a volumetric light mesh	
	if( LightMesh != none )
	{
		bVolumetricLightMesh = HasVolumetricLightMesh();
	}

	if( !bVolumetricLightMesh || IsVolumetricLightingSupported() )
	{
		// Create and cache the MICs that need modification (for the static mesh attachment)
		LightMeshMICs.Remove(0, LightMeshMICs.length);
		if( LightMesh != none )
		{
			for( i=0; i<LightMesh.GetNumElements(); i++ )
			{
				ParentMat = LightMesh.GetMaterial(i);
				if( ParentMat != none &&
					ParentMat.GetScalarParameterValue(class'TWMaterialExpressionLightBrightnessMultiplier'.default.ParameterName, DummyValue)
					)
				{
					NewMIC = LightMesh.CreateAndSetMaterialInstanceConstant(i);
					LightMeshMICs.AddItem(NewMIC);
				}
			}
		}
	}
	else if( bVolumetricLightMesh && !IsVolumetricLightingSupported() )
	{
		// If it is light cone mesh, and light volumetrics is disabled, detach it!
		if( LightMesh != none )
		{
			DetachComponent(LightMesh);
		}
	}

	// Create and cache the MICs that need modification (for the base mesh actor we're standing on)
	BaseMeshMICs.Remove(0, BaseMeshMICs.length);
	if( BaseSkelComponent != none )
	{
		for( i=0; i<BaseSkelComponent.GetNumElements(); i++ )
		{
			ParentMat = BaseSkelComponent.GetMaterial(i);
			if( ParentMat != none &&
				ParentMat.GetScalarParameterValue(class'TWMaterialExpressionLightBrightnessMultiplier'.default.ParameterName, DummyValue)
				)
			{
				NewMIC = BaseSkelComponent.CreateAndSetMaterialInstanceConstant(i);
				BaseMeshMICs.AddItem(NewMIC);
			}
		}
	}

	// Create and cached the lens flare MICs that need modification
	LensFlareMICs.Remove(0, LensFlareMICs.length);
	if( LensFlareComp != none )
	{
		for( i=0; i<LensFlareComp.GetNumMaterials(); i++ )
		{
			ParentMat = LensFlareComp.GetMaterial(i);
			if( ParentMat != none &&
				ParentMat.GetScalarParameterValue(class'TWMaterialExpressionLightBrightnessMultiplier'.default.ParameterName, DummyValue)
				)
			{
				NewMIC = LensFlareComp.CreateAndSetMaterialInstanceConstant(i);
				LensFlareMICs.AddItem(NewMIC);
			}
		}
	}
}

/** Called when light flickers on to activate kismet seq events */
event TriggerFlickerEvent()
{
	// Could also just activate 'SequenceEvent', since we're not going to
	// have other types associated with this light.
	TriggerEventClass(class'TWSeqEvent_LightFlicker', self);
}
`endif //__TW_

defaultproperties
{
	// when you place a light in the editor it defaults to a point light
    // @see ActorFactorLight
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.LightIcons.Light_Point_Stationary_Statics'
		Scale=0.25  // we are using 128x128 textures so we need to scale them down
		HiddenGame=True
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		SpriteCategoryName="Lighting"
	End Object
	Components.Add(Sprite)

`if(`__TW_LIGHTING_MODIFICATIONS_)
	TickGroup=TG_DuringAsyncWork
	bStatic=FALSE
	bHidden=FALSE    //Set hidden to false so that the light mesh is visible in game
`else
	bStatic=TRUE
	bHidden=TRUE
`endif
	bNoDelete=TRUE
	bMovable=FALSE
	bRouteBeginPlayEvenIfStatic=FALSE
	bEdShouldSnap=FALSE

`if(`__TW_LIGHTING_MODIFICATIONS_) // Light Animation
	MaxBrightness=1.0
	AnimationFrequency=1.0
	AnimationTimeOffset=0.0
	CurveOutputValue=-1.f

	// Light mesh
	Begin Object Class=StaticMeshComponent Name=LightMeshComponent0
	   	bAllowApproximateOcclusion=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		bOverridePrecomputedShadowOcclusion=TRUE
	End Object
	CollisionComponent=LightMeshComponent0
	LightMesh=LightMeshComponent0

	// Lens flare
	Begin Object Class=LensFlareComponent Name=LensFlareComponent0
	End Object
	LensFlareComp=LensFlareComponent0

	// kismet
	SupportedEvents.Empty
	SupportedEvents(0)=class'TWSeqEvent_LightFlicker'
`endif // Light Animation
}
