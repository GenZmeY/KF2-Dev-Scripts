//=============================================================================
// NavigationPath
//=============================================================================
// deprecated stub class on 6/29/2015 (script only)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class NavigationPath extends Object;

struct BaseTransform
{
	var const private{private} Actor Base;
	var const private{private} Vector InitialLocation;
	var const private{private} Rotator InitialRotation;
	// used in lazy update
	var const private{private} Vector UpdatedForLocation;
	var const private{private} Rotator UpdatedForRotation;
	// to take from initial pos into base pos
	var const private{private} Matrix InitialReversedTransform;
	// whole transform from initial pos (as in array) into world pos
	var const private{private} Matrix IBS2WSTransform;
	// reverse
	var const private{private} Matrix WS2IBSTransform;
};

struct PathPoint
{
	var Vector				Location;
	var byte				Flags;
};

// -- not to be changed from script! -- //
var init const array<PathPoint> PathPoints;

struct PolyArray_Mirror
{
	var init array<int> Dummy;
};
var private const PolyArray_Mirror PolysUsed;

/** Base on which this path is generated. Valid if bDynamic == true. */
var const BaseTransform Base;
/** Destination expressed in initial navmesh position. */
var const vector LocalDestination;

var private{private} const bool bDynamic;
/** variable auto-incremented every new path is stored in this path object */
var public{private} const int Version;

/**
 * Returns indexed element's position offset and rotated if necessary
 */
final function vector GetElementPos(int index);

final function SetRoute(array<PathPoint> Route);

/** function used to translate given location to path's generation base's space */
final function vector WorldToLocal(vector InLocation);

// ----------------------------------------------------------------------- //
// debug stuff
// ----------------------------------------------------------------------- //
final function DrawPath(Canvas Canvas, optional byte R=0, optional byte G=255, optional byte B=128, optional bool bPersistent);
