//=============================================================================
// KFTargetingWeaponComponent
//=============================================================================
// Actor that encapsulates the management and replication of targeting weapon info.
// Enables any weapon to be targeting.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFTargetingWeaponComponent extends Actor
	abstract;

/** Fire mode 0 is the default weapon firing. */
const DEFAULT_FIREMODE			= 0;
/** Fire mode 1 is the alternate weapon firing. */
const ALTFIRE_FIREMODE			= 1;

enum ETargetingMode
{
	ETargetingMode_Zed,
	ETargetingMode_Player,
};

const TARGETINGMODE_FLAGS_ZED = 1;
const TARGETINGMODE_FLAGS_PLAYER = 2;
const TARGETINGMODE_FLAGS_ALL = 3;

var byte TargetingModeFlags[2];

var KFWeapon KFW;

/*********************************************************************************************
 * @name Weapon lock on support
 **********************************************************************************************/

/** How far out should we be considering actors for a lock */
var float LockRange[2];

/** How long does the player need to target an actor to lock on to it*/
var float LockAcquireTime[2];

/** How long does the player need to target a large zed to lock on to it */
var float LockAcquireTime_Large[2];

/** How long does the player need to target a boss to lock on to it*/
var float LockAcquireTime_Boss[2];

/** How long does the player need to target a versus zed to lock on to it */
var float LockAcquireTime_Versus[2];

/** Once locked, how long can the player go without painting the object before they lose the lock */
var float LockTolerance[2];

/** What "target" is this weapon locked on to */
var KFPawn LockedTarget[2];

/** What hitzone is this weapon locked on to */
var int LockedHitZone[2];

/** What "target" is current pending to be locked on to */
var KFPawn PendingLockedTarget[2];

/** What hitzone is this weapon trying to lock on to */
var int PendingHitZone[2];

/** angle for locking for lock targets */
var float LockAim[2];

/** The frequency with which we play the Lock Targeting sound */
var float LockTargetingSoundInterval[2];

/** Sound Effects to play when Locking */
var AkBaseSoundObject LockAcquiredSoundFirstPerson;
var AkBaseSoundObject LockLostSoundFirstPerson;
var AkBaseSoundObject LockTargetingSoundFirstPerson;

/** How much time is left before pending lock-on can be acquired */
var float PendingLockAcquireTimeLeft[2];
/** How much time is left before pending lock-on is lost */
var float PendingLockTimeout[2];
/** How much time is left before lock-on is lost */
var float LockedOnTimeout;
var float LockedOnTimeoutTimer[2];

/** Location on an enemy we're currently locked onto */
var vector LockedAimLocation[2];

var array<name> HumanTargetableBoneNames;

/** Vulnerable zones on an enemy we're currently locked onto */
var array<vector> TargetVulnerableLocations_Zed;
var array<vector> TargetVulnerableLocations_Player;

/** The frequency with which we replicate the targeting location to the server. Only matters for showing other players where we shot */
var float TargetLocationReplicationInterval;
var float TargetLocationReplicationTimer[2];

var bool bTargetingUpdated;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	SetTickIsDisabled(true);
}

simulated function Init(KFWeapon InKFW)
{
	KFW = InKFW;
	Instigator = InKFW.Instigator;
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (Instigator != none && Instigator.Controller != none && Instigator.IsLocallyControlled())
    {
        CheckTargetLock(DeltaTime);
    }
}

/**
* This function checks to see if we are locked on a target
*/
simulated function CheckTargetLock(float DeltaTime)
{
	local bool bAllowLockOn;
	local byte Flags;

	bTargetingUpdated = false;

	if ((Instigator == None) ||
		(Instigator.Controller == None) ||
		(KFW != Instigator.Weapon) ||
		KFPlayerController(Instigator.Controller) == none)
	{
		return;
	}

	TargetVulnerableLocations_Zed.Length = 0;
	TargetVulnerableLocations_Player.Length = 0;

	Flags = TargetingModeFlags[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];

	if (!AllowTargetLockOn(ETargetingMode_Zed))
	{
		AdjustLockTarget(ETargetingMode_Zed, None);
		PendingLockedTarget[ETargetingMode_Zed] = None;
		LockedAimLocation[ETargetingMode_Zed]=vect(0,0,0);
	}
	else
	{
		bAllowLockOn = true;
		if ((Flags & TARGETINGMODE_FLAGS_ZED) != 0)
		{
			UpdateTargetLock(ETargetingMode_Zed, DeltaTime);
		}
	}

	if (!AllowTargetLockOn(ETargetingMode_Player))
	{
		AdjustLockTarget(ETargetingMode_Player, None);
		PendingLockedTarget[ETargetingMode_Player] = None;
		LockedAimLocation[ETargetingMode_Player]=vect(0,0,0);
	}
	else
	{
		bAllowLockOn = true;
		if ((Flags & TARGETINGMODE_FLAGS_PLAYER) != 0)
		{
			UpdateTargetLock(ETargetingMode_Player, DeltaTime);
		}
	}

	if (!bAllowLockOn)
	{
		ClearTimer(nameof(PlayTargetingBeepTimer));
		return;
	}

	bTargetingUpdated = true;
}

/** returns true if lock-on is possible */
simulated function bool AllowTargetLockOn(byte TargetingMode)
{
	return !Instigator.bNoWeaponFiring;
}

simulated function AdjustLockTarget(byte TargetingMode, KFPawn NewLockTarget)
{
	if (LockedTarget[TargetingMode] == NewLockTarget)
	{
		// no need to update
		return;
	}

	if (NewLockTarget == None)
	{
		// Clear the lock
		if (LockedTarget[TargetingMode] != none)
		{
			LockedTarget[TargetingMode] = None;

			if (TargetingMode == ETargetingMode_Zed)
			{
				TargetVulnerableLocations_Zed.Length = 0;
			}
			else
			{
				TargetVulnerableLocations_Player.Length = 0;
			}

			LockedAimLocation[TargetingMode]=vect(0,0,0);
			ServerSetTargetingLocation(TargetingMode, LockedAimLocation[TargetingMode]);

			if (Instigator != None && Instigator.IsHumanControlled())
    		{
    			KFW.PlaySoundBase(LockLostSoundFirstPerson, true);
    		}
		}
	}
	else
	{
		// Set the lock
		LockedTarget[TargetingMode] = NewLockTarget;

		if (Instigator != None && Instigator.IsHumanControlled())
		{
			KFW.PlaySoundBase(LockAcquiredSoundFirstPerson, true);
		}
	}
}

reliable server private function ServerSetTargetingLocation(byte TargetingMode, vector NewTargetingLocation)
{
	LockedAimLocation[TargetingMode] = NewTargetingLocation;
}

simulated function PlayTargetingBeepTimer()
{
	if (Instigator != None && Instigator.IsHumanControlled() )
	{
		KFW.PlaySoundBase(LockTargetingSoundFirstPerson, true);
	}
}

simulated function UpdateTargetLock(byte TargetingMode, float DeltaTime)
{
	local Actor BestTarget;

	BestTarget = DetermineBestTarget(TargetingMode);
	UpdateLockTargets(TargetingMode, DeltaTime, BestTarget);
	SetupAimLock(TargetingMode, DeltaTime);
}

simulated function Actor DetermineBestTarget(byte TargetingMode)
{
    local vector StartTrace;
    local rotator ViewRotation;
    local vector X,Y,Z;
    local Actor BestTarget, HitActor, TA;
	local vector EndTrace, Aim, HitLocation, HitNormal;
	local KFPlayerController KFPC;

    KFPC = KFPlayerController(Instigator.Controller);

	// Get the location and rotation that a shot would take
	StartTrace = Instigator.GetWeaponStartTraceLocation();
    ViewRotation = Instigator.GetViewRotation();

	// Add in the free-aim rotation
	ViewRotation += KFPC.WeaponBufferRotation;

    GetAxes(ViewRotation, X, Y, Z);

	BestTarget = None;

	// Begin by tracing the shot to see if it hits anyone
	Aim = vector(ViewRotation);
	EndTrace = StartTrace + Aim * GetLockRange();
	HitActor = KFW.Trace(HitLocation, HitNormal, EndTrace, StartTrace, true,,, TRACEFLAG_Bullet);

	// Check for a hit
	if ((HitActor == None) || !CanLockOnTo(TargetingMode, HitActor))
	{
		TA = PickTarget(Aim, StartTrace, TargetingMode == ETargetingMode_Player);
		if (TA != None && CanLockOnTo(TargetingMode, TA))
		{
            // Trace to see if we hit a destructible, as the PickTarget code only traces against world geometry
            // @todo: Set up pick target to ignore pawns (as it should), but not trace through destructibles
            HitActor = Trace(HitLocation, HitNormal, TA.Location, StartTrace, true,,, TRACEFLAG_Bullet);

            // Make sure we didn't hit a destructible
            if (KFFracturedMeshActor(HitActor) != none || KFDestructibleActor(HitActor) != none)
            {
                BestTarget = none;
            }
            else
            {
                BestTarget = TA;
        	}
		}
	}
	else	// We hit a valid target
	{
		BestTarget = HitActor;
	}

	return BestTarget;
}

simulated function bool CanLockOnTo(byte TargetingMode, Actor TA)
{
	Local KFPawn PawnTarget;

    PawnTarget = KFPawn(TA);

    // Make sure the pawn is legit, isn't dead, and isn't already at full health
    if ((TA == None) ||
		!TA.bProjTarget ||
		TA.bDeleteMe ||
		(PawnTarget == None) ||
        (TA == Instigator) ||
		(PawnTarget.Health <= 0) ||
        (!KFW.bUseAltFireMode && !KFW.HasAmmo(DEFAULT_FIREMODE)) ||
		(KFW.bUseAltFireMode && !KFW.HasAmmo(ALTFIRE_FIREMODE)))
	{
		return false;
	}

	return ((TargetingMode == ETargetingMode_Zed && !WorldInfo.GRI.OnSameTeam(Instigator,TA)) ||
			(TargetingMode == ETargetingMode_Player && WorldInfo.GRI.OnSameTeam(Instigator,TA)));
}

simulated function Actor PickTarget(vector Aim, vector StartTrace, optional bool bTargetTeammates=false)
{
	local float BestAim, BestDist;

	BestAim = GetLockAim();
	BestDist = 0.0;
	return KFPlayerController(Instigator.Controller).GetPickedAimAtTarget(
		BestAim, BestDist, Aim, StartTrace, GetLockRange(), bTargetTeammates);
}

simulated function UpdateLockTargets(byte TargetingMode, float DeltaTime, Actor BestTarget)
{
	// clear lock if target is destroyed
	if (LockedTarget[TargetingMode] != None)
	{
		if (LockedTarget[TargetingMode].bDeleteMe)
		{
			AdjustLockTarget(TargetingMode, None);
		}
	}

	// If we have a "possible" target, note its time mark
	if (BestTarget != None)
	{
		if (BestTarget == LockedTarget[TargetingMode])
		{
			UpdateTargetLocked(TargetingMode);
		}
		// We have our best target, see if they should become our current target.
		// Check for a new Pending Lock
		else if (PendingLockedTarget[TargetingMode] != BestTarget)
		{
			UpdatePendingLockTarget(TargetingMode, BestTarget);
		}

		AcquireLockTarget(TargetingMode, DeltaTime, BestTarget);
	}
	// If we lost a target, attempt to invalidate the pending target
	else
	{
		TimeoutPendingLockTarget(TargetingMode, DeltaTime);
	}

	TimeoutLockTarget(TargetingMode, DeltaTime, BestTarget);
}

simulated function UpdateTargetLocked(byte TargetingMode)
{
	LockedOnTimeoutTimer[TargetingMode] = GetLockTolerance();
	if (PendingLockedTarget[TargetingMode] != none)
	{
    	ClearTimer(nameof(PlayTargetingBeepTimer));
    	PendingLockedTarget[TargetingMode] = None;
	}
}

simulated function UpdatePendingLockTarget(byte TargetingMode, Actor BestTarget)
{
	local KFPawn_Monster KFPM;

	KFPM = KFPawn_Monster(BestTarget);

	PendingLockedTarget[TargetingMode] = KFPawn(BestTarget);
	PendingLockTimeout[TargetingMode] = GetLockTolerance();
	PendingLockAcquireTimeLeft[TargetingMode] = GetLockAcquireTime();

	if (KFPM != none)
	{
		if (KFPM.IsABoss())
		{
			PendingLockAcquireTimeLeft[TargetingMode] = GetLockAcquireTime_Boss();
		}
		else if (KFPM.bVersusZed)
		{
			PendingLockAcquireTimeLeft[TargetingMode] = GetLockAcquireTime_Versus();
		}
		else if (KFPM.IsLargeZed())
		{
			PendingLockAcquireTimeLeft[TargetingMode] = GetLockAcquireTime_Large();
		}
	}

	SetTimer(LockTargetingSoundInterval[TargetingMode], true, nameof(PlayTargetingBeepTimer));

	// Play the "targeting" beep when we begin attempting to lock onto a target
	// that we haven't locked onto yet
	if (Instigator != None && Instigator.IsHumanControlled())
	{
    	PlaySoundBase(LockTargetingSoundFirstPerson, true);
	}
}

simulated function AcquireLockTarget(byte TargetingMode, float DeltaTime, Actor BestTarget)
{
	// Acquire new target if LockAcquireTime has passed
	if (PendingLockedTarget[TargetingMode] != None)
	{
		PendingLockAcquireTimeLeft[TargetingMode] -= DeltaTime;
		if (PendingLockedTarget[TargetingMode] == BestTarget && PendingLockAcquireTimeLeft[TargetingMode] <= 0)
		{
			AdjustLockTarget(TargetingMode, PendingLockedTarget[TargetingMode]);
			PendingLockedTarget[TargetingMode] = None;
			ClearTimer(nameof(PlayTargetingBeepTimer));
		}
	}
}

simulated function TimeoutPendingLockTarget(byte TargetingMode, float DeltaTime)
{
	if (PendingLockedTarget[TargetingMode] != None)
	{
		PendingLockTimeout[TargetingMode] -= DeltaTime;
		if (PendingLockTimeout[TargetingMode] <= 0 || !CanLockOnTo(TargetingMode, PendingLockedTarget[TargetingMode]))
		{
			PendingLockedTarget[TargetingMode] = None;
			ClearTimer(nameof(PlayTargetingBeepTimer));
		}
	}
}

simulated function TimeoutLockTarget(byte TargetingMode, float DeltaTime, Actor BestTarget)
{
	// If the new target is not the same, attempt to invalidate current locked on target
	if (LockedTarget[TargetingMode] != None && BestTarget != LockedTarget[TargetingMode])
	{
		LockedOnTimeoutTimer[TargetingMode] -= DeltaTime;
		if (LockedOnTimeoutTimer[TargetingMode] <= 0.f || !CanLockOnTo(TargetingMode, LockedTarget[TargetingMode]))
		{
			AdjustLockTarget(TargetingMode, None);
		}
	}
}

simulated function SetupAimLock(byte TargetingMode, float DeltaTime)
{
	local vector Aim, StartTrace, BestZoneLocation;
	local int OldHitZone;

	Aim = vector(Instigator.GetViewRotation());
	//StartTrace = KFW.GetSafeStartTraceLocation();
	StartTrace = Instigator.GetWeaponStartTraceLocation();

	// Set the aiming location if we have a target lock
    if (LockedTarget[TargetingMode] != none)
	{
        OldHitZone = LockedHitZone[TargetingMode];
        LockedHitZone[TargetingMode] =
			AddTargetingZones(TargetingMode, LockedTarget[TargetingMode], StartTrace, Aim, BestZoneLocation);
        if (OldHitZone != LockedHitZone[TargetingMode])
        {
       		if (Instigator != None && Instigator.IsHumanControlled())
			{
				KFW.PlaySoundBase(LockTargetingSoundFirstPerson, true);
			}
        }

        TargetLocationReplicationTimer[TargetingMode] -= DeltaTime;

        if (TargetLocationReplicationTimer[TargetingMode] <= 0 || IsZero(LockedAimLocation[TargetingMode]))
        {
            TargetLocationReplicationTimer[TargetingMode] = TargetLocationReplicationInterval;
            ServerSetTargetingLocation(TargetingMode, LockedAimLocation[TargetingMode]);
        }

        // Set the location where the shot will go
        LockedAimLocation[TargetingMode] = BestZoneLocation;
	}
	else
	{
        LockedHitZone[TargetingMode] = -1;
	}

	// Set the pending target location
    if (PendingLockedTarget[TargetingMode] != none)
	{
        PendingHitZone[TargetingMode] =
			AddTargetingZones(TargetingMode, PendingLockedTarget[TargetingMode], StartTrace, Aim, BestZoneLocation);
	}
	else
	{
		PendingHitZone[TargetingMode] = -1;
	}
}

simulated function int AddTargetingZones(
	byte TargetingMode, KFPawn KFPTarget, vector StartTrace, vector Aim, out vector BestZoneLocation)
{
	local KFPawn_Monster KFPM;
	local KFPawn_Human KFPH;

	if (TargetingMode == ETargetingMode_Zed)
	{
		KFPM = KFPawn_Monster(KFPTarget);
		if (KFPM != none)
		{
			return GetZedVulnerableLocations(KFPM, Aim, StartTrace, BestZoneLocation);
		}
	}
	else
	{
		KFPH = KFPawn_Human(KFPTarget);
		if (KFPH != none)
		{
			return GetHumanVulnerableLocations(KFPH, Aim, StartTrace, BestZoneLocation);
		}
	}

	return -1;
}

simulated function int GetZedVulnerableLocations(
	KFPawn_Monster Zed, vector Aim, vector StartTrace, out vector BestZoneLocation)
{
	local vector ZoneLocation;
	local int BestZoneIndex;
	local float BestZoneDot;
	local vector DirToZone;
	local float DotToZone;
	local int i;

	// Get all the vulnerable hit zones
	for (i = 0; i < Zed.WeakSpotSocketNames.Length; i++)
	{
		Zed.Mesh.GetSocketWorldLocationAndRotation(Zed.WeakSpotSocketNames[i], ZoneLocation);

		if (!IsZero(ZoneLocation))
		{
			TargetVulnerableLocations_Zed.AddItem(ZoneLocation);

			// Figure out which target zone we are closest to
			DirToZone = ZoneLocation - StartTrace;
			DotToZone = Normal(Aim) dot Normal(DirToZone);

			if (DotToZone > BestZoneDot)
			{
				BestZoneIndex = TargetVulnerableLocations_Zed.Length - 1;
				BestZoneDot = DotToZone;

				// Set the location for the zone we are closest targeting
				BestZoneLocation = ZoneLocation;
			}
		}
	}

	return BestZoneIndex;
}

simulated function int GetHumanVulnerableLocations(
	KFPawn_Human Human, vector Aim, vector StartTrace, out vector BestZoneLocation)
{
	local vector ZoneLocation;
	local int BestZoneIndex;
	local float BestZoneDot;
	local vector DirToZone;
	local float DotToZone;
	local int i;

	// Get all the vulnerable hit zones
	for (i = 0; i < HumanTargetableBoneNames.Length; i++)
	{
		ZoneLocation = Human.Mesh.GetBoneLocation(HumanTargetableBoneNames[i]);
		if(!IsZero(ZoneLocation))
		{
			TargetVulnerableLocations_Player.AddItem(ZoneLocation);

			// Figure out which target zone we are closest to
			DirToZone = ZoneLocation - StartTrace;
			DotToZone = Normal(Aim) dot Normal(DirToZone);

			if( DotToZone > BestZoneDot )
			{
				BestZoneIndex = TargetVulnerableLocations_Player.Length - 1;
				BestZoneDot = DotToZone;

				// Set the location for the zone we are closest targeting
				BestZoneLocation = ZoneLocation;
			}
		}
	}

	return BestZoneIndex;
}

/*********************************************************************************************
 * @name KFWeapon hooks
 **********************************************************************************************/

simulated function OnWeaponAttachedTo()
{
	SetTickIsDisabled(false);
}

simulated function OnWeaponDetached()
{
	SetTickIsDisabled(true);
}

/*********************************************************************************************
 * @name Getters
 **********************************************************************************************/

simulated function float GetLockRange()
{
	return LockRange[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];
}

simulated function float GetLockAim()
{
	return LockAim[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];
}

simulated function float GetLockAcquireTime()
{
	return LockAcquireTime[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];
}

simulated function float GetLockAcquireTime_Large()
{
	return LockAcquireTime_Large[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];
}

simulated function float GetLockAcquireTime_Boss()
{
	return LockAcquireTime_Boss[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];
}

simulated function float GetLockAcquireTime_Versus()
{
	return LockAcquireTime_Versus[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];
}

simulated function float GetLockTolerance()
{
	return LockTolerance[KFW.bUseAltFireMode ? ALTFIRE_FIREMODE : DEFAULT_FIREMODE];
}

defaultproperties
{
	RemoteRole=ROLE_SimulatedProxy
	bOnlyRelevantToOwner=true
	bHidden=true
	bCollideActors=false
	bProjTarget=false
	bStatic=false
	bNoDelete=false
}
