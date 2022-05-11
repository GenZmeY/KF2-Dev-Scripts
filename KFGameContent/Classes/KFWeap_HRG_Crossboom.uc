//=============================================================================
// KFWeap_HRG_Crossboom
//=============================================================================
// A crossbow but with extra explosions
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_HRG_Crossboom extends KFWeap_ScopedBase;

/** Reduction for the amount of damage dealt to the weapon owner (including damage by the explosion) */
var() float SelfDamageReductionValue;

/** Return true if this weapon should play the fire last animation for this shoot animation */
simulated function bool ShouldPlayFireLast(byte FireModeNum)
{
    if( SpareAmmoCount[GetAmmoType(FireModeNum)] == 0 )
    {
        return true;
    }

    return false;
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName( bool bTacticalReload )
{
	if ( AmmoCount[0] > 0 )
	{
		// Disable half-reloads for now.  This can happen if server gets out
		// of sync, but choosing the wrong animation will just make it worse!
		`warn("Grenade launcher reloading with non-empty mag");
	}

	return bTacticalReload ? ReloadEmptyMagEliteAnim : ReloadEmptyMagAnim;
}

/** Returns trader filter index based on weapon type (copied from riflebase) */
static simulated event EFilterTypeUI GetTraderFilter()
{
    return FT_Projectile;
}

/** Instead of switch fire mode use as immediate alt fire */
simulated function AltFireMode()
{
	// StartFire - StopFire called from KFPlayerInput
	StartFire(ALTFIRE_FIREMODE);
}

/**
	Reduce the damage received and apply it to the shield
 */
function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
	super.AdjustDamage(InDamage, DamageType, DamageCauser);

	if (Instigator != none && DamageCauser.Instigator == Instigator)
	{
		InDamage *= SelfDamageReductionValue;
	}
}

defaultproperties
{
	// Inventory
	InventorySize=7
	GroupPriority=70
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_Crossboom_TEX.UI_WeaponSelect_Crossboom'
   	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'

    // FOV / Position
    MeshFOV=70
	MeshIronSightFOV=52
    PlayerIronSightFOV=70
	PlayerViewOffset=(X=1,Y=8,Z=-5)
	IronSightPosition=(X=-13,Y=0,Z=-0.061)

	// AI warning system
	bWarnAIWhenAiming=true
    MaxAIWarningDistSQ=4000000
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

// SCOPE
    // 2D scene capture
	Begin Object Name=SceneCapture2DComponent0
	   TextureTarget=TextureRenderTarget2D'Wep_Mat_Lib.WEP_ScopeLense_Target'
	   FieldOfView=18.5 // "2.0X" = 37(our real world FOV determinant)/2.0
	End Object

	ScopedSensitivityMod=12.0

	ScopeLenseMICTemplate=MaterialInstanceConstant'WEP_1P_HRG_Crossboom_MAT.WEP_1P_HRG_Crossboom_Scope_MAT'
	ScopeMICIndex = 1

//

	// Depth of field
	DOF_BlendInSpeed=3.0
	DOF_FG_FocalRadius=0.0
	DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey="HRG_Crossboom"
	FirstPersonMeshName="WEP_1P_HRG_Crossboom_MESH.Wep_1stP_HRG_Crossboom_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_Crossboom_ANIM.Wep_1stP_HRG_Crossboom_Anim"
	PickupMeshName="WEP_3P_HRG_Crossboom_MESH.Wep_HRG_Crossboom_Pickup"
	AttachmentArchetypeName="WEP_HRG_Crossboom_ARCH.Wep_Crossboom_3P"
	MuzzleFlashTemplateName="WEP_HRG_Crossboom_ARCH.Wep_Crossboom_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=38
	InitialSpareMags[0]=11
	AmmoPickupScale[0]=4.0 // 4 arrows
	bCanBeReloaded=true
	bReloadFromMagazine=true // reloading from mag is one step, while NOT reloading from mag is multi-step (open bolt, load ammo, close bolt) and not applicable for bow

	// Recoil
	maxRecoilPitch=200
	minRecoilPitch=150
	maxRecoilYaw=100
	minRecoilYaw=-100
	RecoilRate=0.06
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=50
	RecoilISMinYawLimit=65485
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletArrow'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFireAndReload
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bolt_HRG_Crossboom'
	InstantHitDamage(DEFAULT_FIREMODE)=10.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Piercing_HRG_Crossboom'
	PenetrationPower(DEFAULT_FIREMODE)=0.0
	FireInterval(DEFAULT_FIREMODE)=0.3 // For this weapon, this is not the fire rate, but the time when the auto reload anim kicks in
	Spread(DEFAULT_FIREMODE)=0.007 //0.007
	FireOffset=(X=25,Y=3.0,Z=-4.0)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletArrow'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFireAndReload
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bolt_HRG_CrossboomAlt'
	InstantHitDamage(ALTFIRE_FIREMODE)=10.0
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Piercing_HRG_Crossboom'
	PenetrationPower(ALTFIRE_FIREMODE)=0.0
	FireInterval(ALTFIRE_FIREMODE)=0.3 // For this weapon, this is not the fire rate, but the time when the auto reload anim kicks in
	Spread(ALTFIRE_FIREMODE)=0.007 //0.007

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_DryFire'
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_Fire_1P')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_HRG_Crossboom.Play_WEP_HRG_Crossboom_DryFire'


	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_Crossboom'
	InstantHitDamage(BASH_FIREMODE)=26

	// Custom animations
	FireSightedAnims=(Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	BonesToLockOnEmpty=(RW_Cable_Parent)

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Just like the launchers, this weapon has mag size of 1 and force reload which
	// causes significant ammo sync issues.  This fix is far from perfect, but it helps.
	bAllowClientAmmoTracking=true

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.2f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.6f,IncrementWeight=3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Damage1, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))

	SelfDamageReductionValue = 0.25f;
}