//=============================================================================
// KFAIController_HansFriendlyTest
//=============================================================================
// Hans's AIController that will target zeds not players - for testing
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_HansFriendlyTest extends KFAIController_Hans;

/** Hans doesn't get SeePlayer calls on monsters, so check occasionally if he can see his enemy */
var float EnemyVisionCheckInterval;

/** Hans doesn't get SeePlayer calls on monsters, so check occasionally if he can see his enemy */
var float LastEnemyVisionCheckTime;

/** Don't create a benchmarking PRI for the test Hans */
function InitPlayerReplicationInfo(){}

/** Make sure test Hans is on the human team */
simulated event byte ScriptGetTeamNum()
{
	return 0;
}

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting */
function bool ShouldSprint()
{
    local float RangeToEnemy;

	if( Enemy != none && MyHansPawn != none && !MyHansPawn.bIsHeadless && !MyHansPawn.bEmpPanicked )
	{
		// Always sprint if we're trying to track down players to heal from
        if( MyHansPawn.bInHuntAndHealMode )
		{
			//`log(self@GetFuncName()$" bInHuntAndHealMode should sprint!");
            return true;
		}

        // Hack, since Hans doesn't get SeePlayer calls on zeds, check here to see if we can see our enemy
        if( LastEnemySightedTime == 0 && (LastEnemyVisionCheckTime == 0 ||
            (`TimeSince(LastEnemyVisionCheckTime) > EnemyVisionCheckInterval)) )
        {
            LastEnemyVisionCheckTime = WorldInfo.TimeSeconds;
            if( CanSee(Enemy) )
            {
                LastEnemySightedTime = WorldInfo.TimeSeconds;
            }
        }

		// Sprint if we can't see our enemy
		if( LastEnemySightedTime == 0 || `TimeSince(LastEnemySightedTime) > LostSightSprintDelay )
		{
            // Hack, since Hans doesn't get SeePlayer calls on zeds, check here to see if we can see our enemy
            if( LastEnemyVisionCheckTime == 0 || (`TimeSince(LastEnemyVisionCheckTime) > EnemyVisionCheckInterval) )
            {
                LastEnemyVisionCheckTime = WorldInfo.TimeSeconds;
                if( CanSee(Enemy) )
                {
                    LastEnemySightedTime = WorldInfo.TimeSeconds;
                    return false;
                }
            }

			//`log(self@GetFuncName()$" don't see any enemy should sprint = true! LastEnemySightedTime: "$LastEnemySightedTime$" TimeSince(LastEnemySightedTime): "$`TimeSince(LastEnemySightedTime));
            return true;
		}

        // No sprinting with the guns out!
        if( MyHansPawn.bGunsEquipped )
        {
            RangeToEnemy = VSize( Enemy.Location - Pawn.Location );

            // Sprint if we're too close to shoot
            if( RangeToEnemy > StartShootingRange || rangeToEnemy < MinShootingRange )
            {
                //`log(self@GetFuncName()$" guns out but enemy not in gun range. Should sprint = true!");
                return true;
            }
            else
            {
                //`log(self@GetFuncName()$" guns out enemy not in gun range. Should sprint = false!");
                return false;
            }
        }

        //`log(self@GetFuncName()$" Generic should sprint depending on phase: "$MyHansPawn.DesireSprintingInThisPhase());
        return MyHansPawn.DesireSprintingInThisPhase();
	}
	//`log(self@GetFuncName()$" Generic should sprint = false!");
	return false;
}


// Below is code to turn on if we want to use Hans with "bIsPlayer=true".
// It simulates "SeePlayer" calls for "SeeMonster" calls so Hans will properly
// get vision calls for seeing monster enemies

/*********************************************************************************************
*  Action_Idle State - default state this controller uses while pawn is active
********************************************************************************************* */

//state Action_Idle
//{
//	event BeginState(Name PreviousStateName)
//	{
//		Super.BeginState( PreviousStateName );
//
//		Enable( 'SeeMonster' );
//	}
//}
//
///** Called when this controller has possessed inPawn */
//event Possess( Pawn inPawn, bool bVehicleTransition )
//{
//	// Currently only enabling SeePlayer during latent moves in AICommand_MoveToGoal
//	Disable( 'SeeMonster' );
//
//	super.Possess( inPawn, bVehicleTransition );
//}
//
///** Timer which re-enables SeePlayer event polling */
//event EnableSeePlayer()
//{
//	Super.EnableSeePlayer();
//	if( !bHasDebugCommand )
//	{
//		Enable( 'SeeMonster' );
//	}
//}
//
///** Disable this NPC's SeePlayer polling for DisabledTime seconds */
//event DisableSeePlayer( optional float DisabledTime )
//{
//    Super.DisableSeePlayer( DisabledTime );
//	Disable( 'SeeMonster' );
//
//}
//
//
///* epic ===============================================
//* ::SeeMonster
//*
//* Called whenever Seen is within of our line of sight
//* if Seen.bIsPlayer==false.
//*
//* =====================================================
//*/
//event SeeMonster( Pawn Seen )
//{
//    SeePlayer( Seen );
//}

/* epic ===============================================
* ::NotifyTakeHit
*
* Notification from pawn that it has received damage
* via TakeDamage().
*
* =====================================================
*/
function NotifyTakeHit(Controller InstigatedBy, vector HitLocation, int Damage, class<DamageType> damageType, vector Momentum)
{
    // Don't heal with a friendly test Hans
//    if( MyHansPawn != none && !MyHansPawn.bHealedThisPhase && MyHansPawn.CurrentBattlePhase < 4 )
//    {
//	   	if( GetHealthPercentage() < 0.35 )
//	   	{
//	       	MyHansPawn.SetHuntAndHealMode( true );
//			NextBattlePhase();
//	   	}
//	}

    Super(KFAIController_ZedBoss).NotifyTakeHit(InstigatedBy, HitLocation, Damage, DamageType, Momentum);
}

defaultproperties
{
    bAllowScriptTeamCheck=true
    MinShootingRange=100
    MaxGunAttackLength=30
    ShootingCooldown=3.0
    EnemyVisionCheckInterval=0.1
    //bIsPlayer=true
}

