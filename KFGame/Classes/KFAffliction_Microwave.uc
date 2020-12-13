//=============================================================================
// KFAfflication_Microwave
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_Microwave extends KFAfflictionAdvanced;

/** How microwaved is this zed currently? */
var protected float     MicrowavedAmount;
/** How microwaved is this zed currently displaying? Used so we can cap how unfluffed the zed gets */
var protected float     UsedMicrowavedAmount;
/** How burned from microwaves is this zed currently? */
var protected float     MicrowaveBurnedAmount;
/** Interp curve that allows us to ramp up how charred a zed looks when hit with microwave **/
var() InterpCurveFloat MicroWaveCharCurve;
/** On Microwave Steam Effect Template */
var protected ParticleSystem                SteamingTemplate;
/** On Microwave Steam Effect Particle System Component */
var protected ParticleSystemComponent       SteamingEffect;
/** The microwave steam effect is active */
var protected bool      bSteamEffectActive;

var bool bHasToSpawnFire;

/** Sound to play when this pawn is on fire */
var protected AkEvent OnSteamSound;
/** Sound to play when this pawn stops being on fire */
var protected AkEvent OnSteamEndSound;

function Activate()
{
	Super.Activate();
	SetMicrowavePanicked(true);
}

function DeActivate()
{
    Super.DeActivate();
    SetMicrowavePanicked(false);
    SteamingEffect.DeactivateSystem();
}

/** Set the fire panic functionality */
function SetMicrowavePanicked(bool bEnabled)
{
    if( PawnOwner.Role == ROLE_Authority )
    {
    	if( MonsterOwner.bMicrowavePanicked != bEnabled )
    	{
			MonsterOwner.bMicrowavePanicked = bEnabled;
			MonsterOwner.OnStackingAfflictionChanged(AF_Microwave);
    	}
    }
}

event Tick(float DeltaTime)
{
    UpdateMicrowaveMatParam(DeltaTime);
}

/** Network: Server */
protected function UpdateMicrowaveMatParam( float DeltaTime )
{
	local float ParamValue;

    // If we're dead, turn off inflate
    if( PawnOwner.bPlayedDeath )
    {
        ParamValue=0.0;
    }
    // If we're microwave panicked, turn the inflate all the way up
    else if( MonsterOwner != none && MonsterOwner.bMicrowavePanicked )
    {
        ParamValue=1.0;
	}
	// Set the inflate to our incap power
	else
	{
        ParamValue = FMin(CurrentStrength / INCAP_THRESHOLD, 1.f);
	}

    // Deflating over time
    if( ParamValue < MicrowavedAmount )
    {
        // If we're dead, ramp down the inflate really fast
        if( PawnOwner.bPlayedDeath )
        {
            MicrowavedAmount = FMax(MicrowavedAmount - (DeltaTime * 4.0), 0);
        }
        // Ramp down the inflate over time
        else
        {
            MicrowavedAmount = FMax(MicrowavedAmount - (DeltaTime * 0.5), 0);
        }
    }
    // Inflating over time
    else if( ParamValue > MicrowavedAmount )
    {
        MicrowavedAmount = FMin(MicrowavedAmount + DeltaTime * 2.0, 1);
    }
    // Not inflating or deflating, just use the same value
    else
    {
        MicrowavedAmount = ParamValue;
    }

    // If we've already been inflated a bit, don't let us completely deflate
    if( UsedMicrowavedAmount >= 0.1 )
    {
        // Store what we used for the inflate parameter to check against later
        UsedMicrowavedAmount = FMax(MicrowavedAmount, 0.1);
    }
    else
    {
        // Store what we used for the inflate parameter to check against later
        UsedMicrowavedAmount = MicrowavedAmount;
    }

	// Set the replicated inflate value
	MonsterOwner.RepInflateMatParams.RepInflateMatParam = FloatToByte(UsedMicrowavedAmount);
	MonsterOwner.RepInflateMatParams.bHasToIgniteFlames = bHasToSpawnFire;
	MonsterOwner.RepInflateMatParams.Count += 1;
    if( MonsterOwner.WorldInfo.NetMode != NM_DedicatedServer )
    {
        SetMaterialParameter(MonsterOwner.GetCurrentInflation());

        // secondary 'burn' material parameter
        UpdateBurnedMatParam( DeltaTime );
    }
}

function UpdateBurnedMatParam( float DeltaTime )
{
    local float ParamValue;
    local KFAffliction_Fire FireAffliction;

    // We have to get our fire incap instance and tick it from here
    if ( !PawnOwner.AfflictionHandler.VerifyAfflictionInstance(AF_FirePanic) )
    {
        return;
    }

    // Set the burned value from being microwaved
    if( MonsterOwner != none )
    {
        ParamValue = EvalInterpCurveFloat(MicroWaveCharCurve, MonsterOwner.GetCurrentInflation());
        // Only make them more burned, not less. You never "unburn"
        if( ParamValue > MicrowaveBurnedAmount )
        {
            MicrowaveBurnedAmount = ParamValue;
        }
        else
        {
            ParamValue = MicrowaveBurnedAmount;
        }

        // Assign to fire affliction
        FireAffliction = KFAffliction_Fire(PawnOwner.AfflictionHandler.Afflictions[AF_FirePanic]);
        FireAffliction.MicrowaveParamValue = ParamValue;

        // Update the burned parameter from here if we're not on fire already
        if( FireAffliction.CurrentStrength <= 0 )
        {
            FireAffliction.UpdateBurnedMatParam(DeltaTime);
        }
    }
}

/** Set scalar parameter value */
function SetMaterialParameter(float ParamValue)
{
	if ( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
        // Handle steam effects
        if( ParamValue > 0.1 )
        {
            if( !bSteamEffectActive )
            {
                if(bHasToSpawnFire == false)
                {
                    SetMicrowaveSteamEffects(false);
                }
                else
                {
                    SetMicrowaveSteamEffects(true);
                }
            }
        }
        else
        {
            if( bSteamEffectActive || bHasToSpawnFire == false)
            {
                SetMicrowaveSteamEffects(false);
            }
        }

        if(bHasToSpawnFire == false)
        {
            SetMicrowaveSteamEffects(false);
        }

		if (MonsterOwner != none)
		{
			MonsterOwner.UpdateVisualInflation(ParamValue * 2.0);
		}
    }
}

/** Set whether or not this pawn is doing the steaming effects */
protected function SetMicrowaveSteamEffects(bool bEnabled)
{
	// Don't do the effects on a dedicated server
    if ( PawnOwner.WorldInfo.NetMode == NM_DedicatedServer )
	{
        return;
    }

    bSteamEffectActive = bEnabled;

    if( bEnabled )
    {
        // Prevent turning these effects on after death.  This is critical because we have
        // looping sounds (with end events) and ShutDown has already been called
        if ( PawnOwner.bPlayedDeath )
        {
            return;
        }

		if( SteamingEffect == none )
		{
            SteamingEffect = new(self) class'ParticleSystemComponent';
			SteamingEffect.SetTemplate( SteamingTemplate );
			PawnOwner.Mesh.AttachComponentToSocket( SteamingEffect, EffectSocketName );
			SteamingEffect.ActivateSystem();
		}
		else
		{
            SteamingEffect.SetStopSpawning( -1, false );
		}

        if ( OnSteamSound != None )
        {
           PawnOwner.PlaySoundBase( OnSteamSound, true, true, true );
        }
	}
	else
	{
		if( SteamingEffect != none )
		{
            SteamingEffect.SetStopSpawning( -1, true );
        }

        if ( OnSteamEndSound != None )
        {
            PawnOwner.PlaySoundBase( OnSteamEndSound, true, true );
        }
	}
}

/** flush active timers */
function Shutdown()
{
    // Must cleanup looping steam PSC and looping audio
    if( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer && CurrentStrength > 0 )
    {
        SetMaterialParameter(0);
    }

    Super.Shutdown();
}


defaultproperties
{
    DissipationRate=20.f
    bNeedsTick=True

    // Steam
    SteamingTemplate=ParticleSystem'FX_Impacts_EMIT.FX_Microwave_steam_01'
    //OnSteamSound=AkEvent'WW_WEP_SA_Microwave_Gun.Play_Microwave_Steam'
    //OnSteamEndSound=AkEvent'WW_WEP_SA_Microwave_Gun.Stop_Microwave_Steam'

    // Microwave
    MicroWaveCharCurve=(Points=((InVal=0.f,OutVal=0.f),(InVal=0.75f, OutVal=0.2f),(InVal=1.0f, OutVal=0.75f)))//(Points=((InVal=0.f,OutVal=0.f),(InVal=0.75f, OutVal=0.2f),(InVal=1.0f, OutVal=1.f)))

    bHasToSpawnFire=true;
}
