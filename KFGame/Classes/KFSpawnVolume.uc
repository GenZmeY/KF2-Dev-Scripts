//=============================================================================
// KFSpawnVolume
//=============================================================================
// Volume which can spawn pawns inside of it and show transient spawn marker
// actors in the editor.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSpawnVolume extends Volume
    dependson(KFScout)
	hidecategories(Volume,Collision,Attachment,Physics,Mobile)
	native
	placeable
	config(Game);

`include(KFGame\KFGameAnalytics.uci);

/*********************************************************************************************
 Configuration
 ********************************************************************************************* */

struct native SpawnMarkerInfo
{
	/** Maximum collision radius supported by the spawn location within this volume */
	var float	Radius;
	/** Maximum collision height supported by the spawn location within this volume */
	var float	Height;
	/** Stored location of this spawn marker, used in-game since the spawn marker actors only exist in the editor */
	var vector			Location;
	/** If true, will forcibly disable spawning for this spawn marker. It will still be visible, but will use a different icon */
	var() editconst bool				bSpawnDisabled;
	/** Last time this spawn marker was used */
	var transient float LastUsedTime;
	/** This changes the color of the spawn location cylinder matching the index you're currently editing */
	var color				SpawnMarkerColor;

	structdefaultproperties
	{
		LastUsedTime=0.f
		SpawnMarkerColor=(R=50,G=205,B=50,A=255)
	}
};
/** Spawn marker info created during the AI pathbuilding process and used in-game when determining AI spawn locations within this volume. */
var() editconst array< SpawnMarkerInfo > SpawnMarkerInfoList;

/** maximum number of spawn markers that should be generated for this volume */
var() int MaxSpawnMarkers<ClampMin=1>;

struct native DoorListInfo
{
	/** Door actor to link to this volume. If all these doors are shut or welded this spawn volume is invalid */
	var() KFDoorActor	DoorActor;
	/** If true, this door will only invalidate spawning if it is welded as opposed to just shut*/
	var() bool			bOnlyWhenWelded;

	structdefaultproperties
	{
		bOnlyWhenWelded=true
	}
};
/** Spawn marker info created during the AI pathbuilding process and used in-game when determining AI spawn locations within this volume. */
var() array< DoorListInfo > DoorList;

/** Rotation to use when spawning pawns from this volume */
var() rotator 				SpawnRotation;

/** Used to include or exclude spawn volumes from gameplay code */
var transient bool bCanUseForSpawning;

/*********************************************************************************************
 Rendering in Game ("show SpawnVolumes" and Editor (when volume is selected)
 ********************************************************************************************* */
var Color	DefaultSpawnMarkerColor;

/** Use this if you want to override the default color for the interior bounding box surrounding the volume's spawn location cylinders */
var Color	SpawnInteriorBoxColor;
/** Sets the bNoCollisionFailForSpawn parameter when attempting to spawn a pawn. */
var bool	bNoCollisionFailForSpawn;

/** Whether this volume should more aggressively check its visibility against where the viewer is moving to */
var() bool	bUsePredictiveVisibilityChecks;

/** Used in determining visibility of volume to players in-game */
var BoxSphereBounds	VisibilityBounds;

/** What percentage of the spawn volume's size will the inner spawn bounds be? */
var() vector SpawnBoundsScale;

/** Will draw lines to represent visibility checks */
var bool bDebugVisibilityChecks;

/** Will log out/display info on Rating Checks for this spawn volume */
var config bool bDebugRatingChecks;

/** Will spit out minimal debug rating checks */
var bool bMinimalDebugRatingChecks;

/** Will log out/display spawning info for this spawn volume */
var bool bDebugSpawning;

/*********************************************************************************************
 Spawn Rating
 ********************************************************************************************* */
// Moved from KFAISpawnManager due to dependson
enum ESquadType
{
	EST_Boss,
	EST_Large,
	EST_Medium,
	EST_Small,
	EST_Crawler
};
/** If set, players cannot spawn here, only AI (Versus) */
var() bool bNoPlayers;
/** Largest type of squad that this volume is capable of spawning (checked vs SquadType in KFAISpawnSquad) */
var() ESquadType LargestSquadType;
/** Scales up (or reduces) base desireability to weight certain volumes differently if needed  */
var() float	DesirabilityMod<ClampMin=0.0 | ClampMax=10.0>;
/** If true, no height-based rating penalty will be applied to this volume. This also overrides MaxHeightDifference. */
var() bool bNoZAxisDistPenalty;
/** If height difference between volume and a player exceeds this value (UU), spawn rating will drop. */
var() float MaxHeightDiffToPlayers;
/** Volume will NOT be considered for spawning if, at wave-spawn time, any player is less than this many units away (from volume) */
var() float MinDistanceToPlayer;
/** Volume rating is partially scaled by its distance from players. Any player beyond this distance (UU) will receive no distance bonus at all, resulting in a lower volume rating. */
var() float MaxDistanceToPlayer;
/** If set, this volume never performs visibility checks */
var() bool bOutOfSight;

/** Result of last time this volume was rated & sorted */
var transient float  CurrentRating;

/** Cached visibility for performance */
var const transient bool 	bCachedVisibility;
var const transient float 	CachedVisibilityTime;

/** If LargestSquadType == EST_Boss, no other squads can spawn here */
var deprecated bool bExclusiveBossVolumes;

/*********************************************************************************************
 Time tracking
 ********************************************************************************************* */
/** How long this spawn volume is derated (gets a lower desireability) after it is spawned in */
var() float				SpawnDerateTime;
/** How long this spawn volume is derated (gets a lower desireability) after it is teleported in */
var   float				TeleportDerateTime;
/** Last time something spawned in this volume */
var protected transient float	LastSpawnTime;
/** Next time it is 100% desireable to spawn in this volume */
var protected transient float	NextSpawnTime;
/** Time after a human pawn untouches it that it can be spawned in again */
var() float				UnTouchCoolDownTime;
/** When was the last time a player touched it.  */
var protected transient	float	LastUnTouchTime;

/** If true, will be used to spawn forcing to use the override pawn list -> MapReplacePawnClass */
var() bool bForceUseMapReplacePawn;

/** If true, this volume will be disabled for Bounty Hunt Spawn */
var() bool bDisableForBountyHuntSpawn;

/*********************************************************************************************
Debug
 ********************************************************************************************* */

/** Debug component that handles rendering spawn locations in-game and in-editor */
var KFSpawnRenderingComponent	DebugComponent;

/** Use for debugging to exclude this volume from being used */
var(Debug) bool bDisabled;

/** The number of times the volume has been chosen to spawn enemies. Used only for stats. */
var int VolumeChosenCount;

cpptext
{
	/** Initializes the spawn marker colors and updates the spawn volume's visibility info */
	virtual void PostLoad();
	/** Init marker last used time after spawning */
	virtual void PostBeginPlay();

	void CalculateSpawnLocations();
	/** Resets the visibility related parameters for this volume */
	void ResetVisibilityInfo();
	/** Begins to calculate the volume's interior visibilty box and bounds, which are used in-game when determining if a player can see this volume */
	void UpdateVisibilityInfo();
	/** Calculates the volume's interior bounding box, used when checking the volume's visibility to players in-game */
	FBox GetInteriorBoundingBox();
	/** Initializes and, if necessary, creates the volume's KFSpawnRenderingComponent in-game or in-editor */
	void InitDebugComponent( UBOOL bUnHide );
	/** Cache visibility for performance */
	UBOOL CacheVisibility(UBOOL bIsVisible);

#if WITH_EDITOR
	/** Assuming parameter "S" is the Scout, this destroys and re-creates the spawn markers within this volume in the editor. */
	virtual INT SetupSpawnMarkers( AScout* Scout );
	/** Used when generating spawn locations within the spawn volume - attempts to fit scout into positions */
	UBOOL PlaceScout( AScout* Scout, FVector TestLocation );
	/** Used to update the locations of this volume's spawn markers immediately after the volume is moved. This helps avoid requiring manual spawn marker building. */
	virtual void PostEditMove(UBOOL bFinished);
	/** Used to update the volume's spawn marker locations if related properties are changed (such as StepSizeOverride) */
	virtual void PostEditChangeProperty( FPropertyChangedEvent& PropertyChangedEvent );
	/**Updates the volume's spawn marker locations and hides (when selected) or unhides (when unselected) the volume's debug components */
	virtual void EditorSelectionChange( UBOOL bSelected );
	/** Updates the volume's spawn markers after using the geometry tool on this brush. */
	virtual void PostEditBrush();
	/** Updates the volume's spawn markers after undoing a transaction in the editor */
	virtual void PostEditUndo();
	/** Empties the spawn marker info array, usually called prior to regenerating spawn locations within a volume */
	void CleanUpMarkers();
	/** Begins generating spawn marker locations within a volume by calling the scout's "AddMyMarker" function */
	void RebuildSpawnMarkers();
	/** Used to add map check warning when this volume has no valid spawn marker locations */
	virtual void CheckForErrors();
	/** Makes sure that all markers can be pathed from */
	void ValidatePathingFromMarkers(AKFScout *KFScout);
#endif // WITH_EDITOR
}

/*********************************************************************************************
 Native SpawnVolume rating functions
 ********************************************************************************************* */
/** Attempts to spawn the pawn classes in the SpawnList array. bAllOrNothing is to be determined */
native final function int SpawnWave( out array< class<KFPawn_Monster> > SpawnList, bool bAllOrNothing, optional bool bSimulatedAIPlayers=false );
/** Attempts to find a place to teleport the pawn class within this spawn volume */
native final function vector FindTeleportLocation( class<KFPawn_Monster> TeleportMonsterClass, optional int ForcedMarkerIdx=0 );
/** Attempts to find an open marker to spawn the pawn class within this spawn volume */
native final function vector FindSpawnLocation( class<KFPawn> SpawnPawnClass );

/** Get distance based score from one human player */
native function float RateDistance(Controller C);
/** Perform line of sight traces against all human players */
native function bool IsVisible(optional bool bAllowVelocityPrediction);
/** Perform line of sight traces for visibility */
native function bool IsVisibleFrom(vector ViewLoc);
/** Checks touching actors for living pawns */
native function bool IsTouchingAlivePawn();

/** Sets the volume's LastUnTouchTime if Other is a player */
event UnTouch(Actor Other)
{
	local Pawn P;

	Super.UnTouch(Other);

	if( Other != none && !Other.bDeleteMe )
	{
		P = Pawn(Other);
		if ( P != none && P.IsHumanControlled() )
		{
			LastUnTouchTime = WorldInfo.TimeSeconds;
		}
	}
}

/**	Handling Toggle event from Kismet. */
simulated function OnToggle( SeqAct_Toggle Action )
{
	// Turn ON
	if( Action.InputLinks[0].bHasImpulse )
	{
		`log("*** turning volume on:" @ self, bDebugRatingChecks);
		bCanUseForSpawning = true;
	}
	// Turn OFF
	else if (Action.InputLinks[1].bHasImpulse)
	{
		`log("*** turning volume off:" @ self, bDebugRatingChecks);
		bCanUseForSpawning = false;
	}
	// Toggle
	else if (Action.InputLinks[2].bHasImpulse)
	{
		bCanUseForSpawning = !bCanUseForSpawning;
		`log("*** toggling volume:" @ self @ bCanUseForSpawning, bDebugRatingChecks);
	}
}

/** Script implementation of RateVolume so mod authors can change things. Native implementation is commented out just
 *  in case we need it, or want to do something like handle KF2 spawning in native but calling this event to allow a
 *  complete override in script.
 * 
 * @param OtherController 		Optional Controller for additional tests
 *
 *  Returning -1 means this volume is not to be considered at all, otherwise the volume's overall rating is returned */
function bool IsValidForSpawn( ESquadType DesiredSquadType, Controller OtherController )
{
	local String DebugText;
	local int i;

	// This volume is disabled
	if( !bCanUseForSpawning )
	{
		return false;
	}
	if( SpawnMarkerInfoList.Length == 0 )
	{
		return false;
	}
	// This volume can't be used by players
	if( bNoPlayers && OtherController != none && OtherController.bIsPlayer )
	{
		return false;
	}
	// Spawn volume can not be reactived until UnTouchCoolDownTime
	if ( LastUnTouchTime > 0.f && `TimeSince(LastUnTouchTime) < UnTouchCoolDownTime )
	{
		`log( "["$self$"] rejected from spawning because LastUnTouchTime difference ("$`TimeSince(LastUnTouchTime)$") < UnTouchCoolDownTime ("$UnTouchCoolDownTime$"), returning a -1 rating", bDebugRatingChecks );
        return false;
	}
	// The desired squad type is not compatible with this volume
	if( DesiredSquadType < LargestSquadType )
	{
		`log( "["$self$"] rejected from spawning because DesiredSquadType ("$DesiredSquadType$") < LargestSquadType ("$LargestSquadType$"), returning a -1 rating", bDebugRatingChecks );
		return false;
	}
	// If a pawn is in the volume automatic fail
	if( IsTouchingAlivePawn() )
	{
        if(bDebugRatingChecks)
        {
            if( !bMinimalDebugRatingChecks )
            {
                DebugText = self@"FinalRating: -1 was touching a live pawn";
                GetALocalPlayerController().AddDebugText(DebugText, self, 20);
            }
    	}

        return false;
	}

	// Fail if any linked doors are shut, or if the setting is set, welded
    for( i = 0; i < DoorList.Length; i++ )
	{
		if( DoorList[i].DoorActor != none && !DoorList[i].DoorActor.bIsDoorOpen
            && !DoorList[i].DoorActor.bIsDestroyed && (!DoorList[i].bOnlyWhenWelded ||
            DoorList[i].DoorActor.WeldIntegrity > 0) )
        {
            return false;
        }
	}

	if ( IsVisible(DesiredSquadType == EST_Boss) )
	{
		return false;
	}

	return true;
}

/** Script implementation of RateVolume so mod authors can change things. Native implementation is commented out just
 *  in case we need it, or want to do something like handle KF2 spawning in native but calling this event to allow a
 *  complete override in script.
 *
 * @param RateController  		Controller that was selected to rate distance against used by MinDistSquared
 * @param bTeleporting			Used for AI teleport rather than initial spawning
 * @param TeleportMinDistSq		If set, perform circumstational distance checking using RateController
 *
 *  Returning -1 means this volume is not to be considered at all, otherwise the volume's overall rating is returned 
 */
event float RateVolume( Controller RateController, bool bTeleporting, float TeleportMinDistSq)
{
	local float UsageRating, LocationRating, FinalRating;
	local float DistSquared;
	local String DebugText;
	local vector TextOffset;

	/** Skip rating if volume isn't enabled */
	if( !bCanUseForSpawning )
	{
		return -1.f;
	}

	// Calculate UsageRating
	UsageRating = 1.f;
	if( NextSpawnTime > 0.f && NextSpawnTime > WorldInfo.TimeSeconds )
	{
		if( !bTeleporting )
		{
            UsageRating = FMin( (SpawnDerateTime - (NextSpawnTime - WorldInfo.TimeSeconds)) / SpawnDerateTime, 1.f );
    		if( bDebugRatingChecks && (!bMinimalDebugRatingChecks || UsageRating < 1.0) )
    		{
                `log( "["$self$"] recently was spawned in "$(SpawnDerateTime - (NextSpawnTime - WorldInfo.TimeSeconds))$" seconds ago, setting UsageRating to "$UsageRating, bDebugRatingChecks );
    		}
		}
		else
		{
            if( (NextSpawnTime - WorldInfo.TimeSeconds) > TeleportDerateTime )
            {
                UsageRating = 1.f;
        		if( bDebugRatingChecks && !bMinimalDebugRatingChecks )
        		{
                    `log( "["$self$"] was not teleported in recently, setting UsageRating to "$UsageRating, bDebugRatingChecks );
        		}
            }
            else
            {
                UsageRating = FMin( (TeleportDerateTime - (NextSpawnTime - WorldInfo.TimeSeconds)) / TeleportDerateTime, 1.f );
        		if( bDebugRatingChecks && (!bMinimalDebugRatingChecks || UsageRating < 1.0) )
        		{
                    `log( "["$self$"] recently was teleported in "$(TeleportDerateTime - (NextSpawnTime - WorldInfo.TimeSeconds))$" seconds ago, setting UsageRating to "$UsageRating, bDebugRatingChecks );
        		}
            }
		}
	}

	// Can't teleport here if it's not closer than MinDistSquared. Typically we reject in IsValidForSpawn(),
	// but we'll make an exception here because we have all the right inputs
    if( bTeleporting && TeleportMinDistSq > 0 && RateController != none && RateController.Pawn != none )
	{
        DistSquared = VSizeSq( Location - RateController.Pawn.Location );
        if( DistSquared > TeleportMinDistSq)
        {
            `log( "["$self$"] rejected from spawning because DistSquared ("$DistSquared$") > MinDistSquared ("$TeleportMinDistSq$"), returning a -1 rating", bDebugRatingChecks );
            return -1.f;
        }
	}

	// Calculate rating based on distance and visibility to players
	LocationRating = RateDistance(RateController);
	if ( LocationRating < 0.f )
	{
        if( !bMinimalDebugRatingChecks )
        {
            `log( self$" returning rating -1 --- Desirability:"$DesirabilityMod$", LocationRating:"$LocationRating$", UsageRating:"$UsageRating, bDebugRatingChecks );
    	}

        `RecordSpawnVolumeRating( self, -1.f, UsageRating, LocationRating );

        if( !bMinimalDebugRatingChecks )
        {
            DebugText = self@"FinalRating: -1, DesirabilityMod:"$DesirabilityMod$", LocationRating:"$LocationRating$", UsageRating:"$UsageRating;
            GetALocalPlayerController().AddDebugText(DebugText, self, 20);
        }

		return -1.f;
	}

    // FinalRating is 30% DesirabilityMod, 30% Distance from players, 30% when the spawn was last used, 10% random
    FinalRating = (DesirabilityMod * 0.3) + (LocationRating * 0.3) + (UsageRating * 0.3) + (FRand() * (DesirabilityMod * 0.1) );

    if( !bMinimalDebugRatingChecks || FinalRating > 0 )
    {
        `log( self$" returning rating "$FinalRating$"--- Desirability:"$DesirabilityMod$", LocationRating:"$LocationRating$", UsageRating:"$UsageRating, bDebugRatingChecks );
	}

	`RecordSpawnVolumeRating( self, FinalRating, UsageRating, LocationRating );

    if( bDebugRatingChecks )
    {
        if( !bMinimalDebugRatingChecks || (LocationRating > 0.25 && UsageRating > 0) )
        {
            DebugText = self$" FinalRating: "$FinalRating$", DesirabilityMod:"$DesirabilityMod$", LocationRating:"$LocationRating$", UsageRating:"$UsageRating;

            TextOffset = vect(0,0,1) * FRand() * 200;
            GetALocalPlayerController().AddDebugText(DebugText, self, 30,TextOffset);
        }
	}

	return FinalRating;
}

/** Sets the volume's LastSpawnTime. Currently only for debugging so other classes can set this */
function SetLastSpawnTime(float NewSpawnTime)
{
    LastSpawnTime = NewSpawnTime;
    NextSpawnTime = WorldInfo.TimeSeconds + SpawnDerateTime;
}

function HandleTeleportedTo()
{
    LastSpawnTime = WorldInfo.TimeSeconds;
    NextSpawnTime = WorldInfo.TimeSeconds + TeleportDerateTime;
}

DefaultProperties
{
	Begin Object Class=KFSpawnRenderingComponent Name=SpawnRenderer
	End Object
	Components.Add(SpawnRenderer)
	DebugComponent=SpawnRenderer

	// volume
	bCanUseForSpawning=true
	bColored=true
	BrushColor=(R=135,G=206,B=250)
	bNoDelete=false
	bPawnsOnly=true
	bForceAllowKismetModification=true // necessary to allow OnToggle event processing

	// Editor
	DefaultSpawnMarkerColor=(R=50,G=205,B=50,A=255)
	SpawnInteriorBoxColor=(R=255,G=69,B=0,A=255)

	// Spawning
	bNoCollisionFailForSpawn=false
	UnTouchCoolDownTime=10.f
	SpawnDerateTime=30.f
	TeleportDerateTime=10.f
	LastSpawnTime=-100.f
	MaxSpawnMarkers=11
	SpawnBoundsScale=(X=0.75,Y=0.75,Z=0.75)

	// Rating
	MinDistanceToPlayer=1200.f		// UU
	MaxDistanceToPlayer=4000.f		// UU
	DesirabilityMod=1.f
	MaxHeightDiffToPlayers=500.f // 5 meters
	LargestSquadType=EST_Large

	bForceUseMapReplacePawn=false
	bDisableForBountyHuntSpawn=false

	// Debugging
	bDebugVisibilityChecks=false
	bMinimalDebugRatingChecks=true
}
