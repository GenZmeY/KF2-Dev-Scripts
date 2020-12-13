class KFGFxHUD_SpectatorInfo_Versus extends KFGFxHUD_SpectatorInfo;

function UpdatePlayerInfo(optional bool bForceUpdate)
{
	local GFxObject TempObject;
    local byte CurrentPerkLevel;

    if(SpectatedKFPRI == none)
    {
        return;
    }

    if(SpectatedKFPRI.GetTeamNum() != 255)
    {
        CurrentPerkLevel = SpectatedKFPRI.GetActivePerkLevel();

        if( ( LastPerkClass != SpectatedKFPRI.CurrentPerkClass ) || ( LastPerkLevel != CurrentPerkLevel ) || bForceUpdate )
        {
            LastPerkLevel = CurrentPerkLevel;
            LastPerkClass = SpectatedKFPRI.CurrentPerkClass;    
        }
    }
    else
    {
        LastPerkLevel = 255;
        LastPerkClass = None;
    }

	TempObject = CreateObject("Object");
    TempObject.SetString("playerName", SpectatedKFPRI.PlayerName);
    if(SpectatedKFPRI.GetTeamNum() == 255)
    {
    	TempObject.SetString("playerPerk", class'KFCommon_LocalizedStrings'.default.ZedString );
    	TempObject.SetString("iconPath", "img://"$PathName(class'KFGFxWidget_PartyInGame_Versus'.default.ZedIConTexture));
    }
    else
    {
    	TempObject.SetString("playerPerk", SpectatedKFPRI.CurrentPerkClass.default.LevelString @SpectatedKFPRI.GetActivePerkLevel() @SpectatedKFPRI.CurrentPerkClass.default.PerkName );
    	TempObject.SetString("iconPath", "img://" $SpectatedKFPRI.CurrentPerkClass.static.GetPerkIconPath());
    }
    
    SetObject("playerData", TempObject);
}