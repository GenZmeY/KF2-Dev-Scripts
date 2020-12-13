//=============================================================================
// KFDT_NPCBump
//=============================================================================
// Damage type caused by NPCs bumping into KFDestructibleActors. If a 
// destructible actor has this class in its InstaKillDamageType list then
// any Zed will attempt to path through the destructible actor.
// See KFScout, PathSizes for current Large size.
// See AKFAIController::ShouldIgnoreNavigationBlocking() for where this is
// checked.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_NPCBump extends KFDT_Bludgeon
	abstract;

defaultproperties
{
}
