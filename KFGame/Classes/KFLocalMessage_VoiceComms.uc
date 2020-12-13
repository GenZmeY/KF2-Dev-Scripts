//=============================================================================
// KFLocalMessage_VoiceComms
//=============================================================================
// Message class for world interaction messages
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFLocalMessage_VoiceComms extends KFLocalMessage;

enum EVoiceCommsType
{
	VCT_REQUEST_HEALING,
	VCT_REQUEST_DOSH,
	VCT_REQUEST_HELP,
	VCT_TAUNT_ZEDS,
	VCT_FOLLOW_ME,
	VCT_GET_TO_THE_TRADER,
	VCT_AFFIRMATIVE,
	VCT_NEGATIVE,
	VCT_EMOTE,
	VCT_THANK_YOU,
	VCT_NONE,
	VCT_MAX,
};

var localized array<string> VoiceCommsOptionStrings;
var array<Texture2D> VoiceCommsIcons;

static function string GetString(
	optional int Switch,
	optional bool bPRI1HUD,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	if(Switch < default.VoiceCommsOptionStrings.length)
	{
		KFPlayerReplicationInfo(RelatedPRI_1).SetCurrentVoiceCommsRequest(Switch);
		return RelatedPRI_1.PlayerName $":"  @default.VoiceCommsOptionStrings[Switch];
	}
}

// Returns a hex color code for the supplied message type
static function string GetHexColor(int Switch)
{
    return default.DefaultColor;
}

DefaultProperties
{
	//defaults
	VoiceCommsIcons(VCT_REQUEST_HEALING)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Heal'
	VoiceCommsIcons(VCT_REQUEST_DOSH)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Dosh'
	VoiceCommsIcons(VCT_REQUEST_HELP)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Help'
	VoiceCommsIcons(VCT_TAUNT_ZEDS)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Taunt'
	VoiceCommsIcons(VCT_FOLLOW_ME)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Follow'
	VoiceCommsIcons(VCT_GET_TO_THE_TRADER)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Trader'
	VoiceCommsIcons(VCT_AFFIRMATIVE)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Affirmative'
	VoiceCommsIcons(VCT_NEGATIVE)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Negative'
	VoiceCommsIcons(VCT_EMOTE)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Emote'
	VoiceCommsIcons(VCT_THANK_YOU)=Texture2D'UI_VoiceComms_TEX.UI_VoiceCommand_Icon_ThankYou'
}
