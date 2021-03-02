//=============================================================================
// KFWeapAttach_GravityImploder
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_GravityImploder extends KFWeaponAttachment;

`define GRAVITYIMPLODER_MIC_LED_INDEX 1

/** Weapons material colors for each fire mode. */
var LinearColor DefaultFireMaterialColor;
var LinearColor AltFireMaterialColor;

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	if ( WeaponMIC == None && WeapMesh != None )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`GRAVITYIMPLODER_MIC_LED_INDEX);
        WeaponMIC.SetVectorParameterValue('Vector_Center_Color_A', DefaultFireMaterialColor);
	}
}

simulated function bool ThirdPersonFireEffects(vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local LinearColor MatColor;
    if(P.FiringMode == 0) // DEFAULT_FIREMODE
    {
        MatColor = DefaultFireMaterialColor;
    }
    else if (P.FiringMode == 1) // ALTFIRE_FIREMODE
    {
        MatColor = AltFireMaterialColor;
    }

    WeaponMIC.SetVectorParameterValue('Vector_Center_Color_A', MatColor);
    return super.ThirdPersonFireEffects(HitLocation, P, ThirdPersonAnimRateByte);
}

defaultproperties
{
	DefaultFireMaterialColor = (R = 0.965f,G = 0.2972f, B = 0.0f)
	AltFireMaterialColor	 = (R = 0.0f,  G = 0.9631f, B = 0.96581f)
}