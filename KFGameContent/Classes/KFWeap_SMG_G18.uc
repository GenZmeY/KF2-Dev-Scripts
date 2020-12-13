//=============================================================================
// KFWeap_SMG_G18
//=============================================================================
// full auto pistol with riot shield
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_SMG_G18 extends KFWeap_SMGBase;

// default fx
var AkBaseSoundObject BlockSound;
var ParticleSystem BlockParticleSystem;
var name BlockEffectsSocketName;

var array<BlockEffectInfo> BlockTypes;
var float BlockDamageMitigation;

var const name IdleToIronSightAnim;
var const name IronSightToIdleAnim;

var float BlockAngle;
var transient float BlockAngleCos;

/** Explosion actor class to spawn */
var class<KFExplosionActor> ExplosionActorClass;
var() KFGameExplosion ExplosionTemplate;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();
	BlockAngleCos = cos((BlockAngle / 2.f) * DegToRad);
}

/*********************************************************************************************
 * State Active
 * A Weapon this is being held by a pawn should be in the active state.  In this state,
 * a weapon should loop any number of idle animations, as well as check the PendingFire flags
 * to see if a shot has been fired.
 *********************************************************************************************/
simulated state Active
{
	simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
	{
		GotoState('ActiveIronSights');
	}
}

/*********************************************************************************************
 * State ActiveIronSights
 * Plays an animation when transitioning to or from iron sights, but this animation
 * should only be played in the "Active" state. This state allows us to encapsulate this
 * functionality.
 *********************************************************************************************/
simulated state ActiveIronSights extends Active
{
	simulated function BeginState(Name PreviousStateName)
	{
		local float ZoomTimeToGo;
		ZoomTimeToGo = MySkelMesh.GetAnimLength(IdleToIronSightAnim);

		Global.ZoomIn(true, ZoomTimeToGo);

		PlayAnimation(IdleToIronSightAnim, ZoomTime, false);
	}

	simulated function ZoomOut(bool bAnimateTransition, float ZoomTimeToGo)
	{
		ZoomTimeToGo = MySkelMesh.GetAnimLength(IronSightToIdleAnim);

		Global.ZoomOut(true, ZoomTimeToGo);

		PlayAnimation(IronSightToIdleAnim, ZoomTime, false);

		GotoState('Active');
	}
}

/*********************************************************************************************
 * State MeleeAttackBasic
 * This is a basic melee state that's used as a base for other more advanced states
 *********************************************************************************************/

simulated state MeleeAttackBasic
{
	simulated function NotifyMeleeCollision(Actor HitActor, optional vector HitLocation)
	{
		local KFPawn Victim;

		if (Role == ROLE_Authority)
		{
			if (HitActor.bWorldGeometry)
			{
				return;
			}

			Victim = KFPawn(HitActor);
			if (Victim == None ||
			   (Victim.GetTeamNum() == Instigator.GetTeamNum()) ||
			   (Victim.bPlayedDeath && `TimeSince(Victim.TimeOfDeath) > 0.f))
			{
				return;
			}

			// need to delay one frame, since this is called from AnimNotify
			SetTimer(0.001f, false, nameof(DoBashImpulse));
		}
	}
}

simulated function DoBashImpulse()
{
	local KFExplosionActor ExploActor;
	local vector SpawnLoc;
	local rotator SpawnRot;

	if (Instigator.Role < ROLE_Authority)
	{
		return;
	}

	SpawnLoc = Instigator.Location;
	SpawnRot = Instigator.Rotation;

	// nudge backwards to give a wider code near the player
	SpawnLoc += vector(SpawnRot);

	// explode using the given template
	ExploActor = Spawn(ExplosionActorClass, self,, SpawnLoc, SpawnRot,, true);
	if (ExploActor != None)
	{
		ExploActor.InstigatorController = Instigator.Controller;
		ExploActor.Instigator = Instigator;
		ExploActor.bReplicateInstigator = true;
		ExploActor.Explode(ExplosionTemplate, vector(SpawnRot));
	}
}

/**
 * State Reloading
 * State the weapon is in when it is being reloaded (current magazine replaced with a new one, related animations and effects played).
 */
simulated state Reloading
{
	/** Cancel reload when going into ironsights */
	simulated function ZoomIn(bool bAnimateTransition, float ZoomTimeToGo)
	{
		GotoState('ActiveIronSights');
		AbortReload();
	}
}

function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
{
	local KFPerk InstigatorPerk;
	local byte BlockTypeIndex;
	local float DmgCauserDot;

	if (!bUsingSights)
	{
		return;
	}

	// don't apply block effects for teammates
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

		if (DmgCauserDot > BlockAngleCos)
		{
			InDamage *= GetUpgradedBlockDamageMitigation(CurrentWeaponUpgradeIndex);
			ClientPlayBlockEffects(BlockTypeIndex);

			InstigatorPerk = GetPerk();
			if (InstigatorPerk != none)
			{
				InstigatorPerk.SetSuccessfullBlock();
			}
		}
	}
}

/** If true, this damage type can be blocked by the MeleeBlocking state */
function bool CanBlockDamageType(class<DamageType> DamageType, optional out byte out_Idx)
{
	local int Idx;

	// Check if this damage should be ignored completely
	for (Idx = 0; Idx < BlockTypes.length; ++Idx)
	{
		if (ClassIsChildOf(DamageType, BlockTypes[Idx].DmgType))
		{
			out_Idx = Idx;
			return true;
		}
	}

	out_Idx = INDEX_NONE;
	return false;
}

/** Called on the server when successfully block/parry an attack */
unreliable client function ClientPlayBlockEffects(optional byte BlockTypeIndex=255)
{
	local AkBaseSoundObject Sound;
	local ParticleSystem PSTemplate;

	GetBlockEffects(BlockTypeIndex, Sound, PSTemplate);
	PlayLocalBlockEffects(Sound, PSTemplate);
}

/** Returns sound and particle system overrides using index into BlockTypes array */
simulated function GetBlockEffects(byte BlockIndex, out AKBaseSoundObject outSound, out ParticleSystem outParticleSys)
{
	outSound = BlockSound;
	outParticleSys = BlockParticleSystem;

	if (BlockIndex != 255)
	{
		if (BlockTypes[BlockIndex].BlockSound != None)
		{
			outSound = BlockTypes[BlockIndex].BlockSound;
		}
		if (BlockTypes[BlockIndex].BlockParticleSys != None)
		{
			outParticleSys = BlockTypes[BlockIndex].BlockParticleSys;
		}
	}
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

/*********************************************************************************************
 * Upgrades
 ********************************************************************************************/

static simulated function float GetUpgradedBlockDamageMitigation(int UpgradeIndex)
{
	return GetUpgradedStatValue(default.BlockDamageMitigation, EWUS_BlockDmgMitigation, UpgradeIndex);
}

defaultproperties
{
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

	// Inventory
	InventorySize=8
	GroupPriority=100
	WeaponSelectTexture=Texture2D'WEP_UI_RiotShield_TEX.UI_WeaponSelect_RiotShield'

	// FOV
	MeshFOV=96
	MeshIronSightFOV=75
	PlayerIronSightFOV=64

	// Zooming/Position
	IronSightPosition=(X=0,Y=0,Z=0)
	PlayerViewOffset=(X=10.f,Y=0.f,Z=-7.0f)

	IdleToIronSightAnim=Iron_Shield_Up
	IronSightToIdleAnim=Iron_Shield_Down

	// Content
	PackageKey="RiotShield"
	FirstPersonMeshName="WEP_1P_RiotShield_MESH.Wep_1P_RiotShield_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_RiotShield_ANIM.Wep_1stP_RiotShield_Anim"
	PickupMeshName="WEP_3P_RiotShield_MESH.Wep_3P_RiotShield_Pickup"
	AttachmentArchetypeName="WEP_RiotShield_ARCH.Wep_G18_3P"
	MuzzleFlashTemplateName="WEP_RiotShield_ARCH.Wep_G18_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=33
	SpareAmmoCapacity[0]=462
	InitialSpareMags[0]=4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	bHasFireLastAnims=true
	BonesToLockOnEmpty=(RW_Bolt, RW_Bullets1, RW_Bullets2, RW_Barrel)

	// Recoil
	maxRecoilPitch=100
	minRecoilPitch=75
	maxRecoilYaw=85
	minRecoilYaw=-85
	RecoilRate=0.045
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=100
	RecoilISMinYawLimit=65435
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	IronSightMeshFOVCompensationScale=1.65
	WalkingRecoilModifier=1.1
	JoggingRecoilModifier=1.2

	// Block FX
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Hammer'
	BlockParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Block_melee_01'
	BlockEffectsSocketName=BlockEffect

	// Blocking
	BlockTypes.Add((DmgType=class'KFDT_Bludgeon', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Slashing', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Fire_HuskFireball', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Fire_HuskFlamethrower'))
	BlockTypes.Add((DmgType=class'KFDT_BloatPuke'))
	BlockTypes.Add((DmgType=class'KFDT_EvilDAR_Rocket', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_EvilDAR_Laser', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_DAR_EMPBlast', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Ballistic_PatMinigun', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Explosive_PatMissile', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Ballistic_HansAK12', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_EMP_MatriarchTeslaBlast', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_EMP_MatriarchPlasmaCannon'))
	BlockTypes.Add((DmgType=class'KFDT_FleshpoundKing_ChestBeam'))
	BlockDamageMitigation=0.4

	// How many degrees in front of the player to block
	// 0 = don't block anything
	// 180 = block everything in front of player
	// 360 = block everything all around player
	BlockAngle=170.f

	// For procedural weapon hiding
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=0)

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_G18'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_G18'
	FireInterval(DEFAULT_FIREMODE)=+.05455 // 1100 RPM
	Spread(DEFAULT_FIREMODE)=0.06
	InstantHitDamage(DEFAULT_FIREMODE)=28
	FireOffset=(X=30,Y=6.5,Z=-4)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_G18'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_G18'
	FireInterval(ALTFIRE_FIREMODE)=+0.175 // 343 RPM
	InstantHitDamage(ALTFIRE_FIREMODE)=28
	Spread(ALTFIRE_FIREMODE)=0.015

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_G18Shield'
	InstantHitMomentum(BASH_FIREMODE)=10000.f
	InstantHitDamage(BASH_FIREMODE)=35

	// Explosion settings.  Using archetype so that clients can serialize the content
	// without loading the 1st person weapon content (avoid 'Begin Object')!
	ExplosionActorClass=class'KFExplosionActorReplicated'
	ExplosionTemplate=KFGameExplosion'WEP_RiotShield_ARCH.Wep_G18_Shield_Impulse'

	//@todo: add akevents when we have them
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18.Play_WEP_G18_Auto_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_G18.Play_WEP_G18_Auto_Loop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18.Play_WEP_G18_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_G18.Play_WEP_G18_Fire_1P_Single')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_MedicSMG.Play_SA_MedicSMG_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_MedicDart.Play_WEP_SA_Medic_Dart_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_G18.Play_WEP_G18_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_G18.Play_WEP_G18_Fire_1P_EndLoop')
	SingleFireSoundIndex=ALTFIRE_FIREMODE

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	//Perks
	AssociatedPerkClasses(0)=class'KFPerk_Swat'

	//Weapon Upgrade
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Weight, Add=1)))
}
