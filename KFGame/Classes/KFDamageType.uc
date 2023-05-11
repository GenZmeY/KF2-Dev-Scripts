//=============================================================================
// KFDamageType
//=============================================================================
// Base class of all KF damagetypes
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDamageType extends DamageType
	dependson(KFPlayerReplicationInfo, KFSkinTypeEffects)
	abstract
	hidedropdown;

`include(KFGameDialog.uci)

var class<KFWeaponDefinition> WeaponDef;

/** Won't do damage to the instigator */
var bool bNoInstigatorDamage;

/** Won't do damage to teammates */
var bool bNoFriendlyFire;

/** This Damge won't kill the pawn when applied */
var bool bNonLethalDamage;

/** Scale up damage to the zed when the head is blown off by this amount. Used for weapons with multiple projectiles like shotguns so you get the effect of all pellets hitting the head */
var float HeadDestructionDamageScale;

/** Scale up ragdoll impulse force to the zed's body when the head is blown off by this amount. Used for weapons with multiple projectiles like shotguns so you get the effect of all pellets hitting the head */
var float HeadDestructionImpulseForceScale;

/**
 * Whether this damagetype is used in consideration for indirect/AoE damage in the AAR
 * @note: AAR only, this is normally determined by TakeRadiusDamage()
 */
var bool bConsideredIndirectOrAoE;

/** If true, this damagetype will destroy a door if closed and unwelded */
var bool bAllowAIDoorDestruction;

/** If true can PlayDeadHitEffects the Zeds when killing them */
var bool bCanPlayDeadHitEffects;

/*********************************************************************************************
Damage over time
 ********************************************************************************************* */

/** abstracted type used specifically for damamge over time */
enum EDamageOverTimeGroup
{
	DOT_None,
	DOT_Fire,
	DOT_Toxic,
	DOT_Bleeding
};

/** Does extra damage over time after the initial damage if not set to DOT_None */
var EDamageOverTimeGroup DoT_Type;
/** How long to keep applying damage over time */
var float DoT_Duration;
/** How often to apply the DoT_Damage */
var float DoT_Interval;
/** How much to scale the original damage received to apply the damage over time.
  * For example, if the original Damage was 10, and this DoT_DamageScale was 0.5
  * then the 5 damage would be applied at the DoT_Interval for DoT_Interval seconds
  */
var float DoT_DamageScale;
/** Whether or not to create a new DoT instance each time this damage type is applied */
var bool bStackDoT;


var bool bHasToSpawnMicrowaveFire;
/*********************************************************************************************
Status Effects
 ********************************************************************************************* */

/** Strength value for each incap effect */
var float StunPower;
var float KnockdownPower;
var float StumblePower;
var float LegStumblePower;

/** Clientside hit reactions.  Two types depends on weapon type */
var float GunHitPower;
var float MeleeHitPower;

/** Strength of stacking incap effect (e.g. Burning/Panic, Poisoned) */
var float BurnPower;
var float EMPPower;
var float PoisonPower;
var float MicrowavePower;
var float FreezePower;
var float SnarePower;
var float BleedPower;
var float BigHeadPower;
var float ShrinkPower;
/*********************************************************************************************
Impact Effects
 ********************************************************************************************* */

/** No impact effects for id==255 */
`define FXG_NONE 255

var EEffectDamageGroup EffectGroup;

/*********************************************************************************************
Perk
 ********************************************************************************************* */
/** List of perk classes that can modify damage/fx for this damage type */
var array<class<KFPerk> >	ModifierPerkList;
var bool 				 	bAnyPerk;

/*********************************************************************************************
Gore
 ********************************************************************************************* */

/** abstracted type used specifically for gore */
enum EGoreDamageGroup
{
	DGT_None,
	DGT_AssaultRifle,
	DGT_Rifle,
	DGT_Submachinegun,
	DGT_Shotgun,
	DGT_Handgun,
	DGT_Explosive,
	DGT_MeleeSlash,
	DGT_MeleeBludgeon,
	DGT_Fire,
	DGT_EMP,
	DGT_Obliteration
};


/** What kind of damage group this damage type belongs to */
var EGoreDamageGroup GoreDamageGroup;

/** Materials to use for body wounds caused by this damage type */
var array<MaterialInstance> BodyWoundDecalMaterials;

/** Dimensions for body wound decals */
var float BodyWoundDecalWidth, BodyWoundDecalHeight;

/** The name of the screen material to update when hit */
var name ScreenMaterialName;

/** Camera lens emitter effects when a pawn is hit with this damage type */
var class<EmitterCameraLensEffectBase> CameraLensEffectTemplate;

/** Camera lens emitter effects when a pawn is hit with this damage type */
var class<EmitterCameraLensEffectBase> AltCameraLensEffectTemplate;

/** If set, spawn blood decal on world */
var bool bShouldSpawnBloodSplat;

/** If set, spawn persistent blood on world */
var bool bShouldSpawnPersistentBlood;

/** If set, calls 'CauseGibsAndApplyImpulse' for radial damage when obliteration is not used */
var bool bCanGib;

var bool bIgnoreAggroOnDamage;

/** If set, it can completely obliterate zeds when hit by this damage type.
	Obliteration can also depend on other factors such as how close the zed
	was to this damage type when taking damage, etc. Eg. explosives.
	*  bCanObliterate - will deal with dismembering all detachable body parts.
	* 2) DGT_Obliterate: GoreGroup (archetype) driven "obliteration" gore.  Used by violent explosives (e.g. Pulverizer) and
	* tends to gore the torso moreso than DGT_Explosive which often gores the legs. This follows the same dismemberment code,
	* but picks specific bones that it can dismember.
	**/
var bool bCanObliterate;

/** How low the pawn's health must get for this damage type to cause obliteration */
var(Obliteration) int ObliterationHealthThreshold;
/** How much damage this damage type must deal before causing obliteration */
var(Obliteration) int ObliterationDamageThreshold;

/** Maximum number of gibs that an obliterate can spawn, 0=MAX */
var float MaxObliterationGibs;

/** When bCanObliterate=TRUE, uses the hit location vector instead of the Victim's location when spawning gibs */
var bool bUseHitLocationForGibImpulses;

/** When ragdoll impulse is applied to a dismembered body part, reduce the impulse by this value.  While
 * not physically accurate, this counters change in mass so those small parts are not launched into orbit! */
var float GibImpulseScale;

/**
 * This creates an impulse direction aligned along instigator location and hitlocation -- this will push all gibs in
 * the same direction, away from the pawn that caused the damage
 */
var bool bPointImpulseTowardsOrigin;
/**
 * When used in conjunction with bPointImpulseTowardsOrigin, this determines how far back to pull the hit origin. Larger means
 * more directional, smaller means more outward */
var float ImpulseOriginScale;

/** When used in conjunction with bPointImpulseTowardsOrigin, this adds additional Z lift to gibs */
var float ImpulseOriginLift;

/** If set, adds a random spread to the blood effects spawned by this damage type.
	Usually used for things like shotgun shells
 */
var float BloodSpread;

/** 0 to 1 value to scale the blood effects spawned by this damage type */
var float BloodScale<ClampMin=0.0|ClampMax=1.0>;

/** If true, this damagetype is specific to a location on an actor (like a bullet). If false it is more general like an explosion */
//var() bool	bLocationalDamage;

/** If true, play screams and screen effects for players */
var bool bNoPain;

/** If true, scale any damage that is self inflicted by the difficulty */
var bool bIgnoreSelfInflictedScale;

/** If true, zed on zed scaling will be ignored */
var bool bIgnoreZedOnZedScaling;

/** Material parameter to alter on the dead pawn for this damage type */
var name DeathMaterialEffectParamName;

/** Interpolation duration for death material parameter above */
var float DeathMaterialEffectDuration;

/** Custom override that bypasses skin type system for one-off damage types. */
var ParticleSystem OverrideImpactEffect;

/** Custom override that bypasses skin type system for one-off damage types. */
var AKEvent OverrideImpactSound;

//For use on in world trap damage types
var bool bIsTrapDamage;

//When doing armour piercing damage (this is a % of total damage received, the rest is considered as base if defined)
var float DamageModifierAP;

// If killing with this damage type can trigger zed time
var bool bCanZedTime;

// If damaging with this can trigger rage
var bool bCanEnrage;

// If applies radial impulse an it affect the affliction power as well?
var bool bCanApplyRadialCalculationtoAffliction;

/**
 * Take the primary HitDirection and modify it to add more spread.
 * Use the BloodSpread property to calculate the spread amount
 * Note: HitSpread is an array so that the damage type can add
 * additional hit directions if appropriate. See melee damage types.
 */
static simulated function AddBloodSpread(KFPawn_Monster InPawn, vector HitDirection, out array<vector> HitSpread, bool bIsDismemberingHit, bool bWasObliterated)
{
	local float RandY, RandZ;
	local rotator BaseRot;
	local vector X, Y, Z;

	if( default.BloodSpread > 0 )
	{
		BaseRot = rotator(HitDirection);
		GetAxes(BaseRot, X, Y, Z);
		RandY = FRand() - 0.5;
		RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
		HitSpread.AddItem(X + RandY*default.BloodSpread*Y + RandZ*default.BloodSpread*Z);
	}
	else
	{
		HitSpread.AddItem(HitDirection);
	}
}

/**
 * Allow damage type to modify the blood scale to be applied
 * (taking into account the damage scale of the hit zone)
 */
static simulated function float GetBloodScale(float HitZoneScale, bool bIsDismemberingHit, bool bWasObliterated)
{
 	return default.BloodScale * HitZoneScale * ((bIsDismemberingHit || bWasObliterated) ? 2.f : 1.f);
}

/**
 * This allows us to customize how much gore damage to apply (for gore fx)
 * independently of the actual damage. It also allows the damage type to attenuate
 * the damage based on distance e.g for shotgun damage
 */
static function float GetGoreDamageScale(vector Location, vector InstigatorLocation)
{
	// For killing shots, scale the gore damage by the scale specified in the hit zone
	return 1.f;
}

/** Multiplied with 'GetGoreDamageScale' on the killing blow */
static function float GetOnDeathGoreScale()
{
	return 3.f;
}

/**
 * Allows the damage type to customize exactly which hit zones it can dismember
 */
static simulated function bool CanDismemberHitZone(name InHitZoneName);

/**
* Allows the damage type to customize exactly which hit zones it can dismember while the zed is alive
*/
static simulated function bool CanDismemberHitZoneWhileAlive(name InHitZoneName)
{
    return true;
}

/**
 * Allows the damage type to map a hit zone to a different bone for dismemberment purposes.
 * This is used by some melee weapons to get a desired cut/slice effect.
 * NOTE: You do not need to set up this function for each dismemberment type. You only
 * need to do this if you want to dismember a bone that is different than the
 * hitzone -> bone name mapping set up in the HitZones array inside KFPawn.
 */
static simulated function GetBoneToDismember(KFPawn_Monster InPawn, vector HitDirection, name InHitZoneName, out name OutBoneName);

/**
 * Allows the damage type to modify the impulse when a specified hit zone is dismembered
 * @InHitZoneName				 The hit zone that is to be dismembered
 * @InHitZoneName				 The original direction of the hit
 * @OutImpulseDir				 Takes in the hit direction, and can be modified to whatever direction the impulse should be applied in
 * @OutParentImpulseDir			 Takes in the hit direction, and can be modified to whatever direction you want to kick the rest of the body back
 * @OutImpluseScale				 The amount to scale the impule by (based on type of dismemberment)
 * @OutParentImpulseScale		 The amount to scale the parent bone's impule by (based on type of dismemberment). Some melee weapons may set the scale to 0 to simulate a clean "in-place" cinematic cut effect.
 */
static simulated function ModifyDismembermentHitImpulse(KFPawn_Monster InPawn, name InHitZoneName, vector HitDirection,
												out vector OutImpulseDir, out vector OutParentImpulseDir,
												out float OutImpluseScale, out float OutParentImpulseScale);


/**
 * Returns the class of the projectile to spawn if the weapon using this damage
 * type can pin a zed when it kills it
 */
static simulated function class<KFProj_PinningBullet> GetPinProjectileClass()
{
    return none;
}

/** Returns ID of dialog event for killer to speak after killing a zed using this damage type */
static function int GetKillerDialogID()
{
	return INDEX_NONE;
}

/** Returns ID of dialog event for damager to speak after damaging a zed using this damage type */
static function int GetDamagerDialogID()
{
	return `DAMZ_Generic;
}

/** Returns ID of dialog event for damagee to speak after getting damaged by a zed using this damage type */
static function int GetDamageeDialogID()
{
	return INDEX_NONE;
}

/** Called when damage is dealt to apply additional damage type (e.g. Damage Over Time) */
static function ApplySecondaryDamage( KFPawn Victim, int DamageTaken, optional Controller InstigatedBy )
{
	if ( default.DoT_Type != DOT_None )
	{
		Victim.ApplyDamageOverTime(DamageTaken, InstigatedBy, default.class);
	}
}

/** Play damage type specific impact effects when taking damage */
static function PlayImpactHitEffects( KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, optional Pawn HitInstigator )
{
	local KFSkinTypeEffects SkinType;

	if ( P.CharacterArch != None && default.EffectGroup < FXG_Max )
	{
		SkinType = P.GetHitZoneSkinTypeEffects( HitZoneIndex );
		if( SkinType != none )
		{
			if( default.OverrideImpactEffect != none )
			{
				P.WorldInfo.MyEmitterPool.SpawnEmitter( default.OverrideImpactEffect, HitLocation, rotator(-HitDirection), P );
			}
			else
			{
				SkinType.PlayImpactParticleEffect(P, HitLocation, HitDirection, HitZoneIndex, default.EffectGroup);
			}

			if ( default.OverrideImpactSound != None )
			{
				P.PlaySoundBase(default.OverrideImpactSound, true,,, HitLocation);
			}
			else
			{
				SkinType.PlayTakeHitSound(P, HitLocation, HitInstigator, default.EffectGroup);
			}
			return;
		}
	}

	// Play overrides even if we had no skin type
	if( default.OverrideImpactEffect != none )
	{
		P.WorldInfo.MyEmitterPool.SpawnEmitter( default.OverrideImpactEffect, HitLocation, rotator(-HitDirection), P );
	}
	if ( default.OverrideImpactSound != None )
	{
		P.PlaySoundBase(default.OverrideImpactSound, true,,, HitLocation);
	}
}

static function bool IsNotPerkBound()
{
	return default.bAnyPerk;
}

/** Test obliterate conditions when taking damage */
static function bool CheckObliterate(Pawn P, int Damage)
{
	return (P.Health <= default.ObliterationHealthThreshold
		&& Damage > default.ObliterationDamageThreshold);

}

/** See if this damagetype should always poison regardless of perk */
static function bool AlwaysPoisons()
{
	return false;
}

/** Do anything related to killing a pawn */
static function ApplyKillResults(KFPawn KilledPawn);

static function bool CanPlayDeadHitEffects()
{
	return default.bCanPlayDeadHitEffects;
}

Defaultproperties
{
	bNoPain=false
	bExtraMomentumZ=false
	bCausesFracture=true
	KDamageImpulse=400
	HeadDestructionDamageScale=1.0
	HeadDestructionImpulseForceScale=1.0
	ImpulseOriginScale=50.0
	GibImpulseScale=0.1

	BloodSpread=0.0
	BloodScale=1.0
	BodyWoundDecalWidth=20
	BodyWoundDecalHeight=20

	EffectGroup=`FXG_NONE
	WeaponDef=None

	bAnyPerk=false;
	bCanObliterate=false;

	bHasToSpawnMicrowaveFire=true

	DamageModifierAP=0.f

	bCanPlayDeadHitEffects=true

	bCanZedTime=true
	bCanEnrage=true

	bCanApplyRadialCalculationtoAffliction=true
}