//=============================================================================
// KFWeapAttach_Doshinegun
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_Doshinegun extends KFWeaponAttachment;

/** Play a melee attack animation */
simulated function float PlayMeleeAtkAnim(EWeaponState NewWeaponState, KFPawn P)
{
	local name AnimName;

    if( P.IsFirstPerson() )
	{
		return 0.0f;
	}

    if (NewWeaponState == WEP_MeleeBasic)
    {
        AnimName = P.bIsCrouched ? CH_MeleeBasic : MeleeBasic;
        return PlayCharacterMeshAnim(P, AnimName, true);
    }

	return super.PlayMeleeAtkAnim(NewWeaponState, P);
}

defaultproperties
{

}
