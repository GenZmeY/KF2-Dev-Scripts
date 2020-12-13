//=============================================================================
// KFDT_Bludgeon_Crovel
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_RifleButt extends KFDT_Bludgeon
	abstract
	hidedropdown;

defaultproperties
{
	KDamageImpulse=700
	KDeathUpKick=300
	KDeathVel=200
	bExtraMomentumZ=true

	StumblePower=200
	MeleeHitPower=100
	
	ModifierPerkList(0)=class'KFPerk_Berserker'
}
