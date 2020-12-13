//=============================================================================
// KFCostTimerNode
//=============================================================================
// Base KF NavigationPoint used to mark door locations
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFCostTimerNode extends KFPathnode
	native(Waypoint)
	placeable;

var() bool		bEnableCostTimer;
var() int		MinCost;
var() int		MaxCost;
var() float		TimerMin;
var() float		TimerMax;

cpptext
	{
		virtual void PostScriptDestroyed();
	}

function PostBeginPlay()
{
	super.PostBeginPlay();

	`log( self$" PostBeginPlay" );
	if( bEnableCostTimer )
	{
	//	StartCostTimer(); // TEMP commented out 11/30
	}
}

function CostTimer()
{
	ExtraCost = RandRange( MinCost, MaxCost );
	`log( self$" Extra cost now "$ExtraCost );
	StartCostTimer();
}

function StartCostTimer()
{
	SetTimer( RandRange( TimerMin, TimerMax ), false, nameof( CostTimer ) );
}


DefaultProperties
{
	MinCost=150
	MaxCost=550
	TimerMin=2.f
	TimerMax=15.f
	bStatic=false
	bNoDelete=false
}
