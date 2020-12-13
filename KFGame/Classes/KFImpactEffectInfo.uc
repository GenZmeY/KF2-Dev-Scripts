//=============================================================================
// KFImpactEffectInfo
//=============================================================================
// Class that stores the content references for impact effects
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFImpactEffectInfo extends Object
	dependson(KFPhysicalMaterialProperty)
	hidecategories(Object)
	editinlinenew;

/** struct for list to map material types supported by an actor to impact sounds and effects */
struct immutablewhencooked MaterialImpactEffect
{
	var() EMaterialTypes MaterialType;
	/** Sound to play for this impact **/
	var() AkBaseSoundObject Sound;
	/** AKEvent to play when stopping this sound, used for looping sound impacts like fire **/
	var() AkBaseSoundObject StopSoundEvent;
	var() ParticleSystem ParticleTemplate;

	var() array<MaterialInterface> DecalMaterials;
	/** MaterialInstance param name for dissolving the decal **/
	var() name DecalDissolveParamName;
	/** How long the decal should last before fading out **/
	var() float DecalDuration;
	/** Uniform scale between MIN/MAX, rather than Width and Height */
	var() float DecalMinSize<ClampMin=8.0 | ClampMax=256.0>;
	var() float DecalMaxSize<ClampMin=8.0 | ClampMax=256.0>;
	/** Don't randomely rotate this decal */
	var() bool bNoDecalRotation;

	StructDefaultProperties
	{
		DecalDuration=24.0
		DecalDissolveParamName="DissolveAmount"
		DecalMinSize=16.0
		DecalMaxSize=16.0
	}
};

/** impact effects by material type */
var() array<MaterialImpactEffect> ImpactEffects;

/** default impact effect to use if a material specific one isn't found */
var() MaterialImpactEffect DefaultImpactEffect;

/** sound that is played when the bullets go whizzing past your head */
var() AkEvent BulletWhipSnd;

/** If true, make splash effect for local player when hit water */
var() bool bMakeSplash;
var() ParticleSystem SplashEffectTemplate<EditCondition=bMakeSplash>;

/** List of particles that play for any impact material type */
var() array<ParticleSystem> GlobalImpactEffectEffects;

defaultproperties
{
}
