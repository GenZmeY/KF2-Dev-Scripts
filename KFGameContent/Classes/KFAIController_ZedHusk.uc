//=============================================================================
// KFAIController_ZedHusk
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_ZedHusk extends KFAIController_Ranged;

var bool bBaseCommandInitialized;

var float	MinDistanceToSuicide;
var float	RequiredHealthPercentForSuicide;
var vector	LastEnemySeenPosition;

var float LastFireBallTime;
var float LastFlameThrowerTime;

/** The time until we shoot again based on difficulty without any randomization */
var float BaseTimeBetweenFireBalls;
/** The time to wait until our next shot, gets randomized with each shot */
var float TimeBetweenFireBalls;

/** The time to wait until we can use the flamethrower again*/
var float TimeBetweenFlameThrower;

var float FireballRandomizedValue;

/** The maximum distance an enemy can be from our pawn for us to be able to do a flamethrower attack */
var int MaxDistanceForFlameThrower;

/** The minimum distance an enemy must be from our pawn for us to be able to do a fireball attack */
var int MinDistanceForFireBall;

/** The maximum distance an enemy can be from our pawn for us to be able to do a fireball attack */
var int MaxDistanceForFireBall;

var bool bCanUseFlameThrower;

var float LastCheckSpecialMoveTime;
var float CheckSpecialMoveTime;

/** Fireball projectile attack */
var name							FireballSocketName;
/** Accuracy spread of fireball aim attack */
var const	float					FireballAimError;
/** Accuracy spread of leading a target for fireball aim attack */
var const	float					FireballLeadTargetAimError;
/** Speed of the fireball. Will override projectile speed. */
var const	float					FireballSpeed;

/** Chance to aim fireballs for splash damage on Normal difficulty */
var const	float					SplashAimChanceNormal;
/** Chance to aim fireballs for splash damage on Hard difficulty */
var const	float					SplashAimChanceHard;
/** Chance to aim fireballs for splash damage on Suicide difficulty */
var const	float					SplashAimChanceSuicidal;
/** Chance to aim fireballs for splash damage on Hell On Earth difficulty */
var const	float					SplashAimChanceHellOnEarth;

/** The base time to wait between firing fireballs on Normal difficulty */
var const float					FireballFireIntervalNormal;
/** The base time to wait between firing fireballs on Hard difficulty */
var const float					FireballFireIntervalHard;
/** The base time to wait between firing fireballs on Suicidal difficulty */
var const float					FireballFireIntervalSuicidal;
/** The base time to wait between firing fireballs on Hell On Earth difficulty */
var const float					FireballFireIntervalHellOnEarth;

/** How much to scale the used FireballInterval to get the low intensity attack scale */
var const float                 LowIntensityAttackScaleOfFireballInterval;

event PostBeginPlay()
{
	local KFGameInfo KFGI;

	super.PostBeginPlay();

	if( WorldInfo.Game != none )
	{
		KFGI = KFGameInfo(WorldInfo.Game);
		// If the difficulty is hard or higher, enable the flamethrower
		if ( KFGI != none && KFGI.GetModifiedGameDifficulty() >= KFGI.DifficultyInfo.GetDifficultyValue(2))
		{
			bCanUseFlameThrower = true;
		}
	}

	// Determine the interval of allowing fireballs to be fired
    if( Skill == class'KFGameDifficultyInfo'.static.GetDifficultyValue(0) ) // Normal
    {
        BaseTimeBetweenFireBalls = FireballFireIntervalNormal;
    }
    else if( Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(1) ) // Hard
    {
        BaseTimeBetweenFireBalls = FireballFireIntervalHard;
    }
    else if( Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(2) ) // Suicidal
    {
        BaseTimeBetweenFireBalls = FireballFireIntervalSuicidal;
    }
    else // Hell on Earth
    {
        BaseTimeBetweenFireBalls = FireballFireIntervalHellOnEarth;
    }

    // Set the low intensity attack cooldown based off the current fireball interval
    LowIntensityAttackCooldown = BaseTimeBetweenFireBalls * LowIntensityAttackScaleOfFireballInterval;

	TimeBetweenFireBalls = BaseTimeBetweenFireBalls + RandRange(-FireballRandomizedValue, FireballRandomizedValue);
}

simulated function Tick( FLOAT DeltaTime )
{
	local float DistToTargetSq;

	super.Tick(DeltaTime);

	if( Role == ROLE_Authority && Enemy != none && MyKFPawn != none )
	{
		// Do not check every tick
		if( `TimeSince(LastCheckSpecialMoveTime) >= CheckSpecialMoveTime && !MyKFPawn.IsDoingSpecialMove() )
		{
			if( GetActiveCommand() != none && !GetActiveCommand().IsA('AICommand_SpecialMove') )
			{
				// Trace from worldinfo, open doors ignore traces from zeds
				if( WorldInfo.FastTrace( Enemy.Location, Pawn.Location,, true ) )
				{
					DistToTargetSq = VSizeSq( Enemy.Location - Pawn.Location );

					// If you are suicidal, do not even try to use the flamethrower or fireball
					if( IsSuicidal() )
					{
						if( CanDoSuicide(DistToTargetSq) )
						{
							class'AICommand_Husk_Suicide'.static.Suicide(self);
						}
					}
					// Check if i can use my flamethrower
					else if( CanDoFlamethrower(DistToTargetSq) )
					{
                    	if( KFGameInfo(WorldInfo.Game) != none && KFGameInfo(WorldInfo.Game).GameConductor != none )
                    	{
                    	   KFGameInfo(WorldInfo.Game).GameConductor.UpdateOverallAttackCoolDowns(self);
                    	}

						class'AICommand_HuskFlameThrowerAttack'.static.FlameThrowerAttack(self);
					}
					// Check if i can use my projectile
					else if( CanDoFireball(DistToTargetSq) )
					{
                    	if( KFGameInfo(WorldInfo.Game) != none && KFGameInfo(WorldInfo.Game).GameConductor != none )
                    	{
                    	   KFGameInfo(WorldInfo.Game).GameConductor.UpdateOverallAttackCoolDowns(self);
                    	}

						class'AICommand_HuskFireBallAttack'.static.FireBallAttack(self);
						// Randomize the next fireball time
						TimeBetweenFireBalls = BaseTimeBetweenFireBalls + RandRange(-FireballRandomizedValue, FireballRandomizedValue);
					}
				}
			}
			LastCheckSpecialMoveTime = WorldInfo.TimeSeconds;
		}
	}
}

function bool IsSuicidal()
{
	if( MyKFPawn == none || MyKFPawn.bIsHeadless )
	{
		return false;
	}
	return( GetHealthPercentage() <= RequiredHealthPercentForSuicide );
}

function bool CanDoSuicide( float DistToTargetSq )
{
	 if( DistToTargetSq <= (MinDistanceToSuicide * MinDistanceToSuicide) &&
		MyKFPawn.CanDoSpecialMove(SM_Suicide) )
	 {
		 return true;
	 }
	 return false;
}

function bool CanDoFlamethrower( float DistToTargetSq )
{
    if( !CheckOverallCooldownTimer() )
    {
        return false;
    }

	 if( bCanUseFlameThrower &&
		(LastFlameThrowerTime == 0 || (`TimeSince(LastFlameThrowerTime) > TimeBetweenFlameThrower)) &&
		DistToTargetSq <= MaxDistanceForFlameThrower * MaxDistanceForFlameThrower &&
		MyKFPawn.CanDoSpecialMove(SM_HoseWeaponAttack) )
	 {
		 return true;
	 }
	 return false;
}

function bool CanDoFireball( float DistToTargetSq )
{
    if( !CheckOverallCooldownTimer() )
    {
        return false;
    }

	 return ((LastFireBallTime == 0 || (`TimeSince(LastFireBallTime) > TimeBetweenFireBalls))
	 	&& DistToTargetSq >= Square(MinDistanceForFireBall)
	 	&& DistToTargetSq <= Square(MaxDistanceForFireBall)
		&& MyKFPawn.CanDoSpecialMove(SM_StandAndShootAttack));
}

/** Overridden so the husk will not change to an enemy outside his view while doing the fireball attack */
event bool SetEnemy( Pawn NewEnemy )
{
	if( MyKFPawn == none || MyKFPawn.IsDoingSpecialMove(SM_StandAndShootAttack) )
	{
		if( MyKFPawn.NeedToTurn(NewEnemy.Location) )
		{
			`AILog( GetFuncName()$"() rejecting "$NewEnemy$" because current enemy ("$Enemy$") we would need to turn to see it", 'SetEnemy' );
			return false;
		}
	}

	return super.SetEnemy( NewEnemy );
}

/** Always sprint if we are suicidal */
function bool ShouldSprint()
{
	if( IsSuicidal() )
	{
		return true;
	}
	return super.ShouldSprint();
}

function DoStrike()
{
	if( MyKFPawn.PawnAnimInfo.Attacks[PendingAnimStrikeIndex].Tag == 'Projectile' )
	{
		`DialogManager.PlaySpotRocketsDialog( MyKFPawn );
	}

	super.DoStrike();
}

function ShootFireball( class<KFProj_Husk_Fireball> FireballClass, vector FireballOffset )
{
	local vector		SocketLocation, DirToEnemy, HitLocation, HitNormal;
	local KFProj_Husk_Fireball MyFireball;
	local actor			HitActor;
	local Vector AimLocation, GroundAimLocation;
	local float SplashAimChance;
	local vector randVectorDraw;
	local float randDraw;
	local vector displacementToHitLoc;
	local float distanceToHitLoc;
	local KFPawn_ZedHusk MyHuskPawn;

	if( MyKFPawn == none )
	{
		return;
	}

   	if( bDebugAimError )
	{
		// Render debug lines and simulate several shots at once to evaluate aimerror
		DebugAimError(FireballSocketName, FireballAimError);
		return;
	}

	SocketLocation = MyKFPawn.GetPawnViewLocation() + (FireballOffset >> Pawn.GetViewRotation());
	if( MyKFPawn.Health > 0.f && Role == ROLE_Authority && MyKFPawn.IsDoingSpecialMove(SM_StandAndShootAttack) )
	{
        AimLocation = Enemy.Location;

        // Determine the random chance of aiming at the ground for splash damage
        if( Skill == class'KFGameDifficultyInfo'.static.GetDifficultyValue(0) ) // Normal
        {
            SplashAimChance = SplashAimChanceNormal;
        }
        else if( Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(1) ) // Hard
        {
            SplashAimChance = SplashAimChanceHard;
        }
        else if( Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(2) ) // Suicidal
        {
            SplashAimChance = SplashAimChanceSuicidal;
        }
        else // Hell on Earth
        {
            SplashAimChance = SplashAimChanceHellOnEarth;
        }

		randDraw = FRand();

		`AILog_Ext( GetFuncName() @ " SplashAimChance: " @ SplashAimChance @ " randDraw: " @ randDraw, 'FireBall', self );

        if( randDraw < SplashAimChance )
		{
			// Simple pass at making the Husk try and do splash damage when it shoots at a player rather than just shoot directly at them (and most likely miss)
            GroundAimLocation = Enemy.Location - (vect(0,0,1) * Enemy.GetCollisionHeight());

            if( GroundAimLocation.Z < SocketLocation.Z )
            {
                AimLocation = GroundAimLocation;
            }
		}

		//DrawDebugLine( SocketLocation, AimLocation, 0, 0, 255, true );

        HitActor = WorldInfo.Trace( HitLocation, HitNormal, AimLocation, SocketLocation, true );

        // Don't shoot if it's too close
		if( HitActor == Enemy )
		{
			//DrawDebugStar( HitLocation, 50, 0, 255, 0, true );

			randVectorDraw = VRand();

			if( !bCanLeadTarget )
			{
 				DirToEnemy = normal( AimLocation - SocketLocation ) + randVectorDraw * FireballAimError;

				`AILog_Ext( GetFuncName() @ " HitActor: " @ HitActor @ " Is My Enemy: " @ Enemy @ " randVectorDraw: " @ randVectorDraw @ " - not leading with an error of: " @ randVectorDraw * FireballAimError, 'FireBall', self );
			}
 			else
 			{
 				DirToEnemy = normal( CalcAimLocToHit(AimLocation, SocketLocation, FireballSpeed, FireballSpeed, Enemy.Velocity) - SocketLocation ) + randVectorDraw * FireballLeadTargetAimError;

				`AILog_Ext( GetFuncName() @ " HitActor: " @ HitActor @ " Is My Enemy: " @ Enemy @ " randVectorDraw: " @ randVectorDraw @ " - leading with an error of: " @ randVectorDraw * FireballLeadTargetAimError, 'FireBall', self );
 			}
		}
		else
		{
			// If our path to the enemy is blocked, try his last known position
			AimLocation = AICommand_HuskFireBallAttack(GetActiveCommand()).LastKnownEnemyLocation;
			HitActor = Trace( HitLocation, HitNormal, AimLocation, SocketLocation, true );

			displacementToHitLoc = HitLocation - SocketLocation;
			distanceToHitLoc = VSize( displacementToHitLoc );

			// If there is an object in front of us, cancel the attack
			if( distanceToHitLoc < 300 )
			{
				//DrawDebugStar( HitLocation, 50, 255, 0, 0, true );

				`AILog_Ext( GetFuncName() @ " HitActor: " @ HitActor @ " Is NOT My Enemy: " @ Enemy @ " and distanceToHitLoc: " @ distanceToHitLoc @ " is too close so not firing!!!", 'FireBall', self );
				MyKFPawn.SpecialMoves[ SM_StandAndShootAttack ].AbortedByAICommand();
				LastFireBallTime = WorldInfo.TimeSeconds;
				return;
			}
			else // Otherwise fire at the enemies last known position
			{
				//DrawDebugStar( HitLocation, 50, 0, 0, 255, true );

				randVectorDraw = VRand();
				DirToEnemy = normal( (AimLocation - SocketLocation) + randVectorDraw * FireballAimError );

				`AILog_Ext( GetFuncName() @" Fire at enemy last known position: " @ Enemy @ AimLocation @ " randVectorDraw: " @ randVectorDraw @ " - leading with an error of: " @ randVectorDraw * FireballLeadTargetAimError, 'FireBall', self );
			}
		}

		//DrawDebugLine( SocketLocation, SocketLocation + DirToEnemy * 5000.0, 255, 0, 0, true );
		MyHuskPawn = KFPawn_ZedHusk( MyKFPawn );

		// Shoot the fireball
		MyFireball = Spawn( FireballClass, MyKFPawn,, SocketLocation, Rotator(DirToEnemy) );
		MyFireball.Instigator			= MyKFPawn;
		MyFireball.InstigatorController	= self;
		MyFireball.Speed				= FireballSpeed;
		MyFireball.MaxSpeed				= FireballSpeed;

		// Set our difficulty setings
		MyFireball.ExplosionTemplate.MomentumTransferScale = MyHuskPawn.FireballSettings.ExplosionMomentum;
		MyFireball.bSpawnGroundFire = MyHuskPawn.FireballSettings.bSpawnGroundFire;

		// Fire
		MyFireball.Init( DirToEnemy );

		LastFireBallTime = WorldInfo.TimeSeconds;
	}
}

DefaultProperties
{
	BaseShapeOfProjectileForCalc=(X=10,Y=10,Z=10)
	FireballSocketName=FireballSocket
	bUseDesiredRotationForMelee=false
	bCanTeleportCloser=false

	// ---------------------------------------------
	// Behaviors

	EvadeGrenadeChance=0.9f

	CheckSpecialMoveTime=0.25f

	// Fireball
	MinDistanceForFireBall=300
	MaxDistanceForFireBall=4000

	FireballFireIntervalNormal=5.0
	FireballFireIntervalHard=4.5
	FireballFireIntervalSuicidal=4
	FireballFireIntervalHellOnEarth=3.5

	FireballRandomizedValue=1

	SplashAimChanceNormal=0.25
	SplashAimChanceHard=0.35
	SplashAimChanceSuicidal=0.5
	SplashAimChanceHellOnEarth=0.75

	FireballSpeed=3600.f
	FireballAimError=0.03f
	FireballLeadTargetAimError=0.03f
	bDebugAimError=false
	bCanLeadTarget=false

	// FlameThrower
	TimeBetweenFlameThrower=5
	MaxDistanceForFlameThrower=500
	LowIntensityAttackScaleOfFireballInterval=1.25

	// Suicide
	MinDistanceToSuicide=280
	RequiredHealthPercentForSuicide=0.15f
}
