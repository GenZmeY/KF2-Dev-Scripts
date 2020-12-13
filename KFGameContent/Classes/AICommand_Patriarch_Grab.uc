//=============================================================================
// AICommand_Patriarch_Grab
//=============================================================================
// Performs the Patriarch tentacle grab attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_Patriarch_Grab extends AICommand_SpecialMove
	within KFAIController_ZedPatriarch;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool TentacleGrab( KFAIController_ZedPatriarch AI )
{
	local AICommand_Patriarch_Grab Cmd;

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

	AIActionStatus = "Starting Tentacle Grab AICommand";
	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
}


function Popped()
{
	AIActionStatus = "Finished Tentacle Grab AICommand";

	Super.Popped();
}

state Command_SpecialMove
{
	function ESpecialMove GetSpecialMove()
	{
		return SM_GrappleAttack;
	}

	/** Begin executing the special move */
	function bool ExecuteSpecialMove()
	{
		local KFSM_Patriarch_Grapple MyGrappleMove;

		SpecialMove = GetSpecialMove();

		`AILog( GetFuncName()$"()"@SpecialMove, 'Command_SpecialMove' );

		if( SpecialMove != SM_None && (!bShouldCheckSpecialMove || MyKFPawn.CanDoSpecialMove( SpecialMove )) )
		{
			MyPatPawn.PlayGrabDialog();
			MyPatPawn.DoSpecialMove(SpecialMove, true, Enemy, GetSpecialMoveFlags(SpecialMove));
			MyGrappleMove = KFSM_Patriarch_Grapple(MyKFPawn.SpecialMoves[SpecialMove]);
			MyGrappleMove.TentacleDamage = MyPatPawn.TentacleDamage;
			MyGrappleMove.TentacleDmgType = MyPatPawn.TentacleDamageType;
			AIActionStatus = "SpecialMove: "$MyKFPawn.SpecialMoves[SpecialMove];
			return true;
		}
		else
		{
			return false;
		}
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