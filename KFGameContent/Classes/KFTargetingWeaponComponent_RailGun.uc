//=============================================================================
// KFTargetingWeaponComponent_RailGun
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFTargetingWeaponComponent_RailGun extends KFTargetingWeaponComponent;

/** returns true if lock-on is possible */
simulated function bool AllowTargetLockOn(byte TargetingMode)
{
	return super.AllowTargetLockOn(TargetingMode) && KFW.bUsingSights;
}

defaultproperties
{
	// Lock on sounds
    LockTargetingSoundInterval=0.09
	LockAcquiredSoundFirstPerson=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Scope_Locked'
	LockLostSoundFirstPerson=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Scope_Lost'
	LockTargetingSoundFirstPerson=AkEvent'WW_WEP_SA_Railgun.Play_Railgun_Scope_Locking'

	// Lock On Functionality
	TargetingModeFlags[DEFAULT_FIREMODE]=TARGETINGMODE_FLAGS_ZED
	LockRange[DEFAULT_FIREMODE]=200000
	LockAim[DEFAULT_FIREMODE]=0.995
	LockAcquireTime[DEFAULT_FIREMODE]=0.35
	LockAcquireTime_Large[DEFAULT_FIREMODE]=0.6
	LockAcquireTime_Boss[DEFAULT_FIREMODE]=1.1
	LockAcquireTime_Versus[DEFAULT_FIREMODE]=1.1
	LockTolerance[DEFAULT_FIREMODE]=0.2

	TargetLocationReplicationInterval=0.016
}