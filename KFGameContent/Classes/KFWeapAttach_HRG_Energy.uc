//=============================================================================
// KFWeapAttach_HRG_Energy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_HRG_Energy extends KFWeaponAttachment;

`define HRG_ENERGY_MIC_LED_INDEX_1 0
`define HRG_ENERGY_MIC_SCREEN_INDEX 1
`define HRG_ENERGY_MIC_LED_INDEX_2 2

var MaterialInstanceConstant WeaponMIC_2;  
var MaterialInstanceConstant WeaponMICScreen;  

simulated function SetWeaponAltFireMode (bool bUsingAltFireMode)
{
    super.SetWeaponAltFireMode(bUsingAltFireMode);
    UpdateMaterial(bUsingAltFireMode ? 1 : 0);
}

simulated function UpdateMaterial(byte FireMode)
{
	local LinearColor MatColor;

    if (WeapMesh == none)
    {
        return;
    }

	MatColor = FireMode == 0 ? class'KFWeap_HRG_Energy'.default.DefaultFireMaterialColor : class'KFWeap_HRG_Energy'.default.AltFireMaterialColor;

    if ( WeaponMIC == none )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`HRG_ENERGY_MIC_LED_INDEX_1);
	}

    if ( WeaponMIC_2 == none )
    {
        WeaponMIC_2 = WeapMesh.CreateAndSetMaterialInstanceConstant(`HRG_ENERGY_MIC_LED_INDEX_2);
    }
    
	if (WeaponMICScreen == none)
	{
		WeaponMICScreen = WeapMesh.CreateAndSetMaterialInstanceConstant(`HRG_ENERGY_MIC_SCREEN_INDEX);
	}

    WeaponMIC.SetVectorParameterValue('Vector_GlowColor', MatColor);
    WeaponMIC_2.SetVectorParameterValue('Vector_GlowColor', MatColor);
	WeaponMICScreen.SetVectorParameterValue('Color_override', MatColor);
}

/** Plays fire animation on weapon mesh */
simulated function PlayWeaponFireAnim()
{
	local float Duration, AnimRateModifier;
    local name Animation;
    local KFPawn_Human KFPH;

    KFPH = KFPawn_Human(Instigator);

    AnimRateModifier = (KFPH != none && KFPH.bUsingAltFireMode) ? class'KFWeap_HRG_Energy'.default.SecondaryFireAnimRateModifier : 1.0f;

	if ( Instigator.bIsWalking )
	{
		Duration = WeapMesh.GetAnimLength( WeaponIronFireAnim );
        Animation = WeaponIronFireAnim;
	}
	else
	{
		Duration = WeapMesh.GetAnimLength( WeaponFireAnim );
        Animation = WeaponFireAnim;
		WeapMesh.PlayAnim( WeaponFireAnim, Duration / ThirdPersonAnimRate,, true );
	}

    WeapMesh.PlayAnim( Animation, Duration / ThirdPersonAnimRate * AnimRateModifier,, true );
}


/** Play a 3rd person reload animation */
simulated function PlayReloadMagazineAnim(EWeaponState NewWeaponState, KFPawn P)
{
	local name AnimName;

	switch (NewWeaponState)
	{
	case WEP_Reload:
    case WEP_ReloadEmpty:
		AnimName = (!P.bIsCrouched) ? ReloadHalfAnim : CH_ReloadHalfAnim;
		break;
	case WEP_Reload_Elite:
    case WEP_ReloadEmpty_Elite:
		AnimName = (!P.bIsCrouched) ? ReloadHalfEliteAnim : CH_ReloadHalfEliteAnim;
		break;
	}

	PlayCharacterMeshAnim(P, AnimName, true);
}

defaultproperties
{

}
