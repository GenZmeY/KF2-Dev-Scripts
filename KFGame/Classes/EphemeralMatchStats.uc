//=============================================================================
// KFPerk
//=============================================================================
// Collects stats for in dialog and after action review (AAR)
//	//http://dictionary.reference.com/browse/ephemeral
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class EphemeralMatchStats extends Object within KFPlayerController
	dependson(KFGFxObject_TraderItems);

`define INCLUDE_MATCH_STATS_EVENT(dummy)
`include(KFGame\KFMatchStats.uci);
`undefine(INCLUDE_MATCH_STATS_EVENT)

var bool bShowMatchStatsLogging;

struct TopWeaponReplicationInfo
{
	var class<KFWeaponDefinition> TopWeapon1;
	var class<KFWeaponDefinition> TopWeapon2;
	var class<KFWeaponDefinition> TopWeapon3;

	var Vector TopWeapon1Info; //x - damage dealt y - headshots z - Large Zed kills
	var Vector TopWeapon2Info;
	var Vector TopWeapon3Info;
};

struct AARAward
{
	var name IconPath;
	var string TitleIdentifier;			//used for localization localized when sent to menu
	var string DescriptionIdentifier; 	//used for localization localized when sent to menu
	var string ValueIdentifier;		//used for localization localized when sent to menu
	var int DisplayValue;
	var bool bHighLight;
	var PlayerReplicationInfo PRI; //WhoEarned this award
};

var array<AARAward> TeamAwardList;

enum ETeamAwards
{	
	ETA_WeaponMaster,
	ETA_ZedStomper,
	ETA_MedicineMaster,
	ETA_ZedSlayer,
	ETA_Enforcer,
	ETA_Destroyer,
	ETA_GiantSlayer,
	ETA_MoneyBags,
	ETA_HeadPopper,
	ETA_Dominator,
	ETA_Carnage,
	ETA_Closer,
	ETA_ComboMaker,
	ETA_Grabby,
	ETA_ZedSupport,
	ETA_Zednnihilation,
	ETA_Max
};

enum EPersonalBests
{
	EPB_KnifeKills,  //single player
	EPB_PistolKills, //single player
	EPB_HeadShots,
	EPB_Healing,
	EPB_Kills,
	EPB_Assists,
	EPB_LargeZedKill,
	EPB_Dosh,
	EPB_DoorWelding,
	EPB_ZedStomps
};

var array<AARAward> PersonalBestList;

var TopWeaponReplicationInfo TWRI;

/**********************************************
// @Dialogue
**********************************************/
var int 	ZedsKilledLastWave;

var byte    DeathStreak;
var byte    SurvivedStreak;

/**********************************************
// @AAR
**********************************************/
//From Vector 1 on WaveReplicationInfo
var int		TotalHeadShots;		//AAR			// Take to client side
var int		TotalDoshEarned;     //dialog		1
var int		TotalDamageDealt; 	//AAR //Client

//From Vector 2 on WaveReplicationInfo
var int		TotalDamageTaken; //dialog
var int 	TotalAmountHealGiven; //dialog
var int 	TotalAmountHealReceived; //dialog

var int		TotalLargeZedKills;
var int     TotalStomps;

var bool bKilledBoss;

struct ZedKillType
{
	var Class<KFPawn_Monster> MonsterClass;
	var int KillCount;
};

struct WeaponDamage
{
	var class<KFWeaponDefinition> 	WeaponDef;
	var int DamageAmount;
	var int HeadShots;
	var int LargeZedKills;
	var int 						Kills; //This var is client side only
};

struct PerkXPGain
{
	var Class<KFPerk> PerkClass;
	var int XPDelta;
	var int SecondaryXPGain;
	var int BonusXP;
	var float StartXPPercentage;
	var int StartLevel;
};

var array<PerkXPGain> PerkXPList;
var array<WeaponDamage> WeaponDamageList;
var array<ZedKillType> ZedKillsArray;

function RecordIntStat(int StatID, int Value)
{
	switch (StatID)
	{
		case MATCH_EVENT_HEADSHOT:
			IncrementHeadShotsInWave(Value);
			break;

		case MATCH_EVENT_DOSH_EARNED:
			IncrementDoshEarnedInWave(Value);
			break;

		case MATCH_EVENT_DAMAGE_DEALT:
			IncrementDamageDealtInWave(Value);
			break;

		case MATCH_EVENT_DAMAGE_TAKEN:
			IncrementDamageTakenInWave(Value);
			break;

		case MATCH_EVENT_HEAL_GIVEN:
			IncrementHealGivenInWave(Value);
			break;

		case MATCH_EVENT_HEAL_RECEIVED:
			IncrementHealReceivedInWave(Value);
			break;
		case MATCH_EVENT_STOMP_GIVEN:
			IncrementStompsGivenInWave(Value);
			break;
	}
}

//var Vector 	VectData1; //used for compressing data //X:HeadShots Y:Dosh Earned Z:Damage Dealt
//var Vector 	VectData2;	//used for compressing data //Damage Taken, Heals Received, Heals Given

function IncrementHeadShotsInWave(int Delta)
{
	PWRI.VectData1.X += Delta;
}

function int GetHeadShotsInWave()
{
	return PWRI.VectData1.X;
}

function IncrementDoshEarnedInWave(int Delta)
{
	PWRI.VectData1.Y += Delta;
}

function int GetDoshEarnedInWave()
{
	return PWRI.VectData1.Y;
}

function IncrementDamageDealtInWave(int Delta)
{
	PWRI.VectData1.Z += Delta;
}

function int GetDamageDealtInWave()
{
	return PWRI.VectData1.Z;
}

function IncrementDamageTakenInWave(int Delta)
{
	PWRI.VectData2.X += Delta;
}

function int GetDamageTakenInWave()
{
	return PWRI.VectData2.X;
}

function IncrementHealReceivedInWave(int Delta)
{
	PWRI.VectData2.Y += Delta;
}

function int GetHealReceivedInWave()
{
	return PWRI.VectData2.Y;
}

function IncrementHealGivenInWave(int Delta)
{
	PWRI.VectData2.Z += Delta;
}

function int GetHealGivenInWave()
{
	return PWRI.VectData2.Z;
}

function IncrementStompsGivenInWave(int Delta)
{
	PWRI.NumStomps += Delta;
}

function int GetStompsGivenInWave()
{
	return PWRI.NumStomps;
}

//Called at the end of the wave. @Note - End of wave is also called with the loss condition is met.  This includes at trader time.
function RecordWaveInfo()
{
	// If reset is pending, clear it now!
	if ( Outer.IsTimerActive(nameof(ResetLastWaveInfo), self) )
	{
		ResetLastWaveInfo();
	}

	TotalHeadShots			+= GetHeadShotsInWave();
	TotalDoshEarned 		+= GetDoshEarnedInWave();
	TotalAmountHealGiven 	+= GetHealGivenInWave();
    TotalAmountHealReceived	+= GetHealReceivedInWave();
    TotalDamageTaken 		+= GetDamageTakenInWave();
    TotalDamageDealt 		+= GetDamageDealtInWave();
	TotalStomps             += GetStompsGivenInWave();

    if ( PWRI.bDiedDuringWave )
    {
	   	DeathStreak++;
    	SurvivedStreak = 0;
    }
    else
    {
    	DeathStreak = 0;
    	SurvivedStreak++;
    }

    // After accumulating stats, clear back to zero for next wave.
    // Delayed long enough for replication to occur.
   	Outer.SetTimer(0.5f, false, nameof(ResetLastWaveInfo), self);
}

/** Clear PWRI, but doesn't cause it to replicate */
function ResetLastWaveInfo()
{
	PWRI.VectData1.X = 0;
	PWRI.VectData1.Y = 0;
	PWRI.VectData1.Z = 0;
	PWRI.VectData2.X = 0;
	PWRI.VectData2.Y = 0;
	PWRI.VectData2.Z = 0;
    PWRI.bKilledMostZeds = false;
    PWRI.bKilledFleshpoundLastWave = false;
    PWRI.bKilledScrakeLastWave = false;
    PWRI.ClassKilledByLastWave = none;
    PWRI.bAllSurvivedLastWave = false;
    PWRI.bSomeSurvivedLastWave = false;
    PWRI.bOneSurvivedLastWave = false;
    PWRI.bDiedDuringWave = false;
	PWRI.NumStomps = 0;
    ZedsKilledLastWave = 0;
}

function RecordPerkXPGain(class<KFPerk> PerkClass, int XPDelta, int BonusXP)
{
	local int index;
	local PerkXPGain TempPerkXPItem;

	index = PerkXPList.Find('PerkClass', PerkClass);

	if(index == INDEX_NONE)
	{
		TempPerkXPItem.PerkClass 			= PerkClass;

		TempPerkXPItem.StartLevel			= GetPerkLevelFromPerkList(PerkClass);
		TempPerkXPItem.StartXPPercentage	= GetPerkLevelProgressPercentage(PerkClass);
		TempPerkXPItem.XPDelta 				+= XPDelta;
		TempPerkXPItem.BonusXP				+= BonusXP;

		PerkXPList.AddItem(TempPerkXPItem);
	}
	else
	{
		PerkXPList[index].XPDelta += XPDelta;
		PerkXPList[index].BonusXP += BonusXP;
	}
}

function RecordSecondaryXPGain(class<KFPerk> PerkClass, int XPDelta)
{
	local int index;

	index = PerkXPList.Find('PerkClass', PerkClass);
	if( index != INDEX_NONE )
	{
		PerkXPList[index].SecondaryXPGain += XPDelta;
	}

}

function RecordZedKill(Class<Pawn> PawnClass, class<DamageType> DT)
{
	local int index;
	local ZedKillType TempZedKillType;
	local class<KFDamageType> KFDT;
	local class<KFPawn_Monster> MonsterClass;

	MonsterClass = Class<KFPawn_Monster>(PawnClass);

	KFDT = class<KFDamageType>(DT);
	if(KFDT != none)
	{
		//record the kill to the weapon here
		RecordWeaponKill(KFDT.default.WeaponDef);
	}

	if(MonsterClass != none)
	{
		if(MonsterClass.static.IsLargeZed())
		{
			TotalLargeZedKills++;
		}

		index = ZedKillsArray.Find('MonsterClass', MonsterClass);

		if(index == INDEX_NONE)
		{
			TempZedKillType.MonsterClass = MonsterClass;
			TempZedKillType.KillCount++;
			ZedKillsArray.AddItem(TempZedKillType);
		}
		else
		{
			ZedKillsArray[index].KillCount++;
		}
	}
}

static function RecordWeaponHeadShot(Controller InstigatedBy, class<DamageType> WeaponDamageType)
{
	local int WeaponIndex;
	local WeaponDamage TempWeaponDamage;
	local KFPlayerController KFPC;
	local Class<KFDamageType> KFDT;

	`log(nameof(RecordWeaponHeadShot), class'EphemeralMatchStats'.default.bShowMatchStatsLogging);

	KFPC = KFPlayerController(InstigatedBy);
	KFDT = class<KFDamageType>(WeaponDamageType);
	if(KFPC != none && KFPC.MatchStats != none)
	{
		`RecordAARIntStat(KFPC, HEADSHOT, 1);
		if(KFDT != none)
		{
			WeaponIndex = KFPC.MatchStats.WeaponDamageList.Find('WeaponDef', KFDT.default.WeaponDef);
			if(WeaponIndex == INDEX_NONE)
			{
				TempWeaponDamage.WeaponDef = KFDT.default.WeaponDef;
				TempWeaponDamage.HeadShots = 1;
				KFPC.MatchStats.WeaponDamageList.AddItem(TempWeaponDamage);
			}
			else
			{
				KFPC.MatchStats.WeaponDamageList[WeaponIndex].HeadShots++;
			}
		}
	}
}

static function RecordWeaponDamage(Controller InstigatedBy, class<KFDamageType> KFDT, class<KFWeaponDefinition> WeaponDef, int Damage, KFPawn TargetPawn, int HitZoneIdx)
{
	local KFPlayerController KFPC;

	if(InstigatedBy == none )
	{
		return;
	}

	KFPC = KFPlayerController(InstigatedBy);
	if(KFPC != none && KFPC.MatchStats != none)
	{
		KFPC.MatchStats.InternalRecordWeaponDamage(KFDT, WeaponDef, Damage, TargetPawn, HitZoneIdx);
	}
}

function RecordWeaponKill(class<KFWeaponDefinition> WeaponDef)
{
	local int WeaponIndex;
	local WeaponDamage TempWeaponDamage;

	WeaponIndex = WeaponDamageList.Find('WeaponDef', WeaponDef);
	if(WeaponIndex == INDEX_NONE)
	{
		TempWeaponDamage.WeaponDef = WeaponDef;
		TempWeaponDamage.Kills++;
		WeaponDamageList.AddItem(TempWeaponDamage);
	}
	else
	{
		WeaponDamageList[WeaponIndex].Kills++;
	}
}

/**
 * Record weapon damage
 * Network: Server
 */
function InternalRecordWeaponDamage(class<KFDamageType> KFDT, class<KFWeaponDefinition> WeaponDef, int Damage, KFPawn TargetPawn, int HitZoneIdx)
{
	local int WeaponIndex;
	local WeaponDamage TempWeaponDamage;
	local bool bLargeZedKill;
	local bool bKilled;
	local KFPlayerReplicationInfoVersus KFPRIV;

	if(Role != ROLE_Authority)
	{
		if( (TargetPawn.isA('KFPawn_Monster') && PlayerReplicationInfo.GetTeamNum() == 255) || (!TargetPawn.isA('KFPawn_Monster') && PlayerReplicationInfo.GetTeamNum() != 255) )
		return;
	}

	bKilled = TargetPawn.Health <= 0 && (TargetPawn.Health + Damage > 0);
	bLargeZedKill = bKilled && TargetPawn.IsLargeZed();

	WeaponIndex = WeaponDamageList.Find('WeaponDef', WeaponDef);
	// Set actual damage
	Damage = TargetPawn.Health > 0 ? Damage : TargetPawn.Health + Damage;

	if(Damage < 0)
	{
		Damage = 0;
		return;
	}

	// Player zed
	if( PlayerReplicationInfo.GetTeamNum() == 255 )
	{
		// Record actual damage
		RecordIntStat(MATCH_EVENT_DAMAGE_DEALT, Damage);

		KFPRIV = KFPlayerReplicationInfoVersus( PlayerReplicationInfo );

		// Record damage dealt on team
		KFPRIV.DamageDealtOnTeam += Damage;

		// Record indirect/aoe damage
		if( KFDT != none && KFDT.default.bConsideredIndirectOrAoE )
		{
			KFPRIV.IndirectDamageDealt += Damage;
		}
		return;
	}

	//survivor
	if(WeaponIndex == INDEX_NONE)
	{
		TempWeaponDamage.WeaponDef = WeaponDef;
		WeaponIndex= WeaponDamageList.Length;
		WeaponDamageList.AddItem(TempWeaponDamage);
	}

	if(WeaponDamageList[WeaponIndex].WeaponDef == WeaponDef)
	{
		// Record actual damage
		RecordIntStat(MATCH_EVENT_DAMAGE_DEALT, Damage);
		WeaponDamageList[WeaponIndex].DamageAmount += Damage;

		if(bLargeZedKill)
		{
			WeaponDamageList[WeaponIndex].LargeZedKills++;
		}
	}
}

/**
 * for sendig weapon stats to client
 * Network: Server
 */
function PackTopWeapons()
{
	local array<WeaponDamage> TopWeaponsArray;
	local int i;

	GetTopWeapons(3, TopWeaponsArray);
	for (i = 0; i < 3; i++)
	{
		if( i >= TopWeaponsArray.length )
		{
			return;
		}

		switch (i)
		{
			case 0:
				TWRI.TopWeapon1 = TopWeaponsArray[i].WeaponDef;

				TWRI.TopWeapon1Info.x = TopWeaponsArray[i].DamageAmount;
				TWRI.TopWeapon1Info.y = TopWeaponsArray[i].HeadShots;
				TWRI.TopWeapon1Info.z = TopWeaponsArray[i].LargeZedKills;
				break;

			case 1:
				TWRI.TopWeapon2 = TopWeaponsArray[i].WeaponDef;

				TWRI.TopWeapon2Info.x = TopWeaponsArray[i].DamageAmount;
				TWRI.TopWeapon2Info.y = TopWeaponsArray[i].HeadShots;
				TWRI.TopWeapon2Info.z = TopWeaponsArray[i].LargeZedKills;
				break;

			case 2:
				TWRI.TopWeapon3 = TopWeaponsArray[i].WeaponDef;

				TWRI.TopWeapon3Info.x = TopWeaponsArray[i].DamageAmount;
				TWRI.TopWeapon3Info.y = TopWeaponsArray[i].HeadShots;
				TWRI.TopWeapon3Info.z = TopWeaponsArray[i].LargeZedKills;
				break;
		}

	}
}

/**
 * for translating weapon stats from packed struct
 * Network: Local Player
 */
function UnpackTopWeapons(TopWeaponReplicationInfo TopWeapons)
{
	TWRI = TopWeapons;
	//We are a client so clear the top weapons
	if( TWRI.TopWeapon1 != none )
	{
		AddUnpackedWeaponToDamageList(TWRI.TopWeapon1, TWRI.TopWeapon1Info.x, TWRI.TopWeapon1Info.y, TWRI.TopWeapon1Info.z);
	}

	if( TWRI.TopWeapon2 != none )
	{
		AddUnpackedWeaponToDamageList(TWRI.TopWeapon2, TWRI.TopWeapon2Info.x, TWRI.TopWeapon2Info.y, TWRI.TopWeapon2Info.z);
	}

	if( TWRI.TopWeapon3 != none )
	{
		AddUnpackedWeaponToDamageList(TWRI.TopWeapon3, TWRI.TopWeapon3Info.x, TWRI.TopWeapon3Info.y, TWRI.TopWeapon3Info.z);
	}
}

function ProcessTopWeaponsStats()
{
	if( Role == ROLE_Authority )
	{
		//Update struct to make it replicate
		PackTopWeapons();
		ReceiveTopWeapons(TWRI);
	}
}

/**
 * Add the weapons replicated by sever to client's list
 * Network: Local Player
 */
function AddUnpackedWeaponToDamageList(class<KFWeaponDefinition> WeaponDef, int DamageAmount, int HeadShots, int LargeZedKills)
{
	local WeaponDamage TempWeaponDamage;
	local int WeaponIndex;

	WeaponIndex = WeaponDamageList.Find('WeaponDef', WeaponDef);
	if(WeaponIndex == INDEX_NONE)
	{
		TempWeaponDamage.DamageAmount = DamageAmount;
		TempWeaponDamage.HeadShots 		= HeadShots;
		TempWeaponDamage.LargeZedKills 	= LargeZedKills;

		WeaponDamageList.AddItem(TempWeaponDamage);
	}
	else
	{
		WeaponDamageList[WeaponIndex].WeaponDef 		= WeaponDef;
		WeaponDamageList[WeaponIndex].DamageAmount 		= DamageAmount;
		WeaponDamageList[WeaponIndex].HeadShots 		= HeadShots;
		WeaponDamageList[WeaponIndex].LargeZedKills 	= LargeZedKills;
	}

}

function GetTopWeapons(int AmountToGrab, out array<WeaponDamage> TopWeaponList)
{
	local int i;
	//Sort
	WeaponDamageList.Sort(SortWeapons);

	//Grab first 3 in list (Top 3)
	for (i = 0; i < WeaponDamageList.length; i++)
	{
		if(i < AmountToGrab)
		{
			if(WeaponDamageList[i].WeaponDef == None)
			{
				WeaponDamageList.Remove(i, 1);
				i -= 1;
			}
			else
			{
				TopWeaponList.AddItem(WeaponDamageList[i]);
			}
		}
	}
}


delegate int SortXP(PerkXPGain A, PerkXPGain B)
{
	return A.XPDelta < B.XPDelta ? -1 : 0;
}

delegate int SortWeapons(WeaponDamage A, WeaponDamage B)
{
	return A.DamageAmount < B.DamageAmount ? -1 : 0;
}

/**
 *
 * Network: Server Only
 */
static function ProcessPostGameStats()
{
	local int i,j;
	local Array<KFPlayerController> KFPCArray;
	local KFPlayerController KFPC;
	local WorldInfo WI;
	local AARAward TempAwardObject;

	WI = Class'WorldInfo'.Static.GetWorldInfo();

	foreach WI.AllControllers(class'KFPlayerController', KFPC)
	{
		if(KFPC != none)
		{
			KFPCArray.AddItem(KFPC);

			KFPC.MatchStats.ProcessTopWeaponsStats();
		}
	}

	for (i = 0; i < ETA_Max; i++)
	{
		GetTeamAward(ETeamAwards(i), TempAwardObject, KFPCArray);
		for (j = 0; j < KFPCArray.Length; j++)
		{
			KFPCArray[j].ClientReceiveAwardInfo(i, TempAwardObject.PRI, TempAwardObject.DisplayValue);
		}
		TempAwardObject.PRI = none;
		TempAwardObject.DisplayValue = 0;
	}
}

static function SendMapOptionsAndOpenAARMenu()
{
	local WorldInfo WI;
	local KFPlayerController KFPC;
	local KFPlayerReplicationInfo KFPRI;
	local KFGameInfo KFGI;
	local int i;
	local KFGameReplicationInfo KFGRI;

	WI = Class'WorldInfo'.Static.GetWorldInfo();

	KFGI = KFGameInfo(WI.Game);
	KFGRI = KFGameReplicationInfo(WI.GRI);

	foreach WI.AllControllers(class'KFPlayerController', KFPC)
	{
		if(WI.NetMode == NM_StandAlone)
		{
			//set map list in vote collector
			if(KFGRI != none && KFGRI.VoteCollector != none)
			{
				class'KFGfxMenu_StartGame'.static.GetMapList(KFGRI.VoteCollector.MapList);
				for (i = 0; i < KFGRI.VoteCollector.MapList.length; i++)
				{
					if (!KFGI.IsMapAllowedInCycle(KFGRI.VoteCollector.MapList[i]))
					{
						KFGRI.VoteCollector.MapList.Remove(i, 1);
						i--;
					}
				}
			}
		}
		else
		{
			KFPRI = KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo);
			for (i = 0; i < KFGI.GameMapCycles[KFGI.ActiveMapCycle].Maps.length; i++)
		    {
				if(KFPRI != none)
				{
					if (KFGI.IsMapAllowedInCycle(KFGI.GameMapCycles[KFGI.ActiveMapCycle].Maps[i]))
					{
						KFPRI.RecieveAARMapOption(KFGI.GameMapCycles[KFGI.ActiveMapCycle].Maps[i]);
					}
				}
			}
		}

		KFPC.ClientShowPostGameMenu();
	}
}

function GetPersonalBests(out Array<AARAward> PersonalBests)
{
	//Kills with a Knife
	PersonalBests.AddItem( GivePersonalBestKnifeKills() );
	//Kills with a Pistol
	PersonalBests.AddItem( GivePersonalBestPistolKills() );
	//Healing (derived from heals to others, only)
	PersonalBests.AddItem( GivePersonalBestHealing() );
	//Kills
	PersonalBests.AddItem( GivePersonalBestKills() );
	//Assists
	PersonalBests.AddItem( GivePersonalBestAssists() );
	//Large Zed Kills
	PersonalBests.AddItem( GivePersonalBestLargeZedKills() );
	//Dosh Earned
	PersonalBests.AddItem( GivePersonalBestDoshEarned() );
	//Headshots
	PersonalBests.AddItem( GivePersonalBestHeadShots() );
	// Stomps
	PersonalBests.AddItem( GivePersonalBestZedStomp() );

}

function int GetPistolKills()
{
	local int WeaponIndex;
	local int TotalPistolKills;

	// 9mm
	WeaponIndex = WeaponDamageList.Find('WeaponDef', class'KFWeapDef_9mm');
	if(WeaponIndex != INDEX_NONE)
	{
		TotalPistolKills += WeaponDamageList[WeaponIndex].Kills;
	}

	// Remington 1858
	WeaponIndex = WeaponDamageList.Find('WeaponDef', class'KFWeapDef_Remington1858');
	if(WeaponIndex != INDEX_NONE)
	{
		TotalPistolKills += WeaponDamageList[WeaponIndex].Kills;
	}

	// Colt 1911
	WeaponIndex = WeaponDamageList.Find('WeaponDef', class'KFWeapDef_Colt1911');
	if(WeaponIndex != INDEX_NONE)
	{
		TotalPistolKills += WeaponDamageList[WeaponIndex].Kills;
	}

	// Desert Eagle
	WeaponIndex = WeaponDamageList.Find('WeaponDef', class'KFWeapDef_Deagle');
	if(WeaponIndex != INDEX_NONE)
	{
		TotalPistolKills += WeaponDamageList[WeaponIndex].Kills;
	}

	// S&W .500 Magnum
	WeaponIndex = WeaponDamageList.Find('WeaponDef', class'KFWeapDef_SW500');
	if(WeaponIndex != INDEX_NONE)
	{
		TotalPistolKills += WeaponDamageList[WeaponIndex].Kills;
	}

	// Medic pistol
	WeaponIndex = WeaponDamageList.Find('WeaponDef', class'KFWeapDef_MedicPistol');
	if(WeaponIndex != INDEX_NONE)
	{
		TotalPistolKills += WeaponDamageList[WeaponIndex].Kills;
	}

	return TotalPistolKills;
}

function int GetKnifeKills()
{
	local int TotalKnifeKills, i;

	for (i = 0; i < WeaponDamageList.Length; i++)
	{
		if(WeaponDamageList[i].WeaponDef != none && class<KFweapDef_Knife_Base>(WeaponDamageList[i].WeaponDef) != none)
		{
			TotalKnifeKills += WeaponDamageList[i].Kills;
		}
	}

	return TotalKnifeKills;
}

//solo
function AARAward GivePersonalBestKnifeKills()
{
	local int Value,KnifeKills;
	Value = GetPersonalBest(EPB_KnifeKills);
	KnifeKills = GetKnifeKills();

	if(Value < KnifeKills)
	{
		PersonalBestList[EPB_KnifeKills].DisplayValue = KnifeKills;
		PersonalBestList[EPB_KnifeKills].bHighLight = true;

		SavePersonalBest(EPB_KnifeKills,KnifeKills);
	}
	else
	{
		PersonalBestList[EPB_KnifeKills].DisplayValue = Value;
	}

	return PersonalBestList[EPB_KnifeKills];
}

//solo
function AARAward GivePersonalBestPistolKills()
{
	local int Value, PistolKills;
	Value = GetPersonalBest(EPB_PistolKills);
	PistolKills = GetPistolKills();

	if(Value < PistolKills)
	{
		PersonalBestList[EPB_PistolKills].DisplayValue = PistolKills;
		PersonalBestList[EPB_PistolKills].bHighLight = true;

		SavePersonalBest(EPB_PistolKills,PistolKills);
	}
	else
	{
		PersonalBestList[EPB_PistolKills].DisplayValue = Value;
	}

	return PersonalBestList[EPB_PistolKills];
}


//solo/multiplayer
function AARAward GivePersonalBestHeadShots()
{
	local int Value;
	Value = GetPersonalBest(EPB_HeadShots);

	if(Value < TotalHeadShots)
	{
		PersonalBestList[EPB_HeadShots].DisplayValue = TotalHeadShots;
		PersonalBestList[EPB_HeadShots].bHighLight = true;

		SavePersonalBest(EPB_HeadShots,TotalHeadShots);
	}
	else
	{
		PersonalBestList[EPB_HeadShots].DisplayValue = Value;
	}

	return PersonalBestList[EPB_HeadShots];
}

//multiplayer
function AARAward GivePersonalBestHealing()
{
	local int Value;
	Value = GetPersonalBest(EPB_Healing);

	if(Value < TotalAmountHealGiven)
	{
		PersonalBestList[EPB_Healing].DisplayValue = TotalAmountHealGiven;
		PersonalBestList[EPB_Healing].bHighLight = true;

		SavePersonalBest(EPB_Healing,TotalAmountHealGiven);
	}
	else
	{
		PersonalBestList[EPB_Healing].DisplayValue = Value;
	}

	return PersonalBestList[EPB_Healing];
}

//multiplayer
function AARAward GivePersonalBestLargeZedKills()
{
	local int Value;
	Value = GetPersonalBest(EPB_LargeZedKill);

	if(Value < TotalLargeZedKills)
	{
		PersonalBestList[EPB_LargeZedKill].DisplayValue = TotalLargeZedKills;
		PersonalBestList[EPB_LargeZedKill].bHighLight = true;

		SavePersonalBest(EPB_LargeZedKill,TotalLargeZedKills);
	}
	else
	{
		PersonalBestList[EPB_LargeZedKill].DisplayValue = Value;
	}

	return PersonalBestList[EPB_LargeZedKill];
}

//multiplayer
function AARAward GivePersonalBestDoshEarned()
{
	local int Value;

	Value = GetPersonalBest(EPB_Dosh);

	if(Value < TotalDoshEarned)
	{
		PersonalBestList[EPB_Dosh].DisplayValue = TotalDoshEarned;
		PersonalBestList[EPB_Dosh].bHighLight = true;

		SavePersonalBest(EPB_Dosh,TotalDoshEarned);
	}
	else
	{
		PersonalBestList[EPB_Dosh].DisplayValue = Value;
	}

	return PersonalBestList[EPB_Dosh];
}

//multiplayer
function AARAward GivePersonalBestKills()
{
	local int Value;

	Value = GetPersonalBest(EPB_Kills);

	if(Value < PlayerReplicationInfo.Kills)
	{
		PersonalBestList[EPB_Kills].DisplayValue = PlayerReplicationInfo.Kills;
		PersonalBestList[EPB_Kills].bHighLight = true;

		SavePersonalBest(EPB_Kills,PlayerReplicationInfo.Kills);
	}
	else
	{
		PersonalBestList[EPB_Kills].DisplayValue = Value;
	}

	return PersonalBestList[EPB_Kills];
}

//multiplayer
function AARAward GivePersonalBestAssists()
{
	local int Value;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);

	Value = GetPersonalBest(EPB_Assists);

	if(Value < KFPRI.Assists)
	{
		PersonalBestList[EPB_Assists].DisplayValue = KFPRI.Assists;
		PersonalBestList[EPB_Assists].bHighLight = true;

		SavePersonalBest(EPB_Assists,KFPRI.Assists);
	}
	else
	{
		PersonalBestList[EPB_Assists].DisplayValue = Value;
	}

	return PersonalBestList[EPB_Assists];
}

//multiplayer
function AARAward GivePersonalBestDoorWelding()
{
	local int Value;

	Value = GetPersonalBest(EPB_DoorWelding);

	if(true)
	{
		PersonalBestList[EPB_DoorWelding].DisplayValue = Value;
		PersonalBestList[EPB_DoorWelding].bHighLight = true;

		SavePersonalBest(EPB_DoorWelding,Value);
	}
	else
	{
		PersonalBestList[EPB_DoorWelding].DisplayValue = Value;
	}

	return PersonalBestList[EPB_DoorWelding];
}

function AARAward GivePersonalBestZedStomp()
{
	local int Value;
	local KFPlayerReplicationInfo KFPRI;

	KFPRI = KFPlayerReplicationInfo(PlayerReplicationInfo);
	Value = GetPersonalBest(EPB_ZedStomps);

	if(Value < KFPRI.ZedStomps)
	{
		PersonalBestList[EPB_ZedStomps].DisplayValue = KFPRI.ZedStomps;
		PersonalBestList[EPB_ZedStomps].bHighLight   = true;

		SavePersonalBest(EPB_ZedStomps, KFPRI.ZedStomps);
	}
	else
	{
		PersonalBestList[EPB_ZedStomps].DisplayValue = Value;
	}

	return PersonalBestList[EPB_ZedStomps];
}

static function GetTeamAward(ETeamAwards AwardIndex, out AARAward TempAwardObject, const out Array<KFPlayerController> KFPCArray)
{
	switch (AwardIndex)
	{
		case ETA_MedicineMaster:
		`log("Attempting to get ETA_MedicineMaster", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_MedicineMaster(TempAwardObject, KFPCArray);
			break;
		case ETA_ZedSlayer:
		`log("Attempting to get ETA_ZedSlayer", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_ZedSlayer(TempAwardObject, KFPCArray);
			break;
		case ETA_Enforcer:
		`log("Attempting to get ETA_Enforcer", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_Enforcer(TempAwardObject, KFPCArray);
			break;
		case ETA_Destroyer:
		`log("Attempting to get ETA_Destroyer", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_Destroyer(TempAwardObject, KFPCArray);
			break;
		case ETA_GiantSlayer:
		`log("Attempting to get ETA_GiantSlayer", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_GiantSlayer(TempAwardObject, KFPCArray);
			break;
		case ETA_MoneyBags:
		`log("Attempting to get ETA_MoneyBags", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_MoneyBags(TempAwardObject, KFPCArray);
			break;
		case ETA_HeadPopper:
		`log("Attempting to get ETA_HeadPopper", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_HeadPopper(TempAwardObject, KFPCArray);
			break;
		case ETA_Dominator:
		`log("Attempting to get ETA_Dominator", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			Give_Dominator(TempAwardObject, KFPCArray);
			break;
		case ETA_Carnage:
			Give_Carnage(TempAwardObject, KFPCArray);
			break;
		case ETA_Closer:
			Give_Closer(TempAwardObject, KFPCArray);
			break;
		case ETA_ComboMaker:
			Give_Combo(TempAwardObject, KFPCArray);
				break;
		case ETA_Grabby:
			Give_Grabby(TempAwardObject, KFPCArray);
				break;
		case ETA_ZedSupport:
			Give_BestSupportingZed(TempAwardObject, KFPCArray);
				break;
		case ETA_Zednnihilation:
			Give_Zednnihilation(TempAwardObject, KFPCArray);
				break;
		case ETA_ZedStomper:
			Give_ZedStomper(TempAwardObject, KFPCArray);
			break;
		case ETA_WeaponMaster:
			GiveWeaponMaster(TempAwardObject, KFPCArray);
			break;
	}
}

/*=============================================================
	Zed AWARDS
==============================================================*/

//highest number of kills in anywave
static function Give_Zednnihilation (out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i, j, MyHighestWaveKillValue;
	local KFPlayerReplicationInfoVersus KPRIV;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KPRIV = KFPlayerReplicationInfoVersus(KFPCArray[i].PlayerReplicationInfo);

		if(KPRIV != none)
		{
			for (j = 0; j < KPRIV.WaveKills.length; j++)
			{
				if(KPRIV.WaveKills[j] > MyHighestWaveKillValue)
				{
					MyHighestWaveKillValue = KPRIV.WaveKills[j];
				}
			}
			if(MyHighestWaveKillValue > outAward.DisplayValue)
			{
				outAward.PRI = KPRIV;
				outAward.DisplayValue = MyHighestWaveKillValue;
			}
		}
	}
}

//most most grabs
static function Give_Grabby(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	local KFPlayerReplicationInfoVersus KPRIV;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KPRIV = KFPlayerReplicationInfoVersus(KFPCArray[i].PlayerReplicationInfo);

		if(KPRIV != none)
		{
			if(KPRIV.ZedGrabs > outAward.DisplayValue)
			{
				outAward.PRI = KPRIV;
				outAward.DisplayValue = KPRIV.ZedGrabs;
			}
		}
	}
}

//best supporting zed
static function Give_BestSupportingZed(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	local KFPlayerReplicationInfoVersus KPRIV;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KPRIV = KFPlayerReplicationInfoVersus(KFPCArray[i].PlayerReplicationInfo);

		if(KPRIV != none)
		{
			if(KPRIV.IndirectDamageDealt > outAward.DisplayValue)
			{
				outAward.PRI = KPRIV;
				outAward.DisplayValue = KPRIV.IndirectDamageDealt;
			}
		}
	}
}

//most Most damgage done
static function Give_Carnage(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	local KFPlayerReplicationInfoVersus KPRIV;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KPRIV = KFPlayerReplicationInfoVersus(KFPCArray[i].PlayerReplicationInfo);

		if(KPRIV != none)
		{
			if(KPRIV.DamageDealtOnTeam > outAward.DisplayValue)
			{
				outAward.PRI = KPRIV;
				outAward.DisplayValue = KPRIV.DamageDealtOnTeam;
			}
		}
	}
}

//most assits
static function Give_Combo(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	local KFPlayerReplicationInfoVersus KPRIV;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KPRIV = KFPlayerReplicationInfoVersus(KFPCArray[i].PlayerReplicationInfo);

		if(KPRIV != none)
		{
			if(KPRIV.AssistsAsZed > outAward.DisplayValue)
			{
				outAward.PRI = KPRIV;
				outAward.DisplayValue = KPRIV.AssistsAsZed;
			}
		}
	}
}

//most kills
static function Give_Closer(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	local KFPlayerReplicationInfoVersus KPRIV;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KPRIV = KFPlayerReplicationInfoVersus(KFPCArray[i].PlayerReplicationInfo);

		if(KPRIV != none)
		{
			if(KPRIV.KillsAsZed > outAward.DisplayValue)
			{
				outAward.PRI = KPRIV;
				outAward.DisplayValue = KPRIV.KillsAsZed;
			}
		}
	}
}


/*=============================================================
	Survivor AWARDS
==============================================================*/

//most healing
static function Give_MedicineMaster(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		if(KFPCArray[i].MatchStats != none)
		{
			if(KFPCArray[i].MatchStats.TotalAmountHealGiven > outAward.DisplayValue)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = KFPCArray[i].MatchStats.TotalAmountHealGiven;
				//Gives away award
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPCArray[i].MatchStats.TotalAmountHealGiven, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			}
		}
	}
}

//most zed kills
static function Give_ZedSlayer(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local KFPlayerReplicationInfo KFPRI;
	local int i;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KFPRI = KFPlayerReplicationInfo(KFPCArray[i].PlayerReplicationInfo);
		if(KFPRI.Kills > outAward.DisplayValue)
		{
			outAward.PRI = KFPRI;
			outAward.DisplayValue = KFPRI.Kills;
			`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPRI.Kills, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
		}
	}
}

//most assists
static function Give_Enforcer(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local KFplayerReplicationInfo KFPRI;
	local int i;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		KFPRI = KFPlayerReplicationInfo(KFPCArray[i].PlayerReplicationInfo);
		if(KFPRI.Assists > outAward.DisplayValue)
		{
			outAward.PRI = KFPRI;
			outAward.DisplayValue = KFPRI.Assists;
			`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPRI.Assists, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
		}
	}
}

//most damage
static function Give_Destroyer(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		if(KFPCArray[i].MatchStats != none)
		{
			if(KFPCArray[i].MatchStats.TotalDamageDealt > outAward.DisplayValue)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = KFPCArray[i].MatchStats.TotalDamageDealt;
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPCArray[i].MatchStats.TotalDamageDealt, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			}
		}
	}
}

//most large zed kills
static function Give_GiantSlayer(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		if(KFPCArray[i].MatchStats != none)
		{
			if(KFPCArray[i].MatchStats.TotalLargeZedKills > outAward.DisplayValue)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = KFPCArray[i].MatchStats.TotalLargeZedKills;
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPCArray[i].MatchStats.TotalLargeZedKills, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			}
		}
	}
}

//most dosh earned
static function Give_MoneyBags(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		if(KFPCArray[i].MatchStats != none)
		{
			if(KFPCArray[i].MatchStats.TotalDoshEarned > outAward.DisplayValue)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = KFPCArray[i].MatchStats.TotalDoshEarned;
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPCArray[i].MatchStats.TotalDoshEarned, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			}
		}
	}
}

//most head shots
static function Give_HeadPopper(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;

	For(i = 0; i < KFPCArray.Length; i++)
	{
		if(KFPCArray[i].MatchStats != none)
		{
			if(KFPCArray[i].MatchStats.TotalHeadShots > outAward.DisplayValue)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = KFPCArray[i].MatchStats.TotalHeadShots;
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPCArray[i].MatchStats.TotalHeadShots, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			}
		}
	}
}

//Final hit on boss
static function Give_Dominator(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	For(i = 0; i < KFPCArray.Length; i++)
	{
		if(KFPCArray[i].MatchStats != none)
		{
			if(KFPCArray[i].MatchStats.bKilledBoss)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = 1;
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @"Killed boss", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
				return;
			}
		}
	}
}

static function Give_ZedStomper(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	for(i = 0; i < KFPCArray.Length; i++)
	{
		if(KFPCArray[i].MatchStats != none)
		{
			if(KFPCArray[i].MatchStats.TotalStomps > outAward.DisplayValue)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = KFPCArray[i].MatchStats.TotalStomps;
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @KFPCArray[i].MatchStats.TotalStomps, class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
			}
		}
	}
}

static function GiveWeaponMaster(out AARAward outAward, const out Array<KFPlayerController> KFPCArray)
{
	local int i;
	local KFPlayerController_WeeklySurvival KFPC_WS;

	for(i = 0; i < KFPCArray.Length; i++)
	{
		KFPC_WS = KFPlayerController_WeeklySurvival(KFPCArray[i]);
		if (KFPC_WS != none)
		{
			if (KFPC_WS.GunGameData.GiveWeaponMaster)
			{
				outAward.PRI = KFPCArray[i].PlayerReplicationInfo;
				outAward.DisplayValue = 1;
				`log(KFPCArray[i].PlayerReplicationInfo.PlayerName @"Weapon Master", class'EphemeralMatchStats'.default.bShowMatchStatsLogging);
				return;
			}
		}
	}
}

function ReceiveAwardInfo(byte AwardID, PlayerReplicationInfo PRI, int Value)
{
	TeamAwardList[AwardID].PRI = PRI;
	TeamAwardList[AwardID].DisplayValue = Value;
}

DefaultProperties
{
	bShowMatchStatsLogging=false

	TeamAwardList(ETA_MedicineMaster)=(TitleIdentifier="MedicineMaster",ValueIdentifier="MedicineMasterValue",IconPath="UI_Award_Team.UI_Award_Team-Healing")
	TeamAwardList(ETA_ZedSlayer)=(TitleIdentifier="ZedSlayer",ValueIdentifier="ZedSlayerValue",IconPath="UI_Award_Team.UI_Award_Team-Kills")
	TeamAwardList(ETA_Enforcer)=(TitleIdentifier="Enforcer",ValueIdentifier="EnforcerValue",IconPath="UI_Award_Team.UI_Award_Team-Assists")
	TeamAwardList(ETA_Destroyer)=(TitleIdentifier="Destroyer",ValueIdentifier="DestroyerValue",IconPath="UI_Award_Team.UI_Award_Team-Damage")
	TeamAwardList(ETA_GiantSlayer)=(TitleIdentifier="GiantSlayer",ValueIdentifier="GiantSlayerValue",IconPath="UI_Award_Team.UI_Award_Team-Giants")
	TeamAwardList(ETA_MoneyBags)=(TitleIdentifier="MoneyBags",ValueIdentifier="MoneyBagsValue",IconPath="UI_Award_Team.UI_Award_Team-Dosh")
	TeamAwardList(ETA_HeadPopper)=(TitleIdentifier="HeadPopper",ValueIdentifier="HeadPopperValue",IconPath="UI_Award_Team.UI_Award_Team-Headshots")
	TeamAwardList(ETA_Dominator)=(TitleIdentifier="Dominator",ValueIdentifier="DominatorValue",IconPath="UI_Award_Team.UI_Award_Team-BossKO")
	TeamAwardList(ETA_ZedStomper)=(TitleIdentifier="ZedStomper",ValueIdentifier="ZedStomperValue",IconPath="UI_Award_Team.UI_Award_Team-ZedStomper")
	TeamAwardList(ETA_WeaponMaster)=(TitleIdentifier="WeaponMaster",ValueIdentifier="WeaponMasterValue",IconPath="UI_Award_Team.UI_Award_Team_GunMode")
	//zed awards
	TeamAwardList(ETA_Carnage)=(TitleIdentifier="Carnage",ValueIdentifier="CarnageValue",IconPath="ui_award_zeds.UI_Award_ZED_RawDmg")
	TeamAwardList(ETA_Closer)=(TitleIdentifier="Closer",ValueIdentifier="CloserValue",IconPath="ui_award_zeds.UI_Award_ZED_Kills")
	TeamAwardList(ETA_ComboMaker)=(TitleIdentifier="ComboMaker",ValueIdentifier="ComboMakerValue",IconPath="ui_award_zeds.UI_Award_ZED_Assists")
	TeamAwardList(ETA_Grabby)=(TitleIdentifier="Grabby",ValueIdentifier="GrabbyValue",IconPath="ui_award_zeds.UI_Award_ZED_CC")
	TeamAwardList(ETA_ZedSupport)=(TitleIdentifier="ZedSupport",ValueIdentifier="ZedSupportValue",IconPath="ui_award_zeds.UI_Award_ZED_SupportAoE")
	TeamAwardList(ETA_Zednnihilation)=(TitleIdentifier="Zednnihilation",ValueIdentifier="ZednnihilationValue",IconPath="ui_award_zeds.UI_Award_ZED_MostKills")

	PersonalBestList(EPB_Healing)=(TitleIdentifier="EPB_Healing",ValueIdentifier="EPB_HealingValue",IconPath="UI_Award_PersonalMulti.UI_Award_PersonalMulti-Healing")
	PersonalBestList(EPB_Kills)=(TitleIdentifier="EPB_Kills",ValueIdentifier="EPB_KillsValue",IconPath="UI_Award_PersonalMulti.UI_Award_PersonalMulti-Kills")
	PersonalBestList(EPB_Assists)=(TitleIdentifier="EPB_Assists",ValueIdentifier="EPB_AssistsValue",IconPath="UI_Award_PersonalMulti.UI_Award_PersonalMulti-Assists")
	PersonalBestList(EPB_LargeZedKill)=(TitleIdentifier="EPB_LargeZedKill",ValueIdentifier="EPB_LargeZedKillValue",IconPath="UI_Award_PersonalMulti.UI_Award_PersonalMulti-Giants")
	PersonalBestList(EPB_Dosh)=(TitleIdentifier="EPB_Dosh",ValueIdentifier="EPB_DoshValue",IconPath="UI_Award_PersonalMulti.UI_Award_PersonalMulti-Dosh")
	PersonalBestList(EPB_HeadShots)=(TitleIdentifier="EPB_HeadShots",ValueIdentifier="EPB_HeadShotsValue",IconPath="UI_Award_PersonalMulti.UI_Award_PersonalMulti-Headshots")
	PersonalBestList(EPB_KnifeKills)=(TitleIdentifier="EPB_KnifeKills",ValueIdentifier="EPB_KnifeKillsValue",IconPath="UI_Award_PersonalSolo.UI_Award_PersonalSolo-Knife")
	PersonalBestList(EPB_PistolKills)=(TitleIdentifier="EPB_PistolKills",ValueIdentifier="EPB_PistolKillsValue",IconPath="UI_Award_PersonalSolo.UI_Award_PersonalSolo-Pistol")
	PersonalBestList(EPB_DoorWelding)=(TitleIdentifier="EPB_DoorWelding",ValueIdentifier="EPB_DoorWeldingValue",IconPath="ui_weaponselect_tex.UI_WeaponSelect_Welder")
	PersonalBestList(EPB_ZedStomps)=(TitleIdentifier="EPB_ZedStomps",ValueIdentifier="EPB_ZedStompsValue",IconPath="UI_Award_PersonalSolo.UI_Award_PersonalSolo-ZedStomper")
}