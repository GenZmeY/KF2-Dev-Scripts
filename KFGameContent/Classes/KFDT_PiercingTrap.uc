//=============================================================================
// KFDT_PiercingTrap
//=============================================================================
// Sharp or high velocity objects designed to pass through enemies
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_PiercingTrap extends KFDT_Piercing;

defaultproperties
{
	KDamageImpulse=300

	EffectGroup=FXG_Piercing
	bIsTrapDamage=true
}
