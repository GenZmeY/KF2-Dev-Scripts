//=============================================================================
// KFGFxHUD_ScoreboardWidget
//=============================================================================
// Displays a list of all active players on the server (not spectators) and
// prints out vital information such as their Kills, Dosh, Health, Perks, etc.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Alex Quick 6/9/2014
//=============================================================================


class KFGFxHUD_ScoreboardWidget extends GFxObject;

//  Performance optimization - Only update list while the scoreboard is visible.
var bool bUpdateScoreboard;

// Interval between scoreboard updates.  Higher values mean less frequent updates.
var const float ScoreboardUpdateInterval;
// Last time we performed an update on this scoreboard's info.
var Protected float LastScoreboardUpdateTime;
//This item will contain the match information.
var KFGFxHUD_ScoreboardMapInfoContainer MatchInfoContainer;

var array<KFPlayerReplicationinfo> CurrentPlayerList;

var localized string PlayerString;
var localized string DoshString;
var localized string KillsString;
var localized string AssistsString;
var localized string PingString;

function InitializeHUD()
{
    LocalizeText();
    UpdatePlayerList();
    UpdateMatchInfo();
    SendServerInfoToGFX();
}

function LocalizeText()
{
    local GFxObject LocalizedObject;
    LocalizedObject = CreateObject( "Object" );

    LocalizedObject.SetString("playerText", PlayerString);
    LocalizedObject.SetString("doshText", DoshString);
    LocalizedObject.SetString("killsText", KillsString);
    LocalizedObject.SetString("assistsText", AssistsString);
    LocalizedObject.SetString("pingText", PingString);

    SetObject("localizeText", LocalizedObject);
}

function SendServerInfoToGFX()
{
    local WorldInfo WI;
    local GFxObject ServerObject;

    WI = class'WorldInfo'.static.GetWorldInfo();

    ServerObject = CreateObject( "Object" );

    if(WI != none &&  WI.NetMode != NM_Standalone )
    {
        if(WI.GRI != none)
        {
            ServerObject.SetString("serverName", WI.GRI.ServerName);    
        }
        //ServerObject.SetString("serverIP", WI.GetAddressURL());
    }

    SetObject("serverInfo", ServerObject);
}

/** Ties the GFxClikWidget variables to the .swf components and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
    switch (WidgetName)
    {
        case ( 'ScoreboardMapInfo' ):
            if(MatchInfoContainer == none)
            {
                MatchInfoContainer = KFGFxHUD_ScoreboardMapInfoContainer(Widget);
                MatchInfoContainer.InitializeHUD();
            }
        break;   
    }
      
    return true;
}

function TickHud(float DeltaTime)
{
    if(bUpdateScoreboard &&
       GetPC() != none &&
       GetPC().WorldInfo.TimeSeconds - LastScoreboardUpdateTime > ScoreboardUpdateInterval)
    {
        LastScoreboardUpdateTime = GetPC().WorldInfo.TimeSeconds;   // throttle the updates so we're not spamming Actionscript with data.

        UpdatePlayerList();
        UpdateMatchInfo();
        SendServerInfoToGFX();
    }
}


function ForceUpdateNextFrame()
{
	// Reset this time so the next TickHud, it'll force an update
	LastScoreboardUpdateTime = 0;
}


function SetOpen(bool bOpen)
{
    SetBool("showScore", bOpen);    
}

// Elapsed time, difficulty, map name.
function UpdateMatchInfo()
{
	if(MatchInfoContainer != none)
    {
        MatchInfoContainer.UpdateMatchInfo();
        MatchInfoContainer.UpdateWaveCount();
    }
}

function UpdatePlayerList()
{
    local KFGameReplicationInfo KFGRI;
    
    KFGRI = KFGameReplicationInfo(GetPC().Worldinfo.GRI);
    if(KFGRI != none)
    {
        KFGRI.GetKFPRIArray(CurrentPlayerList);
        SortPlayerList(CurrentPlayerList);
        UpdatePlayerData();
    }
}

function SortPlayerList(out array<KFPlayerReplicationinfo> PlayerList)
{
    local int i, j, HighestScore, HighestScoreIndex;
    local KFPlayerReplicationinfo TempPRI;

    // Perform a selection sort on the PRIArray by Score
    for ( i = 0; i < PlayerList.Length; i++ )
    {
        HighestScore = -1000000000;
        for ( j = i; j < PlayerList.Length; j++ )
        {
            if ( PlayerList[j].Kills > HighestScore )
            {
                HighestScore = PlayerList[j].Kills;
                HighestScoreIndex = j;
            }
            else if(PlayerList[j].Kills == HighestScore)
            {
                if(PlayerList[j].Assists > PlayerList[HighestScoreIndex].Assists)
                {
                    HighestScore = PlayerList[j].Kills;
                    HighestScoreIndex = j;
                }
            }
        }

        TempPRI = PlayerList[i];
        PlayerList[i] = PlayerList[HighestScoreIndex];
        PlayerList[HighestScoreIndex] = TempPRI;
    }
}

function UpdatePlayerData()
{
	local GFxObject DataProvider,TempData, PerkIconObject;
	local int i;
    local KFPlayerReplicationinfo KFPRI;
    local KFPlayerController KFPC;
    local int PlayerIndex;

    KFPC = KFPlayerController(GetPC());

    PlayerIndex=0;
    DataProvider = CreateArray();
	for(i = 0 ; i < CurrentPlayerList.length; i ++)
    {
        KFPRI = CurrentPlayerList[i];
        if(KFPRI.GetTeamNum() != 255 && KFPRI.bHasSpawnedIn)
        {
            TempData  = CreateObject("Object");

            TempData.SetString("playername", KFPRI.PlayerName);
            
            TempData.SetInt("dosh", KFPRI.Score);
            TempData.SetInt("assists", KFPRI.Assists);
            TempData.SetInt("kills", KFPRI.Kills);
            TempData.SetInt("ping", KFPRI.Ping * `PING_SCALE);
            TempData.SetInt("perkLevel", KFPRI.GetActivePerkLevel());
			TempData.SetInt("prestigeLevel", KFPRI.GetActivePerkPrestigeLevel());
            if( KFPRI.CurrentPerkClass != none )
            {
                TempData.SetString("perkName", KFPRI.CurrentPerkClass.default.PerkName);

				PerkIconObject = CreateObject("Object");
				PerkIconObject.SetString("perkIcon", "img://"$KFPRI.CurrentPerkClass.static.GetPerkIconPath());
				PerkIconObject.SetString("prestigeIcon", KFPRI.CurrentPerkClass.static.GetPrestigeIconPath(KFPRI.GetActivePerkPrestigeLevel()));

				TempData.SetObject("iconPath", PerkIconObject);
            }

			if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Orbis ) )
			{
				TempData.SetString("avatar", "img://"$KFPC.GetPS4Avatar(KFPRI.PlayerName));
			}
			else
			{
				TempData.SetString("avatar", "img://"$KFPC.GetSteamAvatar(KFPRI.UniqueId));
			}
            if(KFPRI.PlayerHealth < 0)
            {
                TempData.SetFloat("health", 0);  
                TempData.SetFloat("healthPercent", 0);  
            }
            else
            {
                TempData.SetFloat("health", KFPRI.PlayerHealth);  
                TempData.SetFloat("healthPercent", ByteToFloat(KFPRI.PlayerHealthPercent) * 100);  
            }

            DataProvider.SetElementObject(PlayerIndex,TempData);
            PlayerIndex++;
        }
    }

    SetObject("playerData", DataProvider);
}

defaultproperties
{
    ScoreboardUpdateInterval=1.f
    SubWidgetBindings.Add((WidgetName="ScoreboardMapInfo",WidgetClass=class'KFGFxHUD_ScoreboardMapInfoContainer'))
}
