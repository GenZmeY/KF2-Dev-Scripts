//=============================================================================
// KFWeap_HRG_BarrierRifle
//=============================================================================
// A modified version of the Stoner63A rifle. 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFWeap_HRG_BarrierRifle extends KFWeap_LMG_Stoner63A;

`define BARRIERRIFLE_MIC_SHIELD_INDEX 4

/** Amount of shield charge that is consumed per second */
var (Shield) float ShieldConsumptionPerSecond;

/** Amount of shield chared that is recharged per second */
var (Shield) float ShieldRechargePerSecond;

/** Cooldown to apply after the shield is destroyed */
var (Shield) float CooldownAfterShieldDepleted;

/** Cooldown to apply after the shield depleted the charge */
var (Shield) float CooldownAfterShieldDestroyed;

/** VFX and SFX for blocking damage */
var (Shield) AkBaseSoundObject BlockSound;
var (Shield) ParticleSystem BlockParticleSystem;
var (Shield) name BlockEffectsSocketName;

/** Blocking information per damage type */
var (Shield) array<BlockEffectInfo> BlockDamageTypes;

/** Modifier applied to the damage received by the character */
var (Shield) float BlockDamageModifier;

/** Modifier applied to the damager that will affect the shield charge */
var (Shield) float ShieldDamageAbsorbtionModifier;

/** Angle to block with the shield */
var (Shield) float BlockingAngle;

/** Turn ON/OFF VFX duration */
var (Shield) float ShieldFXDuration;

/** Shield Block VFX duration */
var (Shield) float ShieldBlockVFXDuration;

/** Is shield active */
var protected transient bool bIsShieldActive;

/** Was shield charge depleted */
var protected transient bool bWasShieldDepleted;

/** Was the shield destroyed */
var protected transient bool bWasShielDestroyed;

/** Self explanatory */
var protected transient bool bCanRechargeShield;

/** float containing the shield charge to not be lost in the next frame
	due to int conversion.
 */
var protected transient float ShieldRechargeIncrement;
var protected transient float ShieldConsumptionIncrement;

/** Cos of the blocking angle (Rads) */
var protected transient float BlockingAngleCos;

/** Wether the timer for activating the shield has expired (using the fire interval) */
var protected transient bool bShieldActionAvailable;

/** Indicates wheter we are activating/deactivating the shield fx */
var protected bool bActivatingShield;
var protected bool bDeactivatingShield; 
var protected transient float FXDelta;

var transient float RedOverlayMax;
var transient float RedOverlayMin;
var protected transient float OverlayDelta;

var	WeaponFireSndInfo ShieldActivateSound;
var	WeaponFireSndInfo ShieldDeactivateSound;
var (Shield) AkBaseSoundObject ShieldEndSound;

var repnotify byte ShieldAmmo;

replication
{
	if (bNetDirty && Role == ROLE_Authority)
		bActivatingShield, bDeactivatingShield;

	if (bNetDirty && Role == ROLE_Authority && bAllowClientAmmoTracking)
		ShieldAmmo;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(ShieldAmmo))
	{
		AmmoCount[ALTFIRE_FIREMODE] = ShieldAmmo;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	BlockingAngleCos = cos((BlockingAngle / 2.f) * DegToRad);
}

simulated function Activate()
{
	super.Activate();

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		UpdateShieldFXValue(0.0f);
	}
}

simulated function UpdateShieldFXValue(float Value)
{
	if( WeaponMICs.Length > `BARRIERRIFLE_MIC_SHIELD_INDEX )
	{
		WeaponMICs[`BARRIERRIFLE_MIC_SHIELD_INDEX].SetScalarParameterValue('Opacity', Value);
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
	
	if( Role < Role_Authority )
	{
		// if we're a client, synchronize server
		UseShield();
	}

	CustomFire();
}

reliable server function UseShield()
{
	CustomFire();
}

/** Shield deploying */
simulated function CustomFire()
{
	if (bWasShieldDepleted || bWasShielDestroyed || !bShieldActionAvailable || AmmoCount[ALTFIRE_FIREMODE] == 0)
	{	
		return;
	}

	bIsShieldActive ? DeactivateShield() : ActivateShield(); 	
	bIsShieldActive = !bIsShieldActive;

	bShieldActionAvailable = false;
}

simulated function ActivateShield()
{
	PlaySoundBase(ShieldActivateSound.FirstPersonCue);
	bActivatingShield = true;
	bDeactivatingShield = false;
	bNetDirty = true;
	NotifyShieldActive(true);
	SetTimer(FireInterval[ALTFIRE_FIREMODE], false, nameof(ShieldActivationCompleted));
}

simulated function DeactivateShield()
{
	PlaySoundBase(ShieldDeactivateSound.FirstPersonCue);
	bDeactivatingShield = true;
	bActivatingShield = false;
	bCanRechargeShield = false;
	bNetDirty=true;
	NotifyShieldActive(false);
	SetTimer(FireInterval[ALTFIRE_FIREMODE], false, nameof(ShieldDeactivatedTimerCompleted));
}

simulated function ShieldActivationCompleted()
{
	bShieldActionAvailable = true;
}

simulated function ShieldDeactivatedTimerCompleted()
{
	bShieldActionAvailable = true;
	bCanRechargeShield = true;
}

/** Update shield charge - client and server */
simulated event Tick(float DeltaTime)
{
	// Update Shield visuals
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bActivatingShield && FXDelta < ShieldFXDuration)
		{
			FXDelta = FMin(FXDelta + DeltaTime, ShieldFXDuration);
			UpdateShieldFXValue(FXDelta / ShieldFXDuration);
			if (FXDelta == ShieldFXDuration)
			{
				bActivatingShield = false;
			}
		}
		else if (bDeactivatingShield && FXDelta > 0.0f)
		{
			FXDelta = FMax(FXDelta - DeltaTime, 0.0f);
			UpdateShieldFXValue(FXDelta / ShieldFXDuration);
			if (FXDelta == 0.0f)
			{
				bDeactivatingShield = false;
			}
		}
	}

	if (OverlayDelta > RedOverlayMin)
	{
		OverlayDelta = FMax(OverlayDelta - DeltaTime, RedOverlayMin);
		UpdateShieldBlockVFX(RedOverlayMax * (OverlayDelta / ShieldBlockVFXDuration));
	}

	if ( Role == Role_Authority )
	{
		// If shield is active it needs to consume charge, otherwise it recharges itself.
		if (bIsShieldActive)
		{
			ConsumeShield(DeltaTime);
		}
		else if (bCanRechargeShield && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE])
		{
			RechargeShield(DeltaTime);
		}
	}

	Super.Tick(DeltaTime);
}

simulated function ConsumeShield(float DeltaTime)
{
	local int Charge;

	if (Role == ROLE_Authority)
	{
		ShieldRechargeIncrement = 0.0f;

		ShieldConsumptionIncrement += ShieldConsumptionPerSecond * DeltaTime;
		
		if (ShieldConsumptionIncrement >= 1.0f && AmmoCount[ALTFIRE_FIREMODE] > 0)
		{
			Charge = int(ShieldConsumptionIncrement);
			AmmoCount[ALTFIRE_FIREMODE] = Max(AmmoCount[ALTFIRE_FIREMODE] - Charge, 0);
			ShieldConsumptionIncrement -= Charge;

			ShieldAmmo = AmmoCount[ALTFIRE_FIREMODE];

			if (AmmoCount[ALTFIRE_FIREMODE] == 0)
			{
				OnShieldDepleted();
			}
		}
	}
}

simulated function RechargeShield(float DeltaTime)
{
	local int Charge;

	if (Role == ROLE_Authority)
	{
		ShieldConsumptionIncrement = 0.0f;
		ShieldRechargeIncrement += ShieldRechargePerSecond * DeltaTime;
		if (ShieldRechargeIncrement >= 1.0f && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE])
		{
			Charge = int(ShieldRechargeIncrement);
			AmmoCount[ALTFIRE_FIREMODE] = Min(AmmoCount[ALTFIRE_FIREMODE] + Charge, MagazineCapacity[ALTFIRE_FIREMODE]);
			ShieldRechargeIncrement    -= Charge;

			ShieldAmmo = AmmoCount[ALTFIRE_FIREMODE];
		}
	}
}

/** Shield consumed all the charge by itself */
simulated function OnShieldDepleted()
{
	bWasShieldDepleted  = true;
	bActivatingShield   = false;
	bDeactivatingShield = true;
	bCanRechargeShield  = false;
	bIsShieldActive     = false;
	ShieldAmmo 			= 0;
	bNetDirty			= true;
	NotifyShieldActive(false);
	PlaySoundBase(ShieldEndSound);
	SetTimer(CooldownAfterShieldDepleted, false, nameof(ShieldRepletedTimerCompleted));
}

simulated function ShieldRepletedTimerCompleted()
{
	bWasShieldDepleted = false;
	bCanRechargeShield = true;
}

/** Shield was destroyed by attacks */
simulated function OnShieldDestroyed()
{
	bWasShielDestroyed  = true;
	bActivatingShield   = false;
	bDeactivatingShield = true;
	bCanRechargeShield  = false;
	bIsShieldActive     = false;
	ShieldAmmo 			= 0;
	bNetDirty			= true;
	NotifyShieldActive(false);
	PlaySoundBase(ShieldEndSound);
	SetTimer(CooldownAfterShieldDestroyed, false, nameof(ShieldDestroyedTimerCompleted));
}

simulated function ShieldDestroyedTimerCompleted()
{
	bWasShielDestroyed = false;
	bCanRechargeShield = true;
}

/** Update HUD ammo icon for shield */
simulated function int GetSecondaryAmmoForHUD()
{
	return AmmoCount[ALTFIRE_FIREMODE];
}

simulated function ShieldAbsorbDamage(int DamageBase)
{
	local int Damage;
	// Use the carried shield reduction by time
	ShieldConsumptionIncrement += DamageBase*ShieldDamageAbsorbtionModifier;
	Damage = int(ShieldConsumptionIncrement);
	AmmoCount[ALTFIRE_FIREMODE] = Max(AmmoCount[ALTFIRE_FIREMODE] - Damage, 0);
	ShieldConsumptionIncrement -= Damage;

	// Check if shield is destroyed.
	if (AmmoCount[ALTFIRE_FIREMODE] == 0)
	{
		OnShieldDestroyed();
	}
}

/**
	Reduce the damage received and apply it to the shield
 */
function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
	local KFPerk InstigatorPerk;
	local byte BlockTypeIndex;
	local float DmgCauserDot;

	if (!bIsShieldActive)
	{
		return;
	}

	// Don't apply block effects for teammates
	if (Instigator.IsSameTeam(DamageCauser.Instigator))
	{
		return;
	}

	if (CanBlockDamageType(DamageType, BlockTypeIndex))
	{
		if (ClassIsChildOf(DamageCauser.class, class'Projectile'))
		{
			// Projectile might be beyond/behind player, resulting in bad dot
			// Projectile won't have a velocity to check against, either
			// Assume velocity is the vector between projectile and instigator
			DmgCauserDot = Normal(DamageCauser.Instigator.Location - DamageCauser.Location) dot vector(Instigator.Rotation);
		}
		else
		{
			DmgCauserDot = Normal(DamageCauser.Location - Instigator.Location) dot vector(Instigator.Rotation);
		}

		if (DmgCauserDot > BlockingAngleCos)
		{
			ShieldAbsorbDamage(InDamage);
			InDamage *= BlockDamageModifier;

			ClientPlayBlockEffects(BlockTypeIndex);
			NotifyShieldBlockActive(true);
			SetTimer(0.1f, false, nameof(ResetShieldBlockVFX));

			InstigatorPerk = GetPerk();
			if (InstigatorPerk != none)
			{
				InstigatorPerk.SetSuccessfullBlock();
			}
		}
	}
}

/** Only DT added to BlockDamageTypes can be blocked. Check if the current one is in the list. */
function bool CanBlockDamageType(class<DamageType> DamageType, optional out byte out_Idx)
{
	local int Idx;

	for (Idx = 0; Idx < BlockDamageTypes.length; ++Idx)
	{
		if (ClassIsChildOf(DamageType, BlockDamageTypes[Idx].DmgType))
		{
			out_Idx = Idx;
			return true;
		}
	}

	out_Idx = INDEX_NONE;
	return false;
}

unreliable client function ClientPlayBlockEffects(optional byte BlockDTIndex=255)
{
	local AkBaseSoundObject Sound;
	local ParticleSystem PSTemplate;

	GetBlockEffects(BlockDTIndex, Sound, PSTemplate);
	PlayLocalBlockEffects(Sound, PSTemplate);
	UpdateShieldBlockVFX(RedOverlayMax);
	OverlayDelta = ShieldBlockVFXDuration;
}

/** Called on the client when successfully block/parry an attack */
simulated function PlayLocalBlockEffects(AKBaseSoundObject Sound, ParticleSystem PSTemplate)
{
	local vector Loc;
	local rotator Rot;
	local ParticleSystemComponent PSC;

	if (Sound != None)
	{
		PlaySoundBase(Sound, true);
	}

	if (PSTemplate != None)
	{
		if (MySkelMesh.GetSocketWorldLocationAndRotation(BlockEffectsSocketName, Loc, Rot))
		{
			PSC = WorldInfo.MyEmitterPool.SpawnEmitter(PSTemplate, Loc,  Rot);
			PSC.SetDepthPriorityGroup(SDPG_Foreground);
		}
		else
		{
			`log(self@GetFuncName()@"missing BlockEffects Socket!");
		}
	}
}

/** Returns sound and particle system overrides using index into BlockDamageTypes array */
simulated function GetBlockEffects(byte BlockDTIndex, out AKBaseSoundObject outSound, out ParticleSystem outParticleSys)
{
	outSound = BlockSound;
	outParticleSys = BlockParticleSystem;

	if (BlockDTIndex != 255)
	{
		if (BlockDamageTypes[BlockDTIndex].BlockSound != None)
		{
			outSound = BlockDamageTypes[BlockDTIndex].BlockSound;
		}
		if (BlockDamageTypes[BlockDTIndex].BlockParticleSys != None)
		{
			outParticleSys = BlockDamageTypes[BlockDTIndex].BlockParticleSys;
		}
	}
}

/**
	Should replicate to 3P to show the shield effects
 */
simulated function NotifyShieldActive(bool bActive)
{
	local KFPawn KFP;

	if (WorldInfo.NetMode != NM_Client)
	{
		KFP = KFPawn(Instigator);
		KFP.OnWeaponSpecialAction(bActive ? 1 : 0);
	}
}

simulated function NotifyShieldBlockActive(bool bActive)
{
	local KFPawn KFP;
	
	if (WorldInfo.NetMode != NM_Client)
	{
		KFP = KFPawn(Instigator);
		KFP.OnWeaponSpecialAction(bActive ? 3 : 2);
	}
}

/*********************************************************************************************
 * State WeaponEquipping
 * The Weapon is in this state while transitioning from Inactive to Active state.
 * Typically, the weapon will remain in this state while its selection animation is being played.
 * While in this state, the weapon cannot be fired.
*********************************************************************************************/

simulated state WeaponEquipping
{
	simulated function BeginState(Name PreviousStateName)
	{
		bShieldActionAvailable = true;
		super.BeginState(PreviousStateName);
	}
}

/*********************************************************************************************
 * State WeaponPuttingDown
 * Putting down weapon in favor of a new one.
 * Weapon is transitioning to the Inactive state.
*********************************************************************************************/

simulated state WeaponPuttingDown
{
	simulated event EndState(Name NextStateName)
	{
		UpdateShieldFXValue(0.0f);
		
		// Reset Values
		bIsShieldActive            = false;
		bWasShieldDepleted         = false;
		bWasShielDestroyed         = false;
		bCanRechargeShield         = true;
		bShieldActionAvailable     = false;
		bActivatingShield          = false;
		bDeactivatingShield        = false;
		FXDelta                    = 0.0f;
		bNetDirty=true;

		super.EndState(NextStateName);
	}
}

simulated function UpdateShieldBlockVFX(float Value)
{
	if( WeaponMICs.Length > `BARRIERRIFLE_MIC_SHIELD_INDEX )
	{
		WeaponMICs[`BARRIERRIFLE_MIC_SHIELD_INDEX].SetScalarParameterValue('RedOverlay', Value);
	}
}

function ResetShieldBlockVFX()
{
	NotifyShieldBlockActive(false);
}

/** Shield doesn't count as ammo for purposes of inventory management (e.g. switching) */
simulated function bool HasAnyAmmo()
{
	return AmmoCount[0] > 0 || SpareAmmoCount[0] > 0;
}

defaultproperties
{
	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

    // FOV
    MeshFOV=75
	MeshIronSightFOV=35
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=2.5

	// Content
	PackageKey="HRG_BarrierRifle"
	FirstPersonMeshName="WEP_1P_HRG_BarrierRifle_MESH.WEP_1stP_HRG_BarrielRifle_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_BarrierRifle_ANIM.Wep_1stP_HRG_BarrierRifle_Anim"
	PickupMeshName="WEP_3P_HRG_BarrierRifle_MESH.Wep_3rdP_HRG_BarrierRifle_Pickup"
	AttachmentArchetypeName="WEP_HRG_BarrierRifle_ARCH.Wep_HRG_BarrierRifle_3P"
	MuzzleFlashTemplateName="WEP_HRG_BarrierRifle_ARCH.Wep_HRG_BarrierRifle_MuzzleFlash"

   	// Zooming/Position
	PlayerViewOffset=(X=4.0,Y=8,Z=-4)
	IronSightPosition=(X=8.5,Y=0,Z=0)

	// Ammo
	MagazineCapacity[0]=60
	SpareAmmoCapacity[0]=540 //480
	InitialSpareMags[0]=2
	bCanBeReloaded=true
	bReloadFromMagazine=true
	
	// Shield "Ammo"
	MagazineCapacity[1]=100
	SpareAmmoCapacity[1]=0
	bCanRefillSecondaryAmmo=false

	// Recoil
	maxRecoilPitch=110 //120
	minRecoilPitch=70 //70
	maxRecoilYaw=80 //130
	minRecoilYaw=-80 //-130
	RecoilRate=0.045 //0.08
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.4 //0.25
	IronSightMeshFOVCompensationScale=2.3
    HippedRecoilModifier=1.5
	//WalkingRecoilModifier=1.1
	//JoggingRecoilModifier=1.2

    // Inventory / Grouping
	InventorySize=7
	GroupPriority=125
	WeaponSelectTexture=Texture2D'wep_ui_hrg_barrierrifle_tex.UI_WeaponSelect_HRG_BarrierRifle'
   	AssociatedPerkClasses(0)=class'KFPerk_SWAT'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_AssaultRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRG_BarrierRifle'
	FireInterval(DEFAULT_FIREMODE)=+0.066 // 900 RPM
	Spread(DEFAULT_FIREMODE)=0.025 //0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=33.0 //35.0
	FireOffset=(X=30,Y=4.5,Z=-5)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	AmmoCost(ALTFIRE_FIREMODE)=0
	FireInterval(ALTFIRE_FIREMODE)=0.01f
    SecondaryAmmoTexture=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRG_BarrierRifle'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Stoner.Play_WEP_Stoner_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_Stoner.Play_WEP_Stoner_Fire_1P_Loop')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Stoner.Play_WEP_Stoner_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_Stoner.Play_WEP_Stoner_Fire_1P_EndLoop')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	EjectedShellForegroundDuration=0.8f

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Ammo belt
	AmmoBeltBulletBonePrefix="RW_Bullets"
	NumAmmoBeltBullets=14
	LastAmmoCount=-1

	bIsShieldActive=false
	bWasShieldDepleted=false
	bWasShielDestroyed=false
	bCanRechargeShield=true
	ShieldRechargeIncrement=0.0f;
	ShieldConsumptionIncrement=0.0f

	ShieldConsumptionPerSecond=3.0f //10.0f
	ShieldRechargePerSecond=8.0f //10.0f //15.0f
	CooldownAfterShieldDepleted=3.0f //3.0f
	CooldownAfterShieldDestroyed=3.0f //5.0f

	ShieldActivateSound=(DefaultCue=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_On', FirstPersonCue=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_On')
	ShieldDeactivateSound=(DefaultCue=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Off', FirstPersonCue=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Off')
	ShieldEndSound=AKEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_End';

	BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'
	BlockParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Block_melee_01'
	BlockEffectsSocketName=BlockEffect

	RedOverlayMax=1.0f
	RedOverlayMin=0.0f
	OverlayDelta=0.0f
	ShieldBlockVFXDuration=0.5f

	BlockDamageTypes.Add((DmgType=class'KFDT_Bludgeon', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_Slashing', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_Fire_HuskFireball', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_Fire_HuskFlamethrower'))
	BlockDamageTypes.Add((DmgType=class'KFDT_BloatPuke'))
	BlockDamageTypes.Add((DmgType=class'KFDT_EvilDAR_Rocket', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_EvilDAR_Laser', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_DAR_EMPBlast', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_Ballistic_PatMinigun', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_Explosive_PatMissile', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_Ballistic_HansAK12', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_EMP_MatriarchTeslaBlast', BlockSound=AkEvent'WW_WEP_HRG_BarrierRifle.Play_WEP_HRG_BarrierRifle_1P_Shield_Impact'))
	BlockDamageTypes.Add((DmgType=class'KFDT_EMP_MatriarchPlasmaCannon'))
	BlockDamageTypes.Add((DmgType=class'KFDT_FleshpoundKing_ChestBeam'))
	BlockDamageModifier=0.3f //0.4f
	ShieldDamageAbsorbtionModifier=1.2f //0.8f //0.8 = equal to base damage
	BlockingAngle=180.f // Adjust with visuals.
	bShieldActionAvailable=true
	bActivatingShield=false
	bDeactivatingShield=false
	FXDelta=0.0f
	ShieldFXDuration=0.15f
	bAllowClientAmmoTracking=true
	NumBloodMapMaterials=5

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.0f), (Stat=EWUS_Weight, Add=0)))
}
