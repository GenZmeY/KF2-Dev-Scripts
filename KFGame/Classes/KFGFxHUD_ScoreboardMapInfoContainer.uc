//=============================================================================
// KFGFxHUD_ScoreboardMapInfoContainer
//=============================================================================
// Stores and displays the current round information.  This includes time, map
// difficulty and wave.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 9/26/2014
//=============================================================================


class KFGFxHUD_ScoreboardMapInfoContainer extends GFxObject;

// Cached value - Elapsed match time as of the last scoreboard tick update.
var Protected int LastMatchTime;
var localized string WaveString;
var localized string FinalString;

var string GameTypeString;
var bool bLocalized;

function InitializeHUD()
{
	UpdateWaveCount();
}

function LocalizeText()
{
    local GFxObject LocalizedObject;
    local string MatchInfoString;
    local string GameDifficultyString;
    local KFGameReplicationInfo KFGRI;

	GameTypeString = class'KFCommon_LocalizedStrings'.static.GetGameModeString(0);
	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	if(KFGRI != none)
	{
		GameDifficultyString =  class'KFCommon_LocalizedStrings'.static.GetDifficultyString(KFGRI.GameDifficulty);
		GameTypeString =  KFGRI.GameClass.default.GameName;
    	MatchInfoString = GameTypeString @"-" @GameDifficultyString;
	}

	LocalizedObject = CreateObject( "Object" );
	LocalizedObject.SetString("waveText", WaveString);
	LocalizedObject.SetString("mapText", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(GetPC().WorldInfo.GetMapName(true)));
	LocalizedObject.SetString("matchInfo", MatchInfoString);

	SetObject("localizeText", LocalizedObject);

	bLocalized = true;
}

// Elapsed time, difficulty, map name.
function UpdateMatchInfo()
{
	local KFGameReplicationInfo KFGRI;
	local int CurrentMatchTime;

    KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);
    if(KFGRI != none)
    {
    	if(!bLocalized)
    	{
    		LocalizeText();
    	}

        CurrentmatchTime = KFGRI.ElapsedTime;
        if(CurrentMatchTime != LastMatchTime)
        {
            // Send match time to actionscript
            SetInt("timeValue" ,CurrentMatchTime);
            LastMatchTime = CurrentMatchTime;
        }
    }
}

function UpdateWaveCount()
{
	local int CurrentWaveNum;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	if(KFGRI == none)
	{
		return;
	}

	CurrentWaveNum = KFGRI.WaveNum;
    if(KFGRI.IsBossWave())
    {
		SetString("waveNumber", class'KFGFxHUD_WaveInfo'.default.BossWaveString);
    }
	else if (KFGRI.IsFinalWave())
	{
		SetString("waveNumber", FinalString);
	}
    else
    {
		if (KFGRI.default.bEndlessMode)
		{
    		SetString("waveNumber", "" $ CurrentWaveNum);
		}
		else
		{
			SetString("waveNumber", CurrentWaveNum $ "/" $ KFGRI.GetFinalWaveNum());
		}
    }
}

defaultProperties
{
	bLocalized=false
}