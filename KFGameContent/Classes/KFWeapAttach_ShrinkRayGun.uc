//=============================================================================
// KFWeapAttach_ShrinkRayGun
//=============================================================================
// Custom weapon attachment for the third person shrink ray gun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_ShrinkRayGun extends KFWeapAttach_SprayBase;

simulated protected function TurnOffPilot()
{
	// Undo the invert of the pilot, so it does really deactivate

	bInvertPilot = false;

    Super.TurnOffPilot();

	bInvertPilot = true;
}

defaultproperties
{
	// Muzzle Flash point light
	// want this light to illuminate characters only
    Begin Object Class=PointLightComponent Name=PilotPointLight0
		LightColor=(R=0,G=200,B=255,A=255)
		Brightness=10.f
		FalloffExponent=4.f
		Radius=128.f
		CastShadows=TRUE
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=FALSE)
	End Object

	    Begin Object Class=PointLightComponent Name=PilotPointLight1
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=3.f
		FalloffExponent=8.f
		Radius=32.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=FALSE)
	End Object

	PilotLights(0)=(Light=PilotPointLight0,FlickerIntensity=25f,FlickerInterpSpeed=50f,LightAttachBone=MuzzleFlash)
	PilotLights(1)=(Light=PilotPointLight1,FlickerIntensity=4.f,FlickerInterpSpeed=50f,LightAttachBone=MuzzleFlash)

	bInvertPilot=true
}