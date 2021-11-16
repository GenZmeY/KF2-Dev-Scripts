//=============================================================================
// KFLocalMessage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFLocalMessage extends LocalMessage
	abstract;

var localized string SystemString;
var localized string AdminString;
var localized string LoggedInAsAdminString;
var localized string LoggedOutAsAdminString;
var localized string MustLoginToCheatString;
var localized string CheatsEnabledString;
var localized string ServerMaintenanceString;

var localized string OtherVoteInProgressString;

var localized string KickVoteStartedString;
var localized string KickVoteFailedString;
var localized string KickVoteSucceededString;
var localized string KickVoteRejectedString;
var localized string KickVoteInProgressString;
var localized string KickVoteDisabledString;

var localized string KickVoteYesReceivedString;
var localized string KickVoteNoReceivedString;

var localized string KickVoteKickAdminString;
var localized string KickVoteActiveTimeString;
var localized string KickVoteMatchNotStartedString;
var localized string KickVoteMaxKicksReachedString;
var localized string KickVoteNotEnoughPlayersString;
var localized string KickVoteNoSpectatorsString;

var localized string KickedFromServerString;
var localized string BannedFromServerString;
var localized string ServerNoLongerAvailableString;

var localized string SkipTraderVoteStartedString;
var localized string SkipTraderTimeString; 
var localized string SkipTraderSuccessString;
var localized string SkipTraiderVoteFailedString;
var localized string SkipTraderVoteNoSpectatorsString;
var localized string SkipTraderIsNotOpenString;
var localized string SkipTraderVoteInProgressString;
var localized string SkipTraderNoEnoughTimeString;
var localized string SkipTraderThisUserAlreadyStartedAVoteString;

var localized string SkipTraderVoteYesReceivedString;
var localized string SkipTraderVoteNoReceivedString;

var localized string PauseVoteStartedString;
var localized string PauseVoteInProgressString;
var localized string PauseVoteYesReceivedString;
var localized string PauseVoteNoReceivedString;
var localized string PauseVoteNoEnoughTimeString;
var localized string PauseVoteNoSpectatorsString;
var localized string PauseVoteTimeString;
var localized string PauseVoteSuccessString;
var localized string PauseVoteFailedString;
var localized string PauseVoteWaveActiveString;
var localized string PauseVoteWrongModeString;

var localized string ResumeVoteStartedString;
var localized string ResumeVoteInProgressString;
var localized string ResumeVoteYesReceivedString;
var localized string ResumeVoteNoReceivedString;
var localized string ResumeVoteNoEnoughTimeString;
var localized string ResumeVoteNoSpectatorsString;
var localized string ResumeVoteTimeString;
var localized string ResumeVoteSuccessString;
var localized string ResumeVoteFailedString;
var localized string ResumeVoteWaveActiveString;

enum ELocalMessageType
{
    LMT_AdminLogin,
    LMT_AdminLogout,
    LMT_MustLoginToCheat,
    LMT_CheatsEnabled,
	LMT_ServerMaintenance,
	LMT_OtherVoteInProgress,
    LMT_KickVoteStarted,
    LMT_KickVoteFailed,
    LMT_KickVoteSucceeded,
    LMT_KickVoteRejected,
    LMT_KickVoteInProgress,
    LMT_KickVoteDisabled,
    LMT_KickVoteYesReceived,
    LMT_KickVoteNoReceived,
    LMT_KickVoteAdmin,
    LMT_KickVoteActiveTime,
    LMT_KickVoteMatchNotStarted,
    LMT_KickVoteMaxKicksReached,
    LMT_KickVoteNotEnoughPlayers,
    LMT_KickVoteNoSpectators,
	LMT_SkipTraderVoteStarted,
	LMT_SkipTraderTime,
	LMT_SkipTraderTimeSuccess,
	LMT_SkipTraderVoteFailed,
	LMT_SkipTraderVoteNoSpectators,
	LMT_SkipTraderIsNotOpen,
	LMT_SkipTraderVoteInProgress,
    LMT_SkipTraderVoteYesReceived,
    LMT_SkipTraderVoteNoReceived,
	LMT_SkipTraderNoEnoughTime,
	LMT_SkipTraderThisUserAlreadyStartedAVote,
    LMT_PauseVoteStarted,
    LMT_PauseVoteInProgress,
    LMT_PauseVoteYesReceived,
    LMT_PauseVoteNoReceived,
    LMT_PauseVoteNoEnoughTime,
    LMT_PauseVoteNoSpectators,
    LMT_PauseVoteTime,
    LMT_PauseVoteSuccess,
    LMT_PauseVoteFailed,
    LMT_PauseVoteWaveActive,
    LMT_PauseVoteWrongMode,
    LMT_ResumeVoteStarted,
    LMT_ResumeVoteInProgress,
    LMT_ResumeVoteYesReceived,
    LMT_ResumeVoteNoReceived,
    LMT_ResumeVoteNoEnoughTime,
    LMT_ResumeVoteNoSpectators,
    LMT_ResumeVoteTime,
    LMT_ResumeVoteSuccess,
    LMT_ResumeVoteFailed,
    LMT_ResumeVoteWaveActive,
};

/** Message area on HUD (index into UTHUD.MessageOffset[]) */
var int MessageArea;

/** Used for ordering messages in announcement queue */
var int AnnouncementPriority;

/** Show PRI's HUD portrait when this message is played */
var bool bShowPortrait;

/** Volume multiplier for announcements */
var float AnnouncementVolume;

/** Delay before playing announcement */
var	float AnnouncementDelay;

// HEX COLOR CODES
//
//@comment
var const string SayColor;
//@comment
var const string TeamSayColor;
//@comment
var const string NonAffialiatedColor;
//@comment
var const string EventColor;
//@comment
var const string GameColor;
//@comment
var const string InteractionColor;
//@comment
var const string PriorityColor;
//@comment
var const string DefaultColor;
//@comment
var const string ConnectionColor;


static function string GetString(
    optional int Switch,
    optional bool bPRI1HUD,
    optional PlayerReplicationInfo RelatedPRI_1,
    optional PlayerReplicationInfo RelatedPRI_2,
    optional Object OptionalObject
    )
{
    local WorldInfo WI;
    local KFPlayerController KFPC;
    local string PlayerName;

    // Restore playername from cache if needed
    switch(Switch)
    {
        case LMT_KickVoteFailed:
        case LMT_KickVoteSucceeded:
        case LMT_KickVoteYesReceived:
        case LMT_KickVoteNoReceived:        
            if( RelatedPRI_1 != none )
            {
                PlayerName = RelatedPRI_1.PlayerName;
            }
            else
            {
                WI = class'WorldInfo'.static.GetWorldInfo();
                if( WI != none )
                {
                    KFPC = KFPlayerController(WI.GetALocalPlayerController());
                    if( KFPC != none && KFPC.MyGFxHUD != none )
                    {
                        PlayerName = KFPC.MyGFxHUD.PendingKickPlayerName;
                    }
                }
            }
            break;
    }

    switch (Switch)
    {
        case LMT_ResumeVoteStarted: 
            return RelatedPRI_1.PlayerName@Default.ResumeVoteStartedString; 

        case LMT_ResumeVoteInProgress:
            return default.ResumeVoteInProgressString;
        
        case LMT_ResumeVoteYesReceived:
            return default.ResumeVoteYesReceivedString;
        
        case LMT_ResumeVoteNoReceived:
            return default.ResumeVoteNoReceivedString;
        
        case LMT_ResumeVoteNoEnoughTime:
            return default.ResumeVoteNoEnoughTimeString; 

        case LMT_ResumeVoteNoSpectators:
            return default.ResumeVoteNoSpectatorsString;
        
        case LMT_ResumeVoteTime:
            return default.ResumeVoteTimeString;

        case LMT_ResumeVoteSuccess:
            return default.ResumeVoteSuccessString;
        
        case LMT_ResumeVoteFailed:
            return default.ResumeVoteFailedString;

        case LMT_ResumeVoteWaveActive:
            return default.ResumeVoteWaveActiveString;

        case LMT_PauseVoteStarted: 
            return RelatedPRI_1.PlayerName@Default.PauseVoteStartedString; 

        case LMT_PauseVoteInProgress:
            return default.PauseVoteInProgressString;
        
        case LMT_PauseVoteYesReceived:
            return default.PauseVoteYesReceivedString;
        
        case LMT_PauseVoteNoReceived:
            return default.PauseVoteNoReceivedString;
        
        case LMT_PauseVoteNoEnoughTime:
            return default.PauseVoteNoEnoughTimeString; 

        case LMT_PauseVoteNoSpectators:
            return default.PauseVoteNoSpectatorsString;
        
        case LMT_PauseVoteTime:
            return default.PauseVoteTimeString;

        case LMT_PauseVoteSuccess:
            return default.PauseVoteSuccessString;
        
        case LMT_PauseVoteFailed:
            return default.PauseVoteFailedString;

        case LMT_PauseVoteWaveActive:
            return default.PauseVoteWaveActiveString;

        case LMT_PauseVoteWrongMode:
            return default.PauseVoteWrongModeString;

		case LMT_OtherVoteInProgress:
			return default.OtherVoteInProgressString;

		case LMT_SkipTraderVoteStarted:
            return RelatedPRI_1.PlayerName@Default.SkipTraderVoteStartedString;

		case LMT_SkipTraderTimeSuccess:
			return default.SkipTraderSuccessString;

        case LMT_SkipTraderVoteFailed:
            return Default.SkipTraiderVoteFailedString;

		case LMT_SkipTraderTime:
			return default.SkipTraderTimeString;

        case LMT_SkipTraderVoteNoSpectators:
            return Default.SkipTraderVoteNoSpectatorsString;

        case LMT_SkipTraderIsNotOpen:
            return Default.SkipTraderIsNotOpenString;
			
        case LMT_SkipTraderVoteInProgress:
            return Default.SkipTraderVoteInProgressString;
			
        case LMT_SkipTraderVoteYesReceived:
            return Default.SkipTraderVoteYesReceivedString;
			
        case LMT_SkipTraderVoteNoReceived:
            return Default.SkipTraderVoteNoReceivedString;

		case LMT_SkipTraderNoEnoughTime:
            return Default.SkipTraderNoEnoughTimeString;

		case LMT_SkipTraderThisUserAlreadyStartedAVote:
            return Default.SkipTraderThisUserAlreadyStartedAVoteString;

        case LMT_AdminLogin:
            return RelatedPRI_1.PlayerName@Default.LoggedInAsAdminString;
            
        case LMT_AdminLogout:
            return RelatedPRI_1.PlayerName@Default.LoggedOutAsAdminString;
            
        case LMT_MustLoginToCheat:
            return Default.MustLoginToCheatString;
            
        case LMT_CheatsEnabled:
            return RelatedPRI_1.PlayerName@Default.CheatsEnabledString;

		case LMT_ServerMaintenance:
			return default.ServerMaintenanceString;
            
        case LMT_KickVoteStarted:
            // Cache player name locally, if player being voted leaves, inactive PRIs are not replicated
            // so we will lose access to the name
            WI = class'WorldInfo'.static.GetWorldInfo();
            if( WI != none )
            {
                KFPC = KFPlayerController(WI.GetALocalPlayerController());
                if( KFPC != none && KFPC.MyGFxHUD != none )
                {
                    KFPC.MyGFxHUD.PendingKickPlayerName = RelatedPRI_1.PlayerName;
                }
            }
            return Default.KickVoteStartedString@RelatedPRI_1.PlayerName;

        case LMT_KickVoteFailed:
            return Default.KickVoteFailedString@PlayerName;

        case LMT_KickVoteSucceeded:        
            return Default.KickVoteSucceededString@PlayerName;

        case LMT_KickVoteRejected:
            return Default.KickVoteRejectedString;

        case LMT_KickVoteInProgress:
            return default.KickVoteInProgressString;

        case LMT_KickVoteDisabled:
            return default.KickVoteDisabledString;

        case LMT_KickVoteYesReceived:
            return Default.KickVoteYesReceivedString@PlayerName;

        case LMT_KickVoteNoReceived:
            return Default.KickVoteNoReceivedString@PlayerName;

        case LMT_KickVoteAdmin:
            return Default.KickVoteKickAdminString;

        case LMT_KickVoteActiveTime:
            return Default.KickVoteActiveTimeString;

        case LMT_KickVoteMatchNotStarted:
            return Default.KickVoteMatchNotStartedString;

        case LMT_KickVoteMaxKicksReached:
            return Default.KickVoteMaxKicksReachedString;

        case LMT_KickVoteNotEnoughPlayers:
            return Default.KickVoteNotEnoughPlayersString;

        case LMT_KickVoteNoSpectators:
            return Default.KickVoteNoSpectatorsString;
    }   
    return "";
}

static function byte AnnouncementLevel(byte MessageIndex)
{
	return 1;
}

static function SoundNodeWave AnnouncementSound(int MessageIndex, Object OptionalObject, PlayerController PC)
{
	return SoundNodeWave(OptionalObject);
}

/**
 * Allow messages to remove themselves if they are superfluous because of newly added message
 */
//static function bool ShouldBeRemoved(KFQueuedAnnouncement MyAnnouncement, class<KFLocalMessage> NewAnnouncementClass, int NewMessageIndex)
//{
//	return false;
//}

static function float GetPos( int Switch, HUD myHUD )
{
    return 0.5;
//	return (KFHUD(myHUD) != None) ? KFHUD(myHUD).MessageOffset[Default.MessageArea] : 0.5;
}

static function bool KilledByVictoryMessage(int AnnouncementIndex)
{
	return (default.AnnouncementPriority < 6);
}

// Returns a hex color code for the supplied message type
static function string GetHexColor(int Switch)
{
    switch (Switch)
    {
        case LMT_AdminLogin:
        case LMT_AdminLogout:
		case LMT_ServerMaintenance:
		case LMT_SkipTraderTimeSuccess:
		case LMT_SkipTraderTime:
            return default.PriorityColor;
        case LMT_KickVoteRejected:
        case LMT_KickVoteSucceeded:
        case LMT_KickVoteFailed:
        case LMT_KickVoteStarted:
        case LMT_KickVoteInProgress:
        case LMT_KickVoteDisabled:
		
            return default.EventColor;
    }
    return default.DefaultColor;
}

// From WebAdminUtils.uc
static final function string getLocalized(coerce string data)
{
    local array<string> parts;
    if (!(Left(data, 9) ~= "<Strings:")) return data;
    data = Mid(data, 9, Len(data)-10);
    ParseStringIntoArray(data, parts, ".", true);
    if (parts.length >= 3)
    {
        return Localize(parts[1], parts[2], parts[0]);
    }
    return "";
}

defaultproperties
{
	MessageArea=1
	AnnouncementVolume=2.0

    SayColor = "FFFFFF";
    TeamSayColor = "00FFFF";
    NonAffialiatedColor = "000000";
    EventColor = "0099FF";
    GameColor = "00FF00";
    InteractionColor = "FF0000";
    PriorityColor = "FFFF00";
    DefaultColor = "FFFFFF";
    ConnectionColor = "8E1720";
}
