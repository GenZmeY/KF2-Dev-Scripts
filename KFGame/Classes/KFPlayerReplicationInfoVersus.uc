//=============================================================================
// KFPlayerReplicationInfoVersus
//=============================================================================
// PlayerReplicationInfo for Versus mode
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPlayerReplicationInfoVersus extends KFPlayerReplicationInfo
	config(Game)
	native(ReplicationInfo)
	nativereplication
	dependson(KFVoteCollector);

/** Total number of successful grab-type attacks done in this match */
var int KillsAsZed;

/** Total number of successful grab-type attacks done in this match */
var int AssistsAsZed;

/** Total number of successful grab-type attacks done in this match */
var int DamageDealtAsZed;

/** Total number of successful grab-type attacks done in this match */
var int ZedGrabs;

/** Total amount of indirect damage dealt this match (bloat mines, crawler gas, etc) */
var int IndirectDamageDealt;

/** Number of kills per wave */
var array<int> WaveKills;

cpptext
{
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	UBOOL IsTeamReplicationViewer( BYTE TeamNum );
}

simulated function Pawn GetOwnerPawn()
{
	local Pawn aPawn;

	// Set owning pawn
	foreach WorldInfo.AllPawns( class'Pawn', aPawn )
	{
		if( aPawn.PlayerReplicationInfo == self )
		{
			return aPawn;
		}
	}

	return none;
}

function SetPlayerTeam( TeamInfo NewTeam )
{
	super.SetPlayerTeam( NewTeam );

	if( NewTeam == none )
	{
		return;
	}

	SetTimer( 1.f, true, nameOf(UpdateReplicatedVariables) );
}

reliable server function ServerSwitchTeam()
{
	local KFGameInfo MyGameInfo;
	local KFGameReplicationInfo KFGRI;

	MyGameInfo = KFGameInfo(WorldInfo.Game);
	if( MyGameInfo == none )
	{
		return;
	}

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI == None || !KFGRI.bAllowSwitchTeam )
	{
		return;
	}

	if( KFGRI.bMatchHasBegun )
	{
		//will this switch upset current game balance?
		if(!WillMaintainTeamBalance())
		{
			ClientRefusedTeamSwitch();
			return;
		}
		PlayerController(Owner).Pawn.Suicide();
	}

	switch( GetTeamNum() )
	{
		case MyGameInfo.Teams[0].TeamIndex:
			MyGameInfo.SetTeam( PlayerController(Owner), MyGameInfo.Teams[1] );
			break;

		case MyGameInfo.Teams[1].TeamIndex:
				MyGameInfo.SetTeam( PlayerController(Owner), MyGameInfo.Teams[0] );
			break;

		default:
			`log("Function: KFPlayerReplicationInfo::ServerSwitchTeam Team index not accounted for - " @GetTeamNum());
	}

	if(PlayerController(Owner).IsLocalController() && Role == Role_Authority)
	{
		ClientRecieveNewTeam();
	}
}

//SERVER ONLY
function bool WillMaintainTeamBalance()
{
	local KFGameInfo MyGameInfo;
	local KFGameReplicationInfo KFGRI;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	MyGameInfo = KFGameInfo(WorldInfo.Game);
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI.bMatchHasBegun)
	{		//dead 					//human
		if( KFPC.Pawn == none && GetTeamNum() == 0 )
		{
			//dead return false
			return false;
		}

		switch( GetTeamNum() )
		{
			case MyGameInfo.Teams[0].TeamIndex:
				//the team i want to go to is smaller than my current team  AND the desired team is also smaller than half the allowed max players
				return MyGameInfo.Teams[1].Size < MyGameInfo.Teams[0].Size  && MyGameInfo.Teams[1].Size < (MyGameInfo.MaxPlayersAllowed / 2);

			case MyGameInfo.Teams[1].TeamIndex:
				return MyGameInfo.Teams[0].Size < MyGameInfo.Teams[1].Size  && MyGameInfo.Teams[0].Size < (MyGameInfo.MaxPlayersAllowed / 2);
			default:
				`log("Function: KFPlayerReplicationInfo::WillUpsetTeamBalance Team index not accounted for - " @GetTeamNum());
		}
	}

	return true;
}

reliable client function ClientRefusedTeamSwitch()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);
	if(KFPC != none && KFPC.IsLocalController())
	{
		if(KFPC.MyGFxManager != none && KFPC.MyGFxManager.bMenusOpen)
		{
			KFPC.MyGFxManager.DelayedOpenPopup(ENotification, EDPPID_SwitchTeams, class'KFCommon_LocalizedStrings'.default.UnableToSwitchTeamString, class'KFCommon_LocalizedStrings'.default.NoSwitchReasonString, class'KFCommon_LocalizedStrings'.default.OKString);
		}
		else if(KFPC.MyGFxHUD != none )
		{
			KFPC.MyGFxHUD.ShowNonCriticalMessage(class'KFCommon_LocalizedStrings'.default.NoSwitchReasonString);
		}
	}

}

reliable client function ClientRecieveNewTeam()
{
	local KFGameReplicationInfo KFGRI;
	local KFGFxHudWrapper MyGFxHUD;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);
	if( KFPC != none && KFPC.IsLocalController() )
	{
		MyGFxHud = KFGFxHudWrapper( KFPC.MyHUD );
		if( MyGFxHud != none )
		{
			KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
			if( KFGRI.bMatchHasBegun && KFPC.PlayerReplicationInfo.bReadyToPlay )
			{
				MyGFxHud.CreateHUDMovie( true );
			}
		}

		KFPC.ClientRecieveNewTeam();
	}
}

simulated function VOIPStatusChanged( PlayerReplicationInfo Talker, bool bIsTalking )
{
	if(Talker.GetTeamNum() != GetTeamNum())
	{
		return;
	}

	super.VOIPStatusChanged(Talker, bIsTalking);
}


function RecordEndGameInfo()
{
	local KFPlayerController KFPC;

	if(GetTeamNum() == 255)
	{
		KFPC = KFPlayerController(Owner);
		if( KFPC != none && KFPC.MatchStats != none )
		{
			KillsAsZed = Kills;
			AssistsAsZed = Assists;
			DamageDealtAsZed = KFPC.MatchStats.TotalDamageDealt;
		}
	}
}

/** Increment total death count on survivor team */
function IncrementDeaths(optional int Amt = 1)
{
	local KFGameInfo MyGameInfo;

	super.IncrementDeaths( Amt );

	if( bReadyToPlay && !bWaitingPlayer && WorldInfo.GRI.bMatchHasBegun && !WorldInfo.GRI.bMatchIsOver && GetTeamNum() == 0 )
	{
		MyGameInfo = KFGameInfo(WorldInfo.Game);
		if( MyGameInfo != none )
		{
			MyGameInfo.HumanDeaths += Amt;
		}
	}
}

/* Reset()
reset actor to initial state - used when restarting level without reloading.
*/
function Reset()
{
	local bool bPrevWaitingPlayer, bPrevReadyToPlay;

	Assists = 0;

	bPrevWaitingPlayer = bWaitingPlayer;
	bPrevReadyToPlay = bReadyToPlay;

	super.Reset();

	bWaitingPlayer = bPrevWaitingPlayer;
	bReadyToPlay = bPrevReadyToPlay;
}

reliable client function ShowKickVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
	super.ShowKickVote(PRI, VoteDuration, bShowChoices && (PRI.GetTeamNum() == GetTeamNum()));
}

reliable client function ShowSkipTraderVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
	super.ShowSkipTraderVote(PRI, VoteDuration, bShowChoices && (PRI.GetTeamNum() != GetTeamNum()));
}

// Override for not allowing skip trader as enemy
simulated function RequestSkiptTrader(PlayerReplicationInfo PRI)
{
	if (GetTeamNum() != 255)
	{
		super.RequestSkiptTrader(PRI);
	}
}

defaultproperties
{
	bReplicateInstigator=false
}