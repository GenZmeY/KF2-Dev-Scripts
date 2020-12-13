//=============================================================================
// KFWeapAttach_IonThruster
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_IonThruster extends KFWeaponAttachment;

/** Name of the special anim used for the ultimate attack */
var name UltimateAttackAnim;
/** Name of the special anim used for the ultimate attack while crouching */
var name UltimateAttackAnimCrouch;

/** Play a melee attack animation */
simulated function float PlayMeleeAtkAnim(EWeaponState NewWeaponState, KFPawn P)
{
	if (P.IsFirstPerson())
	{
		return 0.0f;
	}

	// custom firemode, special attack
	if (Instigator != none && Instigator.FiringMode == 6)
	{
		if (P.bIsCrouched)
		{
			return PlayCharacterMeshAnim(P, UltimateAttackAnimCrouch);
		}
		else
		{
			return PlayCharacterMeshAnim(P, UltimateAttackAnim);
		}
	}

	return super.PlayMeleeAtkAnim(NewWeaponState, P);
}

defaultproperties
{
	UltimateAttackAnim=Super_Attack
	UltimateAttackAnimCrouch=Super_Attack_CH
}
