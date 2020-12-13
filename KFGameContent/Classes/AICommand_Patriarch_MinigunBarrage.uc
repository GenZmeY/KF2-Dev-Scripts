//=============================================================================
// AICommand_Patriarch_MinigunBarrage.uc
//=============================================================================
// Performs the Patriarch minigun attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class AICommand_Patriarch_MinigunBarrage extends AICommand_SpecialMove
	within KFAIController_ZedPatriarch;

var bool bIsFanFire;
var bool bBeganFire;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool MinigunBarrage( KFAIController_ZedPatriarch AI )
{
	local AICommand_Patriarch_MinigunBarrage Cmd;

	if( AI != None )
	{
		Cmd = new(AI)default.class;
		if( Cmd != None )
		{
			AI.PushCommand( Cmd );
			return true;
		}
	}

	return false;
}

function Pushed()
{
	Super.Pushed();
	StopAllLatentMovement();

	if( Enemy != none )
	{
		Focus = Enemy;
	}

	AIActionStatus = "Starting Minigun Barrage AICommand";
	if( Focus != None )
	{
		SetDesiredRotation(rotator(Focus.Location - Pawn.Location));
	}

	DisableMeleeRangeEventProbing();
	bCanEvaluateAttacks = false;
	bBeganFire = false;
}

function LockdownAI();

function Popped()
{
	AIActionStatus = "Finished Minigun Barrage AICommand";
	Super.Popped();
}

function ESpecialMove GetSpecialMove()
{
	return SM_None;
}

state Command_SpecialMove
{
	/** Checks circumstances in which to consider special move completed */
	function bool IsSpecialMoveComplete()
	{
		if( !bPreparingMove || MyKFPawn == None || MyKFPawn.SpecialMove == SM_None || MyKFPawn.SpecialMove != GetSpecialMove() )
		{
			return true;
		}
		return false;
	}

	function byte GetSpecialMoveFlags( ESpecialMove InSpecialMove )
	{
		local int i, NumNearbyEnemies;
		local KFPawn KFP;
		local vector Projection;

		bIsFanFire = false;

		// See if we have enough valid enemies in front of us to do a fan fire attack
		if( RecentlySeenEnemyList.Length > 2 )
		{
			for( i = 0; i < RecentlySeenEnemyList.Length; i++ )
			{
				KFP = RecentlySeenEnemyList[i].TrackedEnemy;
				if( KFP == none || !KFP.IsAliveAndWell() )
				{
					continue;
				}

				Projection = KFP.Location - MyPatPawn.Location;

				// Restrict by Z, distance, and 45 degree angle to targets
				if( Abs(MyPatPawn.Location.Z - KFP.Location.Z) > MyPatPawn.GetCollisionHeight()
					|| VSizeSQ(Projection) > MaxFanFireRangeSQ
					|| vector(MyPatPawn.Rotation) dot Normal(Projection) < 0.5f )
				{
					continue;
				}

				NumNearbyEnemies++;
				if( NumNearbyEnemies >= 3 )
				{
					bIsFanFire = true;
					break;
				}
			}
		}

		if( MyPatPawn != none && MyPatPawn.CanDoSpecialMove(InSpecialMove) )
		{
			// Disallow movement only in fan fire
			if( bIsFanFire || !MyPatPawn.CanMoveWhenMinigunning() )
			{
				super.LockdownAI();
			}

			return class'KFSM_Patriarch_MinigunBarrage'.static.PackSMFlags( bIsFanFire );
		}

		return 255;
	}

	function ESpecialMove GetSpecialMove()
	{
		return SM_HoseWeaponAttack;
	}
}

DefaultProperties
{
	bShouldCheckSpecialMove=true
	bIgnoreNotifies=true
	bAllowedToAttack=false
	TimeOutDelaySeconds=25.f
	bIgnoreStepAside=true
}