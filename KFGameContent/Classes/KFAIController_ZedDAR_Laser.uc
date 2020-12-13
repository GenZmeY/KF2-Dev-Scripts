//=============================================================================
// KFAIController_ZedDAR_Laser
//=============================================================================
// AI Controller for Evulz Lazer DAR
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedDAR_Laser extends KFAIController_ZedDAR;

function StartRangedAttack()
{
	class'AICommand_DAR_LaserAttack'.static.LaserAttack(self);
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

	

	AimError=0.01f
}
