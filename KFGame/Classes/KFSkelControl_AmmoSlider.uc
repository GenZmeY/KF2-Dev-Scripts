//=============================================================================
// KFSkelControl_AmmoSlider
//=============================================================================
// Controller used by 1st person weapon to adjust based on ammo percentage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// -- Andrew "Strago" Ladenberger
//=============================================================================

class KFSkelControl_AmmoSlider extends SkelControlSingleBone
	hidecategories(Translation, Rotation)
	native(Anim);

/** Bone translation used when the weapon is empty. */
var() vector	MaxBoneTranslation;
/** Time it takes for slider to move (UU/sec) */
var() float		BoneInterpInSpeed;
/** Time it takes for slider to move (UU/sec) */
var() float		BoneInterpOutSpeed;

/** Cached Weapon */
var transient KFWeapon WeaponOwner;

cpptext
{
	virtual void TickSkelControl(FLOAT DeltaSeconds, USkeletalMeshComponent* SkelComp);
	//FLOAT CalcWeaponTiltWeight(APawn* P);
}

defaultproperties
{
	bApplyTranslation=true
	bApplyRotation=false
	BoneTranslationSpace=BCS_BoneSpace
	bIgnoreWhenNotRendered=true
	
	// handle blending in our tick
	BlendInTime=0.0
	BlendOutTime=0.0

	BoneInterpInSpeed=5.f
	BoneInterpOutSpeed=5.f
}