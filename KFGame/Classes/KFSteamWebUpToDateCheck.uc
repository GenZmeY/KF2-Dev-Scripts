//=============================================================================
// KFSteamWebUpToDateCheck
//=============================================================================
// Makes a call to the Steam Web API to check the current version of the game server or client
//=============================================================================
// Copyright (C) 2015 Tripwire Interactive LLC
// - Joshua "Josh" Rowan
// All Rights Reserved.
//=============================================================================

class KFSteamWebUpToDateCheck extends KFSteamWebAPICall
	config(Game)
	native;

/** configurable steam app id */
var const int APIAppID;

event SendUpToDateCheck()
{
	CallWebProcedure(APICall, "appid="$APIAppID$"&version="$class'KFGameEngine'.static.GetKFGameVersion());
}

function ProcessResponse(JsonObject response)
{
	local JsonObject ResponseList;
	local bool bUpToDate;

	ResponseList = response.GetObject("response");
	if ( ResponseList == none )
	{
		`log(Name @ "got invalid JSON response.", bDebug);
		return;
	}
	if (!ResponseList.HasKey("up_to_date"))
	{
		`log(Name @ "got unexpected JSON response.", bDebug);
		return;
	}

	bUpToDate = ResponseList.GetBoolValue("up_to_date");
	if (!bUpToDate)
	{
		`warn("Server is out of date, need version" @ ResponseList.GetIntValue("required_version"));
		class'KFGameInfo'.static.StaticSetNeedsRestart();
	}

	`log(Name @ "response="$int(bUpToDate), bDebug);
}

defaultproperties
{
	APICall="/ISteamApps/UpToDateCheck/v1/"
	APIAppID=232130
}
