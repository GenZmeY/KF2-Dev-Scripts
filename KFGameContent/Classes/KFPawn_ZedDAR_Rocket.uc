//=============================================================================
// KFPawn_ZedDAR_Rocket
//=============================================================================
// Pawn for Evulz Rocket DAR
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedDAR_Rocket extends KFPawn_ZedDAR;

simulated function ANIMNOTIFY_FireRocket_L()
{
	FiringSocketName = FiringSocketLName;
	StartRangedAttack();
}

simulated function ANIMNOTIFY_FireRocket_R()
{
	FiringSocketName = FiringSocketRName;
	StartRangedAttack();
}

defaultproperties
{
	LocalizationKey=KFPawn_ZedDAR_Rocket

	ControllerClass=class'KFAIController_ZedDAR_Rocket'
	MonsterArchPath="ZED_ARCH.ZED_DAR_Rocket_Archetype"
	DifficultySettings=class'KFDifficulty_DAR_Rocket'

	RangedProjectileClass=class'KFProj_EvilDAR_Rocket'

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Taunt)=class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
		SpecialMoveClasses(SM_StandAndShootAttack)=class'KFSM_DAR_RocketAttack'
	End Object

	FiringSocketRName=Rocket_R
	FiringSocketLName=Rocket_L
}
