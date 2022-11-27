//=============================================================================
// KFWeap_HRG_MedicMissile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_HRG_MedicMissile extends KFWeap_GrenadeLauncher_Base;

/** Back blash explosion template. */
var() GameExplosion ExplosionTemplate;

/** Holds an offest for spawning back blast effects. */
var()			vector	BackBlastOffset;

/** Fires a projectile, but also does the back blast */
simulated function CustomFire()
{
	local KFExplosionActorReplicated ExploActor;
	local vector SpawnLoc;
	local rotator SpawnRot;

    ProjectileFire();

	if ( Instigator.Role < ROLE_Authority )
	{
		return;
	}

	GetBackBlastLocationAndRotation(SpawnLoc, SpawnRot);

	// explode using the given template
	ExploActor = Spawn(class'KFExplosionActorReplicated', self,, SpawnLoc, SpawnRot,, true);
	if (ExploActor != None)
	{
		ExploActor.InstigatorController = Instigator.Controller;
		ExploActor.Instigator = Instigator;

		// So we get backblash decal from this explosion
		ExploActor.bTraceForHitActorWhenDirectionalExplosion = true;

		ExploActor.Explode(ExplosionTemplate, vector(SpawnRot));
	}

	if ( bDebug )
	{
        DrawDebugCone(SpawnLoc, vector(SpawnRot), ExplosionTemplate.DamageRadius, ExplosionTemplate.DirectionalExplosionAngleDeg * DegToRad,
			ExplosionTemplate.DirectionalExplosionAngleDeg * DegToRad, 16, MakeColor(64,64,255,0), TRUE);
	}
}

/**
 * This function returns the world location for spawning back blast and the direction to send the back blast in
 */
simulated function GetBackBlastLocationAndRotation(out vector BlastLocation, out rotator BlastRotation)
{
    local vector X, Y, Z;
    local Rotator ViewRotation;

	if( Instigator != none )
	{
        if( bUsingSights )
        {
            ViewRotation = Instigator.GetViewRotation();

        	// Add in the free-aim rotation
        	if ( KFPlayerController(Instigator.Controller) != None )
        	{
        		ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
        	}

            GetAxes(ViewRotation, X, Y, Z);

            BlastRotation = Rotator(Vector(ViewRotation) * -1);
            BlastLocation =  Instigator.GetWeaponStartTraceLocation() + X * BackBlastOffset.X;
		}
		else
		{
            ViewRotation = Instigator.GetViewRotation();

        	// Add in the free-aim rotation
        	if ( KFPlayerController(Instigator.Controller) != None )
        	{
        		ViewRotation += KFPlayerController(Instigator.Controller).WeaponBufferRotation;
        	}

            BlastRotation = Rotator(Vector(ViewRotation) * -1);
            BlastLocation = Instigator.GetPawnViewLocation() + (BackBlastOffset >> ViewRotation);
		}
	}
}

/** Locks the bolt bone in place to the open position (Called by animnotify) */
simulated function ANIMNOTIFY_LockBolt()
{
	// Consider us empty after every shot so the rocket gets hidden
	EmptyMagBlendNode.SetBlendTarget(1, 0);
}

defaultproperties
{
	ForceReloadTime=0.4f

	// Inventory
	InventoryGroup=IG_Primary
	GroupPriority=100
	InventorySize=7
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_MedicMissile_TEX.UI_WeaponSelect_HRG_MedicMissile'

    // FOV
	MeshFOV=75
	MeshIronSightFOV=65
	PlayerIronSightFOV=70
	PlayerSprintFOV=95

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_MaxNearBlurSize=2.5

	// Zooming/Position
	PlayerViewOffset=(X=10.0,Y=10,Z=-2)
	FastZoomOutTime=0.2

	// Content
	PackageKey="HRG_MedicMissile"
	FirstPersonMeshName="WEP_1P_HRG_MedicMissile_MESH.Wep_1stP_HRG_MedicMissile_Rig" 
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_MedicMissile_ANIM.Wep_1stP_HRG_MedicMissile_Anim"
	PickupMeshName="WEP_3P_HRG_MedicMissile_MESH.Wep_HRG_MedicMissile_Pickup"
	AttachmentArchetypeName="WEP_HRG_MedicMissile_ARCH.Wep_HRG_MedicMissile_3P"  
	MuzzleFlashTemplateName="WEP_HRG_MedicMissile_ARCH.Wep_HRG_MedicMissile_MuzzleFlash"

   	// Zooming/Position
	IronSightPosition=(X=0,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=22
	InitialSpareMags[0]=6
	AmmoPickupScale[0]=4.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=800
	minRecoilPitch=675
	maxRecoilYaw=400
	minRecoilYaw=-400
	RecoilRate=0.085
	RecoilBlendOutRatio=0.35
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=1500
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=500
	RecoilISMinPitchLimit=65485
	RecoilViewRotationScale=0.8
	FallingRecoilModifier=1.5
	HippedRecoilModifier=1.25

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'UI_FireModes_TEX.UI_FireModeSelect_Rocket'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFireAndReload
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Rocket_HRG_MedicMissile'
	FireInterval(DEFAULT_FIREMODE)=+0.25
	InstantHitDamage(DEFAULT_FIREMODE)=100.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRG_MedicMissile'
	Spread(DEFAULT_FIREMODE)=0.025
	FireOffset=(X=20,Y=4.0,Z=-3)
	BackBlastOffset=(X=-20,Y=4.0,Z=-3)

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// Back blash explosion settings.  Using archetype so that clients can serialize the content
	// without loading the 1st person weapon content (avoid 'Begin Object')!
	ExplosionTemplate=KFGameExplosion'WEP_HRG_MedicMissile_ARCH.Wep_HRG_MedicMissile_BackBlastExplosion'

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_MedicMissile'
	InstantHitDamage(BASH_FIREMODE)=27

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_MedicMissile.Play_WEP_HRG_MedicMissile_3P_Shoot', FirstPersonCue=AkEvent'WW_WEP_HRG_MedicMissile.Play_WEP_HRG_MedicMissile_1P_Shoot')

	//@todo: add akevent when we have it
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_HRG_MedicMissile.Play_WEP_HRG_MedicMissile_DryFire'

	// Animation
	bHasFireLastAnims=true
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2)

	BonesToLockOnEmpty=(RW_Grenade1)

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil_SingleShot'

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.1f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.1f), (Stat=EWUS_Weight, Add=1)))
}