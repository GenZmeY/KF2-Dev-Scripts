//=============================================================================
// KFAffliction_EMPDisrupt
//=============================================================================
// An extended version of EMP that all disrupts mechanical zeds
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_EMPDisrupt extends KFAffliction_EMP;

const DISRUPT_THRESHOLD = 25.f;

var protected float DisruptCooldown;
var protected float LastDisruptActivationTime;

/** */
function Init(KFPawn P, EAfflictionType Type, KFPerk InstigatorPerk)
{
	super.Init(P, Type, InstigatorPerk);
	DisruptCooldown = P.IncapSettings[Type].ChildAfflictionCooldown;
}

function Accrue(float InPower, KFPerk InstigatorPerk, optional class<KFDamageType> DamageType = none)
{
	Super.Accrue(InPower, InstigatorPerk, DamageType);

	if (!PawnOwner.IsTimerActive(nameof(Timer_DisruptCooldown), self))
	{
		if (CurrentStrength > DISRUPT_THRESHOLD)
		{
			ActivateDisrupt();
		}
	}
}

function ActivateDisrupt()
{
	SetEMPDisrupted(true);
	PawnOwner.SetTimer(Duration, false, nameof(DeactivateDisrupt), self);
	PawnOwner.SetTimer(Duration + DisruptCooldown, false, nameof(Timer_DisruptCooldown), self);
}

function DeactivateDisrupt()
{
	SetEMPDisrupted(false);
}

function Timer_DisruptCooldown();

/** Set the EMP disrupt functionality */
function SetEMPDisrupted(bool bEnabled)
{
    if( PawnOwner.Role == ROLE_Authority )
    {
    	if( PawnOwner.bEmpDisrupted == bEnabled )
    	{
    		return;
    	}

        PawnOwner.bEmpDisrupted = bEnabled;

        // Notify special moves that they've been disrupted
	    if( PawnOwner.IsDoingSpecialMove() )
	    {
	    	PawnOwner.SpecialMoves[SpecialMove].OnEMPDisrupted();
	   	}

        PawnOwner.OnStackingAfflictionChanged(AF_EMP);
    }
    ToggleEffects(PawnOwner.bEmpDisrupted, PawnOwner.bEmpPanicked);
}

defaultproperties
{
}
