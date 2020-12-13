//=============================================================================
// KFDT_Bludgeon_BloatKingGorge
//=============================================================================
// Bloat King gorge attack for players when they finish getting sucked in.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Bludgeon_BloatKingGorge extends KFDT_Bludgeon
    abstract;

var AkEvent GorgeBiteSound;

static function PlayImpactHitEffects(KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator)
{
	super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);

	if (P.Controller != none && P.Controller.IsLocalController())
	{
		P.Controller.PlaySoundBase(default.GorgeBiteSound, true);
	}
}

defaultproperties
{
	CameraLensEffectTemplate=class'KFCameraLensEmit_BloodGorge'
	GorgeBiteSound=AkEvent'WW_ZED_Abomination.Play_Abomination_Bite'
    KDamageImpulse=700
    KDeathUpKick=200
    KDeathVel=980
    bExtraMomentumZ=true
}