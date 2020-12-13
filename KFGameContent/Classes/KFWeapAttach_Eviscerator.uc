//=============================================================================
// KFWeapAttach_Eviscerator
//=============================================================================
// A custom 3rd person weapon template for the eviscerator
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_Eviscerator extends KFWeaponAttachment;

var AnimTree CustomAnimTree;

const WeaponShoot = 'Shoot';

event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	// Override the animtree.  Doing this here (before AttachTo) instead of in defaultprops 
	// avoids an undesired call to our owning Pawn's PostInitAnimTree
	if ( CustomAnimTree != None )
	{
		WeapMesh.SetAnimTreeTemplate(CustomAnimTree);
		WeapAnimNode = AnimNodeSequence(AnimTree(WeapMesh.Animations).Children[0].Anim);
	}
}

/** Custom firing animations */
simulated function bool ThirdPersonFireEffects(vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local float Duration;

	if( Super.ThirdPersonFireEffects(HitLocation, P, ThirdPersonAnimRateByte) )
	{
		Duration = WeapMesh.GetAnimLength( WeaponShoot );
		WeapMesh.PlayAnim( WeaponShoot, Duration / ThirdPersonAnimRate );
		return true;
	}

	return false;
}

defaultproperties
{
	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		bForceRefPose=0
	End Object

	CustomAnimTree=AnimTree'WEP_SawBlade_ARCH.3P_Sawblade_Animtree'
	
	bHasLaserSight=TRUE
}
