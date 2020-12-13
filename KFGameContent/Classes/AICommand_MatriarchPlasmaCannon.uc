//=============================================================================
// AICommand_MatriarchPlasmaCannon
//=============================================================================
// Handler for matriarch's plasma cannon running through AI.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class AICommand_MatriarchPlasmaCannon extends AICommand_SpecialMove
    within KFAIController_ZedMatriarch
    config(AI);

/** Base constructor to handle init */
static function bool PlasmaCannonAttack(KFAIController_ZedMatriarch AI)
{
    local AICommand_MatriarchPlasmaCannon Cmd;

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

    `AILog( "Beginning electric blast "$Enemy, 'Command_PlasmaCannon' );
    AIActionStatus = "Starting plasma cannon AICommand";

    if (Enemy != none)
    {
        Focus = Enemy;
    }
}

function Popped()
{
    AIActionStatus = "Finished plasma cannon AICommand";
    LastPlasmaCannonTime = WorldInfo.TimeSeconds;

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

        `AILog( GetFuncName()@SpecialMove, 'Command_PlasmaCannon' );

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
        return SM_HoseWeaponAttack;
    }

	/** Notification that I've changed my enemy (which has already been to to Enemy) */
	function NotifyEnemyChanged( optional Pawn OldEnemy )
	{
		if (CachedChildCommand != None)
		{
			CachedChildCommand.NotifyEnemyChanged(OldEnemy);
		}

		Focus = Enemy;
		KFPawn_ZedMatriarch(Pawn).SetGunTracking(true);
	}
}

defaultproperties
{
    bShouldCheckSpecialMove = true
    bAllowedToAttack = false
    TimeOutDelaySeconds = 6.f
    bIgnoreStepAside = true
}