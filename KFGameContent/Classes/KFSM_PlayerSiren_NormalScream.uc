//=============================================================================
// KFSM_PlayerSiren_NormalScream
//=============================================================================
// Player controlled siren scream
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerSiren_NormalScream extends KFSM_Siren_Scream;

/** Restrictions for doing Scream attack */
protected function bool InternalCanDoSpecialMove()
{
	if( KFPOwner.bIsSprinting )
	{
		KFPOwner.SetSprinting( false );
	}
	
	return super.InternalCanDoSpecialMove();
}

/** Notification called when Special Move starts */
function SpecialMoveStarted( bool bForced, Name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );

	// Disable sprint
	if( KFPOwner != none && KFPOwner.bIsSprinting )
	{
		KFPOwner.SetSprinting( false );
	}
}

defaultproperties
{
}