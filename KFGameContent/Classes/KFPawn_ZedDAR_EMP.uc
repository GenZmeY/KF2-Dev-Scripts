//=============================================================================
// KFPawn_ZedDAR_EMP
//=============================================================================
// Pawn for Evulz EMP DAR
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedDAR_EMP extends KFPawn_ZedDAR;

simulated function ANIMNOTIFY_EMPStart()
{
	ToggleEMPBurst(true);
}

simulated function ANIMNOTIFY_EMPEnd()
{
	ToggleEMPBurst(false);

	if (MyDARController != none)
	{
		MyDARController.LastRangeAttackTime = WorldInfo.TimeSeconds;
	}
}

simulated function ToggleEMPBurst(bool bEnable)
{
	local KFSM_DAR_EMPAttack EMPSM;

	if (SpecialMove != SM_StandAndShootAttack)
	{
		return;
	}

	EMPSM = KFSM_DAR_EMPAttack(SpecialMoves[SpecialMove]);
	if (EMPSM != none)
	{
		EMPSM.ToggleEMP(bEnable);
	}
}

simulated event vector GetWeaponStartTraceLocation(optional Weapon CurrentWeapon)
{
	local KFAIController_ZedDAR_EMP DARAI;
	local vector SocketLoc;
	local rotator SocketRot;

	if (MyKFAIC != none)
	{
		DARAI = KFAIController_ZedDAR_EMP(MyKFAIC);
		if (DARAI != none)
		{
			Mesh.GetSocketWorldLocationAndRotation(DARAI.EMPSocketName, SocketLoc, SocketRot);
			return SocketLoc;
		}
	}

	return super.GetWeaponStartTraceLocation(CurrentWeapon);
}

function OnZedDied(Controller Killer)
{
	local KFSM_DAR_EMPAttack EMPSM;

	super.OnZedDied(Killer);

	EMPSM = KFSM_DAR_EMPAttack(SpecialMoves[SpecialMove]);
	if (EMPSM != none)
	{
		EMPSM.ToggleEMP(false);
		EMPSM.ReleaseVictims();
	}
}

defaultproperties
{
	LocalizationKey=KFPawn_ZedDAR_EMP

	ControllerClass=class'KFAIController_ZedDAR_EMP'
	MonsterArchPath="ZED_ARCH.ZED_DAR_EMP_Archetype"
	DifficultySettings=class'KFDifficulty_DAR_EMP'

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Taunt)=class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
		SpecialMoveClasses(SM_StandAndShootAttack)=class'KFSM_DAR_EMPAttack'
	End Object

	Begin Object Name=Afflictions_0
		AfflictionClasses(AF_EMP)=class'KFGame.KFAffliction_EvilDAR_EMP'
	End Object

}
