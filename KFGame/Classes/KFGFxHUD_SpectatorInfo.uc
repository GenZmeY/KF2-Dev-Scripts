//=============================================================================
// KFGFxHUD_SpectatorInfo
//=============================================================================
// HUD container that stores information about the viewTarget's pawn while in
// spectator mode 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Alex Quick 5/15/2014
//=============================================================================

class KFGFxHUD_SpectatorInfo extends GFxObject;

var localized string PrevPlayerString;
var localized string NextPlayerString;
var localized string ChangeCameraString;

var GFxObject SpectatorInfoMC;
var KFPlayerReplicationInfo SpectatedKFPRI;
var byte LastPerkLevel;
var byte LastPrestigeLevel;
var bool bLastVisible;
var class<KFPerk> LastPerkClass;

function InitializeHUD()
{
    LocalizeText();
    SpectatorInfoMC = GetObject("spectatorInfoMC");
}

function LocalizeText()
{
	local GFxObject TempObject;
	TempObject = CreateObject("Object");

    TempObject.SetString("prevPlayer", PrevPlayerString);
    TempObject.SetString("nextPlayer", NextPlayerString);
    TempObject.SetString("changeCamera", ChangeCameraString);

    SetObject("localizedText", TempObject);
}

//spectatorInfoMC
function SetPlayerInfoVisible(bool bValue)
{
    if(SpectatorInfoMC != none && bValue != bLastVisible)
    {
		bLastVisible = bValue;
        SpectatorInfoMC.SetVisible(bValue);
    }
}

function TickHud(float DeltaTime)
{
	UpdateSpectateeInfo();
}

function UpdateUsingGamepad(bool bIsUsingGamepad)
{
    SetBool("bUsingGamePad", bIsUsingGamepad);
}

function SetSpectatedKFPRI( KFPlayerReplicationInfo TempKFPRI )
{
	local bool bPRIChanged;
	bPRIChanged = TempKFPRI != SpectatedKFPRI;
    SpectatedKFPRI = TempKFPRI;
    UpdateSpectateeInfo(bPRIChanged);
}

function UpdateSpectateeInfo(optional bool bForceUpdate)
{    
    if( GetPC().PlayerCamera.CameraStyle == 'Boss' || GetPC().WorldInfo.NetMode == NM_Standalone || !GetPC().IsSpectating())
    {
        SetVisible(false);  
        return;
    }
    else
    {
        if( SpectatedKFPRI == GetPC().PlayerReplicationInfo || SpectatedKFPRI == none)
        {
            SetPlayerInfoVisible(false);
            return;
        }
        else
        {
            SetPlayerInfoVisible(true);
            UpdatePlayerInfo(bForceUpdate);           
        }
        
    }
    
}

function UpdatePlayerInfo(optional bool bForceUpdate)
{
	local GFxObject TempObject;
    local byte CurrentPerkLevel;
	local byte CurrentPrestigeLevel;
	local GFxObject PerkIconObject;

    if(SpectatedKFPRI == none)
    {
        return;
    }

    CurrentPerkLevel = SpectatedKFPRI.GetActivePerkLevel();
	CurrentPrestigeLevel = SpectatedKFPRI.GetActivePerkPrestigeLevel();

    // Update the perk class.
    if( ( LastPerkClass != SpectatedKFPRI.CurrentPerkClass ) || ( LastPerkLevel != CurrentPerkLevel ) || LastPrestigeLevel != CurrentPrestigeLevel || bForceUpdate )
    {
        LastPerkLevel = CurrentPerkLevel;
        LastPerkClass = SpectatedKFPRI.CurrentPerkClass;
		LastPrestigeLevel = CurrentPrestigeLevel;
		
        TempObject = CreateObject("Object");
        if( TempObject != none )
        {
            TempObject.SetString("playerName", SpectatedKFPRI.PlayerName);
            TempObject.SetString("playerPerk", SpectatedKFPRI.CurrentPerkClass.default.LevelString @SpectatedKFPRI.GetActivePerkLevel() @SpectatedKFPRI.CurrentPerkClass.default.PerkName );
            //TempObject.SetString("iconPath", "img://" $SpectatedKFPRI.CurrentPerkClass.static.GetPerkIconPath());
            
			PerkIconObject = CreateObject("Object");
			PerkIconObject.SetString("perkIcon", "img://"$SpectatedKFPRI.CurrentPerkClass.static.GetPerkIconPath());
			PerkIconObject.SetString("prestigeIcon", SpectatedKFPRI.CurrentPerkClass.static.GetPrestigeIconPath(SpectatedKFPRI.GetActivePerkPrestigeLevel()));

			TempObject.SetObject("perkImageSource", PerkIconObject);

			SetObject("playerData", TempObject);
        }
    }

	
}

DefaultProperties
{
    LastPerkLevel=255
}
