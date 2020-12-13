//=============================================================================
// KFSM_Hans_GrenadeBarrage
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_Hans_GrenadeBarrage extends KFSM_Hans_ThrowGrenade;

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	local KFPawn_ZedHansBase HansPawn;

	HansPawn = KFPawn_ZedHansBase(PawnOwner);
	if( HansPawn != none )
	{
		HansPawn.PlayGrenadeDialog( true );
	}

	super.SpecialMoveStarted( bForced, PrevMove );
}

DefaultProperties
{
	AnimName=Atk_NadeBarrage_V1
	Handle=KFSM_Hans_GrenadeBarrage
}
