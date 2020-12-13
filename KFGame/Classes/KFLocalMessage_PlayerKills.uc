//=============================================================================
// KFLocalMessage_Game
//=============================================================================
// Message class for general gam play messages
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFLocalMessage_PlayerKills extends KFLocalMessage;

var localized string KilledString;
var localized string ZedString;

enum EKillMessageType
{
	KMT_PlayerKillPlayer,
	KMT_PLayerKillZed,
	KMT_AIKillPlayer,
};

// Returns a hex color code for the supplied message type
static function string GetHexColor(int Switch)
{
    switch ( Switch )
	{
		case KMT_PlayerKillPlayer:
			return default.PriorityColor;
		case KMT_PLayerKillZed:
             return default.GameColor;
	}

	return "00FF00";
}

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{

	switch ( Switch )
	{
		case KMT_PlayerKillZed:
			return	"+" $Localize("Zeds", String(OptionalObject.Name), "KFGame");
		default:
			return "";
	}
}

static function string ResolveTeamName(PlayerReplicationInfo PRI)
{
	if(PRI.GetTeamNum() == 255)
	{
		return "("$default.ZedString$")";
	}
	return "";
}

DefaultProperties
{
}

