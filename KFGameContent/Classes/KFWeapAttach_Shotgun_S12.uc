//=============================================================================
// KFWeapAttach_shotgun_s12
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_Shotgun_S12 extends KFWeaponAttachment;

const SecondaryMuzzleSocket      = 'MuzzleFlashAlt';
const SecondaryReloadAnim        = 'Reload_Secondary';
const SecondaryReloadCHAnim      = 'Reload_Secondary_CH';
const SecondaryReloadEliteAnim   = 'Reload_Secondary_Elite';
const SecondaryReloadEliteCHAnim = 'Reload_Secondary_Elite_CH';

var transient ParticleSystemComponent ExplosionPSC;
var transient ParticleSystem ExplosionEffect;
var protected transient KFMuzzleFlash SecondaryMuzzleFlash;
var protected transient bool bWasSecondaryShot;

simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
    local vector SocketLocation;

    bWasSecondaryShot = P.FiringMode == 1;

    if (Super.ThirdPersonFireEffects(HitLocation, P, ThirdPersonAnimRateByte))
    {
        if (P.FiringMode == 1 && !P.IsLocallyControlled())
        {
            if (ExplosionEffect != None)
            {
                WeapMesh.GetSocketWorldLocationAndRotation('MuzzleFlashAlt', SocketLocation);

                ExplosionPSC = WorldInfo.MyEmitterPool.SpawnEmitter(class'KFWeap_Shotgun_S12'.default.ExplosionEffect, SocketLocation, rotator(vect(0,0,1)));
                ExplosionPSC.ActivateSystem();
            }
        }
        return true;
    }
    return false;
}

/** @return the starting location for effects (e.g. tracers) */
simulated function vector GetMuzzleLocation(optional byte MuzzleID)
{
    if (bWasSecondaryShot)
    {
        return GetAltMuzzleLocation();
    }
    else
    {
        return Super.GetMuzzleLocation(MuzzleID);
    }
}

simulated function vector GetAltMuzzleLocation(optional byte MuzzleID)
{
	local vector SocketLocation;

	if (SecondaryMuzzleFlash == None)
	{
		AttachMuzzleFlash();
	}

	if( SecondaryMuzzleFlash != none )
	{
		WeapMesh.GetSocketWorldLocationAndRotation(SecondaryMuzzleFlash.GetSocketName(), SocketLocation);
		return SocketLocation;
	}

	return Super.GetMuzzleLocation(MuzzleID);
}

simulated event Tick(float DeltaTime)
{
    local vector SocketLocation;

    Super.Tick(DeltaTime);

    if (ExplosionPSC != none && ExplosionPSC.bIsActive)
    {
        WeapMesh.GetSocketWorldLocationAndRotation('MuzzleFlashAlt', SocketLocation);
        ExplosionPSC.SetVectorParameter('WeaponEndpoint', SocketLocation);
    }
}

simulated function CauseMuzzleFlash(byte FiringMode)
{
	if ( FiringMode == 1 ) // AltFire
	{
		if (SecondaryMuzzleFlash == None)
		{
			AttachMuzzleFlash();
		}

		if (SecondaryMuzzleFlash != None )
		{
			SecondaryMuzzleFlash.CauseMuzzleFlash(FiringMode);
			if ( SecondaryMuzzleFlash.bAutoActivateShellEject )
			{
				SecondaryMuzzleFlash.CauseShellEject();
			}
		}
	}
	else
	{
		Super.CauseMuzzleFlash(FiringMode);
	}
}

simulated function AttachMuzzleFlash()
{
	Super.AttachMuzzleFlash();

	if ( WeapMesh != none && SecondaryMuzzleFlash == None )
	{
        SecondaryMuzzleFlash = new(self) Class'KFMuzzleFlash'(class'KFWeap_Shotgun_S12'.default.SecondaryMuzzleFlashTemplate);
        SecondaryMuzzleFlash.AttachMuzzleFlash(WeapMesh, SecondaryMuzzleSocket,);
	}
}

simulated function PlayReloadMagazineAnim(EWeaponState NewWeaponState, KFPawn P)
{
	local name AnimName;

	switch (NewWeaponState)
	{

	case WEP_ReloadSecondary:
		AnimName = (P.bIsCrouched) ? SecondaryReloadCHAnim : SecondaryReloadAnim;
		break;
	case WEP_ReloadSecondary_Elite:
		AnimName = (P.bIsCrouched) ? SecondaryReloadEliteCHAnim : SecondaryReloadEliteAnim;		
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

defaultproperties
{
	ExplosionEffect=ParticleSystem'WEP_1P_Saiga12_EMIT.FX_Saiga12_Explosion_3P'
    bWasSecondaryShot=false
}
