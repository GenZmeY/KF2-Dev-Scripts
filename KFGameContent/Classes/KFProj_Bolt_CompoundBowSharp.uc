//=============================================================================
// KFProj_Bolt_CompoundBowSharp
//=============================================================================
// Bullet class for the Compound Bow Sharp Arrows
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//	- Tulio Beloqui (Saber Interactive)
//=============================================================================

class KFProj_Bolt_CompoundBowSharp extends KFProj_RicochetStickBullet
	hidedropdown;

var repnotify int ChargeLevel;

replication
{
	if (bNetInitial)
		ChargeLevel;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(ChargeLevel))
	{
		SpawnFlightEffects();
	}

	Super.ReplicatedEvent(VarName);
}

simulated function PostBeginPlay ()
{
	local KFWeap_Bow_CompoundBow CompoundBow;

	if (Role == ROLE_Authority)
	{
		CompoundBow = KFWeap_Bow_CompoundBow(Owner);
		if (CompoundBow != none)
		{
			ChargeLevel = CompoundBow.GetChargeLevel();
		}
	}

	Super.PostBeginPlay ();
}

simulated function float GetChargeLevelTrail ()
{
	if (ChargeLevel >= 2)
	{
		if (WorldInfo.NetMode == NM_Client)
		{
			return 1.0;
		}

		return 0.73;
	}

	if (ChargeLevel == 1)
	{
		if (WorldInfo.NetMode == NM_Client)
		{
			return 0.825;
		}

		return 0.365;
	}

	// For level 0, no charge on the arrow:
	if (WorldInfo.NetMode == NM_Client)
	{
		return 0.66;
	}

	return 0;
}

simulated function SpawnFlightEffects ()
{
	if (ChargeLevel < 0)
	{
		// we need ChargeLevel to be replicated to Spawn the projectile!
		return;
	}

	super.SpawnFlightEffects ();

	if (ProjEffects != none)
	{
		ProjEffects.SetVectorParameter('ChargeLevelTrail', GetChargeLevelTrail() * vect(1.f, 1.f, 1.f));
	}
}

// Last location needs to be correct, even on first tick.
simulated function SyncOriginalLocation()
{
    LastLocation = OriginalLocation;

    Super.SyncOriginalLocation();
}

defaultproperties
{
	bWarnAIWhenFired=true

	// Speed is defined by the charge level of the bow:
	MaxSpeed=15000.0
	Speed=15000.0
	TerminalVelocity=15000.0

	DamageRadius=0

	ChargeLevel=-1

    BouncesLeft=0
	ProjFlightTemplate=ParticleSystem'WEP_CompoundBow_EMIT.FX_Compound_Bow_Sharp_Projectile'

    LifeSpan=10
    LifeSpanAfterStick=180

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

	ImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Crossbow_impact'

    AmbientSoundPlayEvent=AkEvent'WW_WEP_SA_Crossbow.Play_Bolt_Fly_By'
    AmbientSoundStopEvent=AkEvent'WW_WEP_SA_Crossbow.Stop_Bolt_Fly_By'

	WeaponClassName=KFWeap_Bow_CompoundBow
	ProjPickupTemplate=ParticleSystem'WEP_Crossbow_EMIT.FX_Crossbow_Projectile_Pickup'
    AmmoPickupSound=AkEvent'WW_WEP_SA_Crossbow.Play_Crossbow_Bolt_Pickup'

    TouchTimeThreshhold=0.15
}

