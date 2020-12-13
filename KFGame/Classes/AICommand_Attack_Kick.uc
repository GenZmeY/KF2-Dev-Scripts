//=============================================================================
// AICommand_Attack_Kick
//=============================================================================
// AI Action for kick (RMM) attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Attack_Kick extends AICommand_SM_Attack
	within KFAIController_ZedFleshpound;

var bool bForce;

/*********************************************************************************************
* Initialization
**********************************************************************************************/

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool Kick( KFAIController_ZedFleshpound AI, optional KFPawn InTarget, optional byte InSMFlags, optional bool InForce )
{
	local AICommand_Attack_Kick Cmd;

	if( AI != None )
	{
		Cmd = new(AI) default.class;
		if( Cmd != None )
		{
			if(InTarget != none)
			{
				Cmd.AttackTarget = InTarget;
			}
			else 
			{
				Cmd.AttackTarget = AI.Enemy;
			}
			Cmd.bForce = InForce;
			Cmd.SMFlags = InSMFlags;
			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	AIActionStatus = "Doing forced Kick attack";
	Focus = AttackTarget;
	AIZeroMovementVariables();
	Super.Pushed();
}

function Popped()
{
	AIActionStatus = "Finished forced Kick attack";
	LastKickClotTime = WorldInfo.TimeSeconds;
	Focus = none;
	Super.Popped();
	AIZeroMovementVariables();
	LastAttackTime_Melee = WorldInfo.TimeSeconds;
}

/*********************************************************************************************
* Special Move & State
********************************************************************************************* */

state Command_SpecialMove
{
	function bool ExecuteSpecialMove()
	{
		if( MyKFPawn == None )
			return false;

		`AILog( self$" ExecuteSpecialMove() AttackTarget: "$AttackTarget, 'Command_Attack_Melee' );
		if( AttackTarget != none )
		{
			KFAIController(KFPawn(AttackTarget).Controller).AIZeroMovementVariables();
			KFAIController(KFPawn(AttackTarget).Controller).DoPauseAI( 1.f, true, true );
		}
 		if( ShouldFinishRotation() && AttackTarget != None && AttackTarget != Pawn )
 		{
			SetDesiredRotation( Rotator(AttackTarget.Location - Pawn.Location) );
 		}

		MyKFPawn.DoSpecialMove( GetSpecialMove(), true, none, SMFlags );
		return true;
		`AILog( self$" ExecuteSpecialMove returning false because ReachedDesiredRotation isn't done?  AttackTarget: "$AttackTarget, 'Command_Attack_Melee' );
		return false;
	}

	function bool ShouldFinishRotation()
	{
		local float Dot;

// 		if( bForce )
// 		{
// 			return false;
// 		}
		// Checking dot product because determining if the FleshPound is done rotating needs to
		// more forgiving
		Dot = Normal( AttackTarget.Location - MyKFPawn.Location ) dot vector(MyKFPawn.Rotation);
		if( Dot > 0.7f )
		{
			return false;
		}

		return bFinishRotationBeforeAttack;
	}

	function bool IsSpecialMoveComplete()
	{

		if( MyKFPawn != None )
		{
			if( MyKFPawn.IsDoingMeleeAttack() )
			{
				return false;
			}
			if( !MyKFPawn.IsDoingSpecialMove( GetSpecialMove() ) )
			{
				return true;
			}
		}

		return false;
	}

	function FinishedSpecialMove()
	{
		UpdateLastMeleeTime( EAS_FullBody );
		Status = 'Success';
		super.FinishedSpecialMove();
	}
}

DefaultProperties
{
	bAllowedToAttack=false
	PostSpecialMoveSleepTime=0.f
	AttackSpecialMove=SM_MeleeAttack
	bFinishRotationBeforeAttack=true
	MaxExecuteSMAttemptsBeforeAbort=25
}
