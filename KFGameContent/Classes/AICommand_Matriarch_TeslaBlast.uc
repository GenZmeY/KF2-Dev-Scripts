//=============================================================================
// AICommand_Matriarch_TeslaBlast.uc
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class AICommand_Matriarch_TeslaBlast extends AICommand_RangedAttack
	within KFAIController_ZedMatriarch
	config(AI);

/*********************************************************************************************
* Initialization
********************************************************************************************* */

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool TeslaBlast(KFAIController_ZedMatriarch AI)
{
	local AICommand_Matriarch_TeslaBlast Cmd;

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

	`AILog("Beginning Tesla Blast " $ Enemy, 'Command_Matriarch_TeslaBlast');
	AIActionStatus = "Starting Matriarch TeslaBlast AICommand";
}

function Popped()
{
	AIActionStatus = "Finished Matriarch TeslaBlast AICommand";
	LastTeslaBlastTime = WorldInfo.TimeSeconds;

	Super.Popped();
}

defaultproperties
{
	SpecialMoveClass=class'KFSM_Matriarch_TeslaBlast'
}
