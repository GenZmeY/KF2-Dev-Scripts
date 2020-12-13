//=============================================================================
// KFAIController_ZedDAR_EMP
//=============================================================================
// AI Controller for Evulz EMP DAR
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedDAR_EMP extends KFAIController_ZedDAR;

var name EMPSocketName;

function StartRangedAttack()
{
	class'AICommand_DAR_EMPAttack'.static.EMPAttack(self);
}

defaultproperties
{
	EMPSocketName=EMP_Blast

	RangeAttackIntervalNormal=10.0
	RangeAttackIntervalHard=9.0
	RangeAttackIntervalSuicidal=8.0
	RangeAttackIntervalHellOnEarth=7.0

	MinRangeAttackDist=250 //300
	MaxRangeAttackDist=550 //4000

	SprintWithinEnemyRange=(X=500.f,Y=5000.f)  //X=800.f,Y=1500
}
