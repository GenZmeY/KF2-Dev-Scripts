//=============================================================================
// KFAffliction_Snare
//=============================================================================
// The snare (slowing down) affliction
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFAffliction_Snare extends KFAfflictionAdvanced;

var float SnareSpeedModifier;

function Init(KFPawn P, EAfflictionType Type, KFPerk InstigatorPerk)
{
	Super.Init(P, Type, InstigatorPerk);

	SnareSpeedModifier = 1.f;

	if (InstigatorPerk != none)
	{
		SnareSpeedModifier = InstigatorPerk.GetSnareSpeedModifier();
	}
}

/** */
function Activate(optional class<KFDamageType> DamageType = none)
{
	if( !bIsActive )
	{
		super.Activate();
		PawnOwner.SetTimer(Duration, false, nameof(DeActivate), self);
		bIsActive = true;		
		PawnOwner.SetAfflictionSpeedModifier();
	}
}

function DeActivate()
{
	bIsActive = false;
	`log(self@"was deactivaed", bDebug);
	PawnOwner.SetAfflictionSpeedModifier();
}

/** Accessor to get known affliction speed modifier */
function float GetSpeedModifier()
{
    return bIsActive ? SnareSpeedModifier : 1.f;
}

defaultproperties
{
}