//=============================================================================
// KFDT_Toxic_EnvironmentGas
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDT_Toxic_EnvironmentGas extends KFDT_Toxic
	abstract;

defaultproperties
{
	// override DoT from KFDT_Toxic
	DoT_Type=DOT_None

	PoisonPower=1.f

	CameraLensEffectTemplate=class'KFCameraLensEmit_Puke_Light'
	AltCameraLensEffectTemplate=class'KFCameraLensEmit_Puke_Light'

    bNoInstigatorDamage=true
    bConsideredIndirectOrAoE=true
}
