//=============================================================================
// KFWeap_Beam_Microwave
//=============================================================================
// A gun that shoots microwave beams!!! TODO: Mostly placeholder
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFWeap_Beam_Microwave extends KFWeap_FlameBase;

/** Shoot animation to play when shooting secondary fire */
var(Animations) const editconst	name	FireHeavyAnim;

/** Shoot animation to play when shooting secondary fire last shot */
var(Animations) const editconst	name	FireLastHeavyAnim;

/** Shoot animation to play when shooting secondary fire last shot when aiming */
var(Animations) const editconst	name	FireLastHeavySightedAnim;

/** Alt-fire explosion template */
var() GameExplosion 		ExplosionTemplate;

/** Handle one-hand fire anims */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	local bool bPlayFireLast;

    bPlayFireLast = ShouldPlayFireLast(FireModeNum);

	if ( bUsingSights )
	{
		if( bPlayFireLast )
        {
        	if ( FireModeNum == ALTFIRE_FIREMODE )
        	{
                return FireLastHeavySightedAnim;
        	}
        	else
        	{
                return FireLastSightedAnim;
            }
        }
        else
        {
            return FireSightedAnims[FireModeNum];
        }

	}
	else
	{
		if( bPlayFireLast )
        {
        	if ( FireModeNum == ALTFIRE_FIREMODE )
        	{
                return FireLastHeavyAnim;
        	}
        	else
        	{
                return FireLastAnim;
            }
        }
        else
        {
        	if ( FireModeNum == ALTFIRE_FIREMODE )
        	{
                return FireHeavyAnim;
        	}
        	else
        	{
                return FireAnim;
            }
        }
	}
}

/**
 * Instead of a toggle, just immediately fire alternate fire.
 */
simulated function AltFireMode()
{
	// LocalPlayer Only
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

/** Explosion Actor version */
simulated function CustomFire()
{
	local KFExplosionActorReplicated ExploActor;
	local vector SpawnLoc;
	local rotator SpawnRot;
	local float ModifiedDamage, OriginalDamage, OriginalDamageRadius;

	// Alt-fire blast only (server authoritative)
	if ( CurrentFireMode != ALTFIRE_FIREMODE )
	{
		Super.CustomFire();
		return;
	}

	if ( Instigator.Role < ROLE_Authority )
	{
		return;
	}

	// This is where we would start an instant trace. (what CalcWeaponFire uses)
	SpawnLoc = Instigator.GetWeaponStartTraceLocation();
	SpawnRot = GetAdjustedAim( SpawnLoc );

	// explode using the given template
	ExploActor = Spawn(class'KFExplosionActorReplicated', self,, SpawnLoc, SpawnRot,, true);
	if (ExploActor != None)
	{
		ExploActor.InstigatorController = Instigator.Controller;
		ExploActor.Instigator = Instigator;

		// enable muzzle location sync
		ExploActor.bReplicateInstigator = true;
		ExploActor.bSyncParticlesToMuzzle = true;

		ModifiedDamage = GetUpgradeDamageMod();

		OriginalDamage = ExplosionTemplate.Damage;
		OriginalDamageRadius = ExplosionTemplate.DamageRadius;

		ExplosionTemplate.Damage *= ModifiedDamage;
		ExplosionTemplate.DamageRadius *= ModifiedDamage;

		ExploActor.Explode(ExplosionTemplate, vector(SpawnRot));

		ExplosionTemplate.Damage = OriginalDamage;
		ExplosionTemplate.DamageRadius = OriginalDamageRadius;
	}

	if ( bDebug )
	{
		DrawDebugCone(SpawnLoc, vector(SpawnRot), ExplosionTemplate.DamageRadius, ExplosionTemplate.DirectionalExplosionAngleDeg * DegToRad,
			ExplosionTemplate.DirectionalExplosionAngleDeg * DegToRad, 16, MakeColor(64,64,255,0), TRUE);
	}
}

/** Disable auto-reload for alt-fire */
simulated function bool ShouldAutoReload(byte FireModeNum)
{
	local bool bRequestReload;

    bRequestReload = Super.ShouldAutoReload(FireModeNum);

    // Must be completely empty for auto-reload or auto-switch
    if ( FireModeNum == ALTFIRE_FIREMODE && AmmoCount[0] > 0 )
    {
   		bPendingAutoSwitchOnDryFire = false;
   		return false;
    }

    return bRequestReload;
}

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Electric;
}

defaultproperties
{
    FlameSprayArchetype=SprayActor_Flame'WEP_Microwave_Gun_ARCH.WEP_Microwave_Gun_Flame'

	// Shooting Animations
	bHasFireLastAnims=true
	FireSightedAnims[0]=Shoot
	FireSightedAnims[1]=Shoot_Heavy_Iron
	FireLastHeavySightedAnim=Shoot_Heavy_Iron_Last
    FireHeavyAnim=Shoot_Heavy
    FireLastHeavyAnim=Shoot_Heavy_Last

    // FOV
	MeshIronSightFOV=52
    PlayerIronSightFOV=80

	// Zooming/Position
	IronSightPosition=(X=3,Y=0,Z=0)
	PlayerViewOffset=(X=5.0,Y=9,Z=-3)

	// Depth of field
	DOF_FG_FocalRadius=150
	DOF_FG_MaxNearBlurSize=1

	// Content
	PackageKey="Microwave_Gun"
	FirstPersonMeshName="WEP_1P_Microwave_Gun_MESH.Wep_1stP_Microwave_Gun_Rig"
	FirstPersonAnimSetNames(0)="WEP_1p_Microwave_Gun_ANIM.WEP_1p_Microwave_Gun_ANIM"
	PickupMeshName="WEP_3P_Microwave_Gun_MESH.Wep_Microwave_Gun_Pickup"
	AttachmentArchetypeName="WEP_Microwave_Gun_ARCH.Microwave_Gun_3P"
	MuzzleFlashTemplateName="WEP_Microwave_Gun_ARCH.Wep_Microwave_Gun_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=100
	SpareAmmoCapacity[0]=500
	InitialSpareMags[0]=0
	AmmoPickupScale[0]=0.5
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=150
	minRecoilPitch=115
	maxRecoilYaw=115
	minRecoilYaw=-115
	RecoilRate=0.085
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.25
	IronSightMeshFOVCompensationScale=1.5
    HippedRecoilModifier=1.5

    // Inventory
	InventorySize=9 //10
	GroupPriority=100
	WeaponSelectTexture=Texture2D'WEP_UI_Microwave_Gun_TEX.UI_WeaponSelect_MicrowaveGun'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Flamethrower'
	FiringStatesArray(DEFAULT_FIREMODE)=SprayingFire
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	FireInterval(DEFAULT_FIREMODE)=+0.07 // 850 RPM
	MinAmmoConsumed=3
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	FireInterval(ALTFIRE_FIREMODE)=+1.0
	AmmoCost(ALTFIRE_FIREMODE)=10


	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Flamethrower'
	InstantHitDamage(BASH_FIREMODE)=30

	Begin Object Class=GameExplosion Name=ExploTemplate0
		bDirectionalExplosion=True
		DirectionalExplosionAngleDeg=30
		Damage=210 //200
		DamageRadius=750
		DamageFalloffExponent=1.0
		MomentumTransferScale=200000.0
		MyDamageType=Class'KFDT_Microwave_Blast'
		ParticleEmitterTemplate=ParticleSystem'WEP_Microwave_Gun_EMIT.FX_Microwave_Blast_01'
	End Object
	ExplosionTemplate=ExploTemplate0

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_Fire_1P_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_Fire_Secondary_3P', FirstPersonCue=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_Fire_Secondary_1P')
    WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_Fire_3P_LoopEnd', FirstPersonCue=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_Fire_1P_LoopEnd')

	//@todo: add akevents when we have them
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_DryFire'
	PilotLightPlayEvent=AkEvent'WW_WEP_SA_Microwave_Gun.Play_SA_MicrowaveGun_PilotLight_Loop'
	PilotLightStopEvent=AkEvent'WW_WEP_SA_Microwave_Gun.Stop_SA_MicrowaveGun_PilotLight_Loop'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=FIREMODE_NONE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

   	AssociatedPerkClasses(0)=class'KFPerk_Firebug'

   	BonesToLockOnEmpty=(RW_Handle1, RW_BatteryCylinder1, RW_BatteryCylinder2, RW_LeftArmSpinner, RW_RightArmSpinner, RW_LockEngager2, RW_LockEngager1)

 	// AI Warning
 	bWarnAIWhenFiring=true
    MaxAIWarningDistSQ=2250000

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.15f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
}