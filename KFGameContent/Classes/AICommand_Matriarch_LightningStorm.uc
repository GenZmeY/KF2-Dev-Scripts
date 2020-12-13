//=============================================================================
// AICommand_Matriarch_LightningStorm
//=============================================================================
// Handler for matriarch's lightning AOE attack running through AI.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class AICommand_Matriarch_LightningStorm extends AICommand_SpecialMove
    within KFAIController_ZedMatriarch
    config(AI);

/** Base constructor to handle init */
static function bool LightningStorm(KFAIController_ZedMatriarch AI)
{
    local AICommand_Matriarch_LightningStorm Cmd;

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

    `AILog( "Beginning lightning storm "$Enemy, 'Command_LightningStorm' );
    AIActionStatus = "Starting lightning storm AICommand";

    if (Enemy != none)
    {
        Focus = Enemy;
    }
}

function Popped()
{
    AIActionStatus = "Finished lightning storm AICommand";
    LastLightningStormTime = WorldInfo.TimeSeconds;

    super.Popped();
}

state Command_SpecialMove
{
    function float GetPreSpecialMoveSleepTime()
    {
        return FRand();
    }

    function bool ExecuteSpecialMove()
    {
        SpecialMove = GetSpecialMove();

        `AILog( GetFuncName()@SpecialMove, 'Command_LightningStorm' );

        if (SpecialMove != SM_None && MyKFPawn.CanDoSpecialMove(SpecialMove))
        {
            MyKFPawn.DoSpecialMove(SpecialMove, true, GetInteractionPawn(), 255);
            return true;
        }
        else
        {
            return false;
        }
    }

    function ESpecialMove GetSpecialMove()
    {
        return SM_Custom2;
    }
}

defaultproperties
{
    bShouldCheckSpecialMove = true
    bAllowedToAttack = false
    TimeOutDelaySeconds = 6.f
    bIgnoreStepAside = true
}