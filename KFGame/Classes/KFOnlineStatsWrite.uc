//=============================================================================
// KFOnlineStatsWrite
//=============================================================================
// The KF2 game stats writer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Joshua Rowan 3/4/2014
//=============================================================================

class KFOnlineStatsWrite extends OnlineStatsWrite
	native
	config(game);

`include(KFOnlineStats.uci)
`include(KFGame\KFMatchStats.uci);

const	WeldingPointsRequired = 510;
const	HealingPointsRequired = 10;
const 	MaxPerkLevel = `MAX_PERK_LEVEL;
const 	MaxPrestigeLevel = `MAX_PRESTIGE_LEVEL;

//Event consts
const   SpecialEventObjectiveCountMax = 8;

/** Cached PC */
var KFPlayerController MyKFPC;

/** Cached general stats */
var	private	int		Kills;
var private	int 	StalkerKills;
var private	int 	CrawlerKills;
var private	int 	FleshPoundKills;
var private int 	WeldingPoints;
var private int 	HealingPoints;

/** Cached perk XP and build stats */
var private int 	CommandoXP, CommandoLVL, CommandoPSG;
var private int 	CommandoBuild;
var private int 	BerserkerXP, BerserkerLVL, BerserkerPSG;
var private int 	BerserkerBuild;
var private int 	SupportXP, SupportLVL, SupportPSG;
var private int 	SupportBuild;
var private	int 	MedicXP, MedicLVL, MedicPSG;
var private	int 	MedicBuild;
var private	int 	FirebugXP, FirebugLVL, FirebugPSG;
var private	int 	FirebugBuild;
var private	int 	DemoXP, DemoLVL, DemoPSG;
var private	int 	DemoBuild;
var private	int 	GunslingerXP, GunslingerLVL, GunslingerPSG;
var private	int 	GunslingerBuild;
var private	int 	SharpshooterXP, SharpshooterLVL, SharpshooterPSG;
var private	int 	SharpshooterBuild;
var private	int 	SwatXP, SwatLVL, SwatPSG;
var private	int 	SwatBuild;
var private	int 	SurvXP, SurvLVL, SurvPSG;
var private	int 	SurvBuild;

// XP is calculated as a float but stored as an integer, so we need to keep track of the remainders
// and award them as integers so the player gets his full XP amount
// Keep size in-sync with size of KFPlayerController::PerkList
var private float	BonusXPRemainder[10];

var private int 	PersonalBest_KnifeKills;
var private int 	PersonalBest_PistolKills;
var private int 	PersonalBest_HeadShots;
var private int 	PersonalBest_Healing;
var private int 	PersonalBest_Kills;
var private int 	PersonalBest_Assists;
var private int 	PersonalBest_LargeZedKil;
var private int 	PersonalBest_Dosh;

/** Cached Event Stats */
//Seasonal event tracking
var private int     SpecialEventInfo;
var private int     InitialSpecialEventInfo;

//Weekly Outbreak tracking
var private int     WeeklyEventInfo;
var private int     InitialWeeklyEventInfo;

//Daily event completion/date tracking
var private int     DailyEventInfo;
//Whether or not to ignore reading of other daily event stats.  Allows for clearing of data if stats come in out of order.
var private bool    bIgnoreDailyStatReads;
//Selected IDs that the user is completing for their daily events
var private int     DailyEventIDs;
//Bit fields holding the persistent current stat for each daily objective.  Reserving 16 bit per objective
var private int     DailyEventStats1;
var private int     DailyEventStats2;

var private int		SpecialEventKills_DEPRECATED;
var private int		SeasonalEventStats1, SeasonalEventStatsMax1;
var private int		SeasonalEventStats2, SeasonalEventStatsMax2;
var private int		SeasonalEventStats3, SeasonalEventStatsMax3;
var private int		SeasonalEventStats4, SeasonalEventStatsMax4;
var private int		SeasonalEventStats5, SeasonalEventStatsMax5;

/** Achievement IDs **/
// ids must be sequential (no gaps)
const KFACHID_ParisNormal						=	0;
const KFACHID_ParisHard 						=	1;
const KFACHID_ParisSuicidal						=	2;
const KFACHID_ParisHellOnEarth					=	3;
const KFACHID_OutpostNormal 					=	4;
const KFACHID_OutpostHard						=	5;
const KFACHID_OutpostSuicidal					=	6;
const KFACHID_OutpostHellOnEarth				=	7;
const KFACHID_BioticsNormal 					=	8;
const KFACHID_BioticsHard  						=	9;
const KFACHID_BioticsSuicidal					=	10;
const KFACHID_BioticsHellOnEarth				=	11;
const KFACHID_ManorNormal	 					=	12;
const KFACHID_ManorHard  						=	13;
const KFACHID_ManorSuicidal						=	14;
const KFACHID_ManorHellOnEarth					=	15;

const KFACHID_ParisCollectibles					= 	16;
const KFACHID_OutpostCollectibles				= 	17;
const KFACHID_BioticsCollectibles				= 	18;
const KFACHID_ManorCollectibles					= 	19;

const KFACHID_EvacNormal 						=	20;
const KFACHID_EvacHard  						=	21;
const KFACHID_EvacSuicidal						=	22;
const KFACHID_EvacHellOnEarth					=	23;
const KFACHID_CatacombsNormal	 				=	24;
const KFACHID_CatacombsHard  					=	25;
const KFACHID_CatacombsSuicidal					=	26;
const KFACHID_CatacombsHellOnEarth				=	27;

const KFACHID_EvacsCollectibles					= 	28;
const KFACHID_CatacombsCollectibles				= 	29;

const KFACHID_Berserker_Lvl5					= 	30;
const KFACHID_Berserker_Lvl10					= 	31;
const KFACHID_Berserker_Lvl15					= 	32;
const KFACHID_Berserker_Lvl20					= 	33;
const KFACHID_Berserker_Lvl25					= 	34;
const KFACHID_FieldMedic_Lvl5					= 	35;
const KFACHID_FieldMedic_Lvl10					= 	36;
const KFACHID_FieldMedic_Lvl15					= 	37;
const KFACHID_FieldMedic_Lvl20					= 	38;
const KFACHID_FieldMedic_Lvl25					= 	39;
const KFACHID_Commando_Lvl5						= 	40;
const KFACHID_Commando_Lvl10					= 	41;
const KFACHID_Commando_Lvl15					= 	42;
const KFACHID_Commando_Lvl20					= 	43;
const KFACHID_Commando_Lvl25					= 	44;
const KFACHID_Support_Lvl5						= 	45;
const KFACHID_Support_Lvl10						= 	46;
const KFACHID_Support_Lvl15						= 	47;
const KFACHID_Support_Lvl20						= 	48;
const KFACHID_Support_Lvl25						= 	49;
const KFACHID_Firebug_Lvl5						= 	50;
const KFACHID_Firebug_Lvl10						= 	51;
const KFACHID_Firebug_Lvl15						= 	52;
const KFACHID_Firebug_Lvl20						= 	53;
const KFACHID_Firebug_Lvl25						= 	54;
const KFACHID_Demolitionist_Lvl5				= 	55;
const KFACHID_Demolitionist_Lvl10				= 	56;
const KFACHID_Demolitionist_Lvl15				= 	57;
const KFACHID_Demolitionist_Lvl20				= 	58;
const KFACHID_Demolitionist_Lvl25				= 	59;
const KFACHID_Gunslinger_Lvl5					= 	60;
const KFACHID_Gunslinger_Lvl10					= 	61;
const KFACHID_Gunslinger_Lvl15					= 	62;
const KFACHID_Gunslinger_Lvl20					= 	63;
const KFACHID_Gunslinger_Lvl25					= 	64;

const KFACHID_BerserkerNormal					=	65;
const KFACHID_BerserkerHard						=	66;
const KFACHID_BerserkerSuicidal					=	67;
const KFACHID_BerserkerHellOnEarth				=	68;
const KFACHID_FieldMedicNormal					=	69;
const KFACHID_FieldMedicHard					=	70;
const KFACHID_FieldMedicSuicidal				=	71;
const KFACHID_FieldMedicHellOnEarth				=	72;
const KFACHID_CommandoNormal					=	73;
const KFACHID_CommandoHard						=	74;
const KFACHID_CommandoSuicidal					=	75;
const KFACHID_CommandoHellOnEarth				=	76;
const KFACHID_SupportNormal						=	77;
const KFACHID_SupportHard						=	78;
const KFACHID_SupportSuicidal					=	79;
const KFACHID_SupportHellOnEarth				=	80;
const KFACHID_FirebugNormal						=	81;
const KFACHID_FirebugHard						=	82;
const KFACHID_FirebugSuicidal					=	83;
const KFACHID_FirebugHellOnEarth				=	84;
const KFACHID_DemolitionistNormal				=	85;
const KFACHID_DemolitionistHard					=	86;
const KFACHID_DemolitionistSuicidal				=	87;
const KFACHID_DemolitionistHellOnEarth			=	88;
const KFACHID_GunslingerNormal					=	89;
const KFACHID_GunslingerHard					=	90;
const KFACHID_GunslingerSuicidal				=	91;
const KFACHID_GunslingerHellOnEarth				=	92;

const KFACHID_All_Lvl25							=	93;

const KFACHID_BlackForestNormal	 				=	94;
const KFACHID_BlackForestHard  					=	95;
const KFACHID_BlackForestSuicidal				=	96;
const KFACHID_BlackForestHellOnEarth			=	97;
const KFACHID_BlackForestCollectibles			= 	98;

const KFACHID_FarmhouseNormal	 				=	99;
const KFACHID_FarmhouseHard  					=	100;
const KFACHID_FarmhouseSuicidal					=	101;
const KFACHID_FarmhouseHellOnEarth				=	102;
const KFACHID_FarmhouseCollectibles				= 	103;

const KFACHID_PrisonNormal	 					=	104;
const KFACHID_PrisonHard  						=	105;
const KFACHID_PrisonSuicidal					=	106;
const KFACHID_PrisonHellOnEarth					=	107;
const KFACHID_PrisonCollectibles				= 	108;

const KFACHID_TutorialComplete					=	109;

const KFACHID_Sharpshooter_Lvl5					= 	110;
const KFACHID_Sharpshooter_Lvl10				= 	111;
const KFACHID_Sharpshooter_Lvl15				= 	112;
const KFACHID_Sharpshooter_Lvl20				= 	113;
const KFACHID_Sharpshooter_Lvl25				= 	114;

const KFACHID_SharpshooterNormal				=	115;
const KFACHID_SharpshooterHard					=	116;
const KFACHID_SharpshooterSuicidal				=	117;
const KFACHID_SharpshooterHellOnEarth			=	118;

const KFACHID_ContainmentStationNormal			=	119;
const KFACHID_ContainmentStationHard			=	120;
const KFACHID_ContainmentStationSuicidal		=	121;
const KFACHID_ContainmentStationHellOnEarth		=	122;
const KFACHID_ContainmentStationCollectibles	= 	123;

const KFACHID_HostileGroundsNormal				=	124;
const KFACHID_HostileGroundsHard				=	125;
const KFACHID_HostileGroundsSuicidal			=	126;
const KFACHID_HostileGroundsHellOnEarth			=	127;
const KFACHID_HostileGroundsCollectibles		= 	128;

const KFACHID_DeadSilence						= 	129;
const KFACHID_QuickOnTheTrigger					= 	130;
const KFACHID_ItsOnlyAFleshWound				= 	131;
const KFACHID_HackAndSlash						= 	132;
const KFACHID_DieVolter							= 	133;
const KFACHID_WinHard							= 	134;
const KFACHID_WinSuicidal						= 	135;
const KFACHID_WinHellOnEarth					=	136;
const KFACHID_MrPerky5							=	137;
const KFACHID_MrPerky10							=	138;
const KFACHID_MrPerky15							=	139;
const KFACHID_MrPerky20							=	140;
const KFACHID_MrPerky25							=	141;
const KFACHID_Win1								=	142;
const KFACHID_Win10								=	143;
const KFACHID_Win25								=	144;
const KFACHID_VsZedWin							=	145;
const KFACHID_VsHumanWin						=	146;
const KFACHID_HoldOut							=	147;
const KFACHID_IGotYourBack						=	148;
const KFACHID_Benefactor						=	149;

const KFACHID_InfernalRealmNormal				=	150;
const KFACHID_InfernalRealmHard					=	151;
const KFACHID_InfernalRealmSuicidal				=	152;
const KFACHID_InfernalRealmHellOnEarth			=	153;
const KFACHID_InfernalRealmCollectibles			= 	154;

const KFACHID_SWAT_Lvl5							= 	155;
const KFACHID_SWAT_Lvl10						= 	156;
const KFACHID_SWAT_Lvl15						= 	157;
const KFACHID_SWAT_Lvl20						= 	158;
const KFACHID_SWAT_Lvl25						= 	159;

const KFACHID_SWATNormal						=	160;
const KFACHID_SWATHard							=	161;
const KFACHID_SWATSuicidal						=	162;
const KFACHID_SWATHellOnEarth					=	163;

const KFACHID_Surv_Lvl5							= 	164;
const KFACHID_Surv_Lvl10						= 	165;
const KFACHID_Surv_Lvl15						= 	166;
const KFACHID_Surv_Lvl20						= 	167;
const KFACHID_Surv_Lvl25						= 	168;

const KFACHID_SurvNormal						=	169;
const KFACHID_SurvHard							=	170;
const KFACHID_SurvSuicidal						=	171;
const KFACHID_SurvHellOnEarth					=	172;

const KFACHID_ZedLandingNormal					=	173;
const KFACHID_ZedLandingHard					=	174;
const KFACHID_ZedLandingSuicidal				=	175;
const KFACHID_ZedLandingHellOnEarth				=	176;
const KFACHID_ZedLandingCollectibles			= 	177;

const KFACHID_DescentNormal						=	178;
const KFACHID_DescentHard						=	179;
const KFACHID_DescentSuicidal					=	180;
const KFACHID_DescentHellOnEarth				=	181;
const KFACHID_DescentCollectibles				= 	182;

const KFACHID_NukedNormal						=	183;
const KFACHID_NukedHard							=	184;
const KFACHID_NukedSuicidal						=	185;
const KFACHID_NukedHellOnEarth					=	186;
const KFACHID_NukedCollectibles					= 	187;

const KFACHID_TragicKingdomNormal               =   188;
const KFACHID_TragicKingdomHard                 =   189;
const KFACHID_TragicKingdomSuicidal             =   190;
const KFACHID_TragicKingdomHellOnEarth          =   191;
const KFACHID_TragicKingdomCollectibles         =   192;

const KFACHID_NightmareNormal					=   193;
const KFACHID_NightmareHard						=   194;
const KFACHID_NightmareSuicidal					=   195;
const KFACHID_NightmareHellOnEarth				=   196;
const KFACHID_NightmareCollectibles				=   197;

const KFACHID_KrampusNormal						=   198;
const KFACHID_KrampusHard						=   199;
const KFACHID_KrampusSuicidal					=   200;
const KFACHID_KrampusHellOnEarth				=   201;
const KFACHID_KrampusCollectibles				=   202;

const KFACHID_ArenaNormal						=   203;
const KFACHID_ArenaHard							=   204;
const KFACHID_ArenaSuicidal						=   205;
const KFACHID_ArenaHellOnEarth					=   206;
const KFACHID_ArenaCollectibles					=   207;

const KFACHID_PowercoreNormal					=   208;
const KFACHID_PowercoreHard						=   209;
const KFACHID_PowercoreSuicidal					=   210;
const KFACHID_PowercoreHellOnEarth				=   211;
const KFACHID_PowercoreCollectibles				=   212;

const KFACHID_AirshipNormal						=	213;
const KFACHID_AirshipHard						=	214;
const KFACHID_AirshipSuicidal					=	215;
const KFACHID_AirshipHellOnEarth				=	216;
const KFACHID_AirshipCollectibles				=	217;

const KFACHID_LockdownNormal					=	218;
const KFACHID_LockdownHard						=	219;
const KFACHID_LockdownSuicidal					=	220;
const KFACHID_LockdownHellOnEarth				=	221;
const KFACHID_LockdownCollectibles				=	222;

const KFACHID_MonsterBallNormal					=	223;
const KFACHID_MonsterBallHard					=	224;
const KFACHID_MonsterBallSuicidal				=	225;
const KFACHID_MonsterBallHellOnEarth			=	226;
const KFACHID_MonsterBallCollectibles			=	227;
const KFACHID_MonsterBallSecretRoom				=	228;

const KFACHID_SantasWorkshopNormal				=	229;
const KFACHID_SantasWorkshopHard				=	230;
const KFACHID_SantasWorkshopSuicidal			=	231;
const KFACHID_SantasWorkshopHellOnEarth			=	232;
const KFACHID_SantasWorkshopCollectibles		=	233;

const KFACHID_ShoppingSpreeNormal				=	234;
const KFACHID_ShoppingSpreeHard					=	235;
const KFACHID_ShoppingSpreeSuicidal				=	236;
const KFACHID_ShoppingSpreeHellOnEarth			=	237;
const KFACHID_ShoppingSpreeCollectibles			=	238;

const KFACHID_SpillwayNormal					=	239;
const KFACHID_SpillwayHard					    =   240;
const KFACHID_SpillwaySuicidal					=   241;
const KFACHID_SpillwayHellOnEarth				=   242;
const KFACHID_SpillwayCollectibles				=   243;

const KFACHID_SteamFortressObjectiveNormal		=	244;
const KFACHID_SteamFortressObjectiveHard		=	245;
const KFACHID_SteamFortressObjectiveSuicidal	=	246;
const KFACHID_SteamFortressObjectiveHellOnEarth	=	247;
const KFACHID_SteamFortressCollectibles			=	248;

const KFACHID_ZedLandingObjectiveNormal			=	249;
const KFACHID_ZedLandingObjectiveHard			=	250;
const KFACHID_ZedLandingObjectiveSuicidal		=	251;
const KFACHID_ZedLandingObjectiveHellOnEarth	=	252;

const KFACHID_OutpostObjectiveNormal			=	253;
const KFACHID_OutpostObjectiveHard				=	254;
const KFACHID_OutpostObjectiveSuicidal			=	255;
const KFACHID_OutpostObjectiveHellOnEarth		=	256;

const KFACHID_AsylumHard						=	257;
const KFACHID_AsylumHellOnEarth					=	258;
const KFACHID_AsylumCollectibles				=	259;

const KFACHID_NukedObjectiveHard				=	260;
const KFACHID_NukedObjectiveHellOnEarth			=	261;

const KFACHID_BioticsLabObjectiveHard			=	262;
const KFACHID_BioticsLabObjectiveHellOnEarth	=	263;

const KFACHID_SanitariumHard					=	264;
const KFACHID_SanitariumHellOnEarth				=	265;
const KFACHID_SanitariumCollectibles			=	266;

const KFACHID_DefeatMatriarch					=	267;

const KFACHID_BiolapseHard						=	268;
const KFACHID_BiolapseHellOnEarth				=	269;
const KFACHID_BiolapseCollectibles				=	270;

const KFACHID_DesolationHard					=	271;
const KFACHID_DesolationHellOnEarth				=	272;
const KFACHID_DesolationCollectibles			=	273;

const KFACHID_HellmarkStationHard				=	274;
const KFACHID_HellmarkStationHellOnEarth		=	275;
const KFACHID_HellmarkStationCollectibles		=	276;

const KFACHID_ElysiumHard						=	277;
const KFACHID_ElysiumHellOnEarth				=	278;
const KFACHID_ElysiumEndlessWaveFifteen			=	279;

const KFACHID_Dystopia2029Hard                  =   280;
const KFACHID_Dystopia2029HellOnEarth  			=   281;
const KFACHID_Dystopia2029Collectibles 			=   282;

const KFACHID_MoonbaseHard                      =   283;
const KFACHID_MoonbaseHellOnEarth  		    	=   284;
const KFACHID_MoonbaseCollectibles 			    =   285;

const KFACHID_NetherholdHard 				    =   286;
const KFACHID_NetherholdHellOnEarth 	    	=   287;
const KFACHID_NetherholdCollectibles		    =   288;

const KFACHID_CarillonHamletHard 			    =   289;
const KFACHID_CarillonHamletHellOnEarth        	=   290;
const KFACHID_CarillonHamletCollectibles		=   291;

const KFACHID_RigHard 							=   292;
const KFACHID_RigHellOnEarth        			=   293;
const KFACHID_RigCollectibles					=   294;

const KFACHID_BarmwichHard						=   295;
const KFACHID_BarmwichHellOnEarth      			=   296;
const KFACHID_BarmwichCollectibles				=   297;

const KFACHID_CrashHard							=   298;
const KFACHID_CrashHellOnEarth      			=   299;
const KFACHID_CrashCollectibles					=   300;

/* __TW_ANALYTICS_ */
var int PerRoundWeldXP;
var int PerRoundHealXP;

//Cache of achievements information
var array<AchievementDetails> Achievements;

//var private const InterpCurveFloat 	LevelXPCurve;
var const int XPTable[`MAX_PERK_LEVEL];

/** Stats state */
var private const   bool bFailedToRead;
var private const   bool bReadSuccessful;

/** Dev cheats */
var	config	bool	bAllowPerkCheats;
var	private	const	bool	bDisabled;

/** Max reward if users (theoretically) did the objective perfectly */
var int VoshRewards[11];
/** Vosh Multiplier based on game difficulty */
var array<float> VoshDifficultyScalar;
/** Reward if user kills a zed. */
var native map{ FName, INT } KillZedRewards;
/** Keeps track of how many times player killed each zed. */
var native map{ FName, INT } ZedsKilled;

/** Daily Event Information */
enum eDailyObjectiveType
{
    DOT_WeaponDamage,
    DOT_PerkXP,
    DOT_Maps,
};

enum eDailyObjectiveSecondaryType
{
    DOST_PlayPerk,
    DOST_KillZeds,
    DOST_KillBoss,
    DOST_MapCompletion,
    DOST_VersusDamage,
    DOST_VersusKills,
    DOST_CharacterCompletion,
	DOST_KnifeDamage
};

struct native DailyEventInformation
{
    //Category of the objective.
    var eDailyObjectiveType ObjectiveType;

    //Secondary category for ones that share information (Ex: Versus kills / Versus damage)
    var eDailyObjectiveSecondaryType SecondaryType;

    //Any classes tied to this objective
    var array<name> ObjectiveClasses;

    //Amount of stat necessary to complete this objective
    var int CompletionAmount;
};

var array<DailyEventInformation> DailyEvents;

/** Debugging */
var 		bool 	bLogStatsWrite;

var			int		SeasonalKillsObjectiveThreshold;

var const private KFSeasonalEventStats SeasonalEvent;

cpptext
{
	void InitializeKillZedRewards();
	void InitializeVoshRewards();

	UBOOL IsValidProgressStatId(INT StatId);
	void GrantTutorialLevel(class UClass* PerkClass);

    //Event calls
    void GrantWeeklyOutbreakItems();
    void GrantEventItems();
    void GrantDoshVaultItem();

    //Daily calls
	void ForceDailyObjectives(INT ObjectiveIndex, INT UIIndex);
    void ResetDailyObjectives();
    void SetDailyEventIDs();
    INT GetObjectiveID(INT Index);
    void AddToObjective(INT Index, INT Amount);
    void MarkObjectiveComplete(INT Index);

    //Dosh Vault Calls
    void AddToDoshVault(INT Amount);

	UBOOL IsDamageTypeChildOf(class UClass* DamageType, const TArray<FName>& ObjectiveClasses);

	void CalculateZedKillsDoshReward();

	void IncrementZedsKilled(class UClass* MonsterType);

	void InitializeSeasonalEventStats();
}

/*********************************************************************************************
* @name Native stat functions
********************************************************************************************* */
native function OnStatsInitialized(bool bWasSuccessful);
native function IncrementIntStat(int StatId,optional int IncBy = 1);
native function IncrementFloatStat( int StatId, optional float IncBy = 1.0 );
native function SetIntStat( int StatId, int Value );
native function SetFloatStat( int StatId, float Value );
native final function bool HasCheated();
native final function NotifyCheats(optional bool bSaveToConfig);
native final function bool HasReadFailure();
native final function NotifyReadFailure();
native final function bool HasReadStats();
native final function NotifyReadSucceeded();
native final private function int LogSubsystemIntStat( int StatId );

/*********************************************************************************************
* @name Saving & Loading
********************************************************************************************* */
simulated function LogStats()
{
	`log( "###############################################################" );
	`log( "CACHED VALUES:" );
	`log( "CommandoXP, CommandoLVL " @ "    =" @ CommandoXP @ CommandoLVL );
	`log( "BerserkerXP, BerserkerLVL " @ "  =" @ BerserkerXP @ BerserkerLVL );
	`log( "SupportXP, SupportLVL " @ "      =" @ SupportXP @ SupportLVL );
	`log( "MedicXP, MedicLVL " @ "          =" @ MedicXP @ MedicLVL );
	`log( "---------------------------------------------------------------" );
	`log( "STEAM VALUES:" );
	`log( "CommandoXP, CommandoLVL " @ "    =" @ GetXPFromProgress( LogSubsystemIntStat( STATID_Cmdo_Progress ) ) @ GetLVLFromProgress( LogSubsystemIntStat( STATID_Cmdo_Progress ) ) );
	`log( "BerserkerXP, BerserkerLVL " @ "  =" @ GetXPFromProgress( LogSubsystemIntStat( STATID_Bsrk_Progress ) ) @ GetLVLFromProgress( LogSubsystemIntStat( STATID_Bsrk_Progress ) ) );
	`log( "SupportXP, SupportLVL " @ "      =" @ GetXPFromProgress( LogSubsystemIntStat( STATID_Sup_Progress ) ) @ GetLVLFromProgress( LogSubsystemIntStat( STATID_Sup_Progress ) ) );
	`log( "MedicXP, MedicLVL " @ "          =" @ GetXPFromProgress( LogSubsystemIntStat( STATID_Medic_Progress ) ) @ GetLVLFromProgress( LogSubsystemIntStat( STATID_Medic_Progress ) ) );
	`log( " " );
	`log( "CommandoProgress " @ "           =" @ LogSubsystemIntStat( STATID_Cmdo_Progress ) );
	`log( "BerserkerProgress " @ "          =" @ LogSubsystemIntStat( STATID_Bsrk_Progress ) );
	`log( "SupportProgress " @ "            =" @ LogSubsystemIntStat( STATID_Sup_Progress ) );
	`log( "MedicProgress " @ "              =" @ LogSubsystemIntStat( STATID_Medic_Progress ) );
	`log( "###############################################################" );
}

simulated function LogStatValue(int StatId)
{
    `log("*** Stat value for ID" @ StatId @ ": " @ LogSubsystemIntStat(StatId));
}

//In case we ever use this?
event CacheFloatStatsValue(int StatID, float Value)
{
	`log("*** Not caching float value, please do something with this:" @ StatID @ Value);
}

//Steam stats -> the gameplay variables
event CacheStatsValue(int StatID, int Value)
{
	switch( StatID )
	{
		// Perk XPs and builds
		case STATID_Cmdo_Progress:
			CommandoXP = GetXPFromProgress( Value );
			CommandoLVL = GetLVLFromProgress( Value );
			CommandoPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Commando', CommandoLVL );
			`log(GetFuncName() @ "CommandoXP:" @ CommandoXP @CommandoLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Cmdo_Build:
			CommandoBuild = Value;
			`log(GetFuncName() @ "CommandoBuild:" @ CommandoBuild, bLogStatsWrite);
			break;
		case STATID_Bsrk_Progress:
			BerserkerXP = GetXPFromProgress( Value );
			BerserkerLVL = GetLVLFromProgress( Value );
			BerserkerPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Berserker', BerserkerLVL );
			`log(GetFuncName() @ "BerserkerXP:" @ BerserkerXP @ BerserkerLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Bsrk_Build:
			BerserkerBuild = Value;
			`log(GetFuncName() @ "BerserkerBuild:" @ BerserkerBuild, bLogStatsWrite);
			break;
		case STATID_Sup_Progress:
			SupportXP = GetXPFromProgress( Value );
			SupportLVL = GetLVLFromProgress( Value );
			SupportPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Support', SupportLVL );
			`log(GetFuncName() @ "SupportXP:" @ SupportXP @ SupportLVL @ "VALUE:" @ Round( value ),   bLogStatsWrite);
			break;
		case STATID_Sup_Build:
			SupportBuild = Value;
			`log(GetFuncName() @ "SupportBuild:" @ SupportBuild, bLogStatsWrite);
			break;
		case STATID_Medic_Progress:
			MedicXP = GetXPFromProgress( Value );
			MedicLVL = GetLVLFromProgress( Value );
			MedicPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_FieldMedic', MedicLVL );
			`log(GetFuncName() @ "MedicXP:" @ MedicXP @ MedicLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Medic_Build:
			MedicBuild = Value;
			`log(GetFuncName() @ "MedicBuild:" @ MedicBuild, bLogStatsWrite);
			break;
		case STATID_Fire_Progress:
			FirebugXP = GetXPFromProgress( Value );
			FirebugLVL = GetLVLFromProgress( Value );
			FirebugPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Firebug', FirebugLVL );
			`log(GetFuncName() @ "FirebugXP:" @ FirebugXP @ FirebugLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Fire_Build:
			FirebugBuild = Value;
			`log(GetFuncName() @ "FirebugBuild:" @ FirebugBuild, bLogStatsWrite);
			break;
		case STATID_Demo_Progress:
			DemoXP = GetXPFromProgress( Value );
			DemoLVL = GetLVLFromProgress( Value );
			DemoPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Demolitionist', DemoLVL );
			`log(GetFuncName() @ "DemoXP:" @ DemoXP @ DemoLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Demo_Build:
			DemoBuild = Value;
			`log(GetFuncName() @ "DemoBuild:" @ DemoBuild, bLogStatsWrite);
			break;
		case STATID_Guns_Progress:
			GunslingerXP = GetXPFromProgress( Value );
			GunslingerLVL = GetLVLFromProgress( Value );
			GunslingerPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Gunslinger', GunslingerLVL );
			`log(GetFuncName() @ "GunslingerXP:" @ GunslingerXP @ GunslingerLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Guns_Build:
			GunslingerBuild = Value;
			`log(GetFuncName() @ "GunslingerBuild:" @ GunslingerBuild, bLogStatsWrite);
			break;
		case STATID_Shrp_Progress:
			SharpshooterXP = GetXPFromProgress( Value );
			SharpshooterLVL = GetLVLFromProgress( Value );
			SharpshooterPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Sharpshooter', SharpshooterLVL );
			`log(GetFuncName() @ "SharpshooterXP:" @ SharpshooterXP @ SharpshooterLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Shrp_Build:
			SharpshooterBuild = Value;
			`log(GetFuncName() @ "SharpshooterBuild:" @ SharpshooterBuild, bLogStatsWrite);
			break;
		case STATID_Swat_Progress:
			SwatXP = GetXPFromProgress( Value );
			SwatLVL = GetLVLFromProgress( Value );
			SwatPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Swat', SwatLVL );
			`log(GetFuncName() @ "SwatXP:" @ SwatXP @ SwatLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Swat_Build:
			SwatBuild = Value;
			`log(GetFuncName() @ "SwatBuild:" @ SwatBuild, bLogStatsWrite);
			break;
		case STATID_Surv_Progress:
			SurvXP = GetXPFromProgress( Value );
			SurvLVL = GetLVLFromProgress( Value );
			SurvPSG = GetPSGFromProgress( Value );
			CheckPerkLvlAchievement( class'KFPerk_Survivalist', SurvLVL );
			`log(GetFuncName() @ "SurvXP:" @ SurvXP @ SurvLVL @ "VALUE:" @ Round( value ), bLogStatsWrite);
			break;
		case STATID_Surv_Build:
			SurvBuild = Value;
			`log(GetFuncName() @ "SurvBuild:" @ SurvBuild, bLogStatsWrite);
			break;
		// end of perk progress stats
		case STATID_Kills:
			Kills = Value;
			`log(GetFuncName() @ "Kills:" @ Kills, bLogStatsWrite);
			break;
		case STATID_StalkerKills:
			StalkerKills = Value;
			`log(GetFuncName() @ "Stalker Kills:" @ StalkerKills, bLogStatsWrite);
			break;
		case STATID_Sup_WeldPoints:
			WeldingPoints = Value;
			`log(GetFuncName() @ "Welding points:" @ WeldingPoints, bLogStatsWrite);
			break;
		case STATID_Medic_HealPoints:
			HealingPoints = Value;
			`log(GetFuncName() @ "Healing points:" @ HealingPoints, bLogStatsWrite);
			break;
		case STATID_CrawlerKills:
			CrawlerKills = Value;
			`log(GetFuncName() @ "Crawler kills:" @ CrawlerKills, bLogStatsWrite);
			break;
		case STATID_FleshpoundKills:
			FleshpoundKills = Value;
			`log(GetFuncName() @ "Fleshpound kills:" @ FleshpoundKills, bLogStatsWrite);
			break;
        case STATID_SpecialEventProgress:
            InitialSpecialEventInfo = Value;
            `log(GetFuncName() @ "Special Event: " @ SpecialEventInfo, bLogStatsWrite);
            break;
        case STATID_WeeklyEventProgress:
            InitialWeeklyEventInfo = Value;
            `log(GetFuncName() @ "Weekly Event:" @ WeeklyEventInfo, bLogStatsWrite);
            break;
        case STATID_DailyEventInfo:
            CacheDailyEventProgress(Value);
            `log(GetFuncName() @ "Daily Event:" @ DailyEventInfo, bLogStatsWrite);
            break;
        case STATID_DailyEventIDs:
            //Ignore if we've flagged to not read these values.  If we've done that, we're getting new IDs.
            if (!bIgnoreDailyStatReads)
            {
                DailyEventIDs = Value;
            }
            `log(GetFuncName() @ "Daily Event IDs:" @ DailyEventIDs, bLogStatsWrite);
            break;
        case STATID_DailyEventStats1:
            if (bIgnoreDailyStatReads)
            {
                DailyEventStats1 = 0;
            }
            else
            {
                DailyEventStats1 = Value;
            }
            `log(GetFuncName() @ "Daily Event Stats 1:" @ DailyEventStats1, bLogStatsWrite);
            break;
        case STATID_DailyEventStats2:
            if (bIgnoreDailyStatReads)
            {
                DailyEventStats2 = 0;
            }
            else
            {
                DailyEventStats2 = Value;
            }
            `log(GetFuncName() @ "Daily Event Stats 2:" @ DailyEventStats2, bLogStatsWrite);
            break;
		case STATID_SpecialEventKills_DEPRECATED:
			SpecialEventKills_DEPRECATED = Value;
			`log(GetFuncName() @ "SpecialEventKills_DEPRECATED:" @ SpecialEventKills_DEPRECATED, bLogStatsWrite);
			break;
		case STATID_SeasonalEventStats1:
			SeasonalEventStats1 = Value;
			`log(GetFuncName() @ "SeasonalEventStats1:" @ SeasonalEventStats1, bLogStatsWrite);
			break;
		case STATID_SeasonalEventStats2:
			SeasonalEventStats2 = Value;
			`log(GetFuncName() @ "SeasonalEventStats2:" @ SeasonalEventStats2, bLogStatsWrite);
			break;
		case STATID_SeasonalEventStats3:
			SeasonalEventStats3 = Value;
			`log(GetFuncName() @ "SeasonalEventStats3:" @ SeasonalEventStats3, bLogStatsWrite);
			break;
		case STATID_SeasonalEventStats4:
			SeasonalEventStats4 = Value;
			`log(GetFuncName() @ "SeasonalEventStats4:" @ SeasonalEventStats4, bLogStatsWrite);
			break;
		case STATID_SeasonalEventStats5:
			SeasonalEventStats5 = Value;
			`log(GetFuncName() @ "SeasonalEventStats5:" @ SeasonalEventStats5, bLogStatsWrite);
			break;
		case STATID_DoshVaultProgress:
			VerifyDoshVaultCrates();
			break;
		case STATID_PersonalBest_KnifeKills:
			PersonalBest_KnifeKills = Value;
			`log(GetFuncName() @ "PersonalBest_KnifeKills:" @ PersonalBest_KnifeKills, bLogStatsWrite);
			break;
		case STATID_PersonalBest_PistolKills:
			PersonalBest_PistolKills = Value;
			`log(GetFuncName() @ "PersonalBest_PistolKills:" @ PersonalBest_PistolKills, bLogStatsWrite);
			break;
		case STATID_PersonalBest_HeadShots:
			PersonalBest_HeadShots = Value;
			`log(GetFuncName() @ "PersonalBest_HeadShots:" @ PersonalBest_HeadShots, bLogStatsWrite);
			break;
		case STATID_PersonalBest_Healing:
			PersonalBest_Healing = Value;
			`log(GetFuncName() @ "PersonalBest_Healing:" @ PersonalBest_Healing, bLogStatsWrite);
			break;
		case STATID_PersonalBest_Kills:
			PersonalBest_Kills = Value;
			`log(GetFuncName() @ "PersonalBest_Kills:" @ PersonalBest_Kills, bLogStatsWrite);
			break;
		case STATID_PersonalBest_Assists:
			PersonalBest_Assists = Value;
			`log(GetFuncName() @ "PersonalBest_Assists:" @ PersonalBest_Assists, bLogStatsWrite);
			break;
		case STATID_PersonalBest_LargeZedKill:
			PersonalBest_LargeZedKil = Value;
			`log(GetFuncName() @ "PersonalBest_LargeZedKil:" @ PersonalBest_LargeZedKil, bLogStatsWrite);
			break;
		case STATID_PersonalBest_Dosh:
			PersonalBest_Dosh = Value;
			`log(GetFuncName() @ "PersonalBest_Dosh:" @ PersonalBest_Dosh, bLogStatsWrite);
			break;
	}
}

/** returns cached stats value */
private event GetPerkBuildFromStats( class<KFPerk> PerkClass, out int Build )
{
	switch( PerkClass )
	{
		case class'KFPerk_Commando':
			Build = CommandoBuild;
			break;
		case class'KFPerk_Berserker':
			Build = BerserkerBuild;
			break;
		case class'KFPerk_Support':
			Build = SupportBuild;
			break;
		case class'KFPerk_FieldMedic':
			Build = MedicBuild;
			break;
		case class'KFPerk_Firebug':
			Build = FirebugBuild;
			break;
		case class'KFPerk_Demolitionist':
			Build = DemoBuild;
			break;
		case class'KFPerk_Gunslinger':
			Build = GunslingerBuild;
			break;
		case class'KFPerk_Sharpshooter':
			Build = SharpshooterBuild;
			break;
		case class'KFPerk_Swat':
			Build = SwatBuild;
			break;
		case class'KFPerk_Survivalist':
			Build = SurvBuild;
			break;
	}
}

/** returns cached stats value */
private event SaveBuildToStats(class<KFPerk> InPerk, int Build)
{
	local int StatID;
	StatId = InPerk.static.GetPerkBuildStatID();

	// save and update cached var
	SetIntStat(StatId, Build);
	CacheStatsValue(StatId, Build);

	`log(GetFuncName() @ "Saving build for perk:" @ InPerk @ "Build:" @ Build, bLogStatsWrite);
}

/*********************************************************************************************
* @name Perk Progression
********************************************************************************************* */

// External get functions
native final function int GetPerkPrestigeLevel(class<KFPerk> Perk);
native final function int GetPerkLevel( class<KFPerk> Perk );
native final function int GetPerkBuild( class<KFPerk> Perk );
native final static function int GetXPNeededAt( int Level );

// Use these instead of IncrementIntStat, etc...
native final private function IncrementXPStat( class<KFPerk> PerkClass, optional int IncBy = 1 );
native final private function bool IncrementPSGStat(class<KFPerk> PerkClass);

native final private function int GetXPFromProgress( int PerkProgress );
native final private function int GetLVLFromProgress( int PerkProgress );
native final private function int GetPSGFromProgress( int PerkProgress );

/** Called when some game event awards XP */
private event AddXP( class<KFPerk> PerkClass, int dXP, bool bApplyPrestigeBonus = false )
{
	local float XPMultiplier;
	local float BonusXP;
	local int PerkIndex, BonusXPTruncated, BonusXPOverflow;

	XPMultiplier = 0;

	if( PerkClass == None )
	{
		return;
	}

	if (MyKFPC != none && bApplyPrestigeBonus)
	{
		XPMultiplier = MYKFPC.GetPerkPrestigeXPMultiplier(PerkClass);
		if (XPMultiplier > 0.f)
		{
			// apply integer bonus
			BonusXP = float(dXP) * XPMultiplier;
			BonusXPTruncated = int(BonusXP);

			// accumulate remainder
			PerkIndex = MyKFPC.GetPerkIndexFromClass(PerkClass);
			BonusXPRemainder[PerkIndex] += BonusXP - BonusXPTruncated;

			// apply accumulated remainder if necessary
			if (BonusXPRemainder[PerkIndex] >= 1.f)
			{
				BonusXPOverflow = int(BonusXPRemainder[PerkIndex]);
				BonusXPTruncated += BonusXPOverflow;
				BonusXPRemainder[PerkIndex] -= BonusXPOverflow;
			}

			dXP += BonusXPTruncated;
		}
	}

	IncrementXPStat( PerkClass, dXP );

	if( MyKFPC != none )
	{
		MyKFPC.NotifyXPGain(PerkClass, dXP, BonusXPTruncated);
	}
	`log("AddXP Perk: "$PerkClass$"; dXP: "$dXP$"; BonusXP: "$BonusXPTruncated, bLogStatsWrite);
}

/** Called by IncrementXPStat when new level is achieved */
private event NotifyLevelUp(class<KFPerk> PerkClass, int NewLVL, int NewPrestigeLevel)
{
	if( MyKFPC != None )
	{
		MyKFPC.NotifyLevelUp( PerkClass, NewLVL, NewPrestigeLevel);
		`log(GetFuncName() @ "PerkClass:" @ PerkClass @ "New LVL:" @ NewLVL @ "NewPrestigeLevel" @NewPrestigeLevel, bLogStatsWrite);

		if( NewLVL % 5 == 0 )
		{
			CheckPerkLvlAchievement( PerkCLass, NewLVL );
		}
	}
}

/** returns cached value for xp */
private event int GetPerkXP( int StatID )
{
	switch( StatID )
	{
		case STATID_Cmdo_Progress:			return CommandoXP;
		case STATID_Bsrk_Progress:			return BerserkerXP;
		case STATID_Sup_Progress:			return SupportXP;
		case STATID_Medic_Progress:			return MedicXP;
		case STATID_Fire_Progress:			return FirebugXP;
		case STATID_Demo_Progress:			return DemoXP;
		case STATID_Guns_Progress:			return GunslingerXP;
		case STATID_Shrp_Progress:			return SharpshooterXP;
		case STATID_Swat_Progress:			return SwatXP;
		case STATID_Surv_Progress:			return SurvXP;
	}

	return 0;
}

/** returns cached value for lvl */
private event int GetPerkLVLInternal( int StatID )
{
	switch( StatID )
	{
		case STATID_Cmdo_Progress:			return CommandoLVL;
		case STATID_Bsrk_Progress:			return BerserkerLVL;
		case STATID_Sup_Progress:			return SupportLVL;
		case STATID_Medic_Progress:			return MedicLVL;
		case STATID_Fire_Progress:			return FirebugLVL;
		case STATID_Demo_Progress:			return DemoLVL;
		case STATID_Guns_Progress:			return GunslingerLVL;
		case STATID_Shrp_Progress:			return SharpshooterLVL;
		case STATID_Swat_Progress:			return SwatLVL;
		case STATID_Surv_Progress:			return SurvLVL;
	}

	return 0;
}

/** returns cached value for lvl */
private event int GetPerkPSG( int StatID )
{
	switch( StatID )
	{
		case STATID_Cmdo_Progress:			return CommandoPSG;
		case STATID_Bsrk_Progress:			return BerserkerPSG;
		case STATID_Sup_Progress:			return SupportPSG;
		case STATID_Medic_Progress:			return MedicPSG;
		case STATID_Fire_Progress:			return FirebugPSG;
		case STATID_Demo_Progress:			return DemoPSG;
		case STATID_Guns_Progress:			return GunslingerPSG;
		case STATID_Shrp_Progress:			return SharpshooterPSG;
		case STATID_Swat_Progress:			return SwatPSG;
		case STATID_Surv_Progress:			return SurvPSG;
	}

	return 0;
}

private event int GetPerkLVLByClass(class<KFPerk> PerkClass)
{
	local int StatID;

	StatID = PerkClass.static.GetProgressStatID();
	return GetPerkLVLInternal(StatID);
}

private event int GetPerkPrestigeLVLByClass(class<KFPerk> PerkClass)
{
	local int StatID;

	StatID = PerkClass.static.GetProgressStatID();
	return GetPerkPSG(StatID);
}

/*********************************************************************************************
* @name Personal Bests (AAR)
********************************************************************************************* */

function int GetPersonalBest( EPersonalBests PersonalBestID )
{
	switch( PersonalBestID )
	{
		case EPB_KnifeKills:			return PersonalBest_KnifeKills;
		case EPB_PistolKills:			return PersonalBest_PistolKills;
		case EPB_HeadShots:				return PersonalBest_HeadShots;
		case EPB_Healing:				return PersonalBest_Healing;
		case EPB_Kills:					return PersonalBest_Kills;
		case EPB_Assists:				return PersonalBest_Assists;
		case EPB_LargeZedKill:			return PersonalBest_LargeZedKil;
		case EPB_Dosh:					return PersonalBest_Dosh;
	}

	return 0;
}

function SavePersonalBest( EPersonalBests PersonalBestID, int Value )
{
	switch( PersonalBestID )
	{
		case EPB_KnifeKills:			SetIntStat(STATID_PersonalBest_KnifeKills, Value); 	break;
		case EPB_PistolKills:			SetIntStat(STATID_PersonalBest_PistolKills, Value); 	break;
		case EPB_HeadShots:				SetIntStat(STATID_PersonalBest_HeadShots, Value); 		break;
		case EPB_Healing:				SetIntStat(STATID_PersonalBest_Healing, Value); 		break;
		case EPB_Kills:					SetIntStat(STATID_PersonalBest_Kills, Value); 			break;
		case EPB_Assists:				SetIntStat(STATID_PersonalBest_Assists, Value); 		break;
		case EPB_LargeZedKill:			SetIntStat(STATID_PersonalBest_LargeZedKill, Value); 	break;
		case EPB_Dosh:					SetIntStat(STATID_PersonalBest_Dosh, Value); 			break;
	}
}

/*********************************************************************************************
* @name Gameplay
********************************************************************************************* */

private event AddToHitsTaken()
{
	SeasonalEventStats_OnHitTaken();
}

private event AddToHitsGiven(class<DamageType> DT)
{
	SeasonalEventStats_OnHitGiven(DT);
}

/**
 * @brief Add a kill and give some EXP tp the player
 * @param MonsterClass The killed monster's class
 * @param Difficulty The current game difficulty
 * @param DT The damagetype used to kill the zed
 * @return [description]
 */
private event AddToKills( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT, bool bKiller )
{
	// seasonal event hook
	SeasonalEventStats_OnZedKilled(MonsterClass, Difficulty, DT);

	if (!bKiller)
	{
		return;
	}

	IncrementIntStat( STATID_Kills, 1 );
	Kills++;

	if(!MonsterClass.default.bVersusZed)
	{
		MyKFPC.ReceiveLocalizedMessage(Class'KFLocalMessage_PlayerKills', KMT_PLayerKillZed, MyKFPC.PlayerReplicationInfo, none, MonsterClass);
	}

	if( IsStalkerKill( MonsterClass, DT ) )
	{
		AddStalkerKill( Difficulty );
	}
	else if( IsCrawlerKill( MonsterClass, DT ) )
	{
		AddCrawlerKill( Difficulty );
	}
	else if( IsFleshPoundKill( MonsterClass, DT ) )
	{
		AddFleshpoundKill( Difficulty );
	}
	else if( IsClotKill( MonsterClass, DT ) )
	{
		AddClotKill( Difficulty );
	}
	else if( IsClotSurvivalistKill( MonsterClass ) )
	{
		AddClotSurvivalistKill( Difficulty );
	}
	else if( IsBloatKill( MonsterClass, DT ) )
	{
		AddBloatKill( Difficulty );
	}

	`RecordAARZedKill(MyKFPC, MonsterClass, DT);

    AddToKillObjectives(MonsterClass);
}

private event AddToHeadshotKills( class<KFPawn_Monster> MonsterClass, byte Difficulty, class<DamageType> DT )
{
	// seasonal event hook
	SeasonalEventStats_OnZedKilledByHeadshot(MonsterClass, Difficulty, DT);
}

private event AddNonZedKill(class<Pawn> KilledClass, byte Difficulty)
{
    if (MyKFPC != none && MyKFPC.Pawn != none && (KilledClass.Name == 'KFPawn_Human_Versus' || KilledClass.Name == 'KFPawn_Human'))
    {
        AddToVersusKillObjectives(MyKFPC.Pawn.class);
    }
}

private event AddToWeaponPurchased( class<KFWeaponDefinition> WeaponDef, int Price )
{
	SeasonalEventStats_OnWeaponPurchased(WeaponDef, Price);
}

private event AddAfflictionCaused(EAfflictionType Type)
{
	SeasonalEventStats_OnAfflictionCaused(Type);
}

private native function AddToKillObjectives(class<KFPawn_Monster> ZedClass);
private native function AddToVersusKillObjectives(class<Pawn> KillerClass);

/**
 * @brief Adds EXP for a qualified stalker kill
 * @details The commando perk only receives extra EXP when a stalker is killed
 * 			with a commando weapon. The currently slected skill does not matter
 * @param Difficulty current game difficulty
 */
private function AddStalkerKill( byte Difficulty )
{
	StalkerKills++;
	IncrementIntStat( STATID_StalkerKills, 1 );
	AddXP( class'KFPerk_Commando', class'KFPerk_Commando'.static.GetStalkerKillXP( Difficulty ) );
	`log(GetFuncName() @ "Adding stalker kill, IncrementIntStat STATID_StalkerKills by:" @ class'KFPerk_Commando'.static.GetStalkerKillXP(Difficulty), bLogStatsWrite);

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Commando', class'KFPerk_Commando'.static.GetStalkerKillXP( Difficulty ) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Commando'.static.GetStalkerKillXP( Difficulty );

}

/**
 * @brief Adds EXP for a small radius kill
 * @details Berserker gains XP when killing a zed close to another player
 *
 * @param Difficulty current game difficulty
 */
private event AddSmallRadiusKill( byte Difficulty, class<KFPerk> PerkClass )
{
	if(PerkClass == class'KFPerk_Berserker'.static.GetPerkClass())
	{
		AddXP( class'KFPerk_Berserker', class'KFPerk_Berserker'.static.GetSmallRadiusKillXP(Difficulty) );

		//AAR
		`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Berserker', class'KFPerk_Berserker'.static.GetSmallRadiusKillXP(Difficulty) );
		KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Berserker'.static.GetSmallRadiusKillXP(Difficulty);
	}
	else if(PerkClass == class'KFPerk_Survivalist'.static.GetPerkClass())
	{
		AddXP( class'KFPerk_Survivalist', class'KFPerk_Survivalist'.static.GetSmallRadiusKillXP(Difficulty) );

		//AAR
		`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Survivalist', class'KFPerk_Survivalist'.static.GetSmallRadiusKillXP(Difficulty) );
		KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Survivalist'.static.GetSmallRadiusKillXP(Difficulty);
	}
}

/**
 * @brief Adds EXP for a qualified crawler kill
 * @details The Firebug perk only receives extra EXP when a crawler is killed
 * 			with a Firebug weapon. The currently selected skill does not matter
 * @param Difficulty current game difficulty
 */
private function AddCrawlerKill( byte Difficulty )
{
	CrawlerKills++;
	IncrementIntStat( STATID_CrawlerKills, 1 );
	AddXP( class'KFPerk_Firebug', class'KFPerk_Firebug'.static.GetCrawlerKillXP( Difficulty ) );
	`log(GetFuncName() @ "Adding crawler kill, IncrementIntStat STATID_CrawlerKills by:" @ class'KFPerk_Firebug'.static.GetCrawlerKillXP(Difficulty), bLogStatsWrite);

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Firebug', class'KFPerk_Firebug'.static.GetCrawlerKillXP( Difficulty ) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Firebug'.static.GetCrawlerKillXP( Difficulty );
}

/**
 * @brief Adds EXP for a qualified Fleshpound kill
 * @details The Demolitionist perk only receives extra EXP when a Fleshpound is killed
 * 			with a demo weapon. The currently selected skill does not matter
 * @param Difficulty current game difficulty
 */
private function AddFleshpoundKill( byte Difficulty )
{
	FleshpoundKills++;
	IncrementIntStat( STATID_FleshpoundKills, 1 );
	AddXP( class'KFPerk_Demolitionist', class'KFPerk_Demolitionist'.static.GetFleshpoundKillXP( Difficulty ) );
	`log(GetFuncName() @ "Adding crawler kill, IncrementIntStat STATID_CrawlerKills by:" @ class'KFPerk_Firebug'.static.GetCrawlerKillXP(Difficulty), bLogStatsWrite);

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Demolitionist', class'KFPerk_Demolitionist'.static.GetFleshpoundKillXP( Difficulty ) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Demolitionist'.static.GetFleshpoundKillXP( Difficulty );
}

/**
 * @brief Adds EXP for a qualified clot kill
 * @details The SWAT perk only receives extra EXP when a Fleshpound is killed
 * 			with a demo weapon. The currently selected skill does not matter
 * @param Difficulty current game difficulty
 */
private function AddClotKill( byte Difficulty )
{
	AddXP( class'KFPerk_SWAT', class'KFPerk_SWAT'.static.GetClotKillXP( Difficulty ) );

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_SWAT', class'KFPerk_SWAT'.static.GetClotKillXP( Difficulty ) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_SWAT'.static.GetClotKillXP( Difficulty );
}

/**
 * @brief Adds EXP for a qualified clot kill
 * @details The Survivalist perk receives extra EXP when a clot is killed
 * 			with any weapon
 * @param Difficulty current game difficulty
 */
private function AddClotSurvivalistKill( byte Difficulty )
{
	AddXP( class'KFPerk_Survivalist', class'KFPerk_Survivalist'.static.GetClotKillXP( Difficulty ) );

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Survivalist', class'KFPerk_Survivalist'.static.GetClotKillXP( Difficulty ) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Survivalist'.static.GetClotKillXP( Difficulty );
}

/**
 * @brief Adds EXP for a qualified bloat kill
 * @details The Firebug perk only receives extra EXP when a bloat is killed
 * 			with a Firebug weapon. The currently selected skill does not matter
 * @param Difficulty current game difficulty
 */
private function AddBloatKill( byte Difficulty )
{
	AddXP( class'KFPerk_Firebug', class'KFPerk_Firebug'.static.GetBloatKillXP( Difficulty ) );

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Firebug', class'KFPerk_Firebug'.static.GetBloatKillXP( Difficulty ) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Firebug'.static.GetBloatKillXP( Difficulty );
}

/**
 * @brief Checks if a crawler kill qualifies for Firebug EXP
 *
 * @param DT Used damage type
 * @param MonsterClass the killed zed's class
 * @return true if the zed was a crawler and the damage type is on perk
 */
private final function bool IsCrawlerKill( class<KFPawn_Monster> MonsterClass, class<DamageType> DT )
{
	return  MonsterClass.static.IsCrawlerClass() &&
			class'KFPerk'.static.IsDamageTypeOnThisPerk( class<KFDamageType>(DT), class'KFPerk_Firebug'.static.GetPerkClass() );
}

/**
 * @brief Checks if a stalker kill qualifies for Commando EXP
 *
 * @param DT Used damage type
 * @param MonsterClass the killed zed's class
 * @return true if the zed was a stalker and the damage type is on perk
 */
private final function bool IsStalkerKill( class<KFPawn_Monster> MonsterClass, class<DamageType> DT )
{
	return  MonsterClass.static.IsStalkerClass() &&
			class'KFPerk'.static.IsDamageTypeOnThisPerk( class<KFDamageType>(DT), class'KFPerk_Commando'.static.GetPerkClass() );
}

/**
 * @brief Checks if a fleshpund kill qualifies for demo EXP
 *
 * @param DT Used damage type
 * @param MonsterClass the killed zed's class
 * @return true if the zed was a stalker and the damage type is on perk
 */
private final function bool IsFleshPoundKill( class<KFPawn_Monster> MonsterClass, class<DamageType> DT )
{
	return  MonsterClass.static.IsFleshpoundClass() &&
			class'KFPerk'.static.IsDamageTypeOnThisPerk( class<KFDamageType>(DT), class'KFPerk_Demolitionist'.static.GetPerkClass() );
}

/**
 * @brief Checks if a clot kill qualifies for swat EXP
 *
 * @param DT Used damage type
 * @param MonsterClass the killed zed's class
 * @return true if the zed was a stalker and the damage type is on perk
 */
private final function bool IsClotKill( class<KFPawn_Monster> MonsterClass, class<DamageType> DT )
{
	return  MonsterClass.static.IsClotClass() &&
			class'KFPerk'.static.IsDamageTypeOnThisPerk(class<KFDamageType>(DT), class'KFPerk_SWAT'.static.GetPerkClass());
}

/**
 * @brief Checks if a clot kill qualifies for survivalist EXP
 *
 * @param MonsterClass the killed zed's class
 * @return true if the zed was a clot
 */
private final function bool IsClotSurvivalistKill( class<KFPawn_Monster> MonsterClass )
{
	return  MonsterClass.static.IsClotClass();
}

/**
 * @brief Checks if a bloat kill qualifies for Firebug EXP
 *
 * @param DT Used damage type
 * @param MonsterClass the killed zed's class
 * @return true if the zed was a crawler and the damage type is on perk
 */
private final function bool IsBloatKill( class<KFPawn_Monster> MonsterClass, class<DamageType> DT )
{
	return  MonsterClass.static.IsBloatClass() &&
			class'KFPerk'.static.IsDamageTypeOnThisPerk( class<KFDamageType>(DT), class'KFPerk_Firebug'.static.GetPerkClass() );
}

/*
 * Calculates the perk XP reward for a certain number of points
 * Split from AddWeldingPoints so analytics can log XP earned.
 */
private function int ComputeWeldingXP( int Points )
{
	local int XPEarned;
	local KFGameReplicationInfo KFGRI;

	XPEarned = FFloor( float(Points) / float(WeldingPointsRequired) );
	if( XPEarned >= 1 )
	{
		KFGRI = KFGameReplicationInfo(MyKFPC.WorldInfo.GRI);
		class'KFPerk_Support'.static.MultiplySecondaryXPPoints( XPEarned, KFGRI.GameDifficulty);
	}

	return XPEarned;
}

/** Welding does not earn XP directly, WeldingPointsRequired have to be earned first */
private event int AddWeldingPoints( int PointsWelded )
{
	local int XPEarned;

	WeldingPoints += PointsWelded;

	`log(GetFuncName() @ "WeldingPoints are now:" @ WeldingPoints, bLogStatsWrite);

	XPEarned = ComputeWeldingXP( WeldingPoints ); //FFloor( float(WeldingPoints) / float(WeldingPointsRequired) );
	if( XPEarned >= 1 )
	{
		AddXP(class'KFPerk_Support', XPEarned);

		//AAR
		`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Support', XPEarned );
		KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += XPEarned;

		// keep a running tally for analytics at the end of the match
		PerRoundWeldXP += XPEarned;

		// reset/rollover points needed for next xp gain
		WeldingPoints = WeldingPoints % WeldingPointsRequired;

		`log(GetFuncName() @ "Welding XP earned :" @ XPEarned, bLogStatsWrite);
	}

	// We need the welding points to be persistent
	SetIntStat( STATID_Sup_WeldPoints,  WeldingPoints );

	return XPEarned;
}

/** Repairing doors is another source of secondary XP for the Support class. It uses different
 *      values for the XP earned, and is only earned on completion.  However, it tallies into
 *      the same end stat.
 */
private event int DoorRepaired()
{
    local int XPEarned;
    local KFGameReplicationInfo KFGRI;
    KFGRI = KFGameReplicationInfo(MyKFPC.WorldInfo.GRI);
    if (KFGRI != none)
    {
        class'KFPerk_Support'.static.GetDoorRepairXP(XPEarned, KFGRI.GameDifficulty);
        if (XPEarned > 0)
        {
            AddXP(class'KFPerk_Support', XPEarned);
            `RecordSecondaryXPGain(MyKFPC, class'KFPerk_Support', XPEarned);
            KFGRI.SecondaryXPAccumulator += XPEarned;
            PerRoundWeldXP += XPEarned;

            `log(GetFuncName() @ "Door Repair XP earned :" @ XPEarned);
        }
    }

    return XPEarned;
}

/*
 * Calculates the perk XP reward for a certain number of points
 * Split from AddHealingPoints so analytics can log XP earned.
 */
private function int ComputeHealingXP( int Points )
{
	local int XPEarned;
	local KFGameReplicationInfo KFGRI;

	XPEarned = FFloor( float(Points) / float(HealingPointsRequired) );
	if( XPEarned >= 1 )
	{
		KFGRI = KFGameReplicationInfo(MyKFPC.WorldInfo.GRI);
		class'KFPerk_FieldMedic'.static.MultiplySecondaryXPPoints( XPEarned, KFGRI.GameDifficulty);
	}

	return XPEarned;
}

/** Healing does not earn XP directly, HealingPointsRequired have to be earned first */
private event int AddHealingPoints( int PointsHealed )
{
	local int XPEarned;

	HealingPoints += PointsHealed;

	`log(GetFuncName() @ "HealingPoints are now:" @ HealingPointsRequired, bLogStatsWrite);

	XPEarned = ComputeHealingXP( HealingPoints );
	if( XPEarned >= 1 )
	{
		AddXP(class'KFPerk_FieldMedic', XPEarned);

		//AAR
		`RecordSecondaryXPGain( MyKFPC, class'KFPerk_FieldMedic', XPEarned );
		KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += XPEarned;

		// keep a running tally for analytics at the end of the match
		PerRoundHealXP += XPEarned;

		// reset/rollover points needed for next xp gain
		HealingPoints = HealingPoints % HealingPointsRequired;

		`log(GetFuncName() @ "Healing XP earned :" @ XPEarned, bLogStatsWrite);
	}

	// We need the welding points to be persistent
	SetIntStat( STATID_Medic_HealPoints,  HealingPoints );

	if( MyKFPC != none )
	{
		MyKFPC.ClientUnlockAchievement( KFACHID_IGotYourBack );
	}

	return XPEarned;
}

/**
 * @brief Add a headshot and give some EXP tp the player
 * @param Difficulty The current game difficulty
 * @param DT The damagetype used to headshot the zed
 * @return [description]
 */
private event AddToHeadshots( byte Difficulty, class<DamageType> DT )
{
    //Do both separately to allow for multi-perk pass through (Ex: single flare uses both)
	if( IsGunslingerHeadshot( DT ) )
	{
		AddGunslingerHeadshot( Difficulty );
	}

    if( IsSharpshooterHeadshot(DT) )
	{
		AddSharpshooterHeadshot( Difficulty );
	}
}

/**
 * @brief Adds EXP for a gunslinger headshot
 * @details The Gunslinger perk only receives extra EXP when a headshot is achieved with a Gunslinger weapon.
 * @param Difficulty current game difficulty
 */
private function AddGunslingerHeadshot( byte Difficulty )
{
	AddXP( class'KFPerk_Gunslinger', class'KFPerk_Gunslinger'.static.GetHeadshotXP(Difficulty) );

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Gunslinger', class'KFPerk_Gunslinger'.static.GetHeadshotXP(Difficulty) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Gunslinger'.static.GetHeadshotXP(Difficulty);
}

/**
 * @brief Adds EXP for a sharpshooter headshot
 * @details The Sharpshooter perk only receives extra EXP when a headshot is achieved with a Sharpshooter weapon.
 * @param Difficulty current game difficulty
 */
private function AddSharpshooterHeadshot( byte Difficulty )
{
	AddXP( class'KFPerk_Sharpshooter', class'KFPerk_Sharpshooter'.static.GetHeadshotXP(Difficulty) );

	//AAR
	`RecordSecondaryXPGain( MyKFPC, class'KFPerk_Sharpshooter', class'KFPerk_Sharpshooter'.static.GetHeadshotXP(Difficulty) );
	KFGameReplicationInfo(MyKFPC.WorldInfo.GRI).SecondaryXPAccumulator += class'KFPerk_Sharpshooter'.static.GetHeadshotXP(Difficulty);
}

/**
 * @brief Checks if a headshot qualifies for gunslinger EXP
 *
 * @param DT Used damage type
 * @return true if damage type is on perk
 */
private final function bool IsGunslingerHeadshot( class<DamageType> DT )
{
	return (class'KFPerk_Gunslinger'.static.IsDamageTypeOnPerk( class<KFDamageType>(DT) ));
}

/**
 * @brief Checks if a headshot qualifies for sharpshooter EXP
 *
 * @param DT Used damage type
 * @return true if damage type is on perk
 */
private final function bool IsSharpshooterHeadshot( class<DamageType> DT )
{
	return (class'KFPerk'.static.IsDamageTypeOnThisPerk( class<KFDamageType>(DT), class'KFPerk_Sharpshooter'.static.GetPerkClass() ));
}

final function int GetSeasonalEventStatValue(int StatIdx)
{
	switch (StatIdx)
	{
	case 0:
		return SeasonalEventStats1;

	case 1:
		return SeasonalEventStats2;

	case 2:
		return SeasonalEventStats3;

	case 3:
		return SeasonalEventStats4;

	case 4:
		return SeasonalEventStats5;
	};

	return -1;
}

final function int GetSeasonalEventStatMaxValue(int StatIdx)
{
	switch (StatIdx)
	{
	case 0:
		return SeasonalEventStatsMax1;

	case 1:
		return SeasonalEventStatsMax2;

	case 2:
		return SeasonalEventStatsMax3;

	case 3:
		return SeasonalEventStatsMax4;

	case 4:
		return SeasonalEventStatsMax5;
	};

	return -1;
}

/*********************************************************************************************
* @name Achievements
********************************************************************************************* */

function GetAchievements()
{
	if( MyKFPC.IsLocalPlayerController() )
	{
		Achievements.Remove( 0, Achievements.length );
		MyKFPC.OnlineSub.PlayerInterface.GetAchievements( 0, Achievements );
	}
}

final function bool IsAchievementUnlocked( int AchievementIndex )
{
	return ( AchievementIndex < Achievements.length ) && Achievements[AchievementIndex].bWasAchievedOnline;
}

function OnUnlockAchievement( int AchievementIndex )
{
	//Reload the achievement list to get the change
	GetAchievements();
}

native function UnlockDingoAchievement(int AchievementId, optional int Value = 1);

/**
 * @brief Call into native to determine if we achieved anything
  *
 * @param MapName The name of the map played
 * @param Difficulty The game's difficulty
 * @param GameLength short/medium/long
 * @param bCoop multiplayer or not
  */
native final function OnGameWon( string MapName, byte Difficulty, byte GameLength, byte bCoop, class<KFPerk> PerkClass );

/** Used for Versus. */
native final function OnRoundEnd( byte WinningTeam );

/** Whenever the game end, calculate general acheivements. */
native final function OnGameEnd( string MapName, byte Difficulty, byte GameLength, byte EndingWaveNum, byte bCoop, class<KFPerk> PerkClass );

/**
 * @brief Check for map specific achievements on game end
 *
 * @param MapName The name of the map played
 * @param Difficulty The game's difficulty
 * @param GameLength short/medium/long
 * @param bCoop multiplayer or not
 */
native final function CheckMapEndAchievements( string MapName, byte Difficulty, byte bCoop, byte bObjectiveMode );

/**
* @brief Check for any additional behavior on collectible achievements
*/
native final function CheckCollectibleAchievement( string MapName );

/**
* @brief Check for any additional behavior on collectible achievements
*/
native final function CheckEndWaveObjective(int CurrentWave);

/**
 * @brief Check if a new perk tier has been reached
 *
 * @param PerkClass Perk leveled up
 * @param NewLVL The new perk level
 */
native final private function CheckPerkLvlAchievement( class<KFPerk> PerkClass, int NewLVL );

/**
 * @brief Check if a new difficulty with the selected perk was won
 *
 * @param PerkClass Selected perk class
 * @param Difficulty Difficulty played
 */
native final private function CheckPerkDifficultyAchievements( class<KFPerk> PerkClass, byte Difficulty );

/**
 * @brief Check if all perks reached lvl 25 and unlock achievement
 */
native final private function CheckAllPerksLvl25();
/**
 * @brief Unlocks the tutorial achievement
 */
native final function UnlockTutorialAchievement();
native final function CheckForRoundTeamWinAchievements( byte WinningTeam );

/**
 * @brief Grant any perk prestige inventory rewards if necessary
 */
native final function CheckPerkPSGRewards(class<KFPerk> PSGPerkClass);

/*********************************************************************************************
* @name Events
********************************************************************************************* */
final function bool CanCacheSpecialEvent()
{
    return InitialSpecialEventInfo > 0;
}

/** Verify what event we're in and cache local event state.  If we've changed to a new event,
 *      clear out the status flags before caching new date value.
 */
native final private function CacheSpecialEventState(int Value, int Year, int Month);

native final function int GetSpecialEventRewardValue();

/** Triggered by KF PC when the special event ID is passed through as a valid value */
final function UpdateSpecialEventState()
{
	local int year, month, dayofweek, day, hour, minute, second, msec;
	GetSystemTime(year, month, dayofweek, day, hour, minute, second, msec);

    CacheSpecialEventState(InitialSpecialEventInfo, year, month);
	if( InitialSpecialEventInfo != SpecialEventInfo )
	{
		// Flush stats write if we did a reset
		MyKFPC.ClientWriteAndFlushStats();
	}
}

/** Update the state of a special event.  If the passed in EventIndex doesn't match our current
 *      special event index, do not update the stat.  Also, if the map name passed doesn't match
 *      the list of allowed maps in native, don't record.
 */
native final function UpdateSpecialEvent(int EventIndex, int ObjectiveIndex, int Year, int Month);

/** Grab the state of a special event objective at a specific index. */
native final function bool IsEventObjectiveComplete(int ObjectiveIndex);

final function bool CanCacheWeeklyEvent()
{
    return InitialWeeklyEventInfo > 0;
}

/** Cache the state of the weekly event.If the cached week/year combo in the stored
 *      value don't match, everything is cleared.
 */
native final private function CacheWeeklyEventState(int Value);

/** Triggered by KF PC when the weekly event ID is passed through as a valid value */
final function UpdateWeeklyEventState()
{
    CacheWeeklyEventState(InitialWeeklyEventInfo);

	// Flush stats write if we did a reset
	if (InitialWeeklyEventInfo != WeeklyEventInfo)
	{
		MyKFPC.ClientWriteAndFlushStats();
	}
}

/** Update the state of the weekly event.  Called via game type. */
native final function WeeklyEventComplete();

/** Whether or not the current weekly has been finished */
native final function bool IsWeeklyEventComplete();

/** Get a list of IDs associated with the prizes given out for completing a weekly */
native static final function array<int> GetWeeklyOutbreakRewards(int Index = -1);

/** Get the amount of Vosh a player would earn by completeting a map objective. */
native static final function int GetMapObjectiveVoshReward(byte Difficulty, byte WaveNum);

/** Award the player the Vosh for completeting a map objective. */
native final function MapObjectiveCompleted();

/*********************************************************************************************
* @name Seasonal Events
********************************************************************************************* */

final simulated function SeasonalEventStats_OnStatsInitialized()
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnStatsInitialized();
	}
}

final native simulated function bool SeasonalEventIsValid();

final simulated function SeasonalEventStats_OnMapObjectiveDeactivated(Actor ObjectiveInterfaceActor)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnMapObjectiveDeactivated(ObjectiveInterfaceActor);
	}
}

final simulated function SeasonalEventStats_OnMapCollectibleFound(PlayerReplicationInfo FinderPRI, int CollectibleID)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnMapCollectibleFound(FinderPRI, CollectibleID);
	}
}

final native simulated event SeasonalEventStats_OnGameWon(class<GameInfo> GameClass, int Difficulty, int GameLength, bool bCoOp);

final native simulated event SeasonalEventStats_OnGameEnd(class<GameInfo> GameClass);

final simulated function SeasonalEventStats_OnHitTaken()
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnHitTaken();
	}
}

final simulated function SeasonalEventStats_OnHitGiven(class<DamageType> DT)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnHitGiven(DT);
	}
}

final simulated function SeasonalEventStats_OnZedKilled(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnZedKilled(MonsterClass, Difficulty, DT);
	}
}

final simulated function SeasonalEventStats_OnZedKilledByHeadshot(class<KFPawn_Monster> MonsterClass, int Difficulty, class<DamageType> DT)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnZedKilledByHeadshot(MonsterClass, Difficulty, DT);
	}
}

final simulated function SeasonalEventStats_OnBossDied()
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnBossDied();
	}
}

final simulated function SeasonalEventStats_OnTriggerUsed(class<Trigger_PawnsOnly> TriggerClass)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnTriggerUsed(TriggerClass);
	}
}

final simulated function SeasonalEventStats_OnTryCompleteObjective(int ObjectiveIndex, int EventIndex)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnTryCompleteObjective(ObjectiveIndex, EventIndex);
	}
}

final simulated function SeasonalEventStats_OnWeaponPurchased(class<KFWeaponDefinition> WeaponDef, int Price)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnWeaponPurchased(WeaponDef, Price);
	}
}

final simulated function SeasonalEventStats_OnAfflictionCaused(EAfflictionType Type)
{
	if (SeasonalEventIsValid())
	{
		SeasonalEvent.OnAfflictionCaused(Type);
	}
}

/*********************************************************************************************
* @name Dailies and daily-specific tracking
********************************************************************************************* */
/** Cache the state of our daily event progress.  If we find a day change while doing so, clear progress */
native final function CacheDailyEventProgress(int Value);

/** Tracking for DOT_WeaponDamage type events */
native final function AddTrackedDamage(int Amount, class<DamageType> DamageType);

/** Tracking for DOT_Versus damage type events */
native final function AddTrackedVsDamage(int Amount, class<KFPawn> DamagerClass);

/** Tracking for DOT_PerkXP daily objectives */
native private final function AddTrackedXP(class<KFPerk> PerkClass, int XPGain);

/** Tracking for DOT_MapCompletion daily objectives */
native private final function AddTrackedMapCompletion(string MapName, byte Difficulty);

/** Tracking for DOT_Versus objectives that use round end for completion */
native private final function AddTrackedRoundEnd(byte WinningTeam);

/** Get a copy of the struct for the requested daily event */
native final function DailyEventInformation GetDailyEventStruct(int Index);

/** Whether or not a specific daily is complete */
native final function bool IsDailyObjectiveComplete(int Index);

/** Accessor for objective current value */
native final function int GetCurrentDailyValue(int Index);

/** Accessor for objective max value */
native final function int GetMaxDailyValue(int Index);

/** Accessor for objective reward value */
native static final function int GetDailyEventReward();

/** Accessor for objective reward value */
native static final function int GetWeeklyEventReward();

/*********************************************************************************************
* @name Dosh Vault
********************************************************************************************* */
native final function int GetTotalDoshCount();
native final function int GetLastSeenDoshCount();
native final function int GetUnseenDoshCount();
native final function MarkDoshVaultSeen();
native static final function int GetDoshVaultTierValue();
native static final function int GetPreStigeValueDoshRewardValue();
native final function CheckUnlockDoshVaultReward();
native final function CheckHasViewedDoshVault();
native final function VerifyDoshVaultCrates();

defaultproperties
{
	bLogStatsWrite=false

	PerRoundWeldXP = 0
	PerRoundHealXP = 0

	// These are the stats we are collecting
	Properties.Add((PropertyId=STATID_Cmdo_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Cmdo_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Bsrk_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Bsrk_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Sup_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Sup_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Fire_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Fire_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Medic_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Medic_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Shrp_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Shrp_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Demo_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Demo_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Surv_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Surv_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Guns_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Guns_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SWAT_Progress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SWAT_Build,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Kills,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_StalkerKills,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Sup_WeldPoints,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_Medic_HealPoints,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_CrawlerKills,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_FleshpoundKills,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_SpecialEventProgress,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_WeeklyEventProgress,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_DailyEventInfo,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_DailyEventIDs,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_DailyEventStats1,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_DailyEventStats2,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SpecialEventKills_DEPRECATED,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SeasonalEventStats1,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SeasonalEventStats2,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SeasonalEventStats3,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SeasonalEventStats4,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_SeasonalEventStats5,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_KnifeKills,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_PistolKills,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_HeadShots,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_Healing,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_Kills,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_Assists,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_LargeZedKill,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_PersonalBest_Dosh,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_MatchWins,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_DoshVaultTotal,Data=(Type=SDT_Int32,Value1=0))
    Properties.Add((PropertyId=STATID_LastViewedDoshVaultTotal,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_DoshVaultProgress,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId=STATID_DoshVaultRecovered,Data=(Type=SDT_Int32,Value1=0))

	// These are the views we are writing to
	ViewIds(0)=VIEWID_KFGameStats

	XPTable(0)=795
	XPTable(1)=940
	XPTable(2)=1112
	XPTable(3)=1315
	XPTable(4)=1556
	XPTable(5)=1841
	XPTable(6)=2178
	XPTable(7)=2576
	XPTable(8)=3047
	XPTable(9)=3604
	XPTable(10)=4263
	XPTable(11)=5043
	XPTable(12)=5965
	XPTable(13)=7056
	XPTable(14)=8347
	XPTable(15)=9874
	XPTable(16)=11680
	XPTable(17)=13816
	XPTable(18)=16343
	XPTable(19)=19332
	XPTable(20)=22868
	XPTable(21)=27051
	XPTable(22)=31999
	XPTable(23)=37852
	XPTable(24)=44775

    //Base Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,SecondaryType=DOST_KnifeDamage,ObjectiveClasses=(KFWeap_Edged_Knife,KFDT_Slashing_Knife,KFDT_Slashing_Knife_Berserker,KFDT_Slashing_Knife_Medic,KFDT_Slashing_Knife_SWAT,KFDT_Slashing_KnifeHeavy,KFDT_Slashing_KnifeHeavy_Berserker,KFDT_Slashing_KnifeHeavy_Medic,KFDT_Slashing_KnifeHeavy_SWAT,KFDT_Piercing_KnifeStab,KFDT_Piercing_KnifeStab_Berserker,KFDT_Piercing_KnifeStab_FieldMedic,KFDT_Piercing_KnifeStab_SWAT,KFDT_Slashing_Knife_Survivalist,KFDT_Piercing_KnifeStab_Survivalist,KFDT_Slashing_KnifeHeavy_Survivalist),CompletionAmount=2500))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_9mm, KFDT_Ballistic_9mm,KFDT_Bludgeon_9mm),CompletionAmount=4000)) //2500

    //Swat Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_SMG_MP7, KFDT_Ballistic_MP7,KFDT_Bludgeon_MP7),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_SMG_MP5RAS, KFDT_Ballistic_MP5RAS,KFDT_Bludgeon_MP5RAS),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_Thompson, KFDT_Ballistic_Thompson,KFDT_Bludgeon_Thompson),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Nailgun, KFDT_Ballistic_HRGNailgun, KFDT_Bludgeon_HRGNailgun),CompletionAmount=10000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_SMG_P90, KFDT_Ballistic_P90,KFDT_Bludgeon_P90),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Stunner, KFDT_Ballistic_HRG_Stunner,KFDT_Ballistic_HRG_Stunner_Alt,KFDT_Explosive_HRG_Stunner,KFDT_Bludgeon_HRG_Stunner),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_SMG_Kriss, KFDT_Ballistic_Kriss,KFDT_Bludgeon_Kriss),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_SMG_HK_UMP, KFDT_Ballistic_HK_UMP,KFDT_Bludgeon_HK_UMP),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_BarrierRifle, KFDT_Ballistic_HRG_BarrierRifle,KFDT_Bludgeon_HRG_BarrierRifle),CompletionAmount=10000))

    //Commando Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_AR15, KFDT_Ballistic_AR15,KFDT_Bludgeon_AR15),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_Bullpup, KFDT_Ballistic_Bullpup,KFDT_Bludgeon_Bullpup),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_AK12, KFDT_Ballistic_AK12,KFDT_Bludgeon_AK12),CompletionAmount=10000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_SCAR, KFDT_Ballistic_SCAR,KFDT_Bludgeon_SCAR),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_MKB42, KFDT_Ballistic_MKB42,KFDT_Bludgeon_MKB42),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_LMG_Stoner63A, KFDT_Ballistic_Stoner63A,KFDT_Bludgeon_Stoner63A),CompletionAmount=10000))

    //Support Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_MB500, KFDT_Ballistic_MB500,KFDT_Bludgeon_MB500),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_DoubleBarrel, KFDT_Ballistic_DBShotgun,KFDT_Bludgeon_DBShotgun),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Revolver_Buckshot, KFDT_Ballistic_HRGBuckshot, KFDT_Bludgeon_HRGBuckshot),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_HZ12, KFDT_Ballistic_HZ12,KFDT_Bludgeon_HZ12),CompletionAmount=10000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_M4, KFDT_Ballistic_M4Shotgun,KFDT_Bludgeon_M4Shotgun),CompletionAmount=10000)) //7000
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_AA12, KFDT_Ballistic_AA12Shotgun,KFDT_Bludgeon_AA12Shotgun),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_ElephantGun, KFDT_Ballistic_ElephantGun,KFDT_Bludgeon_ElephantGun),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_BlastBrawlers, KFDT_Ballistic_BlastBrawlersShotgun,KFDT_Bludgeon_BlastBrawlers,KFDT_Bludgeon_BlastBrawlersHeavy,KFDT_Bludgeon_BlastBrawlersBash),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_BallisticBouncer, KFDT_Bludgeon_HRG_BallisticBouncer_Shot,KFDT_Bludgeon_HRG_BallisticBouncer),CompletionAmount=10000))

    //Medic Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_Medic, KFDT_Ballistic_Pistol_Medic,KFDT_Bludgeon_Pistol_Medic),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_SMG_Medic, KFDT_Ballistic_SMG_Medic,KFDT_Bludgeon_SMG_Medic),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_Medic, KFDT_Ballistic_Shotgun_Medic,KFDT_Bludgeon_Shotgun_Medic),CompletionAmount=9000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Healthrower, KFDT_Toxic_HRGHealthrower, KFDT_Bludgeon_HRGHealthrower),CompletionAmount=9000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Rifle_Hemogoblin, KFDT_Ballistic_Hemogoblin, KFDT_Bludgeon_Hemogoblin),CompletionAmount=9000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_Medic, KFDT_Ballistic_Assault_Medic,KFDT_Bludgeon_Assault_Medic),CompletionAmount=9000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Rifle_HRGIncision, KFDT_Ballistic_HRGIncisionHurt, KFDT_Ballistic_HRGIncisionHeal,KFDT_Bludgeon_HRGIncision),CompletionAmount=5000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Vampire, KFDT_Bleeding_HRG_Vampire_BloodSuck, KFDT_Ballistic_HRG_Vampire_BloodBallImpact, KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact, KFDT_Toxic_HRG_Vampire_BloodBall, KFDT_Piercing_HRG_Vampire_CrystalSpike, KFDT_Bludgeon_HRG_Vampire),CompletionAmount=9000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_MedicRifleGrenadeLauncher, KFDT_Ballistic_MedicRifleGrenadeLauncher, KFDT_Bludgeon_MedicRifleGrenadeLauncher, KFDT_Toxic_MedicGrenadeLauncher, KFDT_Ballistic_MedicRifleGrenadeLauncherImpact),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_MedicMissile, KFDT_Explosive_HRG_MedicMissile, KFDT_Bludgeon_HRG_MedicMissile, KFDT_Toxic_HRG_MedicMissile, KFDT_Ballistic_HRG_MedicMissile),CompletionAmount=9000))

    //Demo Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_GrenadeLauncher_HX25, KFDT_ExplosiveSubmunition_HX25,KFDT_Ballistic_HX25Impact,KFDT_Ballistic_HX25SubmunitionImpact,KFDT_Bludgeon_HX25),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Thrown_C4, KFDT_Explosive_C4,KFDT_Bludgeon_C4),CompletionAmount=2500))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_GrenadeLauncher_M79, KFDT_Ballistic_M79Impact,KFDT_Explosive_M79,KFDT_Bludgeon_M79),CompletionAmount=7000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Boomy, KFDT_Ballistic_HRG_Boomy,KFDT_Explosive_HRG_Boomy,KFDT_Bludgeon_HRG_Boomy),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Crossboom, KFDT_Piercing_HRG_Crossboom,KFDT_Explosive_HRG_Crossboom,KFDT_Explosive_HRG_CrossboomAlt,KFDT_Bludgeon_HRG_Crossboom),CompletionAmount=7000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_HRG_Kaboomstick, KFDT_Ballistic_HRG_Kaboomstick,KFDT_Explosive_HRG_Kaboomstick,KFDT_Bludgeon_HRG_Kaboomstick),CompletionAmount=9000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_RocketLauncher_RPG7, KFDT_Ballistic_RPG7Impact,KFDT_Explosive_RPG7,KFDT_Explosive_RPG7BackBlast,KFDT_Bludgeon_RPG7),CompletionAmount=7500))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_M16M203, KFDT_Ballistic_M16M203,KFDT_Bludgeon_M16M203,KFDT_Ballistic_M203Impact,KFDT_Explosive_M16M203),CompletionAmount=9000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_RocketLauncher_SealSqueal, KFDT_Bludgeon_SealSqueal, KFDT_Explosive_SealSqueal, KFDT_Ballistic_SealSquealImpact),CompletionAmount=7500))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_RocketLauncher_Seeker6, KFDT_Explosive_Seeker6, KFDT_Bludgeon_Seeker6, KFDT_Ballistic_Seeker6Impact),CompletionAmount=7500))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_GrenadeLauncher_M32, KFDT_Bludgeon_M32, KFDT_Explosive_M32, KFDT_Ballistic_M32Impact),CompletionAmount=10000))

    //Firebug Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Flame_CaulkBurn, KFDT_Bludgeon_CaulkBurn,KFDT_Fire_CaulkBurn,KFDT_Fire_Ground_CaulkNBurn),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_Flare, KFDT_Bludgeon_FlareGun,KFDT_Fire_FlareGun,KFDT_Fire_FlareGun_Dual,KFDT_Fire_FlareGunDoT),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_DragonsBreath, KFDT_Ballistic_DragonsBreath,KFDT_Bludgeon_DragonsBreath,KFDT_Fire_DragonsBreathDoT, KFDT_Fire_Ground_DragonsBreath),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_SMG_Mac10, KFDT_Bludgeon_Mac10,KFDT_Fire_Mac10,KFDT_Fire_Mac10DoT),CompletionAmount=9000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Flame_Flamethrower, KFDT_Bludgeon_Flamethrower,KFDT_Fire_FlameThrower,KFDT_Fire_Ground_FlameThrower),CompletionAmount=9000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_HRGIncendiaryRifle, KFDT_Bludgeon_HRGIncendiaryRifle,KFDT_Ballistic_HRGIncendiaryRifle,KFDT_Explosive_HRGIncendiaryRifle,KFDT_Ballistic_HRGIncendiaryRifleGrenadeImpact,KFDT_Fire_HRGIncendiaryRifleBulletDoT,KFDT_Fire_HRGIncendiaryRifleGrenadeDoT,KFDT_Fire_Ground_HRGIncendiaryRifle),CompletionAmount=9000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_HRGScorcher, KFDT_Bludgeon_HRGScorcher,KFDT_Ballistic_HRGScorcherLightingImpact,KFDT_Fire_HRGScorcherDoT,KFDT_Ballistic_HRGScorcherBrokenImpact,KFDT_Fire_Ground_HRGScorcher),CompletionAmount=9000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Beam_Microwave, KFDT_Bludgeon_MicrowaveGun,KFDT_Fire_Ground_MicrowaveGun,KFDT_Microwave,KFDT_Microwave_Beam,KFDT_Microwave_Blast),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HuskCannon, KFDT_Bludgeon_HuskCannon, KFDT_Explosive_HuskCannon, KFDT_HuskCannonDot, KFDT_Explosive_HuskCannonImpact),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Dragonbreath, KFDT_Ballistic_HRG_Dragonbreath, KFDT_Bludgeon_HRG_Dragonbreath, KFDT_Fire_HRG_DragonsBreathDoT, KFDT_Fire_HRG_DragonsBreathDoT, KFDT_Fire_Ground_HRG_DragonBreath),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_Microwave, KFDT_Ballistic_MicrowaveRifle, KFDT_Fire_MicrowaveRifleDoT, KFDT_Bludgeon_MicrowaveRifle),CompletionAmount=10000))
	
    //Berserker Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Blunt_Crovel, KFDT_Bludgeon_Crovel,KFDT_Bludgeon_CrovelBash,KFDT_Slashing_Crovel),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Shotgun_Nailgun, KFDT_Ballistic_NailShotgun,KFDT_Bludgeon_NailShotgun),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Edged_Katana, KFDT_Slashing_Katana,KFDT_Piercing_KatanaStab, KFDT_Slashing_KatanaHeavy),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Edged_FireAxe, KFDT_Bludgeon_FireAxeBash,KFDT_Slashing_FireAxe,KFDT_Slashing_FireAxeHeavy),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Blunt_Pulverizer, KFDT_Bludgeon_Pulverizer,KFDT_Bludgeon_PulverizerBash,KFDT_Bludgeon_PulverizerHeavy,KFDT_Explosive_Pulverizer),CompletionAmount=10000)) //7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Blunt_MedicBat, KFDT_Bludgeon_MedicBatBash,KFDT_Bludgeon_MedicBatHeavy,KFDT_Bludgeon_MedicBatLight,KFDT_Toxic_MedicBatGas,KFDT_Toxic_MedicBatDoT),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Eviscerator, KFDT_Slashing_Eviscerator,KFDT_Slashing_EvisceratorProj),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Blunt_MaceAndShield, KFDT_Bludgeon_MaceAndShield,KFDT_Bludgeon_MaceAndShield_Bash,KFDT_Bludgeon_MaceAndShield_MaceHeavy,KFDT_Bludgeon_MaceAndShield_ShieldHeavy,KFDT_Bludgeon_MaceAndShield_ShieldLight),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Blunt_PowerGloves, KFDT_Bludgeon_PowerGloves,KFDT_Bludgeon_PowerGlovesBash,KFDT_Bludgeon_PowerGlovesHeavy),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_HRGTeslauncher, KFDT_Ballistic_HRGTeslauncher, KFDT_Fire_HRGTeslauncherDoT, KFDT_Ballistic_HRGTeslauncherGrenadeImpact, KFDT_Bludgeon_HRGTeslauncher, KFDT_EMP_TeslauncherEMPGrenade),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Edged_AbominationAxe, KFDT_Slashing_AbominationAxe,KFDT_Piercing_AbominationAxeStab,KFDT_Slashing_AbominationAxeHeavy),CompletionAmount=10000))

    //Gunslinger Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Revolver_Rem1858, KFDT_Bludgeon_Rem1858,KFDT_Ballistic_Rem1858,KFDT_Ballistic_Rem1858_Dual),CompletionAmount=5000)) //3000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_Colt1911, KFDT_Bludgeon_Colt1911,KFDT_Ballistic_Colt1911),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_HRGWinterbite, KFDT_Bludgeon_HRGWinterbite,KFDT_Freeze_HRGWinterbiteImpact,KFDT_Explosive_HRGWinterbite),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_Deagle, KFDT_Bludgeon_Deagle,KFDT_Ballistic_Deagle),CompletionAmount=10000)) // 7000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Revolver_SW500, KFDT_Bludgeon_SW500,KFDT_Ballistic_SW500,KFDT_Ballistic_SW500_Dual),CompletionAmount=10000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Pistol_AF2011, KFDT_Bludgeon_AF2011,KFDT_Ballistic_AF2011),CompletionAmount=10000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Energy, KFDT_Ballistic_HRG_Energy_Primary,KFDT_Ballistic_HRG_Energy_Secondary, KFDT_Bludgeon_HRG_Energy),CompletionAmount=10000))

    //Sharpshooter Weapons
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Rifle_Winchester1894, KFDT_Bludgeon_Winchester,KFDT_Ballistic_Winchester),CompletionAmount=5000)) //2000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Bow_Crossbow, KFDT_Bludgeon_Crossbow,KFDT_Piercing_Crossbow),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Rifle_M14EBR, KFDT_Bludgeon_M14EBR,KFDT_Ballistic_M14EBR),CompletionAmount=9000)) //7000
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_SonicGun, KFDT_Bludgeon_HRG_SonicGun, KFDT_Ballistic_HRG_SonicGun_SonicBlastUncharged, KFDT_Ballistic_HRG_SonicGun_SonicBlastHalfCharged, KFDT_Ballistic_HRG_SonicGun_SonicBlastFullyCharged),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_CranialPopper, KFDT_Bludgeon_HRG_CranialPopper,KFDT_Piercing_HRG_CranialPopper,KFDT_Blast_HRG_CranialPopper),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Rifle_RailGun, KFDT_Bludgeon_RailGun,KFDT_Ballistic_RailGun),CompletionAmount=5000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Rifle_CenterfireMB464, KFDT_Bludgeon_CenterfireMB464,KFDT_Ballistic_CenterfireMB464),CompletionAmount=7000)) //5000
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Rifle_M99, KFDT_Bludgeon_M99,KFDT_Ballistic_M99),CompletionAmount=5000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_FNFal, KFDT_Ballistic_FNFal,KFDT_Bludgeon_FNFal),CompletionAmount=10000))

    //Survivalist Weapons
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_Locust, KFDT_Bludgeon_HRG_Locust, KFDT_Toxic_HRG_Locust, KFDT_Ballistic_HRG_Locust),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_Ice_FreezeThrower, KFDT_Bludgeon_Freezethrower, KFDT_Freeze_FreezeThrower, KFDT_Freeze_FreezeThrower_IceShards, KFDT_Freeze_Ground_FreezeThrower),CompletionAmount=7000))
    DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_HRG_EMP_ArcGenerator, KFDT_Bludgeon_ArcGenerator, KFDT_EMP_ArcGenerator_Beam, KFDT_EMP_ArcGeneratorSphereImpact, KFDT_EMP_ArcGenerator_DefaultFiremodeZapDamage, KFDT_EMP_ArcGenerator_AltFiremodeZapDamage),CompletionAmount=9000))
	DailyEvents.Add((ObjectiveType=DOT_WeaponDamage,ObjectiveClasses=(KFWeap_AssaultRifle_LazerCutter, KFDT_Ballistic_LazerCutter, KFDT_LazerCutter_Beam, KFDT_Bludgeon_LazerCutter),CompletionAmount=10000))

    //Kills
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedClot_Alpha),CompletionAmount=20))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedClot_AlphaKing),CompletionAmount=5))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedClot_Cyst),CompletionAmount=30))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedClot_Slasher),CompletionAmount=25))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedCrawler),CompletionAmount=30))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedCrawlerKing),CompletionAmount=5))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedStalker),CompletionAmount=10))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedBloat),CompletionAmount=5))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedSiren),CompletionAmount=5))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedHusk),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedGorefast),CompletionAmount=20))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedGorefastDualBlade),CompletionAmount=8))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedScrake),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedFleshpound),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedFleshpoundMini),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedDAR_EMP),CompletionAmount=5))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedDAR_Laser),CompletionAmount=5))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillZeds,ObjectiveClasses=(KFPawn_ZedDAR_Rocket),CompletionAmount=5))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_KillBoss,CompletionAmount=1)

    //Perk XP
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Berserker),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Commando),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Demolitionist),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_FieldMedic),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Firebug),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Gunslinger),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Sharpshooter),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Support),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_Survivalist),CompletionAmount=1500))
    DailyEvents.Add((ObjectiveType=DOT_PerkXP,SecondaryType=DOST_PlayPerk,ObjectiveClasses=(KFPerk_SWAT),CompletionAmount=1500))

    //Map Completion
    //Note: completion amount for these is the map difficulty
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BURNINGPARIS),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BURNINGPARIS),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BURNINGPARIS),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-OUTPOST),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-OUTPOST),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-OUTPOST),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BIOTICSLAB),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BIOTICSLAB),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BIOTICSLAB),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-VOLTERMANOR),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-VOLTERMANOR),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-VOLTERMANOR),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-EVACUATIONPOINT),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-EVACUATIONPOINT),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-EVACUATIONPOINT),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CATACOMBS),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CATACOMBS),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CATACOMBS),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BLACKFOREST),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BLACKFOREST),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BLACKFOREST),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-FARMHOUSE),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-FARMHOUSE),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-FARMHOUSE),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-PRISON),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-PRISON),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-PRISON),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CONTAINMENTSTATION),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CONTAINMENTSTATION),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CONTAINMENTSTATION),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-HOSTILEGROUNDS),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-HOSTILEGROUNDS),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-HOSTILEGROUNDS),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-INFERNALREALM),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-INFERNALREALM),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-INFERNALREALM),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ZEDLANDING),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ZEDLANDING),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ZEDLANDING),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-THEDESCENT),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-THEDESCENT),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-THEDESCENT),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NUKED),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NUKED),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NUKED),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-TRAGICKINGDOM),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-TRAGICKINGDOM),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-TRAGICKINGDOM),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NIGHTMARE),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NIGHTMARE),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NIGHTMARE),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-KRAMPUSLAIR),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-KRAMPUSLAIR),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-KRAMPUSLAIR),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-POWERCORE_HOLDOUT),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-POWERCORE_HOLDOUT),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-POWERCORE_HOLDOUT),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-AIRSHIP),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-AIRSHIP),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-AIRSHIP),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-LOCKDOWN),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-LOCKDOWN),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-LOCKDOWN),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-MONSTERBALL),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-MONSTERBALL),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-MONSTERBALL),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SHOPPINGSPREE),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SHOPPINGSPREE),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SHOPPINGSPREE),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SANTASWORKSHOP),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SANTASWORKSHOP),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SANTASWORKSHOP),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SPILLWAY),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SPILLWAY),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SPILLWAY),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-STEAMFORTRESS),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-STEAMFORTRESS),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-STEAMFORTRESS),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ASHWOODASYLUM),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ASHWOODASYLUM),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ASHWOODASYLUM),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SANITARIUM),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SANITARIUM),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-SANITARIUM),CompletionAmount=3))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BIOLAPSE),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BIOLAPSE),CompletionAmount=2))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BIOLAPSE),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-DESOLATION),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-DESOLATION),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-DESOLATION),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-HELLMARKSTATION),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-HELLMARKSTATION),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-HELLMARKSTATION),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ELYSIUM),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ELYSIUM),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-ELYSIUM),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-DYSTOPIA2029),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-DYSTOPIA2029),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-DYSTOPIA2029),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-MOONBASE),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-MOONBASE),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-MOONBASE),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NETHERHOLD),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NETHERHOLD),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-NETHERHOLD),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CARILLONHAMLET),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CARILLONHAMLET),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CARILLONHAMLET),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-RIG),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-RIG),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-RIG),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BARMWICHTOWN),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BARMWICHTOWN),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-BARMWICHTOWN),CompletionAmount=3))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CRASH),CompletionAmount=1))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CRASH),CompletionAmount=2))
	DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_MapCompletion,ObjectiveClasses=(KF-CRASH),CompletionAmount=3))

    //Versus Damage
    //    Per design doc that I have right now, these are x class damage y players, not damage y amount
    /*DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedClot_Alpha, KFPawn_ZedClot_Alpha_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedClot_Slasher, KFPawn_ZedClot_Slasher_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedCrawler, KFPawn_ZedCrawler_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedStalker, KFPawn_ZedStalker_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedBloat, KFPawn_ZedBloat_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedSiren, KFPawn_ZedSiren_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedHusk, KFPawn_ZedHusk_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusDamage,ObjectiveClasses=(KFPawn_ZedGorefast, KFPawn_ZedGorefast_Versus),CompletionAmount=1))*/

    //Versus Kills
    /*DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusKills,ObjectiveClasses=(KFPawn_ZedScrake, KFPawn_ZedScrake_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusKills,ObjectiveClasses=(KFPawn_ZedFleshPound, KFPawn_ZedFleshPound_Versus),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_VersusKills,ObjectiveClasses=(KFPawn_ZedPatriarch, KFPawn_ZedPatriarch_Versus),CompletionAmount=1))*/

    //Character Completions
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(chr_briar_archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(CHR_MrFoster_archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(CHR_Coleman_archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(CHR_Alberts_archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(CHR_Masterson_archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(CHR_Tanaka_Archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(CHR_Ana_Archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(chr_rockabilly_archetype),CompletionAmount=1))
    DailyEvents.Add((ObjectiveType=DOT_Maps,SecondaryType=DOST_CharacterCompletion,ObjectiveClasses=(CHR_DAR_archetype),CompletionAmount=1))

	SeasonalKillsObjectiveThreshold=2500
}