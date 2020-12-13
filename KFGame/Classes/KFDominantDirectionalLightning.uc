//=============================================================================
// KFDominantDirectionalLightning
//=============================================================================
// A dominant directional light that represents lightning,
// whose animation can be triggered
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFDominantDirectionalLightning extends DominantDirectionalLight
	ClassGroup(Lights,DirectionalLights)
	placeable;

var repnotify int TriggerCount;

replication
{
	if (bNetDirty)
		TriggerCount;
}

event PostBeginPlay()
{
	super.PostBeginPlay();

	if (AnimationType != LightAnim_ChaoticFlicker)
	{
		`warn(self$": forcing AnimationType to LightAnim_ChaoticFlicker!");
	}

	if (LightComponent != none)
	{
		LightComponent.AnimationType = LightAnim_None;
		LightComponent.SetLightProperties(LightComponent.MinBrightness);
	}
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(TriggerCount))
	{
		TriggerAnimation();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

simulated function TriggerAnimation()
{
	local float StartPct, StopPct, StartTime, StopTime, Duration, Pct, Time, DeltaTime;

	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		// replicate event
		TriggerCount++;
	}
	else
	{
		// This math is mostly pulled from LightComponent::TickLightAnimation. The idea is to set
		// LightComponent.AnimationTimeOffset such that the actual animation part of the animation
		// plays right away.

		LightComponent.AnimationType = LightAnim_ChaoticFlicker;
		Duration = 1.f/FClamp(LightComponent.AnimationFrequency, 0.01f, 20.f);
		Time = WorldInfo.TimeSeconds % Duration;
		Pct = Time / Duration;

		DeltaTime = WorldInfo.DeltaSeconds;
		StartPct = WorldInfo.ChaoticFlickerCurve.Points[1].InVal - DeltaTime * 2.f;
		StopPct = WorldInfo.ChaoticFlickerCurve.Points[WorldInfo.ChaoticFlickerCurve.Points.Length - 1].InVal + DeltaTime * 2.f;

		LightComponent.AnimationTimeOffset = (StartPct - Pct) * Duration;

		StartTime = StartPct * Duration;
		StopTime = StopPct * Duration;
		Duration = StopTime - StartTime;

		`TimerHelper.SetTimer(Duration, false, nameof(Timer_CleanupAnimation), self);
	}
}

function Timer_CleanupAnimation()
{
	CleanupAnimation();
}

simulated function CleanupAnimation()
{
	LightComponent.AnimationType = LightAnim_None;
	LightComponent.SetLightProperties(LightComponent.MinBrightness);
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true

	AnimationType=LightAnim_ChaoticFlicker
}