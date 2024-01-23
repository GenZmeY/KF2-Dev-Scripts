class KFVoteCollector extends Object within KFGameReplicationInfo;

/************************************
* @name 	Common Vote Vars
************************************/

struct sVoteInfo
{
	var UniqueNetId PlayerID;
	var PlayerReplicationInfo PlayerPRI;
	var string PlayerIPAddress;
};

var byte VoteTime;
var byte YesVotes;
var byte NoVotes;

/************************************
* @name 	Kick Vote Vars
************************************/

var byte ShortenedTime;
var sVoteInfo CurrentKickVote;
var bool bIsKickVoteInProgress;
var bool bIsFailedVoteTimerActive;
var byte KickedPlayers;
var const int TopResultsToShow;
var const int ActiveTimeUntilVoteEnabled;
//keep track of people that have voted so that they cannot hack and force a player out
var array<PlayerReplicationInfo> PlayersThatHaveVoted;
var byte LastKickVoteYesValue;
var byte LastKickVoteNoValue;
//var array<PlayerReplicationInfo> PlayersReadyToSkipTrader;

/************************************
* @name 	Skip Trader Vote Vars
************************************/

var sVoteInfo CurrentSkipTraderVote;

var int TimeAfterSkipTrader;
var bool bIsSkipTraderVoteInProgress;

var byte LastSkipTraderYesVoteValue;
var byte LastSkipTraderNoVoteValue;
var int SkipTraderVoteLimit;
var int PauseGameVoteLimit;

var byte CurrentVoteTime;

/************************************
* @name 	Map Vote Vars
************************************/

struct MapVote
{
	var Array<PlayerReplicationInfo> VoterPRIList; //the pri of the user that voted
	var int MapIndex; //the map the user voted for
};

struct TopVotes
{
	var string Map1Name;
	var byte Map1Votes;

	var string Map2Name;
	var byte Map2Votes;

	var string Map3Name;
	var byte Map3Votes;

	StructDefaultProperties
	{
		Map1Votes=255
		Map2Votes=255
		Map3Votes=255
	}
};

var bool bAllPlayersVotedOnMap;
var TopVotes TopVotesObject;
var array<MapVote> MapVoteList;
var array<string> MapList;


/************************************
* @name 	Pause Endless Vote Vars
************************************/

var sVoteInfo CurrentPauseGameVote;
var bool bIsPauseGameVoteInProgress;
var byte LastPauseGameYesVoteValue;
var byte LastPauseGameNoVoteValue;

//==============================================================
// @name Kick Vote
//==============================================================

function ServerStartVoteKick(PlayerReplicationInfo PRI_Kickee, PlayerReplicationInfo PRI_Kicker)
{
	local int i;
	local array<KFPlayerReplicationInfo> PRIs;
	local KFGameInfo KFGI;
	local KFPlayerController KFPC, KickeePC;

	KFGI = KFGameInfo(WorldInfo.Game);
	KFPC = KFPlayerController(PRI_Kicker.Owner);
	KickeePC = KFPlayerController(PRI_Kickee.Owner);

	// Kick voting is disabled
	if(KFGI.bDisableKickVote)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteDisabled);
		return;
	}

	// Spectators aren't allowed to vote
	if(PRI_Kicker.bOnlySpectator)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteNoSpectators);
		return;
	}


	// Not enough players to start a vote
	if( KFGI.NumPlayers <= 2 )
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteNotEnoughPlayers);
		return;
	}

	// Maximum number of players kicked per match has been reached
	if( KickedPlayers >= 2 )
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteMaxKicksReached);
		return;
	}

	// Too early in the match to initiate a vote
	/*if(WorldInfo.GRI.ElapsedTime < ActiveTimeUntilVoteEnabled)  //YAY!  We get to remove this!
	{
		if(WorldInfo.GRI.bMatchHasBegun)
		{
			KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteActiveTime);
		}
		else
		{
			KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteMatchNotStarted);	
		}
		
		return;
	}*/

	// Can't kick admins
	if(KFGI.AccessControl != none)
	{
		if(KFGI.AccessControl.IsAdmin(KickeePC))
		{
			KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteAdmin);
			return;
		}
	}

	// Last vote failed, must wait until failed vote cooldown before starting a new vote
	if( bIsFailedVoteTimerActive )
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteRejected);
		return;
	}

	// A kick vote is not allowed while another vote is active
	if(bIsSkipTraderVoteInProgress || bIsPauseGameVoteInProgress)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_OtherVoteInProgress);
		return;
	}

	if( !bIsKickVoteInProgress )
	{
		// Clear voter array
		PlayersThatHaveVoted.Length = 0;

		// Cache off these values in case player leaves before vote ends -- no cheating!
		CurrentKickVote.PlayerID = PRI_Kickee.UniqueId;
		CurrentKickVote.PlayerPRI = PRI_Kickee;
		CurrentKickVote.PlayerIPAddress = KickeePC.GetPlayerNetworkAddress();

		bIsKickVoteInProgress = true;

		GetKFPRIArray(PRIs);
		for (i = 0; i < PRIs.Length; i++)
		{
			PRIs[i].ShowKickVote(PRI_Kickee, VoteTime, !(PRIs[i] == PRI_Kicker || PRIs[i] == PRI_Kickee));
		}
		KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', LMT_KickVoteStarted, CurrentKickVote.PlayerPRI);
		SetTimer( VoteTime, false, nameof(ConcludeVoteKick), self );
		// Cast initial vote
		RecieveVoteKick(PRI_Kicker, true);
	}
	else if(PRI_Kickee == CurrentKickVote.PlayerPRI)
	{
		RecieveVoteKick(PRI_Kicker, false);
	}
	else
	{
		// Can't start a new vote until current one is over
		KFPlayerController(PRI_Kicker.Owner).ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteInProgress);
	}
}

reliable server function RecieveVoteKick(PlayerReplicationInfo PRI, bool bKick)
{
	local KFPlayerController KFPC;

	if(PlayersThatHaveVoted.Find(PRI) == INDEX_NONE)
	{
		//accept their vote
		PlayersThatHaveVoted.AddItem(PRI);
		if(bKick)
		{
			yesVotes++;
		}
		else
		{
			noVotes++;
		}

		KFPC = KFPlayerController(PRI.Owner);
		if(KFPC != none)
		{
			if(bKick)
			{
				KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteYesReceived, CurrentKickVote.PlayerPRI);
			}
			else
			{
				KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_KickVoteNoReceived, CurrentKickVote.PlayerPRI);	
			}
			
		}

		if( ShouldConcludeKickVote() )
		{
			ConcludeVoteKick();
		}
		else
		{
			ReplicateKickVotes();
		}
	}
}

function ReplicateKickVotes()
{
	local KFGameReplicationInfo KFGRI;

	RepKickYesVotes = YesVotes;
	RepKickNoVotes = NoVotes;

	KFGRI = Outer;
	KFGRI.bForceNetUpdate = true;

	`log("Replicate vote count"@RepKickYesVotes@"/"@RepKickNoVotes);

	if(Role == Role_Authority && WorldInfo.NetMode != NM_DedicatedServer)
	{
		UnPackKickVotes();
	}
}

function UnPackKickVotes()
{
	local KFPlayerController KFPC;

	`log("Unpack vote count"@RepKickYesVotes@"/"@RepKickNoVotes);

	if(LastKickVoteYesValue != RepKickYesVotes || LastKickVoteNoValue != RepKickNoVotes)
	{
		NoVotes = RepKickNoVotes;
		YesVotes = RepKickYesVotes;

		//Update UI
		KFPC = KFPlayerController(GetALocalPlayerController());
		if(KFPC != none && KFPC.MyGFxHUD != none)
		{
			KFPC.MyGFxHUD.UpdateKickVoteCount(YesVotes, NoVotes);
		}

		LastKickVoteYesValue = RepKickYesVotes;
		LastKickVoteNoValue = RepKickNoVotes;
	}
}

function bool ShouldConcludeKickVote()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local KFGameInfo KFGI;
	local int NumPRIs;
	local int KickVotesNeeded;

	KFGI = KFGameInfo(WorldInfo.Game);

	GetKFPRIArray(PRIs);
	NumPRIs = PRIs.Length;

	// Current Kickee PRI should not count towards vote percentage
	if( PRIs.Find(CurrentKickVote.PlayerPRI) != INDEX_NONE )
	{
		NumPRIs--;
	}

	if( YesVotes + NoVotes >= NumPRIs )
	{
		return true;
	}
	else if( KFGI != none )
	{
		KickVotesNeeded = FCeil(float(NumPRIs) * KFGI.KickVotePercentage);
		KickVotesNeeded = Clamp(KickVotesNeeded, 1, NumPRIs);

		if( YesVotes >= KickVotesNeeded ) // conclude if vote kick is majority yes
		{
			return true;
		}
		else if( NoVotes > (NumPRIs - KickVotesNeeded) ) // conclude if vote kick can never succeed
		{
			return true;
		}
	}

	return false;
}

reliable server function ConcludeVoteKick()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int i, NumPRIs;
	local KFGameInfo KFGI;
	local KFPlayerController KickedPC;
	local int KickVotesNeeded;

	KFGI = KFGameInfo(WorldInfo.Game);

	if(bIsKickVoteInProgress)
	{
		GetKFPRIArray(PRIs);

		for (i = 0; i < PRIs.Length; i++)
		{
			PRIs[i].HideKickVote();			
		}

		NumPRIs = PRIs.Length;

		// Current Kickee PRI should not count towards vote percentage
		if( PRIs.Find(CurrentKickVote.PlayerPRI) != INDEX_NONE )
		{
			NumPRIs--;
		}

		KickVotesNeeded = FCeil(float(NumPRIs) * KFGI.KickVotePercentage);
		KickVotesNeeded = Clamp(KickVotesNeeded, 1, NumPRIs);

		if( YesVotes >= KickVotesNeeded )
		{
			// See if kicked player has left
			if( CurrentKickVote.PlayerPRI == none || CurrentKickVote.PlayerPRI.bPendingDelete )
			{
				for( i = 0; i < WorldInfo.Game.InactivePRIArray.Length; i++ )
				{
					if( WorldInfo.Game.InactivePRIArray[i].UniqueId == CurrentKickVote.PlayerID )
					{
						CurrentKickVote.PlayerPRI = WorldInfo.Game.InactivePRIArray[i];
						break;
					}
				}
			}


			if(KFGI.AccessControl != none)
			{
				KickedPC = ( (CurrentKickVote.PlayerPRI != none) && (CurrentKickVote.PlayerPRI.Owner != none) ) ? KFPlayerController(CurrentKickVote.PlayerPRI.Owner) : none;
				KFAccessControl(KFGI.AccessControl).KickSessionBanPlayer(KickedPC, CurrentKickVote.PlayerID, KFGI.AccessControl.KickedMsg);
			}
			//tell server to kick target PRI
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', LMT_KickVoteSucceeded, CurrentKickVote.PlayerPRI);

			// Increment number of kicked players this session
			KickedPlayers++;
		}
		else
		{
			//Set timer so that votes cannot be spammed
			bIsFailedVoteTimerActive=true;
			SetTimer( KFGI.TimeBetweenFailedVotes, false, nameof(ClearFailedVoteFlag), self );
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', LMT_KickVoteFailed, CurrentKickVote.PlayerPRI);
		}

		bIsKickVoteInProgress = false;
		CurrentKickVote.PlayerPRI = none;
		CurrentKickVote.PlayerID = class'PlayerReplicationInfo'.default.UniqueId;
		yesVotes = 0;
		noVotes = 0;
	}
}

function ClearFailedVoteFlag()
{
	bIsFailedVoteTimerActive=false;
}

//==============================================================
// @name Skip Trader Vote
//==============================================================

function ServerStartVoteSkipTrader(PlayerReplicationInfo PRI)
{
	local int i;
	local array<KFPlayerReplicationInfo> PRIs;
	local KFGameInfo KFGI;
	local KFPlayerController KFPC;
	local KFGameReplicationInfo KFGRI;
	local byte TraderTimeRemaining;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	KFGI = KFGameInfo(WorldInfo.Game);
	KFPC = KFPlayerController(PRI.Owner);

	// Spectators aren't allowed to vote
	if(PRI.bOnlySpectator)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_SkipTraderVoteNoSpectators);
		return;
	}

	// Trader is not open, we are not allowed to initiate a skip trader vote
	if(!KFGRI.bTraderIsOpen && !KFGRI.bForceShowSkipTrader)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_SkipTraderIsNotOpen);
		return;
	}
	
	// A skip trader vote is not allowed while another vote is active
	if(bIsKickVoteInProgress || bIsPauseGameVoteInProgress)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_OtherVoteInProgress);
		return;
	}
		
	// Not enough time to start a skip trader vote
	TraderTimeRemaining = KFGRI.GetTraderTimeRemaining();
	if(TraderTimeRemaining <= SkipTraderVoteLimit)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_SkipTraderNoEnoughTime);
		return;
	}

	// This user already started a skip trader vote this trader phase
	/*if(PRI.bAlreadyStartedASkipTraderVote)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_SkipTraderThisUserAlreadyStartedAVote);
		return;
	}*/

	if( !bIsSkipTraderVoteInProgress )
	{
		// Clear voter array
		PlayersThatHaveVoted.Length = 0;

		// Cache off these values in case player leaves before vote ends -- no cheating!
		CurrentSkipTraderVote.PlayerID = PRI.UniqueId;
		CurrentSkipTraderVote.PlayerPRI = PRI;
		CurrentSkipTraderVote.PlayerIPAddress = KFPC.GetPlayerNetworkAddress();

		bIsSkipTraderVoteInProgress = true;

		CurrentVoteTime = min(VoteTime, TraderTimeRemaining - SkipTraderVoteLimit);

		GetKFPRIArray(PRIs, , false);
		for (i = 0; i < PRIs.Length; i++)
		{
			PRIs[i].ShowSkipTraderVote(PRI, CurrentVoteTime, !(PRIs[i] == PRI) && PRI.GetTeamNum() != 255);
		}
		KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', LMT_SkipTraderVoteStarted, CurrentSkipTraderVote.PlayerPRI);
		SetTimer( CurrentVoteTime, false, nameof(ConcludeVoteSkipTrader), self );
		SetTimer( 1, true, nameof(UpdateTimer), self );
		// Cast initial vote
		RecieveVoteSkipTrader(PRI, true);

		KFPlayerReplicationInfo(PRI).bAlreadyStartedASkipTraderVote = true;
	}
	else
	{
		// Can't start a new vote until current one is over
		KFPlayerController(PRI.Owner).ReceiveLocalizedMessage(class'KFLocalMessage', LMT_SkipTraderVoteInProgress);
	}
}

reliable server function UpdateTimer()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int i;
	
	CurrentVoteTime -= 1;
	GetKFPRIArray(PRIs, , false);
	for (i = 0; i < PRIs.Length; i++)
	{
		PRIs[i].UpdateSkipTraderTime(CurrentVoteTime);
	}
}

reliable server function RecieveVoteSkipTrader(PlayerReplicationInfo PRI, bool bSkip)
{
	local KFPlayerController KFPC;

	if(PlayersThatHaveVoted.Find(PRI) == INDEX_NONE)
	{
		//accept their vote
		PlayersThatHaveVoted.AddItem(PRI);
		if(bSkip)
		{
			yesVotes++;
		}
		else
		{
			noVotes++;
		}

		KFPC = KFPlayerController(PRI.Owner);
		if(KFPC != none)
		{
			if(bSkip)
			{
				KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_SkipTraderVoteYesReceived);
			}
			else
			{
				KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_SkipTraderVoteNoReceived);	
			}
			
		}

		if( ShouldConcludeSkipTraderVote() )
		{
			ConcludeVoteSkipTrader();
		}
		else
		{
			ReplicateSkipTraderVotes();
		}
	}
}

function ReplicateSkipTraderVotes()
{
	local KFGameReplicationInfo KFGRI;

	RepSkipTraderYesVotes = YesVotes;
	RepSkipTraderNoVotes = NoVotes;

	KFGRI = Outer;
	KFGRI.bForceNetUpdate = true;

	`log("Replicate vote count"@RepSkipTraderYesVotes@"/"@RepSkipTraderNoVotes);

	if(Role == Role_Authority && WorldInfo.NetMode != NM_DedicatedServer)
	{
		UnPackSkipTraderVotes();
	}
}

function UnPackSkipTraderVotes()
{
	local KFPlayerController KFPC;
	
	`log("Unpack vote count"@RepSkipTraderYesVotes@"/"@RepSkipTraderNoVotes);

	if(LastSkipTraderYesVoteValue != RepSkipTraderYesVotes || LastSkipTraderNoVoteValue != RepSkipTraderNoVotes)
	{
		NoVotes = RepSkipTraderNoVotes;
		YesVotes = RepSkipTraderYesVotes;

		//Update UI
		KFPC = KFPlayerController(GetALocalPlayerController());
		if(KFPC != none && KFPC.MyGFxHUD != none)
		{
			KFPC.MyGFxHUD.UpdateSkipTraderVoteCount(YesVotes, NoVotes);
		}

		LastSkipTraderYesVoteValue = RepSkipTraderYesVotes;
		LastSkipTraderNoVoteValue = RepSkipTraderNoVotes;
	}
}

function bool ShouldConcludeSkipTraderVote()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int NumPRIs;

	GetKFPRIArray(PRIs, , false);
	NumPRIs = PRIs.Length;

	if( YesVotes + NoVotes >= NumPRIs || NoVotes > 0 )
	{
		return true;
	}

	return false;
}

reliable server function ConcludeVoteSkipTrader()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int i, NumPRIs;
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);

	if(bIsSkipTraderVoteInProgress)
	{
		GetKFPRIArray(PRIs, , false);

		for (i = 0; i < PRIs.Length; i++)
		{
			PRIs[i].HideSkipTraderVote();			
		}

		NumPRIs = PRIs.Length;
		SetTimer( 0.f, true, nameof(UpdateTimer), self );

		if( NoVotes > 0)
		{
			bIsFailedVoteTimerActive=true;
			SetTimer( KFGI.TimeBetweenFailedVotes, false, nameof(ClearFailedVoteFlag), self );
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', LMT_SkipTraderVoteFailed);
		}
		else if( YesVotes >= NumPRIs )
		{
			//skip trader
			SkipTraderTime();

			//clear everything
			ResetSkipTraderVote();

			//tell server to skip trader
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', LMT_SkipTraderTimeSuccess);
		}
		else
		{
			//Set timer so that votes cannot be spammed
			bIsFailedVoteTimerActive=true;
			SetTimer( KFGI.TimeBetweenFailedVotes, false, nameof(ClearFailedVoteFlag), self );
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', LMT_SkipTraderVoteFailed);
		}

		bIsSkipTraderVoteInProgress = false;
		CurrentSkipTraderVote.PlayerPRI = none;
		CurrentSkipTraderVote.PlayerID = class'PlayerReplicationInfo'.default.UniqueId;
		yesVotes = 0;
		noVotes = 0;
	}
}

reliable server function SkipTraderTime()
{
	local KFGameReplicationInfo KFGRI;
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);
	KFGRI = Outer;

	// shorten time remaining before next wave
	if (KFGRI.RemainingTime > TimeAfterSkipTrader)
	{
		KFGRI.RemainingTime = TimeAfterSkipTrader;
		KFGRI.RemainingMinute = TimeAfterSkipTrader;

		// refresh timer
		KFGI.SkipTrader(TimeAfterSkipTrader);
	}
}

reliable server function ResetSkipTraderVote()
{
	// Reset votes if needed
	// Reset all players so they can request trader next time
}

function ResetSkipTraderBeforeWaveStarts()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int i;

	GetKFPRIArray(PRIs, , false);
	for (i = 0; i < PRIs.Length; i++)
	{
		PRIs[i].bAlreadyStartedASkipTraderVote = false;
	}
}

//==============================================================
// @name Map Vote
//==============================================================

function AddMapOption(string MapOption)
{
	if(WorldInfo.NetMode != NM_Standalone)
	{
		MapList.AddItem(MapOption);
	}
}

function int GetNextMap()
{	
	if(MapVoteList.length > 0)
	{
		return MapVoteList[0].MapIndex;
	}

	return -1;
}

function SearchAndClearPreviousVote(PlayerReplicationInfo PRI)
{
	local int i;
	for (i = 0; i < MapVoteList.length; i++)
	{
		if(MapVoteList[i].VoterPRIList.Find(PRI) != INDEX_NONE)
		{
			MapVoteList[i].VoterPRIList.RemoveItem(PRI);
			return;
		}
	}
}

reliable server function ReceiveVoteMap(PlayerReplicationInfo PRI, int MapIndex)
{
	local int  i;
	local bool bMapFound;
	local MapVote TempMapVote;
	local array<KFPlayerReplicationInfo> PRIs;
	local KFGameInfo KFGI;

	GetKFPRIArray(PRIs);

	if(MapVoteList.length > 0)
	{
		SearchAndClearPreviousVote(PRI);

		//Search to see if this user has voted already
		for (i = 0; i < MapVoteList.length; i++)
		{
			if(MapVoteList[i].MapIndex == MapIndex)
			{
				bMapFound = true;
				MapVoteList[i].VoterPRIList.AddItem(PRI);
				break;
			}
		}
	}

	if(!bMapFound)
	{
		TempMapVote.MapIndex = MapIndex;
		TempMapVote.VoterPRIList.AddItem(PRI);
		MapVoteList.AddItem(TempMapVote);
	}

	//Sort Map list 
	MapVoteList.Sort(MapVoteSort);

	KFGI = KFGameInfo(WorldInfo.Game);
	for (i = 0; i < TopResultsToShow; i++)
	{
		if(i < MapVoteList.length)
		{
			switch (i)
			{
				case 0:
					TopVotesObject.Map1Votes = MapVoteList[i].VoterPRIList.length;
					if(WorldInfo.NetMode == NM_StandAlone)
					{
						TopVotesObject.Map1Name = MapList[MapIndex];
					}
					else
					{
						TopVotesObject.Map1Name = KFGI.GameMapCycles[KFGI.ActiveMapCycle].Maps[MapVoteList[i].MapIndex];
					}
					
					if(CheckMajorityPlayersVotedOnMap(PRIs, MapVoteList[i].VoterPRIList.length))
					{
						ShortenVoteTime(KFGI);
					}
					break;
			
				case 1:
					TopVotesObject.Map2Votes = MapVoteList[i].VoterPRIList.length;
					if(WorldInfo.NetMode == NM_StandAlone)
					{
						TopVotesObject.Map2Name = MapList[MapIndex];
					}
					else
					{
						TopVotesObject.Map2Name = KFGI.GameMapCycles[KFGI.ActiveMapCycle].Maps[MapVoteList[i].MapIndex];
					}
					
					break;
					
				case 2:
					TopVotesObject.Map3Votes = MapVoteList[i].VoterPRIList.length;
					if(WorldInfo.NetMode == NM_StandAlone)
					{
						TopVotesObject.Map3Name = MapList[MapIndex];
					}
					else
					{
						TopVotesObject.Map3Name = KFGI.GameMapCycles[KFGI.ActiveMapCycle].Maps[MapVoteList[i].MapIndex];
					}
					
					break;					
			}
		}
	}

	//Send out top 3 votes
	for(i = 0; i < PRIs.length; i++)
	{
		PRIs[i].RecieveTopMaps(TopVotesObject);
	}

	if(CheckAllPlayerVoted(PRIs))
	{
		ShortenVoteTime(KFGI);
	}
}

function ShortenVoteTime(KFGameInfo KFGI)
{
	if( !bAllPlayersVotedOnMap && KFGI != none)
	{
		bAllPlayersVotedOnMap = true;
		KFGI.UpdateCurrentMapVoteTime(ShortenedTime, true);
	}
}

function bool CheckMajorityPlayersVotedOnMap(out array<KFPlayerReplicationInfo> PRIs, int NumOfVotesOnMap)
{
	local float VotePercentage;

	VotePercentage = Float(NumOfVotesOnMap) / Float(PRIs.Length);

	return VotePercentage > 0.5f;
}

function bool CheckAllPlayerVoted(out array<KFPlayerReplicationInfo> PRIs)
{
	local int i, j, PlayerVoteCount;
	for (i = 0; i < PRIs.length; i++)
	{
		for (j = 0; j < MapVoteList.length; j++)
		{
			if(MapVoteList[j].VoterPRIList.Find(PRIs[i]) != INDEX_NONE)
			{
				PlayerVoteCount++;
			}
		}
	}

	return PlayerVoteCount >= PRIs.length;
}

function int MapVoteSort(MapVote A, MapVote B)
{
	local int Result;

	if (A.VoterPRIList.Length == B.VoterPRIList.Length)
	{
		Result = 0;
	}
	else 
	{
		Result = A.VoterPRIList.Length > B.VoterPRIList.Length ? 1 : -1;
	}

	return Result;
}

//==============================================================
// @name Pause Vote
//==============================================================

function ServerStartVotePauseGame(PlayerReplicationInfo PRI)
{
	local int i;
	local array<KFPlayerReplicationInfo> PRIs;
	local KFGameInfo KFGI;
	local KFPlayerController KFPC;
	local KFGameReplicationInfo KFGRI;
	local byte WaveTimeRemaining;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	KFGI  = KFGameInfo(WorldInfo.Game);
	KFPC  = KFPlayerController(PRI.Owner);

	// Spectators aren't allowed to vote
	if(PRI.bOnlySpectator)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteNoSpectators : LMT_PauseVoteNoSpectators);
		return;
	}

	// Only pause the game if there's no wave active
	if(KFGRI.bWaveIsActive)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteWaveActive : LMT_PauseVoteWaveActive);
		return;
	}
	
	if(!KFGRI.bEndlessMode)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_PauseVoteWrongMode);
		return;
	}

	// A pause vote is not allowed while another vote is active
	if(bIsKickVoteInProgress || bIsSkipTraderVoteInProgress)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', LMT_OtherVoteInProgress);
		return;
	}

	WaveTimeRemaining = KFGRI.GetTraderTimeRemaining();
	if(WaveTimeRemaining <= PauseGameVoteLimit)
	{
		KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteNoEnoughTime : LMT_PauseVoteNoEnoughTime);
		return;
	}

	if( !bIsPauseGameVoteInProgress )
	{
		// Clear voter array
		PlayersThatHaveVoted.Length = 0;

		// Cache off these values in case player leaves before vote ends -- no cheating!
		CurrentPauseGameVote.PlayerID = PRI.UniqueId;
		CurrentPauseGameVote.PlayerPRI = PRI;
		CurrentPauseGameVote.PlayerIPAddress = KFPC.GetPlayerNetworkAddress();

		bIsPauseGameVoteInProgress = true;

		CurrentVoteTime = min(VoteTime, WaveTimeRemaining - PauseGameVoteLimit);

		GetKFPRIArray(PRIs);
		for (i = 0; i < PRIs.Length; i++)
		{
			PRIs[i].ShowPauseGameVote(PRI, CurrentVoteTime, !(PRIs[i] == PRI));
		}

		KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteStarted : LMT_PauseVoteStarted, CurrentPauseGameVote.PlayerPRI);
		SetTimer( CurrentVoteTime, false, nameof(ConcludeVotePauseGame), self );
		SetTimer( 1, true, nameof(UpdatePauseGameTimer), self );
		// Cast initial vote
		ReceiveVotePauseGame(PRI, true);

		KFPlayerReplicationInfo(PRI).bAlreadyStartedAPauseGameVote = true;
	}
	else
	{
		// Can't start a new vote until current one is over
		KFPlayerController(PRI.Owner).ReceiveLocalizedMessage(class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteInProgress : LMT_PauseVoteInProgress);
	}
}

reliable server function UpdatePauseGameTimer()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int i;
	
	CurrentVoteTime -= 1;
	GetKFPRIArray(PRIs);
	for (i = 0; i < PRIs.Length; i++)
	{
		PRIs[i].UpdatePauseGameTime(CurrentVoteTime);
	}
}

reliable server function ReceiveVotePauseGame(PlayerReplicationInfo PRI, bool bSkip)
{
	local KFPlayerController KFPC;
	local KFGameReplicationInfo KFGRI;

	if(PlayersThatHaveVoted.Find(PRI) == INDEX_NONE)
	{
		//accept their vote
		PlayersThatHaveVoted.AddItem(PRI);
		if(bSkip)
		{
			yesVotes++;
		}
		else
		{
			noVotes++;
		}

		KFPC = KFPlayerController(PRI.Owner);
		if(KFPC != none)
		{
			KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
			if(bSkip)
			{
				KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteYesReceived : LMT_PauseVoteYesReceived);
			}
			else
			{
				KFPC.ReceiveLocalizedMessage(class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteNoReceived : LMT_PauseVoteNoReceived);	
			}
		}

		if( ShouldConcludePauseGameVote() )
		{
			ConcludeVotePauseGame();
		}
		else
		{
			ReplicatePauseGameVotes();
		}
	}
}

function ReplicatePauseGameVotes()
{
	local KFGameReplicationInfo KFGRI;

	RepPauseGameYesVotes = YesVotes;
	RepPauseGameNoVotes  = NoVotes;

	KFGRI = Outer;
	KFGRI.bForceNetUpdate = true;

	if(Role == Role_Authority && WorldInfo.NetMode != NM_DedicatedServer)
	{
		UnPackPauseGameVotes();
	}
}

function UnPackPauseGameVotes()
{
	local KFPlayerController KFPC;
	
	if(LastPauseGameYesVoteValue != RepPauseGameYesVotes || LastPauseGameNoVoteValue != RepPauseGameNoVotes)
	{
		NoVotes  = RepPauseGameNoVotes;
		YesVotes = RepPauseGameYesVotes;

		//Update UI
		KFPC = KFPlayerController(GetALocalPlayerController());
		if(KFPC != none && KFPC.MyGFxHUD != none)
		{
			KFPC.MyGFxHUD.UpdatePauseGameVoteCount(YesVotes, NoVotes);
		}

		LastPauseGameYesVoteValue = RepPauseGameYesVotes;
		LastPauseGameNoVoteValue  = RepPauseGameNoVotes;
	}
}

function bool ShouldConcludePauseGameVote()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int NumPRIs;

	GetKFPRIArray(PRIs);
	NumPRIs = PRIs.Length;
	
	if( YesVotes + NoVotes >= NumPRIs || NoVotes > 0 )
	{
		return true;
	}

	return false;
}

reliable server function ConcludeVotePauseGame()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int i;
	local KFGameInfo KFGI;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	KFGI  = KFGameInfo(WorldInfo.Game);

	if(bIsPauseGameVoteInProgress)
	{
		GetKFPRIArray(PRIs);

		for (i = 0; i < PRIs.Length; i++)
		{
			PRIs[i].HidePauseGameVote();			
		}

		SetTimer( 0.f, true, nameof(UpdatePauseGameTimer), self );

		if( NoVotes > 0)
		{
			bIsFailedVoteTimerActive=true;
			SetTimer( KFGI.TimeBetweenFailedVotes, false, nameof(ClearFailedVoteFlag), self );
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteFailed : LMT_PauseVoteFailed);
		}
		else if( YesVotes >= KFGameInfo(WorldInfo.Game).NumPlayers )
		{

			//pause game
			if (KFGRI.bIsEndlessPaused)
			{
				KFGRI.bIsEndlessPaused = false;
				KFGRI.bStopCountDown   = false;
				KFGI.ResumeEndlessGame();
			}
			else
			{
				KFGRI.bIsEndlessPaused = true;
				KFGRI.bStopCountDown   = true;
				KFGI.PauseEndlessGame();
			}
			
			//clear everything
			ResetPauseGameVote();

			//tell server to skip trader
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage',  KFGRI.bIsEndlessPaused ? LMT_PauseVoteSuccess : LMT_ResumeVoteSuccess);
		}
		else
		{
			//Set timer so that votes cannot be spammed
			bIsFailedVoteTimerActive=true;
			SetTimer( KFGI.TimeBetweenFailedVotes, false, nameof(ClearFailedVoteFlag), self );
			KFGI.BroadcastLocalized(KFGI, class'KFLocalMessage', KFGRI.bIsEndlessPaused ? LMT_ResumeVoteFailed : LMT_PauseVoteFailed);
		}

		bIsPauseGameVoteInProgress = false;
		CurrentPauseGameVote.PlayerPRI = none;
		CurrentPauseGameVote.PlayerID = class'PlayerReplicationInfo'.default.UniqueId;
		yesVotes = 0;
		noVotes = 0;
	}
}

reliable server function ResetPauseGameVote()
{
	local array<KFPlayerReplicationInfo> PRIs;
	local int i;

	GetKFPRIArray(PRIs);
	for (i = 0; i < PRIs.Length; i++)
	{
		PRIs[i].bAlreadyStartedASkipTraderVote = false;
	}
}

function ServerNotifyDisconnect()
{
	local KFGameReplicationInfo KFGRI;
	KFGRI = Outer;

	if (bIsPauseGameVoteInProgress && KFGRI.bIsEndlessPaused && (YesVotes + NoVotes >=  KFGameInfo(WorldInfo.Game).NumPlayers))
	{
		ConcludeVotePauseGame();
	}
}

DefaultProperties
{
	VoteTime=30
	ShortenedTime=10
	TopResultsToShow=3
	bIsFailedVoteTimerActive=false
	ActiveTimeUntilVoteEnabled=30
	KickedPlayers=0
	TimeAfterSkipTrader=5//seconds
	SkipTraderVoteLimit=5//seconds
	PauseGameVoteLimit=1
}