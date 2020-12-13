//=============================================================================
// KFAfflication_Poison
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_Poison extends KFAfflictionAdvanced;

function Activate()
{
	Super.Activate();
	SetPoisoned(true);
}

function DeActivate()
{
	Super.DeActivate();
	SetPoisoned(false);
}

/** Set the EMP disrupt functionality */
function SetPoisoned(bool bEnabled)
{
    if( MonsterOwner.Role == ROLE_Authority )
    {
    	if( MonsterOwner.bIsPoisoned == bEnabled )
    	{
    		return;
    	}

        MonsterOwner.bIsPoisoned = bEnabled;
        MonsterOwner.OnStackingAfflictionChanged(AF_Poison);
    }
    ToggleEffects(bEnabled);
}

function ToggleEffects( bool bEnabled, optional bool bDummy )
{
	local MaterialInstanceConstant MIC;

	if ( PawnOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
		foreach PawnOwner.CharacterMICs(MIC)
	    {
			MIC.SetScalarParameterValue('Scalar_Poison', (bEnabled) ? 1.f : 0.f);
	    }
    }
}

defaultproperties
{
	DissipationRate=10
}
