//=============================================================================
// KFWeapAttach_AltAmmo
//=============================================================================
// A custom 3rd person weapon template for weapons that use multiple different ammo types.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_MultiAmmo extends KFWeaponAttachment;

/** Secondary Weapon Reloads */
const SecondaryReloadAnim			= 'Reload_Secondary';
const CH_SecondaryReloadAnim		= 'Reload_Secondary_CH';
const SecondaryReloadEliteAnim		= 'Reload_Secondary_Elite';
const CH_SecondaryReloadEliteAnim	= 'Reload_Secondary_Elite_CH';

/**
 * Don't allow secondary fire to make a primary fire shell particle come out of the gun.
 */
simulated function CauseMuzzleFlash(byte FireModeNum)
{
	local bool AutoShellEject;

	if(FireModeNum != 0)
	{
		if (MuzzleFlash == None && MuzzleFlashTemplate != None)
		{
			AttachMuzzleFlash();
		}

		AutoShellEject = MuzzleFlash.bAutoActivateShellEject;

		MuzzleFlash.bAutoActivateShellEject = false;

		Super.CauseMuzzleFlash(FireModeNum);

		MuzzleFlash.bAutoActivateShellEject = AutoShellEject;
	}
	else
	{
		Super.CauseMuzzleFlash(FireModeNum);
	}
}

/** Play a 3rd person reload animation */
simulated function PlayReloadMagazineAnim(EWeaponState NewWeaponState, KFPawn P)
{
	local name AnimName;

	if(NewWeaponState == WEP_ReloadSecondary || NewWeaponState == WEP_ReloadSecondary_Elite)
	{
		switch (NewWeaponState)
		{
		case WEP_ReloadSecondary:
			AnimName = (!P.bIsCrouched) ? SecondaryReloadAnim : CH_SecondaryReloadAnim;
			break;
		case WEP_ReloadSecondary_Elite:
			AnimName = (!P.bIsCrouched) ? SecondaryReloadEliteAnim : CH_SecondaryReloadEliteAnim;
			break;
		}

		PlayCharacterMeshAnim(P, AnimName, true);
	}
	else
	{
		Super.PlayReloadMagazineAnim(NewWeaponState, P);
	}
}

defaultproperties
{}