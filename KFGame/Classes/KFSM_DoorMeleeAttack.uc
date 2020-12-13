class KFSM_DoorMeleeAttack extends KFSM_MeleeAttack
	native(SpecialMoves);

// Overridden so door attacks will be interruptible
function SpecialMoveStarted( bool bForced, name PrevMove )
{
	local KFPawn_Monster KFPM;

	bUseRootMotion = false;

	UnpackSpecialMoveFlags();

	KFPM = KFPawn_Monster(KFPOwner);
	if ( KFPM != none && KFPM.bCanCloak && KFPM.bIsCloaking )
	{
		KFPM.SetCloaked(false);
	}

	Super(KFSM_PlaySingleAnim).SpecialMoveStarted( bForced, PrevMove );
}

static function byte PackSMFlags( KFPawn_Monster P, optional name AttackName, optional bool bForce )
{
	if( P != none && P.PawnAnimInfo != none && P.PawnAnimInfo.DoorAttacks.Length > 0 )
	{
		return rand(P.PawnAnimInfo.DoorAttacks.Length);
	}

	return 255;
}

/** Unpack Special move flags */
function UnpackSpecialMoveFlags()
{
	// setup next attack animation based on SpecialMoveFlags
	AnimName = KFPOwner.PawnAnimInfo.DoorAttacks[KFPOwner.SpecialMoveFlags];
}

/** Called from CanDoSpecialMove, checks attack conditions and owning pawn's capabilities */
protected function bool InternalCanDoSpecialMove()
{
	// Ensure that the NPC & target are valid, NPC in valid physics state and not too busy, etc.
	if( AIOwner != none && AIOwner.DoorEnemy != none )
	{
		if( KFPOwner.IsAliveAndWell() && KFPOwner.Physics != PHYS_Falling )
		{
			// Just return true for now
			return super.InternalCanDoSpecialMove();
		}
	}

	return false;
}

DefaultProperties
{
	Handle=KFSM_DoorMeleeAttack
	bCanBeInterrupted=true
}
