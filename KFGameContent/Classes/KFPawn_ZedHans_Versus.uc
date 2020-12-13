class KFPawn_ZedHans_Versus extends KFPawn_ZedHans;

function PossessedBy( Controller C, bool bVehicleTransition )
{
	super.PossessedBy(C, bVehicleTransition);

	class'KFPawn_MonsterBoss'.static.PlayBossEntranceTheatrics(self);
}

/**
 * Pawn starts firing!
 * Called from PlayerController::StartFiring
 * Network: Local Player
 *
 * @param	FireModeNum		fire mode number
 */
simulated function StartFire(byte FireModeNum)
{

	if(IsDoingSpecialMove())
	{
		return;
	}

	switch (FireModeNum)
	{
		case 0: //left click
			//main fire
			/*if(!IsDoingSpecialMove(SM_HoseWeaponAttack))
			{
				ServerDoSpecialMove(SM_HoseWeaponAttack);
			}*/
			if(bGunsEquipped)
			{
				super.StartFire(FireModeNum);
			}
			break;

		case 1: //middle click
			if(!IsDoingSpecialMove(SM_Hans_ThrowGrenade))
			{
				ServerDoSpecialMove(SM_Hans_ThrowGrenade);
			}
			break;
		/*
		case 2:
			//r
			if(!IsDoingSpecialMove(SM_Hans_GrenadeBarrage))
			{
				ServerDoSpecialMove(SM_Hans_GrenadeBarrage);
			}

			break;*/
		case 3:
			//melee
			if(!IsDoingSpecialMove(SM_MeleeAttack))
			{
				ServerDoSpecialMove(SM_MeleeAttack,,, 2 );
			}
			break;
		case 4:

			break;
	}
}

simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon)
{
	`log("WEAPON SWITCH");
	// Save a reference to carried Weapon, so we don't cast all over the place.
	ToggleAim();
}

reliable server function ToggleAim()
{
	SetWeaponStance(!bGunsEquipped, true);
}

// @todo: fixme
/*reliable server function ServerDoSpecialMove(ESpecialMove NewMove, optional bool bForceMove, optional Pawn InInteractionPawn, optional INT InSpecialMoveFlags, optional bool bSkipReplication)
{
	if(NewMove == SM_Hans_ThrowGrenade)
	{
		ThrowGrenade();
	}
	else
	{
		DoSpecialMove(NewMove, bForceMove, InInteractionPawn, InSpecialMoveFlags, bSkipReplication);
	}
}*/

/** Spawns a grenade projectile at the cached throw speed and location */
simulated function bool ThrowGrenade()
{
	ActiveGrenadeClass = SmokeGrenadeClass;
	return super.ThrowGrenade();
}

//get rif of ragemode sprint
function SetSprinting(bool bNewSprintStatus)
{
	if ( bNewSprintStatus )
	{
		// Wait for uncrouch; see CheckJumpOrDuck
		if ( bIsCrouched )
		{
			bNewSprintStatus = false;
		}
		else if ( MyKFWeapon != None && !MyKFWeapon.AllowSprinting() )
		{
			bNewSprintStatus = false;
		}
	}

	bIsSprinting = bNewSprintStatus;

	if ( MyKFWeapon != None )
	{
		MyKFWeapon.SetWeaponSprint(bNewSprintStatus);
	}
}


simulated function ToggleEquipment()
{
	ServerToggleShield();
}

reliable server function ServerToggleShield()
{
	SetHuntAndHealMode(!bInHuntAndHealMode);
}

DefaultProperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30	
}