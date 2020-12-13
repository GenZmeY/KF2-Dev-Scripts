//=============================================================================
// KFDT_BloatPuke
//=============================================================================
// Any bio-chemical substance that burns or causes cell damage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_BloatPuke extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	DoT_Duration=12.0
	DoT_Interval=1.0
	DoT_DamageScale=0.0833334

	PoisonPower=0.f
	bConsideredIndirectOrAoE=true
	bNoInstigatorDamage=true
}