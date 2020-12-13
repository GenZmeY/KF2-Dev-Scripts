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
var bool bIsVoteActive;
var bool bIsSkipTraderVoteActive;
var bool bShowChoicesOnTimerUpdate;

var const string GBA_VoteYes;
var const string GBA_VoteNo;

var GFxObject KickVoteData;

function InitializeHUD()
{
    //LocalizeText();
}

function LocalizeText(bool bIsSkipTraderVote)
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

	if(bIsSkipTraderVote)
	{
		TempObject.SetString("voteKick", VoteSkipTraderString);
	}
	else
	{
		TempObject.SetString("voteKick", VoteKickString);
	}

    SetObject("localizedText", TempObject);
}

function ResetVote()
{
	bShowChoicesOnTimerUpdate = false;
	ActionScriptVoid("onYesReleased");
	ActionScriptVoid("onNoReleased");
}

function ShowVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices, bool bIsSkipTraderVote)
{
	if(PRI != none)
	{
		LocalizeText(bIsSkipTraderVote); //Added this here if the user changes their keybind, it will update
		bIsVoteActive = true;
		bIsSkipTraderVoteActive = bIsSkipTraderVote;
		SendVoteToAS3(PRI.PlayerName, VoteDuration, bShowChoices);
	}
	else
	{
		bIsVoteActive = false;
		bIsSkipTraderVoteActive = false;
	}
}

function SendVoteToAS3(string PlayerName, byte VoteDuration, bool bShowChoices)
{
	if(KickVoteData == None)
	{
		KickVoteData = CreateObject("Object");
	}

	if(bIsSkipTraderVoteActive)
	{
		KickVoteData.SetString("playerName", PlayerName@VoteSkipTraderDetailString);
	}
	else
	{
		KickVoteData.SetString("playerName", PlayerName);
	}
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
		LocalizeText(bIsSkipTraderVoteActive);
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

DefaultProperties
{
	//defaults
	GBA_VoteYes="GBA_VoteYes"
	GBA_VoteNo="GBA_VoteNo"
}