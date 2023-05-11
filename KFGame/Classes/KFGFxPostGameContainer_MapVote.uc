//=============================================================================
// KFGFxPostGameContainer_MapVote
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 05/19/2015
//=============================================================================

class KFGFxPostGameContainer_MapVote extends KFGFxObject_Container;

var localized string YourVoteString;
var localized string TopVotesString;
var string MapVoteString; //localized in parent and parent passes it to this class

// Maps to skip
const MapBiolapse = 'KF-Biolapse';
const MapNightmare = 'KF-Nightmare';
const MapPowerCore = 'KF-PowerCore_Holdout';
const MapDescent = 'KF-TheDescent';
const MapKrampus = 'KF-KrampusLair';
const MapSantas = 'KF-SantasWorkshop';
const MapSteam = 'KF-SteamFortress';
const MapElysium = 'KF-Elysium';

//==============================================================
// Initialization
//==============================================================
function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	LocalizeText();
	SetMapOptions();
}

function LocalizeText()
{
	local GFxObject TextObject;

	TextObject = CreateObject("Object");

	TextObject.SetString("yourVote", 	YourVoteString);
	TextObject.SetString("mapList", 	MapVoteString);
	TextObject.SetString("topVotes", 	TopVotesString);

	SetObject("localizedText", TextObject);
}

function SetMapOptions()
{
	local GFxObject MapList;
	local GFxObject MapObject;
	local int i, Counter;
	local array<string> ServerMapList;
	local KFGameReplicationInfo KFGRI;
	local bool IsWeeklyMode;
	local bool IsBrokenTrader;
	local bool IsBossRush;
	local bool IsGunGame;
	local bool IsContaminationMode;
	local bool bShouldSkipMaps;
	local name MapName;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	bShouldSkipMaps = false;
	Counter = 0;

	if(KFGRI != none && KFGRI.VoteCollector != none)
	{
		ServerMapList  = KFGRI.VoteCollector.MapList;
		IsWeeklyMode   = KFGRI.bIsWeeklyMode;
		IsBrokenTrader = KFGRI.CurrentWeeklyIndex == 11;
		IsBossRush     = KFGRI.CurrentWeeklyIndex == 14;
		IsGunGame      = KFGRI.CurrentWeeklyIndex == 16;
		IsContaminationMode = KFGRI.CurrentWeeklyIndex == 19;

		bShouldSkipMaps = IsWeeklyMode && (IsBrokenTrader || IsBossRush || IsGunGame);

		//gfx
		MapList = CreateArray();

		for (i = 0; i < ServerMapList.length; i++)
		{
			MapName = name(ServerMapList[i]);

			if ( bShouldSkipMaps && ( MapName == MapBiolapse || 
									  MapName == MapNightmare ||
									  MapName == MapPowerCore ||
									  MapName == MapDescent ||
									  MapName == MapKrampus))
			{
				continue;
			}

			if (IsWeeklyMode && IsContaminationMode)
			{
				if (MapName == MapBiolapse || 
					MapName == MapNightmare ||
					MapName == MapPowerCore ||
					MapName == MapDescent ||
					MapName == MapKrampus ||
					MapName == MapElysium ||
					MapName == MapSantas)
				{
					continue;
				}				
			}

			/* Temporary removal of SteamFrotress for BossRush */
			if (IsWeeklyMode && IsBossRush && MapName == MapSteam)
			{
				continue;
			}
			/* */

			MapObject = CreateObject("Object");
			MapObject.SetString("label", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(ServerMapList[i]) );
			MapObject.SetString("mapSource", GetMapSource(ServerMapList[i]) );
			MapObject.SetInt("mapindex", i);
			MapList.SetElementObject(Counter, MapObject);

			Counter++;
		}
	}

	SetObject("mapChoices", MapList);
}

function RecieveTopMaps(const out TopVotes VoteObject)
{
	//For array of objects based on the index pass for map at position.
	local GFxObject MapList;
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	if(KFGRI != none && KFGRI.VoteCollector != none)
	{
		//gfx
		MapList = CreateArray();
		if(VoteObject.Map1Name != "" && VoteObject.Map1Votes > 0)
		{
			MapList.SetElementObject(0, IndexToTopMapObject(VoteObject.Map1Name, VoteObject.Map1Votes));	
		}
		if(VoteObject.Map2Name != "" && VoteObject.Map2Votes > 0)
		{
			MapList.SetElementObject(1, IndexToTopMapObject(VoteObject.Map2Name, VoteObject.Map2Votes));	
		}
		if(VoteObject.Map3Name != "" && VoteObject.Map3Votes > 0)
		{
			MapList.SetElementObject(2, IndexToTopMapObject(VoteObject.Map3Name, VoteObject.Map3Votes));	
		}		
	}

	SetObject("currentVotes", MapList);
}

function GFxObject IndexToTopMapObject(string MapName, int VoteCount)
{
	local GFxObject MapObject;

	MapObject = CreateObject("Object");
	MapObject.SetString("label", class'KFCommon_LocalizedStrings'.static.GetFriendlyMapName(MapName) );
	MapObject.SetString("secondaryText", String(VoteCount));
	MapObject.SetString("mapSource", GetMapSource(MapName));
		
	return MapObject;
}

function string GetMapSource(string MapName)
{
	local KFMapSummary MapData;

	MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName(MapName);
	if ( MapData != none )
	{
		return "img://" $MapData.ScreenshotPathName;
    }
    else
    {    	
    	// Failed to find map image, use the default instead
    	MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName("KF-Default");
    	if ( MapData != none )
		{
			return "img://" $MapData.ScreenshotPathName;			
    	}
    }
}

DefaultProperties
{
}