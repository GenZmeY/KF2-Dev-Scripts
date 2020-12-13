//=============================================================================
// Path_AroundDestructibles
//=============================================================================
// NPCs using this will 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class Path_AroundDestructibles extends PathConstraint
	native(Waypoint);

/** NPC collision radius that I should consider to be "large" size */
var float	LargeNPCCollisionRadius;
/** Path connections which I've blocked will be rendered as red lines */
var bool	bDebug_DrawMyBlockedPathConnections;
/** When true, AddedCost will be applied and affected ReachSpecs won't be fully blocked */	
var bool	bAddCostInsteadOfBlocking;
/** If bAddCostInsteadOfBlocking is true, this cost will be added to affected ReachSpecs */
var int		AddedCost;
/** If false, constraint won't throw out any nodes if the pawn is large sized */
var bool	bAffectLargeNPCs;
/** If false, constraint won't throw out any nodes if the pawn is small sized */
var bool	bAffectStandardNPCs;


struct native DestructiblesInfo
{
	var KFDestructibleActor KFDA;			// Destructible actor blocking a ReachSpec
	var bool bBumpDamageFromStandardZeds;	// Whether or not normal-sized Zeds will damage it on Bump()
	var bool bBumpDamageFromLargeZeds;		// Whether or not large-sized Zeds will damage it on Bump()
};
var transient array<DestructiblesInfo> Destructibles;

cpptext
{
	virtual UBOOL EvaluatePath( UReachSpec* Spec, APawn* Pawn, INT& out_PathCost, INT& out_HeuristicCost );
}

static function bool AvoidDestructibles( Pawn P, optional bool inAffectLargeNPCs=true, optional bool inAffectStandardNPCs=true,
	optional bool inAddCostInsteadOfBlocking=false, optional int inAddedCost=0 )
{
	local Path_AroundDestructibles Con;
	local KFDestructibleActor KFDA;

	if( P != None )
	{
		Con = Path_AroundDestructibles( P.CreatePathConstraint(default.class) );
		if( Con != None )
		{

			Con.bAffectLargeNPCs		  = inAffectLargeNPCs;
			Con.bAffectStandardNPCs		  = inAffectStandardNPCs;
			Con.bAddCostInsteadOfBlocking = inAddCostInsteadOfBlocking;
			Con.AddedCost				  = inAddedCost;

			foreach P.DynamicActors( class'KFDestructibleActor', KFDA )
			{
				Con.Destructibles.Insert( 0, 1 );
				Con.Destructibles[0].KFDA						 = KFDA;
				Con.Destructibles[0].bBumpDamageFromStandardZeds = KFDA.InstaKillFromStandardNPCBumpDamage();
				Con.Destructibles[0].bBumpDamageFromLargeZeds	 = KFDA.InstaKillFromLargeNPCBumpDamage();
			}
			P.AddPathConstraint( Con );
			return true;
		}
	}

	return false;
}

function Recycle()
{
	Super.Recycle();
	Destructibles.Length = 0;
}

defaultproperties
{
	CacheIdx=6
	LargeNPCCollisionRadius=55
	bAffectLargeNPCs=true
	bAffectStandardNPCs=true
	bDebug_DrawMyBlockedPathConnections=false
}
