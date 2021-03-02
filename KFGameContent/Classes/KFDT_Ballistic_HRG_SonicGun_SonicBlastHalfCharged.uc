//=============================================================================
// KFDT_Ballistic_HRG_SonicGun_SonicBlastHalfCharged
//=============================================================================
// Sonic Boom impact damage for the HRG Sonic Gun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_HRG_SonicGun_SonicBlastHalfCharged extends KFDT_Ballistic_Rifle
	abstract
	hidedropdown;

/** Play damage type specific impact effects when taking damage */
static function PlayImpactHitEffects(KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator)
{
	// Play burn effect when dead
	if (P.bPlayedDeath && P.WorldInfo.TimeSeconds > P.TimeOfDeath)
	{
		return;
	}

	super.PlayImpactHitEffects(P, HitLocation, HitDirection, HitZoneIndex, HitInstigator);
}

defaultproperties
{
	OverrideImpactEffect=ParticleSystem'WEP_Microwave_Assault_EMIT.FX_Microwave_Assault_Impact'
	OverrideImpactSound=AkEvent'WW_WEP_SA_DragonsBreath.Play_Bullet_DragonsBreath_Impact_Dirt'
	ArmorDamageModifier=1.5f

	KDamageImpulse=0
	KDeathUpKick=0
	KDeathVel=0
	RadialDamageImpulse=5000
	bExtraMomentumZ=True

	StumblePower=50
	GunHitPower=60
	MicrowavePower=50
	bHasToSpawnMicrowaveFire=false

	EffectGroup=FXG_MicrowaveBlast
	ModifierPerkList(0)=class'KFPerk_Sharpshooter'

	WeaponDef=class'KFWeapDef_HRG_SonicGun'
}
