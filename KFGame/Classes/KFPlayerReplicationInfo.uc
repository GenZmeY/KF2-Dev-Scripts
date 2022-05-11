//=============================================================================
// KFPlayerReplicationInfo
//=============================================================================
// A PlayerReplicationInfo is created for every player on a server (or in a standalone game).
// Players are PlayerControllers, or other Controllers with bIsPlayer=true
// PlayerReplicationInfos are replicated to all clients, and contain network game relevant information about the player,
// such as playername, score, etc.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFPlayerReplicationInfo extends PlayerReplicationInfo
	config(Game)
	native(ReplicationInfo)
	nativereplication
	dependson(KFVoteCollector, KFLocalMessage_VoiceComms);

`include(KFGame\KFGameAnalytics.uci);
`include(KFGame\KFMatchStats.uci);
`include(KFProfileSettings.uci);

/** The time at which this PRI left the game */
var float LastQuitTime;
/** The number of times this PRI has reconnected to this game */
var byte NumTimesReconnected;

/** TRUE if this player has spawned in for the active round. This is used for realtime multipay on PS4 */
var bool bHasSpawnedIn;

/** UTC timestamp representing the last time a crate was gifted to this player. Tracked by server only */
var string LastCrateGiftTimestamp;
/** Seconds of gameplay for this player for crate gifting. Tracked by server only */
var int SecondsOfGameplay;

/** Whether or not dosh can be earned */
var bool bAllowDoshEarning;

/************************************
 *  Character class related variables
 ************************************/

/** This variable exists to tell native our max number of attachments */
const NUM_COSMETIC_ATTACHMENTS = `MAX_COSMETIC_ATTACHMENTS;

/** List of all playable characters */
var const array<KFCharacterInfo_Human> CharacterArchetypes;

/** Replication info for player character customization */
struct native CustomizationInfo
{
	/** Index of the current char archetype among the AvailableCharArchetypes array */
	var const int CharacterIndex;
	var const int HeadMeshIndex;
	var const int HeadSkinIndex;
	var const int BodyMeshIndex;
	var const int BodySkinIndex;
	var const int AttachmentMeshIndices[`MAX_COSMETIC_ATTACHMENTS];
	var const int AttachmentSkinIndices[`MAX_COSMETIC_ATTACHMENTS];

	structcpptext
	{
		FCustomizationInfo& operator=(FCustomizationInfo& rhs)
		{
			CharacterIndex = rhs.CharacterIndex;
			HeadMeshIndex = rhs.HeadMeshIndex;
			HeadSkinIndex = rhs.HeadSkinIndex;
			BodyMeshIndex = rhs.BodyMeshIndex;
			BodySkinIndex = rhs.BodySkinIndex;
			for(INT i = 0; i < UCONST_NUM_COSMETIC_ATTACHMENTS /*MAX_COSMETIC_ATTACHMENTS*/; ++i)
			{
				AttachmentMeshIndices[i] = rhs.AttachmentMeshIndices[i];
				AttachmentSkinIndices[i] = rhs.AttachmentSkinIndices[i];
			}

			return *this;
		}
	}

	structdefaultproperties
	{
		// Index of `CLEARED_ATTACHMENT_INDEX implies don't use any attachment
		// Note: Array size should match MAX_COSMETIC_ATTACHMENTS
		AttachmentMeshIndices[0]=`CLEARED_ATTACHMENT_INDEX
		AttachmentMeshIndices[1]=`CLEARED_ATTACHMENT_INDEX
		AttachmentMeshIndices[2]=`CLEARED_ATTACHMENT_INDEX
	}
};

/** Current customization settings */
var const repnotify CustomizationInfo RepCustomizationInfo;

/** Texture of render of custom character head. */
var	texture		CharPortrait;

/** 0 is Not Talking, 1 is Public, 2 is Team, 3 is Squad, 4 is Vehicle, 5 is Spectator, 6 is Sequestered Spectator */
var	repnotify byte	VOIPStatus;

/** TRUE if player has registered as a local talker with the OSS */
var repnotify bool bVOIPRegisteredWithOSS;

/** The cumulative amount of damage this player has dealt, resets on team change */
var int DamageDealtOnTeam;

/************************************
 *  Replicated Perk Data
 ************************************/
/** Selected perk info replicated to all */
var  	byte			NetPerkIndex; // @todo: replace with class?
var  			Class<KFPerk>	CurrentPerkClass;
var private 	byte	ActivePerkLevel;
var private 	byte	ActivePerkPrestigeLevel;
/** Kill assists. Need an integer here because it is very easy to exceed 255 assists. */
var 			int 			Assists;
var 	byte			PlayerHealth; //represented as a percentage
var 	byte			PlayerHealthPercent; //represented as a percentage
/** The firebug range skill increases the range of fire weapons we need to tell other clients if it is on */
var 			bool 			bExtraFireRange;
/** The firebug splash damage skill changes the explosion template */
var 			bool 			bSplashActive;
/** The demo Nuke skill changes the explosion template */
var 			bool 			bNukeActive;
/** The demo Concussive skill changes the explosion template */
var 			bool 			bConcussiveActive;
/** Certain perks can supply ammo etc. We need to replicate that for the HUD */
var 			byte 			PerkSupplyLevel;
/** Number of stomps during Arachnophobia */
var             int             ZedStomps;

/************************************
 *  Not replicated Perk Data,
 *  local client only
 ************************************/
var 			bool 			bPerkPrimarySupplyUsed;
var 			bool 			bPerkSecondarySupplyUsed;

var bool bVotedToSkipTraderTime;
var	bool bAlreadyStartedASkipTraderVote;

var bool bVotedToPauseGame;
var bool bAlreadyStartedAPauseGameVote;

/************************************
 *  Not replicated Voice Comms Request
 *  local client only -ZG
 ************************************/

var 			EVoiceCommsType CurrentVoiceCommsRequest;
var				float 			VoiceCommsStatusDisplayInterval;
var				int 			VoiceCommsStatusDisplayIntervalCount;
var				int 			VoiceCommsStatusDisplayIntervalMax;

/************************************
 *  Replicated Unlocks
 ************************************/
var private int		SharedUnlocks;

var repnotify private int CurrentHeadShotEffectID;
/************************************
 *  Objective
 ************************************/
 var		bool		bObjectivePlayer;

/************************************
 * Replicated, compressed locations of human players
 ************************************/
var private	Vector 		PawnLocationCompressed;
var private	Vector 		LastReplicatedSmoothedLocation;
var 		bool 		bShowNonRelevantPlayers;

/** Cached (non-replicated) player owner, used by server */
var KFPlayerController KFPlayerOwner;

/** Whether we're waiting for our online subsystem inventory to load (used to determine selectable characters) */
var transient bool bWaitingForInventory;
/** What character should be checked for selection once the online subsystem inventory loads */
var transient int WaitingForInventoryCharacterIndex;

/** Whether the character is currently holding a transport objective */
var bool bCarryingCollectible;

/************************************
*  native
************************************/
cpptext
{
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	UBOOL ShowNonRelevantPlayerInfo();

	/** Inventory */
	UBOOL DelayCharacterOwnership();

	void LoadCosmeticContent(UKFCharacterInfo_Human* CharArch, INT CosmeticType, INT CosmeticIdx);
	void CacheCosmeticContent(UKFCharacterInfo_Human* CharArch, INT CosmeticType, INT CosmeticIdx);

	void CacheHeadshotFxContent();

	virtual void AddReferencedObjects(TArray<UObject*>& ObjectArray);
}

native function bool StartLoadCosmeticContent(KFCharacterInfo_Human CharArch, INT CosmeticType, INT CosmeticIdx);
native function StartLoadHeadshotFxContent();
native function SetWeeklyCharacterAttachment(INT AttachmentIndex, int AttachmentSkin);

replication
{
	if ( bNetDirty )
		RepCustomizationInfo, NetPerkIndex, ActivePerkLevel, ActivePerkPrestigeLevel, bHasSpawnedIn,
		CurrentPerkClass, bObjectivePlayer, Assists, PlayerHealth, PlayerHealthPercent,
		bExtraFireRange, bSplashActive, bNukeActive, bConcussiveActive, PerkSupplyLevel,
		CharPortrait, DamageDealtOnTeam, bVOIPRegisteredWithOSS, CurrentVoiceCommsRequest,CurrentHeadShotEffectID, bCarryingCollectible, ZedStomps;

  	// sent to non owning clients
 	if ( bNetDirty && (!bNetOwner || bDemoRecording) )
 		VOIPStatus, SharedUnlocks;

 	if( !bNetOwner && bNetDirty )
		PawnLocationCompressed;
}

simulated event ReplicatedEvent(name VarName)
{
	local KFPlayerController LocalPC;
	local PlayerNameIdPair newPlayer;

	if ( VarName == 'RepCustomizationInfo' )
	{
		CharacterCustomizationChanged();
	}
	else if ( VarName == nameof(VOIPStatus) )
	{
		VOIPStatusChanged(self, VOIPStatus > 0);
	}
	else if ( VarName == nameof(Score) )
	{
		UpdateTraderDosh();
	}
	else if ( VarName == 'PlayerName' )
	{
		LocalPC = KFPlayerController(GetALocalPlayerController());
		if( LocalPC != none )
		{
			newPlayer.PlayerName = PlayerName;
			LocalPC.RecentlyMetPlayers.AddItem(newPlayer);

			// Refresh the party widget when the name changes
			if( LocalPC.MyGFxManager != none )
			{
				LocalPC.MyGFxManager.ForceUpdateNextFrame();
			}
		}
	}
	else if (VarName == 'bVOIPRegisteredWithOSS')
	{
		OnTalkerRegistered();
	}
	else if (VarName == nameof(CurrentHeadShotEffectID))
	{
		CurrentHeadShotEffectIdChanged();
	}


	if ( VarName == 'Team' )
	{
		ClientRecieveNewTeam();
	}

	Super.ReplicatedEvent(VarName);
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if( Role == ROLE_Authority )
	{
		KFPlayerOwner = KFPlayerController( Owner );
		ResetSkipTrader();
	}
}

/*********************************************************************************************
`*Team management
*********************************************************************************************/
reliable server function ServerSwitchTeam();
reliable client function ClientRecieveNewTeam();

/*********************************************************************************************
`* Current Perk Level
********************************************************************************************* */

simulated function byte GetActivePerkLevel()
{
	return ActivePerkLevel;
}

simulated function byte GetActivePerkPrestigeLevel()
{
	return ActivePerkPrestigeLevel;
}

/*********************************************************************************************
`* VOIP
********************************************************************************************* */


reliable server function ServerNotifyStartVoip()
{
	local int i;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	//ClearTimer('ClearVOIP');

	if ( !KFGameInfo(WorldInfo.Game).bDisableVOIP && !KFGameInfo(WorldInfo.Game).bDisablePublicVOIPChannel )
	{
		if ( !bOnlySpectator )
		{
			bNetDirty = true;
			bForceNetUpdate = true;

			if(!KFPC.IsLocalController())
			{
				VOIPStatusChanged(self, true);
			}
            VOIPStatus = 1;

			KFPC.VoiceReceivers.Remove(0, KFPC.VoiceReceivers.Length);

			if ( KFPC.Pawn != none && KFPC.Pawn.Health > 0 )
			{
				for ( i = 0; i < WorldInfo.GRI.PRIArray.Length; i++ )
				{
					if ( !WorldInfo.GRI.PRIArray[i].bBot )
					{
						KFPC.VoiceReceivers.AddItem(WorldInfo.GRI.PRIArray[i].UniqueId);

						if ( PlayerController(WorldInfo.GRI.PRIArray[i].Owner) != none )
						{
							PlayerController(WorldInfo.GRI.PRIArray[i].Owner).VoiceSenders.AddItem(UniqueId);
						}
					}
				}
			}
			else if ( KFGameInfo(WorldInfo.Game).bEnableDeadToVOIP )
			{
				for ( i = 0; i < WorldInfo.GRI.PRIArray.Length; i++ )
				{
					if ( !WorldInfo.GRI.PRIArray[i].bBot )
					{
						KFPC.VoiceReceivers.AddItem(WorldInfo.GRI.PRIArray[i].UniqueId);

						if ( PlayerController(WorldInfo.GRI.PRIArray[i].Owner) != none )
						{
							PlayerController(WorldInfo.GRI.PRIArray[i].Owner).VoiceSenders.AddItem(UniqueId);
						}
					}
				}
			}

			if ( KFPC.VoiceReceivers.Length <= 0 )
			{
				KFPC.VoiceReceivers.AddItem(UniqueId);
			}
		}
		else
		{
			ServerStartSpectatorVoiceChat();
		}
	}
	else
	{
		KFPC.VoiceReceivers.Remove(0, KFPC.VoiceReceivers.Length);
		KFPC.VoiceReceivers.AddItem(UniqueId);
	}
}

reliable server function ServerNotifyStartTeamVoip()
{
	local byte TeamIndex;
	local int i;
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	//ClearTimer('ClearVOIP');

	if ( !KFGameInfo(WorldInfo.Game).bDisableVoip )
	{
		TeamIndex = GetTeamNum();

		if ( !bOnlySpectator )
		{
			bNetDirty = true;
			bForceNetUpdate = true;

			if(!KFPC.IsLocalController())
			{
				VOIPStatusChanged(self, true);
			}

            VOIPStatus = 2;

			KFPC.VoiceReceivers.Remove(0, KFPC.VoiceReceivers.Length);

			if ( KFPC.Pawn != none && KFPC.Pawn.Health > 0 )
			{
				for ( i = 0; i < WorldInfo.GRI.PRIArray.Length; i++ )
				{
					if ( !WorldInfo.GRI.PRIArray[i].bBot && (WorldInfo.GRI.PRIArray[i].GetTeamNum() == TeamIndex || !WorldInfo.GRI.bMatchHasBegun || WorldInfo.GRI.bMatchIsOver) )
					{
						KFPC.VoiceReceivers.AddItem(WorldInfo.GRI.PRIArray[i].UniqueId);

						if ( PlayerController(WorldInfo.GRI.PRIArray[i].Owner) != none )
						{
							PlayerController(WorldInfo.GRI.PRIArray[i].Owner).VoiceSenders.AddItem(UniqueId);
						}
					}
				}
			}
			else if ( KFGameInfo(WorldInfo.Game).bEnableDeadToVOIP )
			{
				for ( i = 0; i < WorldInfo.GRI.PRIArray.Length; i++ )
				{
					if ( !WorldInfo.GRI.PRIArray[i].bBot &&
						 (WorldInfo.GRI.PRIArray[i].GetTeamNum() == TeamIndex || !WorldInfo.GRI.bMatchHasBegun || WorldInfo.GRI.bMatchIsOver) )
					{
						KFPC.VoiceReceivers.AddItem(WorldInfo.GRI.PRIArray[i].UniqueId);

						if ( PlayerController(WorldInfo.GRI.PRIArray[i].Owner) != none )
						{
							PlayerController(WorldInfo.GRI.PRIArray[i].Owner).VoiceSenders.AddItem(UniqueId);
						}
					}
				}
			}

			if ( KFPC.VoiceReceivers.Length <= 0 )
			{
				KFPC.VoiceReceivers.AddItem(UniqueId);
			}
		}
		else
		{
			ServerStartSpectatorVoiceChat();
		}
	}
	else
	{
		KFPC.VoiceReceivers.Remove(0, KFPC.VoiceReceivers.Length);
		KFPC.VoiceReceivers.AddItem(UniqueId);
	}
}


function ServerStartSpectatorVoiceChat()
{
	local int i;

	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	ClearTimer('ClearVOIP');

	KFPC.VoiceReceivers.Remove(0, KFPC.VoiceReceivers.Length);

	VOIPStatus =KFGameInfo(WorldInfo.Game).bPartitionSpectators ?  6 : 5;

	for ( i = 0; i < WorldInfo.GRI.PRIArray.Length; ++i )
	{
		if ( !WorldInfo.GRI.PRIArray[i].bBot &&
			(!KFGameInfo(WorldInfo.Game).bPartitionSpectators || WorldInfo.GRI.PRIArray[i].bOnlySpectator) )
		{
			KFPC.VoiceReceivers.AddItem(WorldInfo.GRI.PRIArray[i].UniqueId);

			if ( PlayerController(WorldInfo.GRI.PRIArray[i].Owner) != none )
			{
				PlayerController(WorldInfo.GRI.PRIArray[i].Owner).VoiceSenders.AddItem(UniqueId);
			}
		}
	}

	if ( KFPC.VoiceReceivers.Length <= 0 )
	{
		KFPC.VoiceReceivers.AddItem(UniqueId);
	}
}

reliable server function ServerNotifyStopVOIP()
{
	local KFPlayerController KFPC;

	VOIPStatus = 0;
	VOIPStatusChanged(self, false);

	KFPC = KFPlayerController(Owner);

	if( KFPC != none )
	{
	KFPC.VoiceReceivers.Remove(0, KFPC.VoiceReceivers.Length);
	}

	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		while ( KFPC.VoiceSenders.Find('Uid', UniqueId.Uid) != INDEX_NONE )
		{
			KFPC.VoiceSenders.RemoveItem(UniqueId);
		}
	}
}


simulated function VOIPStatusChanged( PlayerReplicationInfo Talker, bool bIsTalking )
{
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo TalkerKFPRI;
	local KFGFxHudWrapper MyGFxHUD;
	local OnlineSubsystem OSS;

	OSS = class'GameEngine'.static.GetOnlineSubsystem();

    foreach WorldInfo.LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		// BWJ - 10-4-16 - Exit out immediately if local player has a chat restriction
		if( OSS != None && OSS.HasChatRestriction( LocalPlayer(KFPC.Player).ControllerId ) )
		{
			return;
		}

		MyGFxHUD = KFGFxHudWrapper(KFPC.myHUD);

		TalkerKFPRI = KFPlayerReplicationInfo(Talker);
		if( TalkerKFPRI != none )
		{
			if( TalkerKFPRI.VOIPStatus == 6 && !KFPC.PlayerReplicationInfo.bOnlySpectator )
			{
				return;
			}
		}

		if(MyGFxHUD != none && MyGFxHUD.HudMovie != none)
		{
			MyGFxHUD.HudMovie.VOIPWidget.VOIPEventTriggered(Talker, bIsTalking);
		}

		if(KFPC.MyGFxManager != none)
		{
			KFPC.MyGFxManager.UpdateVOIP(Talker, bIsTalking);
		}
	}
}


simulated function OnTalkerRegistered()
{
	local PlayerController LocalPC;
	local int i;
	local KFPlayerReplicationInfo PRI;
	local OnlineSubsystem OnlineSub;

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	LocalPC = GetALocalPlayerController();

	// If there is no PRI for the local player or GRI, we wait (really shouldn't be more than a frame) and try again
	if( LocalPC.PlayerReplicationInfo == None || WorldInfo.GRI == None )
	{
		SetTimer( 0.1, false, nameof(OnTalkerRegistered) );
	}

	if (LocalPC != none && LocalPC.PlayerReplicationInfo != none && WorldInfo.GRI != none)
	{
		// Local player has regigistered
		if (LocalPC.PlayerReplicationInfo == self)
		{
			// Register all other players that have been registered
			for (i = 0; i < WorldInfo.GRI.PRIArray.Length; i++)
			{
				PRI = KFPlayerReplicationInfo(WorldInfo.GRI.PRIArray[i]);
				if (PRI != self && PRI.bVOIPRegisteredWithOSS)
				{
					OnlineSub.VoiceInterface.RegisterRemoteTalker(PRI.UniqueId);
				}
			}
		}
		// Registering someone else other than the local player
		else if (KFPlayerReplicationInfo(LocalPC.PlayerReplicationInfo).bVOIPRegisteredWithOSS)
		{
			OnlineSub.VoiceInterface.RegisterRemoteTalker(UniqueId);
		}
	}
}


// JRO - Make sure the talking icon doesn't continue to show up after leaving
simulated function UnregisterPlayerFromSession()
{
	VOIPStatusChanged(self, false);
	super.UnregisterPlayerFromSession();
}

/*********************************************************************************************
`* Kick Voting
********************************************************************************************* */

reliable client function ShowKickVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.ShowKickVote(PRI, VoteDuration, bShowChoices);
	}

	if(KFPC != none && KFPC.MyGFxManager != none && bShowChoices)
	{
		KFPC.MyGFxManager.ShowKickVote(PRI);
	}
}

reliable client function HideKickVote()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.HideKickVote();
	}

	if(KFPC != none && KFPC.MyGFxManager != none)
	{
		KFPC.MyGFxManager.HideKickVote();
	}
}

reliable server function ServerStartKickVote(PlayerReplicationInfo Kickee, PlayerReplicationInfo Kicker)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none)
	{
		KFGRI.ServerStartVoteKick(Kickee, Kicker);
	}
}

simulated function CastKickVote(PlayerReplicationInfo PRI, bool bKick)
{
	local KFPlayerController KFPC;

	ServerCastKickVote(self, bKick);

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxManager != none)
	{
		KFPC.MyGFxManager.HideKickVote();
	}
}

reliable server function ServerCastKickVote(PlayerReplicationInfo PRI, bool bKick)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none)
	{
		KFGRI.RecieveVoteKick(PRI, bKick);
	}
}

/*********************************************************************************************
`* Skip Trader
********************************************************************************************* */

reliable client function ShowSkipTraderVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.ShowSkipTraderVote(PRI, VoteDuration, bShowChoices);
	}

	if(KFPC != none && KFPC.MyGFxManager != none && bShowChoices)
	{
		KFPC.MyGFxManager.ShowSkipTraderVote(PRI);
	}
}

reliable client function UpdateSkipTraderTime(byte CurrentVoteTime)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.UpdateSkipTraderTime(CurrentVoteTime);
	}
}

reliable client function HideSkipTraderVote()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.HideSkipTraderVote();
	}

	if(KFPC != none && KFPC.MyGFxManager != none)
	{
		KFPC.MyGFxManager.HideSkipTraderVote();
	}
}

simulated function RequestSkiptTrader(PlayerReplicationInfo PRI)
{
	bVotedToSkipTraderTime = true;
	ServerRequestSkipTraderVote(self);
}

reliable server function ServerRequestSkipTraderVote(PlayerReplicationInfo PRI)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if (KFGRI != none)
	{
		KFGRI.ServerStartVoteSkipTrader(PRI);
	}
}

simulated function CastSkipTraderVote(PlayerReplicationInfo PRI, bool bSkipTrader)
{
	local KFPlayerController KFPC;

	ServerCastSkipTraderVote(self, bSkipTrader);

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxManager != none)
	{
		KFPC.MyGFxManager.HideSkipTraderVote();
	}
}

reliable server function ServerCastSkipTraderVote(PlayerReplicationInfo PRI, bool bSkipTrader)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none)
	{
		KFGRI.RecieveVoteSkipTrader(PRI, bSkipTrader);
	}
}

reliable server function ResetSkipTrader()
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none && KFGRI.VoteCollector != none)
	{
		KFGRI.VoteCollector.ConcludeVoteSkipTrader();
	}
}

/*********************************************************************************************
`* Map Vote
********************************************************************************************* */

simulated function CastMapVote(int MapIndex, bool bDoubleClick)
{
	local KFGameInfo KFGI;

	ServerCastMapVote(self, KFGameReplicationInfo(WorldInfo.GRI).VoteCollector.MapList[MapIndex]);

	if(WorldInfo.NetMode == NM_StandAlone)
	{
		KFGI = KFGameInfo(WorldInfo.Game);
		if(KFGI != none)
		{
			//do insta map travel because we are impatient
			KFGI.UpdateCurrentMapVoteTime( bDoubleClick ? 0 : 5 );//insta ish
		}
	}
}

reliable server function ServerCastMapVote(PlayerReplicationInfo PRI, string MapName)
{
	local KFGameReplicationInfo kfGRI;
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGI != none && KFGI.bDisableMapVote)
	{
		return;
	}

	if(KFGRI != none && !bOnlySpectator)
	{
		if(WorldInfo.NetMode == NM_StandAlone)
		{
			KFGRI.ReceiveVoteMap(PRI, KFGameReplicationInfo(WorldInfo.GRI).VoteCollector.MapList.Find(MapName));
		}
		else
		{
			KFGRI.ReceiveVoteMap(PRI, KFGI.GameMapCycles[KFGI.ActiveMapCycle].Maps.Find(MapName));
		}
	}
}

reliable client function RecieveAARMapOption(string MapOption)
{
	local KFGameReplicationInfo kfGRI;
	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none && KFGRI.VoteCollector != none)
	{
		KFGRI.VoteCollector.AddMapOption(MapOption);
	}
}

reliable client function RecieveTopMaps(TopVotes VoteObject)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxManager != none && KFPC.MyGFxManager.PostGameMenu != none)
	{
		KFPC.MyGFxManager.PostGameMenu.RecieveTopMaps( VoteObject );
	}
}

/*********************************************************************************************
`* Pause Game
********************************************************************************************* */

reliable client function ShowPauseGameVote(PlayerReplicationInfo PRI, byte VoteDuration, bool bShowChoices)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.ShowPauseGameVote(PRI, VoteDuration, bShowChoices);
	}

	if(KFPC != none && KFPC.MyGFxManager != none && bShowChoices)
	{
		KFPC.MyGFxManager.ShowPauseGameVote(PRI);
	}
}

reliable client function UpdatePauseGameTime(byte CurrentVoteTime)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.UpdatePauseGameTime(CurrentVoteTime);
	}
}

reliable client function HidePauseGameVote()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxHUD != none)
	{
		KFPC.MyGFxHUD.HidePauseGameVote();
	}

	if(KFPC != none && KFPC.MyGFxManager != none)
	{
		KFPC.MyGFxManager.HidePauseGameVote();
	}
}

simulated function RequestPauseGame(PlayerReplicationInfo PRI)
{
	bVotedToPauseGame = true;
	ServerRequestPauseGameVote(self);
}

reliable server function ServerRequestPauseGameVote(PlayerReplicationInfo PRI)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if (KFGRI != none)
	{
		KFGRI.ServerStartVotePauseGame(PRI);
	}
}

simulated function CastPauseGameVote(PlayerReplicationInfo PRI, bool bSkipTrader)
{
	local KFPlayerController KFPC;

	ServerCastPauseGameVote(self, bSkipTrader);

	KFPC = KFPlayerController(Owner);

	if(KFPC != none && KFPC.MyGFxManager != none)
	{
		KFPC.MyGFxManager.HidePauseGameVote();
	}
}

reliable server function ServerCastPauseGameVote(PlayerReplicationInfo PRI, bool bSkipTrader)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none)
	{
		KFGRI.ReceiveVotePauseGame(PRI, bSkipTrader);
	}
}

reliable server function ResetPauseGame()
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if(KFGRI != none && KFGRI.VoteCollector != none)
	{
		KFGRI.VoteCollector.ConcludeVotePauseGame();
	}
	bVotedToPauseGame = false;
}

/*********************************************************************************************
`* Character Customization
********************************************************************************************* */

native reliable server private event ServerSetSharedUnlocks(int NewUnlocks);

native reliable server private event ServerSetCharacterCustomization(CustomizationInfo NewMeshInfo);

native reliable server private event ServerSetCurrentHeadShotEffect(int ItemID);

simulated final function int GetHeadShotEffectID()
{
	return CurrentHeadShotEffectID;
}

native private function bool SaveCharacterConfig();
native private function bool LoadCharacterConfig(out int CharacterIndex);
native private function RetryCharacterOwnership();
native function ClearCharacterAttachment(int AttachmentIndex);

simulated function ClientInitialize(Controller C)
{
	local OnlineContentInterface OnlineContentInt;

	// workaround for repeated repnotify!?!?
	if ( Role < ROLE_Authority && C == Owner )
	{
		return;
	}

	// Ignore the super since NotifyLocalPlayerTeamReceived is never used
	SetOwner( C );

	if ( C.IsLocalController() )
	{
		KFPlayerController(C).InitializeStats();
		SelectCharacter();

		// checked for owned titles that might unlock shared content (e.g. Road Redemption)
		if (class'WorldInfo'.static.IsConsoleBuild())
		{
			OnlineContentInt = class'GameEngine'.static.GetOnlineSubsystem().ContentInterface;
			OnlineContentInt.ClearCrossTitleContentList(0, OCT_Game);
			OnlineContentInt.AddReadCrossTitleContentCompleteDelegate(
				0, OCT_Game, SharedContentInitChain_CrossTitleContentRead);
			if (!OnlineContentInt.ReadCrossTitleContentList(0, OCT_Game))
			{
				SharedContentInitChain_CrossTitleContentRead(true);
			}
		}
		else
		{
			SharedContentInitChain_CrossTitleContentRead(true);
		}
	}
}

simulated function SharedContentInitChain_CrossTitleContentRead(bool bWasSuccessful)
{
	if (class'WorldInfo'.static.IsConsoleBuild())
	{
		class'GameEngine'.static.GetOnlineSubsystem().ContentInterface.
			ClearReadCrossTitleContentCompleteDelegate(0, OCT_Game, SharedContentInitChain_CrossTitleContentRead);

		if (class'GameEngine'.static.GetOnlineSubsystem().CurrentInventory.Length == 0)
		{
			class'GameEngine'.static.GetPlayfabInterface().
				AddInventoryReadCompleteDelegate(SharedContentInitChain_InventoryRead_Playfab);
		}
		else
		{
			SharedContentInitChain_InventoryRead_Playfab(true);
		}
	}
	else
	{
		if (class'GameEngine'.static.GetOnlineSubsystem().bInventoryReady == false)
		{
			class'GameEngine'.static.GetOnlineSubsystem().
				AddOnInventoryReadCompleteDelegate(SharedContentInitChain_InventoryRead_Steamworks);
		}
		else
		{
			SharedContentInitChain_InventoryRead_Steamworks();
		}
	}
}

simulated function SharedContentInitChain_InventoryRead_Steamworks()
{
	class'GameEngine'.static.GetOnlineSubsystem().
		ClearOnInventoryReadCompleteDelegate(SharedContentInitChain_InventoryRead_Steamworks);

	// At this point, inventory should both be available
	class'KFUnlockManager'.static.InitSharedUnlocksFor(self);
}

simulated function SharedContentInitChain_InventoryRead_Playfab(bool bWasSuccessful)
{
	local array<OnlineCrossTitleContent> CrossTitleContent;

	class'GameEngine'.static.GetPlayfabInterface().
		ClearInventoryReadCompleteDelegate(SharedContentInitChain_InventoryRead_Playfab);

	// At this point, cross title content and inventory should both be available
	class'GameEngine'.static.GetOnlineSubsystem().
		ContentInterface.GetCrossTitleContentList(0, OCT_Game, CrossTitleContent);
	class'KFUnlockManager'.static.InitSharedUnlocksFor(self, CrossTitleContent);
}

function OnInventoryReadComplete_Steamworks()
{
	class'GameEngine'.static.GetOnlineSubsystem().ClearOnInventoryReadCompleteDelegate(OnInventoryReadComplete_Steamworks);
	bWaitingForInventory = false;
	SelectCharacter(WaitingForInventoryCharacterIndex);
}

function OnInventoryReadComplete_Playfab(bool bWasSuccessful)
{
	if(bWasSuccessful)
	{
		// select character requires the inventory be set up, so keep this callback around until the inventory read is successful
		class'GameEngine'.static.GetPlayfabInterface().ClearInventoryReadCompleteDelegate(OnInventoryReadComplete_Playfab);
		bWaitingForInventory = false;
		SelectCharacter(WaitingForInventoryCharacterIndex);
	}
}

/**
 * Network: Local Player
 * INDEX_NONE will load last character from config
 */
simulated event SelectCharacter( optional int CharIndex=INDEX_None, optional bool bWaitForInventory=FALSE )
{
	local OnlineProfileSettings Settings;

	// If settings are not loaded yet try again later via OnReadProfileSettingsComplete()
	Settings = class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetProfileSettings( LocalPlayer(GetALocalPlayerController().Player).ControllerId );
	if( Settings == none )
	{
		`log("Not selecting character just yet since there's no profile settings");
		return;
	}

	// We need to wait for the online subsystem inventory to be loaded in order to determine whether
	// the requested character is available to select. If the inventory isn't ready, wait for it and
	// handle selection after the callback.
	// @TODO JDR: should this actually ignore additional calls to SelectCharacter while waiting for inventory?
	if (bWaitForInventory)
	{
		if (bWaitingForInventory)
		{
			return;
		}
		else
		{
			//@SABER_EGS IsEosBuild() case added
			if (class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild())
			{
				if (class'GameEngine'.static.GetOnlineSubsystem().CurrentInventory.Length == 0)
				{
					class'GameEngine'.static.GetPlayfabInterface().AddInventoryReadCompleteDelegate(OnInventoryReadComplete_Playfab);
					WaitingForInventoryCharacterIndex = CharIndex;
					bWaitingForInventory = true;
					return;
				}
			}
			else if (!class'GameEngine'.static.GetOnlineSubsystem().bInventoryReady)
			{
				class'GameEngine'.static.GetOnlineSubsystem().AddOnInventoryReadCompleteDelegate(OnInventoryReadComplete_Steamworks);
				WaitingForInventoryCharacterIndex = CharIndex;
				bWaitingForInventory = true;
				return;
			}
		}
	}

	LoadCharacterConfig(CharIndex);

	// Make sure we get a valid character
	if(!class'KFUnlockManager'.static.GetAvailable(CharacterArchetypes[CharIndex]))
	{
		CharIndex = GetAnyAvailableCharacter(CharIndex);
		LoadCharacterConfig(CharIndex);
	}

	// Resave, in case of invalid selection, and then replicate
	Settings.SetProfileSettingValueInt(KFID_StoredCharIndex, CharIndex);
	if ( Role < Role_Authority )
    {
		ServerSetCharacterCustomization( RepCustomizationInfo );
	}
	else
	{
		CharacterCustomizationChanged();
	}
}

/** Returns the first available unlocked character */
private simulated function int GetAnyAvailableCharacter(byte CharIndex)
{
	local byte i;

	for (i = 0; i < CharacterArchetypes.Length; i++)
	{
		if(class'KFUnlockManager'.static.GetAvailable(CharacterArchetypes[CharIndex]))
		{
			return i;
		}
	}

	return 0;
}

/** Config section name for a given character archetype index */
private simulated event string GetCharacterConfigSection(int Idx)
{
	return PathName(CharacterArchetypes[Idx]);
}

/** Called when RepCustomizationInfo is modified. Network: All*/
simulated event CharacterCustomizationChanged()
{
	local KFPawn_Human KFP;
	local KFCharacterInfoBase NewCharArch;

	`AnalyticsLog(("character_change", self, CharacterArchetypes[RepCustomizationInfo.CharacterIndex].Name));

	foreach WorldInfo.AllPawns(class'KFPawn_Human', KFP)
	{
		if (KFP.PlayerReplicationInfo == self ||
			(KFP.DrivenVehicle != None && KFP.DrivenVehicle.PlayerReplicationInfo == self))
		{
			NewCharArch = CharacterArchetypes[RepCustomizationInfo.CharacterIndex];

			if( NewCharArch != KFP.CharacterArch )
			{
				// selected a new character
				KFP.SetCharacterArch( NewCharArch );
			}
			else if( WorldInfo.NetMode != NM_DedicatedServer )
			{
				// refresh cosmetics only
   				KFP.CharacterArch.SetCharacterMeshFromArch( KFP, self );
			}
		}
	}
}

reliable server private event ServerAnnounceNewSharedContent()
{
	if( WorldInfo.GRI != None && WorldInfo.GRI.bMatchHasBegun )
	{
		BroadcastLocalizedMessage( class'KFLocalMessage_Game', GMT_UserSharingContent, self);
	}
}

simulated event CurrentHeadShotEffectIdChanged()
{
	StartLoadHeadshotFxContent();
}

/*********************************************************************************************
* General
********************************************************************************************* */

function PlayerReplicationInfo Duplicate()
{
	local KFPlayerReplicationInfo NewKFPRI;

	NewKFPRI = KFPlayerReplicationInfo(super.Duplicate());
	NewKFPRI.LastQuitTime = LastQuitTime;
	NewKFPRI.NumTimesReconnected = NumTimesReconnected;
	return NewKFPRI;
}

function OverrideWith(PlayerReplicationInfo PRI)
{
	super.OverrideWith(PRI);

	// while super sets Team, SetPlayerTeam sets other important stuff, too
	SetPlayerTeam(Team);
}

function SetPlayerTeam( TeamInfo NewTeam )
{
	if( NewTeam != Team )
	{
		DamageDealtOnTeam = 0;
	}

	super.SetPlayerTeam( NewTeam );

	KFPlayerOwner = KFPlayerController( Owner );

	SetTimer( 1.f, true, nameOf(UpdateReplicatedVariables) );
}

function UpdateReplicatedVariables()
{
	if( !bIsSpectator &&
		KFPlayerOwner != none &&
		KFPlayerOwner.GetTeamNum() == 0 &&
		KFPlayerOwner.Pawn != none &&
		KFPlayerOwner.Pawn.IsAliveAndWell() )
	{
		UpdatePawnLocation();
	}
	else if( !IsZero( PawnLocationCompressed ) )
	{
		PawnLocationCompressed = vect(0,0,0);
	}

	UpdateReplicatedPlayerHealth();
}

/** Called once per second while on the human team to refresh replicated position */
function UpdatePawnLocation()
{
	PawnLocationCompressed = KFPlayerOwner.Pawn.Location;

	// Compress
	PawnLocationCompressed *= 0.01f;
}

function UpdateReplicatedPlayerHealth()
{
	local Pawn OwnerPawn;

	if( KFPlayerOwner != none )
	{
		OwnerPawn = KFPlayerOwner.Pawn;
		if( OwnerPawn != none && OwnerPawn.Health != PlayerHealth )
		{
			PlayerHealth = OwnerPawn.Health;
			PlayerHealthPercent = FloatToByte( float(OwnerPawn.Health) / float(OwnerPawn.HealthMax) );
		}
	}
}

simulated function SetSmoothedPawnIconLocation( vector NewLocation )
{
	LastReplicatedSmoothedLocation = NewLocation;
}

/** Return location used for overhead icon */
simulated function vector GetSmoothedPawnIconLocation(float BlendSpeed)
{
	local vector UncompressedLocation;

	UncompressedLocation = PawnLocationCompressed * 100.f;

	// if new location is nearby add some quick and dirty blending
	// @note: We're faking timestep and making a few assumptions about the HUD
	if ( BlendSpeed > 0 && !IsZero(UncompressedLocation) && VSizeSq(UncompressedLocation - LastReplicatedSmoothedLocation) < Square(768) )
	{
		LastReplicatedSmoothedLocation = VInterpTo( LastReplicatedSmoothedLocation,
                                UncompressedLocation, WorldInfo.DeltaSeconds,
                                VSize(UncompressedLocation - LastReplicatedSmoothedLocation) * BlendSpeed );
	}
	else
	{
		LastReplicatedSmoothedLocation = UncompressedLocation;
	}

	return LastReplicatedSmoothedLocation;
}

simulated function SetPlayerReady( bool bReady )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);

   	bReadyToPlay = bReady;
	ServerSetPlayerReady( bReady );
	if(KFPC != none && KFPC.LEDEffectsManager != none)
	{
		KFPC.LEDEffectsManager.PlayEffectSetReady(bReadyToPlay);
	}
}

reliable server private function ServerSetPlayerReady( bool bReady )
{
	bReadyToPlay = bReady;
}

/** Called on server to +/- dosh.  Do not modify score directly */
function AddDosh( int DoshAmount, optional bool bEarned )
{
	local KFPlayerController KFPC;

	/** Server code: controllers exist */
	KFPC = KFPlayerController(Owner);
	if (KFPC != none && !KFPC.CanUseDosh())
	{
		return;
	}

    //If the game has turned off dosh earning for this PRI, early out.
    if (!bAllowDoshEarning && bEarned)
    {
        return;
    }

	// Dosh is stored in PRI->Score
	Score = Max(0, Score + DoshAmount);

    // If the trader menu is open, update our menus dosh
	if ( WorldInfo.NetMode == NM_ListenServer )
	{
		UpdateTraderDosh();
	}

	// If player worked for their dosh track it with the AAR
	if ( bEarned && DoshAmount > 0 )
	{
		`RecordAARIntStat(KFPlayerController(Owner), DOSH_EARNED, DoshAmount);
	}
}

/** Update the dosh in our trader menu if it's open */
simulated function UpdateTraderDosh()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Owner);
	if( KFPC != none && KFPC.bClientTraderMenuOpen )
	{
		KFPC.NotifyTraderDoshChanged();
	}
}

simulated event Destroyed()
{
	NotifyHUDofPRIDestroyed();
	super.Destroyed();
}

simulated function NotifyHUDofPRIDestroyed()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetALocalPlayerController());
	ServerNotifyStopVOIP();
	if( KFPC != none )
	{
		// notify HUD of player disconnect
		if( KFPC.MyGFxHUD != none )
		{
			KFPC.MyGFxHUD.NotifyHUDofPRIDestroyed(self);
	}

		// notify movie manager of remote player disconnect
		if( KFPC != Owner && KFPC.MyGFxManager != None )
	{
			KFPC.MyGFxManager.RemotePlayerDisconnected(UniqueId);
		}
	}
}

/**
 * @brief Increments the death count for the player
 * @details Chris: We have to overwrite it here because people might reconnect
 * 			in the lobby. Disconnecting means death and death means no start dosh.
 * @param Amt num deaths (How often can you die simultaniusly?)
 */
function IncrementDeaths( optional int Amt = 1 )
{
	if( WorldInfo.GRI != None && WorldInfo.GRI.bMatchHasBegun )
	{
		super.IncrementDeaths( Amt );
	}

	PawnLocationCompressed = vect(0,0,0);
}

reliable client function MarkSupplierOwnerUsed( KFPlayerReplicationInfo SupplierPRI, optional bool bReceivedPrimary=true, optional bool bReceivedSecondary=true )
{
	if( SupplierPRI != none )
	{
		SupplierPRI.MarkSupplierUsed( bReceivedPrimary, bReceivedSecondary );
	}
}

simulated function MarkSupplierUsed( bool bReceivedPrimary, bool bReceivedSecondary )
{
	bPerkPrimarySupplyUsed = bPerkPrimarySupplyUsed || bReceivedPrimary;
	bPerkSecondarySupplyUsed = bPerkSecondarySupplyUsed || bReceivedSecondary;
}

simulated function ResetSupplierUsed()
{
	local array<KFPlayerReplicationInfo> KFPRIArray;
	local int i;

	KFGameReplicationInfo(WorldInfo.GRI).GetKFPRIArray( KFPRIArray );

	for( i = 0; i < KFPRIArray.Length; ++i )
	{
		KFPRIArray[i].bPerkPrimarySupplyUsed = false;
		KFPRIArray[i].bPerkSecondarySupplyUsed = false;
	}
}

/**
 * Called when a wave has ended.
 * Network: ALL
 */
simulated function NotifyWaveEnded()
{
	bVotedToSkipTraderTime = false;
	
	if ( (WorldInfo.NetMode == NM_Standalone || WorldInfo.NetMode == NM_Client) && KFPlayerController(Owner) != none && KFPlayerController(Owner).GetPerk() != none)
	{
		KFPlayerController(Owner).GetPerk().OnClientWaveEnded();
	}
	/*local KFGameReplicationInfo KFGRI;

	if( Role == ROLE_Authority )
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
		if (KFGRI != none)
		{
			KFGRI.VoteCollector.ResetSkipTraderBeforeWaveStarts();
		}
	}*/
	
	if ( (WorldInfo.NetMode == NM_Standalone || WorldInfo.NetMode == NM_Client) && KFPlayerController(Owner) != none && KFPlayerController(Owner).GetPerk() != none)
	{
		KFPlayerController(Owner).GetPerk().OnClientWaveEnded();
	}
}

//reset the icons here
/**
* Called when a wave has Started.
* Network: ALL
*/
simulated function NotifyWaveStart()
{
	bPerkPrimarySupplyUsed = false;
	bPerkSecondarySupplyUsed = false;
}


// BWJ - 10-5-16 - Check to see if player has had initial spawn. used for PS4 realtime multiplay
native simulated function bool HasHadInitialSpawn();


simulated function SetCurrentVoiceCommsRequest(int NewValue)
{
	//cast it
	CurrentVoiceCommsRequest = EVoiceCommsType(NewValue);
	bNetDirty = true;
	//clear timers
	ClearVoiceCommsRequest();
	//set timers
	SetCurrentIconToVoiceCommsIcon();
}

//this and SetCurrentIconToVoiceCommsIcon used for flashing last voice comms request icon
simulated function SetCurrentIconToPerkIcon()
{
	CurrentVoiceCommsRequest = VCT_NONE;
	bNetDirty = true;
	ClearVoiceCommsRequest();
}

simulated function SetCurrentIconToVoiceCommsIcon()
{
	SetTimer( VoiceCommsStatusDisplayInterval, false, nameof(SetCurrentIconToPerkIcon) );
}

simulated function ClearVoiceCommsRequest()
{
	ClearTimer('SetCurrentIconToPerkIcon');
}

simulated function Texture2D GetCurrentIconToDisplay()
{
	if(CurrentVoiceCommsRequest == VCT_NONE && CurrentPerkClass != none)
	{
		return CurrentPerkClass.default.PerkIcon;
	}

	return class'KFLocalMessage_VoiceComms'.default.VoiceCommsIcons[CurrentVoiceCommsRequest];
}

defaultproperties
{
	// Playable characters from archetypes

	// Mr. Foster is first because he is the only playable character during console installation
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_MrFoster_archetype')

	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Alberts_archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Knight_Archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.chr_briar_archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Mark_archetype')
 	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Jagerhorn_Archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Ana_Archetype')
    CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Masterson_Archetype')
 	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Alan_Archetype')
 	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Coleman_archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.chr_DJSkully_archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Strasser_Archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_Tanaka_Archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.chr_rockabilly_archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_DAR_archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_MrsFoster_archetype')
	CharacterArchetypes.Add(KFCharacterInfo_Human'CHR_Playable_ARCH.CHR_BadSanta_Archetype')

	bShowNonRelevantPlayers=true

	SecondsOfGameplay=-1

    bAllowDoshEarning=true
    VoiceCommsStatusDisplayInterval=5.0f
    VoiceCommsStatusDisplayIntervalMax=1;
    VoiceCommsStatusDisplayIntervalCount=0;
	CurrentVoiceCommsRequest = VCT_NONE
	CurrentHeadShotEffectID=-1;

	bCarryingCollectible=false;
	bVotedToPauseGame=false;
}
