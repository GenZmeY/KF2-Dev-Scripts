//=============================================================================
// KFPathnode
//=============================================================================
// Base KF NavigationPoint that provides some additional options
//=============================================================================
// Killing Floor 2
// Copyright (C) 2012-2013 Tripwire Interactive LLC
//=============================================================================

class KFPathnode extends PathNode
	native(Waypoint);

/** Used internally, set to true if this node is a jump destination for a KFJumpSpot node */
var() duplicatetransient editconst bool		bIsJumpDest;
var() duplicatetransient editconst bool		bIsDropDownDest;
var() duplicatetransient editconst vector	JumpVelocity;
/** How long the jump should take.  Altering this value changes the JumpVelocity. */
var() duplicatetransient float				JumpTime;
var() duplicatetransient bool				bDebugLogAnchorUsability;
var() duplicatetransient bool				bAutoConnectToOtherFloors;
var() duplicatetransient bool				bPauseWhenReached;
var() duplicatetransient float				PauseDuration;
var() const editconst bool					bHasDoorLOS;
/** If this node is on a wall and connected to a ceiling node, then auto adjust those node's height if too low */
var() bool									bAutoAdjustZToCeiling;
var class<ReachSpec>						WallReachSpecClass;
var bool									bAutoFlushPersistentDebugLines;
/** If checked, this pathnode will not be considered by the trader trail emitter */
var() bool 									bIgnoredByTraderTrail;

cpptext
{
#if WITH_EDITOR
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent );
	virtual void AddForcedSpecs( AScout *Scout ) {}
	virtual UReachSpec* ForcePathTo(ANavigationPoint *Nav, AScout *Scout = NULL, UClass* ReachSpecClass = NULL );
	virtual UBOOL ProscribePathTo(ANavigationPoint *Nav, AScout *Scout = NULL);
	virtual UBOOL ConnectWallToFloor( AKFPathnode* FloorNode ) { return FALSE; }
	virtual UBOOL ConnectFloorToWall( AKFPathnode* WallNode );
	virtual void AddFloorToWallSpec();
	virtual void AddSpecialReachSpecs();
	virtual UBOOL CanConnectTo(ANavigationPoint* Nav, UBOOL bCheckDistance);
	virtual void CheckForErrors();
	virtual void PostEditMove( UBOOL bFinished );
	virtual void AutoAdjustHeightToCeiling();
#endif //WITH_EDITOR
	/** Overridden to support wall node Max2DDistToFloorNodes and MaxDropFromWallDistance overrides */
	virtual UClass* GetReachSpecClass( ANavigationPoint* Nav, UClass* DefaultReachSpecClass );
	/** Clean up when destroyed */
	virtual void PostScriptDestroyed();
	/** Reset DropDownDest flag */
	virtual void ClearPaths();
	virtual UBOOL CalculateJumpVelocity( AScout *Scout );
}

native function vector ComputeTrajectoryByTime( vector StartPosition, vector EndPosition, float EndTime );

/** Returns this node's "up" direction, or 0 if using default floor. GetUpDir() isn't native and
	this allows script to call it.  As an example, "Up" for KFWallPathnodes is: -(Rotation.Vector()) */
native function vector GetUpVector();

native function bool IsUsableAnchorFor( Pawn P );

/** Returns the nearest valid navigation on the floor to the given actor */
static final function NavigationPoint GetNearestFloorNavToActor(Actor ChkActor, optional class<NavigationPoint> RequiredClass,optional array<NavigationPoint> ExcludeList,optional float MinDist)
{
	local NavigationPoint Nav, BestNav;
	local float			  Dist, BestDist;

	if( ChkActor != None )
	{
		// iterate through all points in the level
		foreach ChkActor.WorldInfo.AllNavigationPoints( class'NavigationPoint', Nav )
		{
			if( Nav.bWallNode )
			{
				continue;
			}

			// if no filter class specified, and
			// if nav is available to the check actor, and
			// if the nav isn't part of the excluded list,
			if ( (RequiredClass == None || Nav.class == RequiredClass) && ExcludeList.Find(Nav) == INDEX_NONE )
			{
				// pick the closest
				Dist = VSize( Nav.Location-ChkActor.Location );
				if( Dist > MinDist )
				{
					if( BestNav == None || Dist < BestDist )
					{
						BestNav = Nav;
						BestDist = Dist;
					}
				}
			}
		}
	}
	return BestNav;
}

/** Returns the nearest valid navigation on the floor to the given actor within a certain radius */
static final function NavigationPoint GetNearestValidFloorNavWithinRadiusToPawn(Pawn ChkPawn, float MinDist, optional class<NavigationPoint> RequiredClass,optional array<NavigationPoint> ExcludeList)
{
	local NavigationPoint BestNav;
	local float			  Dist, BestDist;
	local array<NavigationPoint> ValidNavs;
	local Cylinder PawnCylinder;
	local int i;

	if( ChkPawn != None )
	{

        PawnCylinder.Radius = ChkPawn.GetCollisionRadius();
        PawnCylinder.Height = ChkPawn.GetCollisionHeight();

        GetAllNavInRadius( ChkPawn, ChkPawn.Location, MinDist, ValidNavs, true,, PawnCylinder );


        for( i = 0; i < ValidNavs.Length; i++ )
		{
			if( ValidNavs[i].bWallNode )
			{
				continue;
			}

            if( !ValidNavs[i].IsUsableAnchorFor( ChkPawn ) )
            {
                continue;
            }
			// if no filter class specified, and
			// if nav is available to the check actor, and
			// if the nav isn't part of the excluded list,
			if ( (RequiredClass == None || ValidNavs[i].class == RequiredClass) && ExcludeList.Find(ValidNavs[i]) == INDEX_NONE )
			{
				// pick the closest
				Dist = VSize( ValidNavs[i].Location-ChkPawn.Location );
				if( Dist > MinDist )
				{
					if( BestNav == None || Dist < BestDist )
					{
						BestNav = ValidNavs[i];
						BestDist = Dist;
					}
				}
			}
		}
	}
	return BestNav;
}


event NotifyReachedBy( Pawn P )
{
	if( P.Controller != none && KFAIController(P.Controller) != none )
	{
		`AILog_Ext( GetFuncName()$" by "$P, 'PathWarning', KFAIController(P.Controller) );
	}
}

simulated event string GetDebugAbbrev()
{
	return "KFPN";
}

simulated function DrawDebugInfo( HUD HUD )
{
	local KFDebugLines KFDL;
	local int i;

	KFDL = class'KFDebugLines'.static.GetDebugLines();

	if( KFDL != none )
	{
		for( i = 0; i < PathList.Length; i++ )
		{
			KFDL.AddDebugLine( Location, PathList[i].GetEnd().Location, 0, 100, 150, true,, name, i );
			KFDL.AddDebugText3D( (Location + PathList[i].GetEnd().Location) * 0.5f, string(PathList[i]), true, 50, 100, 150, true,,,, name, i );
		}
	}
}

DefaultProperties
{
	bBuildLongPaths=false
	bDebugLogAnchorUsability=false
	WallReachSpecClass=class'KFGame.FloorToWallReachSpec'
	bAutoConnectToOtherFloors=true
	bIgnoredByTraderTrail=false
	JumpTime=0.45f
}
