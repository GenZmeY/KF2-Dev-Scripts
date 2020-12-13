//=============================================================================
// AICommand_Base_Combat
//=============================================================================
// Base class for combat related AICommands (based on GOW2-GOW3)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Base_Combat extends AICommand
	within KFAIController
	native(AI);

/** Amount of time before initial time check */
var Vector2D	InitialTransitionCheckTime;
/** Amount of time between timed transition checks */
var Vector2D	TransitionCheckTime;
/** Default (initial) state for this combat command */
var name		DefaultStateName;

function Pushed()
{
	Super.Pushed();
}

function Popped()
{
	Super.Popped();

	ClearTimer( 'CheckInterruptCombatTransitions' );
	ClearTimer( nameof(CombatSelectTarget), self );
}

function Paused( GameAICommand NewCommand )
{
	Super.Paused( NewCommand );
}

final function float GetInitialTransitionCheckTime()
{
	return RandRange( InitialTransitionCheckTime.X, InitialTransitionCheckTime.Y );
}

final function float GetTransitionCheckTime()
{
	return RandRange( TransitionCheckTime.X, TransitionCheckTime.Y );
}
	
function bool TimedTransitionCheck( out class<AICommand> out_NewCommand, out string out_Reason );
function bool CheckTransition( out class<AICommand> out_NewCommand, out string out_Reason );

/** Calls SelectTarget() on a random timer, then resets that timer */
final function CombatSelectTarget()
{
	`AILog( GetFuncName()$"() calling SelectTarget()", 'SetEnemy' );
	SetTimer( 2.5 + FRand() * 0.75, false, nameof(CombatSelectTarget), self );
	SelectTarget();
}

state InCombat 
{
	function BeginState( name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);

		SetTargetSelectionTimer();
	}

	function SetTargetSelectionTimer()
	{
		SetTimer( 1.5f + FRand() * 0.75f, false, nameof(CombatSelectTarget), self );
	}

	function EndState( name NextStateName )
	{
		Super.EndState( NextStateName );

		// Clear target selection timer
		ClearTimer( nameof(CombatSelectTarget), self );
	}
}

DefaultProperties
{
	DefaultStateName=InCombat
	InitialTransitionCheckTime=(X=1.0,Y=1.0)
	TransitionCheckTime=(X=1.0,Y=1.0)
}