//=============================================================================
// KFGFxHUD_WaveInfo
//=============================================================================
// HUD container that stores information about the current wave.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Alex Quick 5/28/2014
//=============================================================================

class KFGFxHUD_WaveInfo extends GFxObject;

/** Cached KFPlayerController */
var KFGameReplicationinfo 				KFGRI;

//
var int LastWaveMax;
//
var int LastZEDCount;
//
var int LastWave;
//
var int LastTraderTimeRemaining;

const ENDLESS_WAVE_ID = -2;

var KFPlayerController KFPC;

var localized string WaveString;
var localized string BossWaveString;
var localized string FinalWaveString;

var KFGFxHUD_ObjectiveConatiner     ObjectiveContainer;

function InitializeHUD()
{
	SetString("waveText", WaveString);
    SetString("bossText", BossWaveString); 
    SetString("finalText", FinalWaveString);
    UpdateWaveCount();
	KFPC = KFPlayerController(GetPC());
}

function TickHud(float DeltaTime)
{
    if(KFGRI == none)
    {
        KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);
    }
    else
    {
		if (KFGRI.bWaveIsActive && !KFGRI.bWaveStarted)
		{
            SetString("waitingForWaveStart", "-----");
		}
		else if (!KFGRI.bWaveIsActive)
        {
			UpdateTraderTimeRemaining();
		}
		else
		{
			UpdateZEDCount();
		}
    }
	if (ObjectiveContainer != none)
	{
		ObjectiveContainer.TickHud(DeltaTime);
	}
}


function UpdateWaveCount()
{
    local int CurrentWaveMax,CurrentWave;

    if( KFGRI == none )
    {
        KFGRI = KFGameReplicationInfo( GetPC().WorldInfo.GRI );
    }

    if( KFGRI == none )
    {
        return;
    }

    // Max # of waves.
	CurrentWaveMax = KFGRI.GetFinalWaveNum();
    if(LastWaveMax != CurrentWaveMax)
    {
        SetInt("maxWaves" , KFGRI.default.bEndlessMode ? INDEX_NONE : CurrentWaveMax);
        LastWaveMax = CurrentWaveMax;
    }

    // Current wave we're on.
    CurrentWave = KFGRI.WaveNum;
    if(CurrentWave != LastWave)
    {
        SetInt("currentWave" , CurrentWave);
        LastWave = CurrentWave;
    }
}

function UpdateZEDCount()
{
    local int CurrentZEDCount;

    if( KFGRI == none )
    {
        return;
    }

    if(KFGRI.IsBossWave())
    {
        SetInt("remainingZEDs" , INDEX_NONE);
		LastZEDCount = -1;
        return;
    }
	else if (KFGRI.IsEndlessWave())
	{
		SetInt("remainingZEDs", ENDLESS_WAVE_ID);
		LastZEDCount = -1;
		return;
	}

    // # of ZEDs left to kill in this wave.
    CurrentZEDCount = KFGRI.AIRemaining;
    if(LastZEDCount != CurrentZEDCount)
    {
        SetInt("remainingZEDs" ,CurrentZEDCount);
        LastZEDCount = CurrentZEDCount;
    }
}

function UpdateTraderTimeRemaining()
{
    local int CurrentTraderTimeRemaining;

    if( KFGRI == none )
    {
        return;
    }

    CurrentTraderTimeRemaining = KFGRI.GetTraderTimeRemaining();
    if(LastTraderTimeRemaining != CurrentTraderTimeRemaining)
    {
        SetInt("remainingTraderTime" ,CurrentTraderTimeRemaining);
        LastTraderTimeRemaining = CurrentTraderTimeRemaining;
		if (LastTraderTimeRemaining < 10 && LastTraderTimeRemaining >= 0)
		{
			if (KFPC != none && KFPC.MyGFxHUD != none)
			{
				KFPC.MyGFxHUD.PlaySoundFromTheme('TraderTime_Countdown', 'UI');
			}
			
		}
    }
}

DefaultProperties
{
    LastTraderTimeRemaining=0
    LastZEDCount=0
}
