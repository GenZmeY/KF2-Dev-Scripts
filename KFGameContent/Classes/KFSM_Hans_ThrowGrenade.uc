//=============================================================================
// KFSM_Hans_ThrowGrenade
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_Hans_ThrowGrenade extends KFSM_PlaySingleAnim;

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	local KFPawn_ZedHansBase HansPawn;

	HansPawn = KFPawn_ZedHansBase(PawnOwner);
	if( HansPawn != none )
	{
		HansPawn.PlayGrenadeDialog( false );

		if( HansPawn.CanMoveWhileThrowingGrenades() )
		{
			AnimStance = EAS_UpperBody;
			bDisableMovement = false;
		}
		else
		{
			AnimStance = EAS_FullBody;
			bDisableMovement = true;
			HansPawn.ZeroMovementVariables();
		}
	}

	super.SpecialMoveStarted( bForced, PrevMove );

	if( AIOwner != none )
	{
		`AILog_Ext( self@"started for"@AIOwner, 'Siren', AIOwner );
	}
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	super.SpecialMoveEnded( PrevMove, NextMove );
	if( AIOwner != none )
	{
		`AILog_Ext( self@"ended for"@AIOwner, 'Siren', AIOwner );
	}
}

protected function bool InternalCanDoSpecialMove()
{
//    local KFPawn_ZedHansBase HansPawn;

	// Need to remove enemy check if Hans ever needs to throw grenades at doors, etc.
	if( PawnOwner == none || PawnOwner.Health <= 0 || AIOwner == none || AIOwner.Enemy == none || AIOwner.Enemy.Health <= 0 )
	{
		return false;
	}

//    HansPawn = KFPawn_ZedHansBase(PawnOwner);

	// Make sure we can throw grenade in the current stance, etc. TODO: Commented out because it caused Hans to get stuck
//    if( HansPawn != none && !HansPawn.IsDoingSpecialMove(SM_ChangeStance)
//        && !HansPawn.bGunsEquipped )
//    {
        return super.InternalCanDoSpecialMove();
//    }
//    else
//    {
//        return false;
//    }
}

DefaultProperties
{
	// SpecialMove
	Handle=KFSM_Hans_ThrowGrenade
	AnimName=Atk_Nade_V1
	//AnimName=Atk_NadeBarrage_V1
	bDisableSteering=false
	bDisableMovement=true
	// Don't let him shoot a gun while tossing a nade!
	bDisablesWeaponFiring=true
}
