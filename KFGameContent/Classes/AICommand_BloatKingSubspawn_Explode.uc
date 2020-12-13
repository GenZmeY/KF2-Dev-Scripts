//=============================================================================
// AICommand_BloatKingSubspawn_Explode
//=============================================================================
// Explosive death for the BK poop monster.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class AICommand_BloatKingSubspawn_Explode extends AICommand_SpecialMove
	within KFAIController_ZedBloatKingSubspawn;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool StartExplode(KFAIController_ZedBloatKingSubspawn AI )
{
	local AICommand_BloatKingSubspawn_Explode Cmd;

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

	AIActionStatus = "Starting Explode AICommand";
	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
}


function Popped()
{
	AIActionStatus = "Finished Explode AICommand";
	Super.Popped();
}

state Command_SpecialMove
{
	function ESpecialMove GetSpecialMove()
	{
		return SM_Custom1;
	}

	function byte GetSpecialMoveFlags(ESpecialMove InSpecialMove)
	{
		if (MyKFPawn != none && MyKFPawn.CanDoSpecialMove(InSpecialMove))
		{
			return MyKFPawn.SpecialMoveHandler.SpecialMoveClasses[InSpecialMove].static.PackFlagsBase(MyKFPawn);
		}
		return 255;
	}

	/** Begin executing the special move */
	function bool ExecuteSpecialMove()
	{
		SpecialMove = GetSpecialMove();

		`AILog( GetFuncName()$"()"@SpecialMove, 'Command_SpecialMove' );

		if( SpecialMove != SM_None && (!bShouldCheckSpecialMove || MyKFPawn.CanDoSpecialMove( SpecialMove )) )
		{
			AIActionStatus = "SpecialMove: Explosion";
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