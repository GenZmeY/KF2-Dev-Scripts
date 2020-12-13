//=============================================================================
// KFWeapAttach_Dual_C4
//=============================================================================
// Dual weapon attachment for C4, used to play correct anims since C4 has
// a few uniquely-named anims
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================
class KFWeapAttach_Dual_C4 extends KFWeapAttach_DualBase;

const ThrowAnim = 'C4_Throw';
const CrouchThrowAnim = 'C4_Throw_CH';

const DetonateAnim = 'Shoot';
const CrouchDetonateAnim = 'CH_Shoot';

/** Completely overridden to play anims for both C4 firemodes (throw and detonate), also doesn't need to play effects */
simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local float Duration;

	// Effects below this point are culled based on visibility and distance
	if ( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	// Weapon shoot anims
	if (P.FiringMode == 0)
	{
		// anim simply hides and unhides bone
		Duration = WeapMesh.GetAnimLength( ThrowAnim );
		WeapMesh.PlayAnim( ThrowAnim, Duration / ThirdPersonAnimRate,, true );

		// use timer to make sure bone gets un-hidden (in case anim gets interrupted)
		SetTimer( 0.75f, false, nameof(UnHide) );
	}
	else if (P.FiringMode == 5)
	{
		Duration = WeapMesh.GetAnimLength( DetonateAnim );
		LeftWeapMesh.PlayAnim( DetonateAnim, Duration / ThirdPersonAnimRate,, true );
	}

	// Additive character shoot anims
	if ( !P.IsDoingSpecialMove() )
	{
		if( P.FiringMode == 0 )
		{
			if ( P.bIsCrouched )
			{
				P.PlayBodyAnim(CrouchThrowAnim, EAS_CH_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
			else
			{
				P.PlayBodyAnim(ThrowAnim, EAS_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
		}
		else if( P.FiringMode == 5 )
		{
			if ( P.bIsCrouched )
			{
				P.PlayBodyAnim(CrouchDetonateAnim, EAS_CH_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
			else
			{
				P.PlayBodyAnim(DetonateAnim, EAS_UpperBody, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
			}
		}
	}

	// prevent using "aiming" KFAnim_BlendByTargetingMode since we don't have/need the aim anims for C4
	P.LastWeaponFireTime = -1.f;

	return true;
}

/** Unhides the C4 unit in hand (basically the same as the notify, but don't use the notify) */
simulated function UnHide()
{
	if( WeapMesh != none )
	{
		WeapMesh.UnHideBoneByName( 'RW_Weapon' );
	}
}
