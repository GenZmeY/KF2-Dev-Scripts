//=============================================================================
// KFDT_DemoNuke_Toxic
//=============================================================================
// Demolitionist's Nuke skill radiation DamageType
// @note: In KFGame.u because it's references by the Demo perk
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Chris "Schneidzekk" Schneider
//=============================================================================

class KFDT_Toxic_DemoNuke extends KFDT_Toxic
	hidedropdown;

/** Nuke will always apply poison */
static function bool AlwaysPoisons()
{
	return true;
}

defaultproperties
{
	DoT_Type=DOT_None
    bNoInstigatorDamage=true

	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000
	KDeathUpKick=1000
	KDeathVel=300

    KnockdownPower=0
	StumblePower=0

	DoT_Duration=5 //10.0
	DoT_Interval=0.3 //1.0 //0.3
	DoT_DamageScale=0.1f //0.1 //1.0

	PoisonPower=1000
	BurnPower=0

	ModifierPerkList(0)=class'KFPerk_Demolitionist'
}