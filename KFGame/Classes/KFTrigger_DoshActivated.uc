//=============================================================================
// KFTrigger_DoshActivated
//=============================================================================
// Trigger used to start triggerable
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================

class KFTrigger_DoshActivated extends KFTrigger_MinigameButton
	config(Game);

var() int ActivationCost;

//what does this do again?
/** KFInterface_Usable */
simulated function int GetInteractionIndex(Pawn User)
{    
    return IMT_DoshActivate;
}

/** Handles trigger interaction */
function bool UsedBy(Pawn User)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(User.Controller);

	if (KFPC.PlayerReplicationInfo.Score < ActivationCost)
	{
		return false;
	}

	return super.UsedBy(User);
}

function ActivateGame()
{
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;

	if (LastActivatingUser == none)
	{
		return;
	}

	KFPC = KFPlayerController(LastActivatingUser.Controller);
	KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);

    if (ReadyToActivate())
    {
		//Deduct dosh here
		if (KFPRI != none)
		{
			KFPRI.AddDosh(-ActivationCost);
		}
		super.ActivateGame();
    }
}

defaultproperties
{
	ActivationCost=100//dosh
}