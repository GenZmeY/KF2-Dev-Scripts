//=============================================================================
// AICommand_Stumble
//=============================================================================
// Handles AI use of the stumble animation special move
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Stumble extends AICommand_PushedBySM
	within KFAIController;

var vector				Momentum;
var EHitZoneBodyPart	HitZoneLimb;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool Stumble( KFAIController AI, vector InMomentum, EHitZoneBodyPart InHitZoneLimb )
{
	local AICommand_Stumble Cmd;

	if( AI != None )
	{
		Cmd = new(AI) default.class;
		if( Cmd != None )
		{
			Cmd.Momentum = InMomentum;
			Cmd.HitZoneLimb = InHitZoneLimb;

			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	Super.Pushed();
	
	if( !bAllowMeleeCombatDecisions )
	{
		DisableMeleeRangeEventProbing();
	}
	
	`AILog( GetFuncName()$"() Beginning stumble AICommand", 'Command_Stumble' );
	AIActionStatus = "Staggering";
}

function Popped()
{
	Super.Popped();
	
	EnableMeleeRangeEventProbing();
	AIActionStatus = "Done Staggering";
	`AILog( GetFuncName()$"() Finished stumble AICommand", 'Command_Stumble' );
}

/*********************************************************************************************
* Overrides
********************************************************************************************* */

function bool ShouldIgnoreTimeTransitions()
{
	return true;
}

function bool IsAllowedToAttack()
{
	return false;
}

DefaultProperties
{
	TimeOutDelaySeconds=10.f
	bAllowedToAttack=false
	bIgnoreNotifies=true
	bAllowMeleeCombatDecisions=false
}