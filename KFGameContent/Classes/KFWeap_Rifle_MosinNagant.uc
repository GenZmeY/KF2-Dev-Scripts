//=============================================================================
// KFWeap_Rifle_MosinNagant
//=============================================================================
// A Mosin-Nagant Rifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Rifle_MosinNagant extends KFWeap_MeleeBase;

var float LastFireInterval;

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Rifle;
}

/**
 * See Pawn.ProcessInstantHit
 * @param DamageReduction: Custom KF parameter to handle penetration damage reduction
 */
simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum)
{
	local KFPerk InstigatorPerk;

	InstigatorPerk = GetPerk();
	if (InstigatorPerk != none)
	{
		InstigatorPerk.UpdatePerkHeadShots(Impact, InstantHitDamageTypes[FiringMode], ImpactNum);
	}

	super.ProcessInstantHitEx(FiringMode, Impact, NumHits, out_PenetrationVal, ImpactNum);
}

/** process local player impact for clientside hit detection */
event RecieveClientImpact(byte FiringMode, const out ImpactInfo Impact, optional out float PenetrationValue, optional int ImpactNum)
{
	// skip KFWeap_MeleeBase because it does melee stuff
	super(KFWeapon).RecieveClientImpact(FiringMode, Impact, PenetrationValue, ImpactNum);
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

/** Save off the start time for the bash to determine whether this will be a normal stab or a bullet stab */
simulated function StartFire(byte FireModeNum)
{
	// copying over auto reload functionality since MeleeBase overrides this by default
	if (FireModeNum == DEFAULT_FIREMODE && ShouldAutoReload(FireModeNum))
	{
		FireModeNum = RELOAD_FIREMODE;
	}

	if (FireModeNum == RELOAD_FIREMODE)
	{
		// Skip Super/ ServerStartFire and let server wait for ServerSendToReload to force state synchronization
		BeginFire(FireModeNum);
		return;
	}

	super.StartFire(FireModeNum);
}

/** Returns animation to play based on reload type and status */
simulated function name GetReloadAnimName(bool bTacticalReload)
{
	local name ReloadAnimName;

	if (AmmoCount[0] > 0)
	{
		// Mosin-Nagant uses a "stripper clip" so there are different animations depending on how many bullets are left in the current clip
		ReloadAnimName = (bTacticalReload) ? ReloadNonEmptyMagEliteAnim : ReloadNonEmptyMagAnim;
		ReloadAnimName = Name(ReloadAnimName$'_'$AmmoCount[0]);
		return ReloadAnimName;
	}
	else
	{
		return (bTacticalReload) ? ReloadEmptyMagEliteAnim : ReloadEmptyMagAnim;
	}
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

simulated function float GetFireInterval(byte FireModeNum)
{
	if (FireModeNum == DEFAULT_FIREMODE && AmmoCount[FireModeNum] == 0)
	{
		return LastFireInterval;
	}

	return super.GetFireInterval(FireModeNum);
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

/** Allows weapon to calculate its own damage for display in trader */
static simulated function float CalculateTraderWeaponStatDamage()
{
	local float BaseDamage, DoTDamage;
	local class<KFDamageType> DamageType;

	BaseDamage = default.InstantHitDamage[DEFAULT_FIREMODE];

	DamageType = class<KFDamageType>(default.InstantHitDamageTypes[DEFAULT_FIREMODE]);
	if (DamageType != none && DamageType.default.DoT_Type != DOT_None)
	{
		DoTDamage = (DamageType.default.DoT_Duration / DamageType.default.DoT_Interval) * (BaseDamage * DamageType.default.DoT_DamageScale);
	}

	return BaseDamage * default.NumPellets[DEFAULT_FIREMODE] + DoTDamage;
}

/** Allows weapon to calculate its own fire rate for display in trader */
static simulated function float CalculateTraderWeaponStatFireRate()
{
	return 60.f / default.FireInterval[DEFAULT_FIREMODE]; // attacks per minute
}

defaultproperties
{
	// MeleeBase
	bMeleeWeapon=false

	// Inventory / Grouping
	InventoryGroup=IG_Primary
	InventorySize=7
	GroupPriority=75
	WeaponSelectTexture = Texture2D'wep_ui_mosin_tex.UI_WeaponSelect_MosinNagant'

	// Perks
	AssociatedPerkClasses(0) = class'KFPerk_Sharpshooter'

	// FOV
	MeshFOV=65
	MeshIronSightFOV=45
	PlayerIronSightFOV=65

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey = "Mosin"
	FirstPersonMeshName="wep_1p_mosin_mesh.Wep_1stP_Mosin_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_mosin_anim.Wep_1stP_Mosin_ANIM"
	PickupMeshName="wep_3p_mosin_mesh.Wep_3rdP_Mosin_Pickup"
	AttachmentArchetypeName="WEP_Mosin_ARCH.Wep_Mosin_3P"
	MuzzleFlashTemplateName="WEP_Mosin_ARCH.Wep_Mosin_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=5
	SpareAmmoCapacity[0]=60
	InitialSpareMags[0]=5
	bCanBeReloaded=true
	bReloadFromMagazine=true // @TODO: Turn off once animations are done

	// Zooming/Position
	PlayerViewOffset = (X = 8.0,Y = 7,Z = -3.5)
	IronSightPosition = (X = 0,Y = 0,Z = 0)

	// AI warning system
	bWarnAIWhenAiming = true
	AimWarningDelay = (X = 0.4f, Y = 0.8f)
	AimWarningCooldown = 0.0f

	// Recoil
	maxRecoilPitch = 550
	minRecoilPitch = 400
	maxRecoilYaw = 150
	minRecoilYaw = -150
	RecoilRate = 0.08
	RecoilMaxYawLimit = 500
	RecoilMinYawLimit = 65035
	RecoilMaxPitchLimit = 1250
	RecoilMinPitchLimit = 64785
	RecoilISMaxYawLimit = 50
	RecoilISMinYawLimit = 65485
	RecoilISMaxPitchLimit = 500
	RecoilISMinPitchLimit = 65485
	RecoilViewRotationScale = 0.6
	IronSightMeshFOVCompensationScale = 1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_MosinNagant'
	InstantHitDamage(DEFAULT_FIREMODE)=250
	InstantHitDamageTypes(DEFAULT_FIREMODE) = class'KFDT_Ballistic_MosinNagant'
	FireInterval(DEFAULT_FIREMODE)=0.85 // 60 RPM
	Spread(DEFAULT_FIREMODE)=0.007
	PenetrationPower(DEFAULT_FIREMODE)=3
	FireOffset = (X = 25,Y = 3.0,Z = -2.5)
	AmmoCost(DEFAULT_FIREMODE)=1
	LastFireInterval=0.5

	// RELOAD_FIREMODE
	FiringStatesArray(RELOAD_FIREMODE)="Reloading"
	WeaponFireTypes(RELOAD_FIREMODE)=EWFT_InstantHit

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_MosinNagant'
	InstantHitDamage(BASH_FIREMODE)=100
	FiringStatesArray(BASH_FIREMODE)=MeleeAttackBasic
	WeaponFireTypes(BASH_FIREMODE)=EWFT_Custom
	InstantHitMomentum(BASH_FIREMODE)=10000.f

	// Custom animations
	FireSightedAnims = (Shoot_Iron, Shoot_Iron2, Shoot_Iron3)
	BonesToLockOnEmpty = (RW_Bolt_Back)
	bHasFireLastAnims = true
	bUseAdditiveMoveAnim = false // @TODO: Remove

	// Defensive
	BlockDamageMitigation=0.6f
	ParryDamageMitigationPercent=0.5
	ParryStrength=4

	// Block Effects
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Hammer'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Wood'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE) = (DefaultCue = AkEvent'WW_WEP_MosinNagant.Play_MosinNagant_Shoot_3P', FirstPersonCue = AkEvent'WW_WEP_MosinNagant.Play_MosinNagant_Shoot_1P') // @TODO: Replace Me
	WeaponDryFireSnd(DEFAULT_FIREMODE) = AkEvent'WW_WEP_MosinNagant.Play_MosinNagant_DryFire' // @TODO: Replace Me
	EjectedShellForegroundDuration = 1.5f

	// Attachments
	bHasIronSights = true
	bHasFlashlight = false

	WeaponFireWaveForm = ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	// Aim Assist
	AimCorrectionSize=40.f

	// Melee hitbox
	Begin Object Name=MeleeHelper_0
		MaxHitRange=250
		HitboxChain.Add((BoneOffset=(X=-3,Z=250)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=230)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=210)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=190)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=170)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=150)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=130)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=110)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=90)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=70)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=50)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=30)))
		HitboxChain.Add((BoneOffset=(Z=10)))
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Bladed_melee_impact'
		MeleeImpactCamShakeScale=0.03f
	End Object

	// Weapon Upgrades
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Damage1, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
}