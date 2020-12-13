//=============================================================================
// KFKActorSpawnable
//=============================================================================
// Custom KActorSpawnable that's used by KFDestructibleActor
// Used to set lighting params on the client for replicated KActors
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFKActorSpawnable extends KActorSpawnable
	native(Effect);

cpptext
{
	UBOOL ShouldTrace(UPrimitiveComponent* Primitive, AActor *SourceActor, DWORD TraceFlags);
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Ideally, these never spawn on dedicated, but just in case destroy here
 	if (WorldInfo.NetMode == NM_DedicatedServer && RemoteRole == ROLE_None)
 	{		
 		Destroy();
 	}
}

simulated function HideForInterval(float Duration)
{
	if ( Duration > 0 )
	{
		StaticMeshComponent.SetHidden(TRUE);
		SetTimer(Duration, false, nameof(UnHideTimer));
	}
}

simulated function UnHideTimer()
{
	StaticMeshComponent.SetHidden(FALSE);
}

/** Level was reset without reloading */
simulated event Reset()
{
	Destroy();
}

defaultproperties
{
	Begin Object Name=StaticMeshComponent0
		CastShadow=FALSE
		RBChannel=RBCC_EffectPhysics
	End Object

	bBlockActors=FALSE
	LifeSpan=30.f
	RemoteRole=ROLE_None
}
