//=============================================================================
// KFWeap_Blunt_MedicBat
//=============================================================================
// A melee weapon that creates healing gas and can smack heals into teammates
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

// Extends MeleeBase with code from KFWeap_HealerBase (for healing dart ammo functionality)
class KFWeap_Blunt_MedicBat extends KFWeap_MeleeBase;

/** Explosion actor class to spawn */
var class<KFExplosionActor> ExplosionActorClass;
var() KFGameExplosion ExplosionTemplate;
var() KFGameExplosion LightAttackExplosionTemplate;

/** Whether Friendly Fire is enabled for the game */
var bool bFriendlyFireEnabled;

/** Amount to heal when hitting a teammate per firemode */
var array<float> AttackHealAmounts;
/** Ammo dart cost for healing a teammate per firemode */
var array<byte> AttackHealCosts;

/** How many points of heal ammo to recharge per second */
var(Healing) float      HealFullRechargeSeconds;

/** Keeps track of incremental healing since we have to heal in whole integers */
var          float      HealingIncrement;

/** How many points of heal ammo to recharge per second. Calculated from the HealFullRechargeSeconds */
var          float      HealRechargePerSecond;

/** Current amount of healing darts available */
var repnotify byte HealingDartAmmo;

/** The actor the alt attack explosion should attach to */
var transient Actor BlastAttachee;

/** The hit location of the blast */
var vector BlastHitLocation;

/** Spawn location offset to improve cone hit detection */
var transient float BlastSpawnOffset;

/** Starting Damage radius of the alt attack explosion*/
var float StartingDamageRadius;

/** Animations that play in reaction to hitting with the alt fire attack*/
const HardFire_L = 'HardFire_L';
const HardFire_R = 'HardFire_R';
const HardFire_F = 'HardFire_F';
const HardFire_B = 'HardFire_B';

/** Damage type that is used when hitting a teammate with an attack */
var class<DamageType> HealingDamageType;

/*********************************************************************************************
 @name Optics UI
********************************************************************************************* */

var class<KFGFxWorld_MedicOptics> OpticsUIClass;
var KFGFxWorld_MedicOptics OpticsUI;

/** The last updated value for our ammo - Used to know when to update our optics ammo */
var byte StoredPrimaryAmmo;
var byte StoredSecondaryAmmo;

replication
{
	if (bNetInitial)
		bFriendlyFireEnabled;

	if (bNetDirty && Role == ROLE_Authority && bAllowClientAmmoTracking)
		HealingDartAmmo;
}


/* epic ===============================================
* ::ReplicatedEvent
*
* Called when a variable with the property flag "RepNotify" is replicated
*
* =====================================================
*/
simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(HealingDartAmmo))
	{
		AmmoCount[ALTFIRE_FIREMODE] = HealingDartAmmo;
	}
	else
	{
		Super.ReplicatedEvent(VarName);
	}
}

/**
  * HealAmmo Regen client and server
  */
simulated event Tick(FLOAT DeltaTime)
{
	// If we're not fully charged tick the HealAmmoRegen system
	if (AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE])
	{
		HealAmmoRegeneration(DeltaTime);
	}

	if (Instigator != none && Instigator.weapon == self)
	{
		UpdateOpticsUI();
	}

	Super.Tick(DeltaTime);
}

simulated function ConsumeAmmoDarts(int AmmoDartCost)
{
	// Handles the consumption of ammo darts for the default attack
	// If AmmoCount is being replicated, don't allow the client to modify it here
	if (Role == ROLE_Authority || bAllowClientAmmoTracking)
	{
		// Don't consume ammo if magazine size is 0 (infinite ammo with no reload)
		if (MagazineCapacity[1] > 0 && AmmoCount[1] > 0)
		{
			// Reduce ammo amount by heal ammo cost
			AmmoCount[1] = Max(AmmoCount[1] - AmmoDartCost, 0);
		}
	}
}

/** @see KFWeapon::ConsumeAmmo */
simulated function ConsumeAmmo(byte FireModeNum)
{
	// If its not the healing fire mode (the heavy attack ammo consumption), use the super's consume
	if (FireModeNum != DEFAULT_FIREMODE)
	{
		Super.ConsumeAmmo(FireModeNum);
		return;
	}

	ConsumeAmmoDarts(AmmoCost[DEFAULT_FIREMODE]);
}

/** Overridden to call StartHealRecharge on server */
function GivenTo(Pawn thisPawn, optional bool bDoNotActivate)
{
	super.GivenTo(thisPawn, bDoNotActivate);

	// StartHealRecharge gets called on the client from ClientWeaponSet (called from ClientGivenTo, called from GivenTo),
	// but we also need this called on the server for remote clients, since the server needs to track the ammo too (to know if/when to spawn projectiles)
	if (Role == ROLE_Authority && !thisPawn.IsLocallyControlled())
	{
		StartHealRecharge();
	}
}

/** Start the heal recharge cycle */
function StartHealRecharge()
{
	local KFPerk InstigatorPerk;
	local float UsedHealRechargeTime;

	// begin ammo recharge on server
	if (Role == ROLE_Authority)
	{
		InstigatorPerk = GetPerk();
		UsedHealRechargeTime = HealFullRechargeSeconds * static.GetUpgradeHealRechargeMod(CurrentWeaponUpgradeIndex);

		InstigatorPerk.ModifyHealerRechargeTime(UsedHealRechargeTime);
		// Set the healing recharge rate whenever we start charging
		HealRechargePerSecond = MagazineCapacity[ALTFIRE_FIREMODE] / UsedHealRechargeTime;
		HealingIncrement = 0;
	}
}

/** Heal Ammo Regen */
function HealAmmoRegeneration(float DeltaTime)
{
	if (Role == ROLE_Authority)
	{
		HealingIncrement += HealRechargePerSecond * DeltaTime;

		if (HealingIncrement >= 1.0 && AmmoCount[ALTFIRE_FIREMODE] < MagazineCapacity[ALTFIRE_FIREMODE])
		{
			AmmoCount[ALTFIRE_FIREMODE]++;
			HealingIncrement -= 1.0;

			// Heal ammo regen is only tracked on the server, so even though we told the client he could
			// keep track of ammo himself like a big boy, we still have to spoon-feed it to him.
			if (bAllowClientAmmoTracking)
			{
				HealingDartAmmo = AmmoCount[ALTFIRE_FIREMODE];
			}
		}
	}
}

simulated event bool HasAmmo(byte FireModeNum, optional int Amount)
{
	// Default fire mode either has ammo to trigger the heal or needs to return true to still allow a basic swing
	if (FireModeNum == DEFAULT_FIREMODE)
	{
		return true;
	}

	return super.HasAmmo(FireModeNum, Amount);
}

reliable client function ClientWeaponSet(bool bOptionalSet, optional bool bDoNotActivate)
{
	local KFInventoryManager KFIM;

	super.ClientWeaponSet(bOptionalSet, bDoNotActivate);

	if (OpticsUI == none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			//Create the screen's UI piece
			OpticsUI = KFGFxWorld_MedicOptics(KFIM.GetOpticsUIMovie(OpticsUIClass));
		}
	}

	// Initialize our displayed ammo count and healer charge
	StartHealRecharge();
}

function ItemRemovedFromInvManager()
{
	local KFInventoryManager KFIM;
	local KFWeap_Blunt_MedicBat KFW;

	Super.ItemRemovedFromInvManager();

	if (OpticsUI != none)
	{
		KFIM = KFInventoryManager(InvManager);
		if (KFIM != none)
		{
			foreach KFIM.InventoryActors(class'KFWeap_Blunt_MedicBat', KFW)
			{
				if (KFW != self && KFW.OpticsUI.Class == OpticsUI.class)
				{
					// A different weapon is still using this optics class
					return;
				}
			}

			//Create the screen's UI piece
			KFIM.RemoveOpticsUIMovie(OpticsUI.class);

			OpticsUI.Close();
			OpticsUI = none;
		}
	}
}

/** Unpause our optics movie and reinitialize our ammo when we equip the weapon */
simulated function AttachWeaponTo(SkeletalMeshComponent MeshCpnt, optional Name SocketName)
{
	super.AttachWeaponTo(MeshCpnt, SocketName);

	if (OpticsUI != none)
	{
		OpticsUI.SetPause(false);
		UpdateOpticsUI(true);
		OpticsUI.SetShotPercentCost(AmmoCost[ALTFIRE_FIREMODE]);
	}
}

/** Pause the optics movie once we unequip the weapon so it's not playing in the background */
simulated function DetachWeapon()
{
	local Pawn OwnerPawn;
	super.DetachWeapon();

	OwnerPawn = Pawn(Owner);
	if (OwnerPawn != none && OwnerPawn.Weapon == self)
	{
		if (OpticsUI != none)
		{
			OpticsUI.SetPause();
		}
	}
}

/**
 * Update our displayed ammo count if it's changed
 */
simulated function UpdateOpticsUI(optional bool bForceUpdate)
{
	if (OpticsUI != none && OpticsUI.OpticsContainer != none)
	{
		if (AmmoCount[DEFAULT_FIREMODE] != StoredPrimaryAmmo || bForceUpdate)
		{
			StoredPrimaryAmmo = AmmoCount[DEFAULT_FIREMODE];
			OpticsUI.SetPrimaryAmmo(StoredPrimaryAmmo);
		}

		if (AmmoCount[ALTFIRE_FIREMODE] != StoredSecondaryAmmo || bForceUpdate)
		{
			StoredSecondaryAmmo = AmmoCount[ALTFIRE_FIREMODE];
			OpticsUI.SetHealerCharge(StoredSecondaryAmmo);
		}

		if (OpticsUI.MinPercentPerShot != AmmoCost[ALTFIRE_FIREMODE])
		{
			OpticsUI.SetShotPercentCost(1);
		}
	}
}

/** Healing charge doesn't count as ammo for purposes of inventory management (e.g. switching) */
simulated function bool HasAnyAmmo()
{
	// Special ammo is stored in the default firemode (heal darts are separate)
	if (HasSpareAmmo() || AmmoCount[DEFAULT_FIREMODE] >= AmmoCost[CUSTOM_FIREMODE])
	{
		return true;
	}

	return false;
}

/** Determines the secondary ammo left for HUD display */
simulated function int GetSecondaryAmmoForHUD()
{
	return AmmoCount[1];
}

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	/** Initially check whether friendly fire is on or not. */
	if (Role == ROLE_Authority && KFGameInfo(WorldInfo.Game).FriendlyFireScale != 0.f)
	{
		bFriendlyFireEnabled = true;
	}

	if (ExplosionTemplate != none)
	{
		StartingDamageRadius = ExplosionTemplate.DamageRadius;
	}
}

/** should be able to interrupt its reload state with any melee attack */
simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	return FireModeNum != RELOAD_FIREMODE;
}

/** Override to allow for two different states associated with RELOAD_FIREMODE */
simulated function SendToFiringState(byte FireModeNum)
{
	// Ammo needs to be synchronized on client/server for this to work!
	if (FireModeNum == RELOAD_FIREMODE && !Super(KFWeapon).CanReload())
	{
		SetCurrentFireMode(FireModeNum);
		GotoState('WeaponUpkeep');
		return;
	}

	Super.SendToFiringState(FireModeNum);
}

/** Always allow reload and choose the correct state in SendToFiringState() */
simulated function bool CanReload(optional byte FireModeNum)
{
	return true;
}

/** Skip calling StillFiring/PendingFire to fix log warning */
simulated function bool ShouldRefire()
{
	if (CurrentFireMode == CUSTOM_FIREMODE)
		return false;

	return Super.ShouldRefire();
}

simulated protected function PrepareExplosion()
{
	local KFPlayerController KFPC;
	local KFPerk InstigatorPerk;

	ExplosionTemplate = default.ExplosionTemplate;
	ExplosionTemplate.DamageRadius = StartingDamageRadius;

	// Change the radius and damage based on the perk
	if (Owner.Role == ROLE_Authority)
	{
		KFPC = KFPlayerController(Instigator.Controller);
		if (KFPC != none)
		{
			InstigatorPerk = KFPC.GetPerk();
			ExplosionTemplate.DamageRadius *= InstigatorPerk.GetAoERadiusModifier();
		}
	}

	ExplosionActorClass = default.ExplosionActorClass;
}

/** Get the hard fire anim when the alt fire attack connects */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	// Adjust cone fire angle based on swing direction
	switch (MeleeAttackHelper.CurrentAttackDir)
	{
	case DIR_Forward:
	case DIR_ForwardLeft:
	case DIR_ForwardRight:
		return HardFire_F;
	case DIR_Backward:
	case DIR_BackwardLeft:
	case DIR_BackwardRight:
		return HardFire_B;
	case DIR_Left:
		return HardFire_L;
	case DIR_Right:
		return HardFire_R;
	}
	return '';
}

simulated function SpawnExplosionFromTemplate(KFGameExplosion Template)
{
	local KFExplosionActor ExploActor;
	local vector SpawnLoc;
	local rotator SpawnRot;

	SpawnLoc = BlastHitLocation;
	SpawnRot = GetAdjustedAim(SpawnLoc);

	// explode using the given template
	ExploActor = Spawn(ExplosionActorClass, self, , SpawnLoc, SpawnRot, , true);
	if (ExploActor != None)
	{
		ExploActor.InstigatorController = Instigator.Controller;
		ExploActor.Instigator = Instigator;
		ExplosionTemplate.bFullDamageToAttachee = true;

		KFExplosionActorReplicated(ExploActor).bIgnoreInstigator = false;
		ExploActor.bReplicateInstigator = true;

		ExploActor.Explode(Template, vector(SpawnRot));
	}
}

simulated function CustomFire()
{
	if (Instigator.Role < ROLE_Authority)
	{
		return;
	}

	PrepareExplosion();
	SpawnExplosionFromTemplate(ExplosionTemplate);

	// tell remote clients that we fired, to trigger effects in third person
	IncrementFlashCount();
}

simulated function HealTeammateWithAttack(Actor HitActor, vector HitLocation, float HealingAmount, byte HealCost)
{
	local KFPawn Victim;

	if (Role == ROLE_Authority)
	{
		if (Instigator != None)
		{
			// only detonate when it hits a pawn so that level geometry doesn't get in the way
			if (HitActor.bWorldGeometry)
			{
				return;
			}

			Victim = KFPawn(HitActor);

			// If the victim is a teammate and the player has default ammo (healing darts) then heal this teammate
			//	also make sure the victim is still alive and is actually missing health
			if (Victim != None && (Victim.GetTeamNum() == Instigator.GetTeamNum()) && Victim.Health > 0 && Victim.Health < Victim.HealthMax)
			{
				if (AmmoCount[1] >= HealCost)
				{
					ConsumeAmmoDarts(HealCost);
					Victim.HealDamage(HealingAmount, Instigator.Controller, HealingDamageType);

					if (Instigator.Role >= ROLE_Authority)
					{
						BlastHitLocation = HitLocation;
						SpawnExplosionFromTemplate(LightAttackExplosionTemplate);
					}
				}
			}
		}
	}
}

// BASH
simulated state MeleeAttackBasic
{
	/** Network: Local Player */
	simulated function NotifyMeleeCollision(Actor HitActor, optional vector HitLocation)
	{
		HealTeammateWithAttack(HitActor, HitLocation, AttackHealAmounts[BASH_FIREMODE], AttackHealCosts[BASH_FIREMODE]);
	}
}

// LIGHT ATTACK
simulated state MeleeChainAttacking
{
	/** Network: Local Player */
	simulated function NotifyMeleeCollision(Actor HitActor, optional vector HitLocation)
	{
		HealTeammateWithAttack(HitActor, HitLocation, AttackHealAmounts[DEFAULT_FIREMODE], AttackHealCosts[DEFAULT_FIREMODE]);
	}
}

// HEAVY ATTACK
simulated state MeleeHeavyAttacking
{
	/** Network: Local Player */
	simulated function NotifyMeleeCollision(Actor HitActor, optional vector HitLocation)
	{
		local KFPawn Victim;

		if (Instigator != None)
		{
			// only detonate when it hits a pawn so that level geometry doesn't get in the way
			if (HitActor.bWorldGeometry)
			{
				return;
			}

			Victim = KFPawn(HitActor);
			if (Victim == None ||
				(Victim.bPlayedDeath && `TimeSince(Victim.TimeOfDeath) > 0.f) )
			{
				return;
			}

			if (AmmoCount[0] >= AmmoCost[CUSTOM_FIREMODE] && !IsTimerActive(nameof(BeginMedicBatExplosion)))
			{
				BlastAttachee = HitActor;
				BlastHitLocation = HitLocation;

				// need to delay one frame, since this is called from AnimNotify
				SetTimer(0.001f, false, nameof(BeginMedicBatExplosion));

				if (Role < ROLE_Authority && Instigator.IsLocallyControlled())
				{
					if (!HitActor.bTearOff || Victim == none)
					{
						ServerBeginMedicBatExplosion(HitActor, HitLocation);
					}
				}
			}
			else
			{
				HealTeammateWithAttack(HitActor, HitLocation, AttackHealAmounts[HEAVY_ATK_FIREMODE], AttackHealCosts[HEAVY_ATK_FIREMODE]);
			}
		}
	}
}

/** Called on the server */
reliable server private function ServerBeginMedicBatExplosion(Actor HitActor, optional vector HitLocation)
{
	// Ignore if too far away (something went wrong!)
	if (VSizeSq2D(HitLocation - Instigator.Location) > Square(500))
	{
		return;
	}

	BlastHitLocation = HitLocation;
	BlastAttachee = HitActor;
	SendToFiringState(CUSTOM_FIREMODE);
}

/** Called when altfire melee attack hits a target and there is ammo left */
simulated function BeginMedicBatExplosion()
{
	SendToFiringState(CUSTOM_FIREMODE);
}

/*********************************************************************************************
 * State Active
 * A Weapon this is being held by a pawn should be in the active state.  In this state,
 * a weapon should loop any number of idle animations, as well as check the PendingFire flags
 * to see if a shot has been fired.
 *********************************************************************************************/

simulated state Active
{
	/**
	 * Called from Weapon:Active.BeginState when HasAnyAmmo (which is overridden above) returns false.
	 */
	simulated function WeaponEmpty()
	{
		local int i;

		// Copied from Weapon:Active.BeginState where HasAnyAmmo returns true.
		// Basically, pretend the weapon isn't empty in this case.
		for (i=0; i<GetPendingFireLength(); i++)
		{
			if (PendingFire(i))
			{
				BeginFire(i);
				break;
			}
		}
	}
}

defaultproperties
{
	// Content
	PackageKey="Medic_Bat"
	FirstPersonMeshName="WEP_1P_Medic_Bat_MESH.Wep_1stP_Medic_Bat_Rig"
	AttachmentArchetypeName = "WEP_Medic_Bat_ARCH.Wep_Medic_Bat_3P"
	FirstPersonAnimSetNames(0)="WEP_1P_Medic_Bat_ANIM.WEP_1stP_Medic_Bat_ANIM"
	PickupMeshName="WEP_3P_Medic_Bat_MESH.Wep_3rdP_Medic_Bat_Pickup"

	PlayerViewOffset=(X=3.0,Y=1.0,Z=-3.0)

	Begin Object Name=MeleeHelper_0
		MaxHitRange = 250
		// Override automatic hitbox creation (advanced)
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
		WorldImpactEffects = KFImpactEffectInfo'FX_Impacts_ARCH.Blunted_melee_impact'
		// modified combo sequences
		MeleeImpactCamShakeScale = 0.035f //0.4
		ChainSequence_F = (DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B = (DIR_BackwardLeft, DIR_Left, DIR_Right, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L = (DIR_Right, DIR_BackwardRight, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
		ChainSequence_R = (DIR_Left, DIR_BackwardLeft, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object

	// Reload
	FiringStatesArray(RELOAD_FIREMODE)=Reloading

	//Heal Dart Function
	HealingDartAmmo=100
	bCanRefillSecondaryAmmo=false
	HealFullRechargeSeconds=12

	// Heavy Attack Explosion Ammo
	MagazineCapacity[0]=3
	SpareAmmoCapacity[0]=12
	InitialSpareMags[0]=1
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Healing Dart (Alt) Ammo
	MagazineCapacity[1]=100
	SpareAmmoCapacity[1]=0

	// Inventory
	GroupPriority=75
	InventorySize=4
	WeaponSelectTexture=Texture2D'WEP_UI_Medic_Bat_TEX.UI_WeaponSelect_MedicBat'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.MedicDarts'

	// Default
	// Maps to Alt Ammo
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BluntMelee'
	InstantHitDamage(DEFAULT_FIREMODE)=80
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Bludgeon_MedicBatLight'
	AmmoCost(DEFAULT_FIREMODE)=40

	// Heavy Attack
	FireModeIconPaths(HEAVY_ATK_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BluntMelee'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=130
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE) = class'KFDT_Bludgeon_MedicBatHeavy'

	// Heavy Attack Explosion
	// Maps to Default Ammot
	FireModeIconPaths(CUSTOM_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(CUSTOM_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(CUSTOM_FIREMODE)=EWFT_Custom
	FireInterval(CUSTOM_FIREMODE)=1.0f
	AmmoCost(CUSTOM_FIREMODE)=1

	// Bash
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_MedicBatBash'
	InstantHitDamage(BASH_FIREMODE)=40

	// Perk
	AssociatedPerkClasses(0)=class'KFPerk_Berserker'
	AssociatedPerkClasses(1)=class'KFPerk_FieldMedic'

	// Block and Parry
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Crovel'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'
	ParryDamageMitigationPercent=0.50
	BlockDamageMitigation=0.60
	ParryStrength=5

	// Explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
		LightColor=(R = 0,G = 128,B = 255,A = 255)
		Brightness=4.f
		Radius=500.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=True
		bEnabled=FALSE
		LightingChannels=(Indoor = TRUE,Outdoor = TRUE,bInitialized = TRUE)
	End Object

	// Explosion
	ExplosionActorClass = class'KFExplosionActorReplicated'
	Begin Object Class=KFGameExplosion Name=HeavyAttackHealingExplosion
		Damage=200
		DamageRadius=500
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_MedicBatGas'
		HealingAmount=30

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
		ExplosionEffects=KFImpactEffectInfo'WEP_Medic_Bat_ARCH.Medic_Bat_Explosion'
		ExplosionSound=AkEvent'WW_WEP_MEL_MedicBat.Play_WEP_MedicBat_Smoke_Explode'
		MomentumTransferScale=0
		bIgnoreInstigator=false

		// Dynamic Light
		//ExploLight=ExplosionPointLight
		//ExploLightStartFadeOutTime=7.0
		//ExploLightFadeOutTime=1.0
		//ExploLightFlickerIntensity=5.f
		//ExploLightFlickerInterpSpeed=15.f

		// Camera Shake
		CamShake=none
		CamShakeInnerRadius=0
		CamShakeOuterRadius=0
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=HeavyAttackHealingExplosion

	Begin Object Class=KFGameExplosion Name=LightAttackExplosion
		Damage=0
		ParticleEmitterTemplate = ParticleSystem'WEP_Medic_Bat_EMIT.FX_Medic_Bat_Hit'

		// Camera Shake
		CamShake=none
		CamShakeInnerRadius=0
		CamShakeOuterRadius=0
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	LightAttackExplosionTemplate=LightAttackExplosion;

	//Weapon Upgrade Stats
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.1f), (Stat=EWUS_Damage1, Scale=1.1f), (Stat=EWUS_Damage2, Scale=1.1f), (Stat=EWUS_HealFullRecharge, Scale=0.8f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Damage2, Scale=1.2f), (Stat=EWUS_HealFullRecharge, Scale=0.6f), (Stat=EWUS_Weight, Add=2)))

	BlastSpawnOffset=-10.f

	AttackHealAmounts(DEFAULT_FIREMODE)=30
	AttackHealAmounts(BASH_FIREMODE)=30
	AttackHealAmounts(HEAVY_ATK_FIREMODE)=40

	AttackHealCosts(DEFAULT_FIREMODE)=30
	AttackHealCosts(BASH_FIREMODE)=30
	AttackHealCosts(HEAVY_ATK_FIREMODE)=30

	OpticsUIClass=class'KFGFxWorld_MedicOptics'

	HealingDamageType=class'KFDT_Healing'
}


