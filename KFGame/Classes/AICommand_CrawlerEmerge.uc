//=============================================================================
// AICommand_CrawlerEmerge
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_CrawlerEmerge extends AICommand_PushedBySM
	within KFAIController_ZedCrawler;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

static function bool Emerge( KFAIController_ZedCrawler AI )
{
	local AICommand_CrawlerEmerge Cmd;

	if( AI != None )
	{
		Cmd = new(AI) Default.Class;
		if( Cmd != None )
		{
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

function NavigationPoint GetStartAnchor()
{
	return none;
}

function NavigationPoint GetUpdatedAnchor()
{
	return none;
}

function SpecialMoveTimeout()
{
	// Temporarily disabled

	`AILog( self$" Special move timed out", 'Command_PushedBySM' );

	if( MyKFPawn.SpecialMove == SpecialMove )
	{
		MyKFPawn.EndSpecialMove();
	}
	if( MyKFPawn != none )
	{
		MyKFPawn.MyKFAIC.AttemptToTeleport();
		return;
	}

	Status = 'Failure';
	AbortCommand(self);
}

state WaitForMove
{
	function bool IsSpecialMoveComplete()
	{
		if( !bPreparingMove || MyKFPawn == None || MyKFPawn.SpecialMove != SpecialMove )
		{
			return true;
		}
		return false;
	}

Begin:
	SetTimer( TimeOutDelaySeconds, FALSE, nameof(self.SpecialMoveTimeOut), self );
	do
	{
		Sleep(0.1f);
	} until( IsSpecialMoveComplete() );
	// 	if( Pawn.bCrawler )
	// 	{
	// 		SetFocalPoint(Vect(0,0,0));
	// 		MyKFPawn.ResetDesiredRotation();
	// 	}
	`AILog( "bPreparingMove:" @ bPreparingMove @ "MyKFPawn:" @ MyKFPawn @ "SpecialMove:" @ MyKFPawn.SpecialMove @ SpecialMove, 'Command_PushedBySM' );
 	Status = 'Success';
 	PopCommand( self );
}

DefaultProperties
{
	TimeOutDelaySeconds=11.f
}
