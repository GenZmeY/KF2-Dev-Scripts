//=============================================================================
// KFDT_Slashing_Hans 
//=============================================================================
// Slashing damage with Hans
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_Hans extends KFDT_Slashing
	abstract
	hidedropdown;

defaultproperties
{
    bExtraMomentumZ=true
	
	KDamageImpulse=400
	KDeathUpKick=200
	KDeathVel=750

	bAllowAIDoorDestruction=true
}
