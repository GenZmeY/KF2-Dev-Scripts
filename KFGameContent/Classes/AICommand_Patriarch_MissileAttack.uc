//=============================================================================
// AICommand_Patriarch_MissileAttack
//=============================================================================
// Performs the Patriarch missile attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_Patriarch_MissileAttack extends AICommand_SpecialMove
	within KFAIController_ZedPatriarch;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool FireMissiles( KFAIController_ZedPatriarch AI )
{
	local AICommand_Patriarch_MissileAttack Cmd;

	if( AI != None )
	{
		Cmd = new(AI)default.class;
		if( Cmd != None )
		{
			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	Super.Pushed();
	StopAllLatentMovement();
	AIZeroMovementVariables();

	if( Enemy != none )
	{
		Focus = Enemy;
	}

	AIActionStatus = "Starting Missile Attack AICommand";
	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
	bCanEvaluateAttacks = false;
}


function Popped()
{
	AIActionStatus = "Finished Missile Attack AICommand";
	Super.Popped();
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

	function byte GetSpecialMoveFlags( ESpecialMove InSpecialMove )
	{
		if( bRaging )
		{
			return 1;
		}
		
		return 0;
	}

	function ESpecialMove GetSpecialMove()
	{
		return SM_StandAndShootAttack;
	}
}

DefaultProperties
{
	bShouldCheckSpecialMove=true
	bIgnoreNotifies=true
	bAllowedToAttack=false
	TimeOutDelaySeconds=25.f
	bIgnoreStepAside=true
}