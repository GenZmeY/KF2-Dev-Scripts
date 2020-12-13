//=============================================================================
// KFSM_PlayerZedBlockBase
//=============================================================================
// Player-controlled zed block special move base class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerZedBlockBase extends KFSM_PlaySingleAnim
	abstract;

/** Minimum duration the move has to run */
var float MinimumBlockTime;

function SpecialMoveStarted( bool bForced, Name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );

	// Set our block flag to true
	KFPawn_Monster(KFPOwner).bIsBlocking = true;

	// Disallow sprinting
	if( KFPOwner.bIsSprinting )
	{
		KFPOwner.SetSprinting( false );
	}

	// Set a timer to force block to stay active for a minimum amount of time
	if( KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.SetTimer( MinimumBlockTime, false, nameOf(Timer_CheckIfBlockReleased), self );
	}
}

function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	super.SpecialMoveEnded( PrevMove, NextMove );

	// Stop looping anim, clear blocking flag
	if( KFPOwner != none )
	{
		KFPOwner.ClearTimer( nameOf(Timer_CheckIfBlockReleased), self );
		KFPOwner.StopBodyAnim( AnimStance, BlendOutTime );
		KFPawn_Monster(KFPOwner).bIsBlocking = false;
	}
}

/** End the move if the player released the block button */
function Timer_CheckIfBlockReleased()
{
	if( bPendingStopFire )
	{
		KFPOwner.EndSpecialMove();
		if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
		{
			KFPOwner.ServerDoSpecialMove( SM_None, true );
		}
	}
}

/* Called on some player-controlled moves when a firemode input has been pressed */
function SpecialMoveButtonRetriggered()
{
    bPendingStopFire = false;
}

/** Called on some player-controlled moves when a firemode input has been released */
function SpecialMoveButtonReleased()
{
    bPendingStopFire = true;

    // Wait out the minimum block duration
    if( KFPOwner.IsTimerActive( nameOf(Timer_CheckIfBlockReleased), self) )
    {
        return;
    }

	KFPOwner.EndSpecialMove();
	if( KFPOwner.Role < ROLE_Authority && KFPOwner.IsLocallyControlled() )
	{
		KFPOwner.ServerDoSpecialMove( SM_None, true );
	}
}

defaultproperties
{
	// ---------------------------------------------
	// SpecialMove
	Handle=KFSM_PlayerBlockBase
	bCanBeInterrupted=false
	MinimumBlockTime=0.4f

	// ---------------------------------------------
	// Animations
	AnimStance=EAS_UpperBody
	bUseRootMotion=false
	bLoopAnim=true
	BlendInTime=0.2f
}