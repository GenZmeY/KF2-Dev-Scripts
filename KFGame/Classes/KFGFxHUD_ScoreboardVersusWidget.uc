//=============================================================================
// KFGFxHUD_ScoreboardVersusWidget
//=============================================================================
// Displays a list of all active players on the server (not spectators) and
// prints out vital information such as their Kills, Dosh, Health, Perks, etc.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 5/2/2016
//=============================================================================


class KFGFxHUD_ScoreboardVersusWidget extends KFGFxHUD_ScoreboardWidget;

var localized string ScoreString;

var int AssistValue;
var int KillValue;
var int DamageValue;

function LocalizeText()
{
    local GFxObject LocalizedObject;

    LocalizedObject = CreateObject( "Object" );

    LocalizedObject.SetString("playerText", PlayerString);
    LocalizedObject.SetString("scoreText", ScoreString);
    LocalizedObject.SetString("killsText", KillsString);
    LocalizedObject.SetString("assistsText", AssistsString);
    LocalizedObject.SetString("pingText", PingString);

    SetObject("localizeText", LocalizedObject);
}

function TickHud(float DeltaTime)
{
    if(bUpdateScoreboard &&
       GetPC() != none &&
       GetPC().WorldInfo.TimeSeconds - LastScoreboardUpdateTime > ScoreboardUpdateInterval)
    {
        LastScoreboardUpdateTime = GetPC().WorldInfo.TimeSeconds;   // throttle the updates so we're not spamming Actionscript with data.

        UpdatePlayerList();
        //UpdateMatchInfo();
        //SendServerInfoToGFX();
    }
}

function UpdatePlayerData()
{
	local GFxObject DataProvider,TempData;
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
        if(KFPRI.GetTeamNum() == 255)
        {
            TempData  = CreateObject("Object");

            TempData.SetString("playername", KFPRI.PlayerName);
            
            TempData.SetInt("score", KFPRI.DamageDealtOnTeam * DamageValue + KFPRI.Kills * KillValue + KFPRI.Assists * AssistValue);
            TempData.SetInt("assists", KFPRI.Assists);
            TempData.SetInt("kills", KFPRI.Kills);
            TempData.SetInt("ping", KFPRI.Ping * `PING_SCALE);
            //TempData.SetInt("perkLevel", KFPRI.GetActivePerkLevel());
            /*if( KFPRI.CurrentPerkClass != none )
            {
                TempData.SetString("perkName", KFPRI.CurrentPerkClass.default.PerkName);
                TempData.SetString("iconPath", "img://"$KFPRI.CurrentPerkClass.static.GetPerkIconPath());
            }*/

			if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Orbis ) )
			{
				TempData.SetString("avatar", "img://"$KFPC.GetPS4Avatar(KFPRI.PlayerName));
			}
			else
			{
				TempData.SetString("avatar","img://"$KFPC.GetSteamAvatar(KFPRI.UniqueId));
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

DefaultProperties
{
	KillValue=100
	AssistValue=40
	DamageValue=1.0f
}