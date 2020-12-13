//=============================================================================
// KFWeapAttach_CompoundBow
//=============================================================================
// A custom 3rd person weapon template for the CompoundBow
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
// Tulio Beloqui (Saber Interactive)
//=============================================================================
class KFWeapAttach_CompoundBow extends KFWeaponAttachment;

/** The static mesh for arrow **/
var() StaticMeshComponent ArrowSMC;

/** The partcile FX to display for the Cryo Projectile **/
var ParticleSystem CryoProjectileEffectOn;
var ParticleSystem CryoProjectileEffectOff;
var() ParticleSystemComponent CryoProjectilePSC;

/** set to True if we started charging **/
var bool bCharging;

const WeaponIdleAnim = 'Idle_master';
const WeaponIronIdleAnim = 'Idle_Iron_V1';
const WeaponFireLoopStartAnim = 'ShootLoop_Start';
const WeaponFireLoopAnim = 'ShootLoop';
const WeaponFireLoopIronAnim = 'ShootLoop_Sight';
const WeaponFireEndLoopAnim = 'ShootLoop_End';

const CH_WeapondleAnim = 'Idle_CH_V1';
const CH_WeaponFireStartAnim = 'ShootLoop_Start_CH';
const CH_WeaponFireLoopAnim = 'ShootLoop_CH';
const CH_WeaponFireLoopIronAnim = 'ShootLoop_Sight_CH';
const CH_WeaponFireEndLoopAnim = 'ShootLoop_End_CH';

const ArrowSocketName = 'RW_Weapon';

simulated function StartFire()
{
	local KFPawn_Human P;
	local name WeaponLoopAnimName;
	
	P = KFPawn_Human(Owner);

	bCharging = true;
	WeaponLoopAnimName = GetWeaponFireLoopAnim (P);

	// ShootLoop animation is determined in PlayLoopAnim(), our "outro" animation is the actual ShootLoop_End:
	if (P.bIsCrouched)
	{
		StartLoopingAnim(P, WeaponLoopAnimName, CH_WeaponFireStartAnim, '', true);
	}
	else
	{
		StartLoopingAnim(P, WeaponLoopAnimName, WeaponFireLoopStartAnim, '', true);
	}
}

simulated function PlayWeaponFireAnim()
{
	local float Duration;

	if (Instigator.bIsCrouched)
	{
		Duration = WeapMesh.GetAnimLength( CH_WeaponFireEndLoopAnim );
		WeapMesh.PlayAnim( CH_WeaponFireEndLoopAnim, Duration / ThirdPersonAnimRate,, true );
	}
	else
	{
		Duration = WeapMesh.GetAnimLength( WeaponFireEndLoopAnim );
		WeapMesh.PlayAnim( WeaponFireEndLoopAnim, Duration / ThirdPersonAnimRate,, true );
	}
}

simulated function PlayShoot(KFPawn P)
{
	PlayPawnFireAnim (P, EAS_Additive);

	if (P.bIsCrouched)
	{
		P.PlayBodyAnim(CH_WeaponFireEndLoopAnim, EAS_CH_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
	else
	{
		P.PlayBodyAnim(WeaponFireEndLoopAnim, EAS_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
}

simulated function PlayReloadMagazineAnim (EWeaponState NewWeaponState, KFPawn P)
{
	Super.PlayReloadMagazineAnim (NewWeaponState, P);
	SetTimer( 0.15f, false, nameof(ShowArrowOnReload) );
}

simulated function ShowArrowOnReload()
{
	// We show the arrow since we are reloading we know that we have one
	SetArrowVisbility (true);
}

simulated function UpdateThirdPersonWeaponAction( EWeaponState NewWeaponState, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local KFPawn_Human PHuman;

	PHuman = KFPawn_Human (P);

	Super.UpdateThirdPersonWeaponAction( NewWeaponState, P, ThirdPersonAnimRateByte );

	switch (NewWeaponState)
	{
	case WEP_Grenade:
		SetArrowVisbility (false);
		break;

	case WEP_Equipping:
	case WEP_Idle:

		if (P.IsLocallyControlled ())
		{
			ToggleShowHideArrow (P);
		}
		else
		{
			/** just show the arrow if we cannot access AmmoCount from MyKFWeapon **/
			SetArrowVisbility (true);
		}
		
		/** restore Cryo visibility based on the Pawn alt fire mode **/
		if (PHuman != none)
		{
			if (PHuman.bUsingAltFireMode)
			{
				ToggleCryoFX (true);
			}
		}

		break;
	default:
		break;
	}
}

simulated function bool ThirdPersonFireEffects (vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte)
{
	bCharging = false;

    SpawnTracer(GetMuzzleLocation(), HitLocation);

	// Effects below this point are culled based on visibility and distance
	if ( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	if (P.FiringMode == 0 || P.FiringMode == 1)
	{
		SetArrowVisbility (false);
	}

	// Weapon shoot anims
	PlayWeaponFireAnim();

	// Character shoot anims
	if ( !P.IsDoingSpecialMove())
	{
		PlayShoot (P);
		
		if ( OnWeaponStateChanged != None )
		{
			OnWeaponStateChanged(true);
		}
	}

	CauseMuzzleFlash(P.FiringMode);
	return true;
}

simulated function ToggleShowHideArrow (KFPawn P)
{
	if (P.MyKFWeapon != none)
	{
		if (P.MyKFWeapon.AmmoCount[0] > 0)
		{
			SetArrowVisbility (true);
		}
		else
		{
			SetArrowVisbility (false);
		}
	}
}

simulated function SetArrowVisbility (bool bVisible)
{
	// Keep the arrow from the weapon mesh unvisible
	WeapMesh.HideBoneByName (ArrowSocketName, PBO_None);

	if (bVisible)
	{
		ArrowSMC.SetHidden(false);
		CryoProjectilePSC.SetHidden(false);
	}
	else
	{
		ArrowSMC.SetHidden(true);
		CryoProjectilePSC.SetHidden(true);
	}
}

simulated function StartPawnCrouch ()
{
	if (KFPawn_Human (Owner) != none)
	{
		ResetAnimationState (KFPawn_Human (Owner));
	}
}

simulated function EndPawnCrouch ()
{
	if (KFPawn_Human (Owner) != none)
	{
		ResetAnimationState (KFPawn_Human (Owner));
	}
}

simulated function SetWeaponUsingIronSights (bool bUsingIronSights)
{
	if (KFPawn_Human (Owner) != none)
	{
		ResetAnimationState (KFPawn_Human (Owner));
	}
}

simulated function SetWeaponAltFireMode (bool bUsingAltFireMode)
{
	ToggleCryoFX (bUsingAltFireMode);
}

simulated function ResetAnimationState (KFPawn_Human P)
{
	PlayCharacterMeshAnim (P, GetCharacterAnimationName(P), true, true);
}

simulated function ToggleCryoFX(bool bEnable)
{
	if (bEnable)
	{
		CryoProjectilePSC.DeactivateSystem();
		CryoProjectilePSC.SetTemplate(CryoProjectileEffectOn);
		CryoProjectilePSC.ActivateSystem();
	}
	else
	{
		CryoProjectilePSC.DeactivateSystem();
		CryoProjectilePSC.SetTemplate(CryoProjectileEffectOff);
		CryoProjectilePSC.ActivateSystem();
	}
}

simulated function name GetWeaponFireLoopAnim (KFPawn_Human P)
{
	if (P.bIsCrouched && P.bUsingIronSights)
	{
		return CH_WeaponFireLoopIronAnim;
	}
	if (P.bIsCrouched)
	{
		return CH_WeaponFireLoopAnim;
	}
	if (P.bUsingIronSights)
	{
		return WeaponFireLoopIronAnim;
	}

	return WeaponFireLoopAnim;
}

simulated function name GetCharacterAnimationName (KFPawn_Human P)
{
	if (bCharging)
	{
		return GetWeaponFireLoopAnim (P);
	}
	if (P.bUsingIronSights && P.bIsCrouched)
	{
		return CH_WeaponFireLoopIronAnim;
	}
	if (P.bUsingIronSights)
	{
		return WeaponIronIdleAnim;
	}
	if (P.bIsCrouched)
	{
		return CH_WeapondleAnim;
	}
	
	return WeaponIdleAnim;
}

simulated function AttachTo (KFPawn P)
{
	local byte WeaponAnimSetIdx;

    if ( WeapMesh != None )
	{
		// Attach Weapon mesh to player skel mesh
		WeapMesh.SetShadowParent(P.Mesh);
		P.Mesh.AttachComponent (WeapMesh, 'LW_Weapon');
		
		// Keep the arrow from the weapon mesh unvisible
		WeapMesh.HideBoneByName (ArrowSocketName, PBO_None);
	}

	// Animation
	if ( CharacterAnimSet != None )
	{
		WeaponAnimSetIdx = P.CharacterArch.GetWeaponAnimSetIdx();
		P.Mesh.AnimSets[WeaponAnimSetIdx] = CharacterAnimSet;
		// update animations will reload all AnimSeqs with the new AnimSet
		P.Mesh.UpdateAnimations();
	}

	// update aim offset nodes with new profile for this weapon
	P.SetAimOffsetNodesProfile(AimOffsetProfileName);

    //Do a first chance weapon skin switch (EX: changed weapon w/o ID changing by throwing a dualie)
    if (KFPawn_Human(P) != None && KFPawn_Human(P).WeaponSkinItemId > 0)
    {
        SetWeaponSkin(KFPawn_Human(P).WeaponSkinItemId);
    }

	if (ArrowSMC != none)
	{
		P.Mesh.AttachComponentToSocket(ArrowSMC, ArrowSocketName);
	}

	if (CryoProjectilePSC != none)
	{
		P.Mesh.AttachComponentToSocket(CryoProjectilePSC, ArrowSocketName);
	}

	if (P.MyKFWeapon != none && P.MyKFWeapon.bUseAltFireMode)
	{
		ToggleCryoFX (true);
	}
}

simulated function DetachFrom(KFPawn P)
{
	if (CryoProjectilePSC != none)
	{
		CryoProjectilePSC.DeactivateSystem();
		CryoProjectilePSC.DetachFromAny();
	}

	if (ArrowSMC != none)
	{
		P.DetachComponent(ArrowSMC);
		ArrowSMC.DetachFromAny();
	}

    Super.DetachFrom(P);
}

event SetWeaponSkin(int ItemId, optional bool bFinishedLoading = false)
{
	local array<MaterialInterface> SkinMICs;

	if ( WeapMesh != none && ArrowSMC != none && ItemId > 0 && WorldInfo.NetMode != NM_DedicatedServer && !bWaitingForWeaponSkinLoad)
	{
		if (!bFinishedLoading && StartLoadWeaponSkin(ItemId))
		{
			return;
		}

		SkinMICs = class'KFWeaponSkinList'.static.GetWeaponSkin(ItemId, WST_ThirdPerson);
		if ( SkinMICs.Length > 0 )
		{
			WeapMesh.SetMaterial(0, SkinMICs[0]);
			ArrowSMC.SetMaterial(0, SkinMICs[0]);
		}
	}
}

defaultproperties
{
	Begin Object Class=StaticMeshComponent Name=ArrowStaticMeshComp0
		StaticMesh=StaticMesh'WEP_3P_CompoundBow_MESH.Wep_3rdP_Compound_Bow_Arrow_Resource'
	End Object
	ArrowSMC=ArrowStaticMeshComp0

	Begin Object Class=KFParticleSystemComponent Name=CryoArrowParticleComp0
		bAutoActivate=FALSE
		TickGroup=TG_PostUpdateWork
	End Object
	CryoProjectilePSC=CryoArrowParticleComp0

	CryoProjectileEffectOn=ParticleSystem'WEP_CompoundBow_EMIT.FX_Compound_Bow_Cryo_Idle_3P'
	CryoProjectileEffectOff=ParticleSystem'WEP_CompoundBow_EMIT.FX_Compound_Bow_Cryo_ToggleOff'
}
