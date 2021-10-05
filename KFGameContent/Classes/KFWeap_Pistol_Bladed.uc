//=============================================================================
// KFWeap_Pistol_Bladed
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Pistol_Bladed extends KFWeap_MeleeBase;

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Pistol;
}

/** Override melee SetIronSights (which sends to heavy attack) so that this weapon ironsights normally*/
simulated function SetIronSights(bool bNewIronSights)
{
	super(KFWeapon).SetIronSights(bNewIronSights);
}

/** Override melee ShouldOwnerWalk which doesn't account for walking when in ironsights */
simulated function bool ShouldOwnerWalk()
{
	return super(KFWeapon).ShouldOwnerWalk();
}


/** Override to drop the player out of ironsights first */
simulated function AltFireMode()
{
	if (!Instigator.IsLocallyControlled())
	{
		return;
	}

	// break out of ironsights when starting to block
	if (bUsingSights)
	{
		SetIronSights(false);
	}

	StartFire(BLOCK_FIREMODE);
}

simulated state MeleeBlocking
{
	simulated function bool AllowIronSights() { return false; }
}

/** Called during reload state */
simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	if (FireModeNum == BLOCK_FIREMODE)
	{
		return true;
	}

	return super.CanOverrideMagReload(FireModeNum);
}

simulated function StartFire(byte FireModeNum)
{
	if( FireModeNum == DEFAULT_FIREMODE )
	{
		if ( ShouldAutoReload(FireModeNum) )
		{
			BeginFire(RELOAD_FIREMODE);
			return;
		}
	}

	super.StartFire(FireModeNum);
}

/*********************************************************************************************
 * @name	Firing / Projectile
********************************************************************************************* */
/**
 * See Pawn.ProcessInstantHit
 * @param DamageReduction: Custom KF parameter to handle penetration damage reduction
 */
simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum )
{
	local KFPerk InstigatorPerk;

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.UpdatePerkHeadShots( Impact, InstantHitDamageTypes[FiringMode], ImpactNum );
	}

	super.ProcessInstantHitEx( FiringMode, Impact, NumHits, out_PenetrationVal, ImpactNum );
}

defaultproperties
{
	// MeleeBase
	bMeleeWeapon=false
    // FOV
	MeshFOV=96
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Zooming/Position
	PlayerViewOffset=(X=-15,Y=12,Z=-6)
	IronSightPosition=(X=0,Y=0.05,Z=-1.2) //(X=0,Y=0,Z=1.0)

	// Content
	PackageKey="BladedPistol"
	FirstPersonMeshName="WEP_1P_BladedPistol_MESH.WEP_1stP_BladedPistol_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_BladedPistol_ANIM.WEP_1stP_BladedPistol_Anim"
	PickupMeshName="WEP_3P_BladedPistol_MESH.Wep_BladedPistol_Pickup"
	AttachmentArchetypeName="WEP_BladedPistol_ARCH.Wep_BladedPistol_3P"
	MuzzleFlashTemplateName="WEP_BladedPistol_ARCH.Wep_BladedPistol_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=6
	SpareAmmoCapacity[0]=66 //72
	InitialSpareMags[0]=2
	AmmoPickupScale[0]=1.0 //2.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=330 //400 //250
	minRecoilPitch=300 //350 //200
	maxRecoilYaw=90 //120 //100
	minRecoilYaw=-90 //-120 //-100
	RecoilRate=0.07
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=250
	RecoilISMinPitchLimit=65485

	// DEFAULT_FIREMODE
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Blade_BladedPistol'
    PenetrationPower(DEFAULT_FIREMODE)=3.0
	FireInterval(DEFAULT_FIREMODE)=+0.25 //+0.3
	InstantHitDamage(DEFAULT_FIREMODE)=115.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_BladedPistol'
	Spread(DEFAULT_FIREMODE)=0.005 //0.015
	AmmoCost(DEFAULT_FIREMODE)=1

	FireOffset=(X=30,Y=5,Z=-4)

	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Sawblade'

	// ALT_FIREMODE
	// FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	// WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_BladedPistol'
	InstantHitDamage(BASH_FIREMODE)=75 //26
	FiringStatesArray(BASH_FIREMODE)=MeleeAttackBasic
	WeaponFireTypes(BASH_FIREMODE)=EWFT_Custom
	InstantHitMomentum(BASH_FIREMODE)=10000.f

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Handling_DryFire'

	// RELOAD_FIREMODE
	FiringStatesArray(RELOAD_FIREMODE)="Reloading"
	WeaponFireTypes(RELOAD_FIREMODE)=EWFT_InstantHit

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'
	AssociatedPerkClasses(1)=class'KFPerk_Berserker'
	

	// Inventory
	InventoryGroup=IG_Secondary
	InventorySize=3
	GroupPriority=25
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_BladedPistol_TEX.UI_WeaponSelect_BladedPistol'
	bIsBackupWeapon=false

	DualClass=class'KFWeap_Pistol_DualBladed'

	// Custom animations
	FireSightedAnims=(Shoot_Iron)
	IdleFidgetAnims=(Guncheck_v1, Guncheck_v2, Guncheck_v3)

	bHasFireLastAnims=true

	BonesToLockOnEmpty=(RW_FrontPivot)

	// default MIC param names
	BlockEffectsSocketName=BlockEffect
	// Defensive
	BlockDamageMitigation=0.70f //0.60f
	ParryDamageMitigationPercent=0.6 //0.5
	ParryStrength=3 //4
	BlockHitAnimCooldownTime=0.5f
	BlockTypes.Add((DmgType=class'KFDT_Bludgeon'))
	BlockTypes.Add((DmgType=class'KFDT_Slashing'))

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Crovel'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	BlockParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Block_melee_01'
	ParryParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Parry_melee_01'
	MeleeBlockHitAnims=(Block_Hit_V1, Block_Hit_V2, Block_Hit_V3);

	//Upgrades
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Damage2, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Damage1, Scale=1.3f),  (Stat=EWUS_Damage2, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
}

