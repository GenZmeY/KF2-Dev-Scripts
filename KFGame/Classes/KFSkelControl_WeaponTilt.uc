//=============================================================================
// KFAnimNotify_ViewShake
//=============================================================================
// Controller used by 1st person weapon to tilt based on player movement
// -- see UDKSkelControl_Rotate and GearSkelCtrl_Copy
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// -- Andrew "Strago" Ladenberger
//=============================================================================

class KFSkelControl_WeaponTilt extends SkelControlSingleBone
	hidecategories(Translation,Rotation)
	native(Anim);

/** Where we wish to get to */
var() rotator	WeaponBoneRotation;
/** Cosine of angle to ignore strafing motion */
var() float		StrafeDeadzoneCos;

/** The rate we wish to rotate */
var transient float	BoneRotationRate;
/** Cached Weapon */
var transient KFWeapon WeaponOwner;

cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	FLOAT CalcWeaponTiltWeight(APawn* P);
}

defaultproperties
{
	bApplyTranslation=false
	bApplyRotation=true
	bAddRotation=true
	BoneRotationSpace=BCS_ActorSpace
	bIgnoreWhenNotRendered=true
	
	BlendInTime=0.1
	BlendOutTime=0.1

	WeaponBoneRotation=(Roll=1820)
	StrafeDeadzoneCos=0.5f
}