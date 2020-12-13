//=============================================================================
// AICommand_RangedAttack
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class AICommand_RangedAttack extends AICommand_SpecialMove
	config(AI);

var vector LastKnownEnemyLocation;
var float LastEnemyLocationCheckTime;

var class<KFSpecialMove> SpecialMoveClass;

function Pushed()
{
	Super.Pushed();
	StopAllLatentMovement();
	AIZeroMovementVariables();

	if( Enemy != none )
	{
		Focus = Enemy;
	}

	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
}

function Popped()
{
	EnableMeleeRangeEventProbing();
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
		SpecialMove = GetSpecialMove();
		if( SpecialMoveClass != none && SpecialMove != SM_None && MyKFPawn.CanDoSpecialMove(SpecialMove) )
		{
			MyKFPawn.DoSpecialMove(SpecialMove, true, GetInteractionPawn(), SpecialMoveClass.static.PackFlagsBase(MyKFPawn));
			return true;
		}
		else
		{
			return false;
		}
	}

	function ESpecialMove GetSpecialMove()
	{
		return SM_StandAndShootAttack;
	}
}

/** Overridden to keep track of the enemys last known location */
event HandleAICommandSpecialAction()
{
	super.HandleAICommandSpecialAction();

	if (MyKFPawn == none || Enemy == none)
	{
		return;
	}

	// Do not update LastKnownEnemyLocation every tick since it uses a swept box trace
	if (`TimeSince(LastEnemyLocationCheckTime) >= 0.25f )
	{
		// Check if our projectile could hit our target
		if (DirectProjectileFireBehavior.IsThereClearDirectFireAttackLaneFromGivenLoc(MyKFPawn.Location, Enemy))
		{
			// Update last known enemy location
			LastKnownEnemyLocation = Enemy.Location;
			LastEnemyLocationCheckTime = WorldInfo.TimeSeconds;
		}
	}
}

defaultproperties
{
	bShouldCheckSpecialMove=true
	bIgnoreNotifies=true
	bAllowedToAttack=false
	TimeOutDelaySeconds=25.f
	bIgnoreStepAside=true
}