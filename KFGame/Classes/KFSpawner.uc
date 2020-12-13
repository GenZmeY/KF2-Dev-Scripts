//=============================================================================
// KFSpawner
//=============================================================================
// Placeable actor that can be used to script AI/Squad spawning
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFSpawner extends Actor
	native
	placeable;

/** Set to true if we're activating this from kismet. Set this to false if it is acting as a child spawner.
	This way any variables that the spawn will inherit from the parent will be greyed out */
var() bool	bIsTriggeredSpawner;

/** Largest type of squad that fits in this spawner */
var() ESquadType	LargestSquadType<EditCondition=bIsTriggeredSpawner>;
/** If > 0, automatically deactivate this spawner after some time */
var() float			MaxStayActiveTime<EditCondition=bIsTriggeredSpawner>;
/** Minimum time before getting re-activated */
var() float			CooldownTime<EditCondition=bIsTriggeredSpawner>;

/** Time between individual spawns within a squad */
var() float			SpawnInterval<EditCondition=bIsTriggeredSpawner>;

/** If set, yaw is randomized (useful for floor spawners) */
var() bool			bRandomizeSpawnYawRot;
/** The direction to spawn a zed if bRandomizeSpawnYawRot is true */
var transient int	LastSpawnYawRot;

/** If set, this spawner will auto-deactivate if this actor (e.g. Trigger, TriggerVolume) is not touching any players */
var() Actor			ActorToReacquirePlayerTouch<EditCondition=bIsTriggeredSpawner>;
/** If > 0, players must be touching the trigger for some amount of time before it can be used */
var() float			MinReacquireTouchTime<EditCondition=bIsTriggeredSpawner>;
var transient float	ReacquireTouchTimeLeft;

/** Number of zeds required to be touching the ActorToReacquirePlayerTouch for this spawning to be active */
var() int			NumTouchingZedsRequired<EditCondition=bIsTriggeredSpawner>;
/** Are enough zeds touching this actor to be able to spawn zeds here */
var transient bool  bRequiredZedAmountTouching;

/** Additional spawn points for pending zeds when this spawner is active */
var() array<KFSpawner> ChildSpawners;

/** list of actor classes waiting to spawn */
var transient array< class<KFPawn_Monster> > PendingSpawns;

/** The animation direction of the last wall spawned zed */
var transient byte	LastAnimDirection;

/** Local timers for CanSpawnHere */
var protected transient float LastActivationTime;
var protected transient float LastSpawnTime;

/** Is this spawner active? */
var bool bIsActive;
/** Is this spawner currently in the process of spawning? */
var bool bIsSpawning;

/** Will log out/display spawning info for this spawn volume */
var bool bDebugSpawning;

/*********************************************************************************************
 `* Effects
********************************************************************************************* */

enum EEmergeAnim
{
	EMERGE_Floor,
	EMERGE_Wall248UU,
	EMERGE_WallHigh,
	EMERGE_Ceiling,
	EMERGE_None,
};

/** Animation to play when exiting the spawner */
var() EEmergeAnim	EmergeAnim;

/** Reference to destructible object that we want to smash through */
var() KFDestructibleActor DestructibleToBreak;

/*********************************************************************************************
 `* Debugging
********************************************************************************************* */

/** If set, do not activate child spawners */
var transient bool bIgnoreChildren;

cpptext
{
	/** Warn the mapper if a child KFSpawner has a "LargestSquadType" that's smaller than it's parent */
#if WITH_EDITOR
	virtual void CheckForErrors();
#endif
	/** Update SpawnInterval in tick */
	virtual void TickSpecial(FLOAT DeltaTime);

	/** Spawns an AI from the pending spawns list */
	UBOOL		SpawnAI(UClass* ActorClass);
	/** If we have child spawners, randomely select a spawn location the list */
	AKFSpawner* ChooseChildSpawner();

	/** Gets a random direction to spawn our zed that's different than the last */
	INT GetRandomYawRot();
}

function OnToggle( SeqAct_Toggle Action )
{
	// On
	if( Action.InputLinks[0].bHasImpulse || (Action.InputLinks[2].bHasImpulse && !bIsActive) )
	{
		ActivateSpawner();
	}
	// Off
	else
	{
		DeactivateSpawner();
	}
}

function ActivateSpawner()
{
	local KFGameInfo KFGI;

	if ( !bIsActive )
	{
		// restart reaquire touching actors interval
		if ( MinReacquireTouchTime > 0 && ActorToReacquirePlayerTouch != None )
		{
			ReacquireTouchTimeLeft = MinReacquireTouchTime;
			SetTimer(1.0, true, nameof(ReacquirePlayerTouch));
		}

		// restart reaquire touching actors interval
		if ( NumTouchingZedsRequired > 0 && ActorToReacquirePlayerTouch != None )
		{
			SetTimer(1.0, true, nameof(ReacquireZedTouch));
		}
	}

	bIsActive = true;
	LastActivationTime = WorldInfo.TimeSeconds;

	// register with the SpawnManager
	KFGI = KFGameInfo( WorldInfo.Game );
	if ( KFGI != None && KFGI.SpawnManager != None )
	{
		KFGI.SpawnManager.ActiveSpawner = self;
	}
}

function DeactivateSpawner()
{
	bIsActive = false;
	LastActivationTime = -1.f;

	ClearTimer(nameof(ReacquirePlayerTouch));
	ClearTimer(nameof(ReacquireZedTouch));
}

function bool CanSpawnHere(ESquadType DesiredSquadType)
{
	// check if activated
	if ( !bIsActive )
		return false;

	// check valid squad type
	if ( DesiredSquadType < LargestSquadType )
		return false;

	// check MaxStayActiveTime
	if ( MaxStayActiveTime > 0 && `TimeSince(LastActivationTime) > MaxStayActiveTime )
		return false;

	// check CooldownTime
	if ( CooldownTime > 0 && LastSpawnTime > 0 && `TimeSince(LastSpawnTime) < CooldownTime )
		return false;

	// check if player touch is still being acquired
	if ( ReacquireTouchTimeLeft > 0.f )
		return false;

	// check if already spawning
	if ( PendingSpawns.Length > 0 )
		return false;

    // Not enough touching zeds here!
    if( ActorToReacquirePlayerTouch != none && NumTouchingZedsRequired > 0
        && bRequiredZedAmountTouching == false )
    {
        return false;
    }

	return true;
}

/** Check if any players are still in the instigating trigger/triggervolume */
function ReacquirePlayerTouch()
{
	local Pawn P;
	local bool bHasAlivePlayers;

	ForEach ActorToReacquirePlayerTouch.TouchingActors(class'Pawn', P)
	{
		if ( P.Controller != None && P.IsAliveAndWell() )
		{
			// Human Team
            if( P.GetTeamNum() == 0 )
			{
                bHasAlivePlayers = true;
            }
		}
	}

	// auto-deactivate if there are no living players in the area
	if ( !bHasAlivePlayers )
	{
		`log(self@"ReacquirePlayerTouch is auto-deactivating this spawner", bDebugSpawning);

		ClearTimer(nameof(ReacquirePlayerTouch));
		DeactivateSpawner();
	}

	ReacquireTouchTimeLeft -= 1.f;
	if ( ReacquireTouchTimeLeft <= 0.f )
	{
		`log(self@"ReacquirePlayerTouch completed successfully", bDebugSpawning);

		ClearTimer(nameof(ReacquirePlayerTouch));
	}
}

/** Check if any zeds are still in the instigating trigger/triggervolume */
function ReacquireZedTouch()
{
	local Pawn P;
	local int NumAliveZedsTouching;

    if( !bIsActive )
    {
        return;
    }

	ForEach ActorToReacquirePlayerTouch.TouchingActors(class'Pawn', P)
	{
		if ( P.Controller != None && P.IsAliveAndWell() )
		{
            // Zed Team
            if( P.GetTeamNum() != 0 )
			{
                NumAliveZedsTouching++;
            }
		}
	}

	`log("NumAliveZedsTouching = "$NumAliveZedsTouching, bDebugSpawning);

    // See if enough zeds are touching to set the flag to true
    if( NumAliveZedsTouching >= NumTouchingZedsRequired )
    {
        bRequiredZedAmountTouching = true;
    }
    else
    {
        bRequiredZedAmountTouching = false;
    }
}


/** Initiate spawning.  Returns a list of classes that weren't able to be spawned here */
function int SpawnSquad( out array< class<KFPawn_Monster> > SpawnList )
{
	if ( SpawnList.Length == 0 )
		return 0;

	AddPendingSpawns( SpawnList );

	LastSpawnTime = WorldInfo.TimeSeconds;
	bIsSpawning = PendingSpawns.Length > 0;

	return PendingSpawns.Length;
}

/** Validate and copy a list of classes to spawn into our PendingSpawn list */
function AddPendingSpawns( out array< class<KFPawn_Monster> > SpawnList )
{
	local int i;
	local KFSpecialMoveHandler SMH;

	// if we don't need an animation, skip the SpecialMove (only valid if we're not using child spawners)
	if ( EmergeAnim == EMERGE_None && ChildSpawners.Length == 0 )
	{
		PendingSpawns = SpawnList;
		SpawnList.Length = 0;
		return;
	}

	// Remove all monsters from the list that don't have emerge moves
	for ( i = SpawnList.length - 1; i >= 0 ; i-- )
	{
		SMH = SpawnList[i].default.SpecialMoveHandler;
		if ( ESpecialMove(SM_Emerge) < SMH.SpecialMoveClasses.Length && SMH.SpecialMoveClasses[SM_Emerge] != None )
		{
			PendingSpawns.AddItem( SpawnList[i] );
			SpawnList.Remove( i, 1 );
		}
	}
}

/**
 * Called when a new pawn is spawned using this spawner,
 * use to handle any special behaviors, such as playing
 * an animation, etc.
 */
event HandleSpawn(KFPawn NewSpawn, int SlotIdx)
{
	local KFGameInfo KFGI;
`if(`notdefined(ShippingPC))
	local KFGameReplicationInfo KFGRI;
`endif

	// instantly damage our linked destructible
	if ( DestructibleToBreak != None && !DestructibleToBreak.bShutDown )
	{
		// use RadiusDamage so that we don't need a valid hit component
		DestructibleToBreak.TakeRadiusDamage(NewSpawn.Controller, 10000, 0, class'DmgType_Crushed', 0, Location, true, self);
	}

	// Handle emerge move/animation
	if ( EmergeAnim != EMERGE_None )
	{
		NewSpawn.DoSpecialMove( SM_Emerge,,, class'KFSM_Emerge'.static.PackAnimFlag( EmergeAnim, LastAnimDirection ) );

		if ( !NewSpawn.IsDoingSpecialMove(SM_Emerge) )
		{
			`warn("SM_Emerge failed for"@NewSpawn);
			NewSpawn.Died( None, WorldInfo.KillZDamageType, Location );
			HandleFailedSpawn();
		}
	}

`if(`notdefined(ShippingPC))
    // Let the GRI know that a spawn volume was just used
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != none && KFGRI.bTrackingMapEnabled )
	{
		KFGRI.AddRecentSpawnVolume(Location, true);
	}
`endif

	// Recount number of living AI for wave gametype
	KFGI = KFGameInfo( WorldInfo.Game );
	if ( KFGI != None )
	{
		KFGI.RefreshMonsterAliveCount();
	}
}

/**
 * Called when the spawner fails to spawn a pawn
 */
event HandleFailedSpawn()
{
	local KFGameInfo KFGI;
`if(`notdefined(ShippingPC))
	local KFGameReplicationInfo KFGRI;
`endif

    `warn(self@PendingSpawns.Length$" zeds failed to spawn at this portal spawn!!!");

    // Removed failed spawns from the NumAISpawnsQueued;
	KFGI = KFGameInfo( WorldInfo.Game );
	if ( KFGI != None )
	{
		`log(self@GetFuncName()$" removing "$PendingSpawns.Length$" from NumAISpawnsQueued due to failed spawn. NumAISpawnsQueued: "$KFGI.NumAISpawnsQueued, bDebugSpawning);
        KFGI.NumAISpawnsQueued -= PendingSpawns.Length;
		KFGI.NumAIFinishedSpawning -= PendingSpawns.Length;
	}

`if(`notdefined(ShippingPC))
    	// Let the GRI know that a portal spawn failed to spawn some AI
    	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
    	if( KFGRI != none && KFGRI.bTrackingMapEnabled )
    	{
    		KFGRI.AddFailedSpawn(Location, true);
    	}
`endif

    if( bDebugSpawning )
    {
    	if ( KFGI != None && KFGI.SpawnManager != None )
    	{
    		KFGI.SpawnManager.ActiveSpawner = self;
    		if( bDebugSpawning )
    		{
                KFGI.SpawnManager.LogMonsterList(PendingSpawns, "Failed Pending Spawns For "$Self);
            }
    	}
    }

    // If a zed failed to spawn, clear the list
    PendingSpawns.Length = 0;
}

/** Debugging */
function bool TestSpawn(class<KFPawn_Monster> SpawnClass, optional int NumSpawns=1, optional bool bImmediate)
{
	local array< class<KFPawn_Monster> > TestSpawnList;

	while( NumSpawns > 0 )
	{
		TestSpawnList.AddItem(SpawnClass);
		NumSpawns--;
	}

	SpawnSquad(TestSpawnList);

	if ( bImmediate )
	{
		// don't wait for spawn interval, update spawn next tick
		LastSpawnTime -= SpawnInterval;
	}

	return bIsSpawning;
}

DefaultProperties
{
	// Ensures we can randomize in all directions
	bIsTriggeredSpawner=true
	LastAnimDirection=255
	LastSpawnYawRot=-1

	SpawnInterval=0.5
	CooldownTime=20.f
	LargestSquadType=EST_Medium

	Begin Object Class=StaticMeshComponent Name=PreviewMesh
		HiddenGame=TRUE
		StaticMesh=StaticMesh'ZED_Clot_MESH.ZED_Clot'
		Rotation=(Yaw=-16384)
	End Object
	Components.Add(PreviewMesh)
}
