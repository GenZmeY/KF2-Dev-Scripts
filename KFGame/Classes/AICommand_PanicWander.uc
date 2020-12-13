//=============================================================================
// AICommand_EMPWander
//=============================================================================
// Command used to make zeds wander around when they are panicked by an EMP
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================
class AICommand_PanicWander extends AICommand_HeadlessWander
	within KFAIController;

static function bool PanicWander( KFAIController AI )
{
	local AICommand_PanicWander Cmd;

	if( AI != None )
	{
		Cmd = new(AI) class'AICommand_PanicWander';
		if( Cmd != None )
		{
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

/** If this Command is resumed, make sure we still want to be wandering */
function Resumed( Name OldCommandName )
{
	if(MyKFPawn != none && !MyKFPawn.ShouldBeWandering())
	{
		AbortCommand( self );
		return;
	}
	super.Resumed(OldCommandName);
}

function EndWander( KFAIController AI )
{
	if( AI != None )
	{
       Status = 'Success';
	   PopCommand( self );
	}
}

function Popped()
{
	if( MyKFPawn != none )
	{
		MyKFPawn.bCanJumpOverWalls = MyKFPawn.default.bCanJumpOverWalls;

		/** Restore my Pawn's rotation rate */
        RotationRateMultiplier = default.RotationRateMultiplier;

		EnableMeleeRangeEventProbing();

		if( MyKFPawn.IsDoingSpecialMove() && !MyKFPawn.IsDoingSpecialMove(SM_Knockdown) )
		{
			MyKFPawn.EndSpecialMove();
		}
	}

	super.Popped();
}

DefaultProperties
{
}


