//=============================================================================
// KFAIController_ZedClot
//=============================================================================
// Base controller for the Alpha, Slasher, and Cyst Clots
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedClot extends KFAIController_Monster
	abstract
	native(AI);

cpptext
{
	/** Overridden to allow grab attack check */
	virtual UBOOL TickMeleeCombatDecision( FLOAT DeltaTime );
}

/*********************************************************************************************
* Movement Methods
********************************************************************************************* */

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting */
function bool ShouldSprint()
{
	if( MyKFPawn == none || (Enemy == none && DoorEnemy == none) || !MyKFPawn.IsAliveAndWell() || !Enemy.IsAliveAndWell() )
	{
		return false;
	}

	// Sprint if we've reached the frustration threshold
	if ( IsFrustrated() )
	{
		return true;
	}

	// Sprint if we've been damaged and sprinting is allowed
	if( bCanSprint || (bCanSprintWhenDamaged && MyKFPawn.Health < MyKFPawn.HealthMax) )
	{
		return true;
	}

	return false;
}

/*********************************************************************************************
* Combat
**********************************************************************************************/

function bool CanDoStrike()
{
	// Prioritize a grab over doing a strike
	if( CanGrabAttack() )
	{
		return false;
	}

	return super.CanDoStrike();
}

/** Launch a grab attack */
event DoGrabAttack( optional Pawn NewEnemy, optional float InPostSpecialMoveSleepTime=0.f )
{
	if( CommandList == None || AICommand(CommandList).bAllowedToAttack )
	{
		if( NewEnemy != None && NewEnemy != Enemy )
		{
			SetEnemy( NewEnemy );
		}
		ClearMovementInfo( true, "Aborted For GrabAttack" );
		`AILog( GetFuncName()$"() Init AICommand_Attack_Grab", 'InitAICommand' );
		class'AICommand_Attack_Grab'.static.Grab( self, InPostSpecialMoveSleepTime );
	}
	else if( CommandList != none && !AICommand(CommandList).bAllowedToAttack )
	{
		`AILog( GetFuncName()$"() not doing grab attack because current command ("$CommandList$") will not allow it", 'GrabAttack' );
	}
}

DefaultProperties
{
	// ---------------------------------------------
	// Combat
	MeleeCommandClass=class'AICommand_Base_Zed'
	DefaultCommandClass=class'AICommand_Base_Zed'
	bIsProbingMeleeRangeEvents=true
	// ---------------------------------------------
	// AI / Navigation
	SprintWithinEnemyRange=(X=600.f,Y=1200.f)
	bEvadeOnRunOverWarning=true
	// To be enabled!
	//bPathAroundDestructiblesICantBreak=true
}

