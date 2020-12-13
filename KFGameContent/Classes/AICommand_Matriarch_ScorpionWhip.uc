//=============================================================================
// AICommand_Matriarch_ScorpionWhip
//=============================================================================
// Handler for matriarch's tentacle grab attack running through AI.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class AICommand_Matriarch_ScorpionWhip extends AICommand_SpecialMove
	within KFAIController_ZedMatriarch;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool ScorpionWhip(KFAIController_ZedMatriarch AI)
{
	local AICommand_Matriarch_ScorpionWhip Cmd;

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

	if (Enemy != none)
	{
		Focus = Enemy;
	}

	AIActionStatus = "Starting Scorpion Whip AICommand";
	if(Focus != None)
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
}


function Popped()
{
	AIActionStatus = "Finished Scorpion Whip AICommand";
	LastScorpionWhipTime = WorldInfo.TimeSeconds;

	Super.Popped();

	EnableMeleeRangeEventProbing();
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
		local KFSM_Matriarch_ScorpionWhip MyGrappleMove;

		SpecialMove = GetSpecialMove();

		`AILog( GetFuncName()$"()"@SpecialMove, 'Command_SpecialMove' );

		if( SpecialMove != SM_None && (!bShouldCheckSpecialMove || MyKFPawn.CanDoSpecialMove( SpecialMove )) )
		{
			//MyMatPawn.PlayGrabDialog();
			MyMatPawn.DoSpecialMove(SpecialMove, true, Enemy, GetSpecialMoveFlags(SpecialMove));
			MyGrappleMove = KFSM_Matriarch_ScorpionWhip(MyKFPawn.SpecialMoves[SpecialMove]);
			MyGrappleMove.TentacleDamage = MyMatPawn.TentacleDamage;
			MyGrappleMove.TentacleDmgType = MyMatPawn.TentacleDamageType;
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