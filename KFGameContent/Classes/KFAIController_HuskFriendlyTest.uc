//=============================================================================
// KFAIController_HuskFriendlyTest
//=============================================================================
// Husk's AIController that will target zeds not players - for testing
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_HuskFriendlyTest extends KFAIController_ZedHusk;

/** Don't create a benchmarking PRI for the test Hans */
function InitPlayerReplicationInfo(){}

/** Make sure test Hans is on the human team */
simulated event byte ScriptGetTeamNum()
{
	return 0;
}

function bool CanDoFireball( float DistToTargetSq )
{
	 return false;
}

function bool CanDoFlamethrower( float DistToTargetSq )
{
	 if( `TimeSince(LastFlameThrowerTime) > TimeBetweenFlameThrower &&
		DistToTargetSq <= MaxDistanceForFlameThrower * MaxDistanceForFlameThrower &&
		MyKFPawn.CanDoSpecialMove(SM_HoseWeaponAttack) )
	 {
		 return true;
	 }
	 return false;
}

defaultproperties
{
    bAllowScriptTeamCheck=true
	// FlameThrower
	TimeBetweenFlameThrower=1
	MaxDistanceForFlameThrower=1000
}
