//=============================================================================
// KFGFxMenu_PostGameReport
//=============================================================================
// This menu is used to show the player's options for leaving the game.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Zane Gholson -  05/19/2015
//=============================================================================

class KFGFxMenu_PostGameReport extends KFGFxObject_Menu;

var localized string MapVoteString;
var localized string PlayerStatsString;
var localized string TeamAwardsString;
var localized string PostGameReportString;
var localized string NextMapString;
var localized string WaveString;
var localized string XPString;
var localized string VictoryString;
var localized string DefeatString;
var localized string ItemDropTitleString;

var TopVotes CurrentTopVoteObject;

var KFGFxPostGameContainer_PlayerStats 		PlayerStatsContainer;
var KFGFxPostGameContainer_MapVote 			MapVoteContainer;
var KFGFxPostGameContainer_TeamAwards 		TeamAwardsContainer;
var KFGFxPostGameContainer_PlayerXP			playerXPContainer;
var KFGFxHUD_ChatBoxWidget 					ChatBoxWidget;

var OnlineSubsystem OnlineSub;

var int LastNextMapTimeRemaining;

var array<KFPlayerReplicationInfo> CurrentPlayerList, TalkerPRIs;

function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	local KFGameReplicationInfo KFGRI;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	super.InitializeMenu( InManager );

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	if (class'GameEngine'.Static.IsGameFullyInstalled())
	{
		//@SABER_EGS IsEosBuild() case added
		if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild() )
		{
			class'GameEngine'.static.GetPlayfabInterface().AddOnCloudScriptExecutionCompleteDelegate(OnProcessEndGameRewardsComplete);
			KFGRI.SendPlayfabGameTimeUpdate(true);
			class'GameEngine'.static.GetPlayfabInterface().AddInventoryReadCompleteDelegate( SearchPlayfabInventoryForNewItem );
		}
		else
		{
			if (KFGRI != none)
			{
				KFGRI.ProcessChanceDrop();
			}
			OnlineSub.AddOnInventoryReadCompleteDelegate(SearchInventoryForNewItem);
		}		
	}

	LocalizeText();
	//SetPlayerInfo(); //no more name plate
	SetSumarryInfo();
	InitPlayerList();
}

function OneSecondLoop()
{
	UpdateNextMapTime();
}

function LocalizeText()
{
	local GFxObject TextObject;
	local WorldInfo WI;

    WI = class'WorldInfo'.static.GetWorldInfo();

	TextObject = CreateObject("Object");

	TextObject.SetString("nextMap", 	NextMapString);
	TextObject.SetString("mapVote", 	MapVoteString);
	TextObject.SetString("playerStats", PlayerStatsString);
	TextObject.SetString("xp", 			XPString);
	TextObject.SetString("teamAwards", 	TeamAwardsString);

	TextObject.SetString("dropTitle", 	ItemDropTitleString);

	if(WI != none &&  WI.NetMode != NM_Standalone )
    {
        if(WI.GRI != none)
        {
            TextObject.SetString("serverName", WI.GRI.ServerName);
        }
        if( class'WorldInfo'.static.IsConsoleBuild() )
        {
        	TextObject.SetString("serverIP", "");
        }
        else
        {
        	TextObject.SetString("serverIP", WI.GetAddressURL());
        }
    }

	SetObject("localizedText", TextObject);
}


function SearchPlayfabInventoryForNewItem( bool bSuccess )
{
	if( bSuccess )
	{
		SearchInventoryForNewItem();
	}
}


function OnProcessEndGameRewardsComplete( bool bWasSuccessful, string FunctionName, JsonObject FunctionResult )
{
	class'GameEngine'.static.GetPlayfabInterface().ClearOnCloudScriptExecutionCompleteDelegate( OnProcessEndGameRewardsComplete );

	if( FunctionName == "UpdatePlayRewards" )
	{
		// Now read inventory to see if anything changed
		class'GameEngine'.static.GetPlayfabInterface().ReadInventory();
	}
}


function SearchInventoryForNewItem()
{
	local int ItemIndex, InventoryIndex;
	local CurrentInventoryEntry TempInventoryDetailsHolder;
	local ItemProperties TempItemDetailsHolder;


	ItemIndex = INDEX_NONE;
	InventoryIndex = INDEX_NONE;

	//check inventory for item dropped
	if(OnlineSub == none)
	{
		return;
	}

	InventoryIndex = OnlineSub.CurrentInventory.Find('NewlyAdded', 1);

	if(InventoryIndex != INDEX_NONE)
	{
		TempInventoryDetailsHolder = OnlineSub.CurrentInventory[InventoryIndex];


		ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', TempInventoryDetailsHolder.Definition);

		if(ItemIndex != INDEX_NONE)
		{
			TempItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
			OnItemRecieved(TempItemDetailsHolder.Name, "img://"$TempItemDetailsHolder.IconURL);
		}
	}
}


function OnItemRecieved(string ItemName, string IconPath)
{
	local GFxObject ItemObject;

	ItemObject = CreateObject("Object");

	ItemObject.SetString("itemName", ItemName);
	ItemObject.SetString("iconImage", IconPath);

	SetObject("itemDrop", ItemObject);
}

function SetSumarryInfo()
{
    local string GameDifficultyString;
    local string GameTypeString;
    local string CurrentMapName;
    local KFGameReplicationInfo KFGRI;
	local GFxObject TextObject;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());

	TextObject = CreateObject("Object");

	//Get match info
	CurrentMapName = GetPC().WorldInfo.GetMapName(true);

	GameTypeString = class'KFCommon_LocalizedStrings'.static.GetGameModeString(0);

	if(KFPC.WorldInfo.GRI != none)
	{
		KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);
		if (KFPC.BeginningRoundVaultAmount > INDEX_NONE)
		{
			TextObject.SetInt("voshDelta", KFPC.GetTotalDoshCount() - KFPC.BeginningRoundVaultAmount);
		}

		GameDifficultyString =  class'KFCommon_LocalizedStrings'.static.GetDifficultyString(KFGRI.GameDifficulty);
		GameTypeString = KFGRI.GameClass.default.GameName;

    	TextObject.SetString("mapName", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(CurrentMapName) );
		TextObject.SetString("typeDifficulty", GameTypeString @"-" @GameDifficultyString);
		if(KFGRI.WaveNum == KFGRI.WaveMax)
		{
			TextObject.SetString("waveTime", class'KFGFxHUD_WaveInfo'.default.BossWaveString @"-" @FormatTime(KFGRI.ElapsedTime));
		}
		else
		{
			if (KFGRI.default.bEndlessMode)
			{
				TextObject.SetString("waveTime", WaveString @ KFGRI.WaveNum  @"-" @FormatTime(KFGRI.ElapsedTime));
			}
			else
			{
				TextObject.SetString("waveTime", WaveString @ KFGRI.WaveNum $ "/" $KFGRI.GetFinalWaveNum() @ "-" @ FormatTime(KFGRI.ElapsedTime));
			}
		}

		TextObject.SetString("winLost", KFGRI.bMatchVictory ? VictoryString : DefeatString);
	}
	//end get match info

	SetObject("gameSummary", TextObject);
}

function SetPlayerInfo()
{
	local GFxObject TextObject;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());

	TextObject = CreateObject("Object");
	if(KFPC.PlayerReplicationInfo.GetTeamNum() != 255)
	{
		TextObject.SetString("playerName", KFPC.PlayerReplicationInfo.PlayerName);
		TextObject.SetString("perkIcon", "img://"$KFPC.CurrentPerk.GetPerkIconPath());
		TextObject.SetString("perkName", KFPC.CurrentPerk.default.PerkName);
		TextObject.SetInt("perkLevel", KFPC.GetLevel());
	}
	else
	{
		TextObject.SetString("playerName", KFPC.PlayerReplicationInfo.PlayerName);
		TextObject.SetString("perkIcon", "img://"$PathName(class'KFGFxWidget_PartyInGame_Versus'.default.ZedIConTexture));
		TextObject.SetString("perkName", class'KFCommon_LocalizedStrings'.default.ZedString);
		TextObject.SetInt("perkLevel", 0);
	}

	SetObject("playerInfo", TextObject);
}

function InitPlayerList()
{
	local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(GetPC().Worldinfo.GRI);
    if(KFGRI != none)
    {
        KFGRI.GetKFPRIArray(CurrentPlayerList);
    }
    SendVoipData();
}

function SendVoipData()
{
    local int i;
	local GFxObject DataProvider, TempObj;
	local KFPlayerController KFPC;

	DataProvider = CreateArray();
	if( DataProvider != none )
	{
		KFPC = KFPlayerController( GetPC() );
		for ( i = 0; i < CurrentPlayerList.length; i++ )
		{
			TempObj = CreateObject( "Object" );
			if( TempObj != none )
			{
				TempObj.SetString( "label", CurrentPlayerList[i].PlayerName );
				TempObj.SetBool("bTalking", (TalkerPRIs.Find(CurrentPlayerList[i]) != INDEX_NONE));
				if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Orbis ) )
				{
					TempObj.SetString("avatar", ("img://"$KFPC.GetPS4Avatar(CurrentPlayerList[i].PlayerName)));
				}
				else
				{
					TempObj.SetString("avatar", ("img://"$KFPC.GetSteamAvatar(CurrentPlayerList[i].UniqueId)));
				}
				DataProvider.SetElementObject( i, TempObj );
			}
		}

		SetObject( "playerList", DataProvider );
	}
}

function VOIPEventTriggered(PlayerReplicationInfo TalkerPRI, bool bIsTalking)
{
	local KFPlayerReplicationInfo KFPRI;
	KFPRI = KFPlayerReplicationInfo(TalkerPRI);

	if ( KFPRI == none )
	{
		return;
	}

	if ( !bIsTalking )
	{
		TalkerPRIs.RemoveItem(KFPRI);
	}
	else
	{
		if(TalkerPRIs.Find(KFPRI) != INDEX_NONE)
		{
			TalkerPRIs.RemoveItem(KFPRI);
		}
		if(!GetPC().IsPlayerMuted(KFPRI.UniqueId))
		{
			TalkerPRIs.AddItem(KFPRI);
		}
	}
	SendVoipData();
}

function UpdateNextMapTime()
{
	local int CurrentNextMapTimeRemaining;
	local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

    CurrentNextMapTimeRemaining = KFGRI.GetTraderTimeRemaining();
    if(LastNextMapTimeRemaining != CurrentNextMapTimeRemaining)
    {
        SetInt("remainingTime" ,CurrentNextMapTimeRemaining);
        LastNextMapTimeRemaining = CurrentNextMapTimeRemaining;
    }
}

function  string FormatTime(int TimeInSeconds)
{
	local string TimeString;
	local int Minutes;


	Minutes = TimeInSeconds / 60;
	TimeInSeconds -= Minutes * 60;

	TimeString = String(Minutes) $ ":";

	if( TimeInSeconds >= 10 )
	{
		TimeString = TimeString $ String(TimeInSeconds);
	}
	else
	{
		TimeString = TimeString $ "0" $ String(TimeInSeconds);
	}

	return TimeString;
}

function OnOpen()
{
	//@SABER_EGS IsEosBuild() case added
	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild() )
	{
		if( GetPC().WorldInfo.NetMode == NM_Client )
		{
			class'GameEngine'.static.GetPlayfabInterface().AddInventoryReadCompleteDelegate( SearchPlayfabInventoryForNewItem );
		}
	}
	else if( OnlineSub != none )
	{
		OnlineSub.AddOnInventoryReadCompleteDelegate(SearchInventoryForNewItem);
	}
}

function OnClose()
{
	//@SABER_EGS IsEosBuild() case added
	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild())
	{
		class'GameEngine'.static.GetPlayfabInterface().ClearOnCloudScriptExecutionCompleteDelegate( OnProcessEndGameRewardsComplete );
		class'GameEngine'.static.GetPlayfabInterface().ClearInventoryReadCompleteDelegate( SearchPlayfabInventoryForNewItem );
	}
	else if( OnlineSub != none )
	{
		OnlineSub.ClearOnInventoryReadCompleteDelegate(SearchInventoryForNewItem);
	}
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
        case 'playerStatsContainer':
            if(PlayerStatsContainer == none)
            {
                PlayerStatsContainer = KFGFxPostGameContainer_PlayerStats(Widget);
                PlayerStatsContainer.PlayerStatsString = PlayerStatsString;
                PlayerStatsContainer.Initialize( self );
            }
        break;

        case 'mapVoteContainer':
			if(MapVoteContainer == none)
            {
                MapVoteContainer = KFGFxPostGameContainer_MapVote(Widget);
                MapVoteContainer.MapVoteString = MapVoteString;
                MapVoteContainer.Initialize( self );
            }
        break;

        case 'teamAwardsContainer':
        	if(teamAwardsContainer == none)
            {
                teamAwardsContainer = KFGFxPostGameContainer_TeamAwards(Widget);
                teamAwardsContainer.Initialize( self );
            }
        break;
       case 'playerXPContainer':
	    	if(playerXPContainer == none)
	        {
	            playerXPContainer = KFGFxPostGameContainer_PlayerXP(Widget);
	            playerXPContainer.Initialize( self );
	        }

        break;

        case 'chatBoxWidget':
        	if(ChatBoxWidget == none)
            {
                ChatBoxWidget = KFGFxHUD_ChatBoxWidget(Widget);
                ChatBoxWidget.SetLobbyChatVisible(true);

            }
        break;
    }

    return true;
}


function ReceiveMessage(string Message, optional string MessageColor)
{
	// Send to chat box
	if( ChatBoxWidget != none )
	{
		if(MessageColor != "")
		{
			ChatBoxWidget.AddChatMessage(message, MessageColor);
		}
		else
		{
			ChatBoxWidget.AddChatMessage(message, class 'KFLocalMessage'.default.SayColor);
		}
	}
}

function RecieveTopMaps(const out TopVotes VoteObject)
{
	//Store them for the persistent display of top maps
	CurrentTopVoteObject = VoteObject;
	//send them to map vote container
	if(MapVoteContainer != none)
	{
		MapVoteContainer.RecieveTopMaps( VoteObject );
	}
}

function StartCountdown(int CountdownTime, bool bFinalCountdown)
{
	ActionScriptVoid("startCountdown");
}

function Callback_BroadcastChatMessage(string Message)
{
	super.Callback_BroadcastChatMessage(Message);
}

function Callback_MapVote(int MapVoteIndex, bool bDoubleClick)
{
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(GetPC().PlayerReplicationInfo);

	KFPRI.CastMapVote(MapVoteIndex, bDoubleClick);
}

function Callback_TopMapClicked(int MapVoteIndex, bool bDoubleClick)
{
	local int SearchIndex;
	local string SearchString;

	switch (MapVoteIndex)
	{
		case 0:
			SearchString = CurrentTopVoteObject.Map1Name;
			break;
		case 1:
			SearchString = CurrentTopVoteObject.Map2Name;
			break;
		case 2:
			SearchString = CurrentTopVoteObject.Map3Name;
			break;
	}

	SearchIndex = KFGameReplicationInfo(GetPC().WorldInfo.GRI).VoteCollector.MapList.Find(SearchString);

	Callback_MapVote(SearchIndex, bDoubleClick);
}


defaultproperties
{
	SubWidgetBindings.Add((WidgetName="playerStatsContainer",WidgetClass=class'KFGFxPostGameContainer_PlayerStats'))
	SubWidgetBindings.Add((WidgetName="mapVoteContainer",WidgetClass=class'KFGFxPostGameContainer_MapVote'))
	SubWidgetBindings.Add((WidgetName="teamAwardsContainer",WidgetClass=class'KFGFxPostGameContainer_TeamAwards'))
	SubWidgetBindings.Add((WidgetName="playerXPContainer",WidgetClass=class'KFGFxPostGameContainer_PlayerXP'))
	SubWidgetBindings.Add((WidgetName="chatBoxWidget",WidgetClass=class'KFGFxHUD_ChatBoxWidget'))
}