//=============================================================================
// KFEmit_TraderPath
//=============================================================================
// Trader path emitter based on UT3's Willow Wisp
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//============================================================================
class KFEmit_TraderPath extends KFEmit_Path;

simulated function bool ShouldStopPathing()
{
	local KFGameReplicationInfo KFGRI;
	local KFPlayerController KFPC;

   	KFPC = KFPlayerController(Owner);
	KFGRI = KFGameReplicationInfo(KFPC.WorldInfo.GRI);

	return ( (KFGRI == none || KFGRI.OpenedTrader == none) ||
			 (KFPC == none || KFPC.bHideTraderPaths) ||
			 super.ShouldStopPathing() ); 
}

defaultproperties
{
	WAYPOINT_HEIGHT=5

	CURVE_TURNRATE=8.f
	ACCEL_RATE=1200.f

	EmitterTemplate=ParticleSystem'FX_Gameplay_EMIT.FX_Trader_Trail'
	LifeSpan=24.0
	Physics=PHYS_Projectile
	bOnlyRelevantToOwner=true
	bOnlyOwnerSee=false
	Position=-1
	bReplicateMovement=false
	bDestroyOnSystemFinish=true
	bNoDelete=false

	Components.Remove(ArrowComponent0)
	Components.Remove(Sprite)

	Begin Object Name=ParticleSystemComponent0
		bAcceptsLights=false
		SecondsBeforeInactive=0
		bOverrideLODMethod=true
		LODMethod=PARTICLESYSTEMLODMETHOD_DirectSet
	End Object
	WAYPOINT_HEIGHT_NAV_MESH=25
	MinDistanceBetweenWayPointsOnNavMesh=200

	bUseAccelerationPhysics=true
}
