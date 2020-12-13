//=============================================================================
// AICommand_Crawler_MoveToGoal
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Crawler_MoveToGoal extends AICommand_MoveToGoal
	within KFAIController_ZedCrawler;


//function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
//{
//}

/*********************************************************************************************
* Initialization
********************************************************************************************* */

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool CrawlerMoveToGoal( KFAIController_ZedCrawler AI, Actor NewMoveGoal, optional Actor NewMoveFocus, optional float NewMoveOffset,
				optional bool bIsValidCache,
				optional bool bInCanPathfind = true,
				optional bool bInAllowedToAttackDuringMove = true,
				optional bool bInAllowPartialPath = true )
{
    local AICommand_Crawler_MoveToGoal Cmd;

	if( AI != None && NewMoveGoal != None )
	{
		Cmd = new(AI) class'AICommand_Crawler_MoveToGoal';
		if( Cmd != None )
		{
			// Never actually want to move to a controller, substitute pawn instead
			if( Controller(NewMoveGoal) != None )
			{
				NewMoveGoal = Controller(NewMoveGoal).Pawn;
			}

			// Replaced with setting on Cmd, 11/6
			AI.MoveGoal				= NewMoveGoal;
			AI.MoveFocus			= NewMoveFocus;
			AI.MoveOffset			= NewMoveOffset;
			Cmd.MoveToActor			= NewMoveGoal;
			Cmd.bValidRouteCache	= bIsValidCache;
			Cmd.bCanPathfind		= bInCanPathfind;
			Cmd.bAllowedToAttack	= bInAllowedToAttackDuringMove;
			Cmd.bAllowPartialPath	= bInAllowPartialPath;
			AI.SetBasedPosition( AI.MovePosition, vect(0,0,0) );
			AI.PushCommand( Cmd );
			return true;
		}
	}
	return false;
}

/*********************************************************************************************
* MovingToGoal state
* TODO: Look into benefits of moving LeapToWall command code into this command, to avoid 
* interrupting latent movement.
********************************************************************************************* */

function bool NotifyLanded( vector HitNormal, Actor FloorActor )
{
	//`log( "**** NotifyLanded **** Phys: "$Pawn.Physics$" HitNormal: "$HitNormal$" FloorActor: "$FloorActor$" Floor is currently "$Pawn.Floor );

	//bJumpingToWall = false;
	if( HitNormal.Z >= Pawn.WalkableFloorZ && (Pawn.Physics == PHYS_Walking || Pawn.Physics == PHYS_Falling) )
	{
		Pawn.SetPhysics( PHYS_Walking );
		return true;
	}
	
	//bJumpingToWall = false;
	`AILog( GetFuncName()$" setting physics to PHYS_Spider, FloorActor: "$FloorActor, 'Crawler');
	Pawn.SetPhysics(PHYS_Spider);
	return true;
}

state MovingToGoal
{
	event BeginState( name PreviousStateName )
	{
		bSpawnedByEmergeSpecialMove = false;
		super.BeginState( PreviousStateName );

		DisableSeePlayer(0.f);
	}

	function FindDirectPath()
	{
	}

	function bool CanDirectlyReach( actor Goal )
	{
		local KFPathnode KFP;

		KFP = KFPathnode( Goal );

		if( KFP == none )
		{
			if( Pawn.Physics == PHYS_Spider )
			{
				return false;
			}

			return Super.CanDirectlyReach( Goal );
		}

// 		if( Pawn.Physics == PHYS_Walking )
// 		{
// 			if( KFWallPathNode(Goal) != none )
// 			{
// 				`AILog( GetFuncName()$" returning true for goal "$Goal, 'Command_Crawler_MoveToGoal' );
// 				return true;
// 			}
// 		}
		
		if( Pawn.Physics == PHYS_Spider )
		{
			return false;

			if( KFP.bIsDropDownDest )
			{
				`AILog( GetFuncName()$" returning false for goal "$Goal$" because it's a dropdown dest", 'Command_Crawler_MoveToGoal' );
				return false;
			}
			
			if( KFWallPathNode(Goal) != none )
			{
				`AILog( GetFuncName()$" returning false for goal "$Goal, 'Command_Crawler_MoveToGoal' );
				return false;
			}
		}

		return Super.CanDirectlyReach( Goal );
	}

	function bool NotifyBaseChange( actor NewBase, vector NewFloor )
	{
		`AILog( GetFuncName()$" OldBase: "$Pawn.Base$" NewBase: "$NewBase$" NewFloor: "$NewFloor$" OldFloor: "$OldFloor, 'Command_Crawler_MoveToGoal' );

		if( NewFloor != OldFloor && NewFloor == vect(0,0,1) && Pawn.Physics == PHYS_Spider )
		{
			`AILog( GetFuncName()$" setting pawn physics back to walking", 'Command_Crawler_MoveToGoal' );
			Pawn.SetPhysics( PHYS_Walking );
		}
		else
		if( NewFloor != OldFloor && IsDoingLatentMove() && Pawn != none && Pawn.Physics == PHYS_Spider && NewBase != none && !NewBase.IsA('Pawn') && NewBase.bWorldGeometry )
		{
			AIActionStatus = "NotifyBaseChange, to "$NewBase$": But not stopping my movement Dist From Goal: "$VSize(MoveTarget.Location - Pawn.Location);
			`AILog( "NotifyBaseChange, to "$NewBase$": But not stopping my movement Dist From Goal: "$VSize(MoveTarget.Location - Pawn.Location));
		}
		return false;
	}

	function bool NotifyFallingHitWall(vector HitNormal, actor Wall)
	{
		return NotifyHitWall( HitNormal, Wall );
	}

	function bool NotifyHitWall( vector HitNormal, actor Wall )
	{
		if( KFDoorActor( Wall ) == none )
		{
			`AILog( GetFuncName()$"() Wall: "$Wall$" HitNormal: "$HitNormal, 'HitWall' );
		}
		else
		{
			if( KFDoorActor(Wall).WeldIntegrity <= 0 && KFDoorMarker(KFDoorActor(Wall).MyMarker) != none && !KFDoorActor(Wall).IsCompletelyOpen() )
			{
				DisableNotifyHitWall(0.25f);
				WaitForDoor( KFDoorActor(Wall) );
				`AILog( "NotifyHitWall() while in MoveToGoal, Wall: "$Wall$" Using door and waiting for it to open", 'Doors' );
				KFDoorActor(Wall).UseDoor(Pawn);
				return true;
			}
			// NOTE: Unless returning true, if the Wall is a closed door, SuggestMovePreparation event will be called on the associated KFDoorMarker
			`AILog( GetFuncName()$"() Wall: "$Wall$" HitNormal: "$HitNormal$" ran into a door!", 'Doors' );
			if( !KFDoorActor(Wall).IsCompletelyOpen() && KFDoorActor(Wall).WeldIntegrity > 0 && (Pawn.Anchor == KFDoorActor(Wall).MyMarker || (DoorEnemy != none && (DoorEnemy == KFDoorActor(Wall) || PendingDoor == KFDoorActor(Wall)))) )
			{
				`AILog( GetFuncName()$"() calling NotifyAttackDoor for "$Wall, 'Doors' );
				NotifyAttackDoor( KFDoorActor(Wall) );
				return true;
				//`AILog( GetFuncName()$"() has door enemy "$DoorEnemy, 'Doors' );
			}
		}
		`AILog( GetFuncName()$" Wall: "$Wall$" HitNormal: "$HitNormal, 'Command_Crawler_MoveToGoal' );
		if( !Wall.bCanStepUpon )
		{
			`warn( GetFuncName()$"() Wall "$Wall$" bCanStepUpOn is FALSE" );
			return false;
		}

		if( Pawn.Physics == PHYS_Falling )
		{
			`AILog( GetFuncName()$" Wall: "$Wall$" setting physics to PHYS_Spider", 'Crawler' );
			Pawn.SetPhysics( PHYS_Spider );
			Pawn.SetBase( Wall, HitNormal );
			DisableNotifyHitWall(1.f);
			return true;
		}
		return false;
	}

HandleNewFloor:
	`AILog( self$" HandleNewFloor label at "$Pawn.Location$" - trying to move ahead (base: "$Pawn.Base$")", 'Command_Crawler_MoveToGoal' );
	MoveTo( Pawn.Location + vector(Pawn.Rotation) * 512.f );
	`AILog( self$" HandleNewFloor done extra move, location is now "$Pawn.Location$" base is now "$Pawn.Base, 'Command_Crawler_MoveToGoal' );
	if( !HasReachedMoveGoal() )
	{
		bReevaluatePath=true;
		NotifyNeedRepath();
	}
}

DefaultProperties
{
}