//=============================================================================
// AnimationProxy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
/**
 *
 *
 * This plugin introduces squad mechanics to owning BaseAIController. This class is not the same as a squad itself,
 * it introduces actions that can be performed on a squad. Advantage of this approach is that any given BaseAIController
 * can easily change squads just by changing 'Squad' variable of its 'CoveringPlugin'.
 */

class PluginSquad extends AIPlugin within BaseAIController
	native(Plugin);

var const BaseAISquad Squad;

final native function EnemyPerceived(EWSPerceptionMode PerceptionType, Pawn PerceivedEnemy);

defaultproperties
{
}