//=============================================================================
// KFDummyReplicationInfo
//=============================================================================
// A dummy PRI for bots that is only used when bEnableGameAnalytics=TRUE.
// Normally, PRI's are not required for bots.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDummyReplicationInfo extends PlayerReplicationInfo;

simulated function bool ShouldBroadCastWelcomeMessage(optional bool bExiting)
{
	return false;
}

defaultproperties
{
	RemoteRole=ROLE_None
	bTickIsDisabled=true

	// make always inactive so it doesn't bloat the PRIArray
	bIsInactive=true
}
