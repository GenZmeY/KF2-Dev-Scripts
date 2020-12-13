//=============================================================================
// KFPlayerControllerVersus
//=============================================================================
// Versus playercontroller class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPlayerControllerVersus extends KFPlayerController;

var string BossName;

/** Array of zed classes spawned by this player */
var array<bool> HasSpawnedZeds;

/************************************
* Zed XP
************************************/
var					int							ZedXPAmount;
var					byte						ZedXPLevel;

/************************************
*  Replication
************************************/
replication
{
	if ( bNetDirty )
		ZedXPAmount, ZedXPLevel;
}

function Restart(bool bVehicleTransition)
{
	super.Restart( bVehicleTransition );

	if( GetTeamNum() == 255 )
	{
	    KFThirdPersonCamera(KFPlayerCamera(PlayerCamera).ThirdPersonCam).SetViewOffset( KFPawn_Monster(Pawn).ThirdPersonViewOffset );

		if( PlayerCamera.CameraStyle != 'Boss' )
		{
			ServerCamera('ThirdPerson');
		}
	}
}

reliable client function ClientRestart(Pawn NewPawn)
{
	Super.ClientRestart(NewPawn);

	if(NewPawn == none)
	{
		return;
	}

	if( Role < ROLE_Authority && GetTeamNum() == 255 )
	{
	    KFThirdPersonCamera(KFPlayerCamera(PlayerCamera).ThirdPersonCam).SetViewOffset( KFPawn_Monster(Pawn).ThirdPersonViewOffset );

		if( PlayerCamera.CameraStyle != 'Boss' )
		{
			SetCameraMode('ThirdPerson');
		}
	}
}

/** GBA_SwitchAltFire */
exec function StartAltFire(optional Byte FireModeNum )
{
	if( Pawn != none && (Pawn.Weapon == none || Pawn.Weapon.ShouldWeaponIgnoreStartFire()) )
	{
		Pawn.StartFire(4);
		return;
	}

	super.StartAltFire();
}

/** GBA_SwitchAltFire
 * Weapons that override AltFireMode (e.g. welder) and call StartFire
 * also need to call StopFire.  For most weapons this is unnecessary.
 */
exec function StopAltFire(optional Byte FireModeNum )
{
	if( Pawn != none && (Pawn.Weapon == none || Pawn.Weapon.ShouldWeaponIgnoreStartFire()) )
	{
		Pawn.StopFire(4);
		return;
	}

	super.StopAltFire();
}

function AwardZedDamage( int DamageAmount, bool bDamagerIsMe )
{
	// Ramm Versus TODO: Finish this zed damage reward stuff
	ZedXPAmount += DamageAmount;
	//SetRTPCValue( 'R_Method', 7, true );
	//PlayAKEvent( AkEvent'WW_UI_PlayerCharacter.Play_R_Method_Top' );

//
//    if( !bDamagerIsMe )
//    {
//	   ClientMessage("Got ZedXP for nearby zed damage. ZedXP = "$ZedXPAmount);
//	}
//	else
//	{
//	   ClientMessage("Got ZedXP for my zed damage. ZedXP = "$ZedXPAmount);
//	}
//
//	if( ZedXPAmount > 50 && ZedXPLevel < 1 )
//	{
//	   ZedXPLevel = 1;
//	   class'KFMusicStingerHelper'.static.PlayLevelUpStinger( self );
//	   ClientMessage("Unlocked Level 1 Zeds!!!");
//	}
//
//    `log("ZedXPAmount = "$ZedXPAmount$" ZedXPLevel = "$ZedXPLevel);
}

function AddTrackedDamage(int Amount, class<DamageType> DamageType, class<Pawn> DamagerClass, class<Pawn> VictimClass)
{
    if (VictimClass == class'KFPawn_Human_Versus')
    {
        AddTrackedVsDamage(Amount, DamagerClass);
    }
	else
	{
		Super.AddTrackedDamage(Amount, DamageType, DamagerClass, VictimClass);
	}
}

/** @return TRUE if any of the gameplay post process effects have a strength greater than 0.
	Append to this list if additional effects are added. */
function bool ShouldDisplayGameplayPostProcessFX()
{
    // Overridden because the zeds health vary so much, it needs to be a percentage of max health - Ramm
	return super.ShouldDisplayGameplayPostProcessFX()
			|| (GetTeamNum() == 255 && Pawn != none && (Pawn.Health / float(Pawn.HealthMax)) * 100.f <= default.LowHealthThreshold);
}

function RecieveChatMessage(PlayerReplicationInfo PRI, string ChatMessage, name Type, optional float MsgLifeTime)
{
	if(PRI.bAdmin)
	{
		ChatMessage = class'KFLocalMessage'.default.AdminString$ChatMessage;
		MyGFxHUD.HudChatBox.AddChatMessage(ChatMessage, class 'KFLocalMessage'.default.PriorityColor);
	}
	else
	{
		if(Type == 'TeamSay')
		{
			MyGFxHUD.HudChatBox.AddChatMessage(ChatMessage, class 'KFLocalMessage'.default.TeamSayColor);
		}
		else
		{
			MyGFxHUD.HudChatBox.AddChatMessage(ChatMessage, class 'KFLocalMessage'.default.SayColor);
		}
	}
}

unreliable client function NotifyOfAutoBalance()
{
	MyGFxManager.DelayedOpenPopup(ENotification, EDPPID_Misc, Class'KFCommon_LocalizedStrings'.default.NoticeString, Class'KFCommon_LocalizedStrings'.default.TeamSwappedString, Class'KFCommon_LocalizedStrings'.default.OKString);
	MyGFxHUD.ShowNonCriticalMessage(Class'KFCommon_LocalizedStrings'.default.TeamSwappedString);
}

//override from base PlayerController
exec function ChangeTeam( optional string TeamName )
{
	RequestSwitchTeam();
}

exec function RequestSwitchTeam()
{
    local KFPlayerReplicationInfo KFPRI;

    KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
    if ( KFPRI != None && !KFPRI.bOnlySpectator )
    {
        KFPRI.ServerSwitchTeam();
    }
}

/** We have to change perks when players team switch */
function ServerNotifyTeamChanged()
{
	if( Role == ROLE_Authority && MonsterPerkClass != None )
	{
		/*if ( CurrentPerk == None )
		{
			// If we get here without a perk via the normal path, we're in trouble.
			// SavedPerkIndex may not have been updated (config loaded) which will
			// cause team switch to get you the wrong perk.
			`warn("Versus: ServerNotifyTeamChanged called before client has assigned a SavedPerkIndex!");
		}*/

		if( GetTeamNum() > 0 )
		{
			ServerSelectPerk( 255, 0, 0, true );
		}
		else if( CurrentPerk != none && CurrentPerk.Class == MonsterPerkClass )
		{
			ServerSelectPerk( SavedPerkIndex, Perklist[SavedPerkIndex].PerkLevel, Perklist[SavedPerkIndex].PrestigeLevel, true );
		}
	}
}

function ClientRecieveNewTeam()
{
	if(MyGFxManager != none)
	{
		MyGFxManager.ClientRecieveNewTeam();
	}
}

state Dead
{
	event BeginState(Name PreviousStateName)
	{
		super.BeginState( PreviousStateName );

		// Reset camera offset
		if( GetTeamNum() == 255 )
		{
		    KFThirdPersonCamera(KFPlayerCamera(PlayerCamera).ThirdPersonCam).SetViewOffset( class'KFThirdPersonCameraMode'.static.GetDefaultOffset() );
		}
	}
}

/** Called when view target is changed while in spectating state */
function NotifyChangeSpectateViewTarget()
{
	local KFPawn_Monster KFPM;

	super.NotifyChangeSpectateViewTarget();

	KFPM = KFPawn_Monster( ViewTarget );
	if( KFPM != none )
	{
	    KFThirdPersonCamera(KFPlayerCamera(PlayerCamera).ThirdPersonCam).SetViewOffset( KFPM.default.ThirdPersonViewOffset );
	}
}

/**
 * Level was reset without reloading
 * NOTE: We can't call the super because it does a lot of things we don't want it to do. -MattF
 */
function Reset()
{
	// Only reset active players!
	if( CanRestartPlayer() )
	{
		SetViewTarget( self );
	    ResetCameraMode();
	    FixFOV();

	 	// This is necessary because the server will try to synchronize pawns with the client when the client
	 	// is in the middle of trying to clean its pawn reference up. The ClientRestart() function sends the
	 	// client into a state (WaitingForPawn) where it thinks the server is about to replicate a new pawn,
	 	// but it isn't, so the client gets stuck there forever.
	    AcknowledgedPawn = none;

		PlayerZedSpawnInfo.PendingZedPawnClass = none;
		PlayerZedSpawnInfo.PendingZedSpawnLocation = vect( 0,0,0 );
	}
}

/** Level was reset without reloading */
reliable client function ClientReset()
{
	local Actor A;
	local array<Actor> BloodSplatActors;
	local int i;

	// Ensures this only runs once on listen servers
	if( !IsLocalPlayerController() )
	{
		return;
	}

	// Reset all actors (except controllers and blood splats)
	foreach AllActors( class'Actor', A )
	{
		if( A.IsA('KFPersistentBloodActor') )
		{
			BloodSplatActors.AddItem( A );
			continue;
		}

		if( WorldInfo.NetMode == NM_Client && !A.IsA('Controller') )
		{
			A.Reset();
		}
	}

	// Reset blood splat actors after everything else
	for( i = 0; i < BloodSplatActors.Length; ++i )
	{
		BloodSplatActors[i].Reset();
	}
}

/**
 * InitInputSystem()
 * Spawn the appropriate class of PlayerInput
 * Only called for playercontrollers that belong to local players
 */
event InitInputSystem()
{
	Super.InitInputSystem();

	KFPlayerInput(PlayerInput).bVersusInput = true;
}

/** Overridden to allow perk changes during the end of the round */
event SetHaveUpdatePerk( bool bUsedUpdate )
{
	super.SetHaveUpdatePerk( KFGameReplicationInfoVersus(WorldInfo.GRI).bRoundIsOver ? false : bUsedUpdate );
}

//-----------------------------------------------------------------------------
// Mixer Integration
//-----------------------------------------------------------------------------
//Do nothing for versus controllers.  Mixer will startup with other spots on pawn receive
reliable client function ClientMatchStarted()
{}

reliable client function GivePawn(Pawn NewPawn)
{
	super.GivePawn(NewPawn);

	if (NewPawn == none)
	{
		MixerCurrentDefaultScene = "default";
	}
	else
	{
		MixerCurrentDefaultScene = GetPawnBasedMixerScene(NewPawn);
	}

	MixerMoveUsersToDefaultGroup();
}

simulated protected function MixerStartupComplete()
{
	MixerCurrentDefaultScene = GetPawnBasedMixerScene(Pawn);
	SetTimer(1.f, false, nameof(MixerMoveUsersToDefaultGroup));
}

simulated final function string GetPawnBasedMixerScene(Pawn InPawn)
{
	if (InPawn != none)
	{
		if (InPawn.IsA('KFPawn_Monster'))
		{
			return "VersusZed";
		}
		else if (!InPawn.IsA('KFPawn_Customization'))
		{
			return "SelectSide";
		}
	}
	return "default";
}

DefaultProperties
{
	CameraClass=class'KFPlayerCamera_Versus'
	MonsterPerkClass=class'KFPerk_Monster'
    PostRoundMenuClass=class'KFGFxMoviePlayer_PostRoundMenu'
}