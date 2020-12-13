//=============================================================================
// KFGFxWidget_PartyMainMenu
//=============================================================================
// The party widget that is used while in the main menu that uses the steam party system
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 11/14/2013
//=============================================================================

class KFGFxWidget_PartyMainMenu extends KFGFxWidget_BaseParty;

var bool bIsInParty;
var int prevMemberCount;

function OneSecondLoop()
{
	local bool IsInLobby;
	RefreshParty(); //@HSL - JRO - Moving this here so the +people icons properly go away when leaving parties
	//@SABER_EGS_BEGIN EOS
	if (class'WorldInfo'.static.isEOSBuild())
	{
		IsInLobby = bIsInParty;
	} 
	else 
	{
		IsInLobby = OnlineLobby != none && OnlineLobby.IsInLobby();
	}
	//@SABER_EGS_END
	if (IsInLobby)
	{
	    SendMyOptions();
	    SendSearching();
	    UpdateInLobby(true);
	}	
	else
	{
		//@HSL_BEGIN - JRO - 8/3/2016 - Make sure non-leader members don't get stuck in the overview screen when leaving a party
		if(class'WorldInfo'.static.IsConsoleBuild() && prevMemberCount != 0 && Manager != none && Manager.StartMenu != none)
		{
			Manager.StartMenu.ShowOverview(false, false, true, false);
		}
		//@HSL_END
		prevMemberCount = 0;
		UpdateInLobby(false);
	}
}

function InitializeWidget()
{
	super.InitializeWidget();
	SetReadyButtonVisibility(false);
}

event SoloGameMenuOpened()
{
	OneSecondLoop();
}

function SendSearching()
{
	local string SearchingTextString;
	local string SearchingMessage;
	local UniqueNetId AdminId;
	local bool bIsLeader;

	if(Manager == none)
	{
		return;
	}

	if(OnlineLobby != none && OnlineLobby.IsInLobby())
	{
		OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
		bIsLeader = OnlineLobby.GetMyId() == AdminId && AdminId != ZeroUniqueId;

		if(bIsLeader)
		{
			if(Manager.CurrentMenuIndex == UI_Start)
			{
				if(Manager.bSearchingForGame)
				{
					SearchingTextString = SearchingForGameString;
					SetSearchingText(SearchingTextString);
					SearchingMessage = SearchingForGame;
				}
				//@HSL_BEGIN - JRO - PS4 supports parties outside of multiplayer menus
				else if(Manager.StartMenu.GetStartMenuState() == EMatchmaking)
				{
					SearchingMessage = UpdatingOptions;
				}
				else if (Manager.StartMenu.GetStartMenuState() == ECreateGame)
				{
					SearchingMessage = CreatingGame;
				}
				else
				{
					SearchingMessage = InOtherMenu;
				}
				//@HSL_END
			}
			else if(Manager.CurrentMenuIndex == UI_ServerBrowserMenu)
			{
				SearchingMessage = ServerBrowserOpen;
			}
			else
			{
				SearchingMessage = InOtherMenu;
			}
			//Send message out to lobby
			OnlineLobby.LobbyMessage(SearchingPrefix$SearchingMessage);   	
		}
	}
	else if(Manager.bSearchingForGame)
	{
		SearchingTextString = SearchingForGameString;
		SetSearchingText(SearchingTextString);
	}
	else
	{
		SetSearchingText(SearchingTextString);
	}
}

function SetSearchingText(string Message)
{
	SetString("searchingText", Message);
}

// Refresh a slot if any of it's values have changed or a player was removed
function RefreshParty()
{
	local ActiveLobbyInfo LobbyInfo;
	local UniqueNetId AdminId;
	local int SlotIndex;
	local bool bInParty;
	local PlayerController PC;
	local GFxObject DataProvider;
	DataProvider = CreateArray();

	if(Manager.CurrentMenuIndex == UI_IIS)
	{
		return;
	}

	super.RefreshParty();
	
	if ( OnlineLobby != none && OnlineLobby.GetCurrentLobby(LobbyInfo) )
	{
		
		OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);

		if(PartyChatWidget != none)
		{
			PartyChatWidget.SetLobbyChatVisible(LobbyInfo.Members.Length > 1);
		}

		if( AdminId != LastLeaderID )
		{	
			HandleLeaderChange(AdminId);	
		}		

		OccupiedSlots = LobbyInfo.Members.Length;

		bInParty = (OccupiedSlots > 1) || bInLobby;

		if(bIsInParty != bInParty)
		{
			bIsInParty = bInParty;
		}

		for (SlotIndex = 0; SlotIndex < LobbyInfo.Members.Length; SlotIndex++)
		{
           DataProvider.SetElementObject(SlotIndex, RefreshSlot(SlotIndex, LobbyInfo.Members[SlotIndex].PlayerUID) );
       	}		
	}
	// If we are not in a party, only add our name to the party list
	else
	{
		PC = GetPC();
		DataProvider.SetElementObject(0, RefreshSlot(0, PC.PlayerReplicationInfo.UniqueId));
	
		LastLeaderID = ZeroUniqueId;
	    bInParty = false || bInLobby;
		bIsInParty = bInParty;
	    SetSearchingText("");
	    
	    if(PartyChatWidget != none)
		{
	    	PartyChatWidget.SetLobbyChatVisible(false);
		}
	}
	SetObject("squadInfo", DataProvider);
	UpdateSoloSquadText();
}

function HandleLeaderChange(UniqueNetId AdminId)
{
	Manager.HandleSteamLobbyLeaderTakeOver(AdminId);
	if(LastLeaderID != ZeroUniqueId )
	{
		if (class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis))
		{
			Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, PartHostLeftString, "", class'KFCommon_LocalizedStrings'.default.OKString);
			//party disband
			if (OnlineLobby != none && OnlineLobby.IsInLobby())
			{
				OnlineLobby.QuitLobby();
				//Manager.StartMenu.OpenMultiplayerMenu();
				//exit overview and open ESTART_HOME
			}
			Manager.SetStartMenuState(EStartHome, true);
		}
		else
		{
			Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, PartHostLeftString, PartyLeaderChangedString, class'KFCommon_LocalizedStrings'.default.OKString);
		}
		
	}
	LastLeaderID = AdminId;
}

// Check which aspect of the slot has changed and update it
function GFxObject RefreshSlot(int SlotIndex, UniqueNetId PlayerUID)
{
	local string PlayerName,ReadablePlayerName;	
	local UniqueNetId AdminId;
	local bool bIsLeader;
	local bool bIsMyPlayer;
	local PlayerController PC;
	local GFxObject PlayerInfoObject, PerkIconObject;
	local KFPerk CurrentPerk;
	local string AvatarPath;
	local KFPlayerReplicationInfo KFPRI;

	PlayerInfoObject = CreateObject("Object");

	PC = GetPC();
	if(OnlineLobby != none)
	{
		OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
	}	
	//leader
	bIsLeader = (PlayerUID == AdminId && PlayerUID != ZeroUniqueId);
	PlayerInfoObject.SetBool("bLeader", bIsLeader);
	//my player
	bIsMyPlayer = OnlineLobby != none && OnlineLobby.GetMyId() == PlayerUID;
	PlayerInfoObject.SetBool("myPlayer", bIsMyPlayer);
	//perk info
	if(bIsMyPlayer)
	{
		CurrentPerk = KFPC.GetPerk();
		if (CurrentPerk != none)
		{			
			KFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);
			MemberSlots[SlotIndex].PerkClass = KFPRI.CurrentPerkClass;

			PlayerInfoObject.SetString("perkLevel", CurrentPerk.GetLevel() @CurrentPerk.PerkName );
			PerkIconObject = CreateObject("Object");
			PerkIconObject.SetString("perkIcon", "img://"$MemberSlots[SlotIndex].PerkClass.static.GetPerkIconPath());
			PerkIconObject.SetString("prestigeIcon", MemberSlots[SlotIndex].PerkClass.static.GetPrestigeIconPath(KFPRI.GetActivePerkPrestigeLevel()));
			PlayerInfoObject.SetObject("perkImageSource", PerkIconObject);
		}
	}
	else
	{
		//muted
		PlayerInfoObject.SetBool("muted", PC.IsPlayerMuted(PlayerUID));
		//perk info
		if(MemberSlots[SlotIndex].PerkClass != none)
		{
			PlayerInfoObject.SetString("perkLevel", MemberSlots[SlotIndex].PerkLevel @MemberSlots[SlotIndex].PerkClass.default.PerkName);

			PerkIconObject = CreateObject("Object");
			PerkIconObject.SetString("perkIcon", "img://"$MemberSlots[SlotIndex].PerkClass.static.GetPerkIconPath());
			//player name 			
			PerkIconObject.SetString("prestigeIcon", MemberSlots[SlotIndex].PerkClass.static.GetPrestigeIconPath(byte(MemberSlots[SlotIndex].PrestigeLevel)));
			
			PlayerInfoObject.SetObject("perkImageSource", PerkIconObject);
		}
		
	}
	//player name 
	if(OnlineLobby != none)
	{
		PlayerName = OnlineLobby.GetFriendNickname(PlayerUID);
	}
	
	if (PlayerName == "")
	{
		ReadablePlayerName = PC.PlayerReplicationInfo.GetHumanReadableName();
		PlayerName = ReadablePlayerName == DefaultPlayerName ? DefaultPlayerName$SlotIndex : ReadablePlayerName;
	}
	
	PlayerInfoObject.SetString("playerName", PlayerName);
	//player icon

	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
	{
		AvatarPath = KFPC.GetPS4Avatar(PlayerName);
	}
	else
	{
		AvatarPath = KFPC.GetSteamAvatar(PlayerUID);
	}	

	if(AvatarPath != "")
	{
		PlayerInfoObject.SetString("profileImageSource", "img://"$AvatarPath);
	}

	MemberSlots[SlotIndex].PlayerUID = PlayerUID;	

	return PlayerInfoObject;
}

/****************************************************************************
*	Sending / Receiving steam data
****************************************************************************/

// As a member of party, check to see if your options are different than the party leaders
function UpdatePerks(string Message)
{
	local array<string> PlayerInfoStrings;
	local UniqueNetId PlayerID;
	local string PerkLevel, PrestigeLevel;
	local ActiveLobbyInfo LobbyInfo;
	local int i;
	local int PerkIndex;

	ParseStringIntoArray(Message, PlayerInfoStrings, "/", true);
	class'OnlineSubsystem'.static.StringToUniqueNetId(PlayerInfoStrings[0], PlayerID);
	PerkIndex = int(PlayerInfoStrings[1]);
	PerkLevel = PlayerInfoStrings[2];
	PrestigeLevel = PlayerInfoStrings[3];

	if(OnlineLobby == none)
	{
		return;
	}

	if (OnlineLobby.GetCurrentLobby(LobbyInfo))
	{
		for (i = 0; i < LobbyInfo.Members.Length; i++)
		{
			UpdatePerkInfoForPlayerID(PlayerID, KFPC.PerkList[PerkIndex].PerkClass, PerkLevel, PrestigeLevel);
		}
	}
}

function UpdatePerkInfoForPlayerID(UniqueNetId PlayerID, class<KFPerk> PerkClass, string PerkLevel, string PrestigeLevel)
{
	local int i;
	
	for (i = 0; i < PlayerSlots; i++)
	{
		if(MemberSlots[i].PlayerUID == PlayerID)
		{			
			MemberSlots[i].PerkLevel = PerkLevel;
			MemberSlots[i].PerkClass = PerkClass;	
			MemberSlots[i].PrestigeLevel = PrestigeLevel;
			return;
		}
	}	
}


function PrintoutDebugMemberSlotInfo()
{
	local string PlayerName;
	local int i;
	
	for (i = 0; i < PlayerSlots; i++)
	{
		if (MemberSlots[i].PerkClass != none)
		{
			if (OnlineLobby != none)
			{
				PlayerName = OnlineLobby.GetFriendNickname(MemberSlots[i].PlayerUID);
			}
			else
			{
				`log("no online lobby.");
			}

			`log("$$ Printing INFO FOR: " @playerName @"Slot index" @MemberSlots[i].PerkClass @MemberSlots[i].PerkLevel @MemberSlots[i].PrestigeLevel);			
		}
	}
	`log("###end printing out debug info");
}

function UpdateSearching(string Message)
{
	local string SearchingText;
	local string PartyLeaderName;
	local UniqueNetId AdminId;

	if(Message == "")
	{
		SetSearchingText("");
		return;
	}
		
	if(OnlineLobby != none)
	{
		OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
		PartyLeaderName = OnlineLobby.GetFriendNickname(AdminId);
	}

	switch (Message)
	{
		case InOtherMenu:
			SearchingText = PartyLeaderInOtherMenuString;
			break;
	
		case ServerBrowserOpen:
			Manager.ChangeOverviewState(true);
			SearchingText = PartyLeaderInServerBrowserString;
			break;

		case SearchingForGame:
			SearchingText = PartyLeaderSearchingForMatchString;
			break;

		case UpdatingOptions:
			Manager.ChangeOverviewState(false);
			SearchingText = PartyLeaderIsUpdatingMatchOptionsString;
			break;

		case CreatingGame:
			Manager.ChangeOverviewState(false);
			SearchingText = CreatingGameString;
			break;

		case InOtherMenu:
			SearchingText = PartyLeaderInOtherMenuString;
			break;
	}

	SetSearchingText(PartyLeaderName @SearchingText);
}

function ToggelMuteOnPlayer(int SlotIndex)
{
	local ActiveLobbyInfo LobbyInfo;
	if( OnlineLobby != none )
	{
		OnlineLobby.GetCurrentLobby(LobbyInfo);
		if( LobbyInfo.Members.Length > SlotIndex )
		{
			`log("CALL MUTE FOR PLAYER: " @OnlineLobby.GetFriendNickname(LobbyInfo.Members[SlotIndex].PlayerUID) );
		}
	}
	super.ToggelMuteOnPlayer(SlotIndex);
}

function ViewProfile(int SlotIndex)
{
	local ActiveLobbyInfo LobbyInfo;
	if( OnlineLobby != none )
	{
		OnlineLobby.GetCurrentLobby(LobbyInfo);
		if( LobbyInfo.Members.Length > SlotIndex )
		{
			`log("View PLAYER profile: " @OnlineLobby.GetFriendNickname(LobbyInfo.Members[SlotIndex].PlayerUID) );
		}
	}

	if ( GetPC().WorldInfo.IsConsoleBuild(CONSOLE_Orbis) )
	{
		if( LobbyInfo.Members.Length > SlotIndex )
		{
			OnlineSub.PlayerInterfaceEx.ShowGamerCardUIByUsername(GetLP().ControllerId,OnlineLobby.GetFriendNickname(LobbyInfo.Members[SlotIndex].PlayerUID));
		}
		else
		{
			OnlineSub.PlayerInterfaceEx.ShowGamerCardUIByUsername(GetLP().ControllerId,OnlineSub.PlayerInterface.GetPlayerNickname(GetLP().ControllerId));
		}
	}
	else
	{
		OnlineSub.PlayerInterfaceEx.ShowGamerCardUI(GetLP().ControllerId,MemberSlots[SlotIndex].PlayerUID);
	}	
}

//Since the PRI Array doe not exist int he main menu, we are using the lobby to access PlayerUI's  
//Adding and removing friends through steam will just bring up the overlay.  From there the player will have to click 
//the option to add or remove them based on the friend status.
function AddFriend(int SlotIndex)
{
	local ActiveLobbyInfo LobbyInfo;
	local LocalPlayer LocPlayer;

	LocPlayer = LocalPlayer(GetPC().Player);

	if( OnlineLobby != none )
	{
		OnlineLobby.GetCurrentLobby(LobbyInfo);
		if( LobbyInfo.Members.Length > SlotIndex )
		{
			if( OnlineSub.IsFriend(LocPlayer.ControllerId, LobbyInfo.Members[SlotIndex].PlayerUID) )
			{
				if( !OnlineSub.RemoveFriend(LocPlayer.ControllerId, LobbyInfo.Members[SlotIndex].PlayerUID) )
				{
					`log("Failed to remove friend!");
				}
			}
			else
			{
				if( !OnlineSub.AddFriend(LocPlayer.ControllerId, LobbyInfo.Members[SlotIndex].PlayerUID) )
				{
					`log("Failed to add friend!");
				}
			}
		}
	}
}

// As the leader of the party, make sure the members have the latest information
function SendMyOptions()
{
	local KFPerk CurrentPerk;
	local int PerkIndex;
	local string CurrentLevel;
	local string PrestigeLevel;
	local string PerkMessage;
	local string UIDStrings;
	local UniqueNetId MyUniqueId;

	CurrentPerk = KFPC.GetPerk();
	PerkIndex = KFPC.GetPerkIndexFromClass(CurrentPerk.Class);
	CurrentLevel = string(KFPC.GetLevel());
	PrestigeLevel = string(KFPC.GetPerkPrestigeLevelFromPerkList(CurrentPerk.class));

	MyUniqueId = OnlineLobby.GetMyId();
	UIDStrings = class'OnlineSubsystem'.static.UniqueNetIdToString(MyUniqueId);
	PerkMessage = PerkPrefix$UIDStrings$"/"$string(PerkIndex)$"/"$CurrentLevel$"/"$PrestigeLevel;
	if(OnlineLobby != none)
	{
		OnlineLobby.LobbyMessage(PerkMessage);
	}
}

defaultproperties
{
	
}