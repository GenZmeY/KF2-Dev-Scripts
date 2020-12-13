//=============================================================================
// AICommand_ScriptedPawn_TraverseSpline
//=============================================================================
// AICommand to get a pawn to follow a spline
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class AICommand_ScriptedPawn_TraverseSpline extends AICommand
    within KFAIController;

var transient int SegmentGranularity;

var transient KFPawn_Scripted MyScriptedPawn;

var transient array<SplineActor> Route;
var transient int SegIdx, SubSegIdx;
var transient vector Direction, SubSegEnd;
var transient SplineComponent SegSplineComp;
var transient float SegSplineLen;

static function bool TraverseSpline(KFAIController AI, SplineActor SplineStart, SplineActor SplineEnd, int Granularity)
{
    local AICommand_ScriptedPawn_TraverseSpline Cmd;

	if( AI != none && SplineStart != none )
	{
		Cmd = new(AI) class'AICommand_ScriptedPawn_TraverseSpline';
		if( Cmd != none )
		{
			SplineStart.FindSplinePathTo(SplineEnd, Cmd.Route);
			Cmd.SegmentGranularity = Granularity;
			AI.PushCommand( Cmd );
			return true;
		}
	}
	return false;
}

function Pushed()
{
	local SplineActor SplineEnd;

	Super.Pushed();
	MyScriptedPawn = KFPawn_Scripted(Pawn);

	// The route represents the path between the pawn's spawn location and its goal, but it's allowed
	// to continue after its goal if there are more spline actors that the goal connects to, so add
	// those to the end of the route
	SplineEnd = Route[Route.Length - 1];
	while (SplineEnd.Connections.Length > 0)
	{
		SplineEnd = SplineEnd.Connections[0].ConnectTo;
		Route.AddItem(SplineEnd);
	}

	GotoState('TraversingSpline');
}

function Paused( GameAICommand NewCommand )
{
	Super.Paused( NewCommand );
}

function Resumed( Name OldCommandName )
{
	Super.Resumed( OldCommandName );
}

function Popped()
{
	Super.Popped();
	Route.Length = 0;
	MyScriptedPawn.EndedRoute(Status == 'Success');
}

function bool PawnReachedDestination(vector Dest)
{
	return VSize2D(MyScriptedPawn.Location - Dest) < 10;
}

state TraversingSpline
{
Begin:
	if (Route.Length == 0)
	{
		Status = 'Failure';
	}
	else
	{
		// consider the pawn to have "reached" the node it spawns at
		MyScriptedPawn.ReachedRouteMarker(0, Route[0], 0, 0);

		SegIdx = 1;
		do // for each segment (space between two spline actors)...
		{
			SegSplineComp = Route[SegIdx-1].FindSplineComponentTo(Route[SegIdx]);
			SegSplineLen = SegSplineComp.GetSplineLength();
			SubSegIdx = 1;
			do // for each sub-segment (space between segment "granules")...
			{
				SubSegEnd = SegSplineComp != none ?
					SegSplineComp.GetLocationAtDistanceAlongSpline((float(SubSegIdx)/float(SegmentGranularity+1))*SegSplineLen) :
					Route[SegIdx].Location;
				do // update velocity and rotation toward sub-segment
				{
					Direction = SubSegEnd - Pawn.Location;
					if (MyScriptedPawn.Physics == PHYS_Walking)
					{
						Direction.Z = 0.f;
					}
					Direction = Normal(Direction);

					MyScriptedPawn.Velocity = Direction * MyScriptedPawn.GroundSpeed;
					MyScriptedPawn.SetDesiredRotation(rotator(Direction),,,0.1f);

					Sleep(0.f);
				} until (PawnReachedDestination(SubSegEnd)); // until we've reached the next segment "granule"

				MyScriptedPawn.ReachedRouteMarker(
					SegIdx,
					SubSegIdx == (SegmentGranularity + 1) ? Route[SegIdx] : none,
					SubSegIdx,
					SegSplineLen / float(SegmentGranularity+1));

				++SubSegIdx;
			} until (PawnReachedDestination(Route[SegIdx].Location) && SubSegIdx == (SegmentGranularity + 2)); // until we've reached the next spline actor AND we've reached each "granule" ...
			// ... because we can get close enough to the next spline actor before we've made sure we've reached each "granule", and that can throw off logic

			++SegIdx;
		} until (SegIdx == Route.Length); // until we've reached the last spline actor in the route

		MyScriptedPawn.Acceleration = vect(0, 0, 0);
		Status = 'Success';
	}

	PopCommand(self);
}