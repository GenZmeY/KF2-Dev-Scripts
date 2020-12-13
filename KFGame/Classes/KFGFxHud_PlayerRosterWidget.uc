class KFGFxHud_PlayerRosterWidget extends GFxObject;

struct SZedPlayerInfo
{
    var string AvatarPath;
    var int PlayerID;  

    StructDefaultProperties
    {
        PLayerID=-1
    }
};

var array<SZedPlayerInfo> ZedPlayerInfoList;

var PlayerReplicationInfo MyPRI;

function InitializeHUD()
{
	MyPRI = GetPC().PlayerReplicationInfo;
}

function TickHud(float DeltaTime)
{
	UpdatePlayerData();
}

function UpdatePlayerData()
{
	local GFxObject DataProvider,TempData;
	local int i, PlayerIndex;
    local KFPlayerReplicationinfo KFPRI;
    local KFPlayerController KFPC;
    

    local KFGameReplicationInfo KFGRI;
    local array<KFPlayerReplicationinfo> CurrentPlayerList;
    local string AvatarIconPath;
    local SZedPlayerInfo ZedPlayerInfo;
    local int SearchIndex;

    KFGRI = KFGameReplicationInfo(GetPC().Worldinfo.GRI);

    if(KFGRI == none)
    {
        return;
    }

    if(MyPRI == none)
    {
    	return;
    }

    PlayerIndex = 0;


    KFGRI.GetKFPRIArray(CurrentPlayerList);

    KFPC = KFPlayerController(GetPC());

    DataProvider = CreateArray();
	for(i = 0 ; i < CurrentPlayerList.length; i ++)
    {
    	if(CurrentPlayerList[i].GetTeamNum() == MyPRI.GetTeamNum() && MyPRI != CurrentPlayerList[i])
    	{
    		KFPRI = CurrentPlayerList[i];
            SearchIndex = ZedPlayerInfoList.Find('PlayerID', KFPRI.PlayerID);
	        TempData  = CreateObject("Object");
            
            if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Orbis ) )
            {
                if(SearchIndex == INDEX_NONE)
                {
                    AvatarIconPath = "img://"$KFPC.GetPS4Avatar(KFPRI.PlayerName);
                    ZedPlayerInfo.PlayerID = KFPRI.PlayerID;
                    ZedPlayerInfo.AvatarPath = AvatarIconPath;
                    ZedPlayerInfoList.AddItem(ZedPlayerInfo);
                }
                else
                {
                    AvatarIconPath = ZedPlayerInfoList[SearchIndex].AvatarPath;   
                }
            }
            else
            {    
                if(SearchIndex == INDEX_NONE)
                {
                    AvatarIconPath = "img://"$KFPC.GetSteamAvatar(KFPRI.UniqueId);
                    ZedPlayerInfo.PlayerID = KFPRI.PlayerID;
                    ZedPlayerInfo.AvatarPath = AvatarIconPath;
                    ZedPlayerInfoList.AddItem(ZedPlayerInfo);
                }
                else
                {
                    AvatarIconPath = ZedPlayerInfoList[SearchIndex].AvatarPath;      
                }
            }	

            TempData.SetString("playerIcon",  AvatarIconPath);	

            if(KFPRI.CharPortrait != none)
            {
                TempData.SetString("zedIcon",  "img://"$PathName(KFPRI.CharPortrait));
            }

	        TempData.SetFloat("health", ByteToFloat(KFPRI.PlayerHealthPercent) * 100);  
	        DataProvider.SetElementObject(PlayerIndex,TempData);
	        PlayerIndex++;
    	}
        
    }
    
    SetObject("data", DataProvider);
}

DefaultProperties
{
    
}