//=============================================================================
// AICommand_Base_Fleshpound
//=============================================================================
// Base AI Command for the Fleshpound.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class AICommand_Base_Fleshpound extends AICommand_Base_Zed
	within KFAIController_ZedFleshpound
	native(AI);

/*********************************************************************************************
* Initialization
**********************************************************************************************/

function Pushed()
{
	EnableSeePlayer();
	Super.Pushed();
}

function Popped()
{
	Super.Popped();
}

/** Notification from controller that enemy has become visible */
function bool NotifyPlayerBecameVisible( Pawn VisiblePlayer )
{
	local float DistSqToEnemy, DistSqToVisiblePlayer;
	local int NumZedsTargetingEnemy, NumZedsTargetingVP;

	/** Only allowed to consider changing enemy every MinTimeBetweenEnemyChanges seconds */
	if( `TimeSince(LastSetEnemyTime) > MinTimeBetweenEnemyChanges )
	{
		/** If VisiblePlayer is alive and isn't my enemy (who's still alive) and isn't currently visible */
		if( VisiblePlayer != Enemy && Enemy != none && Enemy.IsAliveAndWell() && VisiblePlayer.IsAliveAndWell() && !bEnemyIsVisible )
		{
			DistSqToEnemy		  = VSizeSq( Enemy.Location - Pawn.Location );
			DistSqToVisiblePlayer = VSizeSq( VisiblePlayer.Location - Pawn.Location );

			/** If VisiblePlayer is closer to me than my current enemy */
			if( DistSqToVisiblePlayer < DistSqToEnemy )
			{
				NumZedsTargetingEnemy = NumberOfZedsTargetingPawn( Enemy,, 700.f );
				NumZedsTargetingVP	  = NumberOfZedsTargetingPawn( VisiblePlayer,, 700.f );
				/** Check if more Zeds are targeting my enemy than VisiblePlayer (and those Zeds are within 700 units of their target) */ 
				if( NumZedsTargetingEnemy > NumZedsTargetingVP )
				{
					/** My enemy seems preoccupied with other Zeds, so I'm changing my enemy to be VisiblePlayer instead */
					SetEnemy( VisiblePlayer );
					return true;
				}
			}
		}
	}

	return false;
}

/*********************************************************************************************
* Combat
**********************************************************************************************/

/** Notification that I've changed my enemy (which has already been to to Enemy) */
function NotifyEnemyChanged( optional Pawn OldEnemy )
{
	if( CachedChildCommand != None )
	{
		CachedChildCommand.NotifyEnemyChanged( OldEnemy );
	}

	if( LineOfSightTo(Enemy) )
	{
		bSawEnemy = true;
	}
	else
	{
		bSawEnemy = false;
	}
}

function bool NotifyCombatBehaviorChange( name BehaviorName, bool bEnabled )
{
 	if( BehaviorName == 'Enraged' && bEnabled )
 	{
		bReadyToBecomeEnraged = true;
		MyKFPawn.SetEnraged( true );
	 	if( (LastTauntTime == 0 || `TimeSince(LastTauntTime > 260.f)) )
	 	{
			`AILog( "Doing rage taunt at "$Enemy, 'Charging' );
			AbortMovementCommands();
			AbortMovementPlugIns();
			DoRageTauntAt( KFPawn(Enemy) );
			LastTauntTime = WorldInfo.TimeSeconds;
		}
		return true;
 	}
	else if( BehaviorName == 'Enraged' && !bEnabled )
	{
		bReadyToBecomeEnraged = false;
		MyKFPawn.SetEnraged( false );
	}
}

DefaultProperties
{
	bAllowedToAttack=true
}