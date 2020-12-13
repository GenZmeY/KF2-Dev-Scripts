//=============================================================================
// KFWeapAttach_DualBase
//=============================================================================
// Attachment with a second set of meshes/FX for dual weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_DualBase extends KFWeaponAttachment;

/*********************************************************************************************
 * Left-hand weapon components
********************************************************************************************* */

/** Left hand skeletal mesh. If none is specified, the right hand skeletal mesh will be duplicated. */
var() const SkeletalMesh 						LeftHandSkelMesh;
/** Anim set to use for 3rd person weapon anims */
var() AnimSet 									LeftWeaponAnimSet;
var protected transient SkeletalMeshComponent	LeftWeapMesh;
var protected transient KFMuzzleFlash			LeftMuzzleFlash;
/** A reference to the left muzzle flash template (to specify left shell eject socket) */
var() protected const KFMuzzleFlash 			LeftMuzzleFlashTemplate;
var protected transient AnimNodeSequence		LeftWeapAnimNode;

/** Toggled when switching from right to left hand weapons */
var transient bool bPlayFXOnSecondWeapon;
/** Last world time bPlayFXOnSecondWeapon was set */
var transient float LastChooseWeaponTime;

/** Additive shoot anims */
const ShootLeftAnim		= 'ADD_Shoot_LW';
const ShootRightAnim	= 'ADD_Shoot_RW';
const CrouchShootLeftAnim	= 'ADD_CH_Shoot_LW';
const CrouchShootRightAnim	= 'ADD_CH_Shoot_RW';
const IronShootLeftAnim		= 'ADD_Iron_Shoot_LW';
const IronShootRightAnim	= 'ADD_Iron_Shoot_RW';

/** Weapon shoots */
// @todo: these should just be "Shoot", but the animsets for each gun have both anims
const WeaponFireAnim_R		= 'Shoot_RW';
const WeaponFireAnim_L		= 'Shoot_LW';
const WeaponAltFireAnim_R	= 'Shoot_RW';
const WeaponAltFireAnim_L	= 'Shoot_LW';

const LeftWeaponSocket	= 'LW_Weapon';

event PreBeginPlay()
{
	// set up left hand skel mesh just like we do the right in super
	if ( LeftWeapMesh != None && !bWeapMeshIsPawnMesh )
	{
		if ( LeftWeaponAnimSet != None )
		{
			LeftWeapMesh.AnimSets[0] = LeftWeaponAnimSet;
		}
		else if( WeaponAnimSet != None )
		{
			// default to right weapon anim set
			LeftWeapMesh.AnimSets[0] = WeaponAnimSet;
		}

		if ( LeftHandSkelMesh != none )
		{
			// set the skeletal mesh from our archetype to the WeaponAttachment
			LeftWeapMesh.SkeletalMesh = LeftHandSkelMesh;
		}

		LeftWeapAnimNode = AnimNodeSequence(LeftWeapMesh.Animations);
	}

 	super.PreBeginPlay();
}

/** Weapon Mesh Attachment */
event ChangeVisibility( bool bIsVisible )
{
	super.ChangeVisibility( bIsVisible );

	if( LeftWeapMesh != none && !bWeapMeshIsPawnMesh )
	{
		LeftWeapMesh.SetHidden( !bIsVisible );
	}
}

/*********************************************************************************************
 * Attach / Detach
********************************************************************************************* */

/** Added second weapon */
simulated function AttachTo(KFPawn P)
{
    Super.AttachTo(P);

    if ( bWeapMeshIsPawnMesh )
    {
        LeftWeapMesh = P.Mesh;
    }
    else if ( LeftWeapMesh != None )
    {
        if( LeftHandSkelMesh == none )
        {
            // Create a duplicate of the right-hand weapn mesh
            LeftWeapMesh = new(self) Class'SkeletalMeshComponent'(WeapMesh);
        }

        // Attach Weapon mesh to player skel mesh
        LeftWeapMesh.SetShadowParent(P.Mesh);
        P.Mesh.AttachComponent(LeftWeapMesh, LeftWeaponSocket);
    }

    //Do a first chance weapon skin switch (EX: changed weapon w/o ID changing by throwing a dualie)
    if (KFPawn_Human(P) != None && KFPawn_Human(P).WeaponSkinItemId > 0)
    {
        SetWeaponSkin(KFPawn_Human(P).WeaponSkinItemId);
    }
}

/** Added second weapon */
simulated function DetachFrom(KFPawn P)
{
	Super.DetachFrom(P);

	// first, detach FX
	if ( LeftMuzzleFlash != None )
	{
        LeftMuzzleFlash.DetachMuzzleFlash(LeftWeapMesh);
	}

	// detach weapon mesh from player skelmesh
	if ( bWeapMeshIsPawnMesh )
	{
		LeftWeapMesh = None;
	}
	else if ( LeftWeapMesh != None )
	{
		LeftWeapMesh.SetShadowParent(None);
		P.Mesh.DetachComponent(LeftWeapMesh);
	}
}

/** Added second weapon */
simulated function AttachMuzzleFlash()
{
	Super.AttachMuzzleFlash();

	if ( WeapMesh != none && LeftMuzzleFlash == None )
	{
		LeftMuzzleFlash = new(self) Class'KFMuzzleFlash'(LeftMuzzleFlashTemplate);
        LeftMuzzleFlash.AttachMuzzleFlash(LeftWeapMesh);
	}
}

/**
 * Assign weapon skin to 3rd person mesh
 */
event SetWeaponSkin(int ItemId, optional bool bFinishedLoading = false)
{
	local array<MaterialInterface> SkinMICs;

	if ( WeapMesh != none && LeftWeapMesh != none && ItemId > 0 && WorldInfo.NetMode != NM_DedicatedServer && !bWaitingForWeaponSkinLoad)
	{
		if (!bFinishedLoading && StartLoadWeaponSkin(ItemId))
		{
			return;
		}

		SkinMICs = class'KFWeaponSkinList'.static.GetWeaponSkin(ItemId, WST_ThirdPerson);
		if ( SkinMICs.Length > 0 )
		{
			WeapMesh.SetMaterial(0, SkinMICs[0]);
			LeftWeapMesh.SetMaterial(0, SkinMICs[0]);
		}
	}
}

/*********************************************************************************************
* Fire Effects
********************************************************************************************* */

/** Updates bPlayFXOnSecondWeapon each time weapon is fired */
function bool ChooseActiveWeapon(byte FlashCount)
{
	// If this was already called in this frame do nothing.  See GetProjectileStartLoc() for details.
	if ( LastChooseWeaponTime == WorldInfo.TimeSeconds )
	{
		return bPlayFXOnSecondWeapon;
	}

	if ( FlashCount > 0 )
	{
		// If we have a flash count (e.g. projectile) use that to synchronize with 1st P
		bPlayFXOnSecondWeapon = (FlashCount & 1) == 0;
	}
	else
	{
		// Otherwise just toggle it
		bPlayFXOnSecondWeapon = !bPlayFXOnSecondWeapon;
	}

	LastChooseWeaponTime = WorldInfo.TimeSeconds;
	return bPlayFXOnSecondWeapon;
}

/** Added second weapon */
simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	ChooseActiveWeapon(P.FlashCount);
    return super.ThirdPersonFireEffects( HitLocation, P, ThirdPersonAnimRateByte );
}

/** Plays fire animation on weapon mesh.
  * Overloaded to switch between right and left.
  */
simulated function PlayWeaponFireAnim()
{
	local float Duration;

	if( Instigator.FiringMode == 1 && WeaponAltFireAnim != 'None' )
	{
		if( bPlayFXOnSecondWeapon )
		{
			Duration = LeftWeapMesh.GetAnimLength( WeaponAltFireAnim_L );
			LeftWeapMesh.PlayAnim( WeaponAltFireAnim_L, Duration / ThirdPersonAnimRate,, true );
		}
		else
		{
			Duration = WeapMesh.GetAnimLength( WeaponAltFireAnim_R );
			WeapMesh.PlayAnim( WeaponAltFireAnim_R, Duration / ThirdPersonAnimRate,, true );
		}
	}
	else if( WeaponFireAnim != 'None' )
	{
		if( bPlayFXOnSecondWeapon )
		{
			Duration = LeftWeapMesh.GetAnimLength( WeaponFireAnim_L );
			LeftWeapMesh.PlayAnim( WeaponFireAnim_L, Duration / ThirdPersonAnimRate,, true );
		}
		else
		{
			Duration = WeapMesh.GetAnimLength( WeaponFireAnim_R );
			WeapMesh.PlayAnim( WeaponFireAnim_R, Duration / ThirdPersonAnimRate,, true );
		}
	}
}

/** Plays fire animation on pawn
  * Overloaded to switch between right and left.
  */
simulated function PlayPawnFireAnim( KFPawn P, EAnimSlotStance AnimType )
{
	if ( P.bIsCrouched )
	{
		P.PlayBodyAnim((bPlayFXOnSecondWeapon) ? CrouchShootLeftAnim : CrouchShootRightAnim, EAS_FullBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
	else if ( P.bIsWalking )
	{
		P.PlayBodyAnim((bPlayFXOnSecondWeapon) ? IronShootLeftAnim : IronShootRightAnim, EAS_FullBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
	else
	{
		P.PlayBodyAnim((bPlayFXOnSecondWeapon) ? ShootLeftAnim : ShootRightAnim, EAS_FullBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
}

/** Added second weapon */
simulated function CauseMuzzleFlash(byte FiringMode)
{
	// Can use the same weapon that was used by ThirdPersonFireEffects
	if ( bPlayFXOnSecondWeapon )
	{
		if (LeftMuzzleFlash == None && MuzzleFlashTemplate != None)
		{
			AttachMuzzleFlash();
		}

		if (LeftMuzzleFlash != None )
		{
			LeftMuzzleFlash.CauseMuzzleFlash(FiringMode);
			if ( LeftMuzzleFlash.bAutoActivateShellEject )
			{
				LeftMuzzleFlash.CauseShellEject();
			}
		}
	}
	else
	{
		Super.CauseMuzzleFlash(FiringMode);
	}
}

/** Added second weapon */
simulated function vector GetMuzzleLocation(optional byte MuzzleID)
{
	local vector SocketLocation;

	if ( MuzzleID >= 1 || bPlayFXOnSecondWeapon )
	{
		if (LeftMuzzleFlash == None && MuzzleFlashTemplate != None)
		{
			AttachMuzzleFlash();
		}

		if( LeftMuzzleFlash != none )
		{
	        LeftWeapMesh.GetSocketWorldLocationAndRotation(LeftMuzzleFlash.GetSocketName(), SocketLocation);
			return SocketLocation;
		}
	}

	return Super.GetMuzzleLocation(MuzzleID);
}

/** Overrides super to play anim on both meshes. Used for reloads at the moment (will this mess up other possible anims?) */
simulated function PlayWeaponMeshAnim(name AnimName, AnimNodeSlot SyncNode, bool bLoop)
{
	local float Duration;

	super.PlayWeaponMeshAnim( AnimName, SyncNode, bLoop );

	Duration = LeftWeapMesh.GetAnimLength( AnimName );
	LeftWeapMesh.PlayAnim( AnimName, Duration / ThirdPersonAnimRate, bLoop );
}

/*********************************************************************************************
 * @name	Rendering/Lighting
********************************************************************************************* */

/** Set the lighting channels on all the appropriate weapon attachment mesh(es) */
simulated function SetMeshLightingChannels(LightingChannelContainer NewLightingChannels)
{
	super.SetMeshLightingChannels( NewLightingChannels );

	if( !bWeapMeshIsPawnMesh )
	{
		LeftWeapMesh.SetLightingChannels(NewLightingChannels);
	}
}

/** Debug */
simulated function bool HasIndoorLighting()
{
	return super.HasIndoorLighting() && LeftWeapMesh.LightingChannels.Indoor;
}

/** Debug */
simulated function bool HasOutdoorLighting()
{
	return super.HasOutdoorLighting() && LeftWeapMesh.LightingChannels.Outdoor;
}

defaultproperties
{
	// Left Weapon SkeletalMesh (copy of right weapon in super)
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent1
		bOwnerNoSee=true
		bOnlyOwnerSee=false
		CollideActors=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		Animations=MeshSequenceA
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		bForceRefPose=1
		// Default to outdoor. If indoor, this will be set when TWIndoorLightingVolume::Touch() event is received at spawn.
		LightingChannels=(Outdoor=TRUE,bInitialized=TRUE)
	End Object
	LeftWeapMesh=SkeletalMeshComponent1
}
