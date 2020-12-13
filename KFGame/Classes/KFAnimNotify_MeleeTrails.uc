//=============================================================================
// KFAnimNotify_MeleeTrails
//=============================================================================
// A trails notify that adds particle system overrides for special melee
// weapon perk skills (see AKFWeap_MeleeBase::GetAnimTrailParticleSystem).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnimNotify_MeleeTrails extends AnimNotify_Trails
	native(Anim);

var(Trails) ParticleSystem BlueTrailParticle;
var(Trails) ParticleSystem RedTrailParticle;

defaultproperties
{
	BlueTrailParticle=ParticleSystem'FX_Gameplay_EMIT_THREE.Trails.FX_Trail_Blue_R_01'
	RedTrailParticle=ParticleSystem'FX_Gameplay_EMIT_THREE.Trails.FX_Trail_Red_R_01'
}