//=============================================================================
// KFWeapAttach_HRG_BlastBrawlers
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_HRG_BlastBrawlers extends KFWeapAttach_DualBase;

var protected transient bool  bUsingLeftWeapon;
var protected transient name  ReloadAnimName;
var protected transient float ReloadAnimRateMod;

/** Overrides to prevent weapon animation */
simulated function PlayWeaponFireAnim();

/** Caching reload anim name */
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	ReloadAnimName    = class'KFWeap_HRG_BlastBrawlers'.default.ReloadAnimation;
	ReloadAnimRateMod = class'KFWeap_HRG_BlastBrawlers'.default.ReloadAnimRateModifier;
}

/** Overriding to avoid interrupting meleen anims with fire anims */
simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
    SpawnTracer(GetMuzzleLocation(), HitLocation);

	// Effects below this point are culled based on visibility and distance
	if ( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	CauseMuzzleFlash(P.FiringMode);
	P.LastWeaponFireTime = -1.f;

	return true;
}

simulated function vector GetMuzzleLocation(optional byte MuzzleID)
{
	local vector SocketLocation;

	if ( bUsingLeftWeapon)
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

/** Added second weapon */
simulated function CauseMuzzleFlash(byte FiringMode)
{
	if ( bUsingLeftWeapon )
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
		bUsingLeftWeapon = true;
	}
}

simulated function UpdateThirdPersonWeaponAction(EWeaponState NewWeaponState, KFPawn P, byte ThirdPersonAnimRateByte )
{
	// Reset
	bUsingLeftWeapon=false;
	super.UpdateThirdPersonWeaponAction(NewWeaponState, P, ThirdPersonAnimRateByte);
}

simulated function PlayReloadMagazineAnim(EWeaponState NewWeaponState, KFPawn P)
{
	PlayCharacterMeshAnim(P, ReloadAnimNAme, true);
}

simulated function PlayWeaponMeshAnim(name AnimName, AnimNodeSlot SyncNode, bool bLoop)
{
	local float Duration;

	/** Only reload animation could be played */
	if ( !IsAnimationValid(AnimName) )
		return;

	// Weapon shoot anims
	if( !bWeapMeshIsPawnMesh )
	{
		Duration = WeapMesh.GetAnimLength(AnimName);
		
		if (AnimName == ReloadAnimName)
		{
			Duration *= ReloadAnimRateMod;
		}

		WeapMesh.PlayAnim(AnimName, Duration / ThirdPersonAnimRate, bLoop);

		// syncronize this with the character anim
		if ( SyncNode != None )
		{
			bSynchronizeWeaponAnim = true;
			SyncPawnNode = SyncNode;
			SyncAnimName = AnimName;
			bSyncAnimCheckRelevance = false;
		}
	}
}

simulated function bool IsAnimationValid(name AnimName)
{
	return AnimName == ReloadAnimName;
}

defaultproperties
{
	bUsingLeftWeapon=false
}
