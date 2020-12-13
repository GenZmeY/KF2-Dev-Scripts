//=============================================================================
// KFDT_Freeze
//=============================================================================
// Damage caused by cold or ice weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Freeze extends KFDamageType
	abstract;

`include(KFGameDialog.uci)

var protected ParticleSystem FrozenShatterTemplate;

var protected AkBaseSoundObject	ShatterSound;

/** Returns ID of dialog event for killer to speak after killing a zed using this damage type */
static function int GetKillerDialogID()
{
	return `KILL_Freeze;
}

/** Returns ID of dialog event for damager to speak after damaging a zed using this damage type */
static function int GetDamagerDialogID()
{
	return `DAMZ_Freeze;
}

static function PlayShatter(KFPawn P, optional bool bSkipParticles, optional bool bMaterialOnly, optional vector RBLinearVelocity)
{
	local KFPawn_Monster Zed;
	local KFGoreManager GoreManager;
	local float IceScalar;
    local int MICIndex, i;

	IceScalar = 1.f;
	if ( !bMaterialOnly )
	{
		// Switch to gore mesh first so we can apply our gore material param
		Zed = KFPawn_Monster(P);
		if ( Zed != None && !Zed.bUseDamageInflation )
		{
			Zed.RepBleedInflateMatParam = 0;
			GoreManager = KFGoreManager( P.WorldInfo.MyGoreEffectManager );
			if( GoreManager != none && GoreManager.AllowMutilation() )
			{
                //Reinit phys asset here in the event scale changed.  Reinit after constraints break resets constraints
                if (Zed.bReinitPhysAssetOnDeath && Zed.CharacterArch != none && Zed.CharacterArch.PhysAsset != none)
                {
                    Zed.bReinitPhysAssetOnDeath = false;
                    Zed.Mesh.SetPhysicsAsset(Zed.CharacterArch.PhysAsset, , true);
                }

				if ( !Zed.bIsGoreMesh )
				{
					Zed.SwitchToGoreMesh();
				}

		 		Zed.ForceBreakAllConstraints();
		 	}
		 	else
		 	{
		 		// If we're ragdolling instead of shattering, make the zed look less solid
		 		IceScalar = 0.4f;
		 	}

	 		// Because we're going outside of the standard gore path, allow for some extra some whole body impulse here
	 		if ( !IsZero(RBLinearVelocity) )
	 		{
	 			P.Mesh.SetRBLinearVelocity(RBLinearVelocity, TRUE);
	 		}
		}

	    if ( !bSkipParticles )
	    {
			P.WorldInfo.MyEmitterPool.SpawnEmitter( default.FrozenShatterTemplate, P.Location, rotator(vect(0,0,1)) );
			P.PlaySoundBase(default.ShatterSound, true,,, P.Location);
		}
	}

	// Force instant freeze on gore MIC
    MICIndex = 0;
    if (P.GetCharacterInfo() != none)
    {
        MICIndex = P.GetCharacterInfo().GoreFXMICIdx;
    }

    if (P.CharacterMICs.Length > MICIndex)
    {
        P.CharacterMICs[MICIndex].SetScalarParameterValue('Scalar_Ice', IceScalar);
    }

	for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; ++i)
    {
        if (P.ThirdPersonAttachments[i] != none)
        {
            ApplyFreeze(P.ThirdPersonAttachments[i], IceScalar);
        }
    }

	if (KFPawn_Monster(P) != none)
	{
		for (i = 0; i < KFPawn_Monster(P).StaticAttachList.length; i++)
		{
			if (KFPawn_Monster(P).StaticAttachList[i] != none)
			{
				ApplyFreeze(KFPawn_Monster(P).StaticAttachList[i], IceScalar);
			}
		}
	}
}

static function ApplyFreeze(MeshComponent MeshToFreeze, float IceScalar)
{
	local int i;
	local MaterialInstanceConstant MIC;

	if (MeshToFreeze == none)
	{
		return;
	}

	for (i = 0; i < MeshToFreeze.Materials.Length; i++)
	{
		MIC = MaterialInstanceConstant(MeshToFreeze.GetMaterial(i));
		if (MIC != none)
		{
			MIC.SetScalarParameterValue('Scalar_Ice', IceScalar);
		}
	}
}

defaultproperties
{
	EffectGroup=FXG_Freeze
	FreezePower=2.5f
	FrozenShatterTemplate=ParticleSystem'WEP_Freeze_Grenade_EMIT.FX_Freeze_Grenade_Death'
	ShatterSound=AkEvent'WW_WEP_Freeze_Grenade.Play_Freeze_Grenade_Shatter'
}