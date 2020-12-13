//=============================================================================
// KFDT_DemoNuke_Toxic_Lingering
//=============================================================================
// Demolitionist's Nuke skill radiation DamageType
// @note: In KFGame.u because it's references by the Demo perk
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Chris "Schneidzekk" Schneider
//=============================================================================

class KFDT_DemoNuke_Toxic_Lingering extends KFDT_Toxic_DemoNuke
	hidedropdown;

/** Nuke will always apply poison */
static function bool AlwaysPoisons()
{
	return true;
}

defaultproperties
{
	DoT_Type=DOT_Toxic
    bNoInstigatorDamage=true

    KnockdownPower=0
	StumblePower=0

	DoT_Duration=5 //10.0
	DoT_Interval=0.3 //1.0 //0.3
	DoT_DamageScale=1.f //0.1 //1.0

	PoisonPower=1000
	BurnPower=0
}