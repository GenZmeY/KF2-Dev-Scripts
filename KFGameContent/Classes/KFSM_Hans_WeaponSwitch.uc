//=============================================================================
// KFSM_HansWeaponSwitch
//=============================================================================
// Play a weapon switch animation and update AnimSets
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Hans_WeaponSwitch extends KFSM_PlaySingleAnim;

var bool bIsEquipping;

const EquipGunsAnim		= 'Equip_Gun';
const PutAwayGunsAnim	= 'PutAway_Gun';

function PlayAnimation()
{
	local KFPawn_ZedHans HansPawn;

	bIsEquipping = KFPOwner.SpecialMoveFlags > 0;
	AnimName = (bIsEquipping) ? EquipGunsAnim : PutAwayGunsAnim;

	// Need to blend out the hip holster skel controls
	HansPawn = KFPawn_ZedHans(PawnOwner);
	if ( HansPawn != None )
	{
		HansPawn.RightHolsterSkelCtrl.SetSkelControlActive(false);
		HansPawn.LeftHolsterSkelCtrl.SetSkelControlActive(false);

		if( bIsEquipping )
		{
			HansPawn.PlayDrawGunsDialog();
		}
	}

	Super.PlayAnimation();
}

function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	local KFPawn_ZedHans HansPawn;

	// Notify Hans to update AnimSets, etc...
	HansPawn = KFPawn_ZedHans(PawnOwner);
	if ( HansPawn != None )
	{
		HansPawn.SetWeaponStance(bIsEquipping);

		// If we were waiting for Hans to get his guns put away before
		// doing a smoke barrage and summoning minions, do it now!
    	if( !bIsEquipping && HansPawn != none && HansPawn.bPendingSmokeGrenadeBarrage
            && KFAIController_Hans(PawnOwner.Controller) != none )
    	{
            KFAIController_Hans(PawnOwner.Controller).DoSmokeGrenadeThrow( true, true );
    	}
	}

	Super.SpecialMoveEnded(PrevMove, NextMove);
}

DefaultProperties
{
    bDisableMovement=true
    bDisablesWeaponFiring=true
}
