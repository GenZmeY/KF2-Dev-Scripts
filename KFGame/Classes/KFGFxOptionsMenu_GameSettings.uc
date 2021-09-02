//=============================================================================
// KFGFxOptionsMenu_GameSettings
//=============================================================================
// This menu will be used to update and display the audio options for the game
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Zane Gholson -  11/12/2014
//=============================================================================

class KFGFxOptionsMenu_GameSettings extends KFGFxObject_Menu;

//@HSL_MOD_BEGIN - amiller 5/25/2016 - Adding support to save extra data into profile settings
`include(KFProfileSettings.uci);
//@HSL_MOD_END

var localized string SectionNameString;
var localized string GameSettingsString;
var localized string FOVString;
var localized string FriendlyHudScaleString;
var localized string GoreString;
var localized string ShowCrosshairString;
var localized string WiderString;
var localized string NormalString;
var localized string ClassicWeaponSelectString;
var localized string KillTickerString;
var localized string DisableAutoUpgradeString;

var localized string HideBossHealthBarString;
var localized string ShowWelderInInvString;
var localized string UseAltAimOnDualString;
var localized string AntiMotionSicknessString;
var localized string AutoTurnOffString;
var localized string ReduceHighPitchNoiseString;

var localized string EnableMixerString;
var localized string DisableMixerString;

var localized array<string> GoreOptionStrings;

var localized string HideRemodeHeadshotEffectsString;
var localized string ToggleToRunString;
var localized string ClassicPlayerInfoString;

var localized string AllowSwap9mmString;

var float FOVMinValue, FOVMaxValue, FOVCurrentValue;
var float FriendlyHudScaleMinValue, FriendlyHudScaleMaxValue;

var const byte SHOW_NO_GORE_LEVEL;


function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu(InManager);
  	LocalizeText();
  	InitValues();
}

function LocalizeText()
{
    local GFxObject LocalizedObject, GoreOptions;
    local byte i;

    LocalizedObject = CreateObject( "Object" );

    GoreOptions = CreateArray();

    for (i = 0; i <  GoreOptionStrings.Length; i++)
    {
    	GoreOptions.SetElementString(i, GoreOptionStrings[i]);
    }

	//LocalizedObject.SetString("sectionName", SectionNameString);
    LocalizedObject.SetString("header", Caps(class'KFGFxOptionsMenu_Selection'.default.OptionStrings[OM_Gameplay]));
    LocalizedObject.SetString("fov", FOVString);
    LocalizedObject.SetString("friendlyHud", FriendlyHudScaleString);
    LocalizedObject.SetString("gore", GoreString);
    LocalizedObject.SetString("crosshair", ShowCrosshairString);
    LocalizedObject.SetString("classicWeaponSelect", ClassicWeaponSelectString);
    LocalizedObject.SetObject("goreOptions", GoreOptions);
    LocalizedObject.SetString("wider", WiderString);
    LocalizedObject.SetString("normal", NormalString);
    LocalizedObject.SetString("killTicker", KillTickerString);
    LocalizedObject.SetString("disableAutoUpgrade", DisableAutoUpgradeString);
	LocalizedObject.SetString("close", Class'KFCommon_LocalizedStrings'.default.BackString);
	LocalizedObject.SetString("resetDefault", Localize("KFGFxOptionsMenu_Graphics","DefaultString","KFGame"));
	LocalizedObject.SetString("hideRemoteHeadshotEffects", HideRemodeHeadshotEffectsString);
	LocalizedObject.SetString("enableToggleToRun", ToggleToRunString);
	LocalizedObject.SetString("enableClassicPlayerInfo", ClassicPlayerInfoString);

	LocalizedObject.SetString("hideBossHealthBar", 		HideBossHealthBarString);
	LocalizedObject.SetString("showWelderInInv", 		ShowWelderInInvString);
	LocalizedObject.SetString("useAltAimOnDual", 		UseAltAimOnDualString);
	
	LocalizedObject.SetString("autoTurnOff", 			AutoTurnOffString);

	LocalizedObject.SetString("enableMixer", 			EnableMixerString);
	LocalizedObject.SetString("disableMixer",			DisableMixerString);
	//woops these don't actually do anything
	//LocalizedObject.SetString("reduceHighPitchNoise", 	ReduceHighPitchNoiseString);
	//LocalizedObject.SetString("antiMotionSickness", 	AntiMotionSicknessString);

	LocalizedObject.SetString("allowSwap9mmLabel", AllowSwap9mmString);

    SetObject("localizedText", LocalizedObject);
}

function  InitValues()
{
	local GFxObject DataObject;

	//TODO:Savedata amiller - Figure out what is with the extra looking setFOVMinMax here
	SetFOVMinMax(FOVMinValue, FOVMaxValue);
	SetFriendlyHudMinMax(FriendlyHudScaleMinValue, FriendlyHudScaleMaxValue);
	DataObject = CreateObject( "Object" );


	if(class'WorldInfo'.static.IsConsoleBuild())
	{
		`log(`location@"CONSOLE"@Manager.CachedProfile.GetProfileFloat(KFID_FOVOptionsPercentageValue));
		DataObject.SetFloat("fov", 					Manager.CachedProfile.GetProfileFloat(KFID_FOVOptionsPercentageValue));
	}
	else
	{
		`log(`location@"PC"@Manager.CachedProfile.GetProfileFloat(KFID_FOVOptionsPercentageValue));

		// Setting still used by config in PC/NonConsole builds.
		DataObject.SetFloat("fov", 					Class'KFGameEngine'.default.FOVOptionsPercentageValue);

		// Setting not in the console build.		
		DataObject.SetBool("classicWeaponSelect",	Manager.CachedProfile.GetProfileBool(KFID_QuickWeaponSelect));
	}
 	DataObject.SetFloat("gore", 				Manager.CachedProfile.GetProfileInt(KFID_GoreLevel));
 	DataObject.SetFloat("friendlyHud", 			Manager.CachedProfile.GetProfileFloat(KFID_FriendlyHudScale));
 	DataObject.SetBool("crosshair", 			class'WorldInfo'.static.IsConsoleBuild() ? Manager.CachedProfile.GetProfileBool(KFID_ShowConsoleCrossHair) : Manager.CachedProfile.GetProfileBool(KFID_ShowCrossHair));

 	DataObject.SetBool("killTicker",			Manager.CachedProfile.GetProfileBool(KFID_ShowKillTicker));
 	DataObject.SetBool("disableAutoUpgrade",	Manager.CachedProfile.GetProfileBool(KFID_DisableAutoUpgrade));
	DataObject.SetBool("disableRemoteHeadShotEffects", Manager.CachedProfile.GetProfileBool(KFID_HideRemoteHeadshotEffects));

 	DataObject.SetBool("hideBossHealthBar", 	Manager.CachedProfile.GetProfileBool(KFID_HideBossHealthBar));
	DataObject.SetBool("showWelderInInv", 		Manager.CachedProfile.GetProfileBool(KFID_ShowWelderInInventory));
	DataObject.SetBool("useAltAimOnDual", 		Manager.CachedProfile.GetProfileBool(KFID_UseAltAimOnDuals));
	
	DataObject.SetBool("autoTurnOff", 			Manager.CachedProfile.GetProfileBool(KFID_AutoTurnOff));
	DataObject.SetBool("enableToggleToRun",		Manager.CachedProfile.GetProfileBool(KFID_ToggletoRun));
	DataObject.SetBool("enableClassicPlayerInfo", Manager.CachedProfile.GetProfileBool(KFID_ClassicPlayerInfo));

	DataObject.SetBool("allowSwapTo9mm", Manager.CachedProfile.GetProfileBool(KFID_AllowSwapTo9mm));

	if(class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
	{
		DataObject.SetBool("bDingo", true);
		DataObject.SetBool("bMixerEnabled", class'MixerIntegration'.static.IsMixerInteractionEnabled());
	}
	
	//not implemented
	//DataObject.SetBool("antiMotionSickness", 	Manager.CachedProfile.GetProfileBool(KFID_AntiMotionSickness));
	//DataObject.SetBool("reduceHighPitchNoise", 	Manager.CachedProfile.GetProfileBool(KFID_ReduceHightPitchSounds));

 	SetObject("dataValues", DataObject);
}

//use this funtion to set the min and max fov values.
function SetFOVMinMax( float MinVol, float MaxVol )
{
	ActionScriptVoid("setfovRange");
}

//use this funtion to set the min and max fov values.
function SetFriendlyHudMinMax( float MinVol, float MaxVol )
{
	ActionScriptVoid("setFriendlyHudRange");
}

function Callback_CloseMenu()
{
	Manager.CachedProfile.Save( GetLP().ControllerId );
	Manager.OpenMenu( UI_OptionsSelection );
}

function Callback_ToggleMixer(bool bActive)
{
	local KFPlayerController KFPC;	

	KFPC = KFPlayerController(GetPC());
	if( KFPC != none )
	{
		If(bActive)
		{
			KFPC.InitializeMixer();
		}
		else
		{
			KFPC.ShutdownMixer();
		}
	}
}

function Callback_ToggleCrosshair( bool bShow )
{
	local KFPlayerController KFPC;
	local KFHUDBase KFHUD;
	local OnlineProfileSettings Settings;
	

	KFPC = KFPlayerController(GetPC());
	if( KFPC != none )
	{
		KFHUD = KFHUDBase(KFPC.myHUD);

		if( KFHUD != none )
		{
			KFHUD.bDrawCrosshair = bShow;
		}
	}

	class'KFGameEngine'.static.SetCrosshairEnabled(bShow);

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	Settings.SetProfileSettingValueInt(class'WorldInfo'.static.IsConsoleBuild() ? KFID_ShowConsoleCrossHair : KFID_ShowCrossHair, bShow ? 1 : 0);
}

function Callback_FOVChanged( float NewFOVPercentage )
{
	local PlayerController PC;
	local KFGameEngine KFGE;
	local OnlineProfileSettings Settings;

	KFGE = KFGameEngine(Class'Engine'.static.GetEngine());
	KFGE.FOVOptionsPercentageValue = NewFOVPercentage;
	KFGE.SaveConfig();

	class'KFGameEngine'.default.FOVOptionsPercentageValue = NewFOVPercentage;
	class'KFGameEngine'.static.StaticSaveConfig();

	PC = GetPC();

	if( PC != none )
	{
		//update FOV on camera here 
		PC.PlayerCamera.SetFOV( PC.PlayerCamera.DefaultFOV * NewFOVPercentage );
		PC.PlayerCamera.UpdateCamera(0.0);
	}

	if(class'WorldInfo'.static.IsConsoleBuild())
	{
		Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
		Settings.SetProfileSettingValueFloat(KFID_FOVOptionsPercentageValue, NewFOVPercentage);
	}
}

function Callback_FriendlyHudChanged(float NewFriendlyHudScale)
{
	local KFPlayerController KFPC;
	local KFHUDBase KFHUD;
	local OnlineProfileSettings Settings;
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);

	KFPC = KFPlayerController(GetPC());
	
	if(KFPC != none)
	{
		KFHUD = KFHUDBase(KFPC.myHUD);

		if(KFHUD != none)
		{
			KFHUD.FriendlyHudScale = NewFriendlyHudScale;
			KFHUD.SaveConfig();
		}
		
		Settings.SetProfileSettingValueFloat(KFID_FriendlyHudScale, NewFriendlyHudScale);
		class'KFHUDBase'.static.StaticSaveConfig();
	}
}

function Callback_WeaponSelectChanged(bool bActive)
{
	local KFPlayerInput KFPI;
	local OnlineProfileSettings Settings;

	KFPI = KFPlayerInput(GetPC().PlayerInput);
	KFPI.bQuickWeaponSelect = bActive;
	
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	Settings.SetProfileSettingValueInt(KFID_QuickWeaponSelect, bActive ? 1 : 0);
}

function Callback_DisableAutoUpgradeChanged(bool bActive)
{
	local KFPlayerController KFPC;
	local OnlineProfileSettings Settings;

	KFPC = KFPlayerController(GetPC());

	KFPC.bDisableAutoUpgrade = bActive;

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	Settings.SetProfileSettingValueInt(KFID_DisableAutoUpgrade, bActive ? 1 : 0);
}

function Callback_DisableRemoteHeadshotEffects(bool bActive)
{
	local KFPlayerController KFPC;
	local OnlineProfileSettings Settings;

	KFPC = KFPlayerController(GetPC());

	KFPC.bHideRemotePlayerHeadshotEffects = bActive;

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	Settings.SetProfileSettingValueInt(KFID_HideRemoteHeadshotEffects, bActive ? 1 : 0);
}

function Callback_KillTickerChanged(bool bActive)
{
	local KFPlayerController KFPC;
	local OnlineProfileSettings Settings;

	KFPC = KFPlayerController(GetPC());

	KFPC.bShowKillTicker = bActive;

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	Settings.SetProfileSettingValueInt(KFID_ShowKillTicker, bActive ? 1 : 0);
}

function Callback_GoreChanged( int NewGoreLevel )
{
	local KFGameInfo KFGI; 
	local OnlineProfileSettings Settings;
	local KFGoreManager GoreMgr;
	
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);

	if( GetPC().WorldInfo.NetMode == NM_Standalone )
	{
		KFGI = KFGameInfo(GetPC().WorldInfo.Game);
		if(KFGI != none)
		{
			KFGI.GoreLevel = NewGoreLevel;
			KFGI.SaveConfig();
		}
	}
	else if(!class'WorldInfo'.static.IsConsoleBuild())
	{		
		// Legacy support
		class'GameInfo'.default.GoreLevel = NewGoreLevel;
		class'GameInfo'.static.StaticSaveConfig();
	}

	GoreMgr = KFGoreManager(class'WorldInfo'.static.GetWorldInfo().MyGoreEffectManager);
	if(GoreMgr != none)
	{
		GoreMgr.DesiredGoreLevel = NewGoreLevel;
	}

	Settings.SetProfileSettingValueInt(KFID_GoreLevel, NewGoreLevel);
}

function Callback_UseAltAimOnDualsChanged(bool bActive)
{
	local KFGameEngine KFGEngine;
	local OnlineProfileSettings Settings;
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	
	if(Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_UseAltAimOnDuals, bActive ? 1 : 0);
	}

	KFGEngine = KFGameEngine(Class'KFGameEngine'.static.GetEngine());

	if(KFGEngine != none)
	{
		KFGEngine.bUseAltAimOnDual = bActive;
	}
}

function Callback_HideBossHealthBarChanged(bool bActive)
{
	local KFPlayerController KFPC;
	local OnlineProfileSettings Settings;

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	
	if(Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_HideBossHealthBar, bActive ? 1 : 0);
	}

	KFPC = KFPlayerController(GetPC());
	KFPC.bHideBossHealthBar = bActive;
}

function Callback_AntiMotionSicknessChanged(bool bActive)
{
	local KFGameEngine KFGEngine;
	local OnlineProfileSettings Settings;

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	
	if(Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_AntiMotionSickness, bActive ? 1 : 0);
	}

	KFGEngine = KFGameEngine(Class'KFGameEngine'.static.GetEngine());

	if(KFGEngine != none)
	{
		KFGEngine.bAntiMotionSickness = bActive;
	}
}

function Callback_bShowWelderInInvChanged(bool bActive)
{
	local KFGameEngine KFGEngine;
	local OnlineProfileSettings Settings;
	local KFWeapon KFW;
	local KFPlayerController KFPC;
	local KFInventoryManager KFIM;

	KFPC = KFPlayerController(GetPC());
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	
	if(Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_ShowWelderInInventory, bActive ? 1 : 0);
	}

	KFGEngine = KFGameEngine(Class'KFGameEngine'.static.GetEngine());

	if(KFGEngine != none)
	{
		KFGEngine.bShowWelderInInv = bActive;
		//get inventory and update the welder

		//refresh inventory
		KFIM = KFInventoryManager(KFPC.Pawn.InvManager);
		if(KFIM != none)
		{
			foreach KFIM.InventoryActors( class'KFWeapon', KFW )
			{
				if( KFW.IsA('KFWeap_Welder') )
				{
					KFW.SetShownInInventory(bActive);
					return;
				}
			}
		}
	}
}

function Callback_AutoTurnOffChanged(bool bActive)
{
	local KFPlayerController KFPC;
	local OnlineProfileSettings Settings;

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	
	if(Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_AutoTurnOff, bActive ? 1 : 0);
	}
	KFPC = KFPlayerController(GetPC());
	KFPC.bSkipNonCriticalForceLookAt = bActive;
}

function Callback_ReduceHighPitchNoiseChanged(bool bActive)
{
	local KFPlayerController KFPC;
	local OnlineProfileSettings Settings;

	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	
	if(Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_ReduceHightPitchSounds, bActive ? 1 : 0);
	}

	KFPC = KFPlayerController(GetPC());
	KFPC.bNoEarRingingSound = bActive;	
}

function CallBack_ResetGameOptions()
{
	Manager.DelayedOpenPopup( EConfirmation, EDPPID_Misc,
		Localize("KFGFxOptionsMenu_Graphics","WarningPromptString","KFGame"), 
		Localize("KFGFxObject_Menu","ResetDefaults","KFGameConsole"),
		Localize("KFGFxOptionsMenu_Graphics","OKString","KFGame"),
		Localize("KFGFxOptionsMenu_Graphics","CancelString","KFGame"),
		ResetGameOptions);
}


function Callback_ToggleToRunChanged(bool bActive)
{
	local OnlineProfileSettings Settings;
	local name SprintName;
	local KFPlayerInput KFPI;

	SprintName='GBA_Sprint';
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	KFPI = KFPlayerInput(GetPC().PlayerInput);

	if (Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_ToggleToRun, bActive ? 1 : 0);
	}	

	if (KFPI != none)
	{
		KFPI.bToggleToRun = bActive;
		if (bActive)
		{
			KFPI.SetBind(SprintName, "ToggleSprint");
		}
		else
		{
			KFPI.SetBind(SprintName, "Button bRun");
		}
	}
}

function Callback_ClassicPlayerInfoChanged(bool bActive)
{
	local KFPlayerController KFPC;
	local KFHUDBase KFHUD;
	local OnlineProfileSettings Settings;
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);

	KFPC = KFPlayerController(GetPC());

	if (KFPC != none)
	{
		KFHUD = KFHUDBase(KFPC.myHUD);

		if (KFHUD != none)
		{
			KFHUD.ClassicPlayerInfo = bActive;
			KFHUD.SaveConfig();
		}

		Settings.SetProfileSettingValueInt(KFID_ClassicPlayerInfo, bActive ? 1 : 0);
		class'KFHUDBase'.static.StaticSaveConfig();
	}
}

function Callback_AllowSwapTo9mm(bool bActive)
{
	local OnlineProfileSettings Settings;
	local KFPlayerInput KFPI;
	
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings(GetLP().ControllerId);
	KFPI = KFPlayerInput(GetPC().PlayerInput);

	if (Settings != none)
	{
		Settings.SetProfileSettingValueInt(KFID_AllowSwapTo9mm, bActive ? 1 : 0);
	}	

	if (KFPI != none)
	{
		KFPI.bAllowSwapTo9mm = bActive;
	}
}

function ResetGameOptions()
{
	//local KFPlayerController KFPC;
	//local KFGameEngine KFGEngine;

	//KFPC = KFPlayerController(GetPC());
	//KFGEngine = KFGameEngine(Class'KFGameEngine'.static.GetEngine());


	Callback_GoreChanged(Manager.CachedProfile.GetDefaultInt(KFID_GoreLevel));
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_GoreLevel, Manager.CachedProfile.GetDefaultInt(KFID_GoreLevel));

	Callback_FriendlyHudChanged(Manager.CachedProfile.GetDefaultFloat(KFID_FriendlyHudScale));
	//Manager.CachedProfile.SetProfileSettingValueFloat(KFID_FriendlyHudScale, Manager.CachedProfile.GetDefaultFloat(KFID_FriendlyHudScale));	

	Callback_ToggleCrosshair((class'WorldInfo'.static.IsConsoleBuild() ? Manager.CachedProfile.GetDefaultInt(KFID_ShowConsoleCrossHair) : Manager.CachedProfile.GetDefaultInt(KFID_ShowCrossHair)) != 0);
	//Manager.CachedProfile.SetProfileSettingValueInt(class'WorldInfo'.static.IsConsoleBuild() ? KFID_ShowConsoleCrossHair : KFID_ShowCrossHair, 
	//												class'WorldInfo'.static.IsConsoleBuild() ? Manager.CachedProfile.GetDefaultInt(KFID_ShowConsoleCrossHair) : Manager.CachedProfile.GetDefaultInt(KFID_ShowCrossHair));
	
	Callback_KillTickerChanged(Manager.CachedProfile.GetDefaultInt(KFID_ShowKillTicker) != 0);
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_ShowKillTicker, Manager.CachedProfile.GetDefaultInt(KFID_ShowKillTicker));

	//Added 7/11/2016
	Callback_UseAltAimOnDualsChanged(Manager.CachedProfile.GetDefaultInt(KFID_UseAltAimOnDuals) != 0);
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_UseAltAimOnDuals, KFGEngine.bUseAltAimOnDual);

	Callback_HideBossHealthBarChanged(Manager.CachedProfile.GetDefaultInt(KFID_HideBossHealthBar) != 0);
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_HideBossHealthBar, Manager.CachedProfile.GetDefaultInt(KFID_HideBossHealthBar));	

	Callback_AntiMotionSicknessChanged(Manager.CachedProfile.GetDefaultInt(KFID_AntiMotionSickness) != 0);
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_AntiMotionSickness, KFGEngine.bAntiMotionSickness);
	
	Callback_bShowWelderInInvChanged(Manager.CachedProfile.GetDefaultInt(KFID_ShowWelderInInventory) != 0);
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_ShowWelderInInventory, KFGEngine.bShowWelderInInv );
	
	Callback_AutoTurnOffChanged(Manager.CachedProfile.GetDefaultInt(KFID_AutoTurnOff) != 0);
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_AutoTurnOff, KFPC.bSkipNonCriticalForceLookAt);

	Callback_ReduceHighPitchNoiseChanged(Manager.CachedProfile.GetDefaultInt(KFID_ReduceHightPitchSounds) != 0);	
	//Manager.CachedProfile.SetProfileSettingValueInt(KFID_ReduceHightPitchSounds, KFPC.bNoEarRingingSound);

    Callback_DisableAutoUpgradeChanged(Manager.CachedProfile.GetDefaultInt(KFID_DisableAutoUpgrade) != 0);

	Callback_ToggleToRunChanged(Manager.CachedProfile.GetDefaultInt(KFID_ToggleToRun) != 0);

	Callback_DisableRemoteHeadshotEffects(Manager.CachedProfile.GetDefaultInt(KFID_HideRemoteHeadshotEffects) != 0);

	if ( !GetPC().WorldInfo.IsConsoleBuild() )
	{
		Callback_WeaponSelectChanged(Manager.CachedProfile.GetDefaultInt(KFID_QuickWeaponSelect) != 0);
		//Manager.CachedProfile.SetProfileSettingValueInt(KFID_QuickWeaponSelect, Manager.CachedProfile.GetDefaultInt(KFID_QuickWeaponSelect));
	}

	Callback_FOVChanged(Manager.CachedProfile.GetDefaultFloat(KFID_FOVOptionsPercentageValue));

	Callback_ClassicPlayerInfoChanged(Manager.CachedProfile.GetDefaultInt(KFID_ClassicPlayerInfo) != 0);

	Callback_AllowSwapTo9mm(Manager.CachedProfile.GetDefaultInt(KFID_AllowSwapTo9mm) != 0);

	InitValues();
}

defaultproperties
{
	FOVMinValue=1
	FOVMaxValue=1.25
	FriendlyHudScaleMinValue=0.25
	FriendlyHudScaleMaxValue=1.0
}