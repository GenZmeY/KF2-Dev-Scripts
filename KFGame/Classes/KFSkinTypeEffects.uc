//=============================================================================
// KFSkinTypeEffects
//=============================================================================
// Defines content used for hit effects based on surface (e.g. Skin type),
// as well as damage type (aka EffectDamageGroup).
//
// Similar to the KFImpactEffectInfo and PhysicalMaterial system,
// but specifically tailored to characters rather than world.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFSkinTypeEffects extends Object
	hidecategories(Object)
	config(Engine)
	native(Effect);

/** Abstracted DamageType categories useful for effect types */
enum EEffectDamageGroup
{
	FXG_Ballistic,
	FXG_Bludgeon,
	FXG_Piercing,
	FXG_Slashing,
	FXG_Fire,
	FXG_Toxic,
	FXG_Healing,
	FXG_Sawblade,
	FXG_DrainLife,
	FXG_IncendiaryRound,
	FXG_UnexplodedGrenade,
	FXG_MicrowaveBlast,
	FXG_ShieldBash,
	FXG_MetalMace,
    FXG_Flare,
	FXG_Freeze,
	FXG_Bludgeon_Chains,
	FXG_MicrowaveProj,
	FXG_Electricity,
	FXG_Slashing_Ion,
	FXG_Energy_Yellow,
	FXG_Energy_Magenta
};
const FXG_MAX = 22; //!! Update me when the enum gets modified !!

struct native SkinEffectInfo
{
	/** type for readability in editor */
	var() editoronly editconst EEffectDamageGroup Type;

	/** particle system used for this impact */
	var() ParticleSystem DefaultParticle;

	/** If true, attach particle to the hit bone (e.g. fire) */
	var() bool bAttachParticle<DisplayName=Attach FX To Hit Bone | EditCondition=!bAttachToHitLocation>;
	/** If true, attach particle to hit bone but offset to the location of the hit (e.g. electricity) */
	var() bool bAttachToHitLocation<DisplayName=Attach FX to Hit Location | EditCondition=!bAttachParticle>;

	/** Sound used for this impact */
	var() AkEvent DefaultSound;
	/** Sounds used for local player (1st person) impacts only */
	var() AKEvent LocalSound;
	/** Sound played when I'm the one taking damage */
	var() AkEvent LocalTakeHitSound;
};

/** Container for effects per type of damage/weapon */
var() SkinEffectInfo ImpactFXArray[FXG_MAX];

/** Dynamic container for additional modability */
var() array<SkinEffectInfo> CustomEffects;

/** The minimum time between mesh attached impact particle effect (optimization) */
var config float ImpactParticleEffectInterval; // Default=0.5
/** The minimum time between mesh attached impact sound (optimization) */
var float ImpactSoundInterval;

//-----------------------------------------------------------------------------
// cpptext.

cpptext
{
	/** Set default info for new ImpactFXArray entries */
	virtual void PostLoad();
}

function PlayImpactParticleEffect(KFPawn P, vector HitLocation, vector HitDirection, byte HitZoneIndex, EEffectDamageGroup EffectGroup, optional ParticleSystem ForceParticleTemplate)
{
	local ParticleSystem ParticleTemplate;
	local name HitBoneName;

	if (ForceParticleTemplate != none)
	{
		ParticleTemplate = ForceParticleTemplate;
	}
	else
	{
		ParticleTemplate = GetImpactParticleEffect(EffectGroup);
	}

	if (ParticleTemplate == None)
	{
		return;
	}

	if (ConfigureEmitter(P, HitLocation, HitDirection, HitZoneIndex, HitLocation, HitDirection, HitBoneName, EffectGroup))
	{
		SpawnEmitter(P, ParticleTemplate, HitBoneName, HitLocation, HitDirection);
	}
}

function bool ConfigureEmitter(KFPawn P, vector InHitLocation, vector InHitDirection, int HitZoneIndex,
	out vector OutHitLocation, out vector OutHitDirection, out name OutHitBoneName, EEffectDamageGroup EffectGroup)
{
	local int HitBoneIdx;
	local vector HitDirectionRight, HitDirectionLeft, RelativeHitDirection;

	if (ImpactFXArray[EffectGroup].bAttachParticle) // Spawn effect and attach to bone
	{
		// make sure enough time passes between spawning emitters
		if (`TimeSinceEx(P, P.LastImpactParticleEffectTime) < ImpactParticleEffectInterval)
		{
			return false;
		}

		OutHitBoneName = (HitZoneIndex < P.HitZones.Length) ?
			P.HitZones[HitZoneIndex].BoneName :
			P.TorsoBoneName;
		OutHitLocation = vect(0,0,0);
	}
	else if (ImpactFXArray[EffectGroup].bAttachToHitLocation) // Spawn effect and attach to bone with offset
	{
		if (HitZoneIndex >= P.HitZones.Length)
		{
			return false;
		}

		// make sure enough time passes between spawning emitters
		if (`TimeSinceEx(P, P.LastImpactParticleEffectTime) < ImpactParticleEffectInterval)
		{
			return false;
		}

		OutHitBoneName = P.HitZones[HitZoneIndex].BoneName;
		HitBoneIdx = P.Mesh.MatchRefBone(OutHitBoneName);
		OutHitLocation = InverseTransformVector(P.Mesh.GetBoneMatrix(HitBoneIdx), InHitLocation);
	}
	else // Spawn effect, no attachment
	{
		// Don't spawn more than one effect per frame if on low detail
		if( P.WorldInfo.bDropDetail || P.WorldInfo.GetDetailMode() == DM_Low )
		{
			if( `TimeSinceEx(P, P.LastImpactParticleEffectTime) == 0 )
			{
				return false;
			}
		}

		switch (EffectGroup)
		{
		case FXG_Bludgeon:
		case FXG_Piercing:
		case FXG_Slashing:
		case FXG_SawBlade:
			OutHitDirection = -InHitDirection;
			break;
		default:
			InHitDirection.Z = 0.f;
			HitDirectionRight = InHitDirection cross vect(0,0,1);
			HitDirectionLeft = -HitDirectionRight;
			RelativeHitDirection = InHitLocation - P.Location;
			OutHitDirection = HitDirectionRight dot RelativeHitDirection >= 0 ? HitDirectionRight : HitDirectionLeft;
			break;
		}
	}

	return true;
}

function ParticleSystemComponent SpawnEmitter(
	KFPawn P, ParticleSystem ParticleTemplate, optional name HitBoneName,
	optional vector HitLocation, optional vector HitDirection)
{
	local ParticleSystemComponent PSC;

	if (HitBoneName != `NAME_None)
	{
		PSC = P.WorldInfo.ImpactFXEmitterPool.SpawnEmitterMeshAttachment(
			ParticleTemplate, P.Mesh, HitBoneName, false, HitLocation, rotator(HitDirection));

		// Make the particle system ignore bone rotation
		if (PSC != none)
		{
			PSC.SetAbsolute(false, true, true);
		}
	}
	else
	{
		PSC = P.WorldInfo.ImpactFXEmitterPool.SpawnEmitter(ParticleTemplate, HitLocation, rotator(HitDirection));
		if (PSC != none)
		{
			PSC.SetLightingChannels(P.PawnLightingChannel);
		}
	}

	if (PSC != none)
	{
		P.LastImpactParticleEffectTime = P.WorldInfo.TimeSeconds;
	}

	return PSC;
}

/** returns the impact particle that should be played */
function ParticleSystem GetImpactParticleEffect(EEffectDamageGroup EffectGroup)
{
	return ImpactFXArray[EffectGroup].DefaultParticle;
}

/** Play an impact sound on taking damage */
function PlayTakeHitSound(KFPawn P, vector HitLocation, Pawn DamageCauser, EEffectDamageGroup EffectGroup, optional AKEvent ForceImpactSound)
{
	local AKEvent ImpactSound;
	local float ArmorPct;

	if ( P.ActorEffectIsRelevant(DamageCauser, false, 4000.f) )
	{
		// make sure enough time passes between playing sounds
		if( `TimeSinceEx(P, P.LastImpactSoundTime) < ImpactSoundInterval )
		{
			return;
		}

		if (ForceImpactSound != none)
		{
			ImpactSound = ForceImpactSound;
		}
		else
		{
			ImpactSound = GetImpactSound(EffectGroup, DamageCauser, P);
		}

		if (ShouldSetArmorValue(P, ArmorPct))
		{
			P.Controller.SetRTPCValue('Armor_Level', ArmorPct, true);
		}

		if( ImpactSound != none )
		{
			P.LastImpactSoundTime = P.WorldInfo.TimeSeconds;
			P.PlaySoundBase(ImpactSound, true,,, HitLocation);
		}
	}
}

/** returns the impact sound that should be played */
function AkEvent GetImpactSound(EEffectDamageGroup EffectGroup, Pawn DamageCauser, Pawn HitPawn)
{
	// handle local player sounds
	if ( ImpactFXArray[EffectGroup].LocalSound != None && DamageCauser != none
		&& DamageCauser.IsLocallyControlled() && DamageCauser.IsHumanControlled() )
	{
		return ImpactFXArray[EffectGroup].LocalSound;
	}
	else if (HitPawn.Controller != none && HitPawn.Controller.IsLocalController() && ImpactFXArray[EffectGroup].LocalTakeHitSound != none)
	{
		return ImpactFXArray[EffectGroup].LocalTakeHitSound;
	}

	return ImpactFXArray[EffectGroup].DefaultSound;
}

function bool ShouldSetArmorValue(Pawn HitPawn, out float ArmorPct)
{
	local KFPawn_Human KFPH;

	KFPH = KFPawn_Human(HitPawn);
	if (KFPH != none && KFPH.Controller != none && KFPH.Controller.IsLocalController() && KFPH.Armor > 0)
	{
		ArmorPct = float(KFPH.Armor) / float(KFPH.MaxArmor);
		return true;
	}

	return false;
}

defaultproperties
{
	//ImpactParticleEffectInterval=0.5
	ImpactSoundInterval=0.05
}

