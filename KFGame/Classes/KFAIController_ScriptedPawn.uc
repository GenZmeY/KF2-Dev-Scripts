//=============================================================================
// KFAIController_ScriptedPawn
//=============================================================================
// Base AI Controller for KFPawn_Scripted.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ScriptedPawn extends KFAIController;

/** Only spawning a PRI for gameplayevents! */
function InitPlayerReplicationInfo()
{
	// Do we even need this?
	PlayerReplicationInfo = Spawn(class'KFDummyReplicationInfo', self,, vect(0,0,0),rot(0,0,0));
	PlayerReplicationInfo.PlayerName = string(self.name);
	PlayerReplicationInfo.bBot = true;
}