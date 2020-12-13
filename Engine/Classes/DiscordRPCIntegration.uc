//=============================================================================
// DiscordRPCIntegration
//=============================================================================
// Platform interface plugin for Discord's rich presence service.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class DiscordRPCIntegration extends PlatformInterfaceBase
	native(PlatformInterface);

var bool bDiscordReady;

//Delegate/Function pairs with callbacks into other areas
delegate JoinLobby(qword LobbyId);
native function InternalJoinLobby(qword LobbyId);

/**
* Perform any initialization
*/
native event Init();

/*
 * Perform shutdown of the Discord lib
 */
native function Shutdown();

/**
 * Called on PC tick to trigger any callbacks from the Discord DLL
 */
native function TickDiscord();

 /**
  * Create and send a presence object involving being in the main menu.
  */
native simulated function CreateMenuPresence(string PresenceString, qword LobbyId, int CurrentPlayers, int MaxPlayers);

/**
 * Create and send a presence object involving being in-game.
 */
native simulated function CreateGamePresence(string PresenceString, string DetailsString, string MapName, int CurrentPlayers, int MaxPlayers);