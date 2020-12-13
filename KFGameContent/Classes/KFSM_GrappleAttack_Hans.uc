//=============================================================================
// KFSM_GrappleAttack_Hans
//=============================================================================
// Hans's energy drain attack - he grabs his victim (similar to the clot
// grab attack) and siphons health from the victim.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_GrappleAttack_Hans extends KFSM_GrappleCombined;

/** Alternate (lunge) grab anim name */
var name GrabStartAnimNameLunge;

var bool bAlreadyDetachedFollower;
var KFPawn CachedFollower;

/** How often, in seconds, damage/healing should be done */
var float DrainInterval;

/** How long to wait after grabbing the player before draining */
var float DelayBeforeDrain;

/** How much to damage/heal per drain DrainInterval */
var int HealthGainPerDrainInterval;
var int DamageDrainRemaining;
var int NumDrainsRemaining;

var int FollowerStartingHealth;

/** The threshold (multiple of Enemy.MaxHealth) at which to drain health */
var float EnemyDrawLifeThreshold;

/** How much life to draw from an enemy when drawing life per difficulty level */
var float MaxEnemyLifeDrawThresholdNormal;
var float MaxEnemyLifeDrawThresholdHard;
var float MaxEnemyLifeDrawThresholdSuicidal;
var float MaxEnemyLifeDrawThresholdHellOnEarth;
/** When taking damage from multiple sources never drain health beyond this point */
var float MinEnemyLifeDrawThreshold;

/** How long Hans should wait to do an attack on the player he just drained when he is finished */
var float PostDrainAttackCooldown;

/** Smoke explosion */
var class<KFExplosionActor> LifeDrainSmokeExplosionActorClass;
var KFGameExplosion LifeDrainSmokeExplosionTemplate;

/** Invulnerability shield */
var ParticleSystem InvulnerableEnergyFX;
var ParticleSystemComponent InvulnerableEnergyPSC;
var name InvulnerableEnergySocketName;

/** Determine if this is a lunge grab or regular grab */
static function byte PackFlagsBase( KFPawn P )
{
    if( P.MyKFAIC != none && P.MyKFAIC.Enemy != none )
    {
        if( VSizeSQ(P.MyKFAIC.Enemy.Location - P.Location) > class'KFAIController_Hans'.default.MinDistanceToPerformGrabAttack*0.33f )
        {
            return 128;
        }
    }

    return 0;
}

function SpecialMoveStarted( bool bForced, Name PrevMove )
{
    local KFPawn_ZedHansBase HansPawn;

    super.SpecialMoveStarted( bForced, PrevMove );

    if( PawnOwner.Role == ROLE_Authority )
    {
        HansPawn = KFPawn_ZedHansBase(PawnOwner);
        if( HansPawn != none )
        {
            HansPawn.PlayGrabDialog();
        }
    }

    if( KFPOwner != none && KFPOwner.MyKFAIC != none )
    {
        // Determine what life draw threshold to use
        if( KFPOwner.MyKFAIC.Skill == class'KFGameDifficultyInfo'.static.GetDifficultyValue(0) ) // Normal
        {
            EnemyDrawLifeThreshold = MaxEnemyLifeDrawThresholdNormal;
        }
        else if( KFPOwner.MyKFAIC.Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(1) ) // Hard
        {
            EnemyDrawLifeThreshold = MaxEnemyLifeDrawThresholdHard;
        }
        else if( KFPOwner.MyKFAIC.Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(2) ) // Suicidal
        {
            EnemyDrawLifeThreshold = MaxEnemyLifeDrawThresholdSuicidal;
        }
        else // Hell on Earth
        {
            EnemyDrawLifeThreshold = MaxEnemyLifeDrawThresholdHellOnEarth;
        }
    }
}

/** Play an animation and enable the OnAnimEnd notification */
function PlayGrabAnim()
{
    if( KFPOwner.SpecialMoveFlags == 128 )
    {
        bUseRootMotion = true;
        GrabStartAnimName = default.GrabStartAnimNameLunge;
    }
    else
    {
        bUseRootMotion = default.bUseRootMotion;
        GrabStartAnimName = default.GrabStartAnimName;
    }

    super.PlayGrabAnim();
}

function PlayGrappleLoopAnim()
{
    local float Duration, InterruptTime, ActualDrainTime, DrainsPerSecond;

    // Get our anim duration
    Duration = PlaySpecialMoveAnim( GrappleAnims[0], EAS_FullBody );

    // Set our release timer
    bAlreadyDetachedFollower = false;
    InterruptTime = KFSkeletalMeshComponent(KFPOwner.Mesh).GetAniminterruptTime( GrappleAnims[0] );
    KFPOwner.SetTimer( InterruptTime, false, nameof(Timer_DetachFollower), self );

    if( KFPOwner.Role == ROLE_Authority )
    {
        // Set our special move flag so clients start the grab as well
        KFPOwner.SpecialMoveFlags = EGS_GrabSuccess;

        PostDrainAttackCooldown = (Duration - InterruptTime) + 0.5f;
        ActualDrainTime = InterruptTime - DelayBeforeDrain;
        DrainsPerSecond = 1.f / DrainInterval;
        // Number of times the drain timer will be called
        NumDrainsRemaining = ActualDrainTime / DrainInterval;

        // Determine the rate to draw life at
        if( Follower.GetHealthPercentage() > EnemyDrawLifeThreshold )
        {
            // Damage the player only in the period between the initial drain delay and the follower detach time
            DamageDrainRemaining = Max(Follower.Health - (float(Follower.HealthMax) * EnemyDrawLifeThreshold), 0);
        }
        else
        {
            DamageDrainRemaining = 0;
        }

        // Heal only in the period between the initial drain delay and the follower detach time
        HealthGainPerDrainInterval  = Max( (KFPawn_ZedHansBase(KFPOwner).GetHealAmountForThisPhase() / ActualDrainTime) / DrainsPerSecond, 1 );
    }
}

/** Called when grapple is successful and interaction pawn is attached */
function BeginGrapple(optional KFPawn Victim)
{
    local KFPawn_ZedHansBase HansPawn;
    local KFAIController KFAIC;
    local KFExplosionActor ExplosionActor;

    super.BeginGrapple( Victim );

    HansPawn = KFPawn_ZedHansBase(PawnOwner);
    if( Follower != none && HansPawn != none && HansPawn.Controller != none)
    {
        CachedFollower = Follower;

        // Don't let other zeds target this player
        Follower.ExclusiveTargetingController = HansPawn.Controller;

        // If other zeds are targeting this player, make them target someone else or wander around
        foreach Follower.WorldInfo.AllControllers( class'KFAIController', KFAIC )
        {
            if( KFAIC != none && KFAIC != HansPawn.Controller
                && KFAIC.Enemy == Follower )
            {
                KFAIC.Enemy = none;
                KFAIC.FindNewEnemy();

                // Have the enemies buzz off for a few if they can't find an enemy
                if( KFAIC.Enemy == none )
                {
                    KFAIC.DoWander( Follower, 5.0, true );
                }
                // Wander anyway if they are real close, just to get them away from Hans - Ramm, maybe add back later if needed
                //else if( VSizeSq(KFAIC.Pawn.Location - Follower.Location) < 250000 ) // 5 meters
                //{
                //    KFAIC.DoWander( Follower, 1.0, true );
                //}
            }
        }

        HansPawn.PlayHealDialog();

        // Set drain health timer
        KFPOwner.SetTimer( DelayBeforeDrain, true, nameof(Timer_DrainHealth), self );
    }

    // spawn smoke cloud
    ExplosionActor = KFPOwner.Spawn(LifeDrainSmokeExplosionActorClass, KFPOwner,, KFPOwner.mesh.GetBoneLocation('Root'), rotator(vect(0,0,1)));
    if( ExplosionActor != none )
    {
        ExplosionActor.Explode( LifeDrainSmokeExplosionTemplate );
    }

    if( KFPOwner.WorldInfo.NetMode != NM_DedicatedServer )
    {
        InvulnerableEnergyPSC = KFPOwner.WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(InvulnerableEnergyFX, KFPOwner.Mesh, InvulnerableEnergySocketName, true);
    }    
}

/** Toggle attachment */
function SpecialMoveFlagsUpdated()
{
    if( KFPOwner.SpecialMoveFlags != 128 )
    {
        super.SpecialMoveFlagsUpdated();
    }
}

function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
    local KFAISpawnManager SpawnManager;
    local KFPawn_ZedHansBase HansPawn;

    KFPOwner.ClearTimer( nameof(Timer_DrainHealth), self );
    KFPOwner.ClearTimer( nameof(Timer_DetachFollower), self );

    if( KFPOwner != none && KFPOwner.MyKFAIC != none && KFPOwner.MyKFAIC != none
        && KFAIController_Hans(KFPOwner.MyKFAIC) != none )
    {
        HansPawn = KFPawn_ZedHansBase(KFPOwner);

        // stop hunting players and sucking health if you got enough health
        if( HansPawn != none )
        {        
            if( HansPawn.AmountHealedThisPhase > HansPawn.GetHealAmountForThisPhase() * 0.75f )
            { 
                HansPawn.SetHuntAndHealMode( false );
            }
        }
        SpawnManager = KFGameInfo(PawnOwner.WorldInfo.Game).SpawnManager; 
        if ( SpawnManager != none )
        {
            SpawnManager.StopSummoningBossMinions();
        }

        if( CachedFollower != none && HansPawn != none && KFPOwner.MyKFAIC != none)
        {
            // If there is no enemy taunt instead of just standing around
            if( KFPOwner.MyKFAIC.Enemy == None && HansPawn.CanDoSpecialMove(SM_Taunt) )
            {
                class'AICommand_TauntEnemy'.static.Taunt( KFPOwner.MyKFAIC, CachedFollower, TAUNT_Standard );
            }
        }
    }

    if( InvulnerableEnergyPSC != none )
    {
        KFPOwner.DetachEmitter( InvulnerableEnergyPSC );
    }
    CachedFollower = none;

    super.SpecialMoveEnded( PrevMove, NextMove );
}

function Timer_DrainHealth()
{
    local KFPawn_ZedHansBase HansPawn;
    local int Damage;

    if( KFPOwner != none && KFPOwner.Health > 0 && Follower != none && Follower.Health >= 0 && Follower.IsDoingSpecialMove(SM_HansGrappleVictim) )
    {
        if ( NumDrainsRemaining > 0 )
        {
            // Round off an integer damage value from the total damage left
            Damage = Round(float(DamageDrainRemaining) / NumDrainsRemaining);
            DamageDrainRemaining -= Damage;
            NumDrainsRemaining--;

            // Allow life to drop below EnemyDrawLifeThreshold, but don't deal killing blow
            if( Damage > 0 && (float(Follower.Health - Damage) / Follower.HealthMax) > MinEnemyLifeDrawThreshold )
            {
                Follower.TakeDamage( Damage, KFPOwner.Controller, Follower.Location, vect(0,0,0), class'KFDT_DrainHealth' );
            }
        }

        KFPOwner.HealDamage( HealthGainPerDrainInterval, KFPOwner.Controller, class'KFDT_Healing' );

        HansPawn = KFPawn_ZedHansBase(KFPOwner);
        if( HansPawn != none )
        {
            HansPawn.AmountHealedThisPhase += HealthGainPerDrainInterval;
            // Don't let Hans try and toss smoke right after healing
            HansPawn.LastSmokeTossTime = HansPawn.WorldInfo.TimeSeconds;
        }        
    }
    else
    {
        KFPOwner.ClearTimer( nameof(Timer_DrainHealth), self );
    }
}

function Timer_DetachFollower()
{
    // Set flag so follower doesn't try to end special move after detaching
    bAlreadyDetachedFollower = true;

    // Clear timers
    KFPOwner.ClearTimer( nameof(Timer_DrainHealth), self );
    KFPOwner.ClearTimer( nameof(CheckReadyToStartInteraction), self );
    KFPOwner.ClearTimer( nameof(InteractionStartTimedOut), self );
    KFPOwner.ClearTimer( nameof(RetryCollisionTimer), self );

    if( Follower != none )
    {
        if( KFPOwner.Role == ROLE_Authority )
        {
            // Have Hans and other zeds not attack this player after he just drained them
            Follower.AIIgnoreEndTime = Follower.WorldInfo.TimeSeconds + PostDrainAttackCooldown;

            if( KFPOwner.MyKFAIC != none )
            {
                KFPOwner.MyKFAIC.Enemy = none;
                KFPOwner.MyKFAIC.FindNewEnemy();
            }
        }

        // Zero movement variables on Follower to stop any animation-driven motion
        if( bAlignPawns && !KFPOwner.IsHumanControlled() )
        {
            Follower.ZeroMovementVariables();
        }

        // End special move on Follower
        Follower.EndSpecialMove();
    }

    if( ExecutionCameraAnimInst_Follower != None )
    {
        if( PCOwner != None )
        {
            PCOwner.PlayerCamera.StopCameraAnim( ExecutionCameraAnimInst_Follower );
        }
        ExecutionCameraAnimInst_Follower = None;
    }

    // Clear reference to Interaction Pawn.
    Follower = None;
}

// Use timer & animlength instead of animend
function AnimEndNotify( AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime )
{
    ActiveSlotNode = None;

    // By default end this special move.
    KFPOwner.EndSpecialMove();
}

/** Notification when Follower is leaving his FollowerSpecialMove */
function OnFollowerLeavingSpecialMove()
{
    if( bAlreadyDetachedFollower )
    {
        return;
    }

    KFPOwner.EndSpecialMove();
}

/** Disable grab interruption */
function NotifyOwnerTakeHit(class<KFDamageType> DamageType, vector HitLoc, vector HitDir, Controller InstigatedBy);

DefaultProperties
{
    FollowerSpecialMove=SM_HansGrappleVictim
    AlignDistance=108.f
    AlignFollowerInterpSpeed=22.f
    bStopAlignFollowerRotationAtGoal=false
    bCanOnlyWanderAtEnd=true
    MaxGrabDistance=250.f
    bCanBeBlocked=false
    bCanBeInterrupted=false

    // ---------------------------------------------
    // Animations
    GrabStartAnimName=Atk_Paralyze_V1
    GrabStartAnimNameLunge=Atk_Lunge_Paralyze_V1
    GrappleAnims=(Atk_DrawLife_V1)

    DelayBeforeDrain=0.25f
    DrainInterval=0.25f

    MaxEnemyLifeDrawThresholdNormal=0.70
    MaxEnemyLifeDrawThresholdHard=0.45   //0.6
    MaxEnemyLifeDrawThresholdSuicidal=0.35  //0.5
    MaxEnemyLifeDrawThresholdHellOnEarth=0.25  //0.25
    MinEnemyLifeDrawThreshold=0.1

    // smoke cloud explosion template
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=0
        DamageRadius=0
        KnockDownRadius=0
        CringeRadius=0
        bCausesFracture=false

        // effects
        ExplosionEffects=KFImpactEffectInfo'ZED_Hans_EMIT.SmokeGrenade_Explosion'
        ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Explosion'
    End Object
    LifeDrainSmokeExplosionTemplate=ExploTemplate0

    // smoke cloud explosion actor
    LifeDrainSmokeExplosionActorClass=class'KFExplosion_HansSmokeGrenade'

    // invulnerable energy
    InvulnerableEnergyFX=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Energy'
    InvulnerableEnergySocketName=Root
}