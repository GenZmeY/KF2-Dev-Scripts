//=============================================================================
// AICommand_Crawler_LeapToWall
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Crawler_LeapToWall extends AICommand
	within KFAIController_ZedCrawler;

var KFWallPathNode	WallNode;
var NavigationPoint StartLeapNode;
var NavigationPoint EndLeapNode;
var float JumpTime;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

static function bool LeapToWall( KFAIController_ZedCrawler AI, NavigationPoint Start, NavigationPoint End, float InJumpTime )
{
	local AICommand_Crawler_LeapToWall Cmd;

	if( AI != None )
	{
		Cmd = new(AI) Default.Class;
		if( Cmd != None )
		{
			Cmd.StartLeapNode = Start;
			Cmd.EndLeapNode = End;
			Cmd.JumpTime = InJumpTime;
			AI.PushCommand(Cmd);
			return true;
		}
	}

	return false;
}

function Pushed()
{
	super.Pushed();

	DisableMeleeRangeEventProbing();
	//MoveTimer = -1.0;
	//Pawn.ZeroMovementVariables();
	StopAllLatentMovement(); // Abort move commands, too?
	GotoState('LeapingToWall');
}

function Popped()
{
	super.Popped();

	EnableMeleeRangeEventProbing();
}

/*********************************************************************************************
* Notifications
********************************************************************************************* */

/** Prevent changing enemy while paused */
function bool CanChangeEnemy( Pawn NewEnemy )
{
	return false;
}

function bool NotifyLanded(vector HitNormal, Actor FloorActor )
{
    Pawn.SetPhysics(PHYS_Spider);
    return true;
}

function bool NotifyFallingHitWall(vector HitNormal, actor Wall)
{
	return NotifyHitWall( HitNormal, Wall );
}

function bool NotifyHitWall(vector HitNormal, actor HitActor)
{
	if( !HitActor.bCanStepUpon )
	{
		`warn( GetFuncName()$"() Wall "$HitActor$" bCanStepUpOn is FALSE" );
		return false;
	}

	if( Pawn.Physics == PHYS_Falling )
	{
		Pawn.SetPhysics( PHYS_Spider );
		Pawn.SetBase( HitActor, HitNormal );
		DisableNotifyHitWall(1.f);
	}
	return true;
}

/*********************************************************************************************
* LeapToWall state
********************************************************************************************* */

state LeapingToWall
{
	event BeginState( name PreviousStateName )
	{
		Pawn.ZeroMovementVariables();
	}

	function bool NotifyHitWall(vector HitNormal, actor HitActor)
	{
		if( !HitActor.bCanStepUpon )
		{
			`warn( GetFuncName()$"() Wall "$HitActor$" bCanStepUpOn is FALSE" );
			return false;
		}

		if( Pawn.Physics == PHYS_Falling )
		{
			Pawn.SetPhysics( PHYS_Spider );
			Pawn.SetBase( HitActor, HitNormal );
			DisableNotifyHitWall(1.f);
		}
		return true;
	}

	function bool NotifyLanded(vector HitNormal, Actor FloorActor )
    {
		if( HitNormal != vect(0,0,1) )
		{
			Pawn.SetPhysics(PHYS_Spider);
			return true;
		}
		return false;
    }

	function bool DoWallLeap( Actor Target )
	{
		//local Vector Suggested;
		local Vector JumpVel;

		if( (Pawn.Physics == PHYS_Walking || Pawn.Physics == PHYS_Spider) )
		{
			MoveTimer = 2.f;
			//MyKFPawn.SuggestJumpVelocity( Suggested, Target.Location, Pawn.Location );
			//JumpVel = ComputeTrajectoryByTime( Pawn.Location, Target.Location, 0.4f );
			
			JumpVel = ComputeTrajectoryByTime( Pawn.Location, Target.Location, JumpTime );
			MyKFPawn.Velocity = JumpVel;
			MoveTarget = Target;
			//MyKFPawn.Acceleration = vect( 0,0,0 );
			MyKFPawn.SetPhysics( PHYS_Falling );
			return true;
		}
	    return false;
	}

	function DoLeap()
	{
		local vector JumpVel;

		JumpVel = ComputeTrajectoryByTime( Pawn.Location, EndLeapNode.Location, JumpTime );
		Pawn.ZeroMovementVariables();

		if( EndLeapNode.Location.Z > Pawn.Location.Z )
		{
			JumpVel.Z *= 1.04f;
		}
		MyKFPawn.Velocity = JumpVel;
		MyKFPawn.SetPhysics( PHYS_Falling );
		SetFocalPoint(vect(0,0,0));
		Focus = EndLeapNode;
	}

Begin:
	DoWallLeap( EndLeapNode );
	WaitForLanding();
	// 2.5.14
	if( NavigationPoint(MoveTarget) != none )
	{
		Pawn.SetAnchor( NavigationPoint(MoveTarget) );
	}
	while( RouteCache.Length > 0 && RouteCache[ 0 ] == Pawn.Anchor )
	{
		RouteCache_RemoveIndex(0);
	}

//	Pawn.SetPhysics( PHYS_Spider );  2.9.2014
// 	Pawn.ResetDesiredRotation();
// 	SetFocalPoint(vect(0,0,0));
 //	Focus = none;
	Focus = RouteCache[0];
	Pawn.ZeroMovementVariables();
	Sleep( 0.35f ); // Note: Sleep( 0.1f ) results in weird snap rotation
	RecordLeapToWall();
	Status = 'Success';
	PopCommand( self );
};

state RotateToFocus
{
	function PushedState()
	{
		super.PushedState();
		AIActionStatus = "In RotateToFocus state";
	}

Begin:
	SetFocalPoint( vect(0,0,0) );
	Focus = EndLeapNode;
	FinishRotation();
	SetFocalPoint(Vect(0,0,0));
	Focus = none;
	Pawn.ResetDesiredRotation();
	PopState();
}

DefaultProperties
{
	bAllowedToAttack=false
	bIgnoreNotifies=true
	bIgnoreStepAside=true
}

