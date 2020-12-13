//=============================================================================
// KFWeapAttach_Pulverizer
//=============================================================================
// A custom 3rd person weapon template for the pulverizer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_Pulverizer extends KFWeaponAttachment;

const PulverizerShoot_F = 'Atk_F_Shoot';
const PulverizerShoot_B = 'Atk_B_Shoot';
const PulverizerShoot_L = 'Atk_L_Shoot';
const PulverizerShoot_R = 'Atk_R_Shoot';

const CH_PulverizerShoot_F = 'Atk_F_Shoot_CH';
const CH_PulverizerShoot_B = 'Atk_B_Shoot_CH';
const CH_PulverizerShoot_L = 'Atk_L_Shoot_CH';
const CH_PulverizerShoot_R = 'Atk_R_Shoot_CH';

var transient EWeaponState NextPulverizerShootType;

/** Custom firing animations */
simulated function bool ThirdPersonFireEffects(vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	// Character shoot anims
	if ( !P.IsDoingSpecialMove() )
	{
		PlayPulverizerShoot(P);
	}

	// Effects below this point are culled based on visibility and distance
	if ( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	CauseMuzzleFlash(P.FiringMode);
	return true;
}

/** Custom character animation for pulverizer third person shoot */
simulated function PlayPulverizerShoot(KFPawn P)
{
	switch(NextPulverizerShootType)
	{
	case WEP_MeleeHeavy_B:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_PulverizerShoot_B : PulverizerShoot_B);
		break;
	case WEP_MeleeHeavy_F:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_PulverizerShoot_F : PulverizerShoot_F);
		break;
	case WEP_MeleeHeavy_L:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_PulverizerShoot_L : PulverizerShoot_L);
		break;
	case WEP_MeleeHeavy_R:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_PulverizerShoot_R : PulverizerShoot_R);
		break;
	}

	NextPulverizerShootType = -1;
}

/** Cache the previous melee attact action to use it for 'ThirdPersonFireEffects'  */
simulated function UpdateThirdPersonWeaponAction( EWeaponState NewWeaponState, KFPawn P, byte ThirdPersonAnimRateByte )
{
	switch(NewWeaponState)
	{
	case WEP_MeleeHeavy_B:
	case WEP_MeleeHeavy_F:
	case WEP_MeleeHeavy_L:
	case WEP_MeleeHeavy_R:
		NextPulverizerShootType = NewWeaponState;
		break;
	}

	Super.UpdateThirdPersonWeaponAction( NewWeaponState, P, ThirdPersonAnimRateByte );
}

defaultproperties
{
}
