//=============================================================================
// KFWeapAttach_FAMAS
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_ParasiteImplanter extends KFWeaponAttachment;

`define PARASITEIMPLANTER_MIC_INDEX 0

const SecondaryFireAnim                   = 'Shoot_Secondary';
const SecondaryFireAnimCrouch             = 'Shoot_Secondary_CH';
const SecondaryFireIronAnim               = 'Shoot_Secondary_Iron';
const SecondaryFireBodyAnim               = 'ADD_Shoot_Secondary';
const SecondaryFireBodyAnimCH             = 'ADD_Shoot_Secondary_CH';
const SecondaryFireBodyAnimIron           = 'ADD_Shoot_Secondary_Iron';

/** Material colors applied to different fire modes */
var LinearColor NoAmmoMaterialColor;
var LinearColor AmmoReadyMaterialColor;

/** Plays fire animation on weapon mesh */
simulated function PlayWeaponFireAnim()
{
	local float Duration;
	local name Anim;

	if ( Instigator.bIsWalking )
	{
        if (Instigator.FiringMode == 0) // DEFAULT FIRE MODE
        {
            Anim = WeaponIronFireAnim;
        }
        else if (Instigator.FiringMode == 1)
        {
            Anim = SecondaryFireIronAnim;
        }
	}
	else
	{
        if (Instigator.FiringMode == 0) // ALT FIRE MODE
        {
            Anim = WeaponFireAnim;
        }
        else if (Instigator.FiringMode == 1)
        {
            Anim = Instigator.bIsCrouched ? SecondaryFireAnimCrouch : SecondaryFireAnim;
        }
	}

    Duration = WeapMesh.GetAnimLength( Anim );
    WeapMesh.PlayAnim( Anim, Duration / ThirdPersonAnimRate,, true );
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

/** Special event added for weap attachments. Free for use */
function OnSpecialEvent(int Arg)
{
	if (Arg <= 2)
	{
		UpdateMaterial(Arg == 2);
	}
}

simulated function UpdateMaterial(bool HasEnoughAmmo)
{
	local LinearColor Value;

	Value = HasEnoughAmmo ? AmmoReadyMaterialColor : NoAmmoMaterialColor;
	if ( WeaponMIC == None && WeapMesh != None )
	{
		WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(`PARASITEIMPLANTER_MIC_INDEX);
	}

	WeaponMIC.SetVectorParameterValue('Vector_GlowColor', Value);
}

defaultproperties
{
	NoAmmoMaterialColor=(R=0.0f,G=0.0f,B=0.0f)
    AmmoReadyMaterialColor=(R=0.08f,G=1.0f,B=0.08f)
}
