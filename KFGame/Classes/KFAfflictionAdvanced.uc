//=============================================================================
// KFAfflictionAdvanced
//=============================================================================
// An affliction base class for custom (non special move) handling 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAfflictionAdvanced extends KFAfflictionBase
	abstract;

/** Duration copied from owner's incap settings */
var float Duration;
/** true once activated until duration has expired */
var bool bIsActive;

/** Default Effect Socket */
var protected name EffectSocketName;

/** Copy incap settings we're going to need */
function Init(KFPawn P, EAfflictionType Type, KFPerk InstigatorPerk)
{
	Super.Init(P, Type, InstigatorPerk);
	Duration = P.IncapSettings[Type].Duration;
}

/** */
function Activate(optional class<KFDamageType> DamageType = none)
{
	if ( !bIsActive )
	{
		super.Activate();
		PawnOwner.SetTimer(Duration, false, nameof(DeActivate), self);
		bIsActive = true;		
	}
}

function DeActivate()
{
	bIsActive = false;
	`log(self@"was deactivaed", bDebug);
}

/** flush active timers */
function Shutdown()
{
	// flush active timers
	if ( bIsActive )
	{
		DeActivate();
		PawnOwner.ClearTimer(nameof(DeActivate), self);

		`log(self@"shutdown on owner death", bDebug);
	}
}

defaultproperties
{
	EffectSocketName=Hips
}
