//=============================================================================
// KFDT_EMP_MatriarchTeslaBlast
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDT_EMP_MatriarchTeslaBlast extends KFDT_EMP
	abstract
	hidedropdown;

defaultproperties
{
    bArmorStops=true

	RadialDamageImpulse=2000
	KDeathUpKick=500
	KDeathVel=300

	KnockdownPower=50
	MeleeHitPower=50
	EMPPower=50

	bAllowAIDoorDestruction=true
}