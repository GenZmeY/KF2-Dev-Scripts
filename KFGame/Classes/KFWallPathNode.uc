//=============================================================================
// KFWallPathNode
//=============================================================================
// Pathnode type that can be placed on walls (for PHYS_Spider)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
// Based on GearWallPathNode
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================

class KFWallPathNode extends KFPathnode
	placeable
	native(Waypoint);

cpptext
{
#if WITH_EDITOR
	virtual UReachSpec* ManualForcePathTo( ANavigationPoint *Nav, AScout *Scout, UClass* ReachSpecClass, UBOOL bJump = FALSE );
	virtual void PostEditChangeProperty( FPropertyChangedEvent& PropertyChangedEvent );
	virtual void PostEditMove(UBOOL bFinished);
	virtual UBOOL PreserveForcedPath( ANavigationPoint* DestNav )
	{ 
		//bManuallyForced = true;
		return TRUE; 
	}
	//virtual void AddSpecialReachSpecs();
	void addReachSpecs(AScout *Scout, UBOOL bOnlyChanged=0);
	virtual void AddForcedSpecs( AScout *Scout );
	virtual UBOOL CanConnectTo(ANavigationPoint* Dest, UBOOL bCheckDistance);
	virtual UBOOL ConnectWallToFloor( AKFPathnode* FloorNode );
	virtual UReachSpec* ForcePathTo(ANavigationPoint *Nav, AScout *Scout = NULL, UClass* ReachSpecClass = NULL );
#endif //WITH_EDITOR
	virtual UClass* GetReachSpecClass( ANavigationPoint* Nav, UClass* DefaultReachSpecClass );
	virtual void FindBase();
	virtual void ClearPaths(); 
	virtual void SetBase(AActor *NewBase, FVector NewFloor = FVector(0,0,1), INT bNotifyActor=1, USkeletalMeshComponent* SkelComp=NULL, FName AttachName=NAME_None );
	virtual UBOOL GetUpDir( FVector &V )
	{
		V = -(Rotation.Vector());
		return 1;
	}
}

var duplicatetransient const float					MaxJumpDist;
/** If true, Crawlers will attempt to jump from the floor to this node when attempting to move from the floor to a wall */
var() duplicatetransient bool						bMustJumpTo;
var	duplicatetransient bool							bAutoConnectDropDownNodes;
/** KFPathnodes on the default floor will not add a floor-to-wall connection to this wall node if the distance between the nodes exceeds this value. */
var() duplicatetransient float						MaxFloorToWallDistance;
/** Maximum allowed distance (Unreal units) to nodes on the ground - this is almost always going to be for KFWallPathNode to KFPathnode connections.
	Pawns can drop to floor if within distance. */
var() duplicatetransient float						Max2DDistToFloorNodes;
/** Maximum allowed distance (Unreal units) to nodes on other walls or ceiling if I'm not on a ceiling (excluding the real floor, which is handled by MaxDistToFloorNodes */
var() duplicatetransient float						MaxDistToNodesOnOtherFloors;
/** Maximum height distance (UU) to create a wall-to-floor dropdown reachspec from this node to nearby pathnodes on the floor */
var() duplicatetransient float						MaxDropFromWallDistance;
/** Auto-generated during pathbuilding. This is a reference to the KFPathNode, if any, that a Crawler can drop down to from this wall node. */
var() duplicatetransient editconst KFPathNode		DropDownNode;

native function bool IsUsableAnchorFor( Pawn P );

simulated event string GetDebugAbbrev()
{
	return "WPN";
}

/**
 * SpecialCost()
 * Event allowing cost of this path to be modified based on who's pathing and which
 * ReachSpec is in use.
 * 
 * @param	Seeker	The pawn who is pathfinding
 * @param	Path	ReachSpec connecting this navigation point to the end navigation point
 * @return	int		Special cost to apply
 */
event int SpecialCost( Pawn Seeker, ReachSpec Path )
{
	return super.SpecialCost(Seeker, Path);
}

/**
 * Accept()
 * Event that accepts or rejects an actor that has teleported to this node.
 * 
 * @param	Incoming
 * @param	Source
 * @return	function bool
 */
event bool Accept( actor Incoming, actor Source )
{
	return Super.Accept( Incoming, Source );
}

/**
 * DetourWeight()
 * Value of this path to take a quick detour (usually 0, used when on route to distant objective)
 * 
 * @param	Other		Detouring pawn
 * @param	PathWeight	
 * @return	float
 */
event float DetourWeight( Pawn Other, float PathWeight )
{
	return super.DetourWeight( Other, PathWeight );
}

/**
 * SuggestMovePreparation()
 * Optionally tell Pawn any special instructions to prepare for moving to this goal.
 * (Called by Pawn.PrepareForMove() if this node's bSpecialMove==true) 
 * 
 * @param	Other	Pathfinding NPC
 */
event bool SuggestMovePreparation( Pawn Other )
{
	// If special move was taken to get to this link
	return Other.SpecialMoveTo(Other.Anchor, self, Other.Controller.MoveTarget);
}

defaultproperties
{
	EditorIconColor=(R=50,G=50,B=255,A=255)
	bSpecialMove=true	// TODO: Look into auto-setting this, only for Wall to Floor and Floor to Wall ReachSpecs
	bBuildLongPaths=false
	bConnectToSameFloorOnly=false
	WallReachSpecClass=class'KFGame.WallReachSpec'
	bAutoConnectDropDownNodes=false
	Max2DDistToFloorNodes=96.f
	MaxJumpDist=512.f
	MaxDistToNodesOnOtherFloors=300.f
	bWallNode=true
	MaxDropFromWallDistance=350.f
	MaxFloorToWallDistance=100.f
	bAutoAdjustZToCeiling=false
}