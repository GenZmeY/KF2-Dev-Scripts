//=============================================================================
// KFDebugLines
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
//
// Not optimal, but very useful debug line/sphere/text drawing for some
// situations. Allows each debug line/shape to have an owner who can handle
// turning them on/off without affecting other debug lines/shapes (unlike
// flushpersistentdebuglines).
//
// Allows lines to be rendered from/to specific owner/locations and handles
// updating those locations if they change. For example, in a pawn's controller
// class:
// KFDebugLines.AddDebugLineFromOwner(name,MoveTarget.Location,255,255,255,true);
//
// Durations can be set for each shape/line.
//
// This will indefinitely update and render a line from the controller's pawn
// to the current move goal. It's up to the controller to turn it off.
//=============================================================================

class KFDebugLines extends Actor
	native;

struct native DebugDrawInfo
{
	var byte R;
	var byte G;
	var byte B;
	var bool bPersistent;
	var int PersistentFrameCounter;
	var float Duration;
	var name OwnerName;
	var int DDID;
	var bool bHidden;
};

struct native DebugLine extends DebugDrawInfo
{
	var vector Start;
	var vector End;
	var bool bDrawFromOwner;
	var bool bDrawToOwner;
};

struct native PawnDebugLine extends DebugLine
{
	var bool bDrawViewRotation;
	var bool bDrawDesiredRotation;
};

struct native DebugSphere extends DebugDrawInfo
{
	var vector Center;
	var float Radius;
	var int Segments;
};

struct native DebugText3D extends DebugDrawInfo
{
	var vector WorldPos;
	var Vector ScreenPos;
	var string Text;
	var bool bUseDropShadow;
	var float WorldTime;
	var float ZVelocity;
	var float ZOffset;
	var Actor Base;
};

var array<DebugLine> ActiveLines;
var int MaxLines;
var array<DebugSphere> ActiveSpheres;
var int MaxSpheres;
var array<DebugText3D> ActiveText3D;
var int MaxText3D;

cpptext
{
	virtual void TickSpecial( FLOAT DeltaSeconds );
	FVector GetOwnerLocationForLineIndex( INT LineIdx );
	FVector GetOwnerLocationForName( FName InName );
	FVector GetOwnerDesiredRotationForLineIndex( INT LineIdx );
	void CleanUpDebugLines();
}

/** Hook to allow actors to render HUD overlays for themselves. Handles rendering KFDebugLines, Spheres & Text */
simulated native function NativePostRenderFor( PlayerController PC, Canvas Canvas, vector CameraPosition, vector CameraDir );
/** Work in progress */
simulated native function AddPawnDebugLine( bool bDrawViewRotation, bool bDrawDesiredRotation, byte R, byte G, byte B, optional bool bPersistent, optional float InDuration, optional name InOwnerName, optional int DDID );
/** Add a debug line from start to end, with an optional lifespan, ID and actor Owner */
simulated native function AddDebugLine( vector Start, vector End, byte R, byte G, byte B, optional bool bPersistent, optional float InDuration, optional name InOwnerName, optional int DDID, optional bool bDrawFromOwner=false, optional bool bDrawToOwner=false, optional bool bDrawDesiredRotation );
/** Add a debug line from the specified actor Owner's location to the End location, with optional duration */
simulated native function AddDebugLineFromOwner( name InOwner, vector End, byte R, byte G, byte B, optional bool bPersistent, optional float InDuration, optional int DDID );
/** Add a debug line from the Start location to the specified actor Owner's location, with optional duration */
simulated native function AddDebugLineToOwner( vector Start, name InOwner, byte R, byte G, byte B, optional bool bPersistent, optional float InDuration, optional int DDID );
/** Add a debug sphere with optional duration and owner name */
simulated native function AddDebugSphere( vector Center, float Radius, int Segments, byte R, byte G, byte B, optional bool bPersistent, optional float InDuration, optional name InOwnerName, optional int DDID );
/** Add debug text, rendered at WorldPos, with optional owner and duration */
simulated native function AddDebugText3D( vector WorldPos, string Text, bool bUseDropShadow, byte R, byte G, byte B, optional bool bPersistent, optional float InDuration, optional Actor InBase, optional float InZVelocity = 0.0f, optional name InOwnerName, optional int DDID );
/** Remove all debug lines that are owned by InOwnerName (specify an ID to only remove a subset of the owner's lines) */
simulated native function RemoveOwnedDebugLines( name InOwnerName, optional int DDID );
/** Remove all debug spheres that are owned by InOwnerName (specify an ID to only remove a subset of the owner's debug spheres) */
simulated native function RemoveOwnedDebugSpheres( name InOwnerName, optional int DDID );
/** Remove all debug text that is owned by InOwnerName (specify an ID to only remove a subset of the owner's debug text) */
simulated native function RemoveOwnedDebugText3D( name InOwnerName, optional int DDID );
/** Clears all existing debug lines, spheres, and text */
simulated native function ClearAll();

/*********************************************************************************************
* Initialization/Destruction
********************************************************************************************* */

event PostBeginPlay()
{
	super.PostBeginPlay();
	AddToPostRenderList();
}

function AddToPostRenderList()
{
	local PlayerController PC;
	local HUD iHUD;

	// Add to the HUD's PostRendered List
	ForEach LocalPlayerControllers( class'PlayerController', PC )
	{
		iHUD = ( PC.myHUD );

		if( iHUD != None )
		{
			iHUD.AddPostRenderedActor( self );
			iHUD.bShowOverlays = true;
		}
	}
}

function RemoveFromPostRenderList()
{
	local PlayerController PC;
	local HUD iHUD;

	// Remove from the HUD's PostRendered List
	ForEach LocalPlayerControllers( class'PlayerController', PC )
	{
		iHUD = PC.myHUD;

		if( iHUD != None )
		{
			iHUD.RemovePostRenderedActor( self );
			// Assuming there are unrelated postrendered actors remaining, then bShowOverlays shouldn't change
			if( iHUD.PostRenderedActors.Length == 0 )
			{
				iHUD.bShowOverlays = iHUD.Default.bShowOverlays;
			}
		}
	}
}

/** Remove from the HUD's PostRenderList when not in use */
event Destroyed()
{
	RemoveFromPostRenderList();
}

/*********************************************************************************************
* Static functions
********************************************************************************************* */

/**
 * NewDebugLineFromOwner
 * Draws a debug line from the actor Owner's location, to the specified end location.
 * 
 * @param	name InOwner				Name of the actor who owns this debug line (line will be drawn from this actor)
 * @param	vector End					End of the line location
 * @param	optional color inColor		Line color
 * @param	optional bool bPersistent	Whether or not the line should automatically go away after a duration
 * @param	optional float InDuration	Duration (lifespan) of the debug line
 * @param	optional int DDID			Optional ID int which can be used by owner to adjust or remove this debug line
  */
static function NewDebugLineFromOwner( name InOwner, vector End, optional color inColor, optional bool bPersistent, optional float InDuration, optional int DDID )
{
	local KFDebugLines KFDL;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.AddDebugLineFromOwner( InOwner, End, inColor.R, inColor.G, inColor.B, bPersistent, InDuration, DDID );
	}
}

/**
 * NewDebugLineToOwner
 * Draws a debug line from the specified Start location to the line's owner location.
 * 
 * @param	vector Start				Start of the line location
 * @param	name InOwner				Name of the actor who owns this debug line (line will be drawn to this actor)
 * @param	optional color inColor		Line color
 * @param	optional bool bPersistent	Whether or not the line should automatically go away after a duration
 * @param	optional float InDuration	Duration (lifespan) of the debug line
 * @param	optional int DDID			Optional ID int which can be used by owner to adjust or remove this debug line
 */
static function NewDebugLineToOwner( vector Start, name InOwner, optional color inColor, optional bool bPersistent, optional float InDuration, optional int DDID )
{
	local KFDebugLines KFDL;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.AddDebugLineToOwner( Start, InOwner, inColor.R, inColor.G, inColor.B, bPersistent, InDuration, DDID );
	}
}

/**
 * NewDebugSphere
 * Creates a debug sphere with optional actor owner and optional time duration (lifespan)
 * 
 * @param	vector Center				Sphere center location		
 * @param	float Radius				Sphere radius
 * @param	int Segments				Number of segments that compose the sphere
 * @param	optional color inColor		Sphere color
 * @param	optional bool bPersistent	Whether or not the sphere should automatically go away after a duration
 * @param	optional float InDuration	Duration (lifespan) of the debug sphere
 * @param	optional name InOwnerName	Optional actor name for the owner of this sphere
 * @param	optional int DDID			Optional ID int which can be used by owner to adjust or remove this debug line 
 */
static function NewDebugSphere( vector Center, float Radius, int Segments, optional color inColor, optional bool bPersistent, optional float InDuration, optional name InOwnerName, optional int DDID )
{
	local KFDebugLines KFDL;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.AddDebugSphere( Center, Radius, Segments, inColor.R, inColor.G, inColor.B, bPersistent, InDuration, InOwnerName, DDID );
	}
}

/** Gets the active KFDebugLines, if enabled */
static function KFDebugLines GetDebugLines()
{
	local KFGameEngine KFGEngine;

	KFGEngine = KFGameEngine(Class'KFGameEngine'.static.GetEngine());
	if( KFGEngine != none )
	{
		return KFGEngine.GetDebugLines();
	}

	return None;
}

/** Clear all debug lines owned by actor with InName. Specify an ID to selectively clear out specific owned lines */
static function KFDebug_ClearLines( name InName, optional int ID )
{
	local KFDebugLines KFDL;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.RemoveOwnedDebugLines( InName, ID );
	}
}

/** Clear all debug spheres owned by actor with InName. Specify an ID to selectively clear out specific owned spheres */
static function KFDebug_ClearSpheres( name InName, optional int ID )
{
	local KFDebugLines KFDL;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.RemoveOwnedDebugSpheres( InName, ID );
	}
}

/** Clear all debug text owned by actor with InName. Specify an ID to selectively clear out specific owned text */
static function KFDebug_ClearText( name InName, optional int ID )
{
	local KFDebugLines KFDL;

	KFDL = GetDebugLines();

	if( KFDL != none )
	{
		KFDL.RemoveOwnedDebugText3D( InName, ID );
	}
}

DefaultProperties
{
	MaxLines=1000
	MaxSpheres=1000
	MaxText3D=100
	bPostRenderIfNotVisible=true
	bKillDuringLevelTransition=true
}