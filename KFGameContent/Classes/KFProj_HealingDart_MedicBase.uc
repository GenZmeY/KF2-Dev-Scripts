//=============================================================================
// KFProj_HealingDart_MedicBase
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_HealingDart_MedicBase extends KFProj_HealingDart;

defaultproperties
{
	ProjFlightTemplate=ParticleSystem'FX_Projectile_EMIT.FX_Medic_dart_01'
	ProjFlightTemplateZedTime=ParticleSystem'FX_Projectile_EMIT.FX_Medic_dart_01'

    AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_Loop'
    AmbientSoundStopEvent=AkEvent'WW_WEP_SA_MedicDart.Stop_WEP_SA_Medic_Dart_Loop'
}
