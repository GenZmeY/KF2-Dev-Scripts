//=============================================================================
// KFDT_Ballistic_HRG_SonicGun_SonicBlastUncharged
//=============================================================================
// Sonic Boom impact damage for the HRG Sonic Gun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFDT_Ballistic_HRG_SonicGun_SonicBlastUncharged extends KFDT_Ballistic_Rifle
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
	OverrideImpactEffect=ParticleSystem'WEP_HRG_SonicGun_EMIT.FX_SonicGun_Impact'
	OverrideImpactSound=AkEvent'WW_WEP_HRG_SonicGun.Play_WEP_HRG_SonicGun_Hit_Surface'
	ArmorDamageModifier=1.5f

	KDamageImpulse=0
	KDeathUpKick=0
	KDeathVel=0
	RadialDamageImpulse=5000
	bExtraMomentumZ=True

	StumblePower=0
	GunHitPower=30
	MicrowavePower=75
	bHasToSpawnMicrowaveFire=false

	EffectGroup=FXG_MicrowaveBlast
	bCanObliterate=true
	bCanGib=true
	ModifierPerkList(0)=class'KFPerk_Sharpshooter'

	WeaponDef=class'KFWeapDef_HRG_SonicGun'
}
