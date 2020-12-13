//=============================================================================
// AICommand_Patriarch_MortarAttack
//=============================================================================
// Performs the Patriarch mortar attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_Patriarch_MortarAttack extends AICommand_SpecialMove
	within KFAIController_ZedPatriarch;

var bool bDoBarrage;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool FireMortar( KFAIController_ZedPatriarch AI, bool bIsBarrageAttack )
{
	local AICommand_Patriarch_MortarAttack Cmd;

	if( AI != None )
	{
		Cmd = new(AI)default.class;
		if( Cmd != None )
		{
			Cmd.bDoBarrage = bIsBarrageAttack;
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

	AIActionStatus = "Starting Mortar Attack AICommand";
	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
	bCanEvaluateAttacks = false;
}


function Popped()
{
	AIActionStatus = "Finished Mortar Attack AICommand";
	MyPatPawn.ClearMortarTargets();
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
		else if( bDoBarrage )
		{
			// Barrage
			return 2;
		}
		
		return 0;
	}

	function ESpecialMove GetSpecialMove()
	{
		return SM_SonicAttack;
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