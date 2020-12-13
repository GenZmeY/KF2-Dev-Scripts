//=============================================================================
// KFLocalMessage_Priority
//=============================================================================
// Killing Floor 2
//
// Base class for important message that renders to the center of the player's HUD
//
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFLocalMessage_Priority extends KFLocalMessage;

var localized string			WaveStartMessage;
var localized string			WaveEndMessage;
var localized string            GetToTraderMessage;
var localized string            ScavengeMessage;
var localized string            YouLostMessage;
var localized string            YouWonMessage;
var localized string            SquadWipedOutMessage;
var localized string            SquadSurvivedMessage;
var localized string            ObjectiveStartMessage;
var localized string            ObjectiveWonMessage;
var localized string            ObjectiveLostMessage;
var localized string            ObjectiveEndedMessage;
var localized string            ObjNotEnoughPlayersMessage;
var localized string            ObjTimeRanOutMessage;
var localized string            HumansLoseMessage;
var localized string            HumansWinMessage;
var localized string			AttackHumanPlayersString;
var localized string			ZedGroupRegroupingString;
var localized string 			NextRoundBeginString;
var localized string 			PlayerCanChangePerksString;
var localized string 			ZedWaitingForNextRoundString;
var localized string 			LastPlayerStandingString;

struct SDelayedPriorityMessage
{
	var string InPrimaryMessageString;
	var string InSecondaryMessageString;
	var int LifeTime;
	var byte MessageType;
};

enum EGameMessageType
{
	GMT_WaveStart,
	GMT_WaveEnd,
	GMT_MatchWon,
	GMT_MatchLost,
	GMT_ObjectiveStart,
	GMT_ObjectiveWon,
	GMT_ObjectiveLost,
	GMT_ObjEndPlayerNeeded,
	GMT_ObjEndTimeLimit,
	GMT_LevelUp,
	GMT_TierUnlocked,
	GMT_Died,
	GMT_ZedsWin,
	GMT_HumansWin,
	GMT_AttackHumanPlayers,
	GMT_NextRoundBegin,
	GMT_LastPlayerStanding,
	GMT_WaveStartWeekly,
	GMT_WaveStartSpecial,
	GMT_WaveSBoss,
	GMT_Null,
};

static function ClientReceive(
	PlayerController P,
	optional int Switch,
	optional PlayerReplicationInfo RelatedPRI_1,
	optional PlayerReplicationInfo RelatedPRI_2,
	optional Object OptionalObject
	)
{
	local string MessageString,SecondaryMessageString;
	local KFGFxMoviePlayer_HUD myGfxHUD;
	local KFGameReplicationInfo KFGRI;
	local TeamInfo TeamInfo;
	local byte TeamIndex;
	local KFPlayerController KFPC;
	KFPC = KFPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

	TeamIndex = P.PlayerReplicationInfo.GetTeamNum();
	if( OptionalObject != none )
	{
		TeamInfo = TeamInfo( OptionalObject );
		if( TeamInfo != none )
		{
			TeamIndex = TeamInfo.TeamIndex;
		}
	}

	MessageString = static.GetMessageString( Switch, SecondaryMessageString, TeamIndex );
	if ( MessageString != "" && KFGFxHudWrapper(p.myHUD) != none && ShouldShowPriortyMessage(P, Switch))
	{
	    myGfxHUD = KFGFxHudWrapper(p.myHUD).HudMovie;
		if ( myGfxHUD != None  )
		{
            myGfxHUD.DisplayPriorityMessage(MessageString,SecondaryMessageString,static.GetMessageLifeTime(Switch), EGameMessageType(Switch));
		}
		else if(KFPC.MyGFxManager != none) //store it off so we can queue it
		{
			if (KFPC.MyGFxManager != none)
			{
				//queue the message
				KFPC.MyGFxManager.QueueDelayedPriorityMessage(MessageString, SecondaryMessageString, static.GetMessageLifeTime(Switch), EGameMessageType(Switch));
				//return;
			}
		}
	}

	switch( Switch )
	{
		case GMT_WaveStart:
		case GMT_WaveStartWeekly:
		case GMT_WaveStartSpecial:
		case GMT_WaveSBoss:
			if(!P.PlayerReplicationInfo.bOnlySpectator && P.PlayerReplicationInfo.bReadyToPlay)
			{
				if(KFPC != none && KFPC.LEDEffectsManager != none)
				{
					KFPC.LEDEffectsManager.PlayEffectWaveIncoming();
				}
				CloseMenus();
			}
			class'KFMusicStingerHelper'.static.PlayWaveStartStinger( P, Switch );
			break;
		case GMT_WaveEnd:
			class'KFMusicStingerHelper'.static.PlayWaveCompletedStinger( P );
			break;

		case GMT_MatchWon:
			KFGRI = KFGameReplicationInfo(P.WorldInfo.GRI);
			if(KFGRI != none)
			{
				KFGRI.bMatchVictory = true;
			}
			if(!P.PlayerReplicationInfo.bOnlySpectator && P.PlayerReplicationInfo.GetTeamNum() == 255)
			{
				class'KFMusicStingerHelper'.static.PlayMatchLostStinger( P );
			}
			else
			{
				class'KFMusicStingerHelper'.static.PlayMatchWonStinger( P );
			}
			if(KFPC != none && KFPC.LEDEffectsManager != none)
			{
				KFPC.LEDEffectsManager.PlayEffectShowMatchOutcome(P.PlayerReplicationInfo.GetTeamNum() != 255);
			}
			break;

		case GMT_MatchLost:
			if(!P.PlayerReplicationInfo.bOnlySpectator && P.PlayerReplicationInfo.GetTeamNum() == 255)
			{
				class'KFMusicStingerHelper'.static.PlayMatchWonStinger( P );
			}
			else
			{
				class'KFMusicStingerHelper'.static.PlayMatchLostStinger( P );
			}
			if(KFPC != none && KFPC.LEDEffectsManager != none)
			{
				KFPC.LEDEffectsManager.PlayEffectShowMatchOutcome(P.PlayerReplicationInfo.GetTeamNum() == 255);
			}
			break;

		case GMT_HumansWin:
			KFGRI = KFGameReplicationInfo(P.WorldInfo.GRI);
			if(KFGRI != none)
			{
				KFGRI.bMatchVictory = true;
			}
			if(P.PlayerReplicationInfo.GetTeamNum() == 255)
			{
				class'KFMusicStingerHelper'.static.PlayRoundLostStinger( P );
			}
			else
			{
				class'KFMusicStingerHelper'.static.PlayRoundWonStinger( P );
			}
			if(KFPC != none && KFPC.LEDEffectsManager != none)
			{
				KFPC.LEDEffectsManager.PlayEffectShowMatchOutcome(P.PlayerReplicationInfo.GetTeamNum() != 255);
			}
			break;

		case GMT_ZedsWin:
			if(P.PlayerReplicationInfo.GetTeamNum() == 255)
			{
				class'KFMusicStingerHelper'.static.PlayRoundWonStinger( P );
			}
			else
			{
				class'KFMusicStingerHelper'.static.PlayRoundLostStinger( P );
			}
			if(KFPC != none && KFPC.LEDEffectsManager != none)
			{
				KFPC.LEDEffectsManager.PlayEffectShowMatchOutcome(P.PlayerReplicationInfo.GetTeamNum() == 255);
			}
			break;

		// make sure only local player
		case GMT_LevelUp:
			class'KFMusicStingerHelper'.static.PlayLevelUpStinger( P );
			break;

		// make sure only local player
		case GMT_TierUnlocked:
			class'KFMusicStingerHelper'.static.PlayTierUnlockedStinger( P );
			break;

		case GMT_ObjectiveWon:
			class'KFMusicStingerHelper'.static.PlayObjectiveWonStinger( P );
			break;

		case GMT_ObjectiveLost:
			class'KFMusicStingerHelper'.static.PlayObjectiveLostStinger( P );
			break;

		// make sure only local player
		case GMT_Died:
			class'KFMusicStingerHelper'.static.PlayPlayerDiedStinger( P );
			break;
		case GMT_LastPlayerStanding:
			//@TODO: Mark, do we have a stinger or dialog for this?
			break;
	};
}

static function string GetMessageString(int Switch, optional out String SecondaryString, optional byte TeamIndex)
{
	SecondaryString = "";

	switch ( Switch )
	{
		case GMT_HumansWin:
			SecondaryString = default.HumansWinMessage;
			if(TeamIndex == 255)
			{
				return default.YouLostMessage;
			}
			else
			{
				return default.YouWonMessage;
			}

		case GMT_ZedsWin:
			SecondaryString = default.HumansLoseMessage;
			if(TeamIndex == 255)
			{
				return default.YouWonMessage;
			}
			else
			{
				return default.YouLostMessage;
			}
		case GMT_WaveStart:
		case GMT_WaveStartWeekly:
		case GMT_WaveStartSpecial:
		case GMT_WaveSBoss:
			return default.WaveStartMessage;
		case GMT_WaveEnd:
		    if(TeamIndex == 255)
			{
				return default.ZedGroupRegroupingString;
			}
			else
			{
				SecondaryString = KFGameReplicationInfo(class'WorldInfo'.static.GetWorldInfo().GRI).bTradersEnabled ? default.GetToTraderMessage : default.ScavengeMessage;
				return default.WaveEndMessage;
			}
		case GMT_MatchWon:
			if(class'WorldInfo'.static.GetWorldInfo().NetMode != NM_Standalone)
			{
				SecondaryString = default.SquadSurvivedMessage;
			}

			return default.YouWonMessage;
		case GMT_MatchLost:
			if(class'WorldInfo'.static.GetWorldInfo().NetMode != NM_Standalone)
			{
				SecondaryString = default.SquadWipedOutMessage;
			}

			return default.YouLostMessage;
		case GMT_ObjectiveStart:
			return default.ObjectiveStartMessage;
		case GMT_ObjectiveWon:
			return default.ObjectiveWonMessage;
		case GMT_ObjectiveLost:
			return default.ObjectiveLostMessage;
		case GMT_ObjEndPlayerNeeded:
			SecondaryString = default.ObjNotEnoughPlayersMessage;
			return default.ObjectiveEndedMessage;
		case GMT_ObjEndTimeLimit:
			SecondaryString = default.ObjTimeRanOutMessage;
			return default.ObjectiveLostMessage;
		case GMT_LevelUp:
			SecondaryString =""; //TODO: Remove this hard coded test message when we add the pop up in. ZG
			return "";
		case GMT_TierUnlocked:
			SecondaryString =""; //TODO: Remove this hard coded test message when we add the pop up in. ZG
			return "";
		case GMT_AttackHumanPlayers:
			return default.AttackHumanPlayersString;
		case GMT_NextRoundBegin:
			if( TeamIndex == 255 )
			{
				SecondaryString = default.ZedWaitingForNextRoundString;
			}
			else
			{
				SecondaryString = default.PlayerCanChangePerksString;
				//open perk menu
				OpenPerkMenu();
			}
			return default.NextRoundBeginString;
		case GMT_LastPlayerStanding:
			return default.LastPlayerStandingString;
		default:
			return "";
	}
}

static function bool ShouldShowPriortyMessage(PlayerController P, int Switch)
{
	local PlayerController PC;

	if (switch == GMT_ObjectiveLost || switch == GMT_ObjectiveWon)
	{
		return false;
	}

	if(Switch == GMT_LastPlayerStanding)
	{
		PC = class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController();

		if(PC != none && (PC.Pawn != none && PC.Pawn.Health > 0) )
		{
			return false;
		}
	}

	return true;
}

static function CloseMenus()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

	if(KFPC != none && KFPC.MyGfxManager != none)
	{
		if(KFPC.MyGfxManager.bMenusOpen)
		{
			KFPC.MyGfxManager.CloseMenus(true);
		}
	}
}

static function OpenPerkMenu()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(class'WorldInfo'.static.GetWorldInfo().GetALocalPlayerController());

	if(KFPC != none && KFPC.MyGfxManager != none)
	{
		KFPC.MyGfxManager.OpenMenu(UI_Perks, true);
	}
}

static function float GetMessageLifeTime(int Switch)
{
	switch ( Switch )
	{
		case GMT_WaveStart:
		case GMT_WaveStartWeekly:
		case GMT_WaveStartSpecial:
		case GMT_WaveSBoss:
	 	     return 5.f;
	    case GMT_WaveEnd:
	 		 return 4.f;
	 	case GMT_ObjectiveStart:
	 	case GMT_ObjectiveWon:
	 	case GMT_ObjectiveLost:
	 		return 3.f;
 		case GMT_LevelUp:
 		case GMT_TierUnlocked:
 		return 0.01f;
	 	case GMT_MatchWon:
		case GMT_MatchLost:
			return 0.f;
		case GMT_AttackHumanPlayers:
			return 2.f;
		case GMT_NextRoundBegin:
			return 5.f;
		case GMT_LastPlayerStanding:
			return 1.5f;
	}

    return default.LifeTime;
}

DefaultProperties
{
}