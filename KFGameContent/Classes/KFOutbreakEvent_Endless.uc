//=============================================================================
// KFGameDifficulty_Weekly
//=============================================================================
// Zed adjustments used in endless mode.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFOutbreakEvent_Endless extends KFOutbreakEvent;

function OnScoreKill(Pawn KilledPawn)
{
	local StatAdjustments ToAdjust;

	foreach ActiveEvent.ZedsToAdjust(ToAdjust)
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

				KFGameInfo_Endless(Outer).DoDeathExplosion(KilledPawn, ToAdjust.ExplosionTemplate, ToAdjust.ExplosionIgnoreClass);
			}
		}
	}
}

function AdjustMonsterDefaults(out KFPawn_Monster P)
{
	local StatAdjustments ToAdjust;
	local array<StatAdjustments> ZedsToAdjust;

	super.AdjustMonsterDefaults(P);

	if (P == none)
	{
		return;
	}

	ZedsToAdjust = KFGameInfo_Endless(Outer).EndlessDifficulty.GetZedsToAdjust();

	foreach ZedsToAdjust(ToAdjust)
	{
		if (ClassIsChildOf(P.class, ToAdjust.ClassToAdjust))
		{
			P.Health *= ToAdjust.HealthScale;
			P.HealthMax *= ToAdjust.HealthScale;
			P.HitZones[HZI_HEAD].GoreHealth *= ToAdjust.HeadHealthScale;
			P.HitZones[HZI_HEAD].MaxGoreHealth = P.HitZones[HZI_HEAD].GoreHealth;
			P.SetShieldScale(ToAdjust.ShieldScale);
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

	return default.SetEvents[SetEventsIndex].WeeklyOutbreakId;
}

defaultproperties
{
	//Boom
    SetEvents[0]={(
                    EventDifficulty=1,
                    GameLength=GL_Normal,
                    MaxBoomsPerFrame=3,
					WeeklyOutbreakId=0,
                    WaveAICountScale=(0.4, 0.4, 0.4, 0.4, 0.4, 0.4), //This is per player-count
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
                    )},
    )}



    //Tiny Terrors
    SetEvents[1]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    SpawnRateMultiplier=1.0, //10.0
                    bScaleOnHealth=true,
                    StartingDamageSizeScale=1.0,
					WeeklyOutbreakId=2,
                    DeadDamageSizeScale=0.5
    )}

    //Big head
    SetEvents[2]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    ZedSpawnHeadScale=2.7,  //3.0
                    PlayerSpawnHeadScale=2.0,
                    bDisableHeadless=true,
                    SpawnRateMultiplier=2.5, //2.0
                    WaveAICountScale=(0.7, 0.7, 0.7, 0.7, 0.7, 0.7),  //0.7
                    GlobalAmmoCostScale = 0.5,   //half the normal amount
                    WeeklyOutbreakId=3,
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
    SetEvents[3]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    WaveAICountScale=(0.55, 0.55, 0.55, 0.55, 0.55, 0.55), //This is per player-count 0.75
                    WeeklyOutbreakId=4,
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
    SetEvents[4]={(
                    EventDifficulty=1,
                    GameLength=GL_Normal,
                    bUseZedDamageInflation = true,
                    ZeroHealthInflation = 3.0,
                    GlobalDeflationRate = 0.1, //0.1
                    InflationDeathGravity = -0.57, //.025
                    InflationExplosionTimer = 1.7, //3.0
                    WaveAICountScale=(0.7, 0.7, 0.7, 0.7, 0.7, 0.7), //This is per player-count
					WeeklyOutbreakId=5,
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

    //Cartman
    SetEvents[5]={(
                    EventDifficulty=2,
                    GameLength=GL_Normal,
                    bUseBeefcakeRules=true,
                    WaveAICountScale=(0.75, 0.75, 0.75, 0.75, 0.75, 0.75), //This is per player-count
					WeeklyOutbreakId=7,

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
					)},
    )}
}