//=============================================================================
// KFWeapAttach_Flamethrower
//=============================================================================
// Custom weapon attachment for the third person flamethrower
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KFWeapAttach_Flamethrower extends KFWeapAttach_SprayBase;

/** Effect for the pilot light. */
var() protected KFParticleSystemComponent	PSC_SpineLights[4];
/** Socket to attach the pilot light to. */
var() name SpineLightSocketNames[4];

simulated protected function TurnOnPilot()
{
    local int i;

	if (bPilotLightOn)
		return;

    // Attach and start up the pilot lights
    for (i = 0; i < 4; i++)
    {
    	if( PSC_SpineLights[i] != None )
    	{
    		WeapMesh.AttachComponentToSocket( PSC_SpineLights[i], SpineLightSocketNames[i] );

    		PSC_SpineLights[i].ActivateSystem();

    		// Turn on the low flame, turn off the high flame
    		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 1.0);
    		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 0.0);
    	}
	}

    super.TurnOnPilot();
}

simulated protected function TurnOffPilot()
{
    local int i;

    Super.TurnOffPilot();

    for (i = 0; i < 4; i++)
    {
    	if( PSC_SpineLights[i] != None )
    	{
    		PSC_SpineLights[i].DeActivateSystem();
    	}
	}
}

simulated protected function TurnOnFireSpray()
{
    local int i;

	if (!bFireSpraying)
	{
        // Start up the pilot lights on top
        for (i = 0; i < 4; i++)
        {
        	if( PSC_SpineLights[i] != None )
        	{
        		// Turn off the low flame, turn on the high flame
        		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 0.0);
        		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 1.0);
        	}
    	}
	}

	Super.TurnOnFireSpray();
}

simulated protected function TurnOffFireSpray()
{
    local int i;

    for (i = 0; i < 4; i++)
    {
    	if( PSC_SpineLights[i] != None )
    	{
    		// Turn on the low flame, turn off the high flame
    		PSC_SpineLights[i].SetFloatParameter('Pilotlow', 1.0);
    		PSC_SpineLights[i].SetFloatParameter('Pilothigh', 0.0);
    	}
	}

	Super.TurnOffFireSpray();
}

defaultproperties
{
    FlameSprayArchetype=SprayActor_Flame'WEP_Flamethrower_ARCH.WEP_Flamethrower_Flame'

	Begin Object Name=PilotLight0
		Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
	End Object

    PilotLightSocketName=FXPilot1

	Begin Object Class=KFParticleSystemComponent Name=SpineLight0
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(0)=SpineLight0

	Begin Object Class=KFParticleSystemComponent Name=SpineLight1
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(1)=SpineLight1

	Begin Object Class=KFParticleSystemComponent Name=SpineLight2
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(2)=SpineLight2

	Begin Object Class=KFParticleSystemComponent Name=SpineLight3
        Template=ParticleSystem'WEP_Flamethrower_EMIT.FX_pilot_light_01'
		bAutoActivate=TRUE
		TickGroup=TG_PostUpdateWork
	End Object
	PSC_SpineLights(3)=SpineLight3

    SpineLightSocketNames(0)=FXPilot2
    SpineLightSocketNames(1)=FXPilot3
    SpineLightSocketNames(2)=FXPilot4
    SpineLightSocketNames(3)=FXPilot5

	PilotLightPlayEvent=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_PilotLight_Loop'
	PilotLightStopEvent=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_PilotLight_Loop'

	// Muzzle Flash point light
	// want this light to illuminate characters only, so Marcus gets the glow
    Begin Object Class=PointLightComponent Name=PilotPointLight0
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=1.5f
		FalloffExponent=4.f
		Radius=128.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

    Begin Object Class=PointLightComponent Name=PilotPointLight1
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=1.5f
		FalloffExponent=8.f
		Radius=128.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	PilotLights(0)=(Light=PilotPointLight0,FlickerIntensity=1.5f,FlickerInterpSpeed=0.5f,LightAttachBone=LightPilot1)
	PilotLights(1)=(Light=PilotPointLight1,FlickerIntensity=4.f,FlickerInterpSpeed=3.f,LightAttachBone=LightPilot2)
}
