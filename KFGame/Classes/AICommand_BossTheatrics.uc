//=============================================================================
// AICommand_BossTheatrics
//=============================================================================
// Handles AI use of the theatrical entrances and victory animations for bosses
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_BossTheatrics extends AICommand_SpecialMove
	within KFAIController;

var byte TheatricType;
var int TheatricDuration;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool DoTheatrics( KFAIController AI,  optional byte InTheatricType, optional int InTheatricDuration )
{
	local AICommand_BossTheatrics Cmd;

	if( AI != None )
	{
		Cmd = new(AI) default.class;
		if( Cmd != None )
		{
			Cmd.TheatricType	= InTheatricType;
			Cmd.TheatricDuration	= InTheatricDuration;
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

	`AILog( "Beginning boss theatrics"$Enemy, 'Command_BossTheatrics' );
	AIActionStatus = "Starting BossTheatrics AICommand";
	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

    if( bUsePluginsForMovement )
    {
	   MovementPlugin.DisablePlugin();
	}

	DisableMeleeRangeEventProbing();
}

function Popped()
{
	AIActionStatus = "Finished boss theatrics AICommand";
	EnableMeleeRangeEventProbing();
    if( bUsePluginsForMovement )
    {
        MovementPlugin.EnablePlugin();
	}

	Super.Popped();
}

state Command_SpecialMove
{
	function float GetPreSpecialMoveSleepTime()
	{
		return FRand();
	}

	function bool ExecuteSpecialMove()
	{
		local byte SpecialMoveFlags;

		SpecialMove = GetSpecialMove();

		`AILog( GetFuncName()@SpecialMove, 'Command_BossTheatrics' );

		if( SpecialMove != SM_None && MyKFPawn.CanDoSpecialMove(SpecialMove) )
		{
			SpecialMoveFlags = class'KFSM_Zed_Boss_Theatrics'.static.PackSMFlags(MyKFPawn, TheatricType);
			if( SpecialMoveFlags != 255 )
			{
				MyKFPawn.DoSpecialMove(SpecialMove, true, GetInteractionPawn(), SpecialMoveFlags);
				return true;
			}
			else
			{
				return false;
			}
		}
		else
		{
			return false;
		}
	}

	function ESpecialMove GetSpecialMove()
	{
		return SM_BossTheatrics;
	}
}


DefaultProperties
{
	bShouldCheckSpecialMove=true
	bAllowedToAttack=false
	TimeOutDelaySeconds=25.f
}
