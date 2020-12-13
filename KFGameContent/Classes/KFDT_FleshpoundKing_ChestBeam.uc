//=============================================================================
// KFDT_FleshpoundKing_ChestBeam
//=============================================================================
// Damagetype for the Fleshpound King's chest beam attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_FleshpoundKing_ChestBeam extends KFDT_EMP
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
}