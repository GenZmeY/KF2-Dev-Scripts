//=============================================================================
// KFDT_Toxic_BloatKingFart
//=============================================================================
// Bloat King fart gas attack damagetype
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDT_Toxic_BloatKingFart extends KFDT_Toxic
    abstract
    hidedropdown;

defaultproperties
{
	// override DoT from KFDT_Toxic
	DoT_Type=DOT_None

	PoisonPower=0

	CameraLensEffectTemplate=class'KFCameraLensEmit_Puke_Light'
	AltCameraLensEffectTemplate=class'KFCameraLensEmit_Puke_Light'

    bNoInstigatorDamage=true
    bConsideredIndirectOrAoE=true
}
