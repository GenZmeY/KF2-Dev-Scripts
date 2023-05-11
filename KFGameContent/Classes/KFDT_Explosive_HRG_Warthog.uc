//=============================================================================
// KFDT_Explosive_HRG_Warthog
//=============================================================================
// Explosive damage type for HRG Warthog explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_HRG_Warthog extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood = true

	// physics impact
	RadialDamageImpulse = 2000
	GibImpulseScale = 0.15
	KDeathUpKick = 1000
	KDeathVel = 300

	KnockdownPower = 50
	StumblePower = 150

	WeaponDef=class'KFWeapDef_HRG_Warthog'
	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	bCanZedTime=false
	bCanEnrage=false
}
