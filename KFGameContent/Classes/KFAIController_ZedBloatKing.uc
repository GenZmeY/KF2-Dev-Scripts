//=============================================================================
// KFAIController_ZedBloatKing
//=============================================================================
// Boss variant of the Bloat.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFAIController_ZedBloatKing extends KFAIController_ZedBloat;

/** Cached pawn reference */
var KFPawn_ZedBloatKing BloatPawn;

/** How long the Patriarch should wait to start sprinting after losing sight of his enemy */
var float LostSightSprintDelay;

/** How often to spawn a new pack of minions. This is done continuously throughout the fight. */
var() const float MinionSpawnTimer[4];

/** The base amount of minions to spawn in a single cycle */
var vector2D NumMinionsToSpawn[4];

/** Wave infos to use for continuous spawn */
var KFAIWaveInfo ContinuousSpawnWaveInfos[4];

/** Timer triggered when a piece of armor is blown off to keep Bloat in enrage */
var float ArmorEnrageTimer;

/** Attacks */
var float NextSpecialMoveCheck;
var float NextGorgeAttackCheck;
var float NextHumanGorgeAttackCheck;

/** Retargeting modifications - pulled from Hans */
/** The last time we changed to a new target */
var float LastRetargetTime;

/** How long to wait before attempting to find a new target */
var vector2d RetargetWaitTimeRange;

/** The actual retarget wait time after last retarget time has been set */
var transient float ActualRetargetWaitTime;

event Possess(Pawn inPawn, bool bVehicleTransition)
{
    super.Possess(inPawn, bVehicleTransition);

    BloatPawn = KFPawn_ZedBloatKing(inPawn);

    //Init Timers
    NextSpecialMoveCheck = 0.5f;
    NextGorgeAttackCheck = class'KFSM_BloatKing_Gorge'.default.GorgeAttackCheckDelay;

    //Delay start of minion waves a bit to get past boss intro
    SetTimer(2.f, true, 'StartMinionWaves');

	// Initialize retarget time
	LastRetargetTime = WorldInfo.TimeSeconds;
	ActualRetargetWaitTime = RandRange(RetargetWaitTimeRange.X, RetargetWaitTimeRange.Y);
}


simulated function Tick(float DeltaTime)
{
    super.Tick(DeltaTime);

    EvaluateSpecialMoves(DeltaTime);
}

function bool AmIAllowedToSuicideWhenStuck()
{
	return false;
}

function EvaluateSpecialMoves(float DeltaTime)
{
    //Don't attack while we're in theatrics
    if (CommandList != none && CommandList.class == class'AICommand_BossTheatrics')
    {
        return;
    }

    NextSpecialMoveCheck -= DeltaTime;
    NextGorgeAttackCheck -= DeltaTime;
	NextHumanGorgeAttackCheck -= DeltaTime;
    if (NextSpecialMoveCheck > 0.f || BloatPawn.IsDoingSpecialMove())
    {
        return;
    }

    if (NextGorgeAttackCheck < 0)
    {
        if (CanDoGorgeAttack())
        {
            TriggerGorge();
            return;
        }
        else
        {
            NextGorgeAttackCheck = class'KFSM_BloatKing_Gorge'.default.GorgeAttackCheckDelay;
        }
    }

    NextSpecialMoveCheck = 0.5f;
}

function TriggerGorge(bool bForced = false)
{
	class'AICommand_BloatKing_Gorge'.static.StartGorge(self);

	//If we aren't forced, trigger cooldown for gorge intended to pull humans
	if (!bForced)
	{
		NextHumanGorgeAttackCheck = class'KFSM_BloatKing_Gorge'.static.GetGorgeCooldown(MyKFPawn, WorldInfo.Game.GetModifiedGameDifficulty());
	}
}

function bool CanDoGorgeAttack()
{
    local KFPawn KFP;
    local vector ViewDirection, ToTarget;
    local float DotAngle, ToTargetRange;

    ViewDirection = Vector(MyKFPawn.Rotation);

    //Gorge can attack enemy AND friendly units, with different results on contact
    foreach BloatPawn.GorgeTrigger.TouchingActors(class'KFPawn', KFP)
    {
        //Can target enemy and friendly, but they must be alive, and can be filtered by class type
        if (!KFP.IsAliveAndWell() || !class'KFSM_BloatKing_Gorge'.static.IsValidPullClass(KFP))
        {
            continue;
        }

		//Don't allow human-triggered pull if the timer hasn't reset
		if (NextHumanGorgeAttackCheck > 0)
		{
			if (KFP.IsHumanControlled())
			{
				continue;
			}
		}

        ToTarget = KFP.Location - MyKFPawn.Location;
		ToTargetRange = VSizeSq(ToTarget);

		//Check distance.  If out of range, ignore this potential target.
		if (KFP.IsHumanControlled() && ToTargetRange > class'KFSM_BloatKing_Gorge'.default.GorgeHumanAttackRangeSq)
		{
			continue;
		}
		else if (ToTargetRange > class'KFSM_BloatKing_Gorge'.default.GorgeAttackRangeSq)
		{
			continue;
		}

        // Within field of view and not behind geometry
        DotAngle = ViewDirection dot Normal(ToTarget);
        if (DotAngle > class'KFSM_BloatKing_Gorge'.default.GorgeMinAttackAngle && MyKFPawn.FastTrace(KFP.Location, MyKFPawn.Location))
        {
            //Found a target, so we're good to start the move
            return true;
        }
    }

    //If we've gotten this far, there are no valid targets.  Retry later.
    return false;
}

event SeePlayer(Pawn Seen)
{
    Super.SeePlayer(Seen);

    // Evaluate sprinting when visibility changes
    EvaluateSprinting();

    // Reject potential enemy if it's invalid or not on our team, or if it's already my current enemy, or if my pawn is dead or invalid
    if (Seen == none || !Seen.IsAliveAndWell() || Pawn.IsSameTeam(Seen) ||
        Pawn == none || !Pawn.IsAliveAndWell() || !Seen.CanAITargetThisPawn(self))
    {
        return;
    }

    LastEnemySightedTime = WorldInfo.TimeSeconds;
}

function NotifySpecialMoveEnded(KFSpecialMove SM)
{
    super.NotifySpecialMoveEnded(SM);

    EvaluateSprinting();

	// Retarget if it's been enough time since we changed targets
	if (SM.Handle == 'KFSM_MeleeAttack' && `TimeSince(LastRetargetTime) > ActualRetargetWaitTime )
	{
		CheckForEnemiesInFOV(3000.f, -1.f, 1.f, true);
	}
}

event ChangeEnemy(Pawn NewEnemy, optional bool bCanTaunt = true)
{
	local Pawn OldEnemy;
	OldEnemy = Enemy;

	super.ChangeEnemy(NewEnemy, bCanTaunt);

	if (OldEnemy != Enemy)
	{
		LastRetargetTime = WorldInfo.TimeSeconds;
		ActualRetargetWaitTime = RandRange(RetargetWaitTimeRange.X, RetargetWaitTimeRange.Y);
	}
}

/** Evaluate if we should start/stop sprinting, and then set the sprinting flag */
function EvaluateSprinting()
{
    if (MyKFPawn != none && MyKFPawn.IsAliveAndWell() && Enemy != none)
    {
        if (ShouldSprint())
        {
            MyKFPawn.SetSprinting(true);
        }
        else
        {
            MyKFPawn.SetSprinting(false);
        }
    }
}

function bool ShouldSprint()
{
    local float DistToEnemy;
	local float CurrentSprintDistance;

    // Don't allow sprinting when blocking attacks
    if (MyKFPawn.IsDoingSpecialMove(SM_Block))
    {
        return false;
    }
    else if (MyKFPawn.IsEnraged())
    {
        return true;
    }
    // Sprint if we can't see our enemy
    else if (LastEnemySightedTime == 0 || `TimeSince(LastEnemySightedTime) > LostSightSprintDelay )
    {
        //`log(self@GetFuncName()$" don't see any enemy should sprint = true! LastEnemySightedTime: "$LastEnemySightedTime$" TimeSince(LastEnemySightedTime): "$`TimeSince(LastEnemySightedTime));
        return true;
    }
    //Sprint if nobody in range
    else
    {
        DistToEnemy = VSizeSq(Enemy.Location - Pawn.Location);
		CurrentSprintDistance = Lerp(SprintWithinEnemyRange.X, SprintWithinEnemyRange.Y, MyKFPawn.GetHealthPercentage());

        if (DistToEnemy < CurrentSprintDistance * CurrentSprintDistance)
        {
            return true;
        }
        else
        {
            return false;
        }
    }

    return false;
}

function StartMinionWaves()
{
    local KFGameInfo KFGI;
    local float TimerIdx;

    if (CommandList != none && CommandList.class == class'AICommand_BossTheatrics')
    {
        `log("*** Still not done with theatrics");
        return;
    }

    ClearTimer('StartMinionWaves');

    KFGI = KFGameInfo(WorldInfo.Game);
    TimerIdx = Clamp(KFGI.GetModifiedGameDifficulty(), 0, 3);

    SetTimer(MinionSpawnTimer[TimerIdx], true, 'SpawnMinions');
}

//King Bloat spawns minions constantly on a timer throughout the fight, both for player distraction
//      and to eat in a couple of his abilities.
function SpawnMinions()
{
    local KFAIWaveInfo SpawnInfo;
    local KFGameInfo KFGI;

    KFGI = KFGameInfo(WorldInfo.Game);

    SpawnInfo = GetWaveInfo(KFGI.GetModifiedGameDifficulty());
    KFGI.SpawnManager.SummonBossMinions(SpawnInfo.Squads, GetNumMinionsToSpawn(), false);

    //Stop spawning after a couple seconds until the next subwave comes through
    SetTimer(2.f, true, nameof(PauseBossWave));
}

//Once we reach a point where all intended minions for the current spawn cycle are through, pause spawning
function PauseBossWave()
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);
    if (KFGI.SpawnManager.GetNumAINeeded() <= 0)
    {
        StopBossWave();
    }
}

function StopBossWave()
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);

	Cleartimer(nameof(PauseBossWave));
	KFGI.SpawnManager.StopSummoningBossMinions();
}

function KFAIWaveInfo GetWaveInfo(int GameDifficulty)
{
    return ContinuousSpawnWaveInfos[Clamp(GameDifficulty, 0, 3)];
}

/** Returns the number of minions to spawn based on number of players */
function byte GetNumMinionsToSpawn()
{
	local int LivingPlayerCount;
	local float MaxPlayers;
	local byte NumMinsToSpawn;

	local KFGameInfo KFGI;
	KFGI = KFGameInfo(WorldInfo.Game);

    if (KFGI != none)
    {
		LivingPlayerCount = KFGameInfo(WorldInfo.Game).GetLivingPlayerCount();
		MaxPlayers = float(WorldInfo.Game.MaxPlayers);
		NumMinsToSpawn = byte(Lerp(NumMinionsToSpawn[KFGI.GetModifiedGameDifficulty()].X, NumMinionsToSpawn[KFGI.GetModifiedGameDifficulty()].Y, LivingPlayerCount / MaxPlayers));

		`log("[KFAIController_ZedBloatKing::GetNumMinionsToSpawn] LivingPlayerCount:" @ LivingPlayerCount @ "Max Players:" @ MaxPlayers @ "NumMinionsToSpawn:" @ NumMinsToSpawn, KFGI.bLogAICount);
        return NumMinsToSpawn;
    }

    //Backup if we're in a weird state
    return byte(Lerp(NumMinionsToSpawn[0].X, NumMinionsToSpawn[0].Y, fMax(WorldInfo.Game.NumPlayers, 1) / float(WorldInfo.Game.MaxPlayers)));
}

function SetEnrageTimer()
{
	SetTimer(ArmorEnrageTimer, false, nameof(EndArmorEnrage));
}

function StartArmorEnrage()
{
    MyKFPawn.SetEnraged(true);
}

function EndArmorEnrage()
{
    MyKFPawn.SetEnraged(false);
}

function PawnDied(Pawn InPawn)
{
	super.PawnDied(InPawn);

	StopBossWave();
}

/** Victory */
function EnterZedVictoryState()
{
	MyKFGameInfo.SpawnManager.StopSummoningBossMinions();
	BloatPawn.ClearFartTimer();
	super.EnterZedVictoryState();
}

state ZedVictory
{
	ignores NotifyTakeHit, NotifyKilled, NotifySpecialMoveEnded, NotifyFleeFinished, SeePlayer, CheckForEnemiesInFOV,
	EvaluateSprinting, ChangeEnemy, SetEnemy, FindNewEnemy;

Begin:
	Sleep(0.1f);
	class'AICommand_BossTheatrics'.static.DoTheatrics(self, THEATRIC_Victory, -1);
}

DefaultProperties
{
    // Bloat King Specific Functionality
    LostSightSprintDelay=5.0
    ArmorEnrageTimer=9.0 //15  25 //10

	AggroEnemySwitchWaitTime=7.0f
	RetargetWaitTimeRange=(X=4.4, Y=5.0)

    MinionSpawnTimer[0]=70.0
    MinionSpawnTimer[1]=65.0
    MinionSpawnTimer[2]=65.0 //5  //20  //40.0
    MinionSpawnTimer[3]=60.0
    NumMinionsToSpawn[0]=(X=5,Y=30)
	NumMinionsToSpawn[1]=(X=6,Y=36)
	NumMinionsToSpawn[2]=(X=6,Y=36) //(X=7,Y=17)    5  30   10  60
	NumMinionsToSpawn[3]=(X=8,Y=48)

    ContinuousSpawnWaveInfos[0]=KFAIWaveInfo'GP_Spawning_ARCH.Special.Boss.BloatKing_Normal_WaveInfo'
    ContinuousSpawnWaveInfos[1]=KFAIWaveInfo'GP_Spawning_ARCH.Special.Boss.BloatKing_Normal_WaveInfo'
    ContinuousSpawnWaveInfos[2]=KFAIWaveInfo'GP_Spawning_ARCH.Special.Boss.BloatKing_Normal_WaveInfo'
    ContinuousSpawnWaveInfos[3]=KFAIWaveInfo'GP_Spawning_ARCH.Special.Boss.BloatKing_Normal_WaveInfo'

	// ---------------------------------------------
	// ---------------------------------------------
	// AI / Navigation
	SprintWithinEnemyRange=(X=2500.f,Y=500.f) //0% health, 100% health
}