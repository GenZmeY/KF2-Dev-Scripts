//=============================================================================
// KFSM_PlayerSpecial_Slasher
//=============================================================================
// Player controlled stalker attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerStalker_Roll extends KFSM_Evade;

static function byte PackFlagsBase(KFPawn P)
{
	return class'KFSM_PlayerMeleeBase'.static.GetFourWayMoveDirection(P);
}

/** Notification called when Special Move starts */
function SpecialMoveStarted( bool bForced, Name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );

	// Disable cloak
	if( KFPOwner != none && KFPawn_Monster(KFPOwner).bIsCloaking )
	{
		KFPawn_Monster(KFPOwner).SetCloaked( false );
	}
}

/** Special move ended */
function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	// Re-enable cloak
	if( KFPOwner != none )
	{
		KFPawn_Monster(KFPOwner).SetCloaked( true );
	}

	super.SpecialMoveEnded( PrevMove, NextMove );
}

defaultproperties
{
	//Cooldown=0.f

	// @note: Using EPawnOctant not EEvadeDir.  EEvadeDir is defined twice, weirdly offset, and should probably be deleted!
	EvadeAnims(DIR_Forward)=(Anims=(Player_Cartwheel_F))
	EvadeAnims(DIR_Backward)=(Anims=(Player_Cartwheel_B))
	EvadeAnims(DIR_Left)=(Anims=(Player_Cartwheel_L))
	EvadeAnims(DIR_Right)=(Anims=(Player_Cartwheel_R))
}