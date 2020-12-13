//=============================================================================
// KFWeapAttach_Minigun
//=============================================================================
// A custom 3rd person weapon template for the Minigun
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_Minigun extends KFWeaponAttachment
	native;

/* Custom anim tree with the control of the rotation of the barrel */
var AnimTree CustomAnimTree;

/* Flag that indicates that the minigun is in warming up */
var bool bWindUpModeActive;

/* The minigun is winded up and ready to fire */
var bool bWindUpReady;

/* Time used to wind up the weapon (also acts as the cooldown) */
var float WindUpActivationTime;

/* Control variable to check the current state of the wind up */
var transient float WindUpControlTime;

/* Rotation speed of the barrel when fully warmed up*/
var float WindUpRotationSpeed;

var CylinderRotationInfo CylinderRotInfo;

cpptext
{
	// cylinder is incrementally rotated
	virtual void TickSpecial( FLOAT DeltaSeconds );
};

// updates the cylynder rotation in Tick Special
native simulated function UpdateCylinderRotation( out CylinderRotationInfo RotInfo, float Degrees );

event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	// Override the animtree.  Doing this here (before AttachTo) instead of in defaultprops 
	// avoids an undesired call to our owning Pawn's PostInitAnimTree
	if ( CustomAnimTree != None )
	{
		WeapMesh.SetAnimTreeTemplate(CustomAnimTree);
		WeapAnimNode = AnimNodeSequence(AnimTree(WeapMesh.Animations).Children[0].Anim);
		CylinderRotInfo.Control = SkelControlSingleBone( WeapMesh.FindSkelControl('CylinderControl') );
		if( CylinderRotInfo.Control != none )
		{
			CylinderRotInfo.Control.SetSkelControlActive( true );
		}
	}
}

simulated function UpdateWindUp(bool bActive)
{
	bWindUpModeActive = bActive;
}

defaultproperties
{
	// Wind Up variables
	WindUpActivationTime=0.7
	WindUpRotationSpeed=200

	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		bForceRefPose=0
	End Object

	CustomAnimTree=AnimTree'WEP_Minigun_ARCH.WEP_Animtree_Minigun_3p'

	bHasLaserSight=false
}
