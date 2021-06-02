/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */
class GravityVolume extends PhysicsVolume
	native
	placeable;

/**
 *	Simple PhysicsVolume that modifies the gravity inside it.
 */

/** Gravity along Z axis applied to objects inside this volume. */
var()	float	GravityZ;
/** Scaling GravityZ and being used different function (GetGravityZHuman) to retrieve GravityZ */
var()	float	ScaleGravityHuman;
/** Scaling GravityZ and being used different function (GetGravityZMonster) to retrieve GravityZ */
var()	float	ScaleGravityMonster;

cpptext
{
	virtual FLOAT GetGravityZ() { return GravityZ; }
	virtual FLOAT GetGravityZHuman() { return GravityZ * ScaleGravityHuman; }
	virtual FLOAT GetGravityZMonster() { return GravityZ * ScaleGravityMonster; }
}

defaultproperties
{
	GravityZ = -520.0
	ScaleGravityHuman = 1.0
	ScaleGravityMonster = 1.0
}
