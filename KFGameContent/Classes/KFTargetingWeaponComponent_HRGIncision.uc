//=============================================================================
// KFTargetingWeaponComponent_HRGIncision
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFTargetingWeaponComponent_HRGIncision extends KFTargetingWeaponComponent;

simulated function bool AllowTargetLockOn(byte TargetingMode)
{
	local bool bAllowLockOn;

	bAllowLockOn = super.AllowTargetLockOn(TargetingMode);

	if (bAllowLockOn)
	{
		if (TargetingMode == ETargetingMode_Zed)
		{
			bAllowLockOn = KFW.bUsingSights;
		}
	}

	return bAllowLockOn;
}

simulated function bool CanLockOnTo(byte TargetingMode, Actor TA)
{
	local KFPawn PawnTarget;
	local bool bCanLockOnTo;

	bCanLockOnTo = super.CanLockOnTo(TargetingMode, TA);

	if (bCanLockOnTo)
	{
		if (TargetingMode == ETargetingMode_Player)
		{
			PawnTarget = KFPawn(TA);
			bCanLockOnTo = PawnTarget.Health < PawnTarget.HealthMax;
		}
	}

	return bCanLockOnTo;
}

simulated function Actor DetermineBestTarget(byte TargetingMode)
{
	local int i;
    local vector StartTrace, EndTrace;
    local rotator ViewRotation;
	local array<Actor> HitActors;
	local array<vector> HitLocations;
	local Actor HitActor;

	StartTrace = Instigator.GetWeaponStartTraceLocation();
    ViewRotation = Instigator.GetViewRotation();
	ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
	EndTrace = StartTrace + vector(ViewRotation) * GetLockRange();
	HitActors = KFW.BeamLineCheck(EndTrace, StartTrace, vect(0,0,0), HitLocations);

	for (i = 0; i < HitActors.Length; ++i)
	{
		HitActor = HitActors[i];
		if (CanLockOnTo(TargetingMode, HitActor))
		{
			return HitActor;
		}
		else
		{
			if (Pawn(HitActor) == none)
			{
				break;
			}
		}
	}

	return none;
}

defaultproperties
{
	// Lock on sounds
    LockTargetingSoundInterval=0.09
	LockAcquiredSoundFirstPerson=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Scope_Locked'
	LockLostSoundFirstPerson=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Scope_Lost'
	LockTargetingSoundFirstPerson=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Scope_Locking'

	// Lock On Functionality
	TargetingModeFlags[DEFAULT_FIREMODE]=TARGETINGMODE_FLAGS_PLAYER //Target only players. set to TARGETINGMODE_FLAGS_ZED if you only want to target Zeds or TARGETINGMODE_FLAGS_ALL to target both Zeds and Players.
	LockRange[DEFAULT_FIREMODE]=200000
	LockAim[DEFAULT_FIREMODE]=0.987
	LockAcquireTime[DEFAULT_FIREMODE]=0.01
	LockAcquireTime_Large[DEFAULT_FIREMODE]=0.01
	LockAcquireTime_Boss[DEFAULT_FIREMODE]=0.01
	LockAcquireTime_Versus[DEFAULT_FIREMODE]=0.01
	LockTolerance[DEFAULT_FIREMODE]=0.4

	HumanTargetableBoneNames=(spine2)

	TargetLocationReplicationInterval=0.016
}