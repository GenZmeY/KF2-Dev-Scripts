//=============================================================================
// AICommand_BloatKing_Gorge
//=============================================================================
// Performs the Bloat King gorge attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class AICommand_BloatKing_Gorge extends AICommand_SpecialMove
	within KFAIController_ZedBloatKing;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool StartGorge(KFAIController_ZedBloatKing AI )
{
	local AICommand_BloatKing_Gorge Cmd;

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

	AIActionStatus = "Starting Gorge AICommand";
	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
}


function Popped()
{
	AIActionStatus = "Finished Gorge AICommand";
	EnableMeleeRangeEventProbing();
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
		SpecialMove = GetSpecialMove();

		`AILog( GetFuncName()$"()"@SpecialMove, 'Command_SpecialMove' );

		if( SpecialMove != SM_None && (!bShouldCheckSpecialMove || MyKFPawn.CanDoSpecialMove( SpecialMove )) )
		{
			AIActionStatus = "SpecialMove: "$MyKFPawn.SpecialMoves[SpecialMove];
            MyKFPawn.DoSpecialMove(SpecialMove, true, , GetSpecialMoveFlags(SpecialMove));
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