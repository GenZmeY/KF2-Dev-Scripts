//=============================================================================
// KFPickupFactory
//=============================================================================
// Base KF2 PickupFactory
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPickupFactory extends PickupFactory
	abstract
	placeable
	native;

cpptext
{
#if WITH_EDITOR
	virtual UBOOL CanConnectTo(ANavigationPoint* Nav, UBOOL bCheckDistance);
	virtual void CheckForErrors();
#endif //WITH_EDITOR
}

/** Set to true if we've chosen this pickup factory to respawn */
var bool bToBeActivated;

/** If TRUE, will not be added to the standard pickup list, and relies on kismet to enable/disable */
var() bool bKismetDriven;

/** [KISMET ONLY] Overrides the respawn time set in the InventoryType by the RespawnTime property */
var() bool bUseRespawnTimeOverride<EditCondition=bKismetDriven>;

/** [KISMET ONLY] Time, in seconds, that it will take this pickup to respawn again after being picked up */
var() float RespawnTime<EditCondition=bUseRespawnTimeOverride | ClampMin=1.0 | Multiple=1.0>;

/** [KISMET ONLY] Whether this pickup factory is enabled at the start of play, or spawns in disabled */
var() bool bEnabledAtStart<EditCondition=bKismetDriven>;

/** Whether this pickup node has been modified by kismet (enabled or disabled) */
var transient bool bKismetEnabled;

function bool CanUsePickup()
{
	return true;
}

/** Pick a weapon from 'ItemPickups' and enable it in the world */
function Reset()
{
	if (CanUsePickup())
	{
		if( bKismetDriven )
		{
			SetInitialState();
		}
		else
		{
			bToBeActivated = false;
			GotoState('Pickup');
		}
	}
	else
	{
		SetPickupHidden();
	}
}

// Called after PostBeginPlay.
//
simulated event SetInitialState()
{
	if( !bKismetDriven || Role < ROLE_Authority )
	{
		return;
	}

	bKismetEnabled = bEnabledAtStart;
	if( bEnabledAtStart )
	{
		GotoState( 'Pickup' );
	}
	else
	{
		GotoState( 'Disabled' );
	}
}

/**	Handling Toggle event from Kismet. */
function OnToggle( SeqAct_Toggle Action )
{
	// Kismet can only control pickup factories that are kismet-driven
	if( !bKismetDriven )
	{
		return;
	}

	// Turn ON
	if( Action.InputLinks[0].bHasImpulse )
	{
		bKismetEnabled = true;

	}
	// Turn OFF
	else if( Action.InputLinks[1].bHasImpulse )
	{
		bKismetEnabled = false;
	}
	// Toggle
	else if( Action.InputLinks[2].bHasImpulse )
	{
		bKismetEnabled = !bKismetEnabled;
	}

	// Set our state
	if( bKismetEnabled )
	{
		if( !IsInState('Pickup') )
		{
			GotoState( 'Pickup' );
		}
	}
	else if( !IsInState('Disabled') )
	{
		GotoState( 'Disabled' );
	}
}

function SetRespawn()
{
	if( bKismetDriven )
	{
		if( !bKismetEnabled )
		{
			GotoState( 'Disabled' );
		}
		else if( bUseRespawnTimeOverride )
		{
			GotoState( 'Sleeping' );
		}
		return;
	}

	super.SetRespawn();
}

/** Respawns this pickup on a timer */
function float GetRespawnTime()
{
	if( bKismetDriven && bUseRespawnTimeOverride )
	{
		return RespawnTime;
	}

	return super.GetRespawnTime();
}

/** Hide and stop collision on the pickup */
function StartSleeping()
{
 	super.StartSleeping();
 	// Clear reset if StartSleeping is called at the beginninf of a wave
 	ClearTimer( nameof(Reset) );
}

/** Do not try to respawn this pickup on its own */
function bool DelayRespawn()
{
	if( bKismetDriven )
	{
		return false;
	}

 	return true;
}

/** Determine what kind of pickup is visible. Used for dialog. */
function bool CurrentPickupIsWeapon()
{
	return false;
}
function bool CurrentPickupIsArmor()
{
	return false;
}
function bool CurrentPickupIsAmmo()
{
	return false;
}

function bool CurrentPickupIsCash()
{
	return false;
}

/**
  * Make pickup mesh and associated effects hidden.
  */
simulated function SetPickupHidden()
{
	Super.SetPickupHidden();
	if ( PickupMesh != None )
	{
		PickupMesh.SetBlockRigidBody(FALSE);
	}
}

/**
  * Make pickup mesh and associated effects visible.
  */
simulated function SetPickupVisible()
{
	Super.SetPickupVisible();
	if ( PickupMesh != None )
	{
		PickupMesh.SetBlockRigidBody(TRUE);
	}
}

state Disabled
{
	simulated event EndState(Name NextStateName)
	{
		SetPickupVisible();
		SetCollision(true, false);
	}
}

DefaultProperties
{
	// because we call SetRBCollidesWithChannel in SetPickupVisible/Hidden, we can't be in the asynch tickgroup
	TickGroup=TG_PostAsyncWork

	bAllowPathConnections=false
	bNoAutoConnect=true
	bMovable=false

	bKismetDriven=false
	bUseRespawnTimeOverride=false
	RespawnTime=45.0f
}