//=============================================================================
// KFDT_Explosive_Shrapnel
//=============================================================================
// Explosive damage with similar values to frag grenade
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_Shrapnel extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=500  //3000
	KDeathUpKick=900   //1000
	KDeathVel=200      //300

	StunPower=500
	StumblePower=500
	MeleeHitPower=500

	ModifierPerkList(0)=class'KFPerk_Firebug'	
}