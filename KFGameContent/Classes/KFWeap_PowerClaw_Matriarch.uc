//=============================================================================
// KFWeap_PowerClaw_Matriarch
//=============================================================================
// Matriarch's Power Claw / Tesla Beam Shooter
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_PowerClaw_Matriarch extends KFWeap_RifleBase;

var float ChainMaxDist;
var array<ImpactInfo> Impacts;

simulated function StartFire(byte FireModeNum)
{
	Impacts.Length = 0;
	super.StartFire(FireModeNum);
}

simulated function Projectile ProjectileFire()
{
	InstantFireClient();
	return none;
}

simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum)
{
	local KFPawn HitPawn, NearbyPawn;
	local float DistSqToNearbyPawn, MaxDistSq;
	local vector StartTrace, EndTrace, TraceNormal, HitPawnBoneLocation, NearbyPawnBoneLocation;
	local array<KFPawn> SourcePawns, TargetPawns, HitPawns, NewHitPawns;
	local int i;
	local KFProj_Bullet_MatriarchTeslaBlast MatProj;

	if (Role == ROLE_Authority)
	{
		HitPawn = KFPawn(Impact.HitActor);
		if (HitPawn == none)
		{
			return;
		}

		HitPawns.AddItem(HitPawn);
		NewHitPawns.AddItem(HitPawn);
		SourcePawns.AddItem(KFPawn(Owner));
		TargetPawns.AddItem(HitPawn);
		Impacts.AddItem(Impact);

		MaxDistSq = ChainMaxDist * ChainMaxDist;

		while (NewHitPawns.Length > 0)
		{
			HitPawn = NewHitPawns[0];
			NewHitPawns.Remove(0, 1);

			foreach WorldInfo.AllPawns(class'KFPawn', NearbyPawn)
			{
				if (NearbyPawn == Owner)
				{
					continue;
				}

				if (HitPawns.Find(NearbyPawn) != INDEX_NONE)
				{
					continue;
				}

				HitPawnBoneLocation = HitPawn.Mesh.GetBoneLocation(class'KFPawn_ZedMatriarch'.default.GunTargetBoneName);
				NearbyPawnBoneLocation = NearbyPawn.Mesh.GetBoneLocation(class'KFPawn_ZedMatriarch'.default.GunTargetBoneName);

				DistSqToNearbyPawn = VSizeSq(NearbyPawnBoneLocation - HitPawnBoneLocation);
				if (DistSqToNearbyPawn < MaxDistSq)
				{
					TraceNormal = Normal(NearbyPawnBoneLocation - HitPawnBoneLocation);
					StartTrace = HitPawnBoneLocation + TraceNormal * HitPawn.GetCollisionRadius();
					EndTrace = NearbyPawnBoneLocation + TraceNormal * NearbyPawn.GetCollisionRadius();
					Impact = CalcWeaponFire(StartTrace, EndTrace);
					if (Impact.HitActor == NearbyPawn)
					{
						HitPawns.AddItem(NearbyPawn);
						NewHitPawns.AddItem(NearbyPawn);
						SourcePawns.AddItem(HitPawn);
						TargetPawns.AddItem(NearbyPawn);
						Impacts.AddItem(Impact);
					}
				}
			}
		}

		for (i = 0; i < Impacts.Length; ++i)
		{
			super.ProcessInstantHitEx(FiringMode, Impacts[i], NumHits, out_PenetrationVal);
			MatProj = Spawn(
				class'KFProj_Bullet_MatriarchTeslaBlast',
				self,,
				Impacts[i].StartTrace,
				rotator(Impacts[i].RayDir),,
				true);

			MatProj.SourcePawn = SourcePawns[i];
			MatProj.TargetPawn = TargetPawns[i];
			MatProj.bSyncToOriginalLocation = (i == 0);
			MatProj.Init(Impacts[i].RayDir);
			MatProj.bForceNetUpdate = true;
			if (WorldInfo.NetMode != NM_DedicatedServer)
			{
				MatProj.ActivateVFX();
			}
			MatProj.Shutdown();
		}
	}
}

/** Overridden. Matriarch does not consume ammo */
simulated function ConsumeAmmo(byte FireModeNum);

/** Overridden, sprint is controlled by AI */
simulated function StopPawnSprint(bool bClearPlayerInput);

simulated state Active
{
	simulated function GotoWeaponSprinting();
}

defaultproperties
{
	InventorySize=6

    // FOV
    bHidden=true
    MeshFOV=75
	MeshIronSightFOV=33
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_MaxNearBlurSize=3

	// Zooming/Position
	PlayerViewOffset=(X=2.0,Y=8,Z=-3)

	// Content
	WeaponContentLoaded=true

	AttachmentArchetype=KFWeaponAttachment'WEP_Matriarch_ARCH.Wep_Matriarch_PowerClaw_3P'

	// Ammo
	MagazineCapacity[0]=60
	SpareAmmoCapacity[0]=270
	InitialSpareMags[0]=3
	bCanBeReloaded=false//true
	bReloadFromMagazine=false//true

	// Recoil
	maxRecoilPitch=200
	minRecoilPitch=150
	maxRecoilYaw=175
	minRecoilYaw=-125
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=2.5

	// Grouping
	GroupPriority=50
	//WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_AK12'

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_MatriarchTeslaBlast'
	FireInterval(DEFAULT_FIREMODE)=+0.06 // 1250 RPM
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_EMP_MatriarchTeslaBlast'
	Spread(DEFAULT_FIREMODE)=0.0
	InstantHitDamage(DEFAULT_FIREMODE)=65.0
	FireOffset=(X=32,Y=4.0,Z=-5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// Fire Effects
	MuzzleFlashTemplate=KFMuzzleFlash'ZED_Matriarch_ARCH.Tesla_Blast_MuzzleFlash_Arch'
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Tesla_Blast_Attack_01', FirstPersonCue=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Tesla_Blast_Attack_01')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_ZED_Matriarch.Play_Matriarch_SFX_Attack_Gun_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_ZED_Matriarch.Play_Matriarch_SFX_Attack_Gun_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=false
	//WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Plasma_Cannon_End_01', FirstPersonCue=AkEvent'WW_ZED_Matriarch.Play_Matriarch_Plasma_Cannon_End_01')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=none

	bCanThrow=false
	bDropOnDeath=false
	bUseAnimLenEquipTime=false




	ChainMaxDist=650.f
}