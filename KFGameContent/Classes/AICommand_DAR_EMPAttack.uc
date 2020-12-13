//=============================================================================
// AICommand_DAR_EMPAttack
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class AICommand_DAR_EMPAttack extends AICommand_RangedAttack
	within KFAIController_ZedDAR_EMP
	config(AI);

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool EMPAttack(KFAIController_ZedDAR_EMP AI)
{
	local AICommand_DAR_EMPAttack Cmd;

	if (AI != None)
	{
		Cmd = new(AI) default.class;
		if (Cmd != None)
		{
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

function Pushed()
{
	Super.Pushed();

	`AILog( "Beginning EMP " $ Enemy, 'Command_EMP' );
	AIActionStatus = "Starting EMP AICommand";
}

function Popped()
{
	AIActionStatus = "Finished EMP AICommand";
	LastRangeAttackTime = WorldInfo.TimeSeconds;
	Super.Popped();
}

state Command_SpecialMove
{
	function KFPawn GetInteractionPawn()
	{
		return KFPawn(Enemy);
	}
}

defaultproperties
{
	SpecialMoveClass=class'KFSM_DAR_EMPAttack'
}
