//=============================================================================
// KFAIController_ZedDAR
//=============================================================================
// Base AI controller for all ranged units.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFAIController_Ranged extends KFAIController_Monster
	abstract;

var const bool bDebugAimError;
var const bool bCanLeadTarget;

/** If bDebugAimError is true, this will render the projectile's trajectory with no aimerror in green and simulate 7 more shots, rendering
*  those trajectories in red (using aimerror) */
function DebugAimError(name SocketName, optional float AimError = 0)
{
	local int			i;
	local KFDebugLines	KFDL;
	local vector		SocketLocation, DirToEnemy;
	local rotator		SocketRotation;

	KFDL = class'KFDebugLines'.static.GetDebugLines();

	if (KFDL == none)
	{
		msg("You need to turn KFDebugLines on (bEnableAdvDebugLines in KFGame.ini) to do this.");
		return;
	}

	MyKFPawn.Mesh.GetSocketWorldLocationAndRotation(SocketName, SocketLocation, SocketRotation);

	KFDL.AddDebugLine(SocketLocation, SocketLocation + normal(Enemy.Location - SocketLocation) * 3024.f, 0, 255, 0, TRUE);
	for (i = 0; i < 7; i++)
	{
		DirToEnemy = normal(Enemy.Location - SocketLocation) + VRand() * AimError;
		KFDL.AddDebugLine(SocketLocation, SocketLocation + DirToEnemy * 3024.f, 255, 0, 0, TRUE);
	}
	msg("GAME PAUSED, UNPAUSE TO CONTINUE");
	DebugFreezeGame();
}
