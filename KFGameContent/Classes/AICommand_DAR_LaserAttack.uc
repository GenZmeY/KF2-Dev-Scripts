//=============================================================================
// AICommand_DAR_LaserAttack
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class AICommand_DAR_LaserAttack extends AICommand_RangedAttack
	within KFAIController_ZedDAR_Laser
	config(AI);

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool LaserAttack(KFAIController_ZedDAR_Laser AI)
{
	local AICommand_DAR_LaserAttack Cmd;

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

	`AILog( "Beginning Laser " $ Enemy, 'Command_Laser' );
	AIActionStatus = "Starting Laser AICommand";
}

function Popped()
{
	AIActionStatus = "Finished Laser AICommand";
	LastRangeAttackTime = WorldInfo.TimeSeconds;
	Super.Popped();
}

defaultproperties
{
	SpecialMoveClass=class'KFSM_DAR_LaserAttack'
}
