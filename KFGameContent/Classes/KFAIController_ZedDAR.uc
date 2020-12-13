//=============================================================================
// KFAIController_ZedDAR
//=============================================================================
// Base AI controller for evil DAR robots.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedDAR extends KFAIController_Ranged
	abstract;

var float MinRangeAttackDist;
var float MaxRangeAttackDist;
var float LastRangeAttackTime;
var float TimeBetweenRangeAttacks;
var float BaseTimeBetweenRangeAttacks;
var float TimeBetweenRangeAttackVariance;
var float CheckSpecialMoveTime;
var float LastCheckSpecialMoveTime;

var name FiringSocketName;

var protected float RangeAttackIntervalNormal;
var protected float RangeAttackIntervalHard;
var protected float RangeAttackIntervalSuicidal;
var protected float RangeAttackIntervalHellOnEarth;

var float HeadLossAttackTimeDebuff;
var float HeadLossAccuracyDebuffPct;

var float AimError;

var bool bAllowedToSprint;
var bool bCanEvade;

var int ArmorLossStumblePower;

event PostBeginPlay()
{
	Super.PostBeginPlay();

	BaseTimeBetweenRangeAttacks = GetAttackIntervalByDifficulty();

	TimeBetweenRangeAttacks = BaseTimeBetweenRangeAttacks;
	if(TimeBetweenRangeAttackVariance > 0)
	{
		TimeBetweenRangeAttacks += RandRange(-TimeBetweenRangeAttackVariance, TimeBetweenRangeAttackVariance);
	}
}

function float GetAttackIntervalByDifficulty()
{
	if (Skill == class'KFGameDifficultyInfo'.static.GetDifficultyValue(0)) // Normal
	{
		return RangeAttackIntervalNormal;
	}
	else if (Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(1)) // Hard
	{
		return RangeAttackIntervalHard;
	}
	else if (Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(2)) // Suicidal
	{
		return RangeAttackIntervalSuicidal;
	}
	else if (Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(3)) // Hell on Earth
	{
		return RangeAttackIntervalHellOnEarth;
	}

	return RangeAttackIntervalNormal;
}

function bool CanDoRangedAttack(float DistanceToTargetSqr)
{
	if (!CheckOverallCooldownTimer())
	{
		return false;
	}

	return ((LastRangeAttackTime == 0 || (`TimeSince(LastRangeAttackTime) > TimeBetweenRangeAttacks)) &&
		DistanceToTargetSqr >= Square(MinRangeAttackDist) &&
		DistanceToTargetSqr <= Square(MaxRangeAttackDist) &&
		MyKFPawn.CanDoSpecialMove(SM_StandAndShootAttack));
}

simulated function Tick(float DeltaTime)
{
	local float DistToTargetSqr;

	Super.Tick(DeltaTime);

	if (Role == ROLE_Authority && Enemy != none && MyKFPawn != none)
	{
		if (`TimeSince(LastCheckSpecialMoveTime) >= CheckSpecialMoveTime && !MyKFPawn.IsDoingSpecialMove() )
		{
			if (GetActiveCommand() != none && !GetActiveCommand().IsA('AICommand_SpecialMove'))
			{
				// Trace from worldinfo, open doors ignore traces from zeds
				if (WorldInfo.FastTrace(Enemy.Location, Pawn.Location, , true))
				{
					DistToTargetSqr = VSizeSq(Enemy.Location - Pawn.Location);
					if (CanDoRangedAttack(DistToTargetSqr))
					{
						if (KFGameInfo(WorldInfo.Game) != none && KFGameInfo(WorldInfo.Game).GameConductor != none)
						{
							KFGameInfo(WorldInfo.Game).GameConductor.UpdateOverallAttackCoolDowns(self);
						}

						StartRangedAttack();
						if(TimeBetweenRangeAttackVariance > 0)
						{
							TimeBetweenRangeAttacks = BaseTimeBetweenRangeAttacks + RandRange(-TimeBetweenRangeAttackVariance, TimeBetweenRangeAttackVariance);
						}
					}
				}
			}
			LastCheckSpecialMoveTime = WorldInfo.TimeSeconds;
		}

		if (MyKFPawn.IsDoingSpecialMove(SM_StandAndShootAttack))
		{
			Focus = none;
			SetFocalPoint(Enemy.Location);
		}
		else if (Focus == none)
		{
			Focus = Enemy;
		}
	}
}

event bool SetEnemy(Pawn NewEnemy)
{
	if (MyKFPawn == none || MyKFPawn.IsDoingSpecialMove(SM_StandAndShootAttack))
	{
		if (MyKFPawn.NeedToTurn(NewEnemy.Location))
		{
			`AILog( GetFuncName() $ "() rejecting " $ NewEnemy $ " because current enemy (" $ Enemy $ ") we would need to turn to see it", 'SetEnemy' );
			return false;
		}
	}

	return super.SetEnemy(NewEnemy);
}

function StartRangedAttack();

function FireRangedAttack(class<KFProjectile> RangedProjectileClass, vector ProjectileOffset)
{
	local vector SocketLocation, DirToEnemy, HitLocation, HitNormal;
	local KFProjectile SpawnedProjectile;
	local actor	HitActor;
	local Vector AimLocation, AimDispalcement;
	local vector displacementToHitLoc;
	local float distanceToHitLoc;

	if (MyKFPawn == none)
	{
		return;
	}

	if (bDebugAimError)
	{
		// Render debug lines and simulate several shots at once to evaluate aimerror
		DebugAimError(FiringSocketName);
		return;
	}

	SocketLocation = GetStartFireLocation() + (ProjectileOffset >> Pawn.GetViewRotation());
	if (MyKFPawn.Health > 0.f && Role == ROLE_Authority && MyKFPawn.IsDoingSpecialMove(SM_StandAndShootAttack))
	{
		AimLocation = Enemy.Location;
		HitActor = WorldInfo.Trace(HitLocation, HitNormal, AimLocation, SocketLocation, true);

		// Don't shoot if it's too close
		if (HitActor == Enemy)
		{
			if (!bCanLeadTarget)
			{
				DirToEnemy = normal(AimLocation - SocketLocation);

				`AILog_Ext( GetFuncName() @ "Leading - HitActor: " @ HitActor @ " Is My Enemy: " @ Enemy, 'FireBall', self );
			}
			else
			{
				DirToEnemy = normal(CalcAimLocToHit(AimLocation, SocketLocation, RangedProjectileClass.default.Speed, RangedProjectileClass.default.Speed, Enemy.Velocity) - SocketLocation);

				`AILog_Ext( GetFuncName() @ "Not Leading - HitActor: " @ HitActor @ " Is My Enemy: " @ Enemy, 'FireBall', self );
			}
		}
		else
		{
			// If our path to the enemy is blocked, try his last known position
			AimLocation = AICommand_RangedAttack(GetActiveCommand()).LastKnownEnemyLocation;
			HitActor = Trace(HitLocation, HitNormal, AimLocation, SocketLocation, true);

			displacementToHitLoc = HitLocation - SocketLocation;
			distanceToHitLoc = VSize(displacementToHitLoc);

			// If there is an object in front of us, cancel the attack
			if (distanceToHitLoc < MinRangeAttackDist)
			{
				`AILog_Ext( GetFuncName() @ "- HitActor: " @ HitActor @ " Is NOT My Enemy: " @ Enemy @ " and distanceToHitLoc: " @ distanceToHitLoc @ " is too close so not firing!!!", 'FireBall', self );
				MyKFPawn.SpecialMoves[SM_StandAndShootAttack].AbortedByAICommand();
				LastRangeAttackTime = WorldInfo.TimeSeconds;
				return;
			}
			else // Otherwise fire at the enemies last known position
			{
				DirToEnemy = normal((AimLocation - SocketLocation));

				`AILog_Ext( GetFuncName() @ "- Fire at enemy last known position : " @ Enemy @ AimLocation, 'FireBall', self );
			}
		}

		AimDispalcement = VRand();
		DirToEnemy += (AimDispalcement * AimError);

		// Shoot the fireball
		SpawnedProjectile = Spawn(RangedProjectileClass, MyKFPawn, , SocketLocation, Rotator(DirToEnemy));
		SpawnedProjectile.Instigator = MyKFPawn;
		SpawnedProjectile.InstigatorController = self;

		// Fire
		SpawnedProjectile.Init(DirToEnemy);

		LastRangeAttackTime = WorldInfo.TimeSeconds;
	}
}

function vector GetStartFireLocation()
{
	return MyKFPawn.GetPawnViewLocation();
}

function bool ShouldSprint()
{
	return bAllowedToSprint && super.ShouldSprint();
}

function bool CanEvade(optional bool bOverrideSpecialMove)
{
	return bCanEvade && super.CanEvade(bOverrideSpecialMove);
}

function OnArmorLoss(name ArmorName)
{
	MyKFPawn.AfflictionHandler.AccrueAffliction(AF_Stumble, ArmorLossStumblePower);

	if(ArmorName == 'head')
	{
		BaseTimeBetweenRangeAttacks += HeadLossAttackTimeDebuff;
		AimError *= (1.f + HeadLossAccuracyDebuffPct);
	}
	else if (ArmorName == 'front')
	{
		bCanSprint = false;
		bAllowedToSprint = false;
		bCanEvade = false;
		MyKFPawn.bIsSprinting = false;
	}
}

defaultproperties
{
	// ---------------------------------------------
	// Danger Evasion Settings
	DangerEvadeSettings.Empty
    DangerEvadeSettings(0)={(ClassName="KFProj_Bullet_Pellet",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(1)={(ClassName="KFProj_Nail_Nailgun",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(2)={(ClassName="KFProj_Bullet_DragonsBreath",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(3)={(ClassName="KFProj_HighExplosive_M79",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(4)={(ClassName="KFProj_HighExplosive_M32",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(5)={(ClassName="KFProj_Rocket_RPG7",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(6)={(ClassName="KFDT_Explosive_M16M203",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(7)={(ClassName="KFDT_Explosive_HRGIncendiaryRifle",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}


	//shooting fire
	DangerEvadeSettings(8)={(ClassName="KFProj_CaulkNBurn_GroundFire",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(9)={(ClassName="KFProj_FlameThrower_GroundFire",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(10)={(ClassName="KFWeap_Flame_CaulkBurn",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(11)={(ClassName="KFWeap_Flame_Flamethrower",
							    Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(12)={(ClassName="KFWeap_Beam_Microwave",
							    Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.4, 0.5, 0.6, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}


    //Aimed weapons it dodges //sharpshooter
    DangerEvadeSettings(13)={(ClassName="KFWeap_Bow_Crossbow",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(14)={(ClassName="KFWeap_Rifle_M14EBR",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(15)={(ClassName="KFWeap_Rifle_Winchester1894",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}
    DangerEvadeSettings(16)={(ClassName="KFWeap_Rifle_RailGun",
                                Cooldowns=(2.3, 2.3, 2.3, 1.3), // Normal, Hard, Suicidal, HoE
                                EvadeChances=(0.08, 0.1, 0.2, 0.35),
                                ForcedEvadeChances={((FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
                                ReactionDelayRanges={((X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15), (X=0.0, Y=0.15))},
                                SoloChanceMultiplier=1.0)}

	//Grenades
	DangerEvadeSettings(17)={(ClassName="KFProj_FragGrenade",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(18)={(ClassName="KFProj_MolotovGrenade",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(19)={(ClassName="KFProj_DynamiteGrenade",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(20)={(ClassName="KFProj_NailBombGrenade",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(21)={(ClassName="KFProj_HEGrenade",
								Cooldowns=(3.0, 2.0, 1.0, 0.75), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}

	// Ground Fire
	DangerEvadeSettings(22)={(ClassName="KFProj_Flame_HRGIncendiaryRifle",
								Cooldowns=(3.0, 2.0, 1.5,  1.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.1, 0.3, 0.5, 0.7),
								ReactionDelayRanges={((X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5), (X=0.3, Y=0.5))},
								SoloChanceMultiplier=1.0)}

	BaseShapeOfProjectileForCalc=(X=10,Y=10,Z=10)
	bUseDesiredRotationForMelee=false
	bCanTeleportCloser=false

	// ---------------------------------------------
	// Behaviors

	EvadeGrenadeChance=0.9f
	CheckSpecialMoveTime=0.25f
	SprintWithinEnemyRange=(X=500.f,Y=5000.f)  //X=800.f,Y=1500

	RangeAttackIntervalNormal=7.0
	RangeAttackIntervalHard=6.0
	RangeAttackIntervalSuicidal=5.0
	RangeAttackIntervalHellOnEarth=4.0

	TimeBetweenRangeAttackVariance=1.0

	MinRangeAttackDist=300
	MaxRangeAttackDist=4000

	HeadLossAttackTimeDebuff=2.f
	HeadLossAccuracyDebuffPct=2.0f //0.25

	AimError=0.03f

	ArmorLossStumblePower=100

	bAllowedToSprint=true
	bCanEvade=true
}
