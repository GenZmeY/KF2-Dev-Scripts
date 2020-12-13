//=============================================================================
// KFGameInfo_VersusSurvival
//=============================================================================
// The game mode class for players vs zeds survival game type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================
class KFGameInfo_VersusSurvival extends KFGameInfo_Survival;

/** The maximum global number of puke mines that can be active in play */
const MAX_ACTIVE_PUKE_MINES = 30;

/** Anti-griefing system */
var protected const float ANTI_GRIEF_DELAY;
var protected const float ANTI_GRIEF_INTERVAL;
var protected const float ANTI_GRIEF_DAMAGE_PERCENTAGE;

/** Zed pawn classes used by players */
var protected const array<class<KFPawn_Monster> > PlayerZedClasses;
var protected const array<class<KFPawn_Monster> > PlayerBossClassList;

/** Cached reference to versus gamereplicationinfo */
var KFGameReplicationInfoVersus MyKFGRIV;

/** Damagetype used for anti-griefing system */
var class<KFDamageType> AntiGriefDamageTypeClass;

/** Whether auto team balance is enabled */
var config bool bTeamBalanceEnabled;

/** Radius around a damaged zed to award score to player zeds */
var config float ScoreRadius;

/** The delay at the end of a game before auto-switching to the next round */
var int TimeUntilNextRound;

/** The delay after a round is over before opening the round results screen */
var float RoundEndCinematicDelay;

/** Cooldown period after the round results menu is closed but before spawning starts */
var float PostRoundWaitTime;

/** Stat tracking for scoring */
var protected int WaveBonus;
var protected int BossDamageDone;
var protected int BossSurvivorDamageTaken;
var protected float PercentOfZedsKilledBeforeWipe;

/**
 * DLO (by string) content classes specific to this game type
 * - Use when direct ref loading is not possible (e.g. unused GameInfo is loaded)
 * - Class refs can be cached using the supplied GRI
 */
static function PreloadGlobalContentClasses()
{
	local class<KFPawn_Monster> PawnClass;

	super.PreloadGlobalContentClasses();

	foreach default.PlayerZedClasses(PawnClass)
	{
		PawnClass.static.PreloadContent();
	}
}

event PreBeginPlay()
{
	super.PreBeginPlay();

	// Create the zed team
	CreateTeam(1);
}

function InitGRIVariables()
{
    super.InitGRIVariables();

    MyKFGRIV = KFGameReplicationInfoVersus( MyKFGRI );
    MyKFGRIV.bTeamBalanceEnabled = bTeamBalanceEnabled;
}

function bool IsPlayerReady( KFPlayerReplicationInfo PRI )
{
    // Spawn our player even if we don't have a perk while using the editor or skip lobby
    if (class'KFGameEngine'.static.CheckSkipLobby() || class'Engine'.static.IsEditor())
    {
        return true;
    }

    return super(KFGameInfo).IsPlayerReady(PRI);
}

function StartMatch()
{
	local KFPlayerController KFPC;
	local array<KFPlayerController> PlayerControllers;

	// Get a list of players
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		PlayerControllers[PlayerControllers.Length] = KFPC;
        if( KFPC.GetTeamNum() == 255 && KFPC.CanRestartPlayer() && (KFPC.Pawn == none || KFPawn_Customization(KFPC.Pawn) != none) )
        {
            if( KFPC.Pawn != none )
            {
                KFPC.Pawn.Destroy();
            }

            KFPC.StartSpectate();
        }
	}

    // If there's only one player, we must spawn them in as human
    if( PlayerControllers.Length == 1 )
    {
        SetTeam( PlayerControllers[0], Teams[0] );
    }

    // Clear round over flag
    MyKFGRIV.bRoundIsOver = false;
    MyKFGRIV.bNetDirty = true;
    MyKFGRIV.bForceNetUpdate = true;

	super.StartMatch();
}

function bool ShouldStartMatch()
{
`if(`notdefined(ShippingPC))
    if( bWaitForNetPlayers && WorldInfo.NetMode != NM_Standalone )
    {
        return NumPlayers >= 1;
    }
    return true;
`endif

    return ( WorldInfo.NetMode == NM_StandAlone || (Teams[0].Size > 0 && Teams[1].Size > 0) );
}

function StripAbsentPlayers()
{
	local int GroupIndex, PlayerIndex;
	local UniqueNetId StupidUnrealBS;

	`log("StripAbsentPlayers: Stripping players who are no longer logged in from matchmaking groups.", bLogGroupTeamBalance);
	for (GroupIndex = PlayerGroups.length - 1; GroupIndex >= 0; --GroupIndex)
	{
		for (PlayerIndex = PlayerGroups[GroupIndex].PlayerGroup.Length - 1; PlayerIndex >= 0; --PlayerIndex)
		{
			if (GetPRIById(PlayerGroups[GroupIndex].PlayerGroup[PlayerIndex]) == none)
			{
				if (bLogGroupTeamBalance)
				{
					StupidUnrealBS = PlayerGroups[GroupIndex].PlayerGroup[PlayerIndex];
					`log("StripAbsentPlayers: Removing player" @ class'OnlineSubsystem'.static.UniqueNetIdToString(StupidUnrealBS) @ "from group" @ GroupIndex @ "because they are no longer logged in.", bLogGroupTeamBalance );
				}
				PlayerGroups[GroupIndex].PlayerGroup.Remove(PlayerIndex, 1);
			}
		}
		if (PlayerGroups[GroupIndex].PlayerGroup.length == 0)
		{
			`log("StripAbsentPlayers: Removing empty matchmaking group " @ GroupIndex @ "from group list because it is empty.", bLogGroupTeamBalance );
			PlayerGroups.Remove(GroupIndex, 1);
		}
	}
}

function SplitArrayByTeam(out PlayerGroupStruct Group, out PlayerGroupStruct Other)
{
	local int i;
	local PlayerReplicationInfo PRI;
	local UniqueNetId StupidUnrealscriptBS;

	//Clear out the Other struct
	Other.PlayerGroup.length = 0;
	Other.Team = Group.Team == 1 ? 0 : 1;

	//The group should have a team by now, but doublecheck and clear it out
	//if it doesn't and quit
	if (Group.Team == 128)
	{
		`log("SplitArrayByTeam: Aborting and removing group because it hasn't yet been assigned a team.");
		Other.Team = 128;
		Group.PlayerGroup.length = 0;
		return;
	}
	//Iterate backwards because that makes the logic of removing an item simpler
	for (i = Group.PlayerGroup.length - 1; i >= 0; --i)
	{
		PRI = GetPRIById(Group.PlayerGroup[i]);
		//Check again that the player in the group is still connected
		if (PRI == none)
		{
			if (bLogGroupTeamBalance)
			{
				StupidUnrealscriptBS = Group.PlayerGroup[i];
				`log("SplitArrayByTeam: Removing player" @ class'OnlineSubsystem'.static.UniqueNetIdToString(StupidUnrealscriptBS) @ "from group because they are not logged in.");
			}
			Group.PlayerGroup.Remove(i, 1);
			continue;
		}
		//If the team they're currently in doesn't match the one they were assigned, put them into
		//the other player group with the other team
		if (PRI.Team != Teams[Group.Team])
		{
			if (bLogGroupTeamBalance)
			{
				StupidUnrealscriptBS = Group.PlayerGroup[i];
				`log("SplitArrayByTeam: Moving player" @ class'OnlineSubsystem'.static.UniqueNetIdToString(StupidUnrealscriptBS) @ "from group in team" @ Group.Team @ "to group in team" @ Other.Team @ "because they chose that team");
			}
			Other.PlayerGroup.AddItem(Group.PlayerGroup[i]);
			Group.PlayerGroup.Remove(i, 1);
		}
	}
}

function SplitGroups()
{
	//if players have chosen to be in different teams, consider them as singles or separate groups
	//for balancing purposes
	local int i;
	local PlayerGroupStruct NewGroup;
	local PlayerGroupStruct StupidUnrealscriptBS;

	`log("SplitGroups: Splitting groups with players on separate teams.", bLogGroupTeamBalance);

	//iterate from end to make adding and removing elements logic simpler
	for (i = PlayerGroups.length - 1; i >= 0; --i)
	{
		StupidUnrealscriptBS = PlayerGroups[i];
		SplitArrayByTeam(StupidUnrealscriptBS, NewGroup);
		PlayerGroups[i] = StupidUnrealscriptBS;
		if (PlayerGroups[i].PlayerGroup.length < 2)
		{
			if (NewGroup.PlayerGroup.length > 1)
			{
				`log("SplitGroups: Changing group number" @ i @ "from team" @ PlayerGroups[i].Team @ "to team" @ NewGroup.Team @ "(now has" @ NewGroup.PlayerGroup.length @ "members).", bLogGroupTeamBalance);
				PlayerGroups[i] = NewGroup;
			}
			else
			{
				`log("SplitGroups: Removing empty group number" @ i, bLogGroupTeamBalance);
				PlayerGroups.Remove(i,1);
			}
		}
		else
		{
			if (NewGroup.PlayerGroup.length > 0)
			{
				`log("SplitGroups: Adding a new group of team" @ NewGroup.Team @ "at position" @ i+1 @ "with" @ NewGroup.PlayerGroup.length @ "members.", bLogGroupTeamBalance);
				PlayerGroups.Insert(i+1, 1);
				PlayerGroups[i+1] = NewGroup;
			}
		}
	}
}

//Returns human team size - zed team size
function int GetDelta()
{
	return Teams[0].Size - Teams[1].Size;
}

//Returns true if the game is playable (neither team over 6) by only moving players not in a group
//AdditionalDelta is number moved from Zed to Human team, negative for the other direction
function bool IsBalanceable(int NumHumanSingles, int NumZedSingles, optional int AdditionalDelta = 0)
{
	if (Teams[0].Size > 0 && Teams[0].Size <= `KF_MAX_PLAYERS && Teams[1].Size <= `KF_MAX_PLAYERS)
	{
		return true;
	}
	if (Teams[0].Size - NumHumanSingles + AdditionalDelta > `KF_MAX_PLAYERS || Teams[1].Size - NumZedSingles - AdditionalDelta > `KF_MAX_PLAYERS)
	{
		return false;
	}
	return true;
}

//Returns true if it's possible to play a Versus match with the current team balance
//Does not mean balance is optimal (Delta within
function bool IsLegal()
{
	return Teams[0].Size > 0 && Teams[0].Size <= `KF_MAX_PLAYERS && Teams[1].Size <= `KF_MAX_PLAYERS;
}

//Moves single players from team to team until they are equal or within one of each other
//If bTryAnyway is false, will do nothing if they can't be balanced within 1
//If bTryAnyway is true, will get as close as possible
//Returns true if any players were moved or the teams already within 1
function bool BalanceSingles(out array<PlayerReplicationInfo> HumanSingles, out array<PlayerReplicationInfo> ZedSingles, optional bool bTryAnyway = false)
{
	local int Delta;
	local bool rc;


	if (!IsBalanceable(HumanSingles.length, ZedSingles.length) && !bTryAnyway)
	{
		return false;
	}

	Delta = GetDelta();

	if (abs(Delta) <= 1)
	{
		return true;
	}

	rc = false;
	if (Delta < 0)
	{
		while (ZedSingles.length > 0 && Delta < 0)
		{
			SwapTeamFor(ZedSingles[ZedSingles.length-1]);
			ZedSingles.Remove(ZedSingles.length-1, 1);
			Delta = GetDelta();
			rc = true;
		}
	}
	else
	{
		while (HumanSingles.length > 0 && Delta > 0)
		{
			SwapTeamFor(HumanSingles[HumanSingles.length-1]);
			HumanSingles.Remove(HumanSingles.length-1, 1);
			Delta = GetDelta();
			rc = true;
		}
	}
	return rc;
}

function BalanceTeams()
{
    local int Delta;
    local PlayerReplicationInfo PRI;
	local array<PlayerReplicationInfo> HumanSingles, ZedSingles;

	StripAbsentPlayers();
	SplitGroups();

	Delta = Teams[0].Size - Teams[1].Size;
    if ( Delta == 0 )
        return;

	foreach MyKFGRIV.PRIArray(PRI)
	{
		if (GetPRIById(PRI.UniqueId) == none)
		{
			if (PRI.Team == Teams[0])
			{
				HumanSingles.AddItem(PRI);
			}
			else
			{
				ZedSingles.AddItem(PRI);
			}
		}
	}
	if (BalanceSingles(HumanSingles, ZedSingles))
	{
		return;
	}
	else
	{
		BalanceTeamsOld();
	}
}

function BalanceTeamsOld()
{
    local int Delta, AutoBalanceRemaining, i;
    local TeamInfo TI;
    local Array<PlayerReplicationInfo> AutoBalanceList;
    local PlayerReplicationInfo PRI;

    Delta = Teams[1].Size - Teams[0].Size;
    if ( Delta == 0 )
        return;

    TI = (Delta > 0) ? Teams[1] : Teams[0];
    for (i = 0; i < MyKFGRIV.PRIArray.Length; i++)
    {
        PRI = MyKFGRIV.PRIArray[i];
        if ( PRI.Team == TI )
        {
            AutoBalanceList.AddItem(PRI);
        }
    }

    AutoBalanceRemaining = Min(abs(Delta), MyKFGRIV.TeamBalanceDelta);
    while (AutoBalanceRemaining > 0 || TI.Size > (MaxPlayersAllowed / 2) )
    {
        i = Rand(AutoBalanceList.Length);
        SwapTeamFor(AutoBalanceList[i]);
        AutoBalanceList.Remove(i, 1);
        AutoBalanceRemaining--;
    }
}

function SwapTeamFor( PlayerReplicationInfo PRI )
{
    local KFPlayerControllerVersus KFPCV;

    KFPCV = KFPlayerControllerVersus(PRI.Owner);
    if( KFPCV != none )
    {
       KFPCV.NotifyOfAutoBalance();
       SetTeam( KFPCV,  PRI.GetTeamNum() == 255 ? Teams[0] : Teams[1] );
    }
}

/* create a player team, and fill from the team roster
*/
function CreateTeam(int TeamIndex)
{
    switch (TeamIndex)
    {
        case 0:
            Teams[TeamIndex] = spawn(class'KFGame.KFTeamInfo_Human');
            GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
            break;

        case 1:
            Teams[TeamIndex] = spawn(class'KFGameContent.KFTeamInfo_Zeds');
            GameReplicationInfo.SetTeam(TeamIndex, Teams[TeamIndex]);
            break;
    }
}

function int GetPlayerGroup(const out UniqueNetId PlayerId, optional out int IdIndex)
{
	local PlayerGroupStruct Group;
	local UniqueNetId Id;
	local int GroupIndex, Index;

	IdIndex = INDEX_NONE;
	foreach PlayerGroups(Group, GroupIndex)
	{
		foreach Group.PlayerGroup(Id, Index)
		{
			if (id == PlayerId)
			{
				IdIndex = Index;
				return GroupIndex;
			}
		}
	}
	return INDEX_NONE;
}

function byte PickGroupTeam(optional int GroupSize = 1)
{
	local int Human, Zed;

	GetReservedTotals(Human, Zed);
	//Keep the human team ahead of Zeds, since there will always be AI Zeds to fill in
	if (Zed + GroupSize <= Human)
	{
		`log("PickGroupTeam: Team totals are Humans" @ Human @ "Zeds" @ Zed @ ", adding new group to Zed team", bLogGroupTeamBalance);
		//Zed team
		return 1;
	}
	else
	{
		`log("PickGroupTeam: Team totals are Humans" @ Human @ "Zeds" @ Zed @ ", adding new group to Human team", bLogGroupTeamBalance);
		//Human team
		return 0;
	}
}

function PlayerReplicationInfo GetPRIById(const UniqueNetId Id)
{
	local PlayerReplicationInfo PRI;

	foreach MyKFGRIV.PRIArray(PRI)
	{
		if (PRI.UniqueId == Id)
		{
			return PRI;
		}
	}
	return none;
}

/* Adds up the players on each team, including those who are in a group
   assigned to a team but not yet logged in */
function GetReservedTotals(out int Human, out int Zed)
{
	local PlayerGroupStruct Group;
	local UniqueNetId Id;

	//First total who is logged in
	Human = Teams[0].Size;
	Zed = Teams[1].Size;

	foreach PlayerGroups(Group)
	{
		foreach Group.PlayerGroup(Id)
		{
			//If they they have a PRI they have already logged in and were counted in the
			//Team[].Size values above
			if (GetPRIById(Id) == none)
			{
				//If they haven't logged in but their group has been assigned a team, count them
				//in that team. If Team is something other than 0 or 1 they haven't been assigned a
				//team and so don't count them yet
				if (Group.Team == 0)
				{
					++Human;
				}
				else if (Group.Team == 1)
				{
					++Zed;
				}
			}
		}
	}
}

/** Called by Gameinfo::Login(), initial team pick */
function byte PickTeam(byte Current, Controller C, const out UniqueNetId PlayerId)
{
    local int Group;
`if(`notdefined(ShippingPC))
	// Allow us to force join as the zed team if we pass 128 as our team ID to the command line
	if( Current == 128 )
	{
		`log( "[DEBUGVERSUS] Force joining zed team using ?Team=128 from command line!" );
		return 1;
	}
`endif
	Group = GetPlayerGroup(PlayerId);
	if (Group == INDEX_NONE)
	{
		//If they're not in a group, consider them as a group of one
		return PickGroupTeam();
	}
	else if (PlayerGroups[Group].Team != 0 && PlayerGroups[Group].Team != 1)
	{
		//If their group hasn't been assigned a team yet (should only happen for the first member
		//who connects), pick a team for them based on their group size
		PlayerGroups[Group].Team = PickGroupTeam(PlayerGroups[Group].PlayerGroup.length);
	}
	//If we make it here, they should have a team, so return it
	return PlayerGroups[Group].Team;
}

/** Return whether a team change is allowed. */
function bool ChangeTeam(Controller Other, int N, bool bNewTeam)
{
    if( Other.PlayerReplicationInfo == none
        || Other.PlayerReplicationInfo.bBot
        || (!Other.PlayerReplicationInfo.bOnlySpectator
        && ArrayCount(Teams) > N
        && Other.PlayerReplicationInfo.Team != Teams[N]) )
    {
        SetTeam( Other, Teams[N] );
        return true;
    }

    return false;
}

/** SetTeam()
* Change Other's team to NewTeam.
* @param Other:  the controller which wants to change teams
* @param NewTeam:  the desired team.
* @param bNewTeam:  if true, broadcast team change notification
*/
function SetTeam(Controller Other, KFTeamInfo_Human NewTeam)
{
    local KFPlayerControllerVersus KFPCV;
    local TeamInfo OldTeam;

    if( Other == none || Other.PlayerReplicationInfo == none || Other.PlayerReplicationInfo.bBot || Other.PlayerReplicationInfo.bOnlySpectator )
    {
        super.SetTeam( Other, NewTeam );
        return;
    }

    OldTeam = Other.PlayerReplicationInfo.Team;

    super.SetTeam( Other, NewTeam );

    if( OldTeam != none && NewTeam != OldTeam )
    {
        KFPCV = KFPlayerControllerVersus( Other );
        KFPCV.ServerNotifyTeamChanged();
        if( !IsPlayerReady(KFPlayerReplicationInfo(Other.PlayerReplicationInfo)) )
        {
            OnWaitingPlayerTeamSwapped( Other );
        }
        else
        {
            if( OldTeam != none && OldTeam.TeamIndex == 255 && KFPCV != none && KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass != none )
            {
                // If this player switched teams, we need to recycle their zed pawn class back into rotation
                if( SpawnManager != none )
                {
                    KFAISpawnManager_Versus(SpawnManager).RecyclePendingZedPawnClass( KFPCV );
                }
            }
        }
    }
}

/** Overridden to handle team changes right after login */
event PostLogin( PlayerController NewPlayer )
{
    super.PostLogin( NewPlayer );

    if( !NewPlayer.CanRestartPlayer() )
    {
        OnWaitingPlayerTeamSwapped( NewPlayer );
    }
}

/** Initializes player state on team swap */
function OnWaitingPlayerTeamSwapped( Controller C )
{
    local KFPlayerControllerVersus KFPCV;
    local NavigationPoint Start;

    KFPCV = KFPlayerControllerVersus( C );
    if( KFPCV != none )
    {
        if( KFPCV.GetTeamNum() == 255 )
        {
            if( KFPCV.Pawn != none && KFPawn_Customization(KFPCV.Pawn) != none )
            {
                // Hide customization pawn
                KFPawn_Customization(KFPCV.Pawn).SetServerHidden( true );
            }

            KFPCV.SetCameraMode( 'PlayerZedWaiting' );
        }
        else if( KFPCV.Pawn != none )
        {
            // Unhide/relocate customization pawn
            KFPawn_Customization(KFPCV.Pawn).SetServerHidden( false );

            if( !KFPawn_Customization(KFPCV.Pawn).MoveToCustomizationPoint() )
            {
                Start = KFPCV.GetBestCustomizationStart( self );
                if( Start != none )
                {
                    KFPawn_Customization(KFPCV.Pawn).SetUpdatedMovementData( Start.Location, Start.Rotation );
                }
            }

            // Restore view target and camera mode
            KFPCV.SetViewTarget( KFPCV.Pawn );
            KFPCV.SetCameraMode( 'Customization' );
        }

        KFPCV.ServerNotifyTeamChanged();
    }
}

/** Need to recycle any exiting players' pending zed pawn classes back into the spawn rotation */
function Logout( Controller Exiting )
{
    local KFPlayerControllerVersus KFPCV;

    if( Exiting != none )
    {
        KFPCV = KFPlayerControllerVersus( Exiting );
        if( KFPCV != none && KFPCV.GetTeamNum() == 255 && KFPCV.PlayerZedSpawnInfo.PendingZedPawnClass != none )
        {
            if( SpawnManager != none )
            {
                KFAISpawnManager_Versus(SpawnManager).RecyclePendingZedPawnClass( KFPCV );
            }
        }
    }

    super.Logout( Exiting );
}

function RestartPlayer(Controller NewPlayer)
{
    local int PlayerTeamIndex;
    local KFPawn_Monster MonsterPawn;
    local KFPlayerController KFPC;

    // Check bOnlySpectator.  Can be called sometimes without calling CanRestartPlayer()?!?
    if(NewPlayer.PlayerReplicationInfo == none || NewPlayer.PlayerReplicationInfo.bOnlySpectator)
    {
        return;
    }

    PlayerTeamIndex = NewPlayer.GetTeamNum();
    KFPC = KFPlayerController( NewPlayer );
    if( KFPC != none
        && (MyKFGRI.bMatchIsOver || (PlayerTeamIndex == 255 && (MyKFGRI.bTraderIsOpen || KFPC.PlayerZedSpawnInfo.PendingZedPawnClass == none))) )
    {
        if( IsPlayerReady(KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo)) )
        {
            KFPC.StartSpectate();
        }
        return;
    }

    if( NewPlayer.Pawn != none && KFPawn_Customization(NewPlayer.Pawn) != none )
    {
        // If we have a customization pawn, destroy it before spawning a new pawn with super.RestartPlayer
        NewPlayer.Pawn.Destroy();
    }

    // Restart human
    if( PlayerTeamIndex != 255 )
    {
        super.RestartPlayer( NewPlayer );
    }
    else if( NewPlayer.Pawn == none && PlayerTeamIndex == 255 )
    {
        super(GameInfo).RestartPlayer( NewPlayer );
    }

    MonsterPawn = KFPawn_Monster(NewPlayer.Pawn);
    if( MonsterPawn != none && MonsterPawn.IsHumanControlled() )
    {
        MonsterPawn.UpdateLastTimeDamageHappened();
    }
}

/* @see GameInfo::SetPlayerDefaults */
function SetPlayerDefaults(Pawn PlayerPawn)
{
	local KFPawn_Human P;

	Super.SetPlayerDefaults(PlayerPawn);

	// humans get full armor for the first wave
	if ( WaveNum == 0 )
	{
		P = KFPawn_Human(PlayerPawn);
		if ( P != none )
		{
			P.GiveMaxArmor();
		}
	}
}

function int GetAIControlledMonsterAliveCount()
{
	local AIController AIP;
	local int UsedLivingAIMonsterCount;

	foreach WorldInfo.AllControllers(class'AIController', AIP)
	{
		if( AIP != none && AIP.Pawn != none && AIP.Pawn.IsAliveAndWell() )
		{
            if( KFPawn_Monster(AIP.Pawn) != none )
            {
                UsedLivingAIMonsterCount++;
            }
		}
	}

	return UsedLivingAIMonsterCount;
}

/**
 * Returns the default pawn class for the specified controller,
 *
 * @param	C - controller to figure out pawn class for
 *
 * @return	default pawn class
 */
function class<Pawn> GetDefaultPlayerClass( Controller C )
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(C);

	if( KFPC.GetTeamNum() == 255 )
	{
        if( KFPC.PlayerZedSpawnInfo.PendingZedPawnClass != none )
        {
            return KFPC.PlayerZedSpawnInfo.PendingZedPawnClass;
        }

        return none;
    }

	// default to the game specified pawn class
	return super.GetDefaultPlayerClass( C );
}

// Overridden because the native implementation will count human controlled zeds
function int GetLivingPlayerCount()
{
	local Controller P;
	local int UsedLivingHumanPlayersCount;

`if(`notdefined(ShippingPC))
	if ( ForcedNumLivingPlayers != 0 )
	{
		return ForcedNumLivingPlayers;
	}
`endif

	foreach WorldInfo.AllControllers(class'Controller', P)
	{
		if( P != none && P.Pawn != none && P.Pawn.IsAliveAndWell() )
		{
            if( P.GetTeamNum() != 255 )
            {
                //`log(P$" TeamIndex = "$P.PlayerReplicationInfo.Team.TeamIndex);
                UsedLivingHumanPlayersCount++;
            }
		}
	}

	//`log(GetFuncName()$" Player alive count: "$UsedLivingHumanPlayersCount);

	return UsedLivingHumanPlayersCount;
}

/*  Use reduce damage for friendly fire, etc. */
function ReduceDamage( out int Damage, Pawn Injured, Controller InstigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType, Actor DamageCauser, TraceHitInfo HitInfo )
{
    local KFPawn InstigatorPawn, InjuredPawn;

    if( InstigatedBy != none )
    {
        InstigatorPawn = KFPawn(InstigatedBy.Pawn);
        InjuredPawn = KFPawn(Injured);

        if( DamageType != AntiGriefDamageTypeClass )
        {
            if( InstigatorPawn != none && InjuredPawn != none &&
                InstigatorPawn.GetTeamNum() != InjuredPawn.GetTeamNum() )
            {
                InstigatorPawn.UpdateLastTimeDamageHappened();
                InjuredPawn.UpdateLastTimeDamageHappened();
            }
        }

        // Don't let player zeds damage AI zeds
        if( InstigatedBy.GetTeamNum() == 255
            && Injured.GetTeamNum() == 255
            && InstigatedBy.bIsPlayer
            && !Injured.IsHumanControlled() )
        {
            Momentum = vect(0,0,0);
            Damage = 0;
            return;
        }
    }

    super.ReduceDamage( Damage, Injured, InstigatedBy, HitLocation, Momentum, DamageType, DamageCauser, HitInfo );
}

function ScoreDamage( int DamageAmount, int HealthBeforeDamage, Controller InstigatedBy, Pawn DamagedPawn, class<DamageType> damageType )
{
    local KFInterface_MonsterBoss BossRef;

    if( InstigatedBy == none
        || !InstigatedBy.bIsPlayer
        || InstigatedBy.PlayerReplicationInfo == none
        || InstigatedBy.GetTeamNum() == DamagedPawn.GetTeamNum() )
    {
        return;
    }

    DamageAmount = Min( DamageAmount, HealthBeforeDamage );
    KFPlayerReplicationInfo(InstigatedBy.PlayerReplicationInfo).DamageDealtOnTeam += DamageAmount;
	KFPlayerController(InstigatedBy).AddTrackedDamage(DamageAmount, damageType, InstigatedBy.Pawn.Class, DamagedPawn.Class);

    if(InstigatedBy.PlayerReplicationInfo.GetTeamNum() == 255)
    {
        BossRef = KFInterface_MonsterBoss(InstigatedBy.Pawn);
        if(BossRef != none)
        {
            if(DamagedPawn.IsA('KFPawn_Human'))
            {
                //damage taken from boss
                BossSurvivorDamageTaken += DamageAmount;
            }
        }
    }
    else
    {
        BossRef = KFInterface_MonsterBoss(DamagedPawn);
        if(BossRef != none)
        {
            //damage done to boss
            BossDamageDone += DamageAmount;
        }
    }
}

function ScoreKill(Controller Killer, Controller Other)
{
    local KFPawn KFP;
    local KFPlayerReplicationInfo DamagerKFPRI;
    local int i;

    // Add player zed assists
    if( Other.GetTeamNum() == 0 )
    {
        KFP = KFPawn( Other.Pawn );
        for( i = 0; i < KFP.DamageHistory.Length; ++i )
        {
            if( KFP.DamageHistory[i].DamagerController != none
                && KFP.DamageHistory[i].DamagerController.bIsPlayer
                && KFP.DamageHistory[i].DamagerPRI != none
                && KFP.DamageHistory[i].DamagerPRI.GetTeamNum() == 255 )
            {
                if( Killer.PlayerReplicationInfo != KFP.DamageHistory[i].DamagerPRI )
                {
                    DamagerKFPRI = KFPlayerReplicationInfo( KFP.DamageHistory[i].DamagerPRI );
                    if( DamagerKFPRI != none )
                    {
                        ++DamagerKFPRI.Assists;
                    }
                }
            }
        }
    }
    else if( WaveNum == WaveMax && KFInterface_MonsterBoss(Other.Pawn) != none )
    {
        // Add our boss kill points
        BossDamageDone = POINTS_FOR_BOSS_KILL;
    }

    super.ScoreKill( Killer, Other );
}

//override from survival to send correct message
function EndOfMatch(bool bVictory)
{
    local KFPlayerController KFPC;
    local int TempScore;
    local KFPlayerReplicationInfoVersus KFPRIV;

    `AnalyticsLog(("match_end", None, "#"$WaveNum, "#"$(bVictory ? "1" : "0"), "#"$GameConductor.ZedVisibleAverageLifespan));

    if(bVictory)
    {
        SetTimer(EndCinematicDelay, false, nameof(SetWonGameCamera));
        BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_HumansWin);
    }
    else
    {
        BroadcastLocalizedMessage(class'KFLocalMessage_Priority', GMT_ZedsWin);
        SetZedsToVictoryState();
    }

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        if( bVictory )
        {
            KFPC.ClientWonGame( WorldInfo.GetMapName( true ), GameDifficulty, GameLength, IsMultiplayerGame() );
        }

        KFPRIV = KFPlayerReplicationInfoVersus(KFPC.PlayerReplicationInfo);
        if(KFPRIV != none)
        {
            KFPRIV.RecordEndGameInfo();
        }

		KFPC.ClientGameOver(WorldInfo.GetMapName(true), GameDifficulty, GameLength, IsMultiplayerGame(), WaveNum);
    }

    WorldInfo.TWPushLogs();

    // Calculate final score
    WaveBonus = Max( (WaveNum - 1), 0) * POINTS_FOR_WAVE_COMPLETION;

    if( bVictory )
    {
        CheckRoundEndAchievements( 0 );
        TempScore += POINTS_FOR_BOSS_KILL;
        TempScore -= BossSurvivorDamageTaken;
    }
    else
    {
        CheckRoundEndAchievements( 255 );

        if( WaveNum != WaveMax )
        {
            WaveBonus += Max( int(float(POINTS_FOR_WAVE_COMPLETION) * PercentOfZedsKilledBeforeWipe), 0 );
        }
    }

    TempScore += WaveBonus;
    TempScore -= POINTS_PENALTY_FOR_DEATH * HumanDeaths;
    Teams[0].AddRoundScore( TempScore, true );

    // Update team scores
    if( MyKFGRIV.CurrentRound == 0 )
    {
        UpdateFirstRoundTeamScore();
    }
    else
    {
        UpdateSecondRoundTeamScore();
    }

    GotoState('RoundEnded', 'Begin');
}

function Killed( Controller Killer, Controller KilledPlayer, Pawn KilledPawn, class<DamageType> damageType )
{
    super.Killed( Killer, KilledPlayer, KilledPawn, damageType );

    if( IsWaveActive() && GetAIControlledMonsterAliveCount() <= 0 && SpawnManager.IsFinishedSpawning() )
    {
        CheckPawnsForGriefing( true );
    }
}

function WaveEnded( EWaveEndCondition WinCondition )
{
    local KFPlayerReplicationInfoVersus KFPRIV;
    local int WaveKills;
    local int i, j;

    MyKFGRIV.SetPlayerZedSpawnTime( 255, false );
    ClearTimer( nameOf(CheckPawnsForGriefing) );

    // If game ended on a wipe, record how many zeds were killed as well as wave reached
    if( WinCondition == WEC_TeamWipedOut && SpawnManager != none && WaveNum != WaveMax )
    {
        PercentOfZedsKilledBeforeWipe = fClamp( 1.f - (float(MyKFGRI.AIRemaining) / float(SpawnManager.WaveTotalAI)), 0.f, 1.f );
    }

    // Tabulate the number of kills this wave
    for( i = 0; i < WorldInfo.GRI.PRIArray.Length; ++i )
    {
        // No kills to tabulate
        if( WorldInfo.GRI.PRIArray[i].Kills == 0 )
        {
            continue;
        }

        KFPRIV = KFPlayerReplicationInfoVersus( WorldInfo.GRI.PRIArray[i] );
        if( KFPRIV != none && !KFPRIV.bBot && KFPRIV.GetTeamNum() == 255 )
        {
            WaveKills = KFPRIV.Kills;
            for( j = 0; j < KFPRIV.WaveKills.Length; ++j )
            {
                WaveKills -= KFPRIV.WaveKills[j];
            }

            KFPRIV.WaveKills[WaveNum] = WaveKills;
        }
    }

    super.WaveEnded( WinCondition );
}


function BossDied(Controller Killer, optional bool bCheckWaveEnded = true)
{
    super.BossDied(Killer, bCheckWaveEnded);
}

/**
 * @brief Checks if a player zed has dealt or received damage
 *
 * @param bool bInitial Set's the LastTimeDamageHappened to the current time to
 *             give the players some time to get to the humans
 */
protected function CheckPawnsForGriefing( optional bool bInitial=false )
{
    local Pawn TestPawn;
    local KFPawn_Monster MonsterTestPawn;

    foreach WorldInfo.AllPawns( class'Pawn', TestPawn )
    {
        if( TestPawn.IsAliveAndWell() && TestPawn.Controller != none &&
            TestPawn.Controller.bIsPlayer && TestPawn.GetTeamNum() == 255 )
        {
            MonsterTestPawn = KFPawn_Monster(TestPawn);
            if( MonsterTestPawn != none )
            {
                if( bInitial )
                {
                    MonsterTestPawn.LastTimeDamageHappened = WorldInfo.TimeSeconds;
                }
                 else if( WorldInfo.TimeSeconds - MonsterTestPawn.LastTimeDamageHappened >= ANTI_GRIEF_DELAY &&
                          MonsterTestPawn.LastTimeDamageHappened != 0 )
                {
                    MonsterTestPawn.MotivatePlayerToAttack( ANTI_GRIEF_DAMAGE_PERCENTAGE, AntiGriefDamageTypeClass );
                }
            }
        }
    }

    if( IsWaveActive() )
    {
        SetTimer( ANTI_GRIEF_INTERVAL, false, nameOf(CheckPawnsForGriefing) );
    }
}

/** Called to reset all the types of pickups */
function ResetAllPickups()
{
	if ( !bDisablePickups )
	{
		// Reset ALL pickups each wave (ignoring NumPickups)
 		// -1, so that we always have a different pickup to activate
		NumWeaponPickups = Max(ItemPickups.Length - 1, 0);
		NumAmmoPickups = Max(AmmoPickups.Length - 1, 0);
 	}

 	Super.ResetAllPickups();
}

function OpenPostRoundMenu()
{
    local KFPlayerController KFPC;

    foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
    {
        if( IsPlayerReady(KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo)) )
        {
            KFPC.ClientOpenRoundSummary();
        }
    }
}

/** Updates team data for use in the next game round */
function UpdateFirstRoundTeamScore()
{
    // Cache team score
    Teams[1].TeamScoreDataPacket.RoundScore = Teams[0].TeamScoreDataPacket.RoundScore;
    // Cache wave reached
    Teams[1].TeamScoreDataPacket.WaveBonus = WaveBonus;

    // Cache survivor deaths
    Teams[1].TeamScoreDataPacket.Deaths = HumanDeaths;

    // Cache boss values if relevant
    if( WaveNum == WaveMax )
    {
        // Boss damage done
        Teams[1].TeamScoreDataPacket.BossDamageDone = BossDamageDone;

        // Boss survivor damage taken
        Teams[1].TeamScoreDataPacket.BossDamageTaken = BossSurvivorDamageTaken;
    }
    else
    {
        // Clear any boss values
        Teams[1].TeamScoreDataPacket.BossDamageDone = 0;
        Teams[1].TeamScoreDataPacket.BossDamageTaken = 0;
    }


    // Reset merc team stats for second round
    Teams[0].TeamScoreDataPacket.RoundScore = 0;
    Teams[0].TeamScoreDataPacket.WaveBonus = -1;
    Teams[0].TeamScoreDataPacket.Deaths = 0;
    Teams[0].TeamScoreDataPacket.BossDamageDone = 0;
    Teams[0].TeamScoreDataPacket.BossDamageTaken = 0;

    // Force network update
    Teams[0].bForceNetUpdate = true;
    Teams[0].bNetDirty = true;
    Teams[1].bForceNetUpdate = true;
    Teams[1].bNetDirty = true;
}

/** Updates team data for use in the final game round */
function UpdateSecondRoundTeamScore()
{
    // Cache wave reached
    Teams[0].TeamScoreDataPacket.WaveBonus = WaveBonus;

    // Cache survivor deaths
    Teams[0].TeamScoreDataPacket.Deaths = HumanDeaths;

    // Cache boss values if relevant
    if( WaveNum == WaveMax )
    {
        // Boss damage done
        Teams[0].TeamScoreDataPacket.BossDamageDone = BossDamageDone;

        // Boss survivor damage taken
        Teams[0].TeamScoreDataPacket.BossDamageTaken = BossSurvivorDamageTaken;
    }
    else
    {
        // Clear any boss values
        Teams[0].TeamScoreDataPacket.BossDamageDone = 0;
        Teams[0].TeamScoreDataPacket.BossDamageTaken = 0;
    }

    // Force network update
    Teams[0].bNetDirty = true;
    Teams[0].bForceNetUpdate = true;
    Teams[1].bNetDirty = true;
    Teams[1].bForceNetUpdate = true;
}

/** Perform gametype-specific resets */
function Reset()
{
    local KFPlayerControllerVersus KFPCV;

    super.Reset();

    // Swap teams
    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        if( KFPCV.CanRestartPlayer() )
        {
            SetTeam( KFPCV, KFPCV.PlayerReplicationInfo.Team == Teams[0] ? Teams[1] : Teams[0] );
            KFPCV.ServerNotifyTeamChanged();

            // Put everyone into spectator state
            if( !KFPCV.IsInState('Spectating') )
            {
                KFPCV.StartSpectate();
            }
        }
    }

    if( SpawnManager != none )
    {
        SpawnManager.ResetSpawnManager();
    }

    // Reset score statistics
    WaveBonus = -1;
    HumanDeaths = 0;
    BossDamageDone = 0;
    BossSurvivorDamageTaken = 0;
    PercentOfZedsKilledBeforeWipe = 0.f;

    // Reset pool manager (clear puke mines, c4, etc)
    class'KFGameplayPoolManager'.static.GetPoolManager().Reset();
}

 /*********************************************************************************************
 * state RoundEnded
 *********************************************************************************************/

/** Close the team results screen */
protected function ClosePostRoundMenu( optional bool bMatchOver=false )
{
    local KFPlayerControllerVersus KFPCV;

    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        KFPCV.ClientShowPostGameMenu( false );
    }

    // Wait a tiny bit to display the next round message
    if( !bMatchOver )
    {
        SetTimer( 0.1, false, nameOf(Timer_AnnounceNextRound) );
    }
}

/** Announces the next round to players */
protected function Timer_AnnounceNextRound()
{
	local KFPlayerController KFPC;

	foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
	{
		// Only process players that are ready to play
		if( KFPC.CanRestartPlayer() )
		{
			KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Priority', GMT_NextRoundBegin,,, KFPC.PlayerReplicationInfo.Team );
		}
	}
}

/** Checks to ensure a game is actually playable and balances accordingly */
protected function CheckTeamNumbers()
{
    local KFPlayerControllerVersus KFPCV;
    local int HumanPlayers, ZedPlayers;

    // If there aren't at least 2 players, end the match
    if( NumPlayers < 2 || MyKFGRIV.CurrentRound > 1 )
    {
        GotoState( 'MatchEnded' );
        return;
    }

    // If there are no players on one of the teams, force one of them to switch
    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        if( !KFPCV.CanRestartPlayer() )
        {
            continue;
        }

        if( KFPCV.GetTeamNum() == 255 )
        {
            ++ZedPlayers;
        }
        else
        {
            ++HumanPlayers;
        }
    }

    if( HumanPlayers == 0 && ZedPlayers > 1 )
    {
        SwitchOnePlayerToTeam( 0 );
    }
    else if( ZedPlayers == 0 && HumanPlayers > 1 )
    {
        SwitchOnePlayerToTeam( 255 );
    }
}

/** Resets the level and announces a round change */
protected function BeginNextRound()
{
    // Reset everything
    ResetLevel();

    // Init next round
    MyKFGRIV.bStopCountDown = true;
    MyKFGRIV.SetPlayerZedSpawnTime( PostRoundWaitTime, false );

    ClosePostRoundMenu();
}

static function bool IsInitialSpawnPointSelection( WorldInfo WI )
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo( WI.GRI );
	if( KFGRI != none )
	{
		return KFGRI.bRoundIsOver || super.IsInitialSpawnPointSelection( WI );
	}

	return false;
}

/** Attempts to pre-select player starts and begin texture streaming */
protected function PreSelectPlayerStarts()
{
	local KFPlayerController KFPC;
	local byte TeamNum;

	foreach WorldInfo.AllControllers( class'KFPlayerController', KFPC )
	{
		KFPC.StartSpot = none;
		TeamNum = KFPC.GetTeamNum();
		if( KFPC.GetTeamNum() == 0 )
		{
			KFPC.StartSpot = FindPlayerStart( KFPC, TeamNum );
		}
		else
		{
			KFPC.StartSpot = none;
			continue;
		}

		if( KFPC.StartSpot != none )
		{
			KFPC.ClientAddTextureStreamingLoc( KFPC.StartSpot.Location, 0.f, false );
		}
	}
}

/** Starts spawning */
function StartSpawning()
{
    // Reset round over flag
    MyKFGRIV.bRoundIsOver = false;
    MyKFGRIV.bNetDirty = true;
    MyKFGRIV.bForceNetUpdate = true;

    // Off we go!
    GotoState( '' );
    StartMatch();
}

/** Swaps one player to the opposite team */
protected function SwitchOnePlayerToTeam( byte TeamNum )
{
    local KFPlayerControllerVersus KFPCV;

    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        if( KFPCV.CanRestartPlayer()
            && KFPCV.GetTeamNum() != TeamNum )
        {
            SetTeam( KFPCV, TeamNum == 0 ? Teams[0] : Teams[1] );
            break;
        }
    }
}

state RoundEnded
{
    event BeginState( name PrevStateName )
    {
		local int i;

        // Set round over flag (allows perk changes etc)
        MyKFGRIV.bRoundIsOver = true;

        // Increment round
        MyKFGRIV.CurrentRound += 1;

		// BWJ - 10-3-16 - Clear the spawned in flag when round end begins
		for( i = 0; i < GameReplicationInfo.PRIArray.Length; i++ )
		{
			KFPlayerReplicationInfo(GameReplicationInfo.PRIArray[i]).bHasSpawnedIn = false;
		}

        // Turn off respawn timer
        MyKFGRIV.SetPlayerZedSpawnTime( 255, false );
    }

    function bool MatchIsInProgress()
    {
        return false;
    }

ForceEnded:
    Sleep( 1.f );
    BeginNextRound();
    Goto( 'End' );

Begin:
    // Wait a short time and bring up the results screen
    Sleep( RoundEndCinematicDelay );
    OpenPostRoundMenu();

    // Wait for the results screen duration and start the next round
    Sleep( GetEndOfMatchTime() );
    if( MyKFGRIV.CurrentRound > 1 )
    {
        GotoState( 'MatchEnded' );
        Sleep(0.f);
    }
    CheckTeamNumbers();
    BeginNextRound();

    // Wait a short time after closing the results screen (for perk changes) before spawning
    Sleep( fMax(PostRoundWaitTime - 3.f, 0.f) );
    PreSelectPlayerStarts();
    Sleep( 3.f );

End:
    StartSpawning();
}

protected function CheckRoundEndAchievements( byte WinningTeam )
{
    local KFPlayerControllerVersus KFPCV;

    foreach WorldInfo.AllControllers( class'KFPlayerControllerVersus', KFPCV )
    {
        KFPCV.ClientRoundEnded( WinningTeam );
    }
}

function TryRestartGame()
{
    if( IsInState('RoundEnded') )
    {
        BeginNextRound();
    }
    else
    {
        super.TryRestartGame();
    }
}

function ShowPostGameMenu()
{
    ClosePostRoundMenu( true );

    super.ShowPostGameMenu();
}

function float GetEndOfMatchTime()
{
    if( IsInState('RoundEnded') )
    {
        return TimeUntilNextRound;
    }

    return super.GetEndOfMatchTime();
}

function bool IsMapObjectiveEnabled()
{
	return false;
}

DefaultProperties
{
    bIsVersusGame=true
    TimeUntilNextRound=12
    RoundEndCinematicDelay=4
    PostRoundWaitTime=15
    MaxGameDifficulty=0

    GameLengthDoshScale(0)=1.0 // Short but already scaled in other ways for versus
	MaxRespawnDosh(0)=1950 // Max amount of dosh that a player can respawn with after dying //1750
	DeathPenaltyModifiers(0)=0.03 // How much of a penalty to apply to dosh after dying. Smaller means lower penalty //0.05

	OnlineGameSettingsClass=class'KFGame.KFOnlineGameSettingsVersus'
	HUDType=class'KFGameContent.KFGFXHudWrapper_Versus'
    KFGFxManagerClass=class'KFGame.KFGFxMoviePlayer_Manager_Versus'
	PlayerControllerClass=class'KFGameContent.KFPlayerControllerVersus'
    PlayerReplicationInfoClass=class'KFGame.KFPlayerReplicationInfoVersus'
	GameReplicationInfoClass=class'KFGameContent.KFGameReplicationInfoVersus'
	MaxPlayersAllowed=`KF_MAX_PLAYERS_VERSUS
	DefaultPawnClass=class'KFGameContent.KFPawn_Human_Versus'
	GameConductorClass=class'KFGameContent.KFGameConductorVersus'
	DifficultyInfoClass=class'KFGameDifficulty_Versus'
	DifficultyInfoConsoleClass=class'KFGameDifficulty_Versus_Console'

    PlayerZedClasses(AT_AlphaClot)=class'KFGameContent.KFPawn_ZedClot_Alpha_Versus'
    PlayerZedClasses(AT_SlasherClot)=class'KFGameContent.KFPawn_ZedClot_Slasher_Versus'
    PlayerZedClasses(AT_Crawler)=class'KFGameContent.KFPawn_ZedCrawler_Versus'
    PlayerZedClasses(AT_GoreFast)=class'KFGameContent.KFPawn_ZedGorefast_Versus'
    PlayerZedClasses(AT_Stalker)=class'KFGameContent.KFPawn_ZedStalker_Versus'
    PlayerZedClasses(AT_Scrake)=class'KFGameContent.KFPawn_ZedScrake_Versus'
    PlayerZedClasses(AT_FleshPound)=class'KFGameContent.KFPawn_ZedFleshpound_Versus'
    PlayerZedClasses(AT_Bloat)=class'KFGameContent.KFPawn_ZedBloat_Versus'
    PlayerZedClasses(AT_Siren)=class'KFGameContent.KFPawn_ZedSiren_Versus'
    PlayerZedClasses(AT_Husk)=class'KFGameContent.KFPawn_ZedHusk_Versus'

    PlayerBossClassList.Add(class'KFGameContent.KFPawn_ZedPatriarch_Versus')

    SpawnManagerClasses.Empty
	SpawnManagerClasses(0)=class'KFAISpawnManager_Versus'

    AntiGriefDamageTypeClass=class'KFDT_NoGoVolume'

    /** Anti-griefing system */
    ANTI_GRIEF_DELAY=30.f
    ANTI_GRIEF_INTERVAL=2.f
    ANTI_GRIEF_DAMAGE_PERCENTAGE=10.f
}
