//=============================================================================
// KFDT_Healing
//=============================================================================
// Base class of all KF healing damage types
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Healing extends KFDamageType
	abstract
	hidedropdown;

/** Play damage type specific impact effects when taking damage */
static function PlayImpactHitEffects( KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator )
{
	// If we don't have a hit zone, force effect on the torso
	if ( HitZoneIndex == 255 )
	{
		// we pretty much know the chest zone#2, but go ahead and dynamically
		// search for the torso in case we have a pawn with custom zones.
		HitZoneIndex = P.HitZones.Find('BoneName', P.TorsoBoneName);
	}

	Super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
}

defaultproperties
{
	ScreenMaterialName=Effect_Heal
	EffectGroup=FXG_Healing
    bNoPain=true
}
