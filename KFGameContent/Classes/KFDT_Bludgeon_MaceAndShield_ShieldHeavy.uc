//=============================================================================
// KFDT_Bludgeon_MaceAndShield_ShieldHeavy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Bludgeon_MaceAndShield_ShieldHeavy extends KFDT_Bludgeon_MaceAndShield
	abstract
	hidedropdown;

defaultproperties
{
	EffectGroup=FXG_ShieldBash

	//Shield Attack
	KDamageImpulse=4000 //1500 //7000
	KDeathUpKick=700 //0
	KDeathVel=375 //375
	
	KnockdownPower=100
	StunPower=0
	StumblePower=450 //150
	MeleeHitPower=100

	// Obliteration
	GoreDamageGroup=DGT_Explosive
	RadialDamageImpulse=8000.f // This controls how much impulse is applied to gibs when exploding
	bUseHitLocationForGibImpulses=true // This will make the impulse origin where the victim was hit for directional gibs
	MaxObliterationGibs=12 // Maximum number of gibs that can be spawned by obliteration, 0=MAX
	bCanGib=true
	bCanObliterate=true
	ObliterationHealthThreshold=-10
	ObliterationDamageThreshold=80

	WeaponDef=class'KFWeapDef_MaceAndShield'

	ModifierPerkList(0)=class'KFPerk_Berserker'
}