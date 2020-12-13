//=============================================================================
// KFSM_Matriarch_MeleeAttack
//=============================================================================
// Handles close-range melee attacks, and base class for all NPC melee attacks.
// An attack is considered to be a melee attack if there are no projectiles
// involved (i.e, just play an animation-based attack)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Matriarch_MeleeAttack extends KFSM_MeleeAttack;

/** Cached reference to Matriarch pawn */
var KFPawn_ZedMatriarch MyMatPawn;

/** Cached reference to Patriarch AI controller */
var KFAIController_ZedMatriarch MyMatController;

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	Super.SpecialMoveStarted(bForced, PrevMove);

	MyMatPawn = KFPawn_ZedMatriarch(KFPOwner);
	MyMatController	= KFAIController_ZedMatriarch(MyMatPawn.Controller);
	if (MyMatPawn.Role == ROLE_Authority)
	{
		MyMatPawn.SetShieldUp(false);
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	if (MyMatPawn.Role == ROLE_Authority)
	{
		MyMatPawn.SetShieldUp(true);
	}
}