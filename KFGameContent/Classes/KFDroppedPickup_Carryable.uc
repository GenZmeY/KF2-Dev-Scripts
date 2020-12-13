//=============================================================================
// KFDroppedPickup_Carryable
//=============================================================================
// Implements dropped weapon/item pickups
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
// Based on GearDroppedPickup
// Copyright 1998-2011 Epic Games, Inc. All Rights Reserved.
//=============================================================================
class KFDroppedPickup_Carryable extends KFDroppedPickup;

var float idleDestroyTime;
var KFObjectiveCollectActor ParentCollectActor;

simulated function PostBeginPlay()
{
	SetTimer(idleDestroyTime, false, nameof(IdleDestroy));
}

simulated function IdleDestroy()
{
	if (ParentCollectActor != none)
	{
		ParentCollectActor.DestroyingChildCarryable();
	}

	Destroy();
}

defaultproperties
{
	idleDestroyTime = 20.f;
}