//=============================================================================
// KFGFxWidget_PartyInGame_Versus
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================


class KFGFxWidget_PartyInGame_Versus extends KFGFxWidget_PartyInGame;

var localized string SwitchTeamsString;
var localized string balanceWarningString;

var GFxObject SwitchTeamsButton;

var Texture2D ZedIConTexture;

function InitializeWidget()
{
	KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );;
	SwitchTeamsButton = GetObject("switchTeamsButton");
	super.InitializeWidget();
}

function LocalizeText()
{
	super.LocalizeText();
	//SwitchTeamsButton.SetString("label", SwitchTeamsString);
	SetString( "switchTeamsString", SwitchTeamsString );
}

function OneSecondLoop()
{
	super.OneSecondLoop();
	SetInt("myTeam", GetPC().PlayerReplicationInfo.GetTeamNum());
	UpdateTeams();
	UpdateBalanceWarning();
}

function UpdateBalanceWarning()
{
	if(KFGRI == none)
	{
		return;
	}

	if(KFGRI.AreTeamsOutOfBalanced())
	{
		SetString("balanceWarning", balanceWarningString);
	}
	else
	{
		SetString("balanceWarning", "");
	}
}

function UpdateTeams()
{
	local int i;

	for (i = 0; i < PlayerSlots; i++)
	{
		if(MemberSlots[i].PRI != none)
		{
			MemberSlots[i].MemberSlotObject.SetInt("team", MemberSlots[i].PRI.GetTeamNum());
		}
	}
}

function GetKFPRIArray( out array<KFPlayerReplicationInfo> KFPRIArray )
{
	super.GetKFPRIArray(KFPRIArray);

	if(KFPRIArray.length > 0)
	{
		//sort by team
		KFPRIArray.Sort(SortPlayers);
	}
}

delegate int SortPlayers(KFPlayerReplicationInfo A, KFPlayerReplicationInfo B)
{
	return A.GetTeamNum() > B.GetTeamNum() ? -1 : 0;
}

// Check which aspect of the slot has changed and update it
function GFxObject RefreshSlot( int SlotIndex, KFPlayerReplicationInfo KFPRI )
{
   	local byte CurrentTeamIndex;
	local string PlayerName;	
	local UniqueNetId AdminId;
	local bool bIsLeader;
	local bool bIsMyPlayer;
	local PlayerController PC;
	local GFxObject PlayerInfoObject, PerkIconObject;

	CurrentTeamIndex = KFPRI.GetTeamNum();
	PlayerInfoObject = CreateObject("Object");

	PC = GetPC();

	if(OnlineLobby != none)
	{
		OnlineLobby.GetLobbyAdmin( OnlineLobby.GetCurrentLobbyId(), AdminId);
	}
	
	//leader
	bIsLeader = (KFPRI.UniqueId == AdminId && KFPRI.UniqueId != ZeroUniqueId);
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
		PerkIconObject = CreateObject("Object");
		if( CurrentTeamIndex == 255 ) //zed team
   		{
			PerkIconObject.SetString("perkIcon", "img://"$PathName(ZedIConTexture));
   			MemberSlots[SlotIndex].PerkClass = class'KFPerk_Monster';
	   	}
	   	else//human team
	   	{
			PlayerInfoObject.SetString("perkLevel", MemberSlots[SlotIndex].PerkLevel); //separate from icon

			PerkIconObject = CreateObject("Object");
			PerkIconObject.SetString("perkIcon", "img://"$MemberSlots[SlotIndex].PerkClass.static.GetPerkIconPath());
			PerkIconObject.SetString("prestigeIcon", MemberSlots[SlotIndex].PerkClass.static.GetPrestigeIconPath(KFPRI.GetActivePerkPrestigeLevel()));
	   	}
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
		PlayerInfoObject.SetString("profileImageSource", "img://"$KFPC.GetPS4Avatar(PlayerName));
	}
	else
	{
		PlayerInfoObject.SetString("profileImageSource", "img://"$KFPC.GetSteamAvatar(KFPRI.UniqueId));
	}	
	if(KFGRI != none)
	{
		PlayerInfoObject.SetBool( "ready", KFPRI.bReadyToPlay );
	}

	return PlayerInfoObject;	
}

DefaultProperties
{
	PlayerSlots=12
	ZedIConTexture=Texture2D'UI_Widgets.MenuBarWidget_SWF_IF'
}