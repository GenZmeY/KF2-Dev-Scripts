//=============================================================================
// AICommand_SummonZeds
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 12/4/2013
//=============================================================================

class AICommand_SummonZeds extends AICommand_SpecialMove
	within KFAIController;



/** Waves of zeds to summon for this command*/
var	KFAIWaveInfo				SummonWave;

/** The maximum number of zeds to spawn/have active at once for this boss */
var int MaxBossMinions;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool Summon( KFAIController AI, KFAIWaveInfo NewSummonWave, int NewMaxBossMinions )
{
	local AICommand_SummonZeds Cmd;

	if( AI != none )
	{
		Cmd = new(AI) default.class;
		Cmd.SummonWave = NewSummonWave;
		Cmd.MaxBossMinions = NewMaxBossMinions;

		if( Cmd != None )
		{
			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	Super.Pushed();
	StopAllLatentMovement();
	Pawn.ZeroMovementVariables();

	DisableMeleeRangeEventProbing();
}

function Popped()
{
	EnableMeleeRangeEventProbing();
	Super.Popped();
}

state Command_SpecialMove
{
	function bool ExecuteSpecialMove()
	{
		local KFAISpawnManager SpawnManager;

		SpawnManager = KFGameInfo(WorldInfo.Game).SpawnManager;
		if ( SpawnManager != none )
		{
			class'AICommand_TauntEnemy'.static.Taunt( outer );
		 	SpawnManager.SummonBossMinions( SummonWave.Squads, MaxBossMinions );
		 	return true;
		}

		return false;
	}
}
