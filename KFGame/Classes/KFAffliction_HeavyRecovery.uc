//=============================================================================
// KFAffliction_MediumRecovery
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_HeavyRecovery extends KFAfflictionBase;

/** */
function Activate()
{
	// Attempt to interrupt the special move
	if( PawnOwner.SpecialMove != SM_None )
	{
		PawnOwner.SpecialMoves[PawnOwner.SpecialMove].NotifyHitReactionInterrupt();
	}

	// Finally, 'Pause' the AI if we're going to play a medium or heavy hit reaction anim in TryPlayHitReactionAnim
	if ( PawnOwner.SpecialMove == SM_None && PawnOwner.MyKFAIC != None )
	{
		PawnOwner.MyKFAIC.DoPauseAI( PawnOwner.DamageRecoveryTimeHeavy, true );
	}

	Super.Activate();
}

defaultproperties
{
}
