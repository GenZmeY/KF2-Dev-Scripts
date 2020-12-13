//=============================================================================
// KFDT_SwingMinigame
//=============================================================================
// Damage caused by the Swing minigame in the Summer Sideshow.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// Dan Weiss
//=============================================================================

class KFDT_SwingMinigame extends KFDamageType;

static function PlayImpactHitEffects(KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator)
{
    //Volume hit that this is used for was throwing all sorts of screwy hit locations.  Use the Pawn's location instead.
    super.PlayImpactHitEffects(P, P.Location, HitDirection, HitZoneIndex, HitInstigator);
}

defaultproperties
{
	//RadialDamageImpulse=2000//3000
	GibImpulseScale=0.15
	KDeathUpKick=55//200
    //KDeathVel=300
    KDamageImpulse=1000//1000

    bArmorStops=false
    GoreDamageGroup=DGT_Explosive

    OverrideImpactEffect=ParticleSystem'FX_Environmental_EMIT_THREE.FX_Swing_Ride_Bloodhit_01'

    OverrideImpactSound=AkEvent'WW_ENV_Destruction.Play_ENV_Destruction_Swing_Flesh_Hit'
	bIsTrapDamage=true

}