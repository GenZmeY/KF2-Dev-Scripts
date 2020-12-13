//=============================================================================
// KFGoreJointInfo
//=============================================================================
// Describes gore behavior for the specified hit bone.
// NOTE: A lot of struct properties are repeated for the sake of future extensibility.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Sakib Saikia 5/28/2014
//=============================================================================

class KFGoreJointInfo extends Object
	hidecategories(Object)
	editinlinenew;

/** Settings to map each dismembered or gibbed bone to its blood jet effect
	NOTE: Struct propertis are identical to the BloodTrailSettings struct but
	is deliberately duplicated so that it can be extensible if future needs arise.
 */
struct BloodJetSettings
{
	/** Whether this attaches to a specific socket. Otherwise, it will attach to
		the parent bone of the dismembered bone */
	var() bool bAttachToSocket;
	/** Socket name if bAttachToSocket is TRUE */
	var() name SocketName<EditCondition=bAttachToSocket>;
	/** The particle system to use */
	var() ParticleSystem ParticleSystemTemplate;
	/** If specified, constrain the template the specific damage groups only */
	var() array<EGoreDamageGroup> ConstrainToDamageGroups;
};

/** Settings related to blood trails for this bone
	NOTE: Struct properties are identical to the BloodJetSettings struct but is
	deliberately duplicated so that it can be extensible if future needs arise.
 */
struct BloodTrailSettings
{
	/** Whether this attaches to a specific socket. Otherwise, it will attach to the dismembered bone */
	var() bool bAttachToSocket;
	/** Socket name if bAttachToSocket is TRUE */
	var() name SocketName<EditCondition=bAttachToSocket>;
	/** The particle system to use */
	var() ParticleSystem ParticleSystemTemplate;
	/** If specified, constrain the template the specific damage groups only */
	var() array<EGoreDamageGroup> ConstrainToDamageGroups;
};

/** Settings for a single partial gore bone */
struct PartialBreakBone
{
	/** Name of the bone to be shrunk */
	var() name BoneName;
	/** Blood jet to attach to the parent of the partial break bone */
	var() editinline array<BloodJetSettings> BloodJets;
	/** Name of the blood parameter to activate when the bone is dismembered or gibbed */
	var() array<name> BloodMICParamName;
	/** Particle effect to be spawned for this partial break.
		Note: This is different from the blood jet */
	var() ParticleSystem ParticleSystemTemplate;
};

/** Settings related to bone shrink gore (partial gore) */
struct PartialBreakSettings
{
	/** List of child bones that can be shrunk when the bone is hit. If the array contains
		more than 1 bone, the bone that is closest to the HitBone will be selected */
	var() editinline array<PartialBreakBone> PartialBreakBones<DisplayName=Shrink Bones>;
	/** If specified, constrain partial break to the specific damage groups only.
		Otherwise, all damage types can cause this partial break. */
	var() array<EGoreDamageGroup> ConstrainToDamageGroups;
	/** Additional DamageGroups that can cause this break only on the killing blow */
	var() array<EGoreDamageGroup> KillingBlowDamageGroups;
};

/** Settings for a single explosion break bone */
struct ExplosionBreakBone
{
	/** Name of the bone to be dismembered */
	var() name BoneName;
	/** Blood jet to attach to the parent of the dismembered bone */
	var() editinline array<BloodJetSettings> BloodJets;
	/** Blood trails to attach to the dismembered bone */
	var() array<BloodTrailSettings> BloodTrails;
	/** Name of the blood parameter to activate when the bone is gibbed */
	var() array<name> BloodMICParamName;
};

/** Settings related to hit explosion gore
	NOTE: Struct properties are identical to the DependentBreakSettings struct but
	is deliberately duplicated so that it can be extensible if future needs arise.
 */
struct ExplosionBreakSettings
{
	/** List of constraints that will be broken on an explosion. ALL of the break
		bones will be dismembered */
	var() array<ExplosionBreakBone> BreakBones<DisplayName=Break Bones>;
	/** Particle effect to be spawned. The effect will be spawned at the location
	of the hit bone that triggered this explosion */
	var() ParticleSystem ParticleSystemTemplate;
	/** If specified, constrain explosion to the specific damage groups only.
		Otherwise, all damage types can cause this explosion. */
	var() array<EGoreDamageGroup> ConstrainToDamageGroups;
};

/** Settings for a single dependent gore bone */
struct DependentBreakBone
{
	/** Name of the bone to be dismembered */
	var() name BoneName;
	/** Blood jet to attach to the parent of the dismembered bone */
	var() editinline array<BloodJetSettings> BloodJets;
	/** Blood trails to attach to the dismembered bone */
	var() array<BloodTrailSettings> BloodTrails;
	/** Name of the blood parameter to activate when the bone is dismembered or gibbed */
	var() array<name> BloodMICParamName;
	/** Particle effect to be spawned specifically for this dependent break */
	var() ParticleSystem ParticleSystemTemplate;
};

 /** List of joints that are broken when the bone is dismembered
 	NOTE: Struct properties are identical to the ExplosionBreakSettings struct but
	is deliberately duplicated so that it can be extensible if future needs arise.
 */
struct DependentBreakSettings
{
	/** List of bones that need to get broken due to dependency */
	var() editinline array<DependentBreakBone> DependentBones;
	/** If specified, constrain dependant breaks to the specific damage groups only */
	var() array<EGoreDamageGroup> ConstrainToDamageGroups;
};

/** Special effects to be played when a joint is dismembered */
struct DismembermentEffect
{
	/** Particle effect to be spawned */
	var() ParticleSystem ParticleSystemTemplate;
	/** If specified, constrain effect to the specific damage groups only */
	var() array<EGoreDamageGroup> ConstrainToDamageGroups;
};

/** Name of the bone that was hit (as per the hit detection system).
You only set up the bones that correspond to a hit zone in a physics asset.
ALL the hit zone bones must be set up here even if they don't dismember. */
var() name HitBoneName;
/** If TRUE, the joint cannot be dismembered. This applies to gibbing due to an explosion as well. */
var(PrimaryDismemberment) bool bNonBreakableJoint;
/** Use to specify bone shrinking gore */
var(AuxiliaryDismemberment) array<PartialBreakSettings> BoneShrinkGore;
/** Use to specify explosion effects for characters (such as the bloat) that
explode on death even when hit by a non-explosive weapon */
var(AuxiliaryDismemberment) array<ExplosionBreakSettings> HitExplosionGore;
/** Use to specify joints that have dependencies that need to be respected when breaking the mesh */
var(AuxiliaryDismemberment) array<DependentBreakSettings> DependentBreakGore;
/** Use to specify blood jet effects for this bone.
Blood jets are attached to the parent of the dismembered bone or a specified socket thereof. */
var(PrimaryDismemberment) array<BloodJetSettings> BloodJets;
/** Use to specify blood trail effects for this bone.
Blood trails are attached to the dismembered bone or a specified socket thereof. */
var(PrimaryDismemberment) array<BloodTrailSettings> BloodTrails;
/** Name of the blood parameter(s) to activate when the bone is dismembered or gibbed.
This is used to add a blood overlay to the dismembered mesh. */
var(PrimaryDismemberment) array<name> BloodMICParamName;
/** Particle effect settings when the bone is dismembered.
The effect is played at the location of the dismembered bone */
var(PrimaryDismemberment) array<DismembermentEffect> DismembermentEffects;
