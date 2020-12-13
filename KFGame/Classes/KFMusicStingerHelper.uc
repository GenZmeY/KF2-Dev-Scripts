class KFMusicStingerHelper extends Object;

var AkEvent		RoundWonStinger;
var AkEvent 	RoundLostStinger;
var AkEvent		MatchWonStinger;
var AkEvent 	MatchLostStinger;
var AkEvent		WaveStartStinger;
var AkEvent		WaveStartStingerWeekly;
var AkEvent		WaveStartStingerSpecial;
var AkEvent		WaveStartStingerBoss;
var AkEvent		WaveCompletedStinger;
var AkEvent 	NewObjectiveStinger;
var AkEvent 	ObjectiveWonStinger;
var AkEvent 	SpecialEventObjectiveStinger;
var AkEvent 	DailyCompleteStinger;
var AkEvent		ObjectiveLostStinger;
var AkEvent		PlayerDiedStinger;
var AkEvent		LevelUpStinger;
var AkEvent		TierUnlockedStinger;

var AkEvent		TeammateDeathStinger;
var AkEvent		ZedKillHumanStinger;
var AkEvent		ZedPlayerKilledStinger;
var AkEvent		ZedPlayerSuicideStinger;

var AkEvent		WeaponUpgradeStinger;
var AkEvent		PerkPrestigeStinger;

static simulated function PlayWeaponUpgradeStinger(PlayerController P)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(P);
	if (KFPC == none)
	return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent(default.WeaponUpgradeStinger);
}


static simulated function PlayPerkPrestigeStinger(PlayerController P)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(P);
	if (KFPC == none)
	return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent(default.PerkPrestigeStinger);
}


static simulated function PlayTeammateDeathStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.TeammateDeathStinger );
}

static simulated function PlayZedKillHumanStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.ZedKillHumanStinger );
}

static simulated function PlayZedPlayerKilledStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.ZedPlayerKilledStinger );
}

static simulated function PlayZedPlayerSuicideStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.ZedPlayerSuicideStinger );
}

static simulated function PlayRoundWonStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.RoundWonStinger );
}

static simulated function PlayRoundLostStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow player match lost stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.RoundLostStinger );
}

static simulated function PlayMatchWonStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow match won stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.MatchWonStinger );
}

static simulated function PlayMatchLostStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow player match lost stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.MatchLostStinger );
}

static simulated function PlayWaveStartStinger( PlayerController P, optional byte WaveStartType = GMT_WaveStart)
{
	local KFPlayerController KFPC;
	local AkEvent AKEventToPlay;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow player wave complete stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();

	switch (WaveStartType)
	{
	case GMT_WaveStart:
		AKEventToPlay = default.WaveStartStinger;
		break;
	case GMT_WaveStartWeekly:
		AKEventToPlay = default.WaveStartStingerWeekly;
		break;
	case GMT_WaveStartSpecial:
		AKEventToPlay = default.WaveStartStingerSpecial;
		break;
	case GMT_WaveSBoss:
		AKEventToPlay = default.WaveStartStingerBoss;
		break;
	default:
		AKEventToPlay = default.WaveStartStinger;
	}
	

	KFPC.StingerAkComponent.PlayEvent( AKEventToPlay );
}

static simulated function PlayWaveCompletedStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	// allow player wave complete stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.WaveCompletedStinger );
}

static simulated function PlayDailyCompleteStinger(PlayerController P)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(P);
	if (KFPC == none)
		return;

	KFPC.StingerAkComponent.StopEvents();

	KFPC.StingerAkComponent.PlayEvent(default.DailyCompleteStinger);
}

static simulated function PlaySpecialEventObjectiveStinger(PlayerController P)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(P);
	if (KFPC == none)
		return;

	KFPC.StingerAkComponent.StopEvents();

	KFPC.StingerAkComponent.PlayEvent(default.SpecialEventObjectiveStinger);
}

static simulated function PlayObjectiveWonStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	KFPC.StingerAkComponent.StopEvents();

	KFPC.StingerAkComponent.PlayEvent( default.ObjectiveWonStinger );
}

static simulated function PlayNewObjectiveStinger(PlayerController P)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(P);
	if (KFPC == none)
		return;

	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent(default.NewObjectiveStinger);
}


static simulated function PlayObjectiveLostStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	if( KFPC.StingerAkComponent.IsPlaying() )
		return;
	KFPC.StingerAkComponent.PlayEvent( default.ObjectiveLostStinger );
}

static simulated function PlayLevelUpStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	if( KFPC.StingerAkComponent.IsPlaying() )
		return;

	KFPC.StingerAkComponent.PlayEvent( default.LevelUpStinger );
}

static simulated function PlayTierUnlockedStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none )
		return;

	if( KFPC.StingerAkComponent.IsPlaying() )
		return;

	KFPC.StingerAkComponent.PlayEvent( default.TierUnlockedStinger );
}

static simulated function PlayPlayerDiedStinger( PlayerController P )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController( P );
	if( KFPC == none || class'Engine'.static.IsEditor() )
		return;

	// allow player died stinger to interrupt others
	KFPC.StingerAkComponent.StopEvents();
	KFPC.StingerAkComponent.PlayEvent( default.PlayerDiedStinger );
}

defaultproperties
{
	WaveStartStinger=AkEvent'WW_UI_Menu.Play_UI_Alert_Wave_Incoming'
	WaveStartStingerSpecial=AkEvent'WW_UI_Objectives.Play_UI_ObjectiveComplete'
	WaveStartStingerWeekly=AkEvent'WW_UI_Objectives.Play_UI_ObjectiveComplete'
	WaveStartStingerBoss=AkEvent'WW_UI_Menu.Play_Zed_Player_Killed'
	RoundWonStinger=AkEvent'WW_UI_Menu.Play_Round_Won'
	RoundLostStinger=AkEvent'WW_UI_Menu.Play_Round_Lost'
	MatchWonStinger=AkEvent'WW_MSTG_Global.Play_MSTG_BossKilled'
	MatchLostStinger=AkEvent'WW_MSTG_Global.Play_MSTG_TeamWipedOut'
	WaveCompletedStinger=AkEvent'WW_MSTG_Global.Play_MSTG_WaveComplete'
	ObjectiveWonStinger=AkEvent'WW_UI_Objectives.Play_UI_ObjectiveComplete'
	ObjectiveLostStinger=AkEvent'WW_UI_Objectives.Play_UI_Objective_Fail'
	NewObjectiveStinger= AkEvent'WW_UI_Objectives.Play_UI_ObjectiveNotify'
	PlayerDiedStinger=AkEvent'WW_MSTG_Global.Play_MSTG_PlayerDeath'
	LevelUpStinger=AkEvent'WW_MSTG_Global.Play_MSTG_LevelUp_XP'
	TierUnlockedStinger=AkEvent'WW_MSTG_Global.Play_MSTG_LevelUp_KeyXP'

	SpecialEventObjectiveStinger=AkEvent'WW_UI_Objectives.Play_UI_ObjectiveComplete'
	DailyCompleteStinger=AkEvent'WW_UI_Objectives.Play_UI_ObjectiveComplete'

	TeammateDeathStinger=AkEvent'WW_UI_Menu.Play_Teammate_Death'
	ZedKillHumanStinger=AkEvent'WW_UI_Menu.Play_Zed_Kill_Human'
	ZedPlayerKilledStinger=AkEvent'WW_UI_Menu.Play_Zed_Player_Killed'
	ZedPlayerSuicideStinger=AkEvent'WW_UI_Menu.Play_Zed_Player_Suicide'

	WeaponUpgradeStinger=AkEvent'WW_UI_Menu.Play_UI_Weapon_Upgrade'
	PerkPrestigeStinger=AkEvent'WW_UI_Menu.Play_UI_Prestige_Lvl_Reset'
}
