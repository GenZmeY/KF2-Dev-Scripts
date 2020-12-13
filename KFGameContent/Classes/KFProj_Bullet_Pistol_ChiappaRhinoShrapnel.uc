//=============================================================================
// KFProj_Bullet_Pistol_ChiappaRhinoShrapnel
//=============================================================================
// Bullet class for Desert Eagle pistols
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFProj_Bullet_Pistol_ChiappaRhinoShrapnel extends KFProj_Bullet
    hidedropdown;

defaultproperties
{
    MaxSpeed=18000.0
    Speed=18000.0

    DamageRadius=0

	bSyncToOriginalLocation = True
	bSyncToThirdPersonMuzzleLocation = false
	bNoReplicationToInstigator = false
	bReplicateClientHitsAsFragments = true

	MyDamageType=class'KFDT_Piercing_ChiappaShrapnel'
	Damage=80.0f

	ProjFlightTemplate=ParticleSystem'WEP_ChiappaRhino_EMIT.FX_Tracer_ChiappaRhino_ZEDTime'
}

