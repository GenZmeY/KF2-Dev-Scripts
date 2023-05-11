//=============================================================================
// KFOnlineStatsReadDingo
//=============================================================================
// The KF 2 game stats class that holds and modifies the write stats data (XB1 only)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Brandon Johnson 1-4-17
//=============================================================================

class KFOnlineStatsWriteDingo extends KFOnlineStatsWrite;


defaultproperties
{
	// DINGO Properties for Achievement Tracking, these track achievement stats and are used by stats on the xdp backend
		//Possible to only do these on Dingo?
	Properties.Add((PropertyId= STATID_ACHIEVE_MrPerky5,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId= STATID_ACHIEVE_MrPerky10,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId = STATID_ACHIEVE_MrPerky15,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_MrPerky20,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_MrPerky25,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_HardWins,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_SuicidalWins,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId= STATID_ACHIEVE_HellWins,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId= STATID_ACHIEVE_VSZedWins,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId = STATID_ACHIEVE_VSHumanWins,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_HoldOut,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_DieVolter,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId= STATID_ACHIEVE_FleshPoundKill,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId= STATID_ACHIEVE_ShrikeKill,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId = STATID_ACHIEVE_SirenKill,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_Benefactor,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_HealTeam,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_CollectCatacolmbs,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_BioticsCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_EvacsCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_OutpostCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_PrisonCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_ManorCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_ParisCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_FarmhouseCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_BlackForestCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_ContainmentStationCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_InfernalRealmCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_HostileGroundsCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_ZedLandingCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_DescentCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_NukedCollectibles,Data = (Type = SDT_Int32,Value1 = 0))
	Properties.Add((PropertyId = STATID_ACHIEVE_QuickOnTheTrigger,Data = (Type = SDT_Int32,Value1 = 0))
    Properties.Add((PropertyId = STATID_ACHIEVE_TragicKingdomCollectibles,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId = STATID_ACHIEVE_NightmareCollectibles,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId = STATID_ACHIEVE_KrampusCollectibles,Data=(Type=SDT_Int32,Value1=0))
	Properties.Add((PropertyId = STATID_ACHIEVE_ArenaCollectibles,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_PowercoreCollectibles,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_AirshipCollectibles,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_LockdownCollectibles,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_MonsterBallCollectibles,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_MonsterBallSecretRoom,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_SantasWorkshopCollectibles,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_ShoppingSpreeCollectibles,Data=(Type=SDT_Int32,Value1=0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_SpillwayCollectibles,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_SteamFortressCollectibles,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_AsylumCollectibles,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_SanitariumCollectibles,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_DefeatMatriarch,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_BiolapseCollectibles,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_DesolationCollectibles,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_HellmarkStationCollectibles,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_ElysiumEndlessWaveFifteen,Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_Dystopia2029Collectibles, Data = (Type = SDT_Int32,Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_MoonbaseCollectibles, Data = (Type = SDT_Int32, Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_NetherholdCollectibles, Data = (Type = SDT_Int32, Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_CarillonHamletCollectibles, Data = (Type = SDT_Int32, Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_RigCollectibles, Data = (Type = SDT_Int32, Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_BarmwichCollectibles, Data = (Type = SDT_Int32, Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_CrashCollectibles, Data = (Type = SDT_Int32, Value1 = 0)))
	Properties.Add((PropertyId = STATID_ACHIEVE_SubductionCollectibles, Data = (Type = SDT_Int32, Value1 = 0)))
}
