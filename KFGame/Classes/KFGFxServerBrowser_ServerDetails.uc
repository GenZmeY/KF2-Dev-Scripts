//=============================================================================
// KFGFxServerBrowser_ServerDetails
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane 8/19/2014
//=============================================================================

class KFGFxServerBrowser_ServerDetails extends KFGFxObject_Container;

var KFGFxMenu_ServerBrowser ServerMenu;

var localized string MutatorsString;
var localized string ServerInfoString;
var localized string JoinGameString;
var localized string SpectateGameString;
var localized string UnfavoriteString;
var localized string SeasonalSkinsString;
var localized string NoSeasonalSkinsString;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	ServerMenu =KFGFxMenu_ServerBrowser(NewParentMenu);
	LocalizeText();
}

function LocalizeText()
{
	local GFxObject LocalizedObject;
	LocalizedObject = CreateObject( "Object" );

	LocalizedObject.SetString("wave", ServerMenu.WaveString);
	LocalizedObject.SetString("players", ServerMenu.PlayersString);
	LocalizedObject.SetString("zedCount", ServerMenu.ZedCountString);
	LocalizedObject.SetString("ranked", ServerMenu.RankedString);
	LocalizedObject.SetString("unranked", ServerMenu.UnrankedString);
	LocalizedObject.SetString("serverInfo", ServerInfoString);
	LocalizedObject.SetString("vacSecure", ServerMenu.VACSecureString);
	LocalizedObject.SetString("favorite", ServerMenu.FavoriteString);
	LocalizedObject.SetString("unfavorite", UnfavoriteString);
	LocalizedObject.SetString("mutators", MutatorsString);
	LocalizedObject.SetString("joinGame", JoinGameString);
	LocalizedObject.SetString("spectateGame", SpectateGameString);
	LocalizedObject.SetString("seasonalString", SeasonalSkinsString);
	LocalizedObject.SetString("noseasonalString", NoSeasonalSkinsString);

	SetObject("localizedText", LocalizedObject);
}

function bool GetFavoriteButtonActive()
{
	return GetBool("favoriteButtonSelected");
}

function SetFavoriteButtonActive(bool bActive)
{
	SetBool("favoriteButtonSelected", bActive);
}

function SetDetails(KFOnlineGameSettings ServerResult)
{	
	local GFxObject TempObj;
	local int Ping, PlayerCount;
	local KFOnlineGameSettings TempOnlingGamesSettings;
	local bool bShowSeasonalSkins;
	local KFWeeklyOutbreakInformation WeeklyInfo;

	if(ServerResult != none)
	{
		TempOnlingGamesSettings = ServerResult;

		TempObj = CreateObject("Object");
		TempObj.SetString("serverName",    		TempOnlingGamesSettings.OwningPlayerName);        

		PlayerCount = TempOnlingGamesSettings.NumPublicConnections - TempOnlingGamesSettings.NumOpenPublicConnections;

		if (PlayerCount < 0)
		{
			PlayerCount = 0;
		}

		TempObj.SetFloat("playerCount",        	PlayerCount);
		TempObj.SetFloat("maxPlayerCount",     	TempOnlingGamesSettings.NumPublicConnections);

		TempObj.SetFloat("waveCount",     		TempOnlingGamesSettings.CurrentWave);
		TempObj.SetFloat("maxWaveCount",     	TempOnlingGamesSettings.NumWaves);

		TempObj.SetFloat("zedCount",     		TempOnlingGamesSettings.ZedCount);
		TempObj.SetFloat("maxZedCount",     	TempOnlingGamesSettings.MaxZedCount);
		TempObj.SetBool("vacEnable",          	TempOnlingGamesSettings.bAntiCheatProtected);
		TempObj.SetBool("mutators",          	TempOnlingGamesSettings.bMutators);
		TempObj.SetBool("ranked",           	TempOnlingGamesSettings.bUsesStats);
		TempObj.SetBool("seasonalSkins",       	TempOnlingGamesSettings.bNoSeasonalSkins == false);

		bShowSeasonalSkins = class'KFGameEngine'.static.GetSeasonalEventIDForZedSkins() != SEI_None
							&& class'KFGameEngine'.static.GetSeasonalEventIDForZedSkins() != SEI_Spring;

		TempObj.SetBool("showSeasonalSkins",    bShowSeasonalSkins);

		Ping = 									TempOnlingGamesSettings.PingInMs;
		TempObj.SetString("ping",          		(Ping < 0) ? ("-") : (String(Ping)) );
		TempObj.SetString("difficulty",         Class'KFCommon_LocalizedStrings'.static.GetDifficultyString(TempOnlingGamesSettings.difficulty));
		TempObj.SetString("mode",           	class'KFCommon_LocalizedStrings'.static.GetGameModeString(TempOnlingGamesSettings.Mode) );

		// If weekly we add the weekly type
		if (TempOnlingGamesSettings.Mode == 1)
		{
			if (TempOnlingGamesSettings.WeeklySelectorIndex > 0)
			{
				WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetWeeklyOutbreakInfoByIndex(TempOnlingGamesSettings.WeeklySelectorIndex - 1);
			}
			else
			{
				WeeklyInfo = class'KFMission_LocalizedStrings'.static.GetCurrentWeeklyOutbreakInfo();
			}

			TempObj.SetString("weeklyForced", WeeklyInfo.FriendlyName);
		}

		TempObj.SetString("map",           		TempOnlingGamesSettings.MapName);

		TempObj.SetString("mapImagePath",       GetMapSource(TempOnlingGamesSettings.MapName));

		//Get Game State from var const databinding EOnlineGameState GameState;
		TempObj.SetString("gameStatus",         String(TempOnlingGamesSettings.GameState));		

		TempObj.SetObject("playersData", CreatePlayerListGFXObject(TempOnlingGamesSettings));

		SetObject("serverDetails", TempObj);
	}
	else
	{
		`log("NO GAME SEARCH HAS BEEN FOUND!");
	}
}

function GFxObject CreatePlayerListGFXObject(OnlineGameSettings Settings)
{
	local GFxObject PlayerDataProvider, DataObj;
	local byte i;

	PlayerDataProvider = CreateArray();

	for (i = 0; i < Settings.PlayersInGame.Length; ++i)
	{
		DataObj = CreateObject("Object");
		DataObj.SetString("playerName", Settings.PlayersInGame[i].PlayerName);
		DataObj.SetString("playTime", "Time: "$Settings.PlayersInGame[i].TimePlayed);	
		DataObj.SetString("playerPing", "$"$Settings.PlayersInGame[i].Score);	
		DataObj.SetString("killCountText", "");	

		PlayerDataProvider.SetElementObject(i, DataObj);
	}

	return PlayerDataProvider;
}

function UpdatePlayerList(out OnlineGameSettings Settings)
{
	SetObject("playersData", CreatePlayerListGFXObject(Settings));
}

function string GetMapSource(string MapName)
{
	local KFMapSummary MapData;

	MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName(MapName);
	if ( MapData != none )
	{
		return "img://" $MapData.ScreenshotPathName;
    }
    else
    {    	
    	// Failed to find map image, use the default instead
    	MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName("KF-Default");
    	if ( MapData != none )
		{
			return "img://" $MapData.ScreenshotPathName;			
    	}
    }
}
