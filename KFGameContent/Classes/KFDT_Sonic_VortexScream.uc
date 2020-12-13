//=============================================================================
// KFDT_Sonic_VortexScream
//=============================================================================
// Damage type used for the player siren's vortex scream
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFDT_Sonic_VortexScream extends KFDT_Sonic;

defaultproperties
{
	KDamageImpulse=1
	KDeathUpKick=500
	KDeathVel=700
	EffectGroup=FXG_DrainLife
	OverrideImpactEffect=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Life_Draw_01'
}