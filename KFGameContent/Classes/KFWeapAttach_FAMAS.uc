//=============================================================================
// KFWeapAttach_FAMAS
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_FAMAS extends KFWeaponAttachment;

const SecondaryFireAnim                   = 'Shoot_Secondary';
const SecondaryFireAnimCrouch             = 'Shoot_Secondary_CH';
const SecondaryFireIronAnim               = 'Shoot_Secondary_Iron';
const SecondaryFireBodyAnim               = 'ADD_Shoot_Secondary';
const SecondaryFireBodyAnimCH             = 'ADD_Shoot_Secondary_CH';
const SecondaryFireBodyAnimIron           = 'ADD_Shoot_Secondary_Iron';
const SecondaryReloadAnimEmpty            = 'Reload_Secondary_Empty';
const SecondaryReloadAnimEmptyCrouch      = 'Reload_Secondary_Empty_CH';
const SecondaryReloadAnimHalf             = 'Reload_Secondary_Half';
const SecondaryReloadAnimHalfCrouch       = 'Reload_Secondary_Half_CH';
const SecondaryReloadAnimEliteEmpty       = 'Reload_Secondary_Elite_Empty';
const SecondaryReloadAnimEliteEmptyCrouch = 'Reload_Secondary_Elite_Empty_CH';
const SecondaryReloadAnimEliteHalf        = 'Reload_Secondary_Elite_Half';
const SecondaryReloadAnimEliteHalfCrouch  = 'Reload_Secondary_Elite_Half_CH';
const ShotgunMuzzleSocket                 = 'ShotgunMuzzleFlash';

var protected transient KFMuzzleFlash ShotgunMuzzleFlash;


/** Play a 3rd person reload animation */
simulated function PlayReloadMagazineAnim(EWeaponState NewWeaponState, KFPawn P)
{
	local name AnimName;

	switch (NewWeaponState)
	{

	case WEP_ReloadSecondary:
		AnimName = (P.bIsCrouched) ? SecondaryReloadAnimHalfCrouch : SecondaryReloadAnimHalf;
		break;
	case WEP_ReloadSecondaryEmpty:
		AnimName = (P.bIsCrouched) ? SecondaryReloadAnimEmptyCrouch : SecondaryReloadAnimEmpty;
		break;
	case WEP_ReloadSecondary_Elite:
		AnimName = (P.bIsCrouched) ? SecondaryReloadAnimEliteHalfCrouch : SecondaryReloadAnimEliteHalf;		
		break;
	case WEP_ReloadSecondaryEmpty_Elite:
		AnimName = (P.bIsCrouched) ? SecondaryReloadAnimEliteEmptyCrouch : SecondaryReloadAnimEliteEmpty;
		break;
	}

	if (AnimName != '')
	{
		PlayCharacterMeshAnim(P, AnimName, true);
	}
	else
	{
		Super.PlayReloadMagazineAnim(NewWeaponState, P);
	}
}

simulated function CauseMuzzleFlash(byte FiringMode)
{
	if ( FiringMode == 1 ) // AltFire
	{
		if (ShotgunMuzzleFlash == None)
		{
			AttachMuzzleFlash();
		}

		if (ShotgunMuzzleFlash != None )
		{
			ShotgunMuzzleFlash.CauseMuzzleFlash(FiringMode);
			if ( ShotgunMuzzleFlash.bAutoActivateShellEject )
			{
				ShotgunMuzzleFlash.CauseShellEject();
			}
		}
	}
	else
	{
		Super.CauseMuzzleFlash(FiringMode);
	}
}

/** Added second weapon */
simulated function AttachMuzzleFlash()
{
	Super.AttachMuzzleFlash();

	if ( WeapMesh != none && ShotgunMuzzleFlash == None )
	{
        ShotgunMuzzleFlash = new(self) Class'KFMuzzleFlash'(class'KFWeap_AssaultRifle_FAMAS'.default.ShotgunMuzzleFlashTemplate);
        ShotgunMuzzleFlash.AttachMuzzleFlash(WeapMesh, ShotgunMuzzleSocket,);
	}
}

/** Plays fire animation on weapon mesh */
simulated function PlayFireAnim(KFPawn P)
{
	local float Duration;
	local name Anim;
	local KFPawn OwnerPawn;

	OwnerPawn = KFPawn(Owner);

	if ( Instigator.bIsWalking ) // IronSight anims
	{
		if (OwnerPawn.FiringMode == 0) // DEFAULT FIRE MODE (Rifle)
		{
			Anim = WeaponIronFireAnim;
		}
		else if (OwnerPawn.FiringMode == 1) // ALT FIRE MODE (Shotgun)
		{
			Anim = SecondaryFireIronAnim;

		}
	}
	else // Normal anims
	{
		if (OwnerPawn.FiringMode == 0) // DEFAULT FIRE MODE (Rifle)
		{
			Anim = WeaponFireAnim;
		}
		else if (OwnerPawn.FiringMode == 1) // ALT FIRE MODE (Shotgun)
		{
			Anim = OwnerPawn.bIsCrouched ? SecondaryFireAnimCrouch : SecondaryFireAnim;
		}
	}

	Duration = WeapMesh.GetAnimLength( Anim );
	WeapMesh.PlayAnim( Anim, Duration / ThirdPersonAnimRate,, true );
}

simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local EAnimSlotStance AnimType;

	if (P.FiringMode == 1) // AltFire
	{
    	SpawnTracer(GetAltMuzzleLocation(), HitLocation);
	}
	else
	{
    	SpawnTracer(GetMuzzleLocation(), HitLocation);
	}

	// Effects below this point are culled based on visibility and distance
	if ( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	// Weapon shoot anims
	if( !bWeapMeshIsPawnMesh )
	{
		PlayFireAnim(P);
	}

	if( P.IsDoingSpecialMove() && P.SpecialMoves[P.SpecialMove].bAllowFireAnims )
	{
		AnimType = EAS_Additive;
	}
	else
	{
		AnimType = EAS_FullBody;
	}

	// Character shoot anims
	if ( !P.IsDoingSpecialMove() || AnimType == EAS_Additive )
	{
		PlayPawnFireAnim( P, AnimType );

		// interrupt other weapon action anims (e.g. Reload)
		if( !P.IsDoingSpecialMove() )
		{
			P.StopBodyAnim(P.bIsCrouched ? EAS_CH_UpperBody : EAS_UpperBody, 0.1f);
		}

		if ( OnWeaponStateChanged != None )
		{
			OnWeaponStateChanged(true);
		}
	}

	CauseMuzzleFlash(P.FiringMode);
	return true;
}

/** Plays fire animation on pawn */
simulated function PlayPawnFireAnim( KFPawn P, EAnimSlotStance AnimType )
{
	if (P.FiringMode == 0)
	{
		super.PlayPawnFireAnim(P, AnimType);
	}
	else if (P.FiringMode == 1)
	{
		if ( P.bIsCrouched )
		{
			P.PlayBodyAnim(SecondaryFireBodyAnimCH, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
		}
		else if ( P.bIsWalking )
		{
			P.PlayBodyAnim(SecondaryFireBodyAnimIron, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
		}
		else
		{
			P.PlayBodyAnim(SecondaryFireBodyAnim, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
		}
	}
}

simulated function vector GetAltMuzzleLocation(optional byte MuzzleID)
{
	local vector SocketLocation;

	if (ShotgunMuzzleFlash == None && MuzzleFlashTemplate != None)
	{
		AttachMuzzleFlash();
	}

	if( ShotgunMuzzleFlash != none )
	{
		WeapMesh.GetSocketWorldLocationAndRotation(ShotgunMuzzleFlash.GetSocketName(), SocketLocation);
		return SocketLocation;
	}

	return Super.GetMuzzleLocation(MuzzleID);
}


defaultproperties
{

}