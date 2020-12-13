//=============================================================================
// AICommand_StepAside
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_StepAside extends AICommand
	within KFAIController;

var BasedPosition	 PreStepAsideLocation;
var BasedPosition	 StepAsideLocation;
var bool			 bDelayStep;
var bool			 bNoFocus;
var vector			 OriginalFocalPoint;
var actor			 OriginalFocus;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool StepAside( KFAIController AI, Pawn NewStepAsideGoal, bool inbDelayStep, optional bool inNoFocus )
{
	local AICommand_StepAside Cmd;

	if( AI != None &&
		AI.StepAsideGoal == None &&
		NewStepAsideGoal != None )
	{
		Cmd = new(AI) class'AICommand_StepAside';
		if( Cmd != None )
		{
			AI.StepAsideGoal = NewStepAsideGoal;
			Cmd.bDelayStep = inbDelayStep;	
			Cmd.bNoFocus = inNoFocus;
			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	//MyKFPawn.SetDesiredRotation( MyKFPawn.DesiredRotation );
	//MyKFPawn.bDisableTurnInPlace = true;
	MyKFPawn.SetSprinting(false);

// do not do this, this is set in the above function do not reset it
	//MyKFPawn.bIsSprinting = false;

// 	if( Focus != none )
// 	{
// 		OriginalFocus = Focus;
// 	}
// 	OriginalFocalPoint = GetFocalPoint();

	if( Steering != none )
	{
		Steering.EnableDefaultAcceleration();
	}

	Super.Pushed();

	Vect2BP( PreStepAsideLocation, Pawn.Location );

	// If we just need to stand still for a second
	if( bDelayStep )
	{
		`AILog( "Going to Command_DelayStep state", 'Command_StepAside' );
		AIActionStatus = "Delaying StepAside";
		GotoState( 'Command_DelayStep' );
	}
	else
	{
		// Otherwise, do the step aside
		`AILog( "Going to Command_StepAside state", 'Command_StepAside' );
		GotoState( 'Command_StepAside' );
	}
}

function Popped()
{
// 	if( OriginalFocus != none )
// 	{
// 		Focus = OriginalFocus;
// 	}
// 	SetFocalPoint( OriginalFocalPoint );

	AIActionStatus = "Finished StepAside";
	if( Steering != none )
	{
		Steering.DisableDefaultAcceleration();
	}

	Super.Popped();

	StepAsideGoal = None;
	if( !bNoFocus )
	{
		Focus = None;
	}

	if( Pawn != None )
	{
		Pawn.ZeroMovementVariables();
	}

	if(bReevaluatePath)
	{
		`AILog( GetFuncName()$"() Calling NotifyNeedRepath on "$outer, 'Command_StepAside' );
		outer.NotifyNeedRepath();
	}
}

state Command_StepAside
{
	/** Returns true if the specified vector is valid for us to move to */
	function bool IsValidMoveLocation( Vector ChkLoc )
	{
		return PointReachable( ChkLoc );
	}

	/** Returns a location that Best moves out of the way of StepAsideGoal */
	function bool GetStepAsideLocation()
	{
		local vector X, Y, Z, HitLocation, HitNormal;
		local array<vector> ChkLocs;
		local int Idx;
		local float StepDist;

		// If stepping aside from self, pick random direction
		if( StepAsideGoal == Pawn )
		{
			X = VRand();
			//X = Vector(Pawn.Rotation);  NEWJC (haven't tested yet)
		}
		else
		// first try a direction perpendicular to the target's velocity
		if( VSizeSq(StepAsideGoal.Acceleration) > 0 )
		{
			X = StepAsideGoal.Acceleration;
		}
		else
		if( bMovingToGoal )
		{
			`AILog( "- IS MOVING"@MoveTarget@MoveGoal@BP2Vect(MovePosition), 'Command_StepAside' );

			if( MoveTarget != None )
			{
				X = MoveTarget.Location - Pawn.Location;
			}
 			else
			if( MoveGoal != None )
			{
				X = MoveGoal.Location - Pawn.Location;
			}
			else
			if( BP2Vect(MovePosition) != vect(0,0,0) )
			{
				X = BP2Vect( MovePosition ) - Pawn.Location;
			}
			else
			{
				`AILog( self$" Moving but to where??", 'Command_StepAside' );
			}
		}
		else
		{
			X = Vector(Pawn.Rotation);
		}

		// Ignore vertical component
		X.Z = 0;
		X	= Normal(X);
		Z	= vect( 0,0,1 );
		Y	= Normal( X cross Z );

		if( Normal(Pawn.Location-StepAsideGoal.Location) dot Y < 0.f )
		{
			// flip the y to avoid running into them more
			Y = -Y;
		}

		StepDist = MaxStepAsideDist;

		// test first dir at Max Distance
		ChkLocs[0] = Pawn.Location + Y * StepDist + X * StepDist * 0.1f;
		// half dir Max Distance
		ChkLocs[1] = Pawn.Location + X * StepDist * 0.5f + Y * StepDist * 0.5f;
		// other dir Max Distance
		ChkLocs[2] = Pawn.Location - Y * StepDist + X * StepDist * 0.1f;
		// half other dir Max Distance
		ChkLocs[3] = Pawn.Location + X * StepDist * 0.5f - Y * StepDist * 0.5f;
		// Forward until there is room to get out
		ChkLocs[4] = Pawn.Location + X * StepDist;
		// slightly back a bit
		ChkLocs[5] = Pawn.Location + Y * StepDist - X * StepDist *0.1f;
		// slightly back a bit in other dir
		ChkLocs[6] = Pawn.Location - Y * StepDist - X * StepDist * 0.1f;
		// back more
		ChkLocs[7] = Pawn.Location + Y * StepDist - X * StepDist * 0.25f;
		// back other dir more
		ChkLocs[8] = Pawn.Location - Y * StepDist - X * StepDist * 0.25f;

		// return the first valid one
		for( Idx = 0; Idx < ChkLocs.Length; Idx++ )
		{
			if( IsValidMoveLocation(ChkLocs[Idx]) &&
				(Trace(HitLocation, HitNormal, ChkLocs[Idx], Pawn.Location, true) == None || VSize(HitLocation - Pawn.Location) > StepDist * 0.5) )
			{
				Debug_StepRot = Rotator( X );
				Vect2BP( Debug_StepLoc, ChkLocs[Idx] );
				Vect2BP( StepAsideLocation, ChkLocs[Idx] );

				return true;
			}
		}

		`AILog( self$" FAILED TO FIND STEP ASIDE LOCATION... RESORT TO STANDING STILL", 'Command_StepAside' );

		LastFailedToFindStepAsideLocation = WorldInfo.TimeSeconds;


		return false;
	}

	function Actor StepAside_GetMoveFocus()
	{
		return StepAsideGoal;

		if( bNoFocus )
		{
			return None;
		}

		if( Enemy != None )
		{
			return Enemy;
		}

		if( bMovingToGoal )
		{
			`AILog( self$" bMovingToGoal || bMovingToCover, Focus is MoveTarget:" @ MoveTarget, 'Command_StepAside' );
			return MoveTarget;
		}

		`AILog( self$" !HasAnyEnemies(), Focus is StepAsideGoal:" @ StepAsideGoal, 'Command_StepAside' );
		return StepAsideGoal;
	}

Begin:
	if( StepAsideGoal != None && !bIgnoreStepAside && `TimeSince(LastFailedToFindStepAsideLocation) > 1.f )
	{
		`AILog( self$" Starting to step aside...", 'Command_StepAside' );
		bReevaluatePath = true;
		if( GetStepAsideLocation() )
		{
			AIActionStatus = "Stepping Aside From  "$StepAsideGoal;
			//MyKFPawn.LookAtPawn(StepAsideGoal);
			//MoveToDirectNonPathPos( BP2Vect(StepAsideLocation), StepAside_GetMoveFocus(),, Pawn.bIsWalking );
			MoveTo( BP2Vect(StepAsideLocation), StepAside_GetMoveFocus(),, Pawn.bIsWalking );

			// check to see if they are still running into us
			if( StepAsideGoal != None && StepAsideGoal != Pawn &&
				(Pawn.Touching.Find(StepAsideGoal) != -1 || StepAsideGoal.ReachedPoint(BP2Vect( PreStepAsideLocation ), None )) )
			{
				`AILog( self$" Still touching, moving again"@Pawn.Touching.Find(StepAsideGoal)@StepAsideGoal.ReachedPoint(BP2Vect( PreStepAsideLocation ), None ), 'Command_StepAside' );

				// (obstructing pawn may get out of my way)
				Sleep( 0.5f + FRand() * 1.f );

				// set the prestepasidelocation to the current location so that we avoid getting stuck
				Vect2BP( PreStepAsideLocation, Pawn.Location );
				Goto( 'Begin' );
			}
		}

		Sleep( 0.1f + FRand() * 0.5f );
	}
	else
	{
		`AILog( self$" No step aside goal?", 'Command_StepAside' );
		Sleep( 0.5f );
	}

	`AILog( self$" Finished stepping aside", 'Command_StepAside' );
	//SetFocalPoint(Vect(0,0,0));
	//MyKFPawn.ResetDesiredRotation();
	Status = 'Success';
	PopCommand( self );
}

state Command_DelayStep
{
Begin:
	//`AILog( self$" Begin delay step aside" );

	if( StepAsideGoal != None )
	{
		if( Pawn != None )
		{
			Pawn.ZeroMovementVariables();
		}
	}

	// Just stop moving for a sec or two
	Sleep( 0.3f + (FRand() * 0.5f) );

	//`AILog( self$" Finished delay step aside" );

	Status = 'Success';
	PopCommand( self );
}

/*********************************************************************************************
* Debugging
********************************************************************************************* */

/** Build debug string */
event String GetDumpString()
{
	return Super.GetDumpString()@"Goal:"@StepAsideGoal;
}

simulated function DrawDebug( HUD HUD, name Category )
{
	Super.DrawDebug( HUD, Category );

	if( Category == 'Pathing' )
	{
		// Debug step asside
		DrawDebugCoordinateSystem( Pawn.Location, Debug_StepRot, 64.f );
		DrawDebugLine( BP2Vect( Debug_StepLoc ), Pawn.Location, 255, 255, 255 );
		DrawDebugLine( GetDestinationPosition(), Pawn.Location, 64, 128, 255 );
		DrawDebugBox( BP2Vect( PreStepAsideLocation ), vect( 5,5,5 ), 255, 0, 0 );
	}
}

defaultproperties
{
	bAllowedToAttack=false
	bReplaceActiveSameClassInstance=true
}

