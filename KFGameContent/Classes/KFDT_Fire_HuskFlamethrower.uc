//=============================================================================
// KFDT_Fire_HuskFlamethrower
//=============================================================================
// A damage type for the husk flame SprayActor
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Fire_HuskFlamethrower extends KFDT_Fire
	abstract; // no hidedropdown, for archetype

defaultproperties
{
	DoT_DamageScale=0.5f

	KDamageImpulse=400
	KDeathUpKick=50
	KDeathVel=75
}
