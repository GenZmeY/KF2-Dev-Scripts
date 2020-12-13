//=============================================================================
// KFDT_Bludgeon_ZedJump
//=============================================================================
// Bludgeon damage for jump attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Bludgeon_ZedJump extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
    bExtraMomentumZ=true

	KDamageImpulse=1000
	KDeathUpKick=300
	KDeathVel=950
}
