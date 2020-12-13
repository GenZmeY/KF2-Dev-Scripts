//=============================================================================
// KFDT_Explosive_HuskSuicide
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Explosive_HuskSuicide extends KFDT_Explosive
	abstract
	hidedropdown;

static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	return true;
}

DefaultProperties
{
	KDeathUpKick=500
	KDeathVel=700
	KDamageImpulse=1500
	// unreal physics momentum
	bExtraMomentumZ=True

	// hit effects
	bShouldSpawnBloodSplat=true
	bShouldSpawnPersistentBlood=true //jc
	bCanGib=true

	bAnyPerk=true
}
