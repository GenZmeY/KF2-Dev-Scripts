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
	local bool bShouldSkipMaps;
	local bool bWeeklyNoSanta;

	local bool IsBoom, IsCraniumCracker, IsTinyTerror, IsBobbleZed, IsPoundemonium, IsUpUpAndDecay, IsZedTime, IsBeefcake;
	local bool IsBloodThirst, IsColiseum, IsArachnophobia, IsScavenger, IsWW, IsAbandon, IsBossRush, IsShrunkenHeads;
	local bool IsGunGame, /*IsVIP,*/ IsPerkRoulette, IsContaminationMode, IsBountyHunt;

	local name MapName;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	bShouldSkipMaps = false;
	Counter = 0;

	if(KFGRI != none && KFGRI.VoteCollector != none)
	{
		ServerMapList  = KFGRI.VoteCollector.MapList;

		IsWeeklyMode   = KFGRI.bIsWeeklyMode;

		IsBoom = false;
		IsCraniumCracker = false;
		IsTinyTerror = false;
		IsBobbleZed = false;
		IsPoundemonium = false;
		IsUpUpAndDecay = false;
		IsZedTime = false;
		IsBeefcake = false;
		IsBloodThirst = false;
		IsColiseum = false;
		IsArachnophobia = false;
		IsScavenger = false;
		IsWW = false;
		IsAbandon = false;
		IsBossRush = false;
		IsShrunkenHeads = false;
		IsGunGame = false;
		//IsVIP = false;
		IsPerkRoulette = false;
		IsContaminationMode = false;
		IsBountyHunt = false;

		switch (KFGRI.CurrentWeeklyIndex)
		{
			case 0:	IsBoom = true;	break;
			case 1: IsCraniumCracker = true; break;
			case 2: IsTinyTerror = true; break;
			case 3: IsBobbleZed = true; break;
			case 4: IsPoundemonium = true; break;
			case 5: IsUpUpAndDecay = true; break;
			case 6: IsZedTime = true; break;
			case 7: IsBeefcake = true; break;
			case 8: IsBloodThirst = true; break;
			case 9: IsColiseum = true; break;
			case 10: IsArachnophobia = true; break;
			case 11: IsScavenger = true; break;
			case 12: IsWW = true; break;
			case 13: IsAbandon = true; break;
			case 14: IsBossRush = true; break;
			case 15: IsShrunkenHeads = true; break;
			case 16: IsGunGame = true; break;
			//case 17: IsVIP = true; break;
			case 18: IsPerkRoulette = true; break;
			case 19: IsContaminationMode = true; break;
			case 20: IsBountyHunt = true; break;
		}

		bShouldSkipMaps = IsWeeklyMode && (IsScavenger || IsBossRush || IsGunGame);

		bWeeklyNoSanta = IsWeeklyMode && (	IsBoom || IsCraniumCracker || IsTinyTerror || IsBobbleZed
											|| IsPoundemonium || IsUpUpAndDecay || IsZedTime || IsBeefcake
											|| IsBloodThirst || IsColiseum || IsArachnophobia || IsScavenger
											|| IsWW || IsAbandon || IsShrunkenHeads || IsPerkRoulette);

		//gfx
		MapList = CreateArray();

		for (i = 0; i < ServerMapList.length; i++)
		{
			MapName = name(ServerMapList[i]);

			if (bWeeklyNoSanta && MapName == MapSantas)
			{
				continue;
			}

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

			if (IsWeeklyMode && IsBountyHunt)
			{
				if (MapName == MapBiolapse || 
					MapName == MapNightmare ||
					MapName == MapPowerCore ||
					MapName == MapDescent ||
					MapName == MapKrampus ||
					MapName == MapElysium ||
					MapName == MapSteam)
				{
					continue;
				}				
			}			

			if (IsWeeklyMode && IsBossRush && MapName == MapSteam)
			{
				continue;
			}

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