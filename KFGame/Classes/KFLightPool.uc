//=============================================================================
// KFLightPool
//=============================================================================
// A client pool to dynamical scale active lights spawned during gameplay based
// on scene relevance and priority.  Unlike other pools this doesn't have a list
// of blank components to re-use, because there is no light template system.
// Instead, expect the caller to handle component management.
//
// We can categorize lights based on lifetime in the world.  On one end you have
// very brief lights that work well with bDropDetail, but on the other we have
// environment lights that work better with GFX settings such as detail mode.
// 1. Flash / Burst (e.g. explosion, muzzle flash)
// 2. Lifespan (e.g. projectile)
// 3. Indefinite / No-Lifespan (e.g. character, weapon)
// 4. Persistent (e.g. environment)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFLightPool extends Actor
	native(Effect);

struct native LightPoolInfo
{
	var PointLightComponent Component;
	var int Priority;
	var bool bAllowReenable;
};

enum LightPoolPriority
{
	LPP_Low,
	LPP_High,
	LPP_GameplayUsed
};

/** components currently active */
var private array<LightPoolInfo> ActiveComponents;
/** maximum allowed active components */
var() int MaxOnScreenLights;

/** Save values from last frame to use when new lights are registered */
var transient int CurrentOnScreenLights;
var transient int CurrentLowestPriority;

cpptext
{
	void TickSpecial(FLOAT DeltaTime);
	UBOOL ReenableLight(UPointLightComponent* LightComp, FVector& ViewLocation);
}

//
// Called immediately before gameplay begins.
//
event PreBeginPlay()
{
	switch( WorldInfo.GetDetailMode() )
	{
		case DM_Low:
			MaxOnScreenLights = 5;
			break;
		case DM_Medium:
			MaxOnScreenLights = 10;
			break;
		case DM_High:
			MaxOnScreenLights = 20;
			break;
	}

	Super.PreBeginPlay();
}

/**
 * Register a light with the pool so it can be managed relative to other lights
 */
function bool RegisterPointLight(PointLightComponent LightComp, optional LightPoolPriority PriorityType=LPP_Low)
{
	local LightPoolInfo NewLight;
	local int i;

	// Requires attachment before calling (for now), so that we can get info on the owner.  
	// Maybe later we want to pass the owner as a function param?
	if ( LightComp.Owner == None || !LightComp.bAttached )
	{
		`log(GetFuncName()@"failed because light has not been attached");
		LightComp.SetEnabled(false);
		return false;
	}

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		`log(GetFuncName()@"perf warning: dedicated server shouldn't be playing with lights on"@LightComp.Owner);
		LightComp.DetachFromAny();
		return false;
	}

	NewLight.Component = LightComp;
	NewLight.Priority = 100 * PriorityType;
	NewLight.bAllowReenable = LightComp.bEnabled && (Owner.LifeSpan == 0 || PriorityType == LPP_GameplayUsed);
	if ( LightComp.Owner.Instigator != None && LightComp.Owner.Instigator.IsLocallyControlled() )
	{
		NewLight.Priority += 50.f;
	}

	// If the list is full start the light disabled
	if ( CurrentOnScreenLights >= MaxOnScreenLights && NewLight.Priority < CurrentLowestPriority )
	{
		`log(GetFuncName()@"disabling incoming light for Owner:"$LightComp.Owner@"Priority:"$NewLight.Priority@"Total:"$ActiveComponents.Length,bDebug);

		LightComp.SetEnabled(false);
		// If the lifespan is too short to re-enable, don't bother tracking it
		if ( !NewLight.bAllowReenable )
		{
			LightComp.DetachFromAny();
			return false;
		}
	}

	// insert into sorted list
	for (i = 0; i < ActiveComponents.Length; i++)
	{
		if ( NewLight.Priority >= ActiveComponents[i].Priority)
		{
			break;
		}
	}

	`log(GetFuncName()@"adding light for Owner:"$LightComp.Owner@"Priority:"$NewLight.Priority@"Total:"$ActiveComponents.Length,bDebug);

	// Add to the end
	ActiveComponents.InsertItem(i, NewLight);
	SetTickIsDisabled(false);
	return TRUE;
}

defaultproperties
{
	//bDebug=true

	TickGroup=TG_DuringAsyncWork
	bTickIsDisabled=true
	MaxOnScreenLights=20
}
