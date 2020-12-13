//=============================================================================
// KFProj_CrystalSpike_HRG_Vampire
//=============================================================================
// Bullet class for the HRG Vampire crystal spikes.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//
//=============================================================================

class KFProj_CrystalSpike_HRG_Vampire extends KFProj_Bullet
	hidedropdown;


simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	super.ProcessBulletTouch(Other, HitLocation, HitNormal);

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if ( Other.IsA('Pawn') && Other.bCanBeDamaged)
		{
			WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffects.DefaultImpactEffect.ParticleTemplate, HitLocation, rotator(HitNormal), Other);
			PlaySoundBase(ImpactEffects.DefaultImpactEffect.Sound, true,,, HitLocation);
		}
	}
}

defaultproperties
{
	bWarnAIWhenFired=true

	MaxSpeed=12000.0 //15000.0
	Speed=12000.0 ///15000.0
	TerminalVelocity=12000.0 //15000.0

	DamageRadius=0

	ProjFlightTemplate=ParticleSystem'WEP_HRG_Vampire_EMIT.FX_HRG_Vampire_Projectile_ALT'

    LifeSpan=10

    bBlockedByInstigator=false
    bCollideActors=true
    bCollideComplex=true
    bNoEncroachCheck=true
	bNoReplicationToInstigator=false
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=false
	bRotationFollowsVelocity=false
	bNetTemporary=false
    bSyncToOriginalLocation=true

	ImpactEffects = KFImpactEffectInfo'WEP_HRG_Vampire_Arch.HRG_Vampire_SpikeFireImpacts'

    AmbientSoundPlayEvent=None
    AmbientSoundStopEvent=None

    TouchTimeThreshhold=0.15
	
	AssociatedPerkClass=class'KFPerk_FieldMedic'
}

