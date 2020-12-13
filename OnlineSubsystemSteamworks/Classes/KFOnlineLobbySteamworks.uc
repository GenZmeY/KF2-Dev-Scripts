//=============================================================================
// KFOnlineLobbySteamworks
//=============================================================================
// Steam Lobby functionality for Killing Floor 2
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Joshua Rowan 9/25/2013
//=============================================================================

class KFOnlineLobbySteamworks extends OnlineLobbyInterfaceSteamworks within OnlineSubsystemSteamworks
	config(Engine)
	native;

`if(`STEAM_MATCHMAKING_LOBBY)

/** Steam's Id for this lobby */
var UniqueNetId CurrentLobbyId;
/** Empty Id to test for comparision with initialized ids */
var const UniqueNetId ZeroUniqueId;

/** TRUE after MakeLobby and before OnCreateLobbyComplete */
var bool bCreatingLobby;
/** If set, delay ShowLobbyInviteInterface until OnCreateLobbyComplete */
var bool bWaitingForLobby;
/** TRUE after LobbyJoinGame and before LobbyJoinGameDelegate */
var bool bWaitingForServer;

/** Holds server IP address while waiting for authentication to finish */
var string PendingServerIP;

/** TRUE if logging is enabled */
var bool bDebug;

/** Current lobby visibility */
var ELobbyVisibility LobbyVisibility;

var UniqueNetId InviteLobbyId;

cpptext
{
	UBOOL GetServerAddr(DWORD& ip, INT& port);
}

function UniqueNetId GetCurrentLobbyId()
{
	return CurrentLobbyId;
}

/*********************************************************************************************
* @name Creating a Lobby
********************************************************************************************* */

/** Returns true if this client is connected to a steam lobby */
function bool IsInLobby()
{
	if (CurrentLobbyId != ZeroUniqueId)
	{
		return true;
	}
	return false;
}

function bool IsLobbyOwner()
{
	local bool success;
	local UniqueNetId OwnerID;

	if (!IsInLobby())
	{
		`log(GetFuncName()@"Not in lobby", bDebug, 'DevLobby');
		return false;
	}

	success = GetLobbyAdmin(CurrentLobbyId, OwnerID);
	`log(GetFuncName()@"success="$success@"CurrentLobbyId="$UniqueNetIdToString(CurrentLobbyId)@"OwnerID="$UniqueNetIdToString(OwnerID), bDebug, 'DevLobby');
	return success && (OwnerID == LoggedInPlayerId);
}

function Initialize()
{
	//MakeLobby(6, LV_Friends);
	AddLobbyInviteDelegate(OnLobbyInvite);
	AddLobbyJoinGameDelegate(OnLobbyJoinGame);
	AddLobbyReceiveMessageDelegate(OnLobbyReceiveMessage);
}

/**
 * Does some setup and calls the superclass implementation
 *
 * @param MaxPlayers		The maximum number of lobby members
 * @param Type			The type of lobby to setup (public/private/etc.)
 * @param InitialSettings	The list of settings to apply to the lobby upon creation
 * @return			Returns True if a lobby was created, False otherwise
 */
function bool MakeLobby(int MaxPlayers, ELobbyVisibility Type)
{
	`log(GetFuncName()@"MaxPlayers="$MaxPlayers@"Type="$Type@"CurrentLobbyId="$UniqueNetIdToString(CurrentLobbyId), bDebug, 'DevLobby');

	if ( IsInLobby() )
	{
		// If we already have a lobby, use this to modify settings
		SetLobbyType(CurrentLobbyId, Type);
		return false;
	}

	AddCreateLobbyCompleteDelegate(OnCreateLobbyComplete);
	bCreatingLobby = true;
	return CreateLobby(MaxPlayers, Type);
}

/**
 * Called when 'CreateLobby' completes, returning success/failure, and (if successful) the new lobby UID
 *
 * @param bWasSuccessful	whether or not 'CreateLobby' was successful
 * @param LobbyId		If successful, the UID of the new lobby
 * @param Error			If lobby creation failed, returns the error type
 */
function OnCreateLobbyComplete(bool bWasSuccessful, UniqueNetId LobbyId, string Error)
{
	local string ConnectedServerIP;

	`log(GetFuncName()@"bWasSuccessful="$bWasSuccessful@"Id="$UniqueNetIdToString(LobbyId)@"Error="$Error, bDebug, 'DevLobby');

	ClearCreateLobbyCompleteDelegate(OnCreateLobbyComplete);
	bCreatingLobby = false;
	if (bWasSuccessful)
	{
		AddLobbyMemberStatusUpdateDelegate(OnLobbyMemberStatusUpdate);
		CurrentLobbyId = LobbyId;
		ConnectedServerIP = GetConnectedServerIP();
		if (ConnectedServerIP != "")
		{
			`log(GetFuncName()@"SetLobbyServer CurrentLobbyId="$UniqueNetIdToString(CurrentLobbyId)@"ConnectedServerIP="$ConnectedServerIP, bDebug, 'DevLobby');
			SetLobbyServer(CurrentLobbyId, ZeroUniqueId, ConnectedServerIP);
		}
		if (bWaitingForLobby)
		{
			bWaitingForLobby = false;
			ShowLobbyInviteInterfaceInternal();
		}

		NotifyLobbyStatusChanged(true);
	}
}

/*********************************************************************************************
* @name Lobby Invites
********************************************************************************************* */

native function bool ShowLobbyInviteInterfaceInternal();

function ShowLobbyInviteInterface(string InviteMessage)
{
	`log(GetFuncName()@"bCreatingLobby="$bCreatingLobby, bDebug, 'DevLobby');

	if (bCreatingLobby)
	{
		bWaitingForLobby = true;
	}
	else
	{
		ShowLobbyInviteInterfaceInternal();
	}
}

event bool InviteFriendToLobby(string Nickname)
{
	local bool Success;
	local UniqueNetId FriendId;

	`log(GetFuncName()@"Nickname="$Nickname, bDebug, 'DevLobby');

	if ( !IsInLobby() )
	{
		return false;
	}

	FriendId = GetFriendUniqueId(Nickname);
	if (FriendId != ZeroUniqueId)
	{
		Success = InviteToLobby(CurrentLobbyId, FriendId);
	}

	if (Success)
	{
		`log("Friend" @ Nickname @ "with id" @ UniqueNetIdToString(FriendId) @ "invited to party" @ UniqueNetIdToString(CurrentLobbyId), bDebug, 'DevLobby');
	}
	else
	{
		`log("Failed to invite Friend" @ nickname @ "to party" @ UniqueNetIdToString(CurrentLobbyId), bDebug, 'DevLobby');
	}

	return Success;
}

event bool InviteFriendToLobbyByUid(QWORD Uid)
{
	local bool Success;
	local UniqueNetId FriendId;

	if ( !IsInLobby() )
	{
		return false;
	}

	FriendId.Uid = Uid;
	if (FriendId != ZeroUniqueId)
	{
		Success = InviteToLobby(CurrentLobbyId, FriendId);
	}

	if (Success)
	{
		`log("Friend with id" @ UniqueNetIdToString(FriendId) @ "invited to party" @ UniqueNetIdToString(CurrentLobbyId), bDebug, 'DevLobby');
	}
	else
	{
		`log("Failed to invite Friend to party" @ UniqueNetIdToString(CurrentLobbyId), bDebug, 'DevLobby');
	}

	return Success;
}

/** Finds a UniqueId from a Nickname */
function UniqueNetId GetFriendUniqueId(string Nickname, optional bool IncludeSelf = true)
{
	local EOnlineEnumerationReadState readstate;
	local array<OnlineFriend> Friends;
	local OnlineFriend i;

	if (IncludeSelf && Nickname == LoggedInPlayerName)
	{
		return LoggedInPlayerId;
	}

	readstate = GetFriendsList(0, Friends);
	if (readstate != OERS_Done)
	{
		`log("Do not have friends list loaded.", bDebug, 'DevLobby');
		return ZeroUniqueId;
	}

	foreach Friends(i)
	{
		if (Caps(i.NickName) == Caps(Nickname))
		{
			return i.UniqueId;
		}
	}

	`log("A user with nickname" @ Nickname @ "is not a friend.", bDebug, 'DevLobby');
	return ZeroUniqueId;
}

/** Callback on lobby member join, quit, etc... */
function OnLobbyMemberStatusUpdate(const out array<ActiveLobbyInfo> LobbyList, int LobbyIndex, int MemberIndex, int InstigatorIndex,
					string Status)
{
	local UniqueNetId MemberId;
	local string Nickname;

	`log(GetFuncName()@"LobbyIndex="$LobbyIndex@"MemberIndex="$MemberIndex@"Status="$Status, bDebug, 'DevLobby');

	MemberId = LobbyList[LobbyIndex].Members[MemberIndex].PlayerUID;
	if (MemberId != ZeroUniqueId)
	{
		Nickname = UniqueNetIdToPlayerName(MemberId);
		if (Nickname == "")
		{
			Nickname = "Unknown Nickname";
		}

		`log(Nickname @ "(UID" @ UniqueNetIdToString(MemberId) $ ") status changed in party" @ UniqueNetIdToString(LobbyList[LobbyIndex].LobbyUID) $ ":" @ Status, bDebug, 'DevLobby');
	}
}

function LobbyInvite(UniqueNetId LobbyId, UniqueNetId FriendId, bool bAccepted)
{
	OnLobbyInvite(LobbyId, FriendId, bAccepted);
}

/** Client accepted/cancelled an invite from a lobby owner */
function OnLobbyInvite(UniqueNetId LobbyId, UniqueNetId FriendId, bool bAccepted)
{
	`log(GetFuncName()@"LobbyId="$UniqueNetIdToString(LobbyId)@"FriendId="$UniqueNetIdToString(FriendId)@"bAccepted="$bAccepted, bDebug, 'DevLobby');

	if (!bAccepted)
	{
		if (LobbyId != CurrentLobbyId)
		{
			InviteLobbyId = LobbyId;
			
			if(GetPC() != none)
			{
				GetPC().showInvitePopup(GetFriendNickName(FriendId, false), LobbyId, FriendId);
			}
		}
		return; //for now don't do anything upon receiving the invite
	}

	if (LobbyId == CurrentLobbyId)
	{
		`log(GetFuncName()@"Ignoring invitation to current lobby.", bDebug, 'DevLobby');
		return;
	}
 	if( GetPC() != none )
 	{
		`log(GetFuncName()@"Accepting lobby invite; disconnecting from current server.", bDebug, 'DevLobby');
 		GetPC().ConsoleCommand( "disconnect" );
 	}

	AddJoinLobbyCompleteDelegate(OnJoinLobbyComplete);
	JoinLobby(LobbyId);
}

function acceptInviteFromFriend()
{
    `log(getFuncName());
    if( GetPC() != none )
 	{
		`log(GetFuncName()@"Accepting lobby invite; disconnecting from current server.", bDebug, 'DevLobby');
 		GetPC().ConsoleCommand( "disconnect" );
 	}
    AddJoinLobbyCompleteDelegate(OnJoinLobbyComplete);
    `log(GetFuncName()@"LobbyId="$UniqueNetIdToString(InviteLobbyId));
	JoinLobby(InviteLobbyId);
}

/** JoinLobby() finished */
function OnJoinLobbyComplete(bool bWasSuccessful, const out array<ActiveLobbyInfo> LobbyList, int LobbyIndex, UniqueNetId LobbyUID, string Error)
{
	local string ServerIPAddress;

	`log(GetFuncName()@"bWasSuccessful="$bWasSuccessful@"LobbyIndex="$LobbyIndex@"LobbyUID="$UniqueNetIdToString(LobbyUID)@"Error="$Error, bDebug, 'DevLobby');

	ClearJoinLobbyCompleteDelegate(OnJoinLobbyComplete);
	if (bWasSuccessful)
	{
		// If we are in a game already, leave it and take us to the main lobby menu
		//ConsoleCommand("disconnect");

		if ( IsInLobby() )
		{
			LeaveLobby(CurrentLobbyId);
		}
		CurrentLobbyId = LobbyUID;
		AddLobbyMemberStatusUpdateDelegate(OnLobbyMemberStatusUpdate);
		ServerIPAddress = GetLobbyServerIP(CurrentLobbyId);
		`log(GetFuncName()@"ServerIPAddress="$ServerIPAddress, bDebug, 'DevLobby');
		if ((class'WorldInfo'.static.IsEOSBuild() && ServerIPAddress != "" && ServerIPAddress != "NULL") ||  
	        (!class'WorldInfo'.static.IsEOSBuild() && ServerIPAddress != "")) 
		{
			`log(GetFuncName()@"JoinServer called", bDebug, 'DevLobby');
			JoinServer(ServerIPAddress, ZeroUniqueId);
			QuitLobby();
		}

		NotifyLobbyStatusChanged(true);
	}
}

/** Request to leave this lobby */
function bool QuitLobby()
{
	local bool Success;

	`log(GetFuncName()@"CurrentLobbyId="$UniqueNetIdToString(CurrentLobbyId), bDebug, 'DevLobby');

	if ( IsInLobby() )
	{
		Success = LeaveLobby(CurrentLobbyId);
		CurrentLobbyId = ZeroUniqueId;
		ClearLobbyMemberStatusUpdateDelegate(OnLobbyMemberStatusUpdate);
		//MakeLobby(6, LV_Friends);
	}
	if(Success)
	{
		NotifyLobbyStatusChanged(false);
	}

	return success;
}

//@HSL_BEGIN - JRO - 7/16/2016 - Just use the PRI UniqueNetId on PC
function UniqueNetId GetMyId()
{
	local UniqueNetId LoggedInPlayer;
	GetUniquePlayerId(0, LoggedInPlayer);
	return LoggedInPlayer;
}
//@HSL_END

/*********************************************************************************************
* @name Game Invites
********************************************************************************************* */

native function bool JoinServer(string ServerIP, UniqueNetId ServerId);
native function bool SetLobbyServer(UniqueNetId LobbyId, UniqueNetId ServerUID, string ServerIP);
native function bool GetServerConnected();
native function string GetLobbyServerIP(const out UniqueNetId LobbyId);
native function string GetConnectedServerIP();
native function string AppendPasswordToURL(string URL, string Password);
native function RejectInvite(UniqueNetId LobbyId, UniqueNetId FriendId);

/** Called on lobby owner when new listen server game is started */
function bool LobbyJoinGame(optional string ServerIP)
{
	`log(GetFuncName()@"ServerIP="$GetLobbyServerIP(CurrentLobbyId), bDebug, 'DevLobby');

	if ( !IsInLobby() )
	{
		return false;
	}
	else if ( !GetServerConnected() || !Outer.CachedAuthInt.IsReady() )
	{
		`log(GetFuncName()@"Server is not connected or auth is not ready.", bDebug, 'DevLobby');
		if (!bWaitingForServer)
		{
			PendingServerIP = ServerIP;
			bWaitingForServer = true;
			Outer.CachedAuthInt.AddAuthReadyDelegate(LobbyJoinGameDelegate);
			`log(GetFuncName()@"Waiting for server PendingServerIP=" @ PendingServerIP, bDebug, 'DevLobby');
		}
		return true;
	}

	//Make sure that delegate is always cleaned up, no matter what
	LobbyJoinGameDelegate();
	return true;
}

/** Called when AuthReady is complete, or immediately if Auth is already ready */
function LobbyJoinGameDelegate()
{
	local UniqueNetId ServerId;

	`log(GetFuncName()@"Done waiting for server PendingServerIP=" @ PendingServerIP, bDebug, 'DevLobby');

	bWaitingForServer = false;
	Outer.CachedAuthInt.ClearAuthReadyDelegate(LobbyJoinGameDelegate);
	Outer.CachedAuthInt.GetServerUniqueId(ServerId);

	//Blank IP address means we own the lobby and we're joining our local listen server
 	SetLobbyServer(CurrentLobbyId, ServerId, PendingServerIP);
	PendingServerIP = "";
}

/* Called when a lobby member or owner joins a dedicated server,
   if a lobby owner, it takes the lobby, if not, leave the lobby */
function bool LobbyJoinServer(string ServerIP)
{
 	`log(GetFuncName()@"ServerIP="$ServerIP, bDebug, 'DevLobby');
	if (IsLobbyOwner())
	{
		//return LobbyJoinGame(ServerIP);
		return SetLobbyServer(CurrentLobbyId, ZeroUniqueId, ServerIP);

	}
	else
	{
		//If we're in a lobby but not the owner, leave the lobby since we're joining
		//a separate server
		QuitLobby();
		return false;
	}
}

/** Called when the lobby owner starts a map */
function OnLobbyJoinGame(const out array<ActiveLobbyInfo> LobbyList, int LobbyIndex, UniqueNetId ServerId, string ServerIP)
{
	local bool bSuccess;
	if (IsLobbyOwner())
	{
		return;
	}
	`log(GetFuncName()@"LobbyIndex="$LobbyIndex@"ServerId="$UniqueNetIdToString(ServerId)@"ServerIp="$ServerIp, bDebug, 'DevLobby');

	//JoinServer handles the case of trying to join a server to which you are already connected
	//returns true in that case, and if the join attempt start successfully
	bSuccess = JoinServer(ServerIP, ServerId);
	QuitLobby();
	`log(GetFuncName()@"bSuccess="$bSuccess@"ServerIP="$ServerIP, bDebug, 'DevLobby');
}

/*********************************************************************************************
* @name Lobby Matchmaking (aka Find Match)
********************************************************************************************* */

/**
 * Kicks off a search for available lobbies, matching the specified filters, triggering callbacks when done
 */
function bool FindLobbies(optional int MaxResults=32, optional array<LobbyFilter> Filters, optional array<LobbySortFilter> SortFilters,
                          optional int MinSlots, optional ELobbyDistance Distance=LD_Best)
{
	AddFindLobbiesCompleteDelegate(FindLobbiesComplete);
	return super.FindLobbies(MaxResults, Filters, SortFilters, MinSlots, Distance);
}

/** Callback when FindLobbies finished */
function FindLobbiesComplete(bool bWasSuccessful, const out array<BasicLobbyInfo> LobbyList)
{
	ClearFindLobbiesCompleteDelegate(FindLobbiesComplete);
	if (bWasSuccessful && LobbyList.length > 0)
	{
		AddJoinLobbyCompleteDelegate(OnJoinLobbyComplete);
		`log("Starting join of party" @ UniqueNetIdToString(LobbyList[0].LobbyUID));
		JoinLobby(LobbyList[0].LobbyUID);
	}
	else if (bWasSuccessful)
	{
		`log("Unable to find a matching lobby.");
		NotifyUnsuccessfulSearch();
	}
	else
	{
		`log("Find lobbies failed.");
	}
}

//@UI Notify the menu manager that the search was not successful
function NotifyUnsuccessfulSearch()
{
	local PlayerController PC;
	PC = GetPC();
	if(PC != none)
	{
		PC.NotifyUnsuccessfulSearch();
	}
}

function NotifyLobbyStatusChanged(bool bInLobby)
{
	local PlayerController PC;
	PC = GetPC();
	if(PC != none)
	{
		PC.OnLobbyStatusChanged(bInLobby);
	}
}

/*********************************************************************************************
* @name Lobby Settings
********************************************************************************************* */

native function string GetLobbyData( int LobbyIndex, string Key );

function SetLobbyData( string Key, string Value )
{
    if ( !IsInLobby() )
	{
		return;
	}
	SetLobbySetting(CurrentLobbyId, Key, Value);
}

function bool SetVisibility( int VisibilityIndex )
{
	if ( IsInLobby())
	{
		LobbyVisibility = ELobbyVisibility(VisibilityIndex);
		return SetLobbyType( CurrentLobbyId, ELobbyVisibility(VisibilityIndex) );
	}
	return false;
}

/*********************************************************************************************
* @name Messages / Chat
* @todo: We should be using LobbyData instead of messages to broadcast UI info about the lobby and it's members
********************************************************************************************* */

function PlayerController GetPC()
{
	local WorldInfo WI;
	WI = class'WorldInfo'.static.GetWorldInfo();
	return WI.GetALocalPlayerController();
}

event ConsolePrint(string message)
{
	GetPC().ClientMessage(message);
}

//event ConsoleCommand( string Command )
//{
//	GetPC().ConsoleCommand( Command );
//}

/** Recieve from other lobby member */
function OnLobbyReceiveMessage(const out array<ActiveLobbyInfo> LobbyList, int LobbyIndex, int MemberIndex, string Type, string Message)
{
	local UniqueNetId MemberId;
	local string Nickname;

	//`log(GetFuncName()@"LobbyIndex="$LobbyIndex@"MemberIndex="$MemberIndex@"Type="$Type@"Message="$Message, bDebug, 'DevLobbyMsg');

	MemberId = LobbyList[LobbyIndex].Members[MemberIndex].PlayerUID;
	if (MemberId != ZeroUniqueId)
	{
		Nickname = UniqueNetIdToPlayerName(MemberId);
		if (Nickname == "")
		{
			Nickname = "Unknown Nickname";
		}

		ConsolePrint(Message);
	}
}

/** Send message */
function bool LobbyMessage(string Message)
{
	//`log(GetFuncName()@"Message="$Message, bDebug, 'DevLobbyMsg');

	if ( !IsInLobby() )
	{
		return false;
	}

	return SendLobbyMessage(CurrentLobbyId, Message);
}

/*********************************************************************************************
* @name Debugging
********************************************************************************************* */

event TestFindLobbies()
{
	`log("Attempting to find lobbies.");
	FindLobbies();
}

function string GetLobbyURLString()
{
	local ActiveLobbyInfo LobbyInfo;
	local string LobbyURLString;
	local LobbyMember Member;
	local int Index;

	if (!GetCurrentLobby(LobbyInfo))
	{
		return "";
	}

	foreach LobbyInfo.Members(Member, Index)
	{
		if (Member.PlayerUID != LoggedInPlayerId)
		{
			`log("LobbyURLString:"@UniqueNetIdToString(Member.PlayerUID));
			LobbyURLString $= "?party"$Index$"=" $ UniqueNetIdToString(Member.PlayerUID);
		}
	}
	//LobbyURLString $= "?party3=0x0110000100122A11";
	`log("LobbyURLString:"@LobbyURLString);
	return LobbyURLString;
}

function bool GetCurrentLobby(out ActiveLobbyInfo LobbyInfo)
{
	local ActiveLobbyInfo i;
	if ( IsInLobby() )
	{
		foreach ActiveLobbies(i)
		{
			if (i.LobbyUID == CurrentLobbyId)
			{
				LobbyInfo = i;
				return true;
			}
		}
	}
	return false;
}

function string GetFriendNickname(UniqueNetId FriendId, optional bool IncludeSelf = true)
{
	local String Nickname;
	if (FriendId == ZeroUniqueId)
	{
		return "";
	}
	//For convinience, consider yourself to be your own friend
	if (IncludeSelf && FriendId == LoggedInPlayerId)
	{
		return LoggedInPlayerName;
	}
	Nickname = UniqueNetIdToPlayerName(FriendId);

	if (Nickname == "")
	{
		Nickname = "Non-friend";
	}

	return Nickname;
}

function SetServerPassword(string password)
{
	if (IsLobbyOwner())
	{
		SetLobbyData("Password", password);
	}
}

defaultproperties
{
	bDebug=TRUE
	bWaitingForServer=FALSE
}

`endif