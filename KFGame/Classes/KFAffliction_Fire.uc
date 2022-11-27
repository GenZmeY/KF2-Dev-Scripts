//=============================================================================
// KFAfflication_Fire
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_Fire extends KFAfflictionAdvanced;

/** How burned is this zed currently? */
var protected float     FireBurnedAmount;
/** How long does a pawn have to be burning over the heat threshhold to get to fully charred skin */
var protected float     FireFullyCharredDuration;
/** When over this % on the FirePanicResist.StackedPower, apply charring to the skin shader. Think of it like how "hot" the character needs to get before its shader gets char applied */
var protected float     FireCharPercentThreshhold;

/** On Fire Effect Template */
var protected ParticleSystem                BurningTemplate;
/** On Fire Effect Particle System Component */
var protected ParticleSystemComponent       BurningEffect;

/** Material param value from the microwave class */
var float MicrowaveParamValue;

/** Sound to play when this pawn is on fire */
var protected AkEvent OnFireSound;
/** Sound to play when this pawn stops being on fire */
var protected AkEvent OnFireEndSound;

var transient KFPlayerController Instigator;

function Init(KFPawn P, EAfflictionType Type, KFPerk InstigatorPerk)
{
    Super.Init(P, Type, InstigatorPerk);

    // copy over some settings from the affliction handler that we'll need
    FireFullyCharredDuration = P.AfflictionHandler.FireFullyCharredDuration;
    FireCharPercentThreshhold = P.AfflictionHandler.FireCharPercentThreshhold;

    if (InstigatorPerk != none)
    {
        Instigator = InstigatorPerk.OwnerPC;
    }
}

function Activate(KFPerk InstigatorPerk, optional class<KFDamageType> DamageType = none)
{
    // fire can accrue after death, but cannot trigger panic
    if ( !PawnOwner.bPlayedDeath )
    {
        Super.Activate(InstigatorPerk, DamageType);
        SetFirePanicked(true);
    }
}

function DeActivate()
{
    Super.DeActivate();
    BurningEffect.DeactivateSystem();
    SetFirePanicked(false);
}

event Tick(float DeltaTime)
{
    UpdateBurnedMatParam(DeltaTime);
}

/** Set the fire panic functionality */
function SetFirePanicked(bool bEnabled)
{
    if( PawnOwner.Role == ROLE_Authority )
    {
    	if( PawnOwner.bFirePanicked == bEnabled )
    	{
    		return;
    	}
		PawnOwner.bFirePanicked = bEnabled;
        PawnOwner.OnStackingAfflictionChanged(AF_FirePanic);
    }

    ToggleEffects(bEnabled);
}

/** Enable/Disable the Burned material effect */
function SetMaterialParameter(float BurnedAmount)
{
	local MaterialInstanceConstant MIC;

	if ( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
		foreach PawnOwner.CharacterMICs(MIC)
	    {
			MIC.SetScalarParameterValue('Scalar_Burnt',BurnedAmount);
	    }

        if ( PawnOwner.Role < ROLE_Authority )
        {
        	FireBurnedAmount = BurnedAmount * PawnOwner.AfflictionHandler.FireFullyCharredDuration;
        }
    }
}

/** Set whether or not this pawn is doing the burning effects */
function ToggleEffects(bool bEnabled, optional bool bDummy)
{
     `warn("FIRE");
	// Don't do the effects on a dedicated server
    if ( PawnOwner.WorldInfo.NetMode == NM_DedicatedServer )
	{
        return;
    }

    if( bEnabled )
    {
		if( BurningEffect == none )
		{
			BurningEffect = new(self) class'ParticleSystemComponent';
			BurningEffect.SetTemplate( BurningTemplate );
			PawnOwner.Mesh.AttachComponentToSocket( BurningEffect, EffectSocketName );
			BurningEffect.ActivateSystem();
		}
		else
		{
			BurningEffect.SetStopSpawning( -1, false );
		}

        PawnOwner.PlaySoundBase( OnFireSound, true, true, true );

        if( PawnOwner.Role < ROLE_Authority )
        {
             // So the client knows when to stop burning
            LastActivationTime = PawnOwner.WorldInfo.TimeSeconds;
        }
	}
	else
	{
		if( BurningEffect != none )
		{
            BurningEffect.SetStopSpawning( -1, true );
        }

        PawnOwner.PlaySoundBase( OnFireEndSound, true, true );
	}
}

/** Net: Server */
function UpdateBurnedMatParam( float DeltaTime )
{
	local float BurnedParam;
	local float FinalCharParam;

	if ( !PawnOwner.bPlayedDeath && PawnOwner.GetTeamNum() == 0 )
	{
		return;
	}

	// Add additional char to the skin if we're over the threshhold
    if( (PawnOwner.bPlayedDeath || CurrentStrength > (INCAP_THRESHOLD * FireCharPercentThreshhold)) && FireBurnedAmount < FireFullyCharredDuration )
    {
        FireBurnedAmount = FMin(FireBurnedAmount + DeltaTime, FireFullyCharredDuration);

        BurnedParam = FireBurnedAmount/FireFullyCharredDuration;

        // Use whichever is more burned, fire or microwave burn
        if( MicrowaveParamValue > BurnedParam )
        {
            FinalCharParam = MicrowaveParamValue;
        }
        else
        {
            FinalCharParam =  BurnedParam;
        }

        PawnOwner.RepFireBurnedAmount = FloatToByte(FinalCharParam);

        if( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
        {
            SetMaterialParameter(FinalCharParam);
        }
    }
    // Handle exclusive microwave burn
    else if( MicrowaveParamValue > 0 )
    {
        BurnedParam = FireBurnedAmount/FireFullyCharredDuration;

        // Use whichever is more burned, fire or microwave burn
        if( MicrowaveParamValue > BurnedParam )
        {
            FinalCharParam = MicrowaveParamValue;
        }
        else
        {
            FinalCharParam =  BurnedParam;
        }

        PawnOwner.RepFireBurnedAmount = FloatToByte(FinalCharParam);

        if( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
        {
            SetMaterialParameter(FinalCharParam);
        }
    }

    PawnOwner.DeathFireStackedPower = FloatToByte(CurrentStrength/INCAP_THRESHOLD);
}

/** On death send FirePanic strength to all clients so they can continue to burn (aka TearOffFirePanic) */
function Shutdown()
{
    Super.Shutdown();

    if ( PawnOwner.bTearOff )
    {
        CurrentStrength = ByteToFloat(PawnOwner.DeathFireStackedPower) * INCAP_THRESHOLD;
    }
}

defaultproperties
{
    DissipationRate=10
    bNeedsTick=true

    BurningTemplate=ParticleSystem'FX_Gameplay_EMIT.Chr.FX_CHR_Fire'
    OnFireSound=AkEvent'WW_WEP_SA_Flamethrower.Play_WEP_SA_Flamethrower_Fleshburn_Loop'
    OnFireEndSound=AkEvent'WW_WEP_SA_Flamethrower.Stop_WEP_SA_Flamethrower_Fleshburn_Loop'
}
