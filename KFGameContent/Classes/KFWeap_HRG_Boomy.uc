//=============================================================================
// KFWeap_HRG_Boomy
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeap_HRG_Boomy extends KFWeap_SMGBase;

/**
 * Overriden to use instant hit vfx. 
 * Basically, calculate the hit location so vfx can play
 */
 simulated function Projectile ProjectileFire()
{
	local vector		StartTrace, EndTrace, RealStartLoc, AimDir;
	local ImpactInfo	TestImpact;
	local vector DirA, DirB;
	local Quat Q;
	local class<KFProjectile> MyProjectileClass;

    MyProjectileClass = GetKFProjectileClass();

	// This is where we would start an instant trace. (what CalcWeaponFire uses)
	StartTrace = GetSafeStartTraceLocation();
	AimDir = Vector(GetAdjustedAim( StartTrace ));

	// this is the location where the projectile is spawned.
	RealStartLoc = GetPhysicalFireStartLoc(AimDir);

	// if projectile is spawned at different location of crosshair,
	// then simulate an instant trace where crosshair is aiming at, Get hit info.
	EndTrace = StartTrace + AimDir * GetTraceRange();
	TestImpact = CalcWeaponFire( StartTrace, EndTrace );

	// Set flash location to trigger client side effects.  Bypass Weapon.SetFlashLocation since
	// that function is not marked as simulated and we want instant client feedback.
	// ProjectileFire/IncrementFlashCount has the right idea:
	//	1) Call IncrementFlashCount on Server & Local
	//	2) Replicate FlashCount if ( !bNetOwner )
	//	3) Call WeaponFired() once on local player
	if( Instigator != None )
	{
		Instigator.SetFlashLocation( Self, CurrentFireMode, TestImpact.HitLocation );
	}

	if( Role == ROLE_Authority || (MyProjectileClass.default.bUseClientSideHitDetection
        && MyProjectileClass.default.bNoReplicationToInstigator && Instigator != none
        && Instigator.IsLocallyControlled()) )
	{

		if( StartTrace != RealStartLoc )
		{	
			// Store the original aim direction without correction
            DirB = AimDir;

			// Then we realign projectile aim direction to match where the crosshair did hit.
			AimDir = Normal(TestImpact.HitLocation - RealStartLoc);

            // Store the desired corrected aim direction
    		DirA = AimDir;

    		// Clamp the maximum aim adjustment for the AimDir so you don't get wierd
    		// cases where the projectiles velocity is going WAY off of where you
    		// are aiming. This can happen if you are really close to what you are
    		// shooting - Ramm
    		if ( (DirA dot DirB) < MaxAimAdjust_Cos )
    		{
    			Q = QuatFromAxisAndAngle(Normal(DirB cross DirA), MaxAimAdjust_Angle);
    			AimDir = QuatRotateVector(Q,DirB);
    		}
		}

		return SpawnAllProjectiles(MyProjectileClass, RealStartLoc, AimDir);
	}

	return None;
}


defaultproperties
{
	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Charging_Handle)

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

    // FOV
    MeshFOV=75
	MeshIronSightFOV=52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=2.5

	// Content
	PackageKey="HRG_Boomy"
	FirstPersonMeshName="WEP_1P_HRG_Boomy_MESH.Wep_1stP_HRG_Boomy_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_Boomy_ANIM.WEP_1stP_HRG_Boomy_Anim"
	PickupMeshName="WEP_3P_HRG_Boomy_MESH.Wep_3rdP_HRG_Boomy_Pickup"
	AttachmentArchetypeName="WEP_HRG_Boomy_ARCH.Wep_HRG_Boomy_3P"
	MuzzleFlashTemplateName="WEP_HRG_Boomy_ARCH.Wep_HRG_Boomy_MuzzleFlash"


   	// Zooming/Position
	PlayerViewOffset=(X=5.0,Y=9,Z=-5)
	IronSightPosition=(X=5,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=24
	SpareAmmoCapacity[0]=192
	InitialSpareMags[0]=1
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=325 //325 //130 //165
	minRecoilPitch=300 //275 //115 //130
	maxRecoilYaw=140 //150 //115  //130
	minRecoilYaw=-140 //-150 //-115 //130
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

    // Inventory / Grouping
	InventorySize=7
	GroupPriority=50
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_Boomy_TEX.UI_WeaponSelect_HRG_Boomy'

	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_HRG_Boomy'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRG_Boomy'
	FireInterval(DEFAULT_FIREMODE)=+0.1667 // 360 RPM
	Spread(DEFAULT_FIREMODE)=0.01 //0.025
	InstantHitDamage(DEFAULT_FIREMODE)=25.0
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_HRG_Boomy'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRG_Boomy'
	FireInterval(ALTFIRE_FIREMODE)=+0.1667 // 360 RPM
	InstantHitDamage(ALTFIRE_FIREMODE)=25.0
	Spread(ALTFIRE_FIREMODE)=0.01 //0.025

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_Boomy'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'ww_wep_hrg_boomy.Play_WEP_HRG_Boomy_3P_ShootLoop', FirstPersonCue=AkEvent'ww_wep_hrg_boomy.Play_WEP_HRG_Boomy_1P_ShootLoop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'ww_wep_hrg_boomy.Play_WEP_HRG_Boomy_3P_Shoot', FirstPersonCue=AkEvent'ww_wep_hrg_boomy.Play_WEP_HRG_Boomy_1P_Shoot')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'ww_wep_hrg_boomy.Play_WEP_HRG_Boomy_3P_ShootLoopEnd', FirstPersonCue=AkEvent'ww_wep_hrg_boomy.Play_WEP_HRG_Boomy_1P_ShootLoopEnd')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Damage1, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.45f), (Stat=EWUS_Damage1, Scale=1.45f), (Stat=EWUS_Weight, Add=3)))
}
