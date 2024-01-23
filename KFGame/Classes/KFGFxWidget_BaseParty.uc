//=============================================================================
// KFGFxWidget_BaseParty
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 11/14/2013
//=============================================================================

class KFGFxWidget_BaseParty extends KFGFxObject_Container;

var localized string ReadyString, LeaveString, DefaultPlayerName, SquadString, SoloString, CreatePartyString, WaitingString, DeployingString, PlayerReadyString, PartyLeaderString, SkipTraderString;
var localized string MuteString, UnmuteString, AddFriendString, RemoveFriendString, ViewProfileString, VoteKickString;// Profile options
var localized string PartyLeaderSearchingForMatchString, PartyLeaderIsUpdatingMatchOptionsString, PartyLeaderInServerBrowserString, PartyLeaderInOtherMenuString, SearchingForGameString, CreatingGameString;
var localized string PartHostLeftString, PartyLeaderChangedString;
var localized string DownLoadingString, RemainingString;
var localized string MatchOverString;//text used to tell the player the match is over
var localized string PauseGameString;
var localized string ResumeGameString;

var OnlineSubsystem OnlineSub;
var TWOnlineLobby OnlineLobby;
var bool bInLobby;
var KFPlayerController KFPC;
var KFGFxHUD_ChatBoxWidget PartyChatWidget;
var const string PerkPrefix;
var const string SearchingPrefix, ServerBrowserOpen, SearchingForGame, CreatingGame, UpdatingOptions, InOtherMenu;
var const string ViewProfileKey, AddFriendKey, KickKey, MuteKey;
var int OccupiedSlots;
var UniqueNetId LastLeaderID;
var KFGfxMoviePlayer_Manager Manager;

var GFxObject ReadyButton;
var GFxObject LeaveButton;
var GFxObject CreatePartyButton;
var GFxObject SquadHeader;
var GFxObject Notification;
var GFxObject MatchStartContainer;
var GFxObject EndlessPauseButton;

var int PlayerSlots;

var const UniqueNetId ZeroUniqueId;

var bool bReadyButtonVisible;
var bool bCreatePartyVisible;


struct SMemberSlot
{
	var bool	bIsReady;
	var bool	bIsLeader;
	var string	PerkLevel;
	var string	PrestigeLevel;
	var class<KFPerk>	PerkClass;
	var Texture2D Avatar;
	var UniqueNetId	PlayerUID;
	var transient GFxObject MemberSlotObject;
	var PlayerReplicationInfo PRI;
};

var SMemberSlot MemberSlots[`KF_MAX_PLAYERS_VERSUS];

function InitializeWidget()
{
	local int SlotIndex;
	KFPC = KFPlayerController(GetPC());
	OnlineSub = KFPC.OnlineSub;
	if (OnlineSub != none)
	{
		OnlineLobby = OnlineSub.GetLobbyInterface();
	}

	for (SlotIndex = 0; SlotIndex < PlayerSlots; SlotIndex++)
	{
		InitializeMemberSlot(SlotIndex);
	}

	LeaveButton = GetObject("leaveButton");
	CreatePartyButton = GetObject("createPartyButton");
	SetBool("partyButtonVisible", bCreatePartyVisible);
	ReadyButton = GetObject("readyButton");
	SquadHeader = GetObject("squadHeader");
	MatchStartContainer = GetObject("matchStartContainer");
	EndlessPauseButton = GetObject("endlessPauseButton");

	InitNotificationUI();

	LocalizeText();

	UpdateInLobby(Manager.IsInLobby());
	RefreshParty();
	SetBool("matchOver", false);

	SetBool("endlessPauseButtonVisible", false);
}

function  LocalizeText()
{
	local GFxObject TextObject;
	local KFGameReplicationInfo KFGRI;
	local WorldInfo TempWorldInfo;

	TextObject = CreateObject("Object");

	TextObject.SetString("readyString", ReadyString);
	TextObject.SetString("leaveString", LeaveString);
	TextObject.SetString("createPartyString", CreatePartyString);
	TextObject.SetString("deployingString", DeployingString);
	TextObject.SetString("waitingString", WaitingString);
	TextObject.SetString("selectPromptString", Localize("KFGFxWidget_ButtonPrompt", "ConfirmString", "KFGame"));
	TextObject.SetString("backPromptString", Localize("KFGFxWidget_ButtonPrompt", "CancelString", "KFGame"));
	TextObject.SetString("matchOver", MatchOverString);
	
	TempWorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if ( TempWorldInfo != none && TempWorldInfo.GRI != none )
	{
		KFGRI = KFGameReplicationInfo(TempWorldInfo.GRI);
		if ( KFGRI != none )
		{
			SetString("endlessPauseString", KFGRI.bIsEndlessPaused ? ResumeGameString : PauseGameString);
		}
	}

	SetObject("localizedText", TextObject);
}

function InitNotificationUI()
{
	Notification = GetObject("Notification");

	//@Josh Assign delgate here
	//OnlineSub.DownloadNotification = ShowDownLoadNotification;
}

function UpdateReadyButtonVisibility();

function ShowDownLoadNotification(string ItemName, Float PercentComplete)
{
	local GFxObject NotificationInfoObject;

	if(Notification == none)
	{
		return;
	}

	NotificationInfoObject = CreateObject("Object");

	NotificationInfoObject.SetString("itemName"		, ItemName);
	NotificationInfoObject.SetFloat("percent"		, PercentComplete * 100);
	NotificationInfoObject.SetInt("queue"		, 0);
	NotificationInfoObject.SetString("downLoading"	, DownLoadingString);
	NotificationInfoObject.SetString("remaining"		, class'KFCommon_LocalizedStrings'.default.CancelString @"- F10");

	Notification.SetObject("notificationInfo", NotificationInfoObject);
}

function SetSearchingText(string Message){}

function InitializeMemberSlot( int SlotIndex )
{
	MemberSlots[SlotIndex].MemberSlotObject = GetObject("squadMember" $ SlotIndex);
}

function bool isUserYourFriend(UniqueNetId PlayerID) 
{	
	return true;
}

function CreatePlayerOptions(UniqueNetId PlayerID, int SlotIndex)
{
	local PlayerController PC;
	//local bool bConsoleBuild;
	local GFxObject DataProvider;
	local int OptionIndex;
	local string ProfileString;
	local array< KFPlayerReplicationInfo > PRIs;
	local KFGameReplicationInfo KFGRI;
	local WorldInfo TempWorldInfo;

	TempWorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if ( TempWorldInfo != none && TempWorldInfo.GRI != none )
	{
		KFGRI = KFGameReplicationInfo(TempWorldInfo.GRI);

		if ( KFGRI != none )
		{
			KFGRI.GetKFPRIArray(PRIs);
		}
	}

	DataProvider = CreateArray();
	OptionIndex=0;
	DataProvider.SetInt("index", SlotIndex);
	PC = GetPC();
	//Clear the profile options
	//bConsoleBuild = PC.WorldInfo.IsConsoleBuild();

	if(PlayerID != PC.PlayerReplicationInfo.UniqueId)
	{
		if( !PC.WorldInfo.IsMenuLevel() ) //temp for now since voip and such does not work in the main menu
		{
			AddStringOptionToList(MuteKey, OptionIndex, PC.IsPlayerMuted(PlayerID) ? UnmuteString : MuteString, DataProvider); 
			OptionIndex++;
			if(PRIs.length > 2)
			{
				AddStringOptionToList(KickKey, OptionIndex, VoteKickString, DataProvider); 
				OptionIndex++;
			}
		}
	}

	

	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
	{
		ProfileString = ConsoleLocalize("ViewProfileString", "KFGFxWidget_BaseParty");
	}
	else if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
	{
		// Only show this option if we are logged in
		if( KFGameEngine(class'Engine'.static.GetEngine()).LocalLoginStatus == LS_LoggedIn )
		{
			ProfileString = ConsoleLocalize("ViewProfileStringXB1", "KFGFxWidget_BaseParty");
		}
	}
	else
	{
		ProfileString = ViewProfileString;
	}

	// Only add this option if there's something to show
	if( ProfileString != "" )
	{
		//View profile option Added at the end if we are on PC but first on console.
		if (isPlayerFromSteam(PlayerID) || class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) || class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
		{
			AddStringOptionToList(ViewProfileKey, OptionIndex, ProfileString, DataProvider);
		}
	}

	OptionIndex++;

	SetObject("listOptions", DataProvider);
}

function bool isPlayerFromSteam(UniqueNetId PlayerID)
{
	local PlayerReplicationInfo CurrentPRI;
	CurrentPRI = KFPC.GetPRIFromNetId(PlayerID);
	
	`Log("isPlayerFromSteam");
	`Log("!class'WorldInfo'.static.IsEOSBuild(): " $(!class'WorldInfo'.static.IsEOSBuild()));
	
	`Log("CurrentPRI.PlayfabPlayerId: " $(CurrentPRI != none ? CurrentPRI.PlayfabPlayerId : "CurrentPRI was NULL"));

	return !class'WorldInfo'.static.IsEOSBuild() && CurrentPRI != none && CurrentPRI.PlayfabPlayerId == "";
}

function AddStringOptionToList(string OptionKey, int ItemIndex, string Option, out GFxObject DataProvider)
{
	local GFxObject StringOption;

	StringOption = CreateObject("Object");
	StringOption.SetString("optionKey", OptionKey);
	StringOption.SetString("label", Option);

	DataProvider.SetElementObject(ItemIndex, StringOption);
}

event SoloGameMenuOpened(){}

function UpdateInLobby(bool bIsInLobby)
{
	local bool bShouldShowCreateParty;

	if(bIsInLobby != bInLobby)
	{
		bInLobby = bIsInLobby;
		RefreshParty();
	}
	
	if (bInLobby)
	{
		if(class'WorldInfo'.static.IsMenuLevel())
		{
			LeaveButton.SetVisible(true);
		}
		else
		{
			LeaveButton.SetVisible(false);
		}
	}
	else
	{	
		LeaveButton.SetVisible(false);

		//clear all party buttons other than your own
	}
	//@HSL_BEGIN - JRO - Handle the create party button in both situations for PS4
	if ( Manager.StartMenu != None)
	{
		if(GetPC().WorldInfo.IsMenuLevel())
		{
			bShouldShowCreateParty = !bInLobby && EStartMenuState(Manager.StartMenu.GetStartMenuState()) != ESoloGame;
		}
		else if(class'WorldInfo'.static.IsConsoleBuild())
		{
			bShouldShowCreateParty = GetPC().WorldInfo.NetMode != NM_Standalone && !bInLobby;
		}
		
		if(bCreatePartyVisible != bShouldShowCreateParty)
		{
			bCreatePartyVisible = bShouldShowCreateParty;
			SetBool("partyButtonVisible",bCreatePartyVisible);
		}
	}

	//@HSL_END
	SetBool("bInParty", bIsInLobby);
}

function  UpdateSoloSquadText()
{
	if(occupiedSlots > 1)
	{
		SquadHeader.SetString("text", SquadString);
	}
	else
	{
		SquadHeader.SetString("text", SoloString);
	}
}

function ProfileOptionClicked(string OptionKey, int SlotIndex)
{
    switch (OptionKey)
    {
	    case AddFriendKey:
	        AddFriend(SlotIndex);
	       	break;
	    case MuteKey:
	        ToggelMuteOnPlayer(SlotIndex);
	        break;
	    case KickKey:
	        KickPlayer(SlotIndex);
	        break;
	    case ViewProfileKey:
	        ViewProfile(SlotIndex);
	        break;
	    default:
	        ViewProfile(SlotIndex);
    }
}

function bool IsPlayerAFriend(UniqueNetId PlayerID)
{
	local LocalPlayer LocPlayer;
	
	LocPlayer = LocalPlayer(GetPC().Player);

	if(LocPlayer == none)
	{
		return false;
	}
	if(OnlineSub == none)
	{
		return false;
	}
	return OnlineSub.IsFriend(LocPlayer.ControllerId,PlayerID);
}

//Override these in MaineMenu and InGame party widgets so that they can get the Unique id of the players in the slots view PRIarray or lobby 
function ToggelMuteOnPlayer(int SlotIndex)
{
	RefreshParty();
}

function ViewProfile(int SlotIndex)
{
}

function AddFriend(int SlotIndex)
{
	//Override this in child classes
}

function RemoveFriend(int SlotIndex)
{
	
}

function KickPlayer(int SlotIndex)
{
	
}

/****************************************************************************
*	@VOIP
****************************************************************************/

function UpdateVOIP(PlayerReplicationInfo PRI, bool bIsTalking);

/****************************************************************************
*	Refresh
****************************************************************************/

// Refresh a slot if any of it's values have changed or a player was removed
function RefreshParty()
{
	OccupiedSlots = 0; //reset each time to make sure bIsInParty is correct
	UpdateLock();
}

//maybe pass player id here?
function OpenPlayerList(int SlotIndex)
{
	CreatePlayerOptions(MemberSlots[SlotIndex].PlayerUID, SlotIndex);
}

function SetReadyButtonVisibility(bool bVisible, optional bool bShowDeployTimer = true)
{
	SetBool("readyButtonVisible", bVisible);
	if (MatchStartContainer != none)
	{
		MatchStartContainer.SetVisible(bShowDeployTimer && bVisible);
	}
}

function bool ReceiveMessage(string Message, optional string MessageColor)
{	
	local array<string> PlayerInfoStrings;
	ParseStringIntoArray(Message, PlayerInfoStrings, PerkPrefix, true);
	
	// Perk update message
	if (InStr(Message, PerkPrefix) != -1)
	{
		UpdatePerks(repl(Message, PerkPrefix, ""));
		return false;
	}
	if(InStr(Message, SearchingPrefix) != -1)
	{
		UpdateSearching(repl(Message, SearchingPrefix, ""));
		return false;
	}
	// Send to chat box		
	if( PartyChatWidget != none )
	{
		if(MessageColor != "")
		{
			PartyChatWidget.AddChatMessage(message, MessageColor);	
		}
		else
		{
			PartyChatWidget.AddChatMessage(message, class 'KFLocalMessage'.default.SayColor);
		}
	}
	return true;
}

function UpdateLock()
{
	local WorldInfo TempWorldInfo;
	local KFGameReplicationInfo KFGRI;
	local bool bLocked;

	TempWorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if ( TempWorldInfo != none && TempWorldInfo.GRI != none )
	{
		KFGRI = KFGameReplicationInfo(TempWorldInfo.GRI);

		if ( KFGRI != none && KFPC != none )
		{
			bLocked = ( KFGRI.CanChangePerks() && !KFPC.CanUpdatePerkInfo() );
			SetBool( "locked", bLocked);
		}
	}
}

// As a member of party, check to see if your options are different than the party leaders
function UpdatePerks(string Message);

function UpdateSearching(string Message);

function SendSearching();


function StartCountdown(int CountdownTime, bool bFinalCountdown)
{
	ActionScriptVoid("startCountdown");
}

/**
 * @brief Tells AS to stop the countdown
 */
function StopCountdown()
{
	ActionScriptVoid("stopCountdown");
}

DefaultProperties
{
	bCreatePartyVisible=true
	PlayerSlots=6
	//defaults
	bReadyButtonVisible=true
	PerkPrefix="%&1&%" //@HSL - JRO - Also copied in KFOnlineLobbyNP::LobbyMessage(). Needed to cache the messages so as not to spam the network
	SearchingPrefix="%&2&%"
	ServerBrowserOpen="ServerBrowser"
	SearchingForGame="SearchingForGame"
	UpdatingOptions="UpdatingOptions"
	InOtherMenu="InOtherMenu"

	ViewProfileKey="ViewProfile"
	AddFriendKey="AddFriend"
	KickKey="Kick"
	MuteKey="Mute"
}