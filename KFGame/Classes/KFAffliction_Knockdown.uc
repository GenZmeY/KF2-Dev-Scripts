//=============================================================================
// KFAffliction_MediumRecovery
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_Knockdown extends KFAfflictionBase;

/** */
function Activate(optional class<KFDamageType> DamageType = none)
{
	ActivateKnockdown(DamageType, 
		PawnOwner.HitFxInfo.HitLocation, 
		PawnOwner.DecodeUnitVector( PawnOwner.HitFxInfo.EncodedHitDirection ), 
		PawnOwner.HitFxInfo.HitBoneIndex);

	Super.Activate();
}

/** Apply a knockdown (on hit) to this character */
protected function ActivateKnockdown(class<KFDamageType> DamageType, vector HitLoc, vector HitDir, byte HitZoneIdx)
{
	local vector Impulse;

	// Handle explosive damage types as radial impulses
	if ( DamageType.default.RadialDamageImpulse > 0 && !DamageType.default.bPointImpulseTowardsOrigin )
	{
		Impulse = DamageType.default.RadialDamageImpulse * HitDir;
		// If we have a cached RadiusDamageScale, assume it's from this hit and use it to calc the radius impulse falloff
		if ( PawnOwner.HitFxInfo.bRadialDamage && PawnOwner.HitFxRadialInfo.RadiusDamageScale != 255 )
		{
			Impulse *= ByteToFloat(PawnOwner.HitFxRadialInfo.RadiusDamageScale);
		}
		// Add the deathUpKick here for extra oomph
		Impulse += Vect(0,0,1) * DamageType.default.KDeathUpKick;

		// Since we don't have the proper Origin, Radius, and Falloff in TakeDamage use a
		// point impulse, but fake it to to look like a radial impulse.  This is done by:
		// 1) Zeroing the Position.  This causes AddImpulse to call addForce (same as with RadialImpulse) instead of addForceAtPos
		// 2) Zeroing the BoneName.  With AddRadialImpulse, GetNxActor() has no BoneName so addForce will use the root body
		PawnOwner.Knockdown(, vect(1,1,1),,,, Impulse);
	}
	else
	{
		// An artifical RBAngularVelocity is used for replication, see NEQ()
		PawnOwner.Knockdown(, vect(1,1,1),,,, DamageType.default.KDamageImpulse * HitDir, HitLoc, HitZoneIdx);
	}
}

defaultproperties
{
}
