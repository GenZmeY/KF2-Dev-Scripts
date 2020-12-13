//=============================================================================
// KFTeamInfo_Human
//=============================================================================
// KFTeamInfo_Human
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFTeamInfo_Human extends TeamInfo;

struct sTeamScoreData
{
	/** Total score for this team */
	var int RoundScore;

	/** Stat tracking for end-of-match scoring */
	var int WaveBonus;
	var int Deaths;
	var int BossDamageDone;
	var int BossDamageTaken;

	StructDefaultProperties
	{
		WaveBonus=-1
	}
};

/**
 * Since this is only changed once and we are bOnlyDirtyReplication,
 * it's fine to include this in the replication block
 */
var sTeamScoreData TeamScoreDataPacket;

replication
{
	if( bNetDirty )
		TeamScoreDataPacket;
}

simulated function PostBeginPlay()
{
	super.PostBeginPlay();

	if( Role == ROLE_Authority )
	{
		//force a replication since we are putting team index in default properties.
		bForceNetUpdate = true;
		bNetDirty = true;
	}
	else if( TeamIndex >= 0 )
	{
		if (WorldInfo.GRI != None)
		{
			// register this TeamInfo instance now
			WorldInfo.GRI.SetTeam(TeamIndex, self);
		}
		else
		{
			// Spawned before GRI, wait a short time before trying again
			SetTimer( 0.1, true, nameOf(Timer_WaitingForGRI) );
		}
	}
}

simulated function Timer_WaitingForGRI()
{
	if( WorldInfo.GRI != none )
	{
		WorldInfo.GRI.SetTeam( TeamIndex, self );
		ClearTimer( nameOf(Timer_WaitingForGRI) );
	}
}

function bool AddToTeam( Controller Other )
{
	// Update immediately on network for UI snappyness
	bNetDirty = true;
	bForceNetUpdate = true;
	return super.AddToTeam( Other );
}

function RemoveFromTeam(Controller Other)
{
	// Update immediately on network for UI snappyness
	bNetDirty = true;
	bForceNetUpdate = true;
	super.RemoveFromTeam( Other );
}

simulated function string GetHumanReadableName()
{
    // Temp team name hax - Ramm
    return class'KFCommon_LocalizedStrings'.default.HumanString @TeamName;
}

function AddScore( int ScoreToAdd, optional bool bSetScore )
{
	if( bSetScore )
	{
		Score = ScoreToAdd;
	}
	else
	{
		Score += ScoreToAdd;
	}
}

function AddRoundScore( int ScoreToAdd, optional bool bSetScore )
{
	if( bSetScore )
	{
		TeamScoreDataPacket.RoundScore = ScoreToAdd;
	}
	else
	{
		TeamScoreDataPacket.RoundScore += ScoreToAdd;
	}
}

function Reset()
{
	Score = 0;
}

DefaultProperties
{
	TeamIndex=0
	NetUpdateFrequency=1
}