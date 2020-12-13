//=============================================================================
// KFDT_NoGoVolume
//=============================================================================
// Damage caused by sitting in NoGoVolumes for too long
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================

class KFDT_NoGoVolume extends KFDamageType
	abstract;

defaultproperties
{
    bCausedByWorld=true
    bArmorStops=false
	OverrideImpactEffect=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Life_Draw_01'
}