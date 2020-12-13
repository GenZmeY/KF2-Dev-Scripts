//=============================================================================
// KFAIController_ZedSiren
//=============================================================================
// The Siren's NPC controller
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedSiren extends KFAIController_Monster;

/** Delay before next scream */
var float ScreamDelayTime;

/** Cooldown between screams */
var float ScreamCooldown;

/** Last stored time of successful scream */
var transient float LastScreamTime;

/** Push the sirens scream onto the stack before starting a move */
function PreMoveToEnemy()
{
	if( `TimeSince(CreationTime) > 1.f )
	{
		DoScream( true );
	}
	else
	{
		SetTimer( 1.f, false, nameOf(DoScream) );
	}
}

/** Executes a scream */
function DoScream( optional bool bCalledFromPreMove=false )
{
	if( MyKFPawn == none || !MyKFPawn.IsCombatCapable() || GetIsInZedVictoryState() )
	{
		return;
	}

	if( `TimeSince(LastScreamTime) > ScreamCooldown )
	{
		if( FindCommandOfClass(class'AICommand_Siren_Scream') == none )
		{
			class'AICommand_Siren_Scream'.static.Scream( self );
		}

		// Start moving to enemy
		if( !bCalledFromPreMove )
		{
			SetEnemyMoveGoal( self, true );
		}
	}
	else
	{
		SetTimer( 1.f, false, nameOf(DoScream) );			
	}
}


/** Gets the best target based on aggro or distance, moves towards them, and then (optionally) screams */
function AcquireEnemyAndScream( optional bool bStartScreamTimer, optional float ScreamTimer=1.0f )
{
	local Pawn BestTarget;
	local bool bScreamActive;

	if( MyKFPawn == none || !MyKFPawn.IsCombatCapable() || IsTimerActive(nameOf(DoScream)) || GetIsInZedVictoryState() )
	{
        //If this failed due to a combat failure, loop back to it in a bit
        if (MyKFPawn != None && !MyKFPawn.IsCombatCapable())
        {
            SetTimer(1.f, false, nameof(AcquireEnemyAndScream));
        }        
		return;
	}

	// Get a new enemy if needed
	if( Enemy == none )
	{
		BestTarget = MyKFPawn.GetBestAggroEnemy();
		if( BestTarget == none )
		{
			BestTarget = GetClosestEnemy();
		}
		if( BestTarget != none )
		{
			ChangeEnemy( BestTarget, true );
		}
	}

	bScreamActive = FindCommandOfClass( class'AICommand_Siren_Scream' ) != none;
	if( bStartScreamTimer )
	{
		if( bScreamActive )
		{
			ScreamDelayTime = WorldInfo.TimeSeconds + ScreamTimer;
		}
		else
		{
			SetTimer( ScreamTimer, false, nameOf(DoScream) );
		}
	}
	else if( !bScreamActive )
	{
		DoScream();
	}
}

/** If an incap special move just started, abort our scream command */
function NotifySpecialMoveStarted( KFSpecialMove SM )
{
	local AICommand_Siren_Scream ScreamCommand;

	if( MyKFPawn == none || !MyKFPawn.IsAliveAndWell() )
	{
		return;
	}

	if( !MyKFPawn.IsCombatCapable() )
	{
		ScreamCommand = FindCommandOfClass( class'AICommand_Siren_Scream' );
		if( ScreamCommand != none )
		{
			AbortCommand( ScreamCommand );
		}
	}

	super.NotifySpecialMoveStarted( SM );
}

/** Scream after an incap */
function NotifySpecialMoveEnded( KFSpecialMove SM )
{
	super.NotifySpecialMoveEnded( SM );

	// Allow a bit of time to blend out of incaps
	if( SM.Handle == 'KFSM_Stumble' || SM.Handle == 'KFSM_Stunned' || SM.Handle == 'KFSM_Frozen' || SM.Handle == 'KFSM_RecoverFromRagdoll' )
	{
		AcquireEnemyAndScream( true, 0.5f );
	}
}

/** Notification from the move command that we've arrived at an intermediate destination */
function NotifyReachedLatentMoveGoal()
{
	AcquireEnemyAndScream( false );
}

/** Notification from KFSM_MeleeAttack that it has completed */
function NotifyMeleeAttackFinished()
{
	super.NotifyMeleeAttackFinished();

	if( MyKFPawn != none )
	{
		MyKFPawn.NotifyMeleeAttackFinished();
	}
}

/** Notification from AICommand::Popped that it has completed */
function NotifyCommandFinished( AICommand FinishedCommand )
{
	// Need to set our scream timer after a panic wander or else Siren will likely never scream again
	if( AICommand_PanicWander(FinishedCommand) != none )
	{
		AcquireEnemyAndScream( true, 0.75f );
	}

	super.NotifyCommandFinished( FinishedCommand );
}

/** If we're in a panic state, kill the scream command */
function DoPanicWander()
{
	local GameAICommand ActiveCommand;
	local AICommand_Siren_Scream ScreamCommand;

	ActiveCommand = GetActiveCommand();
	if( ActiveCommand != none && AICommand_PanicWander(ActiveCommand) != none )
	{
		return;
	}

	ScreamCommand = FindCommandOfClass( class'AICommand_Siren_Scream' );
	if( ScreamCommand != none )
	{
		AbortCommand( ScreamCommand );
	}

	super.DoPanicWander();
}

/** Stop screaming in victory state */
function EnterZedVictoryState()
{
	local AICommand_Siren_Scream ScreamCommand;

	if( IsTimerActive(nameOf(DoScream)) )
	{
		ClearTimer( nameOf(DoScream) );
	}

	ScreamCommand = FindCommandOfClass( class'AICommand_Siren_Scream' );
	if( ScreamCommand != none )
	{
		AbortCommand( ScreamCommand );
	}

	super.EnterZedVictoryState();
}

DefaultProperties
{
	// AI / Navigation
	SprintWithinEnemyRange=(X=600.f,Y=1200.f)
	MeleeCommandClass=class'AICommand_Base_Zed'
	DefaultCommandClass=class'AICommand_Base_Zed'
	bIsProbingMeleeRangeEvents=true
	LowIntensityAttackCooldown=7.0
	bCanTeleportCloser=false

	// Scream
	ScreamCooldown=4.0
}