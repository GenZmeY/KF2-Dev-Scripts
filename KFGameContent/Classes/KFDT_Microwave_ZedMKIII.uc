//=============================================================================
// KFDT_Microwave_ZedMKIII
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_Microwave_ZedMKIII extends KFDT_Microwave
	abstract
	hidedropdown;

var ParticleSystem ForceImpactEffect;
var AkEvent ForceImpactSound;

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	if( super.CanDismemberHitZone( InHitZoneName ) )
	{
		return true;
	}

	switch ( InHitZoneName )
	{
		case 'lupperarm':
		case 'rupperarm':
	 		return true;
	}

	return false;
}

static function PlayImpactHitEffects( KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator )
{
	local KFSkinTypeEffects SkinType;

	if ( P.CharacterArch != None && default.EffectGroup < FXG_Max )
	{
		SkinType = P.GetHitZoneSkinTypeEffects( HitZoneIndex );

		if (SkinType != none)
		{
			SkinType.PlayImpactParticleEffect(P, HitLocation, HitDirection, HitZoneIndex, default.EffectGroup, default.ForceImpactEffect);
			SkinType.PlayTakeHitSound(P, HitLocation, HitInstigator, default.EffectGroup, default.ForceImpactSound);
		}
	}
}

defaultproperties
{
	KDamageImpulse=550
	GibImpulseScale=0.85
	KDeathUpKick=-200
	KDeathVel=200

	StumblePower=18
	StunPower=15
	GunHitPower=15

	WeaponDef=class'KFWeapDef_ZedMKIII'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Demolitionist'

	EffectGroup=FXG_MicrowaveProj

	ForceImpactEffect=ParticleSystem'WEP_ZEDMKIII_EMIT.FX_ZEDMKIII_Bullet_Impact'
	ForceImpactSound=AkEvent'WW_WEP_ZEDMKIII.Play_WEP_ZEDMKIII_Shoot_Impact'
}
