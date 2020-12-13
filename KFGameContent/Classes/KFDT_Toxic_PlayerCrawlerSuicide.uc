//=============================================================================
// KFDT_Toxic_PlayerCrawlerSuicide
//=============================================================================
// Crawler suicide gas attack damagetype
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Toxic_PlayerCrawlerSuicide extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	// override DoT from KFDT_Toxic
	DoT_Type=DOT_None

	PoisonPower=0

	CameraLensEffectTemplate=class'KFCameraLensEmit_Puke_Light'
	AltCameraLensEffectTemplate=class'KFCameraLensEmit_Puke_Light'

    // Don't let Hans damage himself with his grenade
    bNoInstigatorDamage=true
    bConsideredIndirectOrAoE=true
}
