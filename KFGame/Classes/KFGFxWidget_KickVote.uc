//=============================================================================
// KFGFxWidget_KickVote
//=============================================================================
// HUD Widget that displays when a kick vote has started
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 07/07/2014
//=============================================================================

class KFGFxWidget_KickVote extends GFxObject;

var localized string VoteKickString;
var localized string VoteSkipTraderString;
var localized string VoteSkipTraderDetailString;
var localized string VotePauseGameString;
var localized string VotePauseGameDetailString;
var localized string VoteResumeGameString;
var localized string VoteResumeGameDetailString;
var bool bIsVoteActive;
var bool bShowChoicesOnTimerUpdate;

var const string GBA_VoteYes;
var const string GBA_VoteNo;

var GFxObject KickVoteData;

enum EVoteType
{
	VT_NONE,
    VT_KICK,
    VT_SKIP_TRADER,
    VT_PAUSE_GAME,
	VT_RESUME_GAME
};

var EVoteType CurrentActiveVote;

function InitializeHUD()
{
    //LocalizeText();
}

function LocalizeText(EVoteType Type)
{
	local GFxObject TempObject;
	local KFPlayerInput KFInput;
	local KeyBind TempKeyBind;

	TempObject = CreateObject("Object");

	KFInput =  KFPlayerInput(GetPC().PlayerInput);

	KFInput.GetKeyBindFromCommand(TempKeyBind, GBA_VoteYes);
	TempObject.SetString("yesKey", String(TempKeyBind.Name));

	KFInput.GetKeyBindFromCommand(TempKeyBind, GBA_VoteNo);
	TempObject.SetString("noKey", String(TempKeyBind.Name));

    TempObject.SetString("yes", Class'KFCommon_LocalizedStrings'.default.YesString);
    TempObject.SetString("no", Class'KFCommon_LocalizedStrings'.default.NoString);

	TempObject.SetString("voteKick", GetVoteString(Type));

    SetObject("localizedText", TempObject);
}

function ResetVote()
{
	bShowChoicesOnTimerUpdate = false;
	ActionScriptVoid("onYesReleased");
	ActionScriptVoid("onNoReleased");
}

function ShowVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices, EVoteType Type)
{
	if(PRI != none)
	{
		LocalizeText(Type); //Added this here if the user changes their keybind, it will update
		bIsVoteActive = true;

		CurrentActiveVote = Type;
		SendVoteToAS3(PRI.PlayerName, VoteDuration, bShowChoices);
	}
	else
	{
		bIsVoteActive = false;
		CurrentActiveVote = VT_NONE;
	}
}

function SendVoteToAS3(string PlayerName, byte VoteDuration, bool bShowChoices)
{
	if(KickVoteData == None)
	{
		KickVoteData = CreateObject("Object");
	}

	KickVoteData.SetString("playerName", GetVotePlayerDataString(PlayerName, CurrentActiveVote));
	KickVoteData.SetInt("voteDuration", VoteDuration);
	KickVoteData.SetBool("bShowChoices", bShowChoices);
	bShowChoicesOnTimerUpdate = bShowChoices;

	SetObject("kickVoteData", kickVoteData);
	UpdateUsingGamepad(GetPC().PlayerInput.bUsingGamepad);  // Moved call to here as the initialize seemed to be too early to show controller controls in some cases (orbis mainly) - HSL
}

function UpdateVoteDuration(byte VoteDuration)
{
	if(kickVoteData != None)
	{
		KickVoteData.SetInt("voteDuration", VoteDuration);
		KickVoteData.SetBool("bShowChoices", bShowChoicesOnTimerUpdate);
		SetObject("kickVoteData", kickVoteData);
		UpdateUsingGamepad(GetPC().PlayerInput.bUsingGamepad);
	}
}

function UpdateUsingGamepad(bool bIsUsingGamepad)
{
    SetBool("bUsingGamepad", bIsUsingGamepad);
    if(!bIsUsingGamepad)
	{
		//the gamepad text will show on the input so we need to change it back to keyboard, it is simpler to just relocalize 
		LocalizeText(CurrentActiveVote);
	}
}

function UpdateVoteCount(byte YesVotes, byte NoVotes)
{
	ActionScriptVoid("updateKickVoteCount");
}

function VoteClosed()
{
	bIsVoteActive = false;
	SetVisible(false);
}

function OnYesPressed()
{
	if(bIsVoteActive)
	{
		ActionScriptVoid("onYesPressed");
	}
}

function OnYesReleased()
{
	if(bIsVoteActive)
	{
		ActionScriptVoid("onYesReleased");
	}
}

function OnNoPressed()
{
	if(bIsVoteActive)
	{
		ActionScriptVoid("onNoPressed");
	}
}

function OnNoReleased()
{
	if(bIsVoteActive)
	{
		ActionScriptVoid("onNoReleased");
	}
}

function string GetVoteString(EVoteType Type)
{
	switch(Type)
	{
		case VT_KICK:                           return VoteKickString;
		case VT_SKIP_TRADER:                    return VoteSkipTraderString;
		case VT_PAUSE_GAME:                     return VotePauseGameString;
		case VT_RESUME_GAME:				    return VoteResumeGameString;
		case VT_NONE: `Log("None vote type");   return VoteKickString;
		default:      `Log("Unkown vote type"); return VoteKickString;
	}
}

function string GetVotePlayerDataString(string PlayerName, EVoteType Type)
{
	switch(Type)
	{
		case VT_SKIP_TRADER:                    return PlayerName@VoteSkipTraderDetailString;
		case VT_PAUSE_GAME:                     return PlayerName@VotePauseGameDetailString;
		case VT_RESUME_GAME:				    return PlayerName@VoteResumeGameDetailString;
		case VT_KICK:                           return PlayerName;
		case VT_NONE: `Log("None vote type");   return PlayerName;
		default:      `Log("Unkown vote type"); return PlayerName;
	}
}

DefaultProperties
{
	//defaults
	GBA_VoteYes="GBA_VoteYes"
	GBA_VoteNo="GBA_VoteNo"
	CurrentActiveVote=VT_NONE
}