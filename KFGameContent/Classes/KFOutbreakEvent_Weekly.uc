//=============================================================================
// KFGameDifficulty_Weekly
//=============================================================================
// Zed adjustments used in Weekly outbreak.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFOutbreakEvent_Weekly extends KFOutbreakEvent;

function OnScoreKill(Pawn KilledPawn)
{
    local int WaveNum;

    if (!ActiveEvent.bBossRushMode)
    {
       AdjustScoreKill(KilledPawn, ActiveEvent.ZedsToAdjust);
    }
    else
    {
        WaveNum = KFGameInfo_WeeklySurvival(Outer).WaveNum - 1;
        if ( WaveNum < ActiveEvent.BossRushOverrideParams.PerWaves.length )
        {
            AdjustScoreKill(KilledPawn, ActiveEvent.BossRushOverrideParams.PerWaves[WaveNum].ZedsToAdjust);
        }
    }
}

function AdjustScoreKill(Pawn KilledPawn, array <StatAdjustments> Adjustments)
{
    local StatAdjustments ToAdjust;

    foreach Adjustments(ToAdjust)
    {
        if (ClassIsChildOf(KilledPawn.class, ToAdjust.ClassToAdjust))
        {
            if (ToAdjust.bExplosiveDeath && ToAdjust.ExplosionTemplate != none)
            {
                //Skip if we shouldn't do the normal death explosion
                if (KFPawn(KilledPawn) != none && !KFPawn(KilledPawn).WeeklyShouldExplodeOnDeath())
                {
                    return;
                }

                KFGameInfo_WeeklySurvival(Outer).DoDeathExplosion(KilledPawn, ToAdjust.ExplosionTemplate, ToAdjust.ExplosionIgnoreClass);
            }
        }
    }
}

function AdjustScoreDamage(Controller InstigatedBy, Pawn DamagedPawn, class<DamageType> damageType)
{
	super.AdjustScoreDamage(InstigatedBy, DamagedPawn, damageType);

	if (ActiveEvent.bUseBeefcakeRules)
	{
		if (InstigatedBy != none)
		{
			AdjustForBeefcakeRules(InstigatedBy.Pawn);
		}

		if (DamagedPawn != none && damageType == class'KFDT_Toxic_PlayerCrawlerSuicide')
		{
			AdjustForBeefcakeRules(DamagedPawn, EBT_StalkerPoison);
		}
	}
}

static function int GetOutbreakId(int SetEventsIndex)
{
	if (SetEventsIndex < 0 || SetEventsIndex >= default.SetEvents.length)
	{
		return INDEX_NONE;
	}

	return SetEventsIndex;
}

defaultproperties
{
	//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    //!!! Things to change when the order of this list changes or we add new modes !!!
    //
    // - UKFOnlineStatsWrite::GrantWeeklyOutbreakItems for granted inventory items
    // - WE_CurrentEventsListSize in KFOnlineStats.cpp
    // - Config patch for DefaultGame.ini to update index KFWeeklyOutBreakInformation entries
    // - KFGame.int for new KFWeeklyOutBreakInformation entries

    //Mode Types

    //Boom
    SetEvents[0]={(
                    EventDifficulty=1,
                    GameLength=GL_Normal,
                    MaxBoomsPerFrame=3,
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
									(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.PawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster'),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',bStartEnraged=true,bExplosiveDeath=true,ExplosionTemplate=KFGameExplosion'GP_Weekly_ARCH.BigPawnExplosionTemplate',ExplosionIgnoreClass=class'KFPawn_Monster')
                    )}
    )}

    //Zombies
    SetEvents[1]={(
                    EventDifficulty=1,
                    GameLength=GL_Normal,
                    bHeadshotsOnly=true,
                    SpawnReplacementList={(
                                            
                                            (SpawnEntry=AT_Stalker,NewClass=(class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=1.0),
                                            (SpawnEntry=AT_Husk,NewClass=(class'KFGameContent.KFPawn_ZedBloat'),PercentChance=1.0)
                    )},
                    BossSpawnReplacementList={(
                                            (SpawnEntry=BAT_Matriarch,NewClass=class'KFGameContent.KFPawn_ZedPatriarch')
                    )},
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=0.50), // HealthScale = 0.25, then .40
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=0.75,ShieldScale=0.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=0.75,ShieldScale=0.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=0.40,ShieldScale=0.75), //HealthScale = 0.25, Shieldscale = 1.0
									(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=0.6,ShieldScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale=0.25),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundmini',HealthScale=0.9), //HealthScale = 1.0
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',HealthScale=0.05),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',HealthScale=0.05),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',HealthScale=0.05)
                    )}
    )}

    //Tiny Terrors
    SetEvents[2]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    SpawnRateMultiplier=1.0, //10.0
                    bScaleOnHealth=true,
                    StartingDamageSizeScale=1.0,
                    DeadDamageSizeScale=0.5
    )}

    //Big head
    SetEvents[3]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    ZedSpawnHeadScale=2.7,  //3.0
                    PlayerSpawnHeadScale=2.0,
                    bDisableHeadless=true,
                    SpawnRateMultiplier=2.5, //2.0
                    WaveAICountScale=(0.7, 0.7, 0.7, 0.7, 0.7, 0.7),  //0.7
                    GlobalAmmoCostScale = 0.5,   //half the normal amount
                    BossSpawnReplacementList={(
                                            (SpawnEntry=BAT_Matriarch,NewClass=class'KFGameContent.KFPawn_ZedHans')
                    )},
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthScale=3.0,HeadHealthScale=3.0), //4
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthScale=3.0,HeadHealthScale=4.5), //5
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthScale=3.0,HeadHealthScale=4.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthScale=3.0,HeadHealthScale=4.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthScale=1.5,HeadHealthScale=1.5),   // reduced
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthScale=3.0,HeadHealthScale=5.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthScale=3.0,HeadHealthScale=5.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthScale=2.0,HeadHealthScale=1.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthScale=3.0,HeadHealthScale=2.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=3.0,HeadHealthScale=2.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=1.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=1.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=1.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=2.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=1.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthScale=2.0,HeadHealthScale=2.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthScale=3.0,HeadHealthScale=3.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthScale=3.0,HeadHealthScale=3.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthScale=3.0,HeadHealthScale=2.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundmini',HealthScale=1.5,HeadHealthScale=1.1)
                    )}
    )}

    //Pound Ammonium
    SetEvents[4]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    WaveAICountScale=(0.55, 0.55, 0.55, 0.55, 0.55, 0.55), //This is per player-count 0.75
                    SpawnReplacementList={(
                                            (SpawnEntry=AT_AlphaClot,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundMini'),PercentChance=0.05), //0.5
                                            (SpawnEntry=AT_SlasherClot,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundMini'),PercentChance=0.1), //0.05
                                            (SpawnEntry=AT_GoreFast,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundMini'),PercentChance=0.1), //0.05
                                            (SpawnEntry=AT_Crawler,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundmini'),PercentChance=0.05),
                                            (SpawnEntry=AT_Stalker,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundmini'),PercentChance=0.05),
                                            (SpawnEntry=AT_Scrake,NewClass=(class'KFGameContent.KFPawn_ZedFleshpound'),PercentChance=0.9),
                                            (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundMini'),PercentChance=0.65) //0.65
                    )},
                    BossSpawnReplacementList={(
                                            (SpawnEntry=BAT_Hans,NewClass=class'KFGameContent.KFPawn_ZedFleshpoundKing'),
                                            (SpawnEntry=BAT_Patriarch,NewClass=class'KFGameContent.KFPawn_ZedFleshpoundKing'),
                                            (SpawnEntry=BAT_Matriarch,NewClass=class'KFGameContent.KFPawn_ZedFleshpoundKing'),
											(SpawnEntry=BAT_KingBloat,NewClass=class'KFGameContent.KFPawn_ZedFleshpoundKing')
                    )},
                    ZedsToAdjust={(
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=1.0,bStartEnraged=true) //3.45
                    )}
    )}

    //Death Balloons
    SetEvents[5]={(
                    EventDifficulty=1,
                    GameLength=GL_Normal,
                    bUseZedDamageInflation = true,
                    ZeroHealthInflation = 3.0,
                    GlobalDeflationRate = 0.1, //0.1
                    InflationDeathGravity = -0.57, //.025
                    InflationExplosionTimer = 1.7, //3.0
                    WaveAICountScale=(0.7, 0.7, 0.7, 0.7, 0.7, 0.7), //This is per player-count
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthScale=1.0,HeadHealthScale=1.2), //4
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthScale=2.0,HeadHealthScale=2.5), //5
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthScale=2.0,HeadHealthScale=2.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthScale=2.0,HeadHealthScale=2.5),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthScale=0.4,HeadHealthScale=1.5), //0.7  2.0
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthScale=3.0,HeadHealthScale=6.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthScale=3.0,HeadHealthScale=6.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthScale=0.35,HeadHealthScale=2.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthScale=1.0,HeadHealthScale=3.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=0.75,HeadHealthScale=1.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=1.0,ShieldScale=1.25,OverrideDeflationRate=(X=0.01,Y=0.005)),     //health 0.5 Y = 0.01
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=1.1,OverrideDeflationRate=(X=0.01,Y=0.01)),   //health 0.5 Y = 0.02
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=0.5,OverrideDeflationRate=(X=0.01,Y=0.01)), 
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=0.5,OverrideDeflationRate=(X=0.01,Y=0.01)),   //health 0.5 Y = 0.02
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=0.70,OverrideDeflationRate=(X=0.01,Y=0.01)),   //health 0.5 Healthscale 1.1 X = 0.01 Y = 0.02
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthScale=1.0,HeadHealthScale=1.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthScale=0.5,HeadHealthScale=1.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthScale=1.0,HeadHealthScale=1.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealthScale=3.5,HeadHealthScale=5.0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundmini',HealthScale=0.70,HeadHealthScale=0.75)
                    )}
    )}
    //Zed Time
    SetEvents[6]={(
                    EventDifficulty=3,
                    bPermanentZedTime = true,
                    SpawnRateMultiplier=15.0, //10.0
                    OverrideZedTimeSlomoScale = 0.5,
                    ZedTimeRadius=1450.0, //1024
                    ZedTimeBossRadius=2048.0,
                    ZedTimeHeight=512.0,
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=0.8,DamageDealtScale=0.85),  //health0.75way to weak   damage0.6
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=0.8,DamageDealtScale=0.85),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=0.7,DamageDealtScale=0.7),  //health0.75  damage0.6
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=0.8,DamageDealtScale=0.85),
									(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=0.8,DamageDealtScale=0.85),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',DamageDealtScale=0.6), //4
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',DamageDealtScale=0.6), //5
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',DamageDealtScale=0.6), //0.7  2.0
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',DamageDealtScale=0.6)
                    )},
                    SpawnReplacementList={(
                                            (SpawnEntry=AT_Stalker,NewClass=(class'KFGameContent.KFPawn_ZedScrake'),PercentChance=0.07)
                    )},
                    PermanentZedTimeCutoff = 6,
                    OverrideSpawnDerateTime = 0.0,
                    OverrideTeleportDerateTime = 0.0,
                    WaveAICountScale=(0.5, 0.5, 0.5, 0.5, 0.5, 0.5), //This is per player-count
                    MaxPerkLevel=3,
                    bAllowSpawnReplacementDuringBossWave=false
    )}

    //Cartman
    SetEvents[7]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    bUseBeefcakeRules=true,
                    WaveAICountScale=(0.75, 0.75, 0.75, 0.75, 0.75, 0.75), //This is per player-count

                    //Beefcake notes: Scale and health increase are per event type.  For example:
                    //                          BeefcakeScaleIncreases=(0.05,0.10,0.15,0.20)
                    //                This results in a scale increase of 0.05 for every damage application, 0.10 for every rally application, 0.15 for every scream application, 0.20 for every King Stalker cloud.
                    //                The types of applications are listed in enum BeefcakeType and should have a slot for all types, even if it's 0.0.
                    ZedsToAdjust={(
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=4.5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=4.5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=4.5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=4.5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.5,0.5,0.5,0.5),MaxBeefcakeHealth=3.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=3.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=3.5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',BeefcakeScaleIncreases=(0.1,0.5,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=4.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.9,0.5,0.5,0.5),MaxBeefcakeHealth=3.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',BeefcakeScaleIncreases=(0.05,0.05,0.02,0.02),MaxBeefcake=1.5,BeefcakeHealthIncreases=(0.2,0.2,0.2,0.2),MaxBeefcakeHealth=2.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',BeefcakeScaleIncreases=(0.05,0.1,0.02,0.02),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.2,0.2,0.2,0.2),MaxBeefcakeHealth=3.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',BeefcakeScaleIncreases=(0.05,0.1,0.02,0.02),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.2,0.2,0.2,0.2),MaxBeefcakeHealth=2.5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',BeefcakeScaleIncreases=(0.05,0.1,0.02,0.02),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.2,0.2,0.2,0.2),MaxBeefcakeHealth=2.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',BeefcakeScaleIncreases=(0.05,0.1,0.02,0.02),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.2,0.2,0.2,0.2),MaxBeefcakeHealth=2.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',BeefcakeScaleIncreases=(0.05,0.1,0.02,0.02),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.2,0.2,0.2,0.2),MaxBeefcakeHealth=2.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',BeefcakeScaleIncreases=(0.05,0.2,0.02,0.02),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.0,0.0,0.0,0.0),MaxBeefcakeHealth=1.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',BeefcakeScaleIncreases=(0.05,0.2,0.02,0.02),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.0,0.0,0.0,0.0),MaxBeefcakeHealth=1.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',BeefcakeScaleIncreases=(0.01,0.01,0.01,0.01),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.0,0.0,0.0,0.0),MaxBeefcakeHealth=1.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',BeefcakeScaleIncreases=(0.01,0.01,0.01,0.01),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.0,0.0,0.0,0.0),MaxBeefcakeHealth=1.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',BeefcakeScaleIncreases=(0.01,0.01,0.01,0.01),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.0,0.0,0.0,0.0),MaxBeefcakeHealth=1.0),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',BeefcakeScaleIncreases=(0.01,0.01,0.01,0.01),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.0,0.0,0.0,0.0),MaxBeefcakeHealth=1.0),
								(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',BeefcakeScaleIncreases=(0.01,0.01,0.01,0.01),MaxBeefcake=1.25,BeefcakeHealthIncreases=(0.0,0.0,0.0,0.0),MaxBeefcakeHealth=1.0)
					)}
    )}

    //Blood Thirst
    SetEvents[8]={(
                    EventDifficulty = 1, //2
                    GameLength = GL_Normal,
                    GlobalDamageTickRate = 2.0,
                    GlobalDamageTickAmount = 6.0, //5.0,
                    bHealAfterKill = true,
                    bCannotBeHealed = true,
                    bGlobalDamageAffectsShield = false,
                    bHealPlayerAfterWave = true,
                    bApplyGlobalDamageBossWave = false,
                    DamageDelayAfterWaveStarted = 10.0f,
                    SpawnRateMultiplier=6.0, //8.0,
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=1.0,DamageDealtScale=0.75),
									(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=1.0,DamageDealtScale=0.75)
                    )},
                    ZedsToAdjust={(
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealByKill=5,HealByAssistance=3, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealByKill=5,HealByAssistance=3, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealByKill=10,HealByAssistance=7, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealByKill=5,HealByAssistance=3, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealByKill=12,HealByAssistance=8, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealByKill=7,HealByAssistance=5, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealByKill=5,HealByAssistance=3, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealByKill=10,HealByAssistance=7, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealByKill=7,HealByAssistance=5, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealByKill=10,HealByAssistance=7, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealByKill=16, HealByAssistance=11, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealByKill=12,HealByAssistance=8, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',HealByKill=10,HealByAssistance=7, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',HealByKill=10,HealByAssistance=7, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',HealByKill=10,HealByAssistance=7, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealByKill=50,HealByAssistance=35, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealByKill=60,HealByAssistance=42, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealByKill=36,HealByAssistance=25, InitialGroundSpeedModifierScale=1.20),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealByKill=7,HealByAssistance=5)
					)}
    
    )}


    //Coliseum
    SetEvents[9]={(
                    EventDifficulty=3,
                    GameLength=GL_Normal,
					PerksAvailableList=(class'KFPerk_Berserker'),
                    SpawnWeaponList=KFGFxObject_TraderItems'GP_Trader_ARCH.ColliseumWeeklySpawnList',
					bSpawnWeaponListAffectsSecondaryWeapons=true,
                    TraderWeaponList=KFGFxObject_TraderItems'GP_Trader_ARCH.ColliseumWeeklyTraderList',
					bColliseumSkillConditionsActive=true,
					bModifyZedTimeOnANearZedKill=true,
					ZedTimeOnANearZedKill=0.6,
                    PickupResetTime=PRS_Wave,
                    OverrideItemPickupModifier=0,
                    DoshOnKillGlobalModifier=0.7,
                    SpawnRateMultiplier=2.0,
                    WaveAICountScale=(0.75, 0.7, 0.65, 0.6, 0.55, 0.5),
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=0.75,DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=0.75,DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=0.75,DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=0.75,DamageDealtScale=0.6),
									(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=0.75,DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthScale=0.75,DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthScale=0.75,DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale=0.75,DamageDealtScale=0.6),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=1.0,DamageDealtScale=0.75),                             
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthScale=1.0,DamageDealtScale=0.75),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthScale=1.0,DamageDealtScale=0.75)
                    )},
                    SpawnReplacementList={(
                                            (SpawnEntry=AT_AlphaClot,NewClass=(class'KFGameContent.KFPawn_ZedGorefast'),PercentChance=0.1),
                                            (SpawnEntry=AT_SlasherClot,NewClass=(class'KFGameContent.KFPawn_ZedGorefast'),PercentChance=0.1),
                                            (SpawnEntry=AT_Crawler,NewClass=(class'KFGameContent.KFPawn_ZedGorefast'),PercentChance=1.0),
                                            (SpawnEntry=AT_Stalker,NewClass=(class'KFGameContent.KFPawn_ZedGorefast'),PercentChance=1.0),
                                            (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundMini'),PercentChance=0.5),
                                            (SpawnEntry=AT_Siren,NewClass=(class'KFGameContent.KFPawn_ZedFleshpoundMini'),PercentChance=0.5),
                                            (SpawnEntry=AT_Husk,NewClass=(class'KFGameContent.KFPawn_ZedScrake'),PercentChance=1.0),
                                            (SpawnEntry=AT_GoreFast,NewClass=(class'KFGameContent.KFPawn_ZedGorefastDualBlade'),PercentChance=0.3),
                                            (SpawnEntry=AT_Scrake,NewClass=(class'KFGameContent.KFPawn_ZedFleshpound'),PercentChance=0.5)
                                            
                    )}

    )}

    // Aracnophobia
    SetEvents[10]={(
                    EventDifficulty=2, //1,
                    GameLength=GL_Normal,
                    SpawnRateMultiplier=0.75, //5.0,
                    bHealAfterKill = true,
                    bGoompaJumpEnabled = true,
                    GoompaJumpDamage = 550, //300,
                    GoompaStreakDamage = 0.1, //0.2,
                    GoompaJumpImpulse = 600, //1000,
                    GoompaStreakMax = 5,
                    GoompaBonusDuration=8.0f, //10.0f,
                    DoshOnKillGlobalModifier=1.0,
                    //SpawnWeaponList=KFGFxObject_TraderItems'GP_Trader_ARCH.AracnophobiaWeeklySpawnList',
                    bAddSpawnListToLoadout=true,
                    WaveAICountScale=(0.6, 0.6, 0.6, 0.6, 0.6, 0.6),
                    JumpZ=700.f, // 650.0 by default; -1 used for not overriding.
                    /** HealByKill = Normal kill. HealByAssistance = Goomba stomping  */
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',HealthScale=10.0, HeadHealthScale=20.0, DamageDealtScale=0.7, InitialGroundSpeedModifierScale=0.7, HealByAssistance=10),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',HealthScale=10.0,HeadHealthScale=20.0, DamageDealtScale=0.7, InitialGroundSpeedModifierScale=0.7, HealByAssistance=20)
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',HealByAssistance=5),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealByAssistance=15),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealByAssistance=15),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealByAssistance=15),
                                    //(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealByAssistance=5)
                    )},
                    SpawnReplacementList={(
                                            (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_AlphaClot,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_SlasherClot,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_Stalker,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_Siren,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_Husk,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_GoreFast,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            //(SpawnEntry=AT_Scrake,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.7),
                                            //(SpawnEntry=AT_FleshPound,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.7),
                                            //(SpawnEntry=AT_FleshpoundMini,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.7),
                                            (SpawnEntry=AT_EliteClot,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_EliteGoreFast,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_EDAR_EMP,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_EDAR_Laser,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_EDAR_Rocket,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_Crawler,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=1.0)
                    )}
    )}

    // Broken Trader
    SetEvents[11]={(
                    EventDifficulty=1,
                    GameLength=GL_Normal,
                    bSpawnWeaponListAffectsSecondaryWeapons=true,
                    TraderWeaponList=KFGFxObject_TraderItems'GP_Trader_ARCH.BrokenTraderWeeklyTraderList',
                    PickupResetTime=PRS_Wave,
                    bDisableTraders=false,
                    DroppedItemLifespan=20.0f, //10.0f, // 300 default
                    DoshOnKillGlobalModifier=0.2,
                        //Pickup Notes for when you're modifying:
                    //      NumPickups = Actors * OverridePickupModifer * WavePickupModifier
                    //      Ex: 16 item pickups in the world
                    //          * 0.9 Pickup Modifier = 14
                    //          * 0.5 Current wave modifier = 7 expected to spawn
                    //
                    //      Ex: 16 ammo pickups in the world
                    //          * 0.1 pickup modifier = 2
                    //          * 0.5 current wave modifier = 1 expected to spawn
                    bUnlimitedWeaponPickups=true,
                    OverrideItemPickupModifier=2.0,
                    OverrideAmmoPickupModifier=0.8, //0.5,
                    WaveItemPickupModifiers={(
                                1.0, 1.0, 1.0, 1.0, 1.0
                    )},
                    WaveAmmoPickupModifiers={(
                                0.5, 0.6, 0.7, 0.8, 0.9
                    )},
                    bUseOverrideAmmoRespawnTime=true,
                    OverrideAmmoRespawnTime={(
                                PlayersMod[0]=20.000000,
                                PlayersMod[1]=20.000000,
                                PlayersMod[2]=10.000000,
                                PlayersMod[3]=10.000000,
                                PlayersMod[4]=5.000000,
                                PlayersMod[5]=5.000000,
                                ModCap=1.000000
                    )},
                    bUseOverrideItemRespawnTime=true,
                    OverrideItemRespawnTime={(
                                PlayersMod[0]=10.000000,
                                PlayersMod[1]=10.000000,
                                PlayersMod[2]=5.000000,
                                PlayersMod[3]=5.000000,
                                PlayersMod[4]=2.000000,
                                PlayersMod[5]=2.000000,
                                ModCap=1.000000
                    )}
    )}


    //Wild West
    SetEvents[12]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
					PerksAvailableList=(class'KFPerk_Gunslinger', class'KFPerk_Sharpshooter'),
                    TraderWeaponList=KFGFxObject_TraderItems'GP_Trader_ARCH.WildWestWeeklyTraderList',
					bWildWestSkillConditionsActive=true,
					//bModifyZedTimeOnANearZedKill=true,
                    DoshOnKillGlobalModifier=1.4,
                    PickupResetTime=PRS_Wave,
                    OverrideItemPickupModifier=0,
                    OverrideAmmoPickupModifier=1,
                    WaveAmmoPickupModifiers={(
                       0.125, 0.175, 0.35, 0.525, 0.7, 0.875, 0.75, 0.99, 0.99
                    )},
                    SpawnRateMultiplier=0.75,
                    WaveAICountScale=(0.75, 0.7, 0.7, 0.65, 0.65, 0.6),
                    bHealAfterKill = true,
                    bHealWithHeadshot = true,
                    bForceWWLMusic = true,
                    ZedsToAdjust={(
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler', HealByKill=1, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing', HealByKill=5, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst', HealByKill=1, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha', HealByKill=1, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing', HealByKill=10, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher', HealByKill=1, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren', HealByKill=10, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker', HealByKill=2, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast', HealByKill=5, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade', HealByKill=5, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat', HealByKill=10, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk', HealByKill=10, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP', HealByKill=5, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser', HealByKill=5, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket', HealByKill=5, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake', HealByKill=20, HealByAssistance=0),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound', HealByKill=20, HealByAssistance=0, HealthScale=0.8, DamageDealtScale=0.7),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini', HealByKill=15, HealByAssistance=0, HealthScale=0.8, DamageDealtScale=0.7),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn', HealByKill=2, HealByAssistance=0),

                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=0.8,DamageDealtScale=0.7),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=0.8,DamageDealtScale=0.7),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=0.8,DamageDealtScale=0.7),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=0.8,DamageDealtScale=0.7),
								    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=0.8,DamageDealtScale=0.7)
                    )},
                    SpawnReplacementList={(
                                            (SpawnEntry=AT_FleshPound,NewClass=(class'KFGameContent.KFPawn_ZedScrake'),PercentChance=0.5),
                                            (SpawnEntry=AT_FleshpoundMini,NewClass=(class'KFGameContent.KFPawn_ZedGorefastDualBlade'),PercentChance=0.5)
                    )}

    )}

    //Infernal Eternal
    SetEvents[13]={(
                    EventDifficulty=3,
                    GameLength=GL_Normal,
                    SpawnRateMultiplier=3,
                    WaveAICountScale=(1.3, 1.3, 1.3, 1.3, 1.3, 1.3),
                    OverrideAmmoPickupModifier=1, // 1.2
                    WaveAmmoPickupModifiers={(
                       0.125, 0.15, 0.3, 0.45, 0.6, 0.75, 0.9, 0.99, 0.99
                    )},
                    bUseOverrideAmmoRespawnTime=true,
                    OverrideAmmoRespawnTime={(
                                PlayersMod[0]=25.000000,
                                PlayersMod[1]=12.000000,
                                PlayersMod[2]=8.000000,
                                PlayersMod[3]=5.000000,
                                PlayersMod[4]=4.000000,
                                PlayersMod[5]=3.000000,
                                ModCap=1.000000
                    )},
                    
                    ZedsToAdjust={(
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',HealthScale=1.75,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.25),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',HealthScale=1.75,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.25),              
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',HealthScale=1.75,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.25),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=1.75,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.25),
								(ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',HealthScale=1.75,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.25),
                                
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',bStartEnraged=true, DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn', DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.2)
					)},
                    SpawnReplacementList={(
                                (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=0.15),
                                (SpawnEntry=AT_AlphaClot,NewClass=(class'KFGameContent.KFPawn_ZedClot_AlphaKing'),PercentChance=0.15),
                                (SpawnEntry=AT_GoreFast,NewClass=(class'KFGameContent.KFPawn_ZedGorefastDualBlade'),PercentChance=0.15),
                                (SpawnEntry=AT_Crawler,NewClass=(class'KFGameContent.KFPawn_ZedCrawlerKing'),PercentChance=0.15),
                                (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedScrake'),PercentChance=0.05),
                                (SpawnEntry=AT_FleshpoundMini,NewClass=(class'KFGameContent.KFPawn_ZedFleshpound'),PercentChance=0.2)
                    )}
    )}

    // Boss Rush
    SetEvents[14]={(
                EventDifficulty=2,
                GameLength=GL_Short,
                SpawnRateMultiplier=0,
                bBossRushMode=true,
                OverrideAmmoPickupModifier=1,
                    WaveAmmoPickupModifiers={(
                       0.99, 0.99, 0.99, 0.99, 0.99, 0.99
                    )},
                BossRushOverrideParams={(PerWaves={(
                    // WAVE 1
                    (ZedsToAdjust={(
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',      HealthScale=0.22,DamageDealtScale=0.7, InitialGroundSpeedModifierScale=0.75,ShieldScale=0.22),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',      HealthScale=0.22,DamageDealtScale=0.7, InitialGroundSpeedModifierScale=0.75),              
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',           HealthScale=0.22,DamageDealtScale=0.7, InitialGroundSpeedModifierScale=0.75,ShieldScale=0.22),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing', HealthScale=0.22,DamageDealtScale=0.7, InitialGroundSpeedModifierScale=0.75,ShieldScale=0.22),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',      HealthScale=0.22,DamageDealtScale=0.7, InitialGroundSpeedModifierScale=0.75,ShieldScale=0.22),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',        HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',      HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',     HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini', HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',          HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',           HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing', HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=0.6,DamageDealtScale=0.5, InitialGroundSpeedModifierScale=0.7),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale=0.6,DamageDealtScale=0.3, InitialGroundSpeedModifierScale=0.6)
                        )},
                    /*SpawnReplacementList={(
                                (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=0.15),
                                (SpawnEntry=AT_AlphaClot,NewClass=(class'KFGameContent.KFPawn_ZedClot_AlphaKing'),PercentChance=0.15),
                                (SpawnEntry=AT_GoreFast,NewClass=(class'KFGameContent.KFPawn_ZedGorefastDualBlade'),PercentChance=0.15),
                                (SpawnEntry=AT_Crawler,NewClass=(class'KFGameContent.KFPawn_ZedCrawlerKing'),PercentChance=0.15),
                                (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedScrake'),PercentChance=0.05),
                                (SpawnEntry=AT_FleshpoundMini,NewClass=(class'KFGameContent.KFPawn_ZedFleshpound'),PercentChance=0.05)
                    )},*/
                    DoshOnKillGlobalModifier=0.0f,
                    ExtraDoshGrantedonWaveWon=1700),
                    // WAVE 2
                    (ZedsToAdjust={(
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',      HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0,ShieldScale=0.9),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',      HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),              
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',           HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0,ShieldScale=0.9),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing', HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0,ShieldScale=0.9),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',      HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0,ShieldScale=0.9),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',        HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',      HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',     HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini', HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',          HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',           HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing', HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale=0.9,DamageDealtScale=0.9, InitialGroundSpeedModifierScale=1.0)
                        )},
                    /*SpawnReplacementList={(
                            (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=0.15)
                    )},*/
                    DoshOnKillGlobalModifier=0.0f,
                    ExtraDoshGrantedonWaveWon=2000),
                    // WAVE 3
                    (ZedsToAdjust={(
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',      HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',      HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),              
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',           HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing', HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',      HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',        HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',      HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',     HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini', HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',          HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',           HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing', HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0)
                        )},
                    /*SpawnReplacementList={(
                            (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=0.15)
                    )},*/
                    DoshOnKillGlobalModifier=0.0f,
                    ExtraDoshGrantedonWaveWon=2300),
                    // WAVE 4
                    (ZedsToAdjust={(
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',      HealthScale=1.1,DamageDealtScale=1.1, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.1),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',      HealthScale=1.1,DamageDealtScale=1.1, InitialGroundSpeedModifierScale=1.0),              
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',           HealthScale=1.1,DamageDealtScale=1.1, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.1),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing', HealthScale=1.1,DamageDealtScale=1.1, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.1),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',      HealthScale=1.1,DamageDealtScale=1.1, InitialGroundSpeedModifierScale=1.0,ShieldScale=1.1),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',        HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',      HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',     HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini', HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',          HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',           HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing', HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0)
                        )},
                   /*SpawnReplacementList={(
                            (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=0.15)
                    )},*/
                    DoshOnKillGlobalModifier=0.0f,
                    ExtraDoshGrantedonWaveWon=3000),
                    // WAVE 5
                    (ZedsToAdjust={(
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedMatriarch',      HealthScale=1.4,DamageDealtScale=1.2, InitialGroundSpeedModifierScale=1.2,ShieldScale=1.4),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch',      HealthScale=1.4,DamageDealtScale=1.2, InitialGroundSpeedModifierScale=1.2),              
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans',           HealthScale=1.4,DamageDealtScale=1.2, InitialGroundSpeedModifierScale=1.2,ShieldScale=1.4),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing', HealthScale=1.4,DamageDealtScale=1.2, InitialGroundSpeedModifierScale=1.2,ShieldScale=1.4),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing',      HealthScale=1.4,DamageDealtScale=1.2, InitialGroundSpeedModifierScale=1.2,ShieldScale=1.4),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',        HealthScale=1.0,DamageDealtScale=1.2, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',      HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',     HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini', HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',          HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',           HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing', HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0),
                            (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',HealthScale=1.0,DamageDealtScale=1.0, InitialGroundSpeedModifierScale=1.0)
                        )},
                   /*SpawnReplacementList={(
                            (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=0.15)
                    )},*/
                    DoshOnKillGlobalModifier=0.0f,
                    ExtraDoshGrantedonWaveWon=0)
                    )}
                )}
    )}

    //Tiny head
    SetEvents[15]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    ZedSpawnHeadScale=0.3,
                    PlayerSpawnHeadScale=0.2,
                    bDisableHeadless=true,
                    SpawnRateMultiplier=1.5,
                    WaveAICountScale=(0.8, 0.8, 0.8, 0.8, 0.8, 0.8),
                    DoshOnKillGlobalModifier=1.2,
                    //GlobalAmmoCostScale = 0.5,
                    bInvulnerableHeads = true,
                    BossSpawnReplacementList={(
                                            (SpawnEntry=BAT_Matriarch,NewClass=class'KFGameContent.KFPawn_ZedHans')
                    )},
                    SpawnReplacementList={(
                                            (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedClot_AlphaKing'),PercentChance=0.2),
                                            (SpawnEntry=AT_AlphaClot,NewClass=(class'KFGameContent.KFPawn_ZedClot_AlphaKing'),PercentChance=0.2),
                                            (SpawnEntry=AT_SlasherClot,NewClass=(class'KFGameContent.KFPawn_ZedClot_AlphaKing'),PercentChance=0.2),
                                            //(SpawnEntry=AT_Crawler,NewClass=(class'KFGameContent.KFPawn_ZedGorefastDualBlade'),PercentChance=0.4),
                                            (SpawnEntry=AT_Stalker,NewClass=(class'KFGameContent.KFPawn_ZedGorefastDualBlade'),PercentChance=1.0),
                                            (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedBloat'),PercentChance=1.0),
                                            (SpawnEntry=AT_Siren,NewClass=(class'KFGameContent.KFPawn_ZedSiren'),PercentChance=1.0),
                                            (SpawnEntry=AT_Husk,NewClass=(class'KFGameContent.KFPawn_ZedHusk'),PercentChance=1.0),
                                            (SpawnEntry=AT_GoreFast,NewClass=(class'KFGameContent.KFPawn_ZedGorefastDualBlade'),PercentChance=1.0),
                                            (SpawnEntry=AT_FleshPound,NewClass=(class'KFGameContent.KFPawn_ZedScrake'),PercentChance=0.3),
                                            (SpawnEntry=AT_FleshpoundMini,NewClass=(class'KFGameContent.KFPawn_ZedScrake'),PercentChance=0.3),
                                            //(SpawnEntry=AT_EliteClot,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            //(SpawnEntry=AT_EliteGoreFast,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.6),
                                            (SpawnEntry=AT_EDAR_EMP,NewClass=(class'KFGameContent.KFPawn_ZedBloat'),PercentChance=1.0),
                                            (SpawnEntry=AT_EDAR_Laser,NewClass=(class'KFGameContent.KFPawn_ZedBloat'),PercentChance=1.0),
                                            (SpawnEntry=AT_EDAR_Rocket,NewClass=(class'KFGameContent.KFPawn_ZedBloat'),PercentChance=1.0)
                                            
                    )},
                    ZedsToAdjust={(
                                    //bosses
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHans', HealthScale=1.2,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=armor, GoreHealth=MaxInt, DmgScale=1.3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = Spine2, Offset=(X=-5,Y=45,Z=10))
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedPatriarch', HealthScale=1.2,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=rfoot, GoreHealth=MaxInt, DmgScale=1.3, MaxGoreHealth=MaxInt),
                                        (ZoneName=rcalf, GoreHealth=MaxInt, DmgScale=1.3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = RightLeg)
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing', HealthScale=1.2,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=heart, GoreHealth=MaxInt, DmgScale=1.3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = Spine2, Offset=(X=30,Y=-30,Z=10))
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKing', HealthScale=1.4,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=rupperarm, GoreHealth=MaxInt, DmgScale=1.5, MaxGoreHealth=MaxInt),
                                        (ZoneName=rforearm, GoreHealth=MaxInt, DmgScale=1.5, MaxGoreHealth=MaxInt),
                                        (ZoneName=rhand, GoreHealth=MaxInt, DmgScale=1.5, MaxGoreHealth=MaxInt),
                                        (ZoneName=lupperarm, GoreHealth=MaxInt, DmgScale=1.5, MaxGoreHealth=MaxInt),
                                        (ZoneName=lforearm, GoreHealth=MaxInt, DmgScale=1.5, MaxGoreHealth=MaxInt),
                                        (ZoneName=lhand, GoreHealth=MaxInt, DmgScale=1.5, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = RightForearm, Offset=(X=15,Y=0,Z=5)),
                                        (BoneName = LeftForearm, Offset=(X=25,Y=15,Z=15))
                                    )}),
                                    
                                    //arms
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',HealthScale=1.0,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=rforearm, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=rupperarm, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = RightForearm, Offset=(X=20,Y=0,Z=5))
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',HealthScale=1.0,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=rforearm, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=rupperarm, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName=RightForearm, Offset=(X=20,Y=0,Z=10))
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',HealthScale=1.0,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=rupperarm, GoreHealth=MaxInt, DmgScale=4, MaxGoreHealth=MaxInt),
                                        (ZoneName=rforearm, GoreHealth=MaxInt, DmgScale=4, MaxGoreHealth=MaxInt),
                                        (ZoneName=rhand, GoreHealth=MaxInt, DmgScale=4, MaxGoreHealth=MaxInt),
                                        (ZoneName=lupperarm, GoreHealth=MaxInt, DmgScale=4, MaxGoreHealth=MaxInt),
                                        (ZoneName=lforearm, GoreHealth=MaxInt, DmgScale=4, MaxGoreHealth=MaxInt),
                                        (ZoneName=lhand, GoreHealth=MaxInt, DmgScale=4, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = RightForearm, Offset=(X=20,Y=0,Z=5)),
                                        (BoneName = LeftForearm, Offset=(X=20,Y=7,Z=5))
                                    )}),

                                    //legs
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',HealthScale=1.0,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=rfoot, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=lfoot, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=rcalf, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=lcalf, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=rthigh, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=lthigh, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = RightLeg, Offset=(X=0,Y=0,Z=10)),
                                        (BoneName = LeftLeg, Offset=(X=50,Y=0,Z=10))
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',HealthScale=1.5,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=rfoot, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=rcalf, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=rthigh, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = RightLeg, Offset=(X=0,Y=0,Z=15))
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',HealthScale=1.3,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=lfoot, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=lcalf, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt),
                                        (ZoneName=lthigh, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = LeftLeg, Offset=(X=50,Y=0,Z=10))
                                    )}),

                                    //heart
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',HealthScale=1.0,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=heart, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = Spine2, Offset=(X=25,Y=-25,Z=10))
                                    )}),
                                    (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',HealthScale=1.0,DamageDealtScale=1.0, HitZonesOverride = {(
                                        (ZoneName=heart, GoreHealth=MaxInt, DmgScale=3, MaxGoreHealth=MaxInt)
                                    )}, WeakPoints = {(
                                        (BoneName = Spine2, Offset=(X=30,Y=-30,Z=10))
                                    )})
                                )}
    )}

    // Gun Run
    SetEvents[16]={(
                EventDifficulty=2,
                GameLength=GL_Normal,
                bGunGameMode=true,
                PerksAvailableList=(class'KFPerk_Survivalist'),
                bDisableTraders=true,
                bForceShowSkipTrader=true,
                SpawnWeaponList=KFGFxObject_TraderItems'GP_Trader_ARCH.GunGameWeeklySpawnList',
                bSpawnWeaponListAffectsSecondaryWeapons=true,
                OverrideItemPickupModifier= 0.5f, //1.0f, //2.0f, // 0.f,
                OverrideAmmoPickupModifier= 1.0f, //2.0f, //3.0f, // 0.01f,
                TraderTimeModifier=1.0f, // 0.1f,
				TimeBetweenWaves=30.f,
                bDisableAddDosh=true,
                bDisableThrowWeapon=true,
                ZedsToAdjust={(
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Cyst',GunGameKilledScore=10, GunGameAssistanceScore=2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Alpha',GunGameKilledScore=10, GunGameAssistanceScore=2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_AlphaKing',GunGameKilledScore=30, GunGameAssistanceScore=5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedClot_Slasher',GunGameKilledScore=10, GunGameAssistanceScore=2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedSiren',GunGameKilledScore=30, GunGameAssistanceScore=5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedStalker',GunGameKilledScore=10, GunGameAssistanceScore=2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawler',GunGameKilledScore=10, GunGameAssistanceScore=2),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedCrawlerKing',GunGameKilledScore=20, GunGameAssistanceScore=4),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefast',GunGameKilledScore=20, GunGameAssistanceScore=4),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedGorefastDualBlade',GunGameKilledScore=30, GunGameAssistanceScore=4),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloat',GunGameKilledScore=30, GunGameAssistanceScore=5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedHusk',GunGameKilledScore=30, GunGameAssistanceScore=5),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_EMP',GunGameKilledScore=20, GunGameAssistanceScore=4),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Laser',GunGameKilledScore=20, GunGameAssistanceScore=4),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedDAR_Rocket',GunGameKilledScore=20, GunGameAssistanceScore=4),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedScrake',GunGameKilledScore=50, GunGameAssistanceScore=10),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpound',GunGameKilledScore=50, GunGameAssistanceScore=10),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundMini',GunGameKilledScore=40, GunGameAssistanceScore=8),
                                (ClassToAdjust=class'KFGameContent.KFPawn_ZedBloatKingSubspawn',GunGameKilledScore=0, GunGameAssistanceScore=0)
                 )},
                 // 
                 GunGamePerksData={(GunGameRespawnLevels={(
                                        (Wave=1, Level=3), (Wave=2, Level=7),
										(Wave=3, Level=10), (Wave=4, Level=12),
										(Wave=5, Level=14), (Wave=6, Level=16),
										(Wave=7, Level=18), (Wave=8, Level=19),
                                        (Wave=9, Level=20) // We have to take in account that players spawn during trade time, and the wave changes after that
                                    )},
                                    GunGameLevels={(
                                        (   RequiredScore=50
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_9mm'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=100
                                            ,  GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_9mmDual'
                                                                        , class'KFGame.KFWeapDef_MedicPistol'
                                                                        , class'KFGame.KFWeapDef_Crovel'
                                                                    )
                                                               }
                                        ),
                                        (   RequiredScore=200
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_HX25'
                                                                        , class'KFGame.KFWeapDef_FlareGun'
                                                                        , class'KFGame.KFWeapDef_HRGWinterbite'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=300
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_AR15'
                                                                        , class'KFGame.KFWeapDef_CaulkBurn'
                                                                        , class'KFGame.KFWeapDef_MP7'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=400
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_Remington1858Dual'
                                                                        , class'KFGame.KFWeapDef_Winchester1894'
                                                                        , class'KFGame.KFWeapDef_MB500'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=500
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_FireAxe'
                                                                        , class'KFGame.KFWeapDef_MedicSMG'
                                                                        , class'KFGame.KFWeapDef_SW500_HRG'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=600
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_M79'
                                                                        , class'KFGame.KFWeapDef_Crossbow'
                                                                        , class'KFGame.KFWeapDef_Colt1911Dual'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=750
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_MP5RAS'
                                                                        , class'KFGame.KFWeapDef_Thompson'
                                                                        , class'KFGame.KFWeapDef_HRG_Boomy'
                                                                        , class'KFGame.KFWeapDef_Bullpup'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=900
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_FlareGunDual'
                                                                        , class'KFGame.KFWeapDef_HRGWinterbiteDual'
                                                                        , class'KFGame.KFWeapDef_Katana'
                                                                        , class'KFGame.KFWeapDef_CenterfireMB464'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=1050
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_Nailgun'
                                                                        , class'KFGame.KFWeapDef_DoubleBarrel'
                                                                        , class'KFGame.KFWeapDef_HZ12'
                                                                        , class'KFGame.KFWeapDef_DragonsBreath'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=1200
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_Healthrower_HRG'
                                                                        , class'KFGame.KFWeapDef_Mac10'
                                                                        , class'KFGame.KFWeapDef_HRG_Crossboom'
                                                                        , class'KFGame.KFWeapDef_HRGScorcher'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=1350
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_SealSqueal'
                                                                        , class'KFGame.KFWeapDef_HRG_CranialPopper'
                                                                        , class'KFGame.KFWeapDef_HRG_SonicGun'
                                                                        , class'KFGame.KFWeapDef_Hemogoblin'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=1500
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_AK12'
                                                                        , class'KFGame.KFWeapDef_MKB42'
                                                                        , class'KFGame.KFWeapDef_FlameThrower'
                                                                        , class'KFGame.KFWeapDef_FreezeThrower'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=1650
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_Pulverizer'
                                                                        , class'KFGame.KFWeapDef_MedicBat'
                                                                        , class'KFGame.KFWeapDef_Nailgun_HRG'
                                                                        , class'KFGame.KFWeapDef_P90'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=1800
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_DeagleDual'
                                                                        , class'KFGame.KFWeapDef_HRG_Energy'
                                                                        , class'KFGame.KFWeapDef_AF2011Dual'
                                                                        , class'KFGame.KFWeapDef_HRG_Vampire'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=2000
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_HRG_Kaboomstick'
                                                                        , class'KFGame.KFWeapDef_MedicShotgun'
                                                                        , class'KFGame.KFWeapDef_M4'
                                                                        , class'KFGame.KFWeapDef_SW500Dual_HRG'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=2200
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_HK_UMP'
                                                                        , class'KFGame.KFWeapDef_HRGIncendiaryRifle'
                                                                        , class'KFGame.KFWeapDef_M16M203'
                                                                        , class'KFGame.KFWeapDef_M14EBR'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=2400
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_PowerGloves'
                                                                        , class'KFGame.KFWeapDef_HRG_BlastBrawlers'
                                                                        , class'KFGame.KFWeapDef_HRGTeslauncher'
                                                                        , class'KFGame.KFWeapDef_MaceAndShield'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=2600
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_MedicRifle'
                                                                        , class'KFGame.KFWeapDef_HRG_BarrierRifle'
                                                                        , class'KFGame.KFWeapDef_HRG_Stunner'
                                                                        , class'KFGame.KFWeapDef_SCAR'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=2800
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_HuskCannon'
                                                                        , class'KFGame.KFWeapDef_AA12'
                                                                        , class'KFGame.KFWeapDef_FNFal'
                                                                        , class'KFGame.KFWeapDef_HRGIncision'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=3000
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_Stoner63A'
                                                                        , class'KFGame.KFWeapDef_ElephantGun'
                                                                        , class'KFGame.KFWeapDef_Seeker6'
                                                                        , class'KFGame.KFWeapDef_Eviscerator'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=3300
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_AbominationAxe'
                                                                        , class'KFGame.KFWeapDef_RailGun'
                                                                        , class'KFGame.KFWeapDef_MicrowaveGun'
                                                                        , class'KFGame.KFWeapDef_SW500Dual'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=3600
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_MedicRifleGrenadeLauncher'
                                                                        , class'KFGame.KFWeapDef_Kriss'
                                                                        , class'KFGame.KFWeapDef_RPG7'
                                                                        , class'KFGame.KFWeapDef_M99'
                                                                    )
                                                                }
                                        ),
                                        (   RequiredScore=4000
                                            ,   GrantedWeapons= {
                                                                    (
                                                                        class'KFGame.KFWeapDef_M32'
                                                                        , class'KFGame.KFWeapDef_LazerCutter'
                                                                        , class'KFGame.KFWeapDef_MicrowaveRifle'
                                                                        , class'KFGame.KFWeapDef_HRG_EMP_ArcGenerator'
                                                                    )
                                                                }
                                        )
                                )})}
                
    )}

    // VIP
    SetEvents[17]={(
                EventDifficulty=2,
                GameLength=GL_Normal,
                bVIPGameMode=true,
                VIPTargetting=(class'KFGameContent.KFPawn_ZedScrake'
                , class'KFGameContent.KFPawn_ZedFleshpound'
                , class'KFGameContent.KFPawn_ZedFleshpoundMini'
                , class'KFGameContent.KFPawn_ZedGorefast'
                , class'KFGameContent.KFPawn_ZedGorefastDualBlade'
                , class'KFGameContent.KFPawn_ZedClot_Cyst'
                , class'KFGameContent.KFPawn_ZedClot_Slasher'
                , class'KFGameContent.KFPawn_ZedClot_Alpha'
                , class'KFGameContent.KFPawn_ZedClot_AlphaKing'
                , class'KFGameContent.KFPawn_ZedBloat'
                , class'KFGameContent.KFPawn_ZedHusk'
                , class'KFGameContent.KFPawn_ZedSiren'
                , class'KFGameContent.KFPawn_ZedCrawler'
                , class'KFGameContent.KFPawn_ZedCrawlerKing'
                , class'KFGameContent.KFPawn_ZedStalker'
                , class'KFGameContent.KFPawn_ZedDAR_EMP'
                , class'KFGameContent.KFPawn_ZedDAR_Laser'
                , class'KFGameContent.KFPawn_ZedDAR_Rocket'
                , class'KFGameContent.KFPawn_ZedMatriarch'
                , class'KFGameContent.KFPawn_ZedPatriarch'
                , class'KFGameContent.KFPawn_ZedBloatKing'
                , class'KFGameContent.KFPawn_ZedBloatKingSubspawn'
                , class'KFGameContent.KFPawn_ZedFleshpoundKing'
                , class'KFGameContent.KFPawn_ZedHans'),
    )}

    // Random Perks
    SetEvents[18]={(
                EventDifficulty=2,
                GameLength=GL_Normal,
                DoshOnKillGlobalModifier=1.3,
                SpawnReplacementList={(
                                            (SpawnEntry=AT_Clot,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.3),
                                            (SpawnEntry=AT_AlphaClot,NewClass=(class'KFGameContent.KFPawn_ZedCrawler'),PercentChance=0.3),
                                            (SpawnEntry=AT_SlasherClot,NewClass=(class'KFGameContent.KFPawn_ZedStalker'),PercentChance=0.3),
                                            (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedSiren'),PercentChance=0.3),
                                            (SpawnEntry=AT_Scrake,NewClass=(class'KFGameContent.KFPawn_ZedFleshpound'),PercentChance=0.3)
                                            
                    )}
    )}

	// Contamination Mode
    SetEvents[19]={(
                EventDifficulty=2,
                GameLength=GL_Normal,
				ContaminationModeZedsToFinish=5,
				ContaminationModeExtraDosh=200,
                SpawnReplacementList={(
                                            (SpawnEntry=AT_EliteCrawler,NewClass=(class'KFGameContent.KFPawn_ZedGorefast'),PercentChance=0.9),
                                            (SpawnEntry=AT_Siren,NewClass=(class'KFGameContent.KFPawn_ZedDAR_Laser'),PercentChance=0.2),
                                            (SpawnEntry=AT_Bloat,NewClass=(class'KFGameContent.KFPawn_ZedDAR_Rocket'),PercentChance=0.2)
                                            
                    )}
    )}

	// Bounty Hunt
    SetEvents[20]={(
                EventDifficulty=2,
                GameLength=GL_Normal,
				OverrideAmmoPickupModifier=2.0f,
                WaveAICountScale=(0.8f, 0.7f, 0.6f, 0.6f, 0.5f, 0.5f), // This is per player-count, if more players than slots uses last value
				bBountyHunt=true,
				BountyHuntExtraDosh=200,

                // Navigation parameters
				BountyHuntNeedsToSeePlayerToTriggerFlee=false, //DEFAULT: false
				BountyHuntTimeBetweenFlee=10.f, //DEFAULT: 10f				// (seconds) Time the Flee AI Order is active
				BountyHuntTimeBetweenAttack=12.f, //DEFAULT 12f				// (seconds) Seconds between a new Attack Order can be issued using proximity to any player (BountyHuntDistancePlayerAttack)
				BountyHuntTimeCanCancelAttack=1f,	//DEFAULT 5.f			// (seconds) Seconds after Attack is issued we can cancel it (to flee if the distance BountyHuntDistancePlayerMinFlee is okay)
				BountyHuntDistancePlayerMinFirstFlee=2000.f, //DEFAULT 100f	// (cm) Minimal Distance between Player and Zed when Zed decides to Flee first time (then we block crossing Blocking Volumes)
 			    BountyHuntDistancePlayerMinFlee=2000.f, //DEFAULT 1000f     // (cm) Minimal Distance between Player and Zed when Zed decides to Flee
				BountyHuntDistancePlayerMaxFlee=20000.f, // DEFAULT 2200F   // (cm) Distance between Player and Zed when Zed stops Fleeing (use to cancel a Flee)
                BountyHuntDistancePlayerAttack=80.f, // DEFAULT 400f       // (cm) Distance between Player and Zed when Zed decides to Attack 

                // BZ stat parameters
                BountyHuntSpecialZedBuffHealthRatio=0.1f, // EXTRA 10% health for all Bounty Zeds
                BountyHuntSpecialZedBuffAfflictionResistance=5f, // EXTRA 500% affliction resistance for all Bounty Zeds
				HeadshotDamageMultiplier=0.25f,
				
                BountyHuntMaxCoexistingZeds=3,
				BountyHuntLastLevelStillUsesCoexistingZeds=false,
			    BountyHuntUseGradualSpawn=false,
                BountyHuntGame=
                {(
                    BountyHuntDataWaves= // Amount of Zeds is TOTAL, NOT NumberOfZeds per player
                    {(
                        (Wave=1
                            , BountyHuntWavePerPlayerZed =
                                 {(
                                        (NumberOfPlayers=1, NumberOfZeds=1) 
                                    ,   (NumberOfPlayers=2, NumberOfZeds=2) 
                                    ,   (NumberOfPlayers=3, NumberOfZeds=3) 
                                    ,   (NumberOfPlayers=4, NumberOfZeds=4) 
                                    ,   (NumberOfPlayers=5, NumberOfZeds=5) 
                                    ,   (NumberOfPlayers=6, NumberOfZeds=5) 
                                 )}),
                        (Wave=2
                            , BountyHuntWavePerPlayerZed =
                                 {(
                                        (NumberOfPlayers=1, NumberOfZeds=2)
                                    ,   (NumberOfPlayers=2, NumberOfZeds=3) 
                                    ,   (NumberOfPlayers=3, NumberOfZeds=4) 
                                    ,   (NumberOfPlayers=4, NumberOfZeds=5) 
                                    ,   (NumberOfPlayers=5, NumberOfZeds=6) 
                                    ,   (NumberOfPlayers=6, NumberOfZeds=6) 
                                 )}),
                        (Wave=3
                            , BountyHuntWavePerPlayerZed =
                                 {(
                                        (NumberOfPlayers=1, NumberOfZeds=3) 
                                    ,   (NumberOfPlayers=2, NumberOfZeds=4) 
                                    ,   (NumberOfPlayers=3, NumberOfZeds=5) 
                                    ,   (NumberOfPlayers=4, NumberOfZeds=6) 
                                    ,   (NumberOfPlayers=5, NumberOfZeds=7) 
                                    ,   (NumberOfPlayers=6, NumberOfZeds=7) 
                                 )}),
                        (Wave=4
                            , BountyHuntWavePerPlayerZed =
                                 {(
                                        (NumberOfPlayers=1, NumberOfZeds=3) 
                                    ,   (NumberOfPlayers=2, NumberOfZeds=5) 
                                    ,   (NumberOfPlayers=3, NumberOfZeds=6) 
                                    ,   (NumberOfPlayers=4, NumberOfZeds=7) 
                                    ,   (NumberOfPlayers=5, NumberOfZeds=7) 
                                    ,   (NumberOfPlayers=6, NumberOfZeds=8) 
                                 )}),
                        (Wave=5
                            , BountyHuntWavePerPlayerZed =
                                 {(
                                        (NumberOfPlayers=1, NumberOfZeds=4) 
                                    ,   (NumberOfPlayers=2, NumberOfZeds=6) 
                                    ,   (NumberOfPlayers=3, NumberOfZeds=7) 
                                    ,   (NumberOfPlayers=4, NumberOfZeds=8) 
                                    ,   (NumberOfPlayers=5, NumberOfZeds=8) 
                                    ,   (NumberOfPlayers=6, NumberOfZeds=8) 
                                 )}),
                        (Wave=6
                            , BountyHuntWavePerPlayerZed =
                                 {(
                                        (NumberOfPlayers=1, NumberOfZeds=5) 
                                    ,   (NumberOfPlayers=2, NumberOfZeds=7) 
                                    ,   (NumberOfPlayers=3, NumberOfZeds=8) 
                                    ,   (NumberOfPlayers=4, NumberOfZeds=9) 
                                    ,   (NumberOfPlayers=5, NumberOfZeds=9) 
                                    ,   (NumberOfPlayers=6, NumberOfZeds=9) 
                                 )}),
                        (Wave=7
                            , BountyHuntWavePerPlayerZed =
                                 {(
                                        (NumberOfPlayers=1, NumberOfZeds=6) 
                                    ,   (NumberOfPlayers=2, NumberOfZeds=8) 
                                    ,   (NumberOfPlayers=3, NumberOfZeds=9) 
                                    ,   (NumberOfPlayers=4, NumberOfZeds=10) 
                                    ,   (NumberOfPlayers=5, NumberOfZeds=12) 
                                    ,   (NumberOfPlayers=6, NumberOfZeds=12) 
                                 )})
                    )},

                    // Zed Stats progression related to remaining AI zeds
                    BountyHuntZedAndProgression=
                    {(
                        (   ZedType=class'KFGameContent.KFPawn_ZedGorefastDualBlade',
							BountyHuntSpecialZedPerWave =
							{(
								(Wave=2), (Wave=3), (Wave=4), (Wave=5)
							)},
                            BountyHuntZedProgression =
                            {(
                                (RemainingZedRatio=1.f, HealthBuffRatio=1f, DamageBuffRatio=0.f), // +100% H // +0% DMG
                                (RemainingZedRatio=0.75f, HealthBuffRatio=1.5f, DamageBuffRatio=0.1f), // +150% H // +10% DMG
                                (RemainingZedRatio=0.5f, HealthBuffRatio=2f, DamageBuffRatio=0.2f), // +200% H / +20% DMG
                                (RemainingZedRatio=0.3f, HealthBuffRatio=2.5f, DamageBuffRatio=0.3f), // +250% H // +30% DMG
                                (RemainingZedRatio=0.1f, HealthBuffRatio=3f, DamageBuffRatio=3.f) // +300%H // +300% DMG
                            )}
                        ),
                        (   ZedType=class'KFGameContent.KFPawn_ZedClot_AlphaKing',
							BountyHuntSpecialZedPerWave =
							{(
								(Wave=1), (Wave=3)
							)},
                            BountyHuntZedProgression =
                            {(
                                (RemainingZedRatio=1.f, HealthBuffRatio=5f, DamageBuffRatio=0.f), // +500% H // +0% DMG
                                (RemainingZedRatio=0.75f, HealthBuffRatio=5.1f, DamageBuffRatio=0.1f), // +510% H // +10% DMG
                                (RemainingZedRatio=0.5f, HealthBuffRatio=5.2f, DamageBuffRatio=0.2f), // +520% H / +20% DMG
                                (RemainingZedRatio=0.3f, HealthBuffRatio=5.3f, DamageBuffRatio=0.5f), // +530% H // +50% DMG
                                (RemainingZedRatio=0.1f, HealthBuffRatio=5.5f, DamageBuffRatio=3.f) // +550% H // +300% DMG
                            )}
                        ),
                        (   ZedType=class'KFGameContent.KFPawn_ZedFleshpoundMini',
							BountyHuntSpecialZedPerWave =
							{(
								(Wave=6), (Wave=7)
							)},
                            BountyHuntZedProgression =
                            {(
                                (RemainingZedRatio=1.f, HealthBuffRatio=0.f, DamageBuffRatio=0.f), // +0% H // +0% DMG
                                (RemainingZedRatio=0.75f, HealthBuffRatio=0.0f, DamageBuffRatio=0.01f), // +0% H // +1% DMG
                                (RemainingZedRatio=0.5f, HealthBuffRatio=0.0f, DamageBuffRatio=0.02f), // +0% H // +2% DMG
                                (RemainingZedRatio=0.3f, HealthBuffRatio=0.01f, DamageBuffRatio=0.03f), // +1% H // +3% DMG
                                (RemainingZedRatio=0.1f, HealthBuffRatio=0.05f, DamageBuffRatio=0.1f) // +5% H // +10% DMG
                            )}
                        ),
                        (   ZedType=class'KFGameContent.KFPawn_ZedScrake',
							BountyHuntSpecialZedPerWave =
							{(
								(Wave=4), (Wave=5), (Wave=6), (Wave=7)
							)},
                            BountyHuntZedProgression =
                            {(
                                (RemainingZedRatio=1.f, HealthBuffRatio=0.01f, DamageBuffRatio=0.f), // +1% H // +0% DMG
                                (RemainingZedRatio=0.75f, HealthBuffRatio=0.02f, DamageBuffRatio=0.05f), // +2% H // +5% DMG
                                (RemainingZedRatio=0.5f, HealthBuffRatio=0.03f, DamageBuffRatio=0.05f), // +3% H // +5% DMG
                                (RemainingZedRatio=0.3f, HealthBuffRatio=0.04f, DamageBuffRatio=0.05f), // +4% H // +5% DMG
                                (RemainingZedRatio=0.1f, HealthBuffRatio=0.05f, DamageBuffRatio=0.25f) // +5% H // +25% DMG
                            )}
                        )
                    )},
                    BountyHuntDosh=
                    {(
                        (NumberOfPlayers=1, Dosh=300, DoshNoAssist=250),
                        (NumberOfPlayers=2, Dosh=250, DoshNoAssist=200),
                        (NumberOfPlayers=3, Dosh=200, DoshNoAssist=150),
                        (NumberOfPlayers=4, Dosh=150, DoshNoAssist=100),
                        (NumberOfPlayers=5, Dosh=130, DoshNoAssist=80),
                        (NumberOfPlayers=6, Dosh=130, DoshNoAssist=80)
                    )}
                )}
    )}

    //Test events from here down.  These don't end up in the regular rotation.
    //      The override ID starts from one higher than the last SetEvents entry above.
    //      Ex: Big head = 7, Horde = 8

    //Horde
    TestEvents[0]={(
                    EventDifficulty=2,
                    SpawnRateMultiplier=15.0,
                    OverrideSpawnDerateTime=0.1,
                    OverrideTeleportDerateTime=0.1,
                    SpawnWeaponList=KFGFxObject_TraderItems'GP_Trader_ARCH.HordeWeeklyList',
                    SpawnReplacementList={(
                                (SpawnEntry=AT_AlphaClot,NewClass = (class'KFGameContent.KFPawn_ZedClot_Alpha')),
                                (SpawnEntry=AT_SlasherClot,NewClass = (class'KFGameContent.KFPawn_ZedClot_Slasher')),
                                (SpawnEntry=AT_Crawler,NewClass = (class'KFGameContent.KFPawn_ZedClot_Slasher'),PercentChance=0.7),
                                (SpawnEntry=AT_GoreFast,NewClass = (class'KFGameContent.KFPawn_ZedClot_Slasher')),
                                (SpawnEntry=AT_Stalker,NewClass = (class'KFGameContent.KFPawn_ZedClot_Slasher'),PercentChance=0.7),
                                (SpawnEntry=AT_Scrake,NewClass = (class'KFGameContent.KFPawn_ZedBloat')),
                                (SpawnEntry=AT_FleshPound,NewClass = (class'KFGameContent.KFPawn_ZedHusk')),
                                (SpawnEntry=AT_Bloat,NewClass = (class'KFGameContent.KFPawn_ZedClot_Alpha'),PercentChance=0.01),
                                (SpawnEntry=AT_Siren,NewClass = (class'KFGameContent.KFPawn_ZedGorefast')),
                                (SpawnEntry=AT_Husk,NewClass = (class'KFGameContent.KFPawn_ZedClot_Alpha'))
                    )},
                    BossSpawnReplacementList={(
                                (SpawnEntry=BAT_Hans,NewClass = class'KFGameContent.KFPawn_ZedFleshpoundKing'),
                                (SpawnEntry=BAT_Patriarch,NewClass = class'KFGameContent.KFPawn_ZedFleshpoundKing'),
								(SpawnEntry=BAT_KingBloat,NewClass = class'KFGameContent.KFPawn_ZedFleshpoundKing')
                    )},
                    ZedsToAdjust={(
                                (ClassToAdjust = class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale = 1.2)
                                //This will spawn a pack of Mini Fleshpounds w/ the king fleshpound when he spawns.  It works the same as the timer-based waves below, but spawns once per-instance of the class
                                //      that is being adjusted.  This can be used on any zed class.  Ex: This could be used to spawn a pack of mini FPs each time a scrake is spawned.
                                //(ClassToAdjust=class'KFGameContent.KFPawn_ZedFleshpoundKing',HealthScale=1.2,AdditionalSubSpawns=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',AdditionalsubSpawnCount=(X=4,Y=8))
                    )},
                    GlobalAmmoCostScale=15.0,
                    bDisableGrenades=true,
                    bDisableTraders=true,
                    PickupResetTime=PRS_Trader,
                    //Pickup Notes for when you're modifying:
                    //      NumPickups = Actors * OverridePickupModifer * WavePickupModifier
                    //      Ex: 16 item pickups in the world
                    //          * 0.9 Pickup Modifier = 14
                    //          * 0.5 Current wave modifier = 7 expected to spawn
                    //
                    //      Ex: 16 ammo pickups in the world
                    //          * 0.1 pickup modifier = 2
                    //          * 0.5 current wave modifier = 1 expected to spawn
                    OverrideItemPickupModifier=0.9,
                    OverrideAmmoPickupModifier=0.1,
                    WaveItemPickupModifiers={(
                                0.8, 0.7, 0.6, 0.5, 0.4
                    )},
                    WaveAmmoPickupModifiers={(
                                0.6, 0.7, 0.8, 0.9, 0.9
                    )},
                    bUseOverrideAmmoRespawnTime=true,
                    OverrideAmmoRespawnTime={(
                                PlayersMod[0]=10.000000,
                                PlayersMod[1]=10.000000,
                                PlayersMod[2]=10.000000,
                                PlayersMod[3]=10.000000,
                                PlayersMod[4]=10.000000,
                                PlayersMod[5]=10.000000,
                                ModCap=1.000000
                    )},
                    AdditionalBossWaveInfo=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_HOE_One',
                    AdditionalBossWaveStartDelay=15,
                    AdditionalBossWaveFrequency=150,
                    AdditionalBossSpawnCount=(X=5,Y=20)
	)}
}
