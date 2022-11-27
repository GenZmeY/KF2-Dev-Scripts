//=============================================================================
// KFDT_EMP_HVStormCannon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFDT_EMP_HVStormCannon extends KFDT_EMP
	abstract
	hidedropdown;

var ParticleSystem ForceImpactEffect;
var AkEvent ForceImpactSound;

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
	KDamageImpulse=2000
	KDeathUpKick=400
	KDeathVel=250

    KnockdownPower=20
	StunPower=50
	StumblePower=200
	GunHitPower=150
	MeleeHitPower=100
	EMPPower=0 // Don't use the affliction here, we manage this on KFWeap_HVStormCannon to completely synchronize it with the logic of the weapon

	GoreDamageGroup=DGT_EMP
	EffectGroup=FXG_Electricity

	ForceImpactEffect=ParticleSystem'WEP_HVStormCannon_EMIT.FX_HVStormCannon_Impact'
	ForceImpactSound=AkEvent'WW_WEP_HVStormCannon.Play_WEP_HVStormCannon_Impact'

	WeaponDef=class'KFWeapDef_HVStormCannon'

	//Perk
	ModifierPerkList(0)=class'KFPerk_Sharpshooter'
}
