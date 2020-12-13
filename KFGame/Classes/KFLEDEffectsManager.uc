class KFLEDEffectsManager extends Object within KFPlayerController;

enum ELightFXID
{
	LFID_None,
	LFID_Puke,
	LFID_ZedTimeBegin,
	LFID_ZedTimeEnd,
	LFID_LowHealth,
	LFID_Siren,
	LFID_Flashbang,
	LFID_Heal,
	LFID_Fire,
	LFID_Gas,
	LFID_WaveIncoming,
	LFID_Ready,
	LFID_Unready,
	LFID_MatchLost,
	LFID_MatchWon,
	LFID_Emote,
};

struct S_LightingFrame
{
	var byte Red;
	var byte Green;
	var byte Blue;
	var byte Brightness;
	var float Duration;
};

var array<S_LightingFrame> PukeEffectArr;
var array<S_LightingFrame> ZedTimeBeginEffectArr;
var array<S_LightingFrame> ZedTimeEndEffectArr;
var array<S_LightingFrame> LowHealthEffectArr;
var array<S_LightingFrame> SirenEffectArr;
var array<S_LightingFrame> FlashbangEffectArr;
var array<S_LightingFrame> HealEffectArr;
var array<S_LightingFrame> FireEffectArr;
var array<S_LightingFrame> GasEffectArr;
var array<S_LightingFrame> WaveIncomingEffectArr;
var array<S_LightingFrame> ReadyEffectArr;
var array<S_LightingFrame> UnreadyEffectArr;
var array<S_LightingFrame> MatchLostEffectArr;
var array<S_LightingFrame> MatchWonEffectArr;
var array<S_LightingFrame> EmoteEffectArr;

var array<S_LightingFrame> CurrentLightingFrames;
var int CurrentLightFrameIndex;

var bool bPendingKill;

simulated function InitLEDEffects()
{
    local LogitechLEDInterface LogtitechLED;
    local RazerLEDInterface RazerFXLED;
    local AlienFXLEDInterface AlienFXLED;

    AlienFXLED = class'PlatformInterfaceBase'.static.GetAlienFXIntegration();
    RazerFXLED = class'PlatformInterfaceBase'.static.GetRazerIntegration();
    LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();

    if (RazerFXLED == none)
    {
       `log("RazerFXLED == none");
    }       

    if (LogtitechLED == none)
    {
        `log("LogtitechLED == none");
    }       

    if(AlienFXLED == none)
    {
        `log("AlienFXLED == none");   
    }
    else
    {
        AlienFXLED.Activate();
    }

    PlayEffectSetReady(false);
}

simulated function ResetLightingAnimation()
{
	CurrentLightFrameIndex = INDEX_NONE;
	CurrentLightingFrames.length = 0;
}

//recursive timer for animations
simulated function PlayNextLightFrame(optional bool bNewEffect)
{
	if (bPendingKill)
	{
		return;
	}
	if (bNewEffect)
	{
		CurrentLightFrameIndex = INDEX_NONE;
	}
	CurrentLightFrameIndex++;
	//validate frame
	if (CurrentLightFrameIndex < CurrentLightingFrames.length)
	{
		//Set the color
		SetLEDRGB(CurrentLightingFrames[CurrentLightFrameIndex].Red, CurrentLightingFrames[CurrentLightFrameIndex].Green, CurrentLightingFrames[CurrentLightFrameIndex].Blue, CurrentLightingFrames[CurrentLightFrameIndex].Brightness);
		SetTimer(CurrentLightingFrames[CurrentLightFrameIndex].Duration, false, nameof(PlayNextLightFrame), self);
	}
	else
	{
		//done restore lighting
		LedRestoreLighting();
	}
}

simulated function byte PercentToByte(int Percent)
{
    local byte MyByte;
    local float PercentFloat;

    PercentFloat = float(Percent) / 100.0f;

    MyByte = clamp(255 * PercentFloat, 0, 255); 

    return MyByte;
}


simulated function SetLEDRGB(int RedPercent, int GreenPercent, int BluePercent, int Brightness = 100)
{
    local LogitechLEDInterface LogtitechLED;
    local RazerLEDInterface RazerFXLED;
    local AlienFXLEDInterface AlienFXLED;

	if (bPendingKill)
	{
		return;
	}
    
    LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();
    RazerFXLED = class'PlatformInterfaceBase'.static.GetRazerIntegration();
    AlienFXLED = class'PlatformInterfaceBase'.static.GetAlienFXIntegration();

    if (LogtitechLED != none) //percent based
    {
       LogtitechLED.SetColor(RedPercent, GreenPercent, BluePercent, float(Brightness)/100.0f);
    }       
    
    if(RazerFXLED != none) //raw rgb byte
    {
        RazerFXLED.SetColor( PercentToByte(RedPercent), PercentToByte(GreenPercent), PercentToByte(BluePercent), float(Brightness)/100.0f );
    }

    if (AlienFXLED != none) //raw rgb byte
    {
        AlienFXLED.SetColor( PercentToByte(RedPercent), PercentToByte(GreenPercent), PercentToByte(BluePercent), PercentToByte(Brightness));
    }
}


simulated function LedStopEffects()
{
    local LogitechLEDInterface LogtitechLED;
    local RazerLEDInterface RazerFXLED;
    local AlienFXLEDInterface AlienFXLED;
    
    LogtitechLED = class'PlatformInterfaceBase'.static.GetLogitechIntegration();
    RazerFXLED = class'PlatformInterfaceBase'.static.GetRazerIntegration();
    AlienFXLED = class'PlatformInterfaceBase'.static.GetAlienFXIntegration();

    if (LogtitechLED != none)
    {
       LogtitechLED.LedStopEffects();
    }       
 
	if (RazerFXLED != none)
	{
		RazerFXLED.LedRestoreLighting();
	}

    if (AlienFXLED != none)
    {
        AlienFXLED.LedStopEffects();
    }
	bPendingKill = true;
}


simulated function LedRestoreLighting ()
{
	ResetLightingAnimation();
	SetLEDRGB(100, 0, 0, 75);
}

//puke
simulated function PlayEffectPuke(float timeSeconds)
{
    //LEDPulseLighting(50,50,0, int(timeSeconds)*1000, 100);
	CurrentLightingFrames = PukeEffectArr;
	PlayNextLightFrame(true);
}
//zed time
simulated function PlayEffectZedTime()
{
	CurrentLightingFrames = ZedTimeBeginEffectArr;
	PlayNextLightFrame(true);
}

simulated function ClearEffectZedTime()
{
	CurrentLightingFrames = ZedTimeEndEffectArr;
	PlayNextLightFrame(true);
}
//low health
simulated function PlayEffectLowHealth()
{
	CurrentLightingFrames = LowHealthEffectArr;
	PlayNextLightFrame(true);
}
//siren
simulated function PlayEffectSiren(float timeSeconds)
{
	CurrentLightingFrames = SirenEffectArr;
	PlayNextLightFrame(true);
}
//

simulated function PlayEffectFlashbang(float timeSeconds)
{
	CurrentLightingFrames = FlashbangEffectArr;
	PlayNextLightFrame(true);
}
//heal
simulated function PlayEffectHeal(float timeSeconds)
{
	CurrentLightingFrames = HealEffectArr;
	PlayNextLightFrame(true);
}
//fire
simulated function PlayEffectFire()
{
	CurrentLightingFrames = FireEffectArr;
	PlayNextLightFrame(true);
}
//gas
simulated function PlayEffectGas()
{
	CurrentLightingFrames = GasEffectArr;
	PlayNextLightFrame(true);
}

simulated function PlayEffectWaveIncoming() //
{
	CurrentLightingFrames = WaveIncomingEffectArr;
	PlayNextLightFrame(true);
}

simulated function PlayEffectRecievedDosh()
{
    //todo
}

simulated function PlayEmoteEffect()
{
	CurrentLightingFrames = EmoteEffectArr;
	PlayNextLightFrame(true);
}

simulated function PlayEffectSetReady(bool bReady)
{
    if(bReady)
    {
		CurrentLightingFrames = ReadyEffectArr;
    }
    else
    {
		CurrentLightingFrames = UnreadyEffectArr;
		
    }
	PlayNextLightFrame(true);
}

simulated function PlayEffectShowMatchOutcome(bool bWon) //
{
	if (bWon)
	{
		CurrentLightingFrames = MatchWonEffectArr;
	}
	else
	{
		CurrentLightingFrames = MatchLostEffectArr;

	}
	PlayNextLightFrame(true);
}

DefaultProperties
{
	EmoteEffectArr={(
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.15f), 
		(Red = 100,Green = 60,Blue = 18,Brightness = 100,Duration = 0.15f), 
		(Red = 90,Green = 99,Blue = 60,Brightness = 100,Duration = 0.15f), 
		(Red = 0,Green = 100,Blue = 60,Brightness = 0,Duration = 0.15f),	
		(Red = 0,Green = 0,Blue = 100,Brightness = 100,Duration = 0.15f),  
		(Red = 60,Green = 25,Blue = 98,Brightness = 100,Duration = 0.15f), 
		(Red = 244,Green = 30,Blue = 88,Brightness = 100,Duration = 0.15f), 
		(Red = 60,Green = 25,Blue = 98,Brightness = 100,Duration = 0.15f), 
		(Red = 0,Green = 0,Blue = 100,Brightness = 100,Duration = 0.15f),  
		(Red = 0,Green = 100,Blue = 60,Brightness = 0,Duration = 0.15f),	
		(Red = 90,Green = 99,Blue = 60,Brightness = 100,Duration = 0.15f), 
		(Red = 100,Green = 60,Blue = 18,Brightness = 100,Duration = 0.15f), 
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.15f) 
		)}


	PukeEffectArr={(
		(Red = 50,Green = 50,Blue = 0,Brightness = 100,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 00,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 100,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 00,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 50,Green = 50,Blue = 0,Brightness = 100,Duration = 0.25f)
		)}

	ZedTimeBeginEffectArr={(
		(Red = 75,Green = 75,Blue = 75,Brightness = 05,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 10,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 15,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 20,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 25,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 30,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 35,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 40,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 45,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 50,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 55,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 60,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 65,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 70,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 75,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 80,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 85,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 90,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 95,Duration = 0.1f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.0f)
		)}

	ZedTimeEndEffectArr={(
		(Red = 75, Green = 75, Blue = 75, Brightness = 100, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 95, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 90, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 85, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 80, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 75, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 70, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 65, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 60, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 55, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 50, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 45, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 40, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 35, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 30, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 25, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 20, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 15, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 10, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 05, Duration = 0.1f),
		(Red = 75, Green = 75, Blue = 75, Brightness = 00, Duration = 0.25f)
		)}

	LowHealthEffectArr ={(
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 00,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 00,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 10,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 20,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 30,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 40,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 50,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 60,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 70,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 80,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 90,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.25f) 
		)}


	SirenEffectArr={(
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 0,Duration = 0.25f),
		(Red = 75,Green = 75,Blue = 75,Brightness = 100,Duration = 0.25f)
	)}

	FlashbangEffectArr={(
		(Red = 100,Green = 100,Blue = 100,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 100,Brightness = 100,Duration = 0.25f)
		)}


	HealEffectArr={(
		(Red = 0,Green = 100,Blue = 100,Brightness = 05,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 10,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 15,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 20,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 25,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 30,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 35,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 40,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 45,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 50,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 55,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 60,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 65,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 70,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 75,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 80,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 85,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 90,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 95,Duration = 0.1f),
		(Red = 0,Green = 100,Blue = 100,Brightness = 100,Duration = 0.25f)
		)}

	FireEffectArr={(
		(Red = 100,Green = 50,Blue = 25,Brightness = 05,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 15,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 25,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 35,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 45,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 55,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 65,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 75,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 85,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 95,Duration = 0.1f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 50,Blue = 25,Brightness = 100,Duration = 0.25f)
		)}

	GasEffectArr={(
		(Red = 100,Green = 100,Blue = 0,Brightness = 05,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 15,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 25,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 35,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 45,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 55,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 65,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 75,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 85,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 95,Duration = 0.1f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 100,Blue = 0,Brightness = 100,Duration = 0.25f)
		)}

	WaveIncomingEffectArr={(
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 0,Duration = 0.25f),
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.25f)
		)}

	ReadyEffectArr={(
		(Red = 0,Green = 100,Blue = 0,Brightness = 100,Duration = 0.0f)
	)}

	UnreadyEffectArr={(
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.0f)
	)}

	MatchWonEffectArr ={(
		(Red = 0,Green = 100,Blue = 0,Brightness = 100,Duration = 0.0f)
	)}

	MatchLostEffectArr ={(
		(Red = 100,Green = 0,Blue = 0,Brightness = 100,Duration = 0.0f)
	)}
		
}
