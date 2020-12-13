//=============================================================================
// KFDT_Slashing_Gorefast
//=============================================================================
// Slashing damage with light impact energy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_Gorefast extends KFDT_Slashing
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=400
	KDeathUpKick=120
	KDeathVel=500
	bExtraMomentumZ=true
}
