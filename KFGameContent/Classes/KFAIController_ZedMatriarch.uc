//=============================================================================
// KFAIController_ZedMatriarch
//=============================================================================
// AI controller class for the matriarch.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFAIController_ZedMatriarch extends KFAIController_ZedBoss;

enum EMatriarchAttacksByRange
{
	EMatriarchAttacksByRange_SweepingClaw,
	EMatriarchAttacksByRange_LightningStorm,
	EMatriarchAttacksByRange_WarningSiren,
	EMatriarchAttacksByRange_TeslaBlast,
	EMatriarchAttacksByRange_PlasmaCannon,
	EMatriarchAttacksByRange_ScorpionWhip
};

/** Cached reference to patriarch pawn */
var KFPawn_ZedMatriarch MyMatPawn;

/** Whether attack evaluation is enabled or not */
var bool bCanEvaluateAttacks;

/** How long to wait before evaluating special attacks */
var float GlobalCooldownTimer;
var vector2d GlobalCooldownTimeRange_Melee;
var vector2d GlobalCooldownTimeRange_LightningStorm;
var vector2d GlobalCooldownTimeRange_WarningSiren;
var vector2d GlobalCooldownTimeRange_TeslaBlast;
var vector2d GlobalCooldownTimeRange_PlasmaCannon;
var vector2d GlobalCooldownTimeRange_ScorpionWhip;

/*
	Player Targeting
*/

var vector2d ReevaluateEnemiesTimeRange;
var transient float ReevaluateEnemiesTimer;
var array<int> PlayerDamages;
var Pawn CurrentTargetPawn;
var bool bLogTargeting;

/*
	Special Attacks
*/

var float SweepingClawCooldown, LastSweepingClawTime;
var float TeslaBlastCooldown, LastTeslaBlastTime;
var float PlasmaCannonCooldown, LastPlasmaCannonTime;
var float LightningStormCooldown, LastLightningStormTime;
var float WarningSirenCooldown, LastWarningSirenTime;
var float ScorpionWhipCooldown, LastScorpionWhipTime;

var config bool bRandomMoves;

/** Set MyPatPawn to avoid casting */
event Possess( Pawn inPawn, bool bVehicleTransition )
{
	super.Possess( inPawn, bVehicleTransition );

	if (KFPawn_ZedMatriarch(inPawn) != none)
	{
		MyMatPawn = KFPawn_ZedMatriarch(inPawn);
	}
	else
	{
		`warn( GetFuncName()$"() attempting to possess "$inPawn$", but it's not a KFPawn_ZedMatriarch class! MyMatPawn variable will not be valid." );
	}

	// Wait a bit before evaluating special attacks
	GlobalCooldownTimer = 2.5f + fRand();

	// Start evaluating on next tick
	bCanEvaluateAttacks = true;

	if (CommandList == none || CommandList.class != class'AICommand_BossTheatrics')
    {
        MyMatPawn.ActivateShield();
    }

	SetReevaluateEnemiesTimer();
}

simulated function SetReevaluateEnemiesTimer()
{
	ReevaluateEnemiesTimer = RandRange(ReevaluateEnemiesTimeRange.X, ReevaluateEnemiesTimeRange.Y);
	if (bLogTargeting)
	{
		`log(self$"::SetReevaluateEnemiesTimer - ReevaluateEnemiesTimer: "$ReevaluateEnemiesTimer);
	}
}

simulated function ReevaluateEnemies()
{
	local int MaxPlayerDamage, i;
	local KFPlayerController KFPC, MaxKFPC;

	if (bLogTargeting)
	{
		for (i = 0; i < PlayerDamages.Length; ++i)
		{
			`log(self$"::ReevaluateEnemies - PlayerDamages "$i$": "$PlayerDamages[i]);
		}
	}

	MaxPlayerDamage = 0;

	// find most damaging player
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		if (KFPawn(KFPC.Pawn).IsAliveAndWell())
		{
			if (PlayerDamages.Length > KFPC.PlayerNum &&
				PlayerDamages[KFPC.PlayerNum] > MaxPlayerDamage)
			{
				MaxPlayerDamage = PlayerDamages[KFPC.PlayerNum];
				MaxKFPC = KFPC;
			}
		}
		else
		{
			// mark invalid player as untargetable
			PlayerDamages[MaxKFPC.PlayerNum] = 0;
		}
	}

	if (bLogTargeting)
	{
		`log(self$"::ReevaluateEnemies - Max damage player: "$MaxKFPC);
	}

	// target most damaging player
	if (MaxKFPC != none)
	{
		CurrentTargetPawn = MaxKFPC.Pawn;
		ChangeEnemy(MaxKFPC.Pawn, false);

		// mark most damaging player as untargetable now
		PlayerDamages[MaxKFPC.PlayerNum] = 0;
	}

	SetReevaluateEnemiesTimer();
}

simulated function Tick(FLOAT DeltaTime)
{
    super.Tick(DeltaTime);
    EvaluateAttacks(DeltaTime);
}

event SeePlayer(Pawn Seen);

event bool FindNewEnemy()
{
	local bool Result;

	Result = super.FindNewEnemy();
	CurrentTargetPawn = Enemy;

	return Result;
}

/** Evaluates whether or not the Matriarch can do a special attack */
function EvaluateAttacks( float DeltaTime )
{
	local float DistToTargetSq;
	local array<EMatriarchAttacksByRange> PossibleMoves;
	local EMatriarchAttacksByRange ChosenMove;

	if (!bCanEvaluateAttacks)
	{
		return;
	}

	ReevaluateEnemiesTimer -= DeltaTime;

	if (MyMatPawn.IsDoingSpecialMove() ||
		(CommandList != none && GetActiveCommand().IsA('AICommand_SpecialMove')))
	{
		return;
	}

	if (MyMatPawn.bShouldTaunt)
	{
		MyMatPawn.bShouldTaunt = false;
		MyMatPawn.DoSpecialMove(SM_Taunt, true,, class'KFSM_Matriarch_Taunt'.static.PackSMFlags(MyMatPawn, TAUNT_Standard));
		return;
	}

	if (ReevaluateEnemiesTimer <= 0.f)
	{
		ReevaluateEnemies();
	}

	GlobalCooldownTimer -= DeltaTime;
	if (GlobalCooldownTimer > 0.f)
	{
		return;
	}

	// Trace from worldinfo, open doors ignore traces from zeds
    if (Enemy != none && WorldInfo.FastTrace(Enemy.Location, Pawn.Location, , true))
    {
        DistToTargetSq = VSizeSq(Enemy.Location - Pawn.Location);
		PossibleMoves = GetPossibleMovesByRange(DistToTargetSq);
		if (PossibleMoves.Length > 0)
		{
			if (!bRandomMoves)
			{
				ChosenMove = PossibleMoves[0];
			}
			else
			{
				ChosenMove = PossibleMoves[Rand(PossibleMoves.Length)];
			}

			switch (ChosenMove)
			{
			//case EMatriarchAttacksByRange_SweepingClaw:
			//	class'AICommand_Matriarch_SweepingClaw'.static.SweepingClaw(self);
			//	break;

			case EMatriarchAttacksByRange_LightningStorm:
				class'AICommand_Matriarch_LightningStorm'.static.LightningStorm(self);
				break;

			case EMatriarchAttacksByRange_WarningSiren:
				class'AICommand_Matriarch_WarningSiren'.static.WarningSiren(self);
				break;

			case EMatriarchAttacksByRange_TeslaBlast:
				class'AICommand_Matriarch_TeslaBlast'.static.TeslaBlast(self);
				break;

			case EMatriarchAttacksByRange_PlasmaCannon:
				class'AICommand_MatriarchPlasmaCannon'.static.PlasmaCannonAttack(self);
				break;

			case EMatriarchAttacksByRange_ScorpionWhip:
				class'AICommand_Matriarch_ScorpionWhip'.static.ScorpionWhip(self);
				break;
			};

			GlobalCooldownTimer = 1000000.f;
		}
		else
		{
			GlobalCooldownTimer = 0.5f;
		}
    }
	else
	{
		GlobalCooldownTimer = 0.5f;
	}
}

function array<EMatriarchAttacksByRange> GetPossibleMovesByRange(float DistToTargetSq)
{
	local array<EMatriarchAttacksByRange> PossibleMoves;

	//if (CanUseSweepingClaw(DistToTargetSq))
	//{
	//	PossibleMoves.AddItem(EMatriarchAttacksByRange_SweepingClaw);
	//}

	if (CanUseLightningStorm(DistToTargetSq))
	{
		PossibleMoves.AddItem(EMatriarchAttacksByRange_LightningStorm);
	}

	if (CanUseWarningSiren(DistToTargetSq))
	{
		PossibleMoves.AddItem(EMatriarchAttacksByRange_WarningSiren);
	}

	if (CanUseTeslaBlast(DistToTargetSq))
	{
		PossibleMoves.AddItem(EMatriarchAttacksByRange_TeslaBlast);
	}

	if (CanUsePlasmaCannon(DistToTargetSq))
	{
		PossibleMoves.AddItem(EMatriarchAttacksByRange_PlasmaCannon);
	}

	if (CanUseScorpionWhip(DistToTargetSq))
	{
		PossibleMoves.AddItem(EMatriarchAttacksByRange_ScorpionWhip);
	}

	return PossibleMoves;
}

//function bool CanUseSweepingClaw(float DistToTargetSq)
//{
//	if (!MyMatPawn.CanUseSweepingClaw())
//	{
//		return false;
//	}
//
//	if (DistToTargetSq > Square(class'KFSM_Matriarch_SweepingClaw'.default.MaxVictimDistance))
//	{
//		return false;
//	}
//
//	if (`TimeSince(LastSweepingClawTime) < SweepingClawCooldown)
//	{
//		return false;
//	}
//
//	return true;
//}

function bool CanUseTeslaBlast(float DistToTargetSq)
{
	if (!MyMatPawn.CanUseTeslaBlast())
	{
		return false;
	}

	if (DistToTargetSq > Square(class'KFSM_Matriarch_TeslaBlast'.default.MaxVictimDistance))
	{
		return false;
	}

	if (`TimeSince(LastTeslaBlastTime) < TeslaBlastCooldown)
	{
		return false;
	}

	return true;
}

function bool CanUsePlasmaCannon(float DistToTargetSq)
{
	if (!MyMatPawn.CanUsePlasmaCannon())
	{
		return false;
	}

	if (DistToTargetSq > Square(class'KFSM_Matriarch_PlasmaCannon'.default.MaxVictimDistance))
	{
		return false;
	}

	if (`TimeSince(LastPlasmaCannonTime) < PlasmaCannonCooldown)
	{
		return false;
	}

	return true;
}

function bool CanUseLightningStorm(float DistToTargetSq)
{
	if (!MyMatPawn.CanUseLightningStorm())
	{
		return false;
	}

	if (DistToTargetSq > Square(class'KFSM_Matriarch_LightningStorm'.default.MaxVictimDistance))
	{
		return false;
	}

	if (`TimeSince(LastLightningStormTime) < LightningStormCooldown)
	{
		return false;
	}

	return true;
}

function bool CanUseWarningSiren(float DistToTargetSq)
{
	if (!MyMatPawn.CanUseWarningSiren())
	{
		return false;
	}

	if (DistToTargetSq > Square(class'KFSM_Matriarch_WarningSiren'.default.MaxVictimDistance))
	{
		return false;
	}

	if (`TimeSince(LastWarningSirenTime) < WarningSirenCooldown)
	{
		return false;
	}

	return true;
}

function bool CanUseScorpionWhip(float DistToTargetSq)
{
	if (!MyMatPawn.CanUseScorpionWhip())
	{
		return false;
	}

	if (DistToTargetSq > Square(class'KFSM_Matriarch_ScorpionWhip'.default.MaxRange))
	{
		return false;
	}

	if (`TimeSince(LastScorpionWhipTime) < ScorpionWhipCooldown)
	{
		return false;
	}

	return true;
}

//function DoStrike()
//{
//	if (CanUseSweepingClaw(0))
//	{
//		class'AICommand_Matriarch_SweepingClaw'.static.SweepingClaw(self);
//	}
//	else
//	{
//		super.DoStrike();
//	}
//}

function NotifySpecialMoveStarted(KFSpecialMove SM)
{
	super.NotifySpecialMoveStarted(SM);

	if (MyMatPawn.Role == ROLE_Authority)
	{
		MyMatPawn.SetShieldUp(false);
		MyMatPawn.SetCloaked(false);
	}
}

/** Special move has ended, whether cleanly or aborted */
function NotifySpecialMoveEnded(KFSpecialMove SM)
{
	super.NotifySpecialMoveEnded(SM);

	switch (SM.Handle)
	{
	case 'KFSM_MeleeAttack':
		GlobalCooldownTimer = RandRange(GlobalCooldownTimeRange_Melee.X, GlobalCooldownTimeRange_Melee.Y);
		break;

	case 'KFSM_Matriarch_TeslaBlast':
		GlobalCooldownTimer = RandRange(GlobalCooldownTimeRange_TeslaBlast.X, GlobalCooldownTimeRange_TeslaBlast.Y);
		break;

	case 'KFSM_Matriarch_PlasmaCannon':
		GlobalCooldownTimer = RandRange(GlobalCooldownTimeRange_PlasmaCannon.X, GlobalCooldownTimeRange_PlasmaCannon.Y);
		break;

	case 'KFSM_Matriarch_LightningStorm':
		GlobalCooldownTimer = RandRange(GlobalCooldownTimeRange_LightningStorm.X, GlobalCooldownTimeRange_LightningStorm.Y);
		break;

	case 'KFSM_Matriarch_WarningSiren':
		GlobalCooldownTimer = RandRange(GlobalCooldownTimeRange_WarningSiren.X, GlobalCooldownTimeRange_WarningSiren.Y);
		break;

	case 'KFSM_Matriarch_ScorpionWhip':
		GlobalCooldownTimer = RandRange(GlobalCooldownTimeRange_ScorpionWhip.X, GlobalCooldownTimeRange_ScorpionWhip.Y);
		break;

	default:
		GlobalCooldownTimer = 0.5f;
		break;
	};

	EvaluateSprinting();

	if (SM.Handle == 'KFSM_Zed_Boss_Theatrics')
	{
		MyMatPawn.ActivateShield();
	}
	else
	{
		MyMatPawn.SetShieldUp(true);
		MyMatPawn.SetCloaked(true);
	}

	if (CurrentTargetPawn != none && Enemy != CurrentTargetPawn)
	{
		ChangeEnemy(CurrentTargetPawn, false);
	}
}

/** Evaluate if we should start/stop sprinting, and then set the sprinting flag */
function EvaluateSprinting()
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

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting */
function bool ShouldSprint()
{
	local float DistToEnemy;

	if (MyKFPawn != none && MyKFPawn.IsAliveAndWell() && Enemy != none && Enemy.IsAliveAndWell())
	{
		DistToEnemy = VSize(Enemy.Location - Pawn.Location);
		if (DistToEnemy > SprintWithinEnemyRange.X && DistToEnemy < SprintWithinEnemyRange.Y)
		{
			return true;
		}
		else if (!FastTrace(Enemy.Location, Pawn.Location,, true))
		{
			return true;
		}
	}

	return false;
}

function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
	super.NotifyTakeHit(InstigatedBy, Hitlocation, Damage, damageType, Momentum);

	if (Damage > 0)
	{
		if (PlayerDamages.Length <= InstigatedBy.PlayerNum)
		{
			PlayerDamages[InstigatedBy.PlayerNum] = Damage;
		}
		else
		{
			PlayerDamages[InstigatedBy.PlayerNum] += Damage;
		}

		if (bLogTargeting)
		{
			`log(self$"::NotifyTakeHit - player "$InstigatedBy.PlayerNum$" add "$Damage$" damage ("$PlayerDamages[InstigatedBy.PlayerNum]$")");
		}
	}
}

function NotifyKilled(Controller Killer, Controller Killed, pawn KilledPawn, class<DamageType> damageType)
{
	if (GetIsInZedVictoryState())
	{
		return;
	}

	if (self == Killer && Killed.GetTeamNum() != GetTeamNum())
	{
		`DialogManager.PlayMattyKilledDialog(MyKFPawn);
	}
	else if (Killed.GetTeamNum() == GetTeamNum())
	{
		`DialogManager.PlayMattyMinionKilledDialog(MyKFPawn);
	}

	super.NotifyKilled( Killer, Killed, KilledPawn, damageType );
}

function EnterZedVictoryState()
{
	super.EnterZedVictoryState();

	bCanEvaluateAttacks = false;
	KFWeapon(MyMatPawn.Weapon).GotoState( 'Inactive' );

	MyMatPawn.ClearTimer(nameof(MyMatPawn.Timer_TickDialog), MyMatPawn);
}

/*********************************************************************************************
* Pathfinding
**********************************************************************************************/

function bool AmIAllowedToSuicideWhenStuck()
{
	return false;
}

/*********************************************************************************************
* Bump
**********************************************************************************************/

function bool DoHeavyZedBump( Actor Other, vector HitNormal )
{
	local int BumpEffectDamage;
	local KFPawn_Monster BumpedMonster;

	/** If we bumped into a glass window, break it */
	if (Other.bCanBeDamaged && KFFracturedMeshGlass(Other) != none)
	{
		KFFracturedMeshGlass(Other).BreakOffAllFragments();
		return true;
	}

	BumpedMonster = KFPawn_Monster(Other);
	if (BumpedMonster == none || !BumpedMonster.IsAliveAndWell() || BumpedMonster.ZedBumpDamageScale <= 0)
	{
		return false;
	}

	if (MyKFPawn == none || !MyKFPawn.IsAliveAndWell())
	{
		return false;
	}

	BumpEffectDamage = ZedBumpEffectThreshold * BumpedMonster.ZedBumpDamageScale * (MyKFPawn.bIsSprinting ? 2 : 1);

	// If the Bumped Zed is near death, play either a knockdown or an immediate obliteration
	if (BumpedMonster.Health - BumpEffectDamage <= 0)
	{
		BumpedMonster.TakeDamage(BumpEffectDamage, self, BumpedMonster.Location, vect(0, 0, 0), MyKFPawn.GetBumpAttackDamageType());
		BumpedMonster.Knockdown(, vect(1, 1, 1), Pawn.Location, 1000, 100);
		return true;
	}
	else
	{
		// otherwise deal damage and stumble the zed
		BumpedMonster.TakeDamage(BumpEffectDamage, self, BumpedMonster.Location, vect(0,0,0), MyKFPawn.GetBumpAttackDamageType());
		BumpedMonster.DoSpecialMove(SM_Stumble,,, class'KFSM_Stumble'.static.PackBodyHitSMFlags(BumpedMonster, HitNormal));
		return true;
	}

	return false;
}

event bool NotifyBump(Actor Other, vector HitNormal)
{
	local KFPawn_Human BumpedHuman;

	BumpedHuman = KFPawn_Human(Other);
	if (BumpedHuman != none &&
		BumpedHuman != CurrentTargetPawn &&
		!MyMatPawn.IsDoingSpecialMove() &&
		!IsZero(MyMatPawn.Velocity) &&
		HitNormal dot vector(Rotation) < -0.7)
	{
		AbortCommand(CommandList);

		// Set our new enemy
		ChangeEnemy(BumpedHuman, false);

		//SetEnemyMoveGoal(self, true);
		EnableMeleeRangeEventProbing();

		// Restart default command
		BeginCombatCommand(GetDefaultCommand(), "Restarting default command");
		return true;
	}

	return super.NotifyBump(Other, HitNormal);
}

defaultproperties
{
	Steering=none
	DefaultCommandClass=class'KFGameContent.AICommand_Base_Matriarch'
	MeleeCommandClass=class'KFGameContent.AICommand_Base_Matriarch'

	//SweepingClawCooldown=10.f
	TeslaBlastCooldown=5.f
    PlasmaCannonCooldown=7.f
	LightningStormCooldown=8.f
	WarningSirenCooldown=10.f
	ScorpionWhipCooldown=12.f

	SprintWithinEnemyRange=(X=1500.f,Y=1000000000.f)

	ReevaluateEnemiesTimeRange=(X=8.f, Y=10.f)
	bLogTargeting=false

	bCanDoHeavyBump=true

	GlobalCooldownTimeRange_Melee=(X=0.0, Y=0.0)
	GlobalCooldownTimeRange_LightningStorm=(X=2.5, Y=2.5)
	GlobalCooldownTimeRange_WarningSiren=(X=2.5, Y=2.5)
	GlobalCooldownTimeRange_TeslaBlast=(X=2.5, Y=2.5)
	GlobalCooldownTimeRange_PlasmaCannon=(X=2.5, Y=2.5)
	GlobalCooldownTimeRange_ScorpionWhip=(X=0.0, Y=0.0)
}