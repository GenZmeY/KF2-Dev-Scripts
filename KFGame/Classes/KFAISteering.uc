//=============================================================================
// KFAISteering
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAISteering extends Object
	native(AI)
	config(AI);

/** Owning KFAIController */
var transient KFAIController	AIController;
/** Pawn that's being steered */
var transient KFPawn			AIPawn;

/** Steering flags used for adjusting AI acceleration */
enum ESteeringFlags
{
	/** Accept unreal calculated acceleration using UnPawn:moveToward & moveTo */
	STEERING_Default,
	/** Separation distance from target */
	STEERING_Separate,
};

/** Active steering flags ( 1 << ESteeringFlags ) */
var int	SteeringFlags;

/*********************************************************************************************
 Unreal Acceleration
 ********************************************************************************************* */

/** Percent of total acceleration that unreal accel may account for */
var const float	UnrealAccelMaxForce;
/** Acceleration force computed by unreal */
var Vector		UnrealAccel;

/*********************************************************************************************
 Separation steering
 ********************************************************************************************* */

/** Percent of total acceleration that separation may account for */
var const float				SeparateMaxForce;
/** Default amount of speration to keep from target */
var const float				DefaultSeparationDistance;
/** List of classes to exclude from separation */
var array< class<Actor> >	SeparationExcludeClasses;
/** List of classes to separate from */
var array< class<Actor> >	SeparationClasses;
/** Distance to keep from a class type */
var array<float>			SeparationDistance;

/*********************************************************************************************
 Miscellaneous functions
 ********************************************************************************************* */

/** Initialize AI controller and AI pawn for steering */
native function Initialize( Actor Owner );
/** Add flag to steering flags */
native function AddFlag( ESteeringFlags Flag );
/** Remove flag from steering flags */
native function ClearFlag( ESteeringFlags Flag ); 
/** Clear all flags (SteeringFlags=0) */
native function ClearAllFlags();
/** Check if a steering flag is present */
native function bool On( ESteeringFlags Flag );
/** Get acceleration rate for the pawn */
native function float GetAccelRate();
/** Get ground speed for the pawn */
native function float GetGroundSpeed();
/** Perform any clean up needed when the owner is destroyed, called by owner */
native function OnOwnerDestroy();

/*********************************************************************************************
 Acceleration functions
 ********************************************************************************************* */

/** Returns the final acceleration to apply to the AI pawn */
native function vector CalculateAcceleration();
/** Add a specific force to the total acceleration being calculated */
native function bool AccumulateForce( out Vector TotalAccel, vector ForceToAdd );

/*********************************************************************************************
 Unreal acceleration steering functions
 ********************************************************************************************* */

/** Start using unreal acceleration force */
native function EnableDefaultAcceleration();
/** Stop using unreal acceleration force */
native function DisableDefaultAcceleration();
/** Set unreal acceleration force */
native function UnrealAccelSet( Vector NewUnrealAccel );
/** Get the unreal acceleration force */
native function vector UnrealAccelGetForce();

/*********************************************************************************************
 Separation steering functions
 ********************************************************************************************* */

/** Get the separation force */
native function vector SeparationGetForce();
/** Start separation steering */
native function SeparationOn( optional class<Actor> SeparateFrom, optional float DistanceToSeparate );
/** Stop separation steering */
native function SeparationOff( optional class<Actor> RemoveSeparateFrom );
/** Add separation exclusion classes */
native function SeparateExclude( optional class<Actor> ExcludeClass );
/** Remove separation exclusion classes */
native function SeparateStopExclude( optional class<Actor> ExcludeClass );
/** Check if the class is a separation class */
native function bool IsSeparationClass( class<Actor> SeparationClass, out float DistanceToSeparate );
/** Check if the class is excluded from separation */
native function bool IsClassExcluded( class<Actor> ExcludeClass );

defaultproperties
{
	UnrealAccelMaxForce=1.f
	SeparateMaxForce=0.75f
	DefaultSeparationDistance=128.f
}