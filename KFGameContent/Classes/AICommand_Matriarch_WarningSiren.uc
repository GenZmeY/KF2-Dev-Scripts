//=============================================================================
// AICommand_Matriarch_WarningSiren
//=============================================================================
// Handler for matriarch's projectile shield scream running through AI.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class AICommand_Matriarch_WarningSiren extends AICommand_SpecialMove
    within KFAIController_ZedMatriarch
    config(AI);

/** Base constructor to handle init */
static function bool WarningSiren(KFAIController_ZedMatriarch AI)
{
    local AICommand_Matriarch_WarningSiren Cmd;

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

// This is called from AICommand_SpecialMove::Pushed and prevents pawn from moving during this command
// which we don't want.
function LockdownAI();

function Pushed()
{
    super.Pushed();

    `AILog( "Beginning warning siren "$Enemy, 'Command_WarningSiren' );
    AIActionStatus = "Starting warning siren AICommand";

    if (Enemy != none)
    {
        Focus = Enemy;
    }
}

function Popped()
{
    AIActionStatus = "Finished warning siren AICommand";
	LastWarningSirenTime = WorldInfo.TimeSeconds;

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

        `AILog( GetFuncName()@SpecialMove, 'Command_WarningSiren' );

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
        return SM_SonicAttack;
    }
}

defaultproperties
{
    bShouldCheckSpecialMove = true
    bAllowedToAttack = false
    TimeOutDelaySeconds = 6.f
    bIgnoreStepAside = true
}