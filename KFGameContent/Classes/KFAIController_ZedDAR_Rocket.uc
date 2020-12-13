//=============================================================================
// KFAIController_ZedDAR_Rocket
//=============================================================================
// AI Controller for Evulz Rocket DAR
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedDAR_Rocket extends KFAIController_ZedDAR;

function StartRangedAttack()
{
	class'AICommand_DAR_RocketAttack'.static.RocketAttack(self);
}

function vector GetStartFireLocation()
{
	local vector SocketLocation;
	local rotator SocketRotation;

	MyKFPawn.Mesh.GetSocketWorldLocationAndRotation(KFPawn_ZedDAR(MyKFPawn).FiringSocketName, SocketLocation, SocketRotation);
	return SocketLocation;
}

defaultproperties
{

	RangeAttackIntervalNormal=11.0
	RangeAttackIntervalHard=10.0
	RangeAttackIntervalSuicidal=9.0
	RangeAttackIntervalHellOnEarth=8.0

}
