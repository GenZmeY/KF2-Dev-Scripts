//=============================================================================
// KFGFxWidget_PartyInGame
//=============================================================================
// The party widget that is used while in game which usese the KFPlayerReplicationInfo to be updated
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 11/14/2013
//=============================================================================

class KFGFxWidget_PartyInGame extends KFGFxWidget_BaseParty;

var KFGameReplicationInfo KFGRI;
var KFPlayerReplicationInfo MyKFPRI;

var bool bShowingSkipTrader;

function InitializeWidget()
{
	super.InitializeWidget();
	SetReadyButtonVisibility(true);

	ReadyButton        = GetObject("readyButton");
	EndlessPauseButton = GetObject("endlessPauseButton");

	MyKFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);
	
	KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );
	if ( KFGRI != none )
	{
		StartCountdown(KFGRI.RemainingTime, false);		
	}	
	RefreshParty();
	UpdateReadyButtonVisibility();
	UpdateEndlessPauseButtonVisibility();
}

function UpdateReadyButtonText()
{
	Local bool bIsConsole;

	if (ReadyButton != none)
	{
		bIsConsole = GetPC().WorldInfo.IsConsoleBuild();

		if(bIsConsole && bShowingSkipTrader)
		{
			ReadyButton.SetString("label", ("  "@default.SkipTraderString));
		}
		else
		{
			ReadyButton.SetString("label", bShowingSkipTrader ? default.SkipTraderString : default.ReadyString);
		}
	}
}


function UpdateEndlessPauseButtonText()
{
	local bool bIsConsole;
	
	if (EndlessPauseButton != none)
	{
		bIsConsole = GetPC().WorldInfo.IsConsoleBuild();
		if(bIsConsole)
		{
			EndlessPauseButton.SetString("label", KFGRI.bIsEndlessPaused ? ("  "@default.ResumeGameString) : ("  "@default.PauseGameString));
		}
		else
		{
			EndlessPauseButton.SetString("label", KFGRI.bIsEndlessPaused ? default.ResumeGameString : default.PauseGameString);
		}
	}
}

function UpdateReadyButtonVisibility()
{
	if(KFGRI == none)
	{
		return;
	}
	if (MyKFPRI == none)
	{
		//sanity check because this is happening
		MyKFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);
	}
	if(bReadyButtonVisible)
	{
		KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );
		if ( KFGRI != none )
		{
			if (KFGRI.bMatchHasBegun && (MyKFPRI != none && MyKFPRI.bHasSpawnedIn && KFGRI.bTraderIsOpen) && !KFGRI.bMatchIsOver && MyKFPRI.GetTeamNum() != 255 )
			{
				bShowingSkipTrader = !MyKFPRI.bVotedToSkipTraderTime;
				if (bShowingSkipTrader && !ReadyButton.GetBool("visible"))
				{
					UpdateReadyButtonText();
					SetReadyButtonVisibility(true, false);
					ReadyButton.SetBool("selected", false);
				}
			}
			else
			{
				bShowingSkipTrader = false;
				UpdateReadyButtonText();
				
				//@HSL_BEGIN - JRO - 9/9/2016 - Blind fix for ready button sometimes disappearing when the wave ends
				if (KFGRI.bMatchHasBegun && !KFGRI.bMatchIsOver && MyKFPRI != none && !MyKFPRI.bReadyToPlay && !MyKFPRI.bHasSpawnedIn)
				{
					SetReadyButtonVisibility(true);
				}
				//@HSL_END

				if (KFGRI.bMatchHasBegun || KFGRI.bMatchIsOver)
				{
					if (GetPC().PlayerReplicationInfo.bReadyToPlay || KFGRI.bMatchIsOver)
					{
						SetReadyButtonVisibility(false);
					}
				}
				else if (GetPC().WorldInfo.NetMode == NM_Standalone && MyKFPRI != none)
				{
					MatchStartContainer.SetVisible(MyKFPRI.bReadyToPlay); //hide the waiting for players text when alone		
				}
				SetBool("matchOver", KFGRI.bMatchIsOver);
			}
		}
	}
}

function UpdateEndlessPauseButtonVisibility()
{
	if(KFGRI == none)
	{
		return;
	}

	if (MyKFPRI == none)
	{
		//sanity check because this is happening
		MyKFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);
	}

	if (GetPC().WorldInfo.NetMode != NM_Standalone && KFGRI.bMatchHasBegun && (MyKFPRI != none && MyKFPRI.bHasSpawnedIn && !KFGRI.bWaveIsActive) && !KFGRI.bMatchIsOver && KFGRI.bEndlessMode)
	{

		UpdateEndlessPauseButtonText();

//		if (!MyKFPRI.bVotedToPauseGame)
//		{
			SetBool("endlessPauseButtonVisible", true);
//		}
	}
	else
	{
		SetBool("endlessPauseButtonVisible", false);
	}
	
	if (EndlessPauseButton != none)
	{
		EndlessPauseButton.SetBool("selected", false);
	}
}

/****************************************************************************
*	Slot Component Updates
****************************************************************************/
function OneSecondLoop()
{
	if(KFGRI == none)
	{
		KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );
	}
	RefreshParty();
	UpdateReadyButtonVisibility();
	UpdateEndlessPauseButtonVisibility();
}

//==============================================================
// @VOIP
//==============================================================

function UpdateVOIP(PlayerReplicationInfo PRI, bool bIsTalking)
{
	local int i;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(PRI);

	for (i = 0; i < PlayerSlots; i++)
	{
		if(MemberSlots[i].PlayerUID == KFPRI.UniqueId)
		{
			// TODO:  Right now we are using VOIPStatus to determine if someone is talking.  This does not take into account if we SHOULD show that someone is talking 
			// (i.e. Player 1 mutes Player 2.  Right now Player 2 can see that Player 1 is still talking. )
			MemberSlots[i].MemberSlotObject.SetBool("isTalking", bIsTalking);
		}
	}
}

//==============================================================
// Refreshing
//==============================================================

function GetKFPRIArray( out array<KFPlayerReplicationInfo> KFPRIArray )
{
	local PlayerController PC;

	PC = GetPC();

	if ( PC == none || PC.WorldInfo == none || PC.WorldInfo.GRI == none )
	{
	 	return;
	}

	if ( KFGRI != none )
	{
	 	KFGRI.GetKFPRIArray( KFPRIArray );
	}
}

// Calls the lobby component to see if a refresh is necessary and updates the necessary data
function RefreshParty()
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local int SlotIndex;
	local GFxObject DataProvider;
	DataProvider = CreateArray();
	if(!Manager.bStatsInitialized)
	{
		return;
	}	
	super.RefreshParty();

	GetKFPRIArray( KFPRIArray );
	if ( KFPRIArray.Length <= 0 )
	{
	 	return;
	}
	if(PartyChatWidget != none)
	{
		PartyChatWidget.SetLobbyChatVisible(KFPRIArray.Length > 1);
	}

	UpdateInLobby(KFPRIArray.Length > 1);		

	OccupiedSlots = KFPRIArray.Length;
	
	for ( SlotIndex = 0; SlotIndex < PlayerSlots; SlotIndex++ )
	{
		if ( SlotIndex < KFPRIArray.Length )
		{
			DataProvider.SetElementObject(SlotIndex, RefreshSlot(SlotIndex, KFPRIArray[SlotIndex]) );
		}
	}
	SetBool("bInParty", bInLobby || ( GetPC().WorldInfo.NetMode != NM_Standalone ));
	SetObject("squadInfo", DataProvider);
	UpdateSoloSquadText();
}

// Check which aspect of the slot has changed and update it
function GFxObject RefreshSlot(int SlotIndex, KFPlayerReplicationInfo KFPRI)
{
	local string PlayerName;	
	local UniqueNetId AdminId;
	local bool bIsLeader;
	local bool bIsMyPlayer;
	local PlayerController PC;
	local GFxObject PlayerInfoObject, PerkIconObject;
	local string AvatarPath;

	PlayerInfoObject = CreateObject("Object");

	PC = GetPC();

	if(OnlineLobby != none)
	{
		OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
	}
	
	//leader
	bIsLeader = (KFPRI.UniqueId == AdminId && AdminId != ZeroUniqueId);
	PlayerInfoObject.SetBool("bLeader", bIsLeader);
	//my player
	bIsMyPlayer = PC.PlayerReplicationInfo.UniqueId == KFPRI.UniqueId;
	MemberSlots[SlotIndex].PlayerUID = KFPRI.UniqueId;
	MemberSlots[SlotIndex].PRI = KFPRI;
	MemberSlots[SlotIndex].PerkClass = KFPRI.CurrentPerkClass;
	MemberSlots[SlotIndex].PerkLevel = String(KFPRI.GetActivePerkLevel());
	MemberSlots[SlotIndex].PrestigeLevel = String(KFPRI.GetActivePerkPrestigeLevel());
	
	PlayerInfoObject.SetBool("myPlayer", bIsMyPlayer);

	//perk info
	if(MemberSlots[SlotIndex].PerkClass != none)
	{
		PlayerInfoObject.SetString("perkLevel", MemberSlots[SlotIndex].PerkLevel @MemberSlots[SlotIndex].PerkClass.default.PerkName); //separate from icon

		PerkIconObject = CreateObject("Object");
		PerkIconObject.SetString("perkIcon", "img://"$MemberSlots[SlotIndex].PerkClass.static.GetPerkIconPath());
		PerkIconObject.SetString("prestigeIcon", MemberSlots[SlotIndex].PerkClass.static.GetPrestigeIconPath(KFPRI.GetActivePerkPrestigeLevel()));

		PlayerInfoObject.SetObject("perkImageSource", PerkIconObject);
	}
	//perk info
	if(!bIsMyPlayer)
	{
		PlayerInfoObject.SetBool("muted", PC.IsPlayerMuted(KFPRI.UniqueId));	
	}
	
	
	// E3 build force update of player name
	if( class'WorldInfo'.static.IsE3Build() )
	{
		// Update this slots player name
		PlayerName = KFPRI.PlayerName;
	}
	else
	{
		PlayerName = KFPRI.PlayerName;
	}
	PlayerInfoObject.SetString("playerName", PlayerName);
	//player icon
	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
	{
		AvatarPath = KFPC.GetPS4Avatar(PlayerName);
	}
	else
	{
		AvatarPath = KFPC.GetSteamAvatar(KFPRI.UniqueId);
	}	

	if(AvatarPath != "")
	{
		PlayerInfoObject.SetString("profileImageSource", "img://"$AvatarPath);
	}
	if(KFGRI != none)
	{
		PlayerInfoObject.SetBool("ready", KFPRI.bReadyToPlay && !KFGRI.bMatchHasBegun);
	}

	return PlayerInfoObject;	
}


function ToggelMuteOnPlayer(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local UniqueNetId PlayerNetID;
	local PlayerController PC;

	PC = GetPC();
	GetKFPRIArray( KFPRIArray );

	if ( KFPRIArray.Length <= 0 )
	{
	 	return;
	}

	if( KFPRIArray.Length > SlotIndex )
	{
		PlayerNetID = KFPRIArray[SlotIndex].UniqueId;
		if(PC.IsPlayerMuted(PlayerNetID))
		{
			PC.ServerUnMutePlayer(PlayerNetID, !class'WorldInfo'.static.IsConsoleBuild()); //@HSL - JRO - 8/2/2016 - 1-way muting on consoles
			if ( MemberSlots[SlotIndex].MemberSlotObject != None )
			{
				MemberSlots[SlotIndex].MemberSlotObject.SetBool("isMuted",false);
			}
		}
		else
		{
			PC.ServerMutePlayer(PlayerNetID, !class'WorldInfo'.static.IsConsoleBuild()); //@HSL - JRO - 8/2/2016 - 1-way muting on consoles
			if ( MemberSlots[SlotIndex].MemberSlotObject != None )
			{
				MemberSlots[SlotIndex].MemberSlotObject.SetBool("isMuted",true);
			}	
		}
	}
	super.ToggelMuteOnPlayer(SlotIndex);
}

function ViewProfile(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	GetKFPRIArray( KFPRIArray );

	if ( KFPRIArray.Length <= 0 || OnlineSub == None || OnlineSub.PlayerInterfaceEx == None )
	{
	 	return;
	}

	if( KFPRIArray.Length > SlotIndex )
	{
		//KFPRIArray[SlotIndex].UniqueId
		//OnlineSub.PlayerInterfaceEx.ShowGamerCardUIByUsername(GetLP().ControllerId,KFPRIArray[SlotIndex].PlayerName);
		if ( GetPC().WorldInfo.IsConsoleBuild(CONSOLE_Orbis) )
		{
			OnlineSub.PlayerInterfaceEx.ShowGamerCardUIByUsername(GetLP().ControllerId,KFPRIArray[SlotIndex].PlayerName);

		}
		else
		{
			OnlineSub.PlayerInterfaceEx.ShowGamerCardUI(GetLP().ControllerId,KFPRIArray[SlotIndex].UniqueId);
		}
		`log("View PLAYER profile: "@KFPRIArray[SlotIndex].PlayerName);
	}
}

//Use the pri array to access the player's UID to send to steam interface. 
//Adding and removing friends through steam will just bring up the overlay.  From there the player will have to click 
//the option to add or remove them based on the friend status.
function AddFriend(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local LocalPlayer LocPlayer;

	GetKFPRIArray( KFPRIArray );

	LocPlayer = LocalPlayer(GetPC().Player);

	if(LocPlayer == none)
	{
		return;
	}

	if ( KFPRIArray.Length <= 0 )
	{
	 	return;
	}

	if( SlotIndex < KFPRIArray.Length )
	{
		if( OnlineSub.IsFriend(LocPlayer.ControllerId,KFPRIArray[SlotIndex].UniqueId))
		{
			if( !OnlineSub.RemoveFriend( LocPlayer.ControllerId, KFPRIArray[SlotIndex].UniqueId ) )
			{
				`log("Failed to remove friend!");
			}
		}
		else
		{
			if( !OnlineSub.AddFriend( LocPlayer.ControllerId, KFPRIArray[SlotIndex].UniqueId ) )
			{
				`log("Failed to add friend!");
			}
		}
	}
}

function KickPlayer(int SlotIndex)
{
	local array<KFPlayerReplicationInfo> KFPRIArray;

	GetKFPRIArray( KFPRIArray );	

	if( KFPRIArray.Length <= 0 )
	{
	 	return;
	}

	if( SlotIndex < KFPRIArray.Length )
	{
		KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo).ServerStartKickVote(KFPRIArray[SlotIndex], GetPC().PlayerReplicationInfo);	
	}	
}

defaultproperties
{
}
