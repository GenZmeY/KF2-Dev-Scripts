//=============================================================================
// AICommand_FleshpoundKing_ChestBeamAttack
//=============================================================================
// Performs the Fleshpound King's chest beam attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Matt 'Squirrlz' Farber
//=============================================================================
class AICommand_FleshpoundKing_ChestBeamAttack extends AICommand_SpecialMove
    within KFAIController_ZedFleshpoundKing
    config(AI);

/** Base constructor to handle init */
static function bool ChestBeamAttack( KFAIController_ZedFleshpoundKing AI )
{
    local AICommand_FleshpoundKing_ChestBeamAttack Cmd;

    if (AI != none)
    {
        Cmd = new (AI) default.class;
        if (Cmd != none)
        {
            AI.PushCommand(Cmd);
            return true;
        }
    }

    return false;
}

function Pushed()
{
    super.Pushed();

    AIActionStatus = "Starting chest beam attack AICommand";
    if (Enemy != none)
    {
        Focus = Enemy;
    }
}

function Popped()
{
    AIActionStatus = "Finished chest beam attack AICommand";
    NextBeamCheckTime = WorldInfo.TimeSeconds + class'KFDifficulty_FleshpoundKing'.static.GetChestBeamCooldownTime( MyKFGameInfo.MyKFGRI ) + fRand();

    super.Popped();
}

state Command_SpecialMove
{
	/** Checks circumstances in which to consider special move completed */
	function bool IsSpecialMoveComplete()
	{
		if( !bPreparingMove || MyKFPawn == None || MyKFPawn.SpecialMove == SM_None || MyKFPawn.SpecialMove != GetSpecialMove() )
		{
			return true;
		}
		return false;
	}

	function ESpecialMove GetSpecialMove()
	{
		return SM_HoseWeaponAttack;
	}
}

defaultproperties
{
	bShouldCheckSpecialMove=true
	bIgnoreNotifies=true
	bAllowedToAttack=false
	TimeOutDelaySeconds=10.f
	bIgnoreStepAside=true
}