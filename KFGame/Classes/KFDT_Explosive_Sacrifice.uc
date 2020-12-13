//=============================================================================
// KFDT_Explosive_Sacrifice
//=============================================================================
// Explosive damage type used for Demolitionist Sacrifice skill
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// by Jeff Robinson
//=============================================================================

class KFDT_Explosive_Sacrifice extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=300

	KnockdownPower=20 // knockdown any non-boss zed in one hit
	StumblePower=0
	StunPower=21 // stun any non-boss zed in one hit

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'

    bAnyPerk = true
}