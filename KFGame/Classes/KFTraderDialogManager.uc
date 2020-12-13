//=============================================================================
// KFTraderDialogManager
//=============================================================================
// Manager class for trader dialog
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFTraderDialogManager extends Actor
	dependson(KFTraderVoiceGroupBase);

`include(KFGame/KFGameDialog.uci)

var bool	bEnabled;

struct TraderDialogCoolDownInfo
{
	var	int		EventID;
	var int 	Priority;
	var float 	EndTime;
};

var transient array< TraderDialogCoolDownInfo >	CoolDowns;

/** The voice class contains the actual AkEvents to play (allows us to swap out different voices) */
var transient class<KFTraderVoiceGroupBase> TraderVoiceGroupClass;

/** The event currently being spoken by the trader */
var transient TraderDialogEventInfo ActiveEventInfo;

/** variables used to determine what should be said by trader */
var float 	FewZedsDeadPct;
var float 	ManyZedsDeadPct;
var float 	FarFromTraderDistance;
var float	NeedHealPct;
var float 	TeammateNeedsHealPct;
var int 	ShareDoshAmount;
var int		LowDoshAmount;

/** Delay trader open dialog a short time so we don't overlap wave end sounds */
var float 	WaveClearDialogDelay;
/** Event to play at end of delay.  Cached after MatchStats are recieved, but before they are reset */
var int 	DelayedWaveClearEventID;

/** Used as SetTimer callback. Set by PlayDialog. */
simulated function EndOfDialogTimer()
{
	local TraderDialogCoolDownInfo CoolDownInfo;

	CoolDownInfo.EventID = ActiveEventInfo.EventID;
	CoolDownInfo.Priority = ActiveEventInfo.Priority;
	CoolDownInfo.EndTime = WorldInfo.TimeSeconds + ActiveEventInfo.CoolDown;
	CoolDowns.AddItem( CoolDownInfo );

	ActiveEventInfo.AudioCue = none;
}

/** Whether given event is cooling down */
simulated function bool DialogIsCoolingDown( int EventID )
{
    local int CoolDownIndex;

    CoolDownIndex = CoolDowns.Find('EventID', EventID);
    if( CoolDownIndex == INDEX_NONE )
    {
    	return false;
    }

    if( CoolDowns[CoolDownIndex].EndTime <= WorldInfo.TimeSeconds )
    {
    	CoolDowns.Remove( CoolDownIndex, 1 );
    	return false;
    }

    return true;
}

/** Whether the dialog should play, given the percent chance. */
simulated function bool ShouldDialogPlay(int EventID)
{
	local float PercentChance;

	PercentChance = TraderVoiceGroupClass.default.DialogEvents[EventID].Chance;
	if (PercentChance >= 1.f)
	{
		return true;
	}

	if (FRand() <= PercentChance)
	{
		return true;
	}

	return false;
}

/** Plays dialog event and replicates it as necessary */
simulated function PlayDialog( int EventID, Controller C, bool bInterrupt = false )
{
	local KFPawn_Human KFPH;

	// safeguard - don't play audio on dedicated server because we can't anyway
	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		`log("Failed to play dialog id " $ EventId $ ". Tried to play on dedicated server.");
		return;
	}

	if (C == none)
	{
		`log("Failed to play dialog id " $ EventId $ ". Controller is null.");
		return;
	}

	// safeguard - only play trader dialog for local players
	if( !C.IsLocalController() )
	{
		`log("Failed to play dialog id " $ EventId $ ". Controller is not local");
		return;
	}

	if( !bEnabled || TraderVoiceGroupClass == none )
	{
		`log("Failed to play dialog id " $ EventId $ ". Manager is disabled or trader voice group class is none.");
		return;
	}

	if( EventID < 0 || EventID >= `TRADER_DIALOG_COUNT )
	{
		`log("Failed to play dialog id " $ EventId $ ". Event id is outside of range of 0 and " $ (`TRADER_DIALOG_COUNT - 1));
		return;
	}

	if( C.Pawn == none || !C.Pawn.IsAliveAndWell() )
	{
		`log("Failed to play dialog id " $ EventId $ ". Controller's pawn is either null or dead.");
		return;
	}

	// don't interrupt active dialog
	if( ActiveEventInfo.AudioCue != none && !bInterrupt )
	{
		`log("Failed to play dialog id " $ EventId $ ". There is already another audio cue going and we can't interrupt.");
		return;
	}

	// don't speak same dialog again too soon
	if( DialogIsCoolingDown(EventID) )
	{
		`log("Failed to play dialog id " $ EventId $ ". Event id is still cooling down.");
		return;
	}

	if (!ShouldDialogPlay(EventID))
	{
		`log("Failed to play dialog id " $ EventId $ ". Failed random chance to play.");
		return;
	}

	KFPH = KFPawn_Human( C.Pawn );
	if( KFPH != none )
	{
		if (bInterrupt)
		{
			KFPH.StopTraderDialog();
		}

		ActiveEventInfo = TraderVoiceGroupClass.default.DialogEvents[ EventID ];
		//`log("Play Dialog" @ ActiveEventInfo.EventID @ ActiveEventInfo.AudioCue);
		KFPH.PlayTraderDialog( ActiveEventInfo.AudioCue );
		SetTimer( ActiveEventInfo.AudioCue.Duration, false, nameof(EndOfDialogTimer) );
	}
}

/** Plays a synced dialog event for every player in the game.
	Called on server.
  */
static function PlayGlobalDialog( int EventID, WorldInfo WI, bool bInterrupt = false )
{
	local Controller C;
	local KFPlayerController KFPC;

	foreach WI.AllControllers(class'Controller', C)
	{
		if( C.bIsPlayer )
		{
			KFPC = KFPlayerController( C );
			if( KFPC == none )
			{
				continue;
			}

			if( KFPC.IsLocalController() )
			{
				//`log("Play Global Dialog " $ EventID $ ": Play Trader Dialog");
				KFPC.PlayTraderDialog( EventID, bInterrupt );
			}
			else
			{
				//`log("Play Global Dialog " $ EventID $ ": Play Client Trader Dialog");
				KFPC.ClientPlayTraderDialog( EventID, bInterrupt );
			}
		}
	}
}

/** Plays wave progress event for every player in the game.
	Called on server.
  */
static function PlayGlobalWaveProgressDialog( int ZedsRemaining, int ZedsTotal, WorldInfo WI )
{
	local float ZedDeadPct, PrevZedDeadPct;

	if ( ZedsTotal == 0 )
		return;

	ZedDeadPct = 1.f - (float(ZedsRemaining) / float(ZedsTotal));
	PrevZedDeadPct = 1.f - (float(ZedsRemaining+1) / float(ZedsTotal));
	if( PrevZedDeadPct < default.ManyZedsDeadPct && ZedDeadPct >= default.ManyZedsDeadPct )
	{
		PlayGlobalDialog( `TRAD_Wave80pctDead, WI );
	}
	else if( PrevZedDeadPct < default.FewZedsDeadPct && ZedDeadPct >= default.FewZedsDeadPct )
	{
		PlayGlobalDialog( `TRAD_Wave20pctDead, WI );
	}
}

/** Plays dialog when trader time begins */
simulated function PlayOpenTraderDialog( int WaveNum, int WaveMax, Controller C )
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	if( KFGRI != none && KFGRI.IsBossWaveNext() )
	{
		PlayDialog( `TRAD_FinalShopWave, C );
	}
	else if (KFGRI != none && KFGRI.bEndlessMode && KFGRI.IsBossWave())
	{
		PlayDialog(`TRAD_PATTY_KILLBOSS_1 + Clamp((WaveNum / 5), 0, 14), C);
	}
	else
	{
		PlayDialog( `TRAD_WaveLastZedDies, C );
	}
}

/** Plays dialog when player enters trader trigger.
	Called on server.
  */
static function PlayApproachTraderDialog( Controller C )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( C );
	if( KFPC == none )
	{
		return;
	}

	if( KFPC.IsLocalController() )
	{
		KFPC.PlayTraderDialog( `TRAD_PlayerArrive );
	}
	else
	{
		KFPC.ClientPlayTraderDialog( `TRAD_PlayerArrive );
	}
}

/** Plays dialog when trader time ends */
simulated function PlayCloseTraderDialog( Controller C )
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(C.WorldInfo.GRI);
	if(KFGRI == none || !KFGRI.bEndlessMode)
	{
		// Only play trader close dialog for non-endless game modes.
		PlayDialog( `TRAD_Close, C );
	}
}

/** Modifies "BestOptionID" based on "NumOptions" to represent a random event */
simulated function AddRandomOption( int OptionID, out byte NumOptions, out int BestOptionID )
{
	local TraderDialogEventInfo NewOptionEventInfo, BestOptionEventInfo;

	if( OptionID < 0 || TraderVoiceGroupClass == none )
	{
		return;
	}

	if( BestOptionID >= 0 )
	{
		NewOptionEventInfo = TraderVoiceGroupClass.default.DialogEvents[OptionID];
		BestOptionEventInfo = TraderVoiceGroupClass.default.DialogEvents[BestOptionID];
		if( NewOptionEventInfo.Priority < BestOptionEventInfo.Priority )
		{
			NumOptions = 0;
		}
		else if( NewOptionEventInfo.Priority > BestOptionEventInfo.Priority )
		{
			return;
		}
	}

	NumOptions++;
	if( Frand() <= 1.f / float(NumOptions) )
	{
		BestOptionID = OptionID;
	}
}

/** called once per second from KFGameReplicationInfo Timer(), which is simulated */
simulated function PlayTraderTickDialog( int RemainingTime, Controller C, WorldInfo WI )
{
	local Pawn P;
	local KFPawn_Human KFPH, Teammate;
	local KFGameReplicationInfo KFGRI;
	local KFPlayerController KFPC;
	local KFMapInfo KFMI;
	local int BestOptionID;
	local byte NumOptions;

	if( !default.bEnabled )
	{
		return;
	}

	if( RemainingTime == 30 )
	{
		PlayDialog( `TRAD_30SecLeft, C );
		return;
	}

	if( RemainingTime == 10 )
	{
		PlayDialog( `TRAD_10SecLeft, C );
		return;
	}

	KFPC = KFPlayerController( C );
	if( KFPC == none )
	{
		return;
	}

	if( KFPC.bClientTraderMenuOpen )
	{
		return;
	}

	KFPH = KFPawn_Human( C.Pawn );
	if( KFPH == none )
	{
		return;
	}

	BestOptionID = INDEX_NONE;

	if( KFPH.GetHealthPercentage() < default.NeedHealPct )
	{
		// need healing
		AddRandomOption( `TRAD_NeedToHeal, NumOptions, BestOptionID );
	}

	KFGRI = KFGameReplicationInfo(WI.GRI);

	if( KFGRI != none && KFGRI.OpenedTrader != none )
	{
		KFMI = KFMapInfo( WorldInfo.GetMapInfo() );
		if( (KFMI == none || KFMI.SubGameType != ESGT_Descent)
			&& VSize(KFGRI.OpenedTrader.Location - KFPH.Location) >= default.FarFromTraderDistance )
		{
			// far from trader
			AddRandomOption( `TRAD_PlayerFarAway, NumOptions, BestOptionID );
		}
	}

	for( P = WI.PawnList; P != none; P = P.NextPawn )
	{
		if( KFPH == P )
	    {
	    	continue;
	    }

	    if( P.GetTeamNum() != 0 )
	    {
	        continue;
	    }

	    if( !P.IsAliveAndWell() )
	    {
	        continue;
	    }

	    Teammate = KFPawn_Human( P );
	    if( Teammate == none )
	    {
	        continue;
	    }

	    if( Teammate.GetHealthPercentage() < default.TeammateNeedsHealPct )
	    {
	    	// teammates needs healing
	    	AddRandomOption( `TRAD_TeamNeedsHeal, NumOptions, BestOptionID );
	    	break;
	    }
	}

	if(BestOptionID != INDEX_NONE)
	{
		PlayDialog( BestOptionID, C );
	}
}

/** Plays dialog when trader time begins based on performance last wave */
simulated function PlayBeginTraderTimeDialog( KFPlayerController KFPC )
{
	if( !default.bEnabled )
	{
		return;
	}
	if( KFPC.PWRI.bDiedDuringWave )
	{
		PlayPlayerDiedLastWaveDialog( KFPC );
	}
	else
	{
		PlayPlayerSurvivedLastWaveDialog( KFPC  );
	}
}

/** Called from PlayBeginTraderTimeDialog if player died last wave */
simulated function PlayPlayerDiedLastWaveDialog( KFPlayerController KFPC )
{
	local int BestOptionID;
	local byte NumOptions;

	BestOptionID = -1;

	// killed by specific zed last wave
	if( KFPC.PWRI.ClassKilledByLastWave != none )
	{
		AddRandomOption( KFPC.PWRI.ClassKilledByLastWave.static.GetTraderAdviceID(), NumOptions, BestOptionID );
	}

	if( KFPC.MatchStats.DeathStreak >= 3 )
	{
		// keep dying
		AddRandomOption( `TRAD_KeepDying, NumOptions, BestOptionID );
	}
	else
	{
		// died last wave
		AddRandomOption( `TRAD_DiedLastWave, NumOptions, BestOptionID );
	}

	PlayWaveClearDialog(BestOptionID, KFPC);
}

/** Called from PlayBeginTraderTimeDialog if player survived last wave */
simulated function PlayPlayerSurvivedLastWaveDialog( KFPlayerController KFPC )
{
	local int BestOptionID;
	local byte NumOptions;
	local KFPawn_Human KFPH;

	BestOptionID = -1;

	KFPH = KFPawn_Human( KFPC.Pawn );
	if( KFPH == none )
	{
		return;
	}

	if( KFPC.MatchStats.GetHealGivenInWave() >= 200 )
	{
		// good job healing
		AddRandomOption( `TRAD_GoodJobHeal, NumOptions, BestOptionID );
	}

	if( KFPC.MatchStats.SurvivedStreak >= 3 )
	{
		// didn't die multiple waves
		AddRandomOption( `TRAD_SurviveMultWaves, NumOptions, BestOptionID );
	}

	if (KFPC.MatchStats.GetDamageTakenInWave() == 0)
	{
		// no damage taken
		AddRandomOption(`TRAD_NoDamage, NumOptions, BestOptionID);
	}

	if (KFPH.HealthMax != KFPH.Health)
	{	
		if (KFPC.MatchStats.GetDamageTakenInWave() < KFPH.HealthMax / 2)
		{
			// less than half damage taken
			AddRandomOption(`TRAD_LT50PctDamTaken, NumOptions, BestOptionID);
		}

		if (KFPC.MatchStats.GetDamageTakenInWave() >= 300)
		{
			// took lots of damage but didn't die
			AddRandomOption(`TRAD_HighDmgSurvivor, NumOptions, BestOptionID);
		}

		if (KFPC.MatchStats.GetDamageTakenInWave() >= 100 && KFPC.MatchStats.GetHealReceivedInWave() >= 100)
		{
			// took lots of damage and got healed a lot
			AddRandomOption(`TRAD_HighDmgHighHeal, NumOptions, BestOptionID);
		}
	}

	if( KFPC.PWRI.bKilledFleshpoundLastWave )
	{
		// killed fp
		AddRandomOption( `TRAD_KilledFleshpound, NumOptions, BestOptionID );
	}

	if( KFPC.PWRI.bKilledScrakeLastWave )
	{
		// killed scrake
		AddRandomOption( `TRAD_KilledScrake, NumOptions, BestOptionID );
	}

	if( KFPH.PlayerReplicationInfo.Score < default.LowDoshAmount )
	{
		// low dosh
		AddRandomOption( `TRAD_LittleDosh, NumOptions, BestOptionID );
	}

	// Team based dialog options (skip in solo)
	if ( !IsSoloHumanPlayer() )
	{
		if( KFPC.PWRI.bKilledMostZeds )
		{
			// killed most zeds
			AddRandomOption( `TRAD_KilledMost, NumOptions, BestOptionID );
		}

		if( KFPC.PWRI.bEarnedMostDosh )
		{
			// earned most dosh last wave
			AddRandomOption( `TRAD_EarnMostDosh, NumOptions, BestOptionID );
		}

		if( KFPC.PWRI.bBestTeammate )
		{
			AddRandomOption( `TRAD_BestTeamPlayer, NumOptions, BestOptionID );
		}

		if( KFPH.PlayerReplicationInfo.Score >= default.ShareDoshAmount )
		{
			// you're rich, share dosh
			AddRandomOption( `TRAD_ShareDosh, NumOptions, BestOptionID );
		}

		if( KFPC.PWRI.bAllSurvivedLastWave )
		{
			// no one died
			AddRandomOption( `TRAD_NoOneDies, NumOptions, BestOptionID );
		}
		else if( KFPC.PWRI.bSomeSurvivedLastWave )
		{
			// a view teammates died
			AddRandomOption( `TRAD_SomeDie, NumOptions, BestOptionID );
		}
		else if( KFPC.PWRI.bOneSurvivedLastWave )
		{
			// whole team died except you
			AddRandomOption( `TRAD_OnlySurvivor, NumOptions, BestOptionID );
		}
	}

	PlayWaveClearDialog(BestOptionID, KFPC);
}

/** Helper function to count human team players on the client */
function bool IsSoloHumanPlayer()
{
    local int i, NumHumans;
    local PlayerReplicationInfo PRI;

    // trivial case
    if ( WorldInfo.NetMode == NM_StandAlone )
    {
    	return true;
    }

    // Count human team members by adding up active PRI's. TeamInfo.Size not replicated?
	for ( i = 0; i < WorldInfo.GRI.PRIArray.Length && NumHumans < 2; i++)
    {
    	PRI = WorldInfo.GRI.PRIArray[i];
		if ( PRI != None && !PRI.bOnlySpectator && PRI.GetTeamNum() == 0 )
		{
			NumHumans++;
		}
	}

    return (NumHumans == 1);
}

/**
 * Trigger a delayed dialog event when trader opens. Delay should be long enough to bypass
 * wave end sounds.  Need to cache the EventId, because MatchStats may not have valid data
 * by the time the timer expires.
 */
simulated function PlayWaveClearDialog( int EventID, Controller C )
{
	if( C != None && C.IsLocalController() )
	{
		DelayedWaveClearEventID = EventID;
		SetTimer(WaveClearDialogDelay, false, nameof(WaveClearDialogTimer));
	}
}

/** Actually play sound after timer expires */
simulated function WaveClearDialogTimer()
{
	PlayDialog( DelayedWaveClearEventID, WorldInfo.GetALocalPlayerController() );
}

/** Plays dialog when player "uses" trader and opens trader menu */
simulated function PlayOpenTraderMenuDialog( KFPlayerController KFPC )
{
	local KFPawn_Human KFPH;
    local KFGameReplicationInfo KFGRI;
	local float ArmorPct, AmmoMax, AmmoPct;

	local int BestOptionID;
	local byte NumOptions;

	BestOptionID = -1;

	KFPH = KFPawn_Human( KFPC.Pawn );
	if( KFPH != none )
	{
        KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
        if (KFGRI == none || KFGRI.WaveNum > 1)
        {
            ArmorPct = float(KFPH.Armor) / float(KFPH.MaxArmor);
            if (ArmorPct <= 0.f)
            {
                // no armor
                AddRandomOption(`TRAD_NoArmor, NumOptions, BestOptionID);
            }
            else if (ArmorPct < 0.3f)
            {
                // low armor
                AddRandomOption(`TRAD_LowArmor, NumOptions, BestOptionID);
            }
        }

		// only play low ammo dialog if the weapon uses ammo
		AmmoMax = float(KFPH.MyKFWeapon.GetMaxAmmoAmount(0));
		if( AmmoMax > 0 )
		{
			AmmoPct = KFPH.MyKFWeapon.GetAmmoPercentage(0);
			if( AmmoPct < 0.3f )
			{
				// low ammo
				AddRandomOption( `TRAD_LowAmmo, NumOptions, BestOptionID );
			}
		}

		if( !KFPH.MyKFWeapon.HasAmmo(4) )
		{
			// no grenades
			AddRandomOption( `TRAD_NoNades, NumOptions, BestOptionID );
		}
	}

	PlayDialog( BestOptionID, KFPC );
}

/** Plays dialog related to current objective */
simulated function PlayObjectiveDialog( Controller C, int ObjDialogID )
{
	PlayDialog( ObjDialogID, C );
}

function PlayLastManStandingDialog( WorldInfo WI )
{
	PlayGlobalDialog( `TRAD_LastManStanding, WI );
}

/** Plays dialog if selected item in trader menu is unobtainable */
simulated function PlaySelectItemDialog( Controller C, bool bTooExpensive, bool bTooHeavy )
{
	local int BestOptionID;
	local byte NumOptions;

	BestOptionID = -1;

	if( bTooExpensive )
	{
		AddRandomOption( `TRAD_ClickTooExpensive, NumOptions, BestOptionID );
	}

	if( bTooHeavy )
	{
		AddRandomOption( `TRAD_ClickTooHeavy, NumOptions, BestOptionID );
	}

	PlayDialog( BestOptionID, C );
}

static function BroadcastEndlessStartWaveDialog(int WaveNum, int ModeIndex, WorldInfo WI)
{
	local int SpecialWaveEventId, NormalWaveEventId;
	local Controller C;
	local KFPlayerController KFPC;

	SpecialWaveEventId = INDEX_NONE;
	NormalWaveEventId = INDEX_NONE;

	if (ModeIndex != INDEX_NONE)
	{
		SpecialWaveEventId = `TRAD_SPECIALWAVE_1 + (ModeIndex % 3);
	}

	if (WaveNum > 100)
	{
		NormalWaveEventId = `TRAD_PATTY_WAVE_100Plus;
	}
	else
	{
		NormalWaveEventId = `TRAD_PATTY_WAVE_1 + (WaveNum - 1);
	}

	// Play specific global dialog
	// We can't just call "PlayGlobalDialog" because we need to do some extra logic client-side, where the trader voice group lives
	foreach WI.AllControllers(class'Controller', C)
	{
		if( C.bIsPlayer )
		{
			KFPC = KFPlayerController( C );
			if( KFPC == none )
			{
				continue;
			}

			if( KFPC.IsLocalController() )
			{
				KFPC.PlayTraderEndlessWaveStartDialog(SpecialWaveEventId, NormalWaveEventId);
			}
			else
			{
				KFPC.ClientPlayTraderEndlessWaveStartDialog(SpecialWaveEventId, NormalWaveEventId);
			}
		}
	}
}

static function PlayFirstWaveStartDialog(WorldInfo WI)
{
    PlayGlobalDialog(`TRAD_FirstWave, WI);
}

defaultproperties
{
	bEnabled=true

	FewZedsDeadPct=0.2
	ManyZedsDeadPct=0.8

	FarFromTraderDistance=50000

	NeedHealPct=0.5
	TeammateNeedsHealPct=0.5

	ShareDoshAmount=2000
	LowDoshAmount=200

	WaveClearDialogDelay=7.f
}
