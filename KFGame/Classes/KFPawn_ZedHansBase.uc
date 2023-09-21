//=============================================================================
// KFPawn_ZedHansBase
//=============================================================================
// Base Hans Class. Put here so classes in KFGame could reference
// Hans properties, and if any native code is needed
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFPawn_ZedHansBase extends KFPawn_MonsterBoss
	abstract;

/** Cached AI controller */
var KFAIController_Hans MyHansController;

/** If true, MkB42s are unholstered and aiming (also see bIsTargeting) */
var repnotify bool bGunsEquipped;

/*********************************************************************************************
* Battle phases
**********************************************************************************************/

/** Info for hans battle phases */
struct HansBattlePhaseInfo
{
    /** Whether or not we can do the Frenzy attack this battle phase */
    var             bool            bCanFrenzy;
    /** Whether or not to desire sprinting behavior this battle phase */
    var             bool            bSprintingBehavior;
    /** Info on how often we can toss any grenades in this battle phase */
    var             float           GlobalOffensiveNadePhaseCooldown;
    /** Whether or not we can use a regular nerve gas toss this battle phase */
    var             bool            bCanTossNerveGas;
    /** Info on how often we can toss Nerve Gas Nades in this battle phase */
    var             float           NerveGasTossPhaseCooldown;
    /** Whether or not we can use a nerve gas barrage this battle phase */
    var             bool            bCanBarrageNerveGas;
    /** Info on how often we can barrage Nerve Gas Nades in this battle phase */
    var             float           NerveGasBarragePhaseCooldown;
    /** Whether or not we can use the MKB assault rifle this battle phase */
    var             bool            bCanUseGuns;
    /** Info on how often we can use guns in this battle phase */
    var             float           GunAttackPhaseCooldown;
    /** How long Hans will keep his guns out when he pulls them out in this battle phase */
    var             float           GunAttackLengthPhase;
    /** Whether or not we can use a regular grenade this battle phase */
    var             bool            bCanTossGrenade;
    /** Info on how often we can toss HENades in this battle phase */
    var             float           HENadeTossPhaseCooldown;
    /** Whether or not we can use grenade barrage this battle phase */
    var             bool            bCanBarrageGrenades;
    /** Info on how often we can barrage HENades in this battle phase */
    var             float           HENadeBarragePhaseCooldown;
    /** Whether Hans can move when throwing grenades, per difficulty level */
    var             array<bool>     bCanMoveWhileThrowingGrenades;
    /** Heal threshold (MaxHealth * HealThreshold) per difficulty level */
    var             array<float>    HealThresholds;
    /** Heal amount Health + MaxHealth*(MaxHealth * HealAmount) per difficulty level */
    var             array<float>    HealAmounts;
    /** Shield health per difficulty level */
    var             array<int>      MaxShieldHealth;

	structdefaultproperties
	{
		bSprintingBehavior=true
        GlobalOffensiveNadePhaseCooldown=8
        NerveGasTossPhaseCooldown=10
		NerveGasBarragePhaseCooldown=20
		GunAttackPhaseCooldown=20
		GunAttackLengthPhase=15
		HENadeTossPhaseCooldown=10
		HENadeBarragePhaseCooldown=20
	}
};

/** Configuration for the Hans battle phases */
var	array<HansBattlePhaseInfo>  BattlePhases;

/** Whether or not we've healed this battle phase */
var             bool            bHealedThisPhase;

/** Amount of health healed this phase (cumulative) */
var             float           AmountHealedThisPhase;

/** In the mode to hunt players and try and heal */
var repnotify   bool            bInHuntAndHealMode;

/** How much to reduce Hans' damage he receives when he is in hunt and heal mode */
var()           float           HuntAndHealModeDamageReduction;

/** How much to scale incap powers by when healing */
var             float           IncapPowerScaleWhenHealing;

/** Amount of health shield has remaining */
var             float           ShieldHealth;
var             float           ShieldHealthMax;
var				float			ShieldHealthScale;

/** Replicated shield health percentage */
var repnotify   byte            ShieldHealthPctByte;

/** Number of times we've bumped into enemies when trying to heal */
var             int             NumHuntAndHealEnemyBumps;

/** Last time we bumped into an enemy */
var             float           LastHuntAndHealEnemyBumpTime;

/*********************************************************************************************
* Grenade Throwing
**********************************************************************************************/

/** Grenade tossing */
var class<KFProj_Grenade>           ActiveGrenadeClass;
/** Grenade tossing */
var class<KFProj_Grenade>	    ExplosiveGrenadeClass;
var const class<KFProj_Grenade>		SeasonalExplosiveGrenadeClasses[5];
/** Grenade tossing */
var class<KFProj_Grenade>	    NerveGasGrenadeClass;
var const class<KFProj_Grenade>		SeasonalNerveGasGrenadeClasses[5];
/** Grenade tossing */
var class<KFProj_Grenade>	    SmokeGrenadeClass;
var const class<KFProj_Grenade>		SeasonalSmokeGrenadeClasses[5];
/** Socket where grenade spawns when Hans throws with his right hand */
var name RightHandSocketName;
/** Socket where grenade spawns when Hans throws with his left hand */
var name LeftHandSocketName;

/** Grenade accuracy TODO: Make this based on skill level for AI*/
var vector GrenadeTossSpread;

/** Waiting to do a smoke grenade barrage as soon as the guns are put away */
var bool bPendingSmokeGrenadeBarrage;

/** How many grenades have been tossed this barrage */
var int BarrageTossCount;

/** The current grenade attack is a barrage */
var bool bDoingBarrage;

/** Info on how often we can tossed any damaging grenades */
var float GlobalOffensiveNadeCooldown;
var float LastOffensiveNadeTime;
/** Info on how often we can toss HENades */
var float HENadeTossCooldown;
var float LastHENadeTossTime;
/** Info on how often we can barrage HENades */
var float HENadeBarrageCooldown;
var float LastHENadeBarrageTime;
/** Info on how often we can toss Nerve Gas Nades */
var float NerveGasTossCooldown;
var float LastNerveGasTossTime;
/** Info on how often we can barrage Nerve Gas Nades */
var float NerveGasBarrageCooldown;
var float LastNerveGasBarrageTime;
/** Info on how often we can toss Smoke Nades */
var float SmokeTossCooldown;
var float LastSmokeTossTime;

replication
{
    // Replicated to ALL
    if ( bNetDirty )
        bGunsEquipped, bInHuntAndHealMode, ShieldHealthPctByte;
}

simulated event ReplicatedEvent( name VarName )
{
    switch( VarName )
    {
    case nameof( bInHuntAndHealMode ):
        SetHuntAndHealMode( bInHuntAndHealMode );
        break;

    case nameOf( ShieldHealthPctByte ):
        UpdateShieldColor();
        break;

    default:
        super.ReplicatedEvent( VarName );
    }
}

/** Called from Possessed event when this controller has taken control of a Pawn */
function PossessedBy( Controller C, bool bVehicleTransition )
{
    Super.PossessedBy( C, bVehicleTransition );

    MyHansController = KFAIController_Hans( C );

    SetPhaseCooldowns( 0 );

	ExplosiveGrenadeClass = SeasonalExplosiveGrenadeClasses[class'KFGameEngine'.static.GetSeasonalEventID()];
	NerveGasGrenadeClass = SeasonalNerveGasGrenadeClasses[class'KFGameEngine'.static.GetSeasonalEventID()];
	SmokeGrenadeClass = SeasonalSmokeGrenadeClasses[class'KFGameEngine'.static.GetSeasonalEventID()];
}

/** Increment Hans to the next battle phase */
function IncrementBattlePhase()
{
    CurrentBattlePhase++;
    bHealedThisPhase = true;
    AmountHealedThisPhase = 0;

    SetPhaseCooldowns( CurrentBattlePhase - 1 );

    bForceNetUpdate = true;
}

/** Set the correct phase based cooldown for this battle phase */
function SetPhaseCooldowns( int BattlePhase )
{
    GlobalOffensiveNadeCooldown = BattlePhases[BattlePhase].GlobalOffensiveNadePhaseCooldown;
    HENadeTossCooldown = BattlePhases[BattlePhase].HENadeTossPhaseCooldown;
    HENadeBarrageCooldown = BattlePhases[BattlePhase].HENadeBarragePhaseCooldown;
    NerveGasTossCooldown = BattlePhases[BattlePhase].NerveGasTossPhaseCooldown;
    NerveGasBarrageCooldown = BattlePhases[BattlePhase].NerveGasBarragePhaseCooldown;

    if( MyHansController != none )
    {
        MyHansController.ShootingCooldown = BattlePhases[BattlePhase].GunAttackPhaseCooldown;
        MyHansController.MaxGunAttackLength = BattlePhases[BattlePhase].GunAttackLengthPhase;

        // Reset summon flag
        MyHansController.bSummonedThisPhase = false;
    }
}

/** Reduce damage when in hunt and heal mode */
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
    Super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

    // Update shield health before scaling damage
    UpdateShieldHealth( InDamage );

    // Reduce damage when in hunt and heal mode
    if( bInHuntAndHealMode && ShieldHealth > 0 )
    {
        InDamage = Max( InDamage * HuntAndHealModeDamageReduction, 1 );
    }
}

/** Reduce affliction/incap strength when healing */
simulated function AdjustAffliction( out float AfflictionPower )
{
    if( bInHuntAndHealMode )
    {
        AfflictionPower *= IncapPowerScaleWhenHealing;
    }

    super.AdjustAffliction( AfflictionPower );
}

/** Updates shield health and shield health percent */
function UpdateShieldHealth( optional int Damage=-1 )
{
    // If shield has been depleted already, or no damage was taken, don't update
    if( ShieldHealth == 0 || Damage == 0 )
    {
        return;
    }

    // Damage the shield if applicable
    if( ShieldHealth > 0 && Damage > 0 )
    {
        ShieldHealth = Max( ShieldHealth - Damage, 0 );
    }

    // Shield health depleted, break shield
    if( ShieldHealth == 0 )
    {
        ShieldHealthPctByte = 0;
    }
    else
    {
        ShieldHealthPctByte = FloatToByte( fClamp(ShieldHealth / ShieldHealthMax, 0.f, 1.f) );
    }

    // Update color based on percentage of health remaining
    UpdateShieldColor();

    // Need to ensure shield gets broken on dedicated servers
    if( WorldInfo.NetMode == NM_DedicatedServer && bInHuntAndHealMode && ShieldHealthPctByte == 0 )
    {
        BreakShield();
    }
}

/** Breaks the shield */
simulated function BreakShield()
{
    if( Role == ROLE_Authority )
    {
        // Cancel any flee in progress
        if( MyHansController != none )
        {
            MyHansController.CancelFlee();
        }

        // Cancel hunt and heal mode
        SetHuntAndHealMode( false );

        // Cancel any active special moves
        if( IsDoingSpecialMove() )
        {
            EndSpecialMove();
        }

        // Knock down
        Knockdown( Velocity != vect(0,0,0) ? -Velocity*2 : 3*(-vector(Rotation) * GroundSpeed), vect(1,1,1),,,,, Location );
    }
}

/** Can we frenzy attack in this phase */
function bool CanFrenzyInThisPhase()
{
    return BattlePhases[CurrentBattlePhase-1].bCanFrenzy;
}

/** If true Hans will favor sprinting in this phase. Even if it's false he may sprint under certain circumstances, but when it's true he'll try and sprint almost all the time */
function bool DesireSprintingInThisPhase()
{
    return BattlePhases[CurrentBattlePhase-1].bSprintingBehavior;
}

/** Called by PawnAnimInfo when determining whether an attack with bSpecializedMode TRUE can be performed */
function bool ShouldPlaySpecialMeleeAnims()
{
	// make all of Han's melee attacks available when he can frenzy
	return CanFrenzyInThisPhase();
}

/** Only allow blocking when in melee */
function bool CanBlock()
{
    return !bGunsEquipped && !bInHuntAndHealMode && super.CanBlock();
}

/** Has the offensive grenade cooldown time elapsed */
function bool OffensiveGrenadeCooldownComplete()
{
    if( LastOffensiveNadeTime == 0 || `TimeSince(LastOffensiveNadeTime) > GlobalOffensiveNadeCooldown )
    {
        return true;
    }

    return false;
}

/** Can we toss nerve gas in this phase */
function bool CanTossNerveGasInThisPhase()
{
    if( BattlePhases[CurrentBattlePhase -1].bCanTossNerveGas && !bInHuntAndHealMode
        && `TimeSince(LastNerveGasTossTime) > 0 && `TimeSince(LastNerveGasTossTime) > NerveGasTossCooldown
        && OffensiveGrenadeCooldownComplete() )
    {
        return true;
    }

    return false;
}

/** Can we barrage nerve gas in this phase */
function bool CanBarrageNerveGasInThisPhase()
{
    if( BattlePhases[CurrentBattlePhase -1].bCanBarrageNerveGas && !bInHuntAndHealMode
        && `TimeSince(LastNerveGasBarrageTime) > 0 && `TimeSince(LastNerveGasBarrageTime) > NerveGasBarrageCooldown
        && OffensiveGrenadeCooldownComplete() )
    {
        return true;
    }

    return false;
}

/** Can we use guns in this phase */
function bool CanUseGunsInThisPhase()
{
    return BattlePhases[CurrentBattlePhase -1].bCanUseGuns;
}

/** Can we do a standard grenade toss in this phase */
function bool CanTossGrenadeInThisPhase()
{
    if( BattlePhases[CurrentBattlePhase -1].bCanTossGrenade && !bInHuntAndHealMode
        && `TimeSince(LastHENadeTossTime) > 0 && `TimeSince(LastHENadeTossTime) > HENadeTossCooldown
        && OffensiveGrenadeCooldownComplete() )
    {
        return true;
    }

    return false;
}

/** Can we do a grenade barrage in this phase */
function bool CanGrenadeBarrageInThisPhase()
{
    if( BattlePhases[CurrentBattlePhase -1].bCanBarrageGrenades && !bInHuntAndHealMode
        && `TimeSince(LastHENadeBarrageTime) > 0 && `TimeSince(LastHENadeBarrageTime) > HENadeBarrageCooldown
        && OffensiveGrenadeCooldownComplete() )
    {
        return true;
    }

    return false;
}

/** Can we do a regular smoke toss in this phase */
function bool CanSmokeTossInThisPhase()
{
    return bInHuntAndHealMode && `TimeSince(LastSmokeTossTime) > 0 && `TimeSince(LastSmokeTossTime) > SmokeTossCooldown;
}

/** Return true if busy throwing grenade(s) or using AICommand_ThrowGrenade */
function bool IsThrowingGrenade()
{
    return false;
}

/** Implemented in subclass, put here to be accessible from KFGame.u */
function bool CacheGrenadeThrowLocation( optional bool bLeftHand )
{
    return false;
}

function SetActiveGrenadeClassGrenade()
{
    ActiveGrenadeClass=ExplosiveGrenadeClass;
}

function SetActiveGrenadeClassSmoke()
{
    ActiveGrenadeClass=SmokeGrenadeClass;
}

function SetActiveGrenadeClassNerveGas()
{
    ActiveGrenadeClass=NerveGasGrenadeClass;
}

/** Returns TRUE if all conditions are met to allow movement while throwing grenades */
simulated function bool CanMoveWhileThrowingGrenades()
{
    local KFGameReplicationInfo KFGRI;

    // See if this battle phase allows it
    KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
    if( KFGRI != none && BattlePhases[CurrentBattlePhase-1].bCanMoveWhileThrowingGrenades[KFGRI.GetModifiedGameDifficulty()] )
    {
        return true;
    }

    return bInHuntAndHealMode || LocalIsOnePlayerLeftInTeamGame();
}

function PlayDrawGunsDialog()
{
    `DialogManager.PlayHansDrawGunsDialog( self );
}

function PlayGrenadeDialog( bool bBarrage )
{
    switch( ActiveGrenadeClass )
    {
    case ExplosiveGrenadeClass:
        `DialogManager.PlayHansNadeDialog( self, bBarrage );
        break;

    case SmokeGrenadeClass:
        `DialogManager.PlayHansSmokeDialog( self, false );
        break;

    case NerveGasGrenadeClass:
        `DialogManager.PlayHansGasDialog( self, bBarrage );
        break;
    };
}

/** Sets variables related to "hunt and heal" mode */
simulated function SetHuntAndHealMode( bool bOn )
{
    local KFGameInfo KFGI;
    local float HealthMod;
    local float HeadHealthMod;

    bInHuntAndHealMode = bOn;

    if( Role == ROLE_Authority )
    {
        if( bInHuntAndHealMode )
        {
            SetTimer(0.25f, true, nameof(HuntAndHealBump));

            // Use health/player count to scale shield health
            HealthMod = 1.f;
            KFGI = KFGameInfo( WorldInfo.Game );
            if( KFGI != none )
            {
                KFGI.DifficultyInfo.GetAIHealthModifier(
                    self,
                    KFGI.GetModifiedGameDifficulty(),
                    KFGI.GetLivingPlayerCount(),
                    HealthMod,
                    HeadHealthMod );
            }

            // Initialize shield health
            ShieldHealthMax = BattlePhases[CurrentBattlePhase-1].MaxShieldHealth[WorldInfo.Game.GetModifiedGameDifficulty()] * HealthMod * ShieldHealthScale;
            ShieldHealth = ShieldHealthMax;
            UpdateShieldHealth();

            // Initialize bump variables
            NumHuntAndHealEnemyBumps = 0;
            LastHuntAndHealEnemyBumpTime = WorldInfo.TimeSeconds;

            // Stumble
            if( IsDoingSpecialMove() )
            {
                EndSpecialMove();
            }
            DoSpecialMove( SM_Stumble,,, class'KFSM_Stumble'.static.PackBodyHitSMFlags(self, vector(Rotation)) );

            // Inform AI of phase change
            if( MyHansController != none )
            {
                MyHansController.NextBattlePhase();
            }

            // Increment battle phase
            IncrementBattlePhase();
        }
        else
        {
            ClearTimer(nameof(HuntAndHealBump));

            `DialogManager.PlayHansBattlePhaseDialog( self, CurrentBattlePhase );
        }
    }

	if( !bOn )
	{
		bHealedThisPhase = false;
        SetTimer( 0.1, false, nameOf(Timer_ResetShieldHealthPct) );
	}
}

function SetShieldScale(float InScale)
{
	ShieldHealthScale = InScale;
}

/** Sets shield health pct back to 0 for next phase */
function Timer_ResetShieldHealthPct()
{
    ShieldHealthPctByte = 0;
}

/** Returns the amount that Hans should heal for this phase */
function float GetHealAmountForThisPhase()
{
    return float(HealthMax) * BattlePhases[CurrentBattlePhase-2].HealAmounts[WorldInfo.Game.GetModifiedGameDifficulty()];
}

/** Summons boss minions depending on difficulty and battle phase */
function SummonMinions()
{
    local int Skill;
    local int DifficultyIndex;
    local KFAIWaveInfo MinionWave;
    local KFAISpawnManager SpawnManager;
    local KFGameInfo MyKFGameInfo;

    MyKFGameInfo = KFGameInfo( WorldInfo.Game );

    if( MyHansController != none )
    {
        Skill = MyHansController.Skill;
    }

    // Determine which summon squad to spawn by difficulty
    if( Skill == class'KFGameDifficultyInfo'.static.GetDifficultyValue(0) ) // Normal
    {
        DifficultyIndex = 0;
    }
    else if( Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(1) ) // Hard
    {
        DifficultyIndex = 1;
    }
    else if( Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(2) ) // Suicidal
    {
        DifficultyIndex = 2;
    }
    else // Hell on Earth
    {
        DifficultyIndex = 3;
    }

    // Force frustration mode on
    MyKFGameInfo.GetAIDirector().bForceFrustration = true;

    // Spawn our minions
    MinionWave = GetWaveInfo(CurrentBattlePhase, DifficultyIndex);
    SpawnManager = MyKFGameInfo.SpawnManager;
    if ( MinionWave != none && SpawnManager != none )
    {
        SpawnManager.SummonBossMinions( MinionWave.Squads, GetNumMinionsToSpawn() );
    }
}

/** Used to clear DOTs, such as when Hans is healing */
simulated function ClearDOTs()
{
    DamageOverTimeArray.Length = 0;
}

/** If Hans repeatedly bumps into players during his hunt and heal phase, just heal */
simulated event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
    local KFPawn KFP;

    if( !bGunsEquipped )
    {
        if( Role == ROLE_Authority && bInHuntAndHealMode && MyHansController != none && NumHuntAndHealEnemyBumps >= 0 && !IsDoingSpecialMove()
            && Other.GetTeamNum() != GetTeamNum() && MyHansController.FindCommandOfClass(class'AICommand_Attack_Grab') == none )
        {
            KFP = KFPawn( Other );
            if( KFP != none )
            {
                if( `TimeSince(LastHuntAndHealEnemyBumpTime) > 1.f )
                {
                    ++NumHuntAndHealEnemyBumps;
                    LastHuntAndHealEnemyBumpTime = WorldInfo.TimeSeconds;

                    // If we've bumped into players enough times, just heal off of them
                    if( NumHuntAndHealEnemyBumps > 0 )
                    {
                        NumHuntAndHealEnemyBumps = -1;
                        MyHansController.CancelFlee( false );
                        MyKFAIC.DoGrabAttack( KFP );
                        return;
                    }
                }
            }
        }
    }

    super.Bump( Other, OtherComp, HitNormal );
}

// Knock other zeds the heck out of the way when I want to attack my enemy!!!
function HuntAndHealBump()
{
    local KFPawn_Monster KFPM;
    local vector ClosestPoint;
    local float ClosestDist;

    if( MyKFAIC == none || MyKFAIC.Enemy == none /*|| IsDoingSpecialMove(SM_GrappleAttack)*/
        || VSizeSq(Location - MyKFAIC.Enemy.Location) > 250000 ) // 5 meters
    {
        return;
    }

	foreach WorldInfo.AllPawns( class'KFPawn_Monster', KFPM, Location, 300.f )
	{
		// Heavy bump guys that are between us and our prey!
		if( KFPM != self && KFPM.IsAliveAndWell() )
		{
            ClosestDist = PointDistToSegment(KFPM.Location, Location, MyKFAIC.Enemy.Location, ClosestPoint);

            if( ClosestDist < GetCollisionRadius() * 1.5 )
            {
                MyKFAIC.DoHeavyZedBump(KFPM, Normal(KFPM.Location - Location));
            }
		}
	}
}

/** returns whether we need to turn to fire at the specified location and angle*/
function bool NeedToTurnEx(vector targ, optional float Angle = 0.93)
{
	local vector LookDir, AimDir;

	LookDir = Vector(Rotation);
	LookDir.Z = 0;
	LookDir = Normal(LookDir);
	AimDir = targ - Location;
	AimDir.Z = 0;
	AimDir = Normal(AimDir);

	return ((LookDir Dot AimDir) < Angle);
}

/** AnimNotify which starts during Hans's AoE melee attack */
simulated function ANIMNOTIFY_AoENerveGas(){}

/** Overridden to prevent blood while invulnerable */
simulated function ApplyBloodDecals(int HitZoneIndex, vector HitLocation, vector HitDirection, name HitZoneName, name HitBoneName, class<KFDamageType> DmgType, bool bIsDismemberingHit, bool bWasObliterated)
{
    if( !bInHuntAndHealMode )
    {
        super.ApplyBloodDecals( HitZoneIndex, HitLocation, HitDirection, HitZoneName, HitBoneName, DmgType, bIsDismemberingHit, bWasObliterated );
    }

    // else do nothing, leave no blood because hans is mostly invulnerable
}

/** Updates the color of the shield based on its health */
simulated function UpdateShieldColor();

/** Detaches the shield PSC */
simulated function DetachShieldFX();

DefaultProperties
{
	ShieldHealthScale=1.f
}