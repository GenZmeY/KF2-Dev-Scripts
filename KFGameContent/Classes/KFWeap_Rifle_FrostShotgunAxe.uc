//=============================================================================
// KFWeap_Rifle_FrostShotgunAxe
//=============================================================================
// A Rifle with an axe that freezes enemies
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Rifle_FrostShotgunAxe extends KFWeap_MeleeBase;

var float LastFireInterval;
var int iInstantHitDamageOnEnemyFrozen;
var int iNormalInstantHitDamage;

/** Returns trader filter index based on weapon type */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Rifle;
}

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
	iNormalInstantHitDamage = InstantHitDamage[BASH_FIREMODE];
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
	if( FireModeNum == BASH_FIREMODE && WeaponFireTypes[FireModeNum] == EWFT_Custom )
	{
		super.StartMeleeFire(FireModeNum, MeleeAttackHelper.ChooseAttackDir(), ATK_Normal);
		return;
	}
	super.StartFire(FireModeNum);
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
	simulated function BeginState(name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		if (bUsingSights)
		{
			SetIronSights(false);
		}
	}
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

/** returns the damage amount for this attack */
simulated function int GetMeleeDamage(byte FireModeNum, optional vector RayDir)
{
	local KFMeleeHelperWeaponFrostShotgunAxe oHelper;
	local int Damage;
	oHelper = KFMeleeHelperWeaponFrostShotgunAxe(MeleeAttackHelper);
	if(oHelper.IsEnemyIced())
	{
		InstantHitDamage[FireModeNum] = iInstantHitDamageOnEnemyFrozen;
	}
	else
	{
		InstantHitDamage[FireModeNum] = iNormalInstantHitDamage;
	}
	Damage = Super.GetMeleeDamage(FireModeNum, RayDir);
	return Damage;
}



simulated function int GetModifiedDamage(byte FireModeNum, optional vector RayDir)
{
	switch(FireModeNum)
	{
		case DEFAULT_FIREMODE:
			return GetUpgradedStatValue(InstantHitDamage[FireModeNum], EWUS_Damage0 , CurrentWeaponUpgradeIndex);
		break;
		case ALTFIRE_FIREMODE:
			return GetUpgradedStatValue(InstantHitDamage[FireModeNum], EWUS_Damage1 , CurrentWeaponUpgradeIndex);
		break;
		case BASH_FIREMODE:
			return GetUpgradedStatValue(InstantHitDamage[FireModeNum], EWUS_Damage2 , CurrentWeaponUpgradeIndex);
		break;
	}
	return GetUpgradedStatValue(InstantHitDamage[FireModeNum], EWUS_Damage0 , CurrentWeaponUpgradeIndex);
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

/** Spawn projectile is called once for each shot pellet fired */
simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local KFPerk InstigatorPerk;

	if (CurrentFireMode == GRENADE_FIREMODE)
	{
		return Super.SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
	}

	InstigatorPerk = GetPerk();
	if (InstigatorPerk != none)
	{
		Spread[CurrentFireMode] = default.Spread[CurrentFireMode] * InstigatorPerk.GetTightChokeModifier();
	}

	return super.SpawnAllProjectiles(KFProjClass, RealStartLoc, AimDir);
}

/** Plays a 'settle' animation after a melee attack is finished */
simulated function PlayMeleeSettleAnim()
{
	PlayAnimation(MeleeAttackSettleAnims[0], 0.0, false, 0.1);
}

defaultproperties
{
	// MeleeBase
	bMeleeWeapon=true

	// Inventory / Grouping
	InventoryGroup=IG_Primary
	InventorySize=7
	GroupPriority=80 //75
	WeaponSelectTexture = Texture2D'WEP_UI_Frost_Shotgun_Axe_TEX.UI_WeaponSelect_FrostGun'
	// Perks
	AssociatedPerkClasses(0)=class'KFPerk_Support'
	AssociatedPerkClasses(1)=class'KFPerk_Berserker'

	// FOV
	MeshFOV=65
	MeshIronSightFOV=45
	PlayerIronSightFOV=65

	// Depth of field
	DOF_FG_FocalRadius=50
	DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey = "Frost_Shotgun_Axe"
	FirstPersonMeshName="WEP_1P_Frost_Shotgun_Axe_MESH.Wep_1stP_Frost_Shotgun_Axe_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Frost_Shotgun_Axe_ANIM.WEP_1stP_Frost_Shotgun_Axe"
	PickupMeshName="WEP_3P_Frost_Shotgun_Axe_MESH.Wep_3rdP_Frost_Shotgun_Pickup"
	AttachmentArchetypeName="WEP_Frost_Shotgun_Axe_ARCH.Wep_Frost_Shotgun_Axe_3P"
	MuzzleFlashTemplateName="WEP_Frost_Shotgun_Axe_ARCH.Wep_Frost_Shotgun_Axe_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=6
	SpareAmmoCapacity[0]=66
	InitialSpareMags[0]=4
	AmmoPickupScale[0]=1
	bCanBeReloaded=true
	bReloadFromMagazine=false // @TODO: Turn off once animations are done

	// Zooming/Position
	PlayerViewOffset = (X = 8.0,Y = 7,Z = -3.5)
	IronSightPosition = (X = 0,Y = 0,Z = 0)

	// AI warning system
	bWarnAIWhenAiming = true
	AimWarningDelay = (X = 0.4f, Y = 0.8f)
	AimWarningCooldown = 0.0f

	// Recoil
	maxRecoilPitch = 1050 //550
	minRecoilPitch = 900 //400
	maxRecoilYaw = 350 //150
	minRecoilYaw = -350 //-150
	RecoilRate = 0.075
	RecoilMaxYawLimit = 500
	RecoilMinYawLimit = 65035
	RecoilMaxPitchLimit = 900
	RecoilMinPitchLimit = 64785
	RecoilISMaxYawLimit = 50
	RecoilISMinYawLimit = 65485
	RecoilISMaxPitchLimit = 500
	RecoilISMinPitchLimit = 65485
	RecoilViewRotationScale = 0.6

	FallingRecoilModifier=1.5
	HippedRecoilModifier=1.3

	IronSightMeshFOVCompensationScale = 1.5

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Frost_Shotgun_Axe'
	InstantHitDamage(DEFAULT_FIREMODE)=30 //32 //30
	InstantHitDamageTypes(DEFAULT_FIREMODE) = class'KFDT_Ballistic_Frost_Shotgun_Axe'
	FireInterval(DEFAULT_FIREMODE)=0.5 //0.25 // 240 RPM
	Spread(DEFAULT_FIREMODE)=0.13 //0.007
	PenetrationPower(DEFAULT_FIREMODE)=2
	FireOffset = (X = 25,Y = 3.0,Z = -2.5)
	NumPellets(DEFAULT_FIREMODE)=7
	AmmoCost(DEFAULT_FIREMODE)=1
	LastFireInterval=0.5

	// RELOAD_FIREMODE
	FiringStatesArray(RELOAD_FIREMODE)="Reloading"
	WeaponFireTypes(RELOAD_FIREMODE)=EWFT_InstantHit

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Slashing_Frost_Shotgun_Axe'
	InstantHitDamage(BASH_FIREMODE)=75 //120
	FiringStatesArray(BASH_FIREMODE)=MeleeChainAttacking
	WeaponFireTypes(BASH_FIREMODE)=EWFT_Custom
	InstantHitMomentum(BASH_FIREMODE)=10000.f
	iInstantHitDamageOnEnemyFrozen = 185 //360; //300;

	// Custom animations
	FireSightedAnims = (Shoot_Iron)
	BonesToLockOnEmpty = (RW_Hammer)
	bHasFireLastAnims = true

	// Defensive
	BlockDamageMitigation=0.6f
	ParryDamageMitigationPercent=0.5
	ParryStrength=4

	// Block Effects
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Hammer'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Wood'

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE) = (DefaultCue = AkEvent'WW_WEP_FrostFang.Play_FrostFang_Shoot_3p', FirstPersonCue = AkEvent'WW_WEP_FrostFang.Play_FrostFang_Shoot_1p') // @TODO: Replace Me
	WeaponDryFireSnd(DEFAULT_FIREMODE) = AkEvent'WW_WEP_FrostFang.Play_FrostFang_Dryfire' // @TODO: Replace Me
	EjectedShellForegroundDuration = 1.5f

	// Attachments
	bHasIronSights = true
	bHasFlashlight = false

	WeaponFireWaveForm = ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Medium_Recoil'

	// Aim Assist
	AimCorrectionSize=40.f

	// Melee


	// Melee hitbox
	Begin Object Class=KFMeleeHelperWeaponFrostShotgunAxe Name=MeleeHelper_0
		MaxHitRange=250
		HitboxChain.Add((BoneOffset=(X=+3,Z=-190)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=-170)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=-150)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=-130)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=-110)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=-90)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=-70)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=-50)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=-30)))
		HitboxChain.Add((BoneOffset=(Z=10)))
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Bladed_melee_impact'
		MeleeImpactCamShakeScale=0.03f
		bUseDirectionalMelee=true
		bHasChainAttacks=true
		bUseMeleeHitTimer=false
		// modified combo sequences
		ChainSequence_F=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardRight, DIR_ForwardLeft, DIR_BackwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L=(DIR_Right, DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
		ChainSequence_R=(DIR_Left, DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object
	MeleeAttackHelper=MeleeHelper_0

	// Weapon Upgrades
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.125f), (Stat=EWUS_Damage1, Scale=1.125f), (Stat=EWUS_Damage2, Scale=1.1f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.25f), (Stat=EWUS_Damage1, Scale=1.25f), (Stat=EWUS_Damage2, Scale=1.2f), (Stat=EWUS_Weight, Add=2)))

	bHasToBeConsideredAsRangedWeaponForPerks=true;
}