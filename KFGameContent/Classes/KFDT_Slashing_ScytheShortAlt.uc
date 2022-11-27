//=============================================================================
// KFDT_Slashing_ScytheShortAlt
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_ScytheShortAlt extends KFDT_Slashing_ZweihanderHeavy
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=3600 //1600
	KDeathUpKick=400 //200
	KDeathVel=750 //500

	KnockdownPower=0
	StunPower=0
	StumblePower=150
	MeleeHitPower=100

	// Obliteration
	GoreDamageGroup = DGT_Explosive
	RadialDamageImpulse = 8000.f // This controls how much impulse is applied to gibs when exploding
	bUseHitLocationForGibImpulses = true // This will make the impulse origin where the victim was hit for directional gibs
	bPointImpulseTowardsOrigin = true // This creates an impulse direction aligned along hitlocation and pawn location -- this will push all gibs in the same direction
	ImpulseOriginScale = 100.f // Higher means more directional gibbing, lower means more outward (and upward) gibbing
	ImpulseOriginLift = 150.f
	MaxObliterationGibs = 12 // Maximum number of gibs that can be spawned by obliteration, 0=MAX
	bCanGib = true
	bCanObliterate = true
	ObliterationHealthThreshold = 0
	ObliterationDamageThreshold = 100

	WeaponDef=class'KFWeapDef_Scythe'
	ModifierPerkList(0)=class'KFPerk_Berserker'
}
