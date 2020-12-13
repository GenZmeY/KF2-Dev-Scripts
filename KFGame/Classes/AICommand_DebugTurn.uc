//=============================================================================
// AICommand_DebugTurnInPlace
//=============================================================================
// Used for debugging turn in place node
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_DebugTurn extends AICommand
	within KFAIController;

/** Player who issued the cheat command (focus is set to this) */
var KFPlayerController	Player;

/** NPC will play melee sequences if player gets in range */
var bool				bEnableMeleeWhenInRange;

static function bool DebugTurnInPlace( KFAIController AI, bool InEnableMeleeWhenInRange, KFPlayerController InPlayerWhoIssuedCheat )
{
	local AICommand_DebugTurn Cmd;

	if( AI != None )
	{
		Cmd = new(AI) Default.Class;
		if( Cmd != None )
		{
			Cmd.Player = InPlayerWhoIssuedCheat;
			Cmd.bEnableMeleeWhenInRange = InEnableMeleeWhenInRange;
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

function Pushed()
{
	super.Pushed();
	
	// Make sure TurnInPlace node is enabled
	if( MyKFPawn != none )
	{
		MyKFPawn.bDisableTurnInPlace = false;
	}

	GotoState( 'Debug_TurningInPlace' );
}

/** Starts melee attack if player is in range, ends if player leaves range */
function CheckMeleeRange()
{
	local Pawn P;

	if( !MyKFPawn.IsDoingSpecialMove() )
	{
		foreach WorldInfo.AllPawns( class'Pawn', P )
		{
			if( P != Pawn && VSize( Pawn.Location - P.Location ) < 850.f )
			{
				StartMeleeSpecialMove();
				return;
			}
		}
	}
	return;

	if( Player != none )
	{
		if( InMeleeRange( Player.Pawn.Location ) )
		{
			if( !MyKFPawn.IsDoingSpecialMove() )
			{
				// Target is in range and I'm not already busy with a special move, so start one now.				
				StartMeleeSpecialMove();
			}
		}
		else if( MyKFPawn.IsDoingSpecialMove(SM_MeleeAttack) )
		{
			// Target is out of range, end the special move.
			MyKFPawn.EndSpecialMove();
		}
	}
}

function StartMeleeSpecialMove()
{
	MyKFPawn.DoSpecialMove(SM_MeleeAttack, false, none, 5);
}

state Debug_TurningInPlace
{
	event BeginState( name PreviousStateName )
	{
		Super.BeginState( PreviousStateName );

		if( bEnableMeleeWhenInRange )
		{
			SetTimer( 0.1f, true, nameof(CheckMeleeRange), self );
		}
	}

Begin:
	SetFocalPoint(vect(0,0,0));

	if( (Player == none || !IsControllerAlive( Player )) || (MyKFPawn == none || !IsPawnAlive(MyKFPawn)) )
	{
		Sleep( 0.1f );
		Status = 'Success';
		PopCommand( self );
	}
	else
	{
		Focus = Player.Pawn;
	}
	
	Sleep( 3.f );
	Goto( 'Begin' );
}

defaultproperties
{
	bAllowedToAttack=false
	bIgnoreNotifies=true
	bIgnoreStepAside=true
}