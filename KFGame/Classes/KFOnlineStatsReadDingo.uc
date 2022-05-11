//=============================================================================
// KFOnlineStatsReadDingo
//=============================================================================
// The KF 2 game stats class that holds and modifies the read stats data (XB1 only)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Brandon Johnson 1-4-17
//=============================================================================

class KFOnlineStatsReadDingo extends KFOnlineStatsRead;


defaultproperties
{
	ColumnIds.Add(STATID_ACHIEVE_MrPerky5)
	ColumnIds.Add(STATID_ACHIEVE_MrPerky10)
	ColumnIds.Add(STATID_ACHIEVE_MrPerky15)
	ColumnIds.Add(STATID_ACHIEVE_MrPerky20)
	ColumnIds.Add(STATID_ACHIEVE_MrPerky25)
	ColumnIds.Add(STATID_ACHIEVE_HardWins)
	ColumnIds.Add(STATID_ACHIEVE_SuicidalWins)
	ColumnIds.Add(STATID_ACHIEVE_HellWins)
	ColumnIds.Add(STATID_ACHIEVE_VSZedWins)
	ColumnIds.Add(STATID_ACHIEVE_VSHumanWins)
	ColumnIds.Add(STATID_ACHIEVE_HoldOut)
	ColumnIds.Add(STATID_ACHIEVE_DieVolter)
	ColumnIds.Add(STATID_ACHIEVE_FleshPoundKill)
	ColumnIds.Add(STATID_ACHIEVE_ShrikeKill)
	ColumnIds.Add(STATID_ACHIEVE_SirenKill)
	ColumnIds.Add(STATID_ACHIEVE_Benefactor)
	ColumnIds.Add(STATID_ACHIEVE_HealTeam)
	ColumnIds.Add(STATID_ACHIEVE_CollectCatacolmbs)
	ColumnIds.Add(STATID_ACHIEVE_BioticsCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_EvacsCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_OutpostCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_PrisonCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_ManorCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_ParisCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_FarmhouseCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_BlackForestCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_ContainmentStationCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_InfernalRealmCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_HostileGroundsCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_ZedLandingCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_DescentCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_NukedCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_QuickOnTheTrigger)
    ColumnIds.Add(STATID_ACHIEVE_TragicKingdomCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_NightmareCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_KrampusCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_ArenaCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_PowercoreCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_AirshipCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_LockdownCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_MonsterBallCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_MonsterBallSecretRoom)
	ColumnIds.Add(STATID_ACHIEVE_SantasWorkshopCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_ShoppingSpreeCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_SpillwayCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_SteamFortressCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_AsylumCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_SanitariumCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_DefeatMatriarch)
	ColumnIds.Add(STATID_ACHIEVE_BiolapseCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_DesolationCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_HellmarkStationCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_ElysiumEndlessWaveFifteen)
	ColumnIds.Add(STATID_ACHIEVE_Dystopia2029Collectibles)
	ColumnIds.Add(STATID_ACHIEVE_MoonbaseCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_NetherholdCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_CarillonHamletCollectibles)
	ColumnIds.Add(STATID_ACHIEVE_RigCollectibles)

	ColumnMappings.Add((Id=STATID_ACHIEVE_MrPerky5, Name="AchievementMrPerky5"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_MrPerky10, Name = "AchievementMrPerky10"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_MrPerky15, Name = "AchievementMrPerky15"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_MrPerky20, Name = "AchievementMrPerky20"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_MrPerky25, Name = "AchievementMrPerky25"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_HardWins, Name = "AchievementHardWins"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_SuicidalWins, Name="AchievementSuicidalWins"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_HellWins, Name="AchievementHellWins"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_VSZedWins, Name="AchievementVsZedWins"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_VSHumanWins, Name = "AchievementVsHumanWins"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_HoldOut, Name = "AchievementHoldOut"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_DieVolter, Name = "AchievementDieVolter"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_FleshPoundKill, Name = "AchievementFleshpoundKills"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ShrikeKill, Name = "AchievementShrikeKills"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_SirenKill, Name = "AchievementSirenKill"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_Benefactor, Name = "AchievementBenefactor"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_HealTeam, Name = "AchievementHealTeam"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_CollectCatacolmbs, Name = "AchievementCollectCatacolmbs"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_BioticsCollectibles, Name = "AchievementBioticsCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_EvacsCollectibles, Name = "AchievementEvacsCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_OutpostCollectibles, Name = "AchievementOutpostCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_PrisonCollectibles, Name = "AchievementPrisonCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ManorCollectibles, Name = "AchievementManorCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ParisCollectibles, Name = "AchievementParisCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_FarmhouseCollectibles, Name = "AchievementFarmhouseCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_BlackForestCollectibles, Name = "AchievementBlackForestCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ContainmentStationCollectibles, Name = "AchievementContainmentStationCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_InfernalRealmCollectibles, Name="AchievementInfernalRealmsCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_HostileGroundsCollectibles, Name="AchievementHostileGroundsCollectibles"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ZedLandingCollectibles, Name="AchievementCollectZedLanding"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_DescentCollectibles, Name="AchievementCollectDescent"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_NukedCollectibles, Name="AchievementCollectNuked"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_QuickOnTheTrigger, Name="AchievementQuickOnTheTrigger"))
    ColumnMappings.Add((Id=STATID_ACHIEVE_TragicKingdomCollectibles, Name="AchievementCollectTragicKingdom"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_NightmareCollectibles, Name="AchievementCollectNightmare"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_KrampusCollectibles, Name="AchievementCollectKrampus"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ArenaCollectibles, Name="AchievementCollectDiesector"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_PowercoreCollectibles, Name="AchievementCollectPowercore"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_AirshipCollectibles,Name="AchievementCollectAirship"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_LockdownCollectibles,Name="AchievementCollectLockdown"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_MonsterBallCollectibles,Name="AchievementCollectMonsterBall"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_MonsterBallSecretRoom,Name="AchievementMonsterBallSecretRoom"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_SantasWorkshopCollectibles,Name="AchievementCollectSantasWorkshop"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ShoppingSpreeCollectibles,Name="AchievementCollectShoppingSpree"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_SpillwayCollectibles,Name="AchievementCollectSpillway"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_SteamFortressCollectibles,Name="AchievementCollectSteamFortress"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_AsylumCollectibles,Name="AchievementCollectAsylum"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_SanitariumCollectibles,Name="AchievementCollectSanitarium"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_DefeatMatriarch,Name="AchievementDefeatMatriarch"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_BiolapseCollectibles,Name="AchievementCollectBiolapse"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_DesolationCollectibles,Name="AchievementCollectDesolation"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_HellmarkStationCollectibles,Name="AchievementCollectHellmarkStation"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_ElysiumEndlessWaveFifteen,Name="AchievementEndlessElysium"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_Dystopia2029Collectibles,Name="AchievementCollectDystopia2029"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_MoonbaseCollectibles,Name="AchievementCollectMoonbase"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_NetherholdCollectibles,Name="AchievementCollectNetherhold"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_CarillonHamletCollectibles,Name="AchievementCollectCarillonHamlet"))
	ColumnMappings.Add((Id=STATID_ACHIEVE_RigCollectibles,Name="AchievementCollectRig"))
}
