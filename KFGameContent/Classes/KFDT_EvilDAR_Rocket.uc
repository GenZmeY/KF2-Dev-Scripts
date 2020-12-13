//=============================================================================
// KFDT_EvilDAR_Rocket
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFDT_EvilDAR_Rocket extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	// physics impact
	RadialDamageImpulse=2500//10000
	GibImpulseScale=0.15
	KDeathUpKick=1500//2000
	KDeathVel=500

	KnockdownPower=225
	StumblePower=400

	bAllowAIDoorDestruction=true
}
