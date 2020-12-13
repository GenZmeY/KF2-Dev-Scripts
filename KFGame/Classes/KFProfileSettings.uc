/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 */

/**
 * This class holds the data used in reading/writing online profile settings.
 * Online profile settings are stored by an external service.
 */
class KFProfileSettings extends OnlineProfileSettings
	native;

`include(KFProfileSettings.uci)

struct native WeaponSkinPairs
{
	var init string	ClassPath;
	var int		SkinId;
};

var transient array<CustomizationInfo> Characters;
var transient array<string> FavoriteWeapons;
var transient array<WeaponSkinPairs> ActiveSkins;
var transient bool Dirty;

event FavoriteWeapon(name WeaponName)
{
	if(FavoriteWeapons.Find(string(WeaponName)) == INDEX_NONE)
	{
		// Only add if unique
		FavoriteWeapons.AddItem(string(WeaponName));
		Dirty = true;
	}
}

event UnFavoriteWeapon(name WeaponName)
{
	local int Index;
	Index = FavoriteWeapons.Find(string(WeaponName));
	if( Index != INDEX_NONE )
	{
		FavoriteWeapons.Remove(Index, 1);
		Dirty = true;
	}
}

event Save( byte ControllerId )
{
	if(Dirty)
	{
		FlattenExtraToProfileSettings();
		if( KFGameEngine(class'Engine'.static.GetEngine()).LocalLoginStatus != LS_UsingLocalProfile )
		{
			class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.WriteProfileSettings(ControllerId, self);
		}
		Dirty = false;
	}
}

native function SaveWeaponSkin(string ClassPath, int Id);
native function ClearWeaponSkin(string ClassPath);

event ApplyWeaponSkin(int ItemDefinition)
{
	local class<KFWeaponDefinition> WeaponDef;
	local int ItemIndex;

	ItemIndex = class'KFWeaponSkinList'.default.Skins.Find('Id', ItemDefinition);

	if(ItemIndex == INDEX_NONE)
	{
		return;
	}

	WeaponDef = class'KFWeaponSkinList'.default.Skins[ItemIndex].WeaponDef;

	if(WeaponDef != none)
	{
		class'KFWeaponSkinList'.Static.SaveWeaponSkin(WeaponDef, ItemDefinition);
	}
}

function bool HasSafeFrameSet()
{
	return GetProfileFloat( KFID_SafeFrameScale ) != 0.f;
}

function bool SetProfileSettingValueInt(int ProfileSettingId,int Value)
{
	if(super.SetProfileSettingValueInt(ProfileSettingId, Value))
	{
		Dirty = true;
		return true;
	}

	//`QALog(`location@"Failed to set value for"@`showvar(ProfileSettingId)@"To"@`showvar(Value));

	return false;
}

function bool SetProfileSettingValueBool(int ProfileSettingId, bool Value)
{
	if(super.SetProfileSettingValueInt(ProfileSettingId, Value ? 1 : 0))
	{
		Dirty = true;
		return true;
	}

	//`QALog(`location@"Failed to set value for"@`showvar(ProfileSettingId)@"To"@`showvar(Value));

	return false;
}

function bool SetProfileSettingValueFloat(int ProfileSettingId,float Value)
{
	if(super.SetProfileSettingValueFloat(ProfileSettingId, Value))
	{
		Dirty = true;
		return true;
	}

	//`QALog(`location@"Failed to set value for"@`showvar(ProfileSettingId)@"To"@`showvar(Value));

	return false;
}

event int GetProfileInt(int ProfileSettingId)
{
	local int tempInt;
	GetProfileSettingValueInt(ProfileSettingId, tempInt);
	return tempInt;
}


event bool GetProfileBool(int ProfileSettingId)
{
	local int tempInt;
	GetProfileSettingValueInt(ProfileSettingId, tempInt);
	return tempInt != 0;
}

event float GetProfileFloat(int ProfileSettingId)
{
	local float tempFloat;
	GetProfileSettingValueFloat(ProfileSettingId, tempFloat);
	return tempFloat;
}

event string GetProfileString(int ProfileSettingId)
{
	local string TempStr;
	GetProfileSettingValue(ProfileSettingId, TempStr);
	return TempStr;
}


function int GetDefaultInt(int ProfileSettingId)
{
	local int tempInt;
	GetProfileSettingDefaultInt(ProfileSettingId, tempInt);
	return tempInt;
}


function bool GetDefaultBool(int ProfileSettingId)
{
	local int tempInt;
	GetProfileSettingDefaultInt(ProfileSettingId, tempInt);
	return tempInt != 0;
}

function float GetDefaultFloat(int ProfileSettingId)
{
	local float tempFloat;
	GetProfileSettingDefaultFloat(ProfileSettingId, tempFloat);
	return tempFloat;
}


native function bool SetCharacterGear(const out CustomizationInfo GearSet);

native function PushProfileSettingsToClasses();

native event SetToDefaults();

//@HSL_MOD_BEGIN - amiller 5/11/2016 - Adding support to save extra data into profile settings
native function FlattenExtraToProfileSettings();
native function ExpandExtraFromProfileSettings();
//@HSL_MOD_END

cpptext
{
	void ForceCharacterSync();
}

defaultproperties
{
	VersionNumber=6
	Dirty=false

	// UI readable versions of the owners
	OwnerMappings(0)=(Id=OPPO_None)
	OwnerMappings(1)=(Id=OPPO_OnlineService)
	OwnerMappings(2)=(Id=OPPO_Game)

	ProfileMappings.Empty()
	// Meta data for displaying in the UI
	ProfileMappings.Add((Id=KFID_QuickWeaponSelect, Name="Quick Weapon Select", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_CurrentLayoutIndex, Name="Current Layout Index", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_ForceFeedbackEnabled, Name="Force Feedback Enabled", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedPerkIndex, Name="Saved Perk Index", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_AllowBloodSplatterDecals, Name="Allow Blood Splatter Decals", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_GoreLevel, Name="Gore Level", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_StoredCharIndex, Name="Stored Character Index", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_MasterVolumeMultiplier, Name="Master Volume Multi", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_DialogVolumeMultiplier, Name="Dialog Volume Multi", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_MusicVolumeMultiplier, Name="Music Volume Multi", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SFXVolumeMultiplier, Name="SFX Volume Multi", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_GammaMultiplier, Name="Gamma Multiplier", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_MusicVocalsEnabled, Name="Music Vocals Enabled", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_MinimalChatter, Name="Minimal Chatter", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_ShowCrossHair, Name="Show Crosshair", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_FOVOptionsPercentageValue, Name="FOV Options Percentage", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_ShowKillTicker, Name="FOV Options Percentage", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_FriendlyHudScale, Name="Friendly HUD Scale", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_FavoriteWeapons, Name="Favorite Weapons", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_GearLoadouts, Name="Gear Loadouts", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SetGamma, Name="Set Gamma", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_RequiresPushToTalk, Name="RequiresPushToTalk", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_InvertController, Name="controllerInvertedValue", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_AutoTargetEnabled, Name="AutoTarget Enabled", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_GamepadSensitivityScale, Name="GamepadSensitivityScale", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_ZoomedSensitivityScale, Name="Zoomed Sensitivity", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_GamepadZoomedSensitivityScale, Name="Gamepad Zoomed Sensitivity", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_MouseSensitivity, Name="View acceleration enabled", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_TargetAdhesionEnabled, Name="aimAssistRotationValue", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_TargetFrictionEnabled, Name="aimAssistSlowDownValue", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_InvertMouse, Name="invertedValue", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_EnableMouseSmoothing, Name="mouseSmoothingLabel", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_VOIPVolumeMultiplier, Name="VOIPVolumeMultiplier", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_VOIPMicVolumeMultiplier, Name="VOIPMicVolumeMultiplier", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedSoloModeIndex, Name="SavedSoloModeIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedSoloMapString, Name="SavedSoloMapString", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedSoloDifficultyIndex, Name="SavedSoloDifficultyIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedSoloLengthIndex, Name="SavedSoloLengthIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedModeIndex, Name="SavedModeIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedMapString, Name="SavedMapString", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedDifficultyIndex, Name="SavedDifficultyIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedLengthIndex, Name="SavedLengthIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedPrivacyIndex, Name="SavedPrivacyIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedServerTypeIndex, Name="SavedServerTypeIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedInProgressIndex, Name="SavedInProgressIndex", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_ControllerSoundEnabled, Name="Controller Sound Enabled", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_MatchmakingRegion, Name="Matchmaking Region", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_GamepadDeadzoneScale, Name="Gamepad Deadzone", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_GamepadAccelerationJumpScale, Name="Gamepad Acceleration Jump", MappingType=PVMT_RawValue))


	//Added 7/11/2016
	ProfileMappings.Add((Id=KFID_UseAltAimOnDuals, Name="Use alt Dual Aim", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_HideBossHealthBar, Name="Hide Boss Health Bar", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_AntiMotionSickness, Name="Anti Motion Sickness", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_ShowWelderInInventory, Name="Show Welder in Inventory", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_AutoTurnOff, Name="Auto Turn off", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_ReduceHightPitchSounds, Name="Reduce High Pitch Sounds", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_DisableAutoUpgrade, Name="Disable Auto Upgrade", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_HideRemoteHeadshotEffects, Name="Hide Remote Player Headshot Effects", MappingType=PVMT_RawValue))

	//Added 9/6/2016- Support for WeaponSkins
	ProfileMappings.Add((Id=KFID_WeaponSkinAssociations, Name="Weapon Skin KeyValue Pairs", MappingType=PVMT_RawValue))
	//PS4 specific
	ProfileMappings.Add((Id=KFID_ShowConsoleCrossHair, Name="Show Console Crosshair", MappingType=PVMT_RawValue))

	ProfileMappings.Add((Id=KFID_SavedEmoteId, Name="Saved Emote ID", MappingType=PVMT_RawValue))
	ProfileMappings.Add((Id=KFID_SavedHeadshotID, Name="Saved Headshot ID", MappingType=PVMT_RawValue))

	//Added 2/27/2017 - Support for safe frame setting
	ProfileMappings.Add((Id=KFID_SafeFrameScale, Name="Safe Frame", MappingType=PVMT_RawValue))

	//Added 8/21/2017 - Support for native 4k rendering on Xbox One X (Scorpio)
	ProfileMappings.Add((Id=KFID_Native4kResolution, Name="Native 4k Resolution", MappingType=PVMT_RawValue))

	//Added 1/31/2019 - Toggle for Sprint
	ProfileMappings.Add((Id=KFID_ToggleToRun, Name="Toggle To Run", MappingType=PVMT_RawValue))

	//Added 3/6/2019 - Classic Player Info
	ProfileMappings.Add((Id = KFID_ClassicPlayerInfo, Name = "Legacy Health Bars", MappingType = PVMT_RawValue))

	//Added 10/15/2020 - Has Enter to Store Tab during sales
	ProfileMappings.Add((Id = KFID_HasTabbedToStore, Name = "Has Tabbed To Store", MappingType = PVMT_RawValue))

	// Hex values for SDT_Float values, I use http://www.h-schmidt.net/FloatConverter/IEEE754.html for conversion

	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_QuickWeaponSelect,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_CurrentLayoutIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ForceFeedbackEnabled,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedPerkIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_AllowBloodSplatterDecals,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_GoreLevel,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_StoredCharIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_MasterVolumeMultiplier,Data=(Type=SDT_Float,Value1=0x42480000)))) //50.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_DialogVolumeMultiplier,Data=(Type=SDT_Float,Value1=0x42480000)))) //50.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_MusicVolumeMultiplier,Data=(Type=SDT_Float,Value1=0x42480000)))) //50.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SFXVolumeMultiplier,Data=(Type=SDT_Float,Value1=0x42480000)))) //50.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_GammaMultiplier,Data=(Type=SDT_Float,Value1=0x3f666666)))) // 0.9f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_MusicVocalsEnabled,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_MinimalChatter,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ShowCrossHair,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_FOVOptionsPercentageValue,Data=(Type=SDT_Float,Value1=0x3f800000)))) // 1.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ShowKillTicker,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_FriendlyHudScale,Data=(Type=SDT_Float,Value1=0x3f800000)))) // default of 1.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_FavoriteWeapons,Data=(Type=SDT_String,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_GearLoadouts,Data=(Type=SDT_String,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SetGamma,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_RequiresPushToTalk,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_InvertController,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_GamepadSensitivityScale,Data=(Type=SDT_Float,Value1=0x3f800000)))) // 1.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ZoomedSensitivityScale,Data=(Type=SDT_Float,Value1=0x3eb33333)))) // 0.35f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_GamepadZoomedSensitivityScale,Data=(Type=SDT_Float,Value1=0x3f19999a)))) // 0.60f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_MouseSensitivity,Data=(Type=SDT_Float,Value1=0x41f00000)))) // 30.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_TargetAdhesionEnabled,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_TargetFrictionEnabled,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_AutoTargetEnabled,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_InvertMouse,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_EnableMouseSmoothing,Data=(Type=SDT_Int32,Value1=1))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_VOIPVolumeMultiplier,Data=(Type=SDT_Float,Value1=0x3fc00000)))) // 1.50f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_VOIPMicVolumeMultiplier,Data=(Type=SDT_Float,Value1=0x42480000)))) // 50.0f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedSoloModeIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedSoloMapString,Data=(Type=SDT_String,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedSoloDifficultyIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedSoloLengthIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedModeIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedMapString,Data=(Type=SDT_String,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedDifficultyIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedLengthIndex,Data=(Type=SDT_Int32,Value1=0))))	//default to any
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedPrivacyIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedServerTypeIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedInProgressIndex,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ControllerSoundEnabled,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_MatchmakingRegion,Data=(Type=SDT_String,Value1=0))))
	//Added 7/11/2016
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_UseAltAimOnDuals,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_HideBossHealthBar,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_AntiMotionSickness,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ShowWelderInInventory,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_AutoTurnOff,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ReduceHightPitchSounds,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_DisableAutoUpgrade,Data=(Type=SDT_Int32,Value1=0))))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId= KFID_HideRemoteHeadshotEffects,Data=(Type=SDT_Int32,Value1=1))))

	//Added 9/6/2016- Support for WeaponSkins
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_WeaponSkinAssociations,Data=(Type=SDT_String, Value1=0))))

	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_ShowConsoleCrossHair,Data=(Type=SDT_Int32,Value1=1))))

	//Added 11/2/2016- Support for Emotes
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedEmoteId,Data=(Type=SDT_Int32,Value1=-1))))
	//Added 6/6/2018- Support for Emotes
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_SavedHeadshotID,Data=(Type=SDT_Int32,Value1=-1))))
	

	//Added 2/27/2017 - Support for safe frame setting
	DefaultSettings.Add((Owner=OPPO_Game, ProfileSetting=(PropertyId=KFID_SafeFrameScale,Data=(Type=SDT_Float,Value1=0))))

	//Added 8/21/2017 - Support for native 4k rendering on Xbox One X (Scorpio)
	DefaultSettings.Add((Owner=OPPO_Game, ProfileSetting=(PropertyId=KFID_Native4kResolution,Data=(Type=SDT_Int32,Value1=0))))

	//Added 1/31/2019 - Toggle for Sprint
	DefaultSettings.Add((Owner=OPPO_Game, ProfileSetting=(PropertyId=KFID_ToggleToRun, Data=(Type=SDT_INT32, Value1=1))))

	//Added 3/6/2019 - Classic Player Info
	DefaultSettings.Add((Owner=OPPO_Game, ProfileSetting=(PropertyId=KFID_ClassicPlayerInfo, Data=(Type=SDT_INT32, Value1=0))))

	//Added 10/1/2020 - Support for deadzone and acceleration jump gamepad settings
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_GamepadDeadzoneScale,Data=(Type=SDT_Float,Value1=0x3e4ccccd)))) // 0.20f
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_GamepadAccelerationJumpScale,Data=(Type=SDT_Float,Value1=0x3ecccccd)))) // 0.4f

	//Saber Added 10/15/2020 - Has Enter to Store Tab during sales
	ProfileMappings.Add((Id = KFID_HasTabbedToStore, Name = "Has Tabbed To Store", MappingType = PVMT_RawValue))
	DefaultSettings.Add((Owner=OPPO_Game,ProfileSetting=(PropertyId=KFID_HasTabbedToStore,Data=(Type=SDT_Int32,Value1=0))))
}
