//=============================================================================
// KFAccessControl
//=============================================================================
// Extended Functionality for Admin controls
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFAccessControl extends AccessControl;

var	globalconfig	bool				bSilentAdminLogin;	// If set, there will be no announcement when an Admin logs in
var					Array<UniqueNetID>	SessionBannedIDs;


/**
 * @brief Kick a player and session bans the UniqueId
 * 
 * @param C The kicked player's controller
 * @param KickReason Text shown to the player with a reason for the kick
 * 
 * @return Kick/sessionban un/successfull
 */
function KickSessionBanPlayer( PlayerController C, UniqueNetID KickBanID, string KickReason )
{
	if( KickBanID != class'PlayerReplicationInfo'.default.UniqueId )
	{
		if( !IsIDBanned( KickBanID ) &&	!IsSessionBanned( KickBanID ) )
		{
			SessionBannedIDs.AddItem( KickBanID );
		}

		// Kick player from server if they didn't leave before vote ended
		if( C != none )
		{
			KickPlayer( C, KickReason );
		}
	}
}

/** Overriden from AccessControl.uc, controller is removed in ClientWasKicked() */
function bool ForceKickPlayer(PlayerController C, string KickReason)
{
	if (C != None && NetConnection(C.Player)!=None )
	{
		if (C.Pawn != None)
		{
			C.Pawn.Suicide();
		}
		C.ClientWasKicked();
		return true;
	}
	return false;
}

function AdminEntered( PlayerController P )
{
	if(P == none)
	{
		return;
	}

	if(bSilentAdminLogin)
	{
		P.ReceiveLocalizedMessage(Class'KFLocalMessage', LMT_AdminLogin, P.PlayerReplicationInfo);
	}
	else
	{
		P.BroadcastLocalizedMessage(class'KFLocalMessage', LMT_AdminLogin, P.PlayerReplicationInfo);
	}
}

function AdminExited( PlayerController P )
{
	if(P == none)
	{
		return;
	}

	if(bSilentAdminLogin)
	{
		P.ReceiveLocalizedMessage(Class'KFLocalMessage', LMT_AdminLogout, P.PlayerReplicationInfo);
	}
	else
	{
		P.BroadcastLocalizedMessage(class'KFLocalMessage', LMT_AdminLogout, P.PlayerReplicationInfo);
	}
}

/** Overridden so we do not commit suicide upon logging out */
function bool AdminLogout(PlayerController P)
{
	if (P.PlayerReplicationInfo.bAdmin)
	{
		P.PlayerReplicationInfo.bAdmin = false;
		P.bGodMode = false;

		return true;
	}

	return false;
}

/**
 * @brief Kick a player and perma bans the IP 
 * 
 * @param C The kicked player's controller
 * @param KickReason Text shown to the player with a reason for the kick
 * 
 * @return Kick/ban un/successfull
 */
function KickBanPlayer( PlayerController C, string KickReason )
{
	local string IP;

	if( NetConnection( C.Player ) != None )
	{
		if( !WorldInfo.IsConsoleBuild() )
		{
			IP = C.GetPlayerNetworkAddress();
			if( CheckIPPolicy( IP ) )
			{
				IP = Left(IP, InStr(IP, ":"));
				`Log("Adding IP Ban for: "$IP);
				IPPolicies[IPPolicies.length] = "DENY," $ IP;
				SaveConfig();
			}
		}

		if( C.PlayerReplicationInfo.UniqueId != C.PlayerReplicationInfo.default.UniqueId &&
			!IsIDBanned( C.PlayerReplicationInfo.UniqueID ) )
		{
			BannedIDs.AddItem( C.PlayerReplicationInfo.UniqueId );
			SaveConfig();
		}

		KickPlayer( C, KickReason );
		return;
	}
}

/**
 * @brief Checks if UniqueNetID is already banned
 * 
 * @param UniqueNetID Player's unique net ID
 * @return Ban found or not
 */
function bool IsSessionBanned( const out UniqueNetID NetID )
{
	return SessionBannedIDs.Find('Uid', NetID.Uid) > INDEX_NONE;
}

/**
 * @brief Called from gameinfo when player joins server
 * 
 * @param UniqueNetID Player's unique net ID
 * @return Ban found or not
 */
function bool IsIDBanned(const out UniqueNetID NetID)
{
	return ( IsSessionBanned(NetID) || super.IsIDBanned(NetID) );
}