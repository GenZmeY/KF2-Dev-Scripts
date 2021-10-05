//=============================================================================
// KFWeap_Pistol_DualBladed
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Pistol_DualBladed extends KFWeap_DualBase;

/*
 *
 * BROUGHT FROM MELEE WEAPON TO SUPPORT PARRYING
 *
 */

/** These override the base firemodes of the same ID (for readability) */
const BLOCK_FIREMODE = 1; // ALTFIRE_FIREMODE

/*********************************************************************************************
 * @name Defensive Abilities
 *********************************************************************************************/

struct native BlockEffectInfo
{
	var class<DamageType> DmgType;

	/** If != None, overrides the class default FX */
	var AkEvent 		BlockSound;
	var AkEvent			ParrySound;
	var ParticleSystem	BlockParticleSys;
	var ParticleSystem  ParryParticleSys;
};

var array<BlockEffectInfo> BlockTypes;

/** Damage while blocking will be mitigated by this percentage */
var() float BlockDamageMitigation;

/** Parry damage will be mitigated by this percentage */
var() float ParryDamageMitigationPercent;
/** Hit reaction strength to bypass pawn's ParryStumbleResist */
var() byte ParryStrength;

/** If true, owning pawn moves at a slower (iron sight) walking speed */
var bool bMoveAtWalkingSpeed;

/** Time between block hit reaction anims */
var() protected float BlockHitAnimCooldownTime;

/** The last time we played a block hit reaction anim */
var transient protected float LastBlockHitAnimTime;

/** Animations played on successful block */
var array<name> MeleeBlockHitAnims;

/*********************************************************************************************
 * @name	Effects
 ********************************************************************************************* */
/** Block / Parry */
var AkBaseSoundObject BlockSound;
var AKBaseSoundObject ParrySound;
var ParticleSystem	  BlockParticleSystem;
var ParticleSystem	  ParryParticleSystem;
var name			  BlockEffectsSocketName;

/** Defensive stance animation names */
const MeleeBlockStartAnim = 'Brace_in';
const MeleeBlockLoopAnim  = 'Brace_loop';
const MeleeBlockEndAnim   = 'Brace_out';

var array<name> BonesToLockOnEmpty_Override;

simulated function NotifyAttackParried();
simulated function NotifyAttackBlocked();

// Global declarations for blocking state
simulated function BlockLoopTimer();
simulated function ParryCheckTimer();

/** Called on the server when successfully block/parry an attack */
unreliable client function ClientPlayBlockEffects(optional byte BlockTypeIndex=255)
{
	local AkBaseSoundObject Sound;
	local ParticleSystem PSTemplate;

	GetBlockEffects(BlockTypeIndex, Sound, PSTemplate);
	PlayLocalBlockEffects(Sound, PSTemplate);
}

/** Called on the server when successfully block/parry an attack */
reliable client function ClientPlayParryEffects(optional byte BlockTypeIndex=255)
{
	local AkBaseSoundObject Sound;
	local ParticleSystem PSTemplate;
	local KFPerk InstigatorPerk;

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.SetSuccessfullParry();
	}

	GetParryEffects(BlockTypeIndex, Sound, PSTemplate);
	PlayLocalBlockEffects(Sound, PSTemplate);
}

simulated state MeleeBlocking
{
	ignores ForceReload, ShouldAutoReload;

	simulated function bool AllowIronSights() { return false; }

	simulated function byte GetWeaponStateId()
	{
		return WEP_MeleeBlock;
	}

	simulated function BeginState(name PreviousStateName)
    {
    	local float ParryDuration;

   		ParryDuration = PlayBlockStart();

		// Set the duration of the window to parry incoming attacks
		if ( ParryDuration > 0.f )
		{
			SetTimer( ParryDuration, false, nameof(ParryCheckTimer) );
		}

		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		if ( Instigator.IsLocallyControlled() )
		{
			PlayAnimation(MeleeBlockEndAnim);
		}

		//SetSlowMovement(false);
		NotifyEndState();
	}

	/** Return to active state if we're done blocking */
	simulated function EndFire(byte FireModeNum)
	{
		Global.EndFire(FireModeNum);

		// Wait until parry is finished, then check PendingFire to stop blocking
		if ( !StillFiring(CurrentFireMode) && !IsTimerActive(nameof(ParryCheckTimer)) )
		{
			GotoState('BlockingCooldown');
		}
	}

	/** After the parry window is finished, check PendingFire to see if we're still blocking */
	simulated function ParryCheckTimer()
	{
		// Check PendingFire to stop blocking
		if ( !StillFiring(CurrentFireMode) )
		{
			GotoState('BlockingCooldown');
		}
	}

	/** Grab/Grapple attacks can be parried */
	function bool IsGrappleBlocked(Pawn InstigatedBy)
	{
		local float FacingDot;
		local vector Dir2d;

		// zero Z to give us a 2d dot product
		Dir2d = Normal2d(InstigatedBy.Location - Instigator.Location);
		FacingDot = vector(Instigator.Rotation) dot (Dir2d);

		// Cos(85)
		if ( FacingDot > 0.087f )
		{
			if ( IsTimerActive(nameof(ParryCheckTimer)) )
			{
				KFPawn(InstigatedBy).NotifyAttackParried(Instigator, 255);
				ClientPlayParryEffects();
				NotifyAttackParried();
			}
			else
			{
				ClientPlayBlockEffects();
				NotifyAttackBlocked();
			}

			return TRUE;
		}
		return FALSE;
	}

	/** While holding a melee weapon reduce some incoming damage */
	function AdjustDamage(out int InDamage, class<DamageType> DamageType, Actor DamageCauser)
	{
		local float FacingDot;
		local vector Dir2d;
		local KFPerk InstigatorPerk;
		local byte BlockTypeIndex;

		// don't apply block/parry effects for teammates
		if (Instigator.IsSameTeam(DamageCauser.Instigator))
		{
			return;
		}

		// zero Z to give us a 2d dot product
		Dir2d = Normal2d(DamageCauser.Location - Instigator.Location);
		FacingDot = vector(Instigator.Rotation) dot (Dir2d);

		// Cos(85)
		if ( FacingDot > 0.087f && CanBlockDamageType(DamageType, BlockTypeIndex) )
		{
			InstigatorPerk = GetPerk();

			if ( IsTimerActive(nameof(ParryCheckTimer)) )
			{
				InDamage *= GetUpgradedParryDamageMitigation(CurrentWeaponUpgradeIndex);
				// Notify attacking pawn for effects / animations
				if ( KFPawn(DamageCauser) != None )
				{
					KFPawn(DamageCauser).NotifyAttackParried(Instigator, ParryStrength);
				}

				// @NOTE: This is now always true per discussion with AndrewL on KFII-29686. Since we always
				// do the damage mitigation, we should always play the effect regardless of whether the
				// zed was stumbled or knocked down. -MattF
				ClientPlayParryEffects(BlockTypeIndex);

				NotifyAttackParried();

				if( InstigatorPerk != none )
				{
					InstigatorPerk.SetSuccessfullParry();
				}
			}
			else
			{
				InDamage *= GetUpgradedBlockDamageMitigation(CurrentWeaponUpgradeIndex);
				ClientPlayBlockEffects(BlockTypeIndex);

				NotifyAttackBlocked();

				if( InstigatorPerk != none )
				{
					InstigatorPerk.SetSuccessfullBlock();
				}
			}
		}
	}

	simulated function BlockLoopTimer()
	{
		if( Instigator.IsLocallyControlled() )
		{
			PlayAnimation(MeleeBlockLoopAnim, , true);
		}
	}

	/** State override for Block_Hit animations */
	unreliable client function ClientPlayBlockEffects(optional byte BlockTypeIndex=255)
	{
		local int AnimIdx;
		local float Duration;
		local KFPerk InstigatorPerk;

		Global.ClientPlayBlockEffects(BlockTypeIndex);

		InstigatorPerk = GetPerk();
		if( InstigatorPerk != none )
		{
			InstigatorPerk.SetSuccessfullBlock();
		}

		if( MeleeBlockHitAnims.Length > 0 && `TimeSince(LastBlockHitAnimTime) > BlockHitAnimCooldownTime && !IsTimerActive(nameof(ParryCheckTimer)) )
		{
			AnimIdx = Rand(MeleeBlockHitAnims.Length);
			Duration = MySkelMesh.GetAnimLength(MeleeBlockHitAnims[AnimIdx]);

			if ( Duration > 0 )
			{
				LastBlockHitAnimTime = WorldInfo.TimeSeconds;
				PlayAnimation(MeleeBlockHitAnims[AnimIdx]);
				SetTimer(Duration, false, nameof(BlockLoopTimer));
			}
		}
	}
}

simulated function float PlayBlockStart()
{
	local float AnimDuration;

	if( Instigator.IsLocallyControlled() )
	{
		PlayAnimation(MeleeBlockStartAnim);
	}

	// set when to start playing the looping anim
	AnimDuration = MySkelMesh.GetAnimLength(MeleeBlockStartAnim);
	if ( AnimDuration > 0.f )
	{
		SetTimer(AnimDuration, false, nameof(BlockLoopTimer));
	}
	else
	{
		BlockLoopTimer();
	}

	// set the parry duration to the same as the block start anim
	return AnimDuration;
}

/** Called on the client when successfully block/parry an attack */
simulated function PlayLocalBlockEffects(AKBaseSoundObject Sound, ParticleSystem PSTemplate)
{
	local vector Loc;
	local rotator Rot;
	local ParticleSystemComponent PSC;

	if ( Sound != None )
	{
		PlaySoundBase(Sound, true);
	}

	if ( PSTemplate != None )
	{
		if ( MySkelMesh.GetSocketWorldLocationAndRotation(BlockEffectsSocketName, Loc, Rot) )
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

/** If true, this damage type can be blocked by the MeleeBlocking state */
function bool CanBlockDamageType(class<DamageType> DamageType, optional out byte out_Idx)
{
	local int Idx;

	// Check if this damage should be ignored completely
	for (Idx = 0; Idx < BlockTypes.length; ++Idx)
	{
		if ( ClassIsChildOf(DamageType, BlockTypes[Idx].DmgType) )
		{
			out_Idx = Idx;
			return true;
		}
	}

	out_Idx = INDEX_NONE;
	return false;
}

/** Returns sound and particle system overrides using index into BlockTypes array */
simulated function GetBlockEffects(byte BlockIndex, out AKBaseSoundObject outSound, out ParticleSystem outParticleSys)
{
	outSound = BlockSound;
	outParticleSys = BlockParticleSystem;

	if ( BlockIndex != 255 )
	{
		if ( BlockTypes[BlockIndex].BlockSound != None )
		{
			outSound = BlockTypes[BlockIndex].BlockSound;
		}
		if ( BlockTypes[BlockIndex].BlockParticleSys != None )
		{
			outParticleSys = BlockTypes[BlockIndex].BlockParticleSys;
		}
	}
}

/** Returns sound and particle system overrides using index into BlockTypes array */
simulated function GetParryEffects(byte BlockIndex, out AKBaseSoundObject outSound, out ParticleSystem outParticleSys)
{
	outSound = ParrySound;
	outParticleSys = ParryParticleSystem;

	if ( BlockIndex != 255 )
	{
		if ( BlockTypes[BlockIndex].ParrySound != None )
		{
			outSound = BlockTypes[BlockIndex].ParrySound;
		}
		if ( BlockTypes[BlockIndex].ParryParticleSys != None )
		{
			outParticleSys = BlockTypes[BlockIndex].ParryParticleSys;
		}
	}
}

/*********************************************************************************************
 * State BlockingCooldown
  * A short cooldown state to prevent spamming block while still allowing pendingfire to be set
 *********************************************************************************************/

// Global declarations for this state
simulated function BlockCooldownTimer();

simulated state BlockingCooldown extends Active
{
	ignores AllowSprinting;

	/** Set cooldown duration */
	simulated function BeginState( Name PreviousStateName )
	{
		SetTimer(0.5, false, nameof(BlockCooldownTimer));
		Super.BeginState(PreviousStateName);
	}

	// prevent going to block/parry state
	simulated function bool HasAmmo( byte FireModeNum, optional int Amount )
	{
		if ( FireModeNum == BLOCK_FIREMODE )
		{
			return false;
		}

		return Global.HasAmmo(FireModeNum, Amount);
	}

	// prevent HasAmmo (above) from causing an auto reload
	simulated function bool ShouldAutoReload(byte FireModeNum)
	{
		if ( FireModeNum == BLOCK_FIREMODE )
		{
			return false;
		}

		return Global.ShouldAutoReload(FireModeNum);
	}

	simulated function BlockCooldownTimer()
	{
		GotoState('Active');
	}
}

/*
 *
 * END of parrying code.
 *
 */


/**
 * Toggle between DEFAULT and ALTFIRE
 */
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

	Super(KFWeapon).StartFire(BLOCK_FIREMODE);
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

/*********************************************************************************************
 * Upgrades
 ********************************************************************************************/

static simulated function float GetUpgradedBlockDamageMitigation(int UpgradeIndex)
{
	return GetUpgradedStatValue(default.BlockDamageMitigation, EWUS_BlockDmgMitigation, UpgradeIndex);
}

static simulated function float GetUpgradedParryDamageMitigation(int UpgradeIndex)
{
	return GetUpgradedStatValue(default.ParryDamageMitigationPercent, EWUS_ParryDmgMitigation, UpgradeIndex);
}

simulated function int GetModifiedDamage(byte FireModeNum, optional vector RayDir)
{
	if (FireModeNum == BASH_FIREMODE)
	{
		return GetUpgradedStatValue(InstantHitDamage[FireModeNum], EWUS_Damage2, CurrentWeaponUpgradeIndex);
	}

	return super.GetModifiedDamage(FireModeNum, RayDir);
}

/** Check AmmoCount and update anim tree nodes if needed */
simulated function UpdateOutOfAmmoEffects(float BlendTime)
{
	if ( WorldInfo.NetMode == NM_DedicatedServer )
		return;

	if( EmptyMagBlendNode != None )
	{
		// Differentiate Left/Right
		if ( bAllowClientAmmoTracking && AmmoCount[0] <= 1 )
		{
			EmptyMagBlendNode.SetBlendTarget(1, 0);
			if ( AmmoCount[0] == 0 )
			{

				EmptyMagBlendNode = AnimNodeBlendPerBone(SkeletalMeshComponent(Mesh).FindAnimNode('EmptyMagBlend'));
				BuildEmptyMagNodeWeightList( EmptyMagBlendNode, BonesToLockOnEmpty_Override );
				
				EmptyMagBlendNode.SetBlendTarget(1,0);

				`Log("blending left");
				EmptyMagBlendNode_L.SetBlendTarget(1,0);
			}
		}
	}
}

/** Unlocks the bolt bone (Called by animnotify) */
simulated function ANIMNOTIFY_UnLockBolt()
{
	super.ANIMNOTIFY_UnLockBolt();
	EmptyMagBlendNode_L.SetBlendTarget(0, 0);

	EmptyMagBlendNode = AnimNodeBlendPerBone(SkeletalMeshComponent(Mesh).FindAnimNode('EmptyMagBlend'));
	BuildEmptyMagNodeWeightList( EmptyMagBlendNode, BonesToLockOnEmpty);
}

defaultproperties
{
	// Content
	PackageKey="Dual_BladedPistol"
	FirstPersonMeshName="WEP_1P_Dual_BladedPistol_MESH.WEP_1stP_DualBladedPistol_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Dual_BladedPistol_ANIM.Wep_1stP_Dual_BladedPistol_ANIM"
	PickupMeshName="WEP_3P_Dual_BladedPistol_MESH.Wep_Dual_BladedPistol_Pickup"
	AttachmentArchetypeName="WEP_Dual_BladedPistol_ARCH.Wep_Dual_BladedPistol_3P"
	MuzzleFlashTemplateName="WEP_Dual_BladedPistol_ARCH.Wep_Dual_BladedPistol_MuzzleFlash"

	Begin Object Name=FirstPersonMesh
		AnimTreeTemplate=AnimTree'CHR_1P_Arms_ARCH.WEP_1stP_Dual_Animtree_Master'
	End Object

	FireOffset=(X=30,Y=7,Z=-5)
	LeftFireOffset=(X=30,Y=-7,Z=-5)

	// Zooming/Position
	IronSightPosition=(X=-3,Y=0,Z=0)
	PlayerViewOffset=(X=-15,Y=0,Z=0)

	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=0)

	SingleClass=class'KFWeap_Pistol_Bladed'

	// FOV
	MeshFOV=96
	MeshIronSightFOV=77
    PlayerIronSightFOV=77

	// Depth of field
	DOF_FG_FocalRadius=40
	DOF_FG_MaxNearBlurSize=3.5

	// Ammo
	MagazineCapacity[0]=12
	SpareAmmoCapacity[0]=72 //96
	InitialSpareMags[0]=1
	AmmoPickupScale[0]=0.5 //1.0
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=330 //400 //250
	minRecoilPitch=300 //350 //200
	maxRecoilYaw=120 //100
	minRecoilYaw=-120 //-100
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
	FireInterval(DEFAULT_FIREMODE)=+0.19 //+0.231
	InstantHitDamage(DEFAULT_FIREMODE)=115.0
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_BladedPistol'
	Spread(DEFAULT_FIREMODE)=0.005 //0.015

	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Sawblade'

	// MELEE_BLOCK_FIREMODE
	FiringStatesArray(BLOCK_FIREMODE)=MeleeBlocking
	WeaponFireTypes(BLOCK_FIREMODE)=EWFT_Custom
	FireInterval(BLOCK_FIREMODE)=1.f
	AmmoCost(BLOCK_FIREMODE)=0

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_BladedPistol'
	InstantHitDamage(BASH_FIREMODE)=75 //26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Fire_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Handling_DryFire'

	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Fire_1P')
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_BladedPistol.Play_WEP_BladedPistol_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=true

	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'
	AssociatedPerkClasses(1)=class'KFPerk_Berserker'
	

	// Inventory
	InventoryGroup=	IG_Primary
	InventorySize=6
	GroupPriority=45
	bCanThrow=true
	bDropOnDeath=true
	WeaponSelectTexture=Texture2D'WEP_UI_Dual_BladedPistol_TEX.UI_WeaponSelect_Dual_BladedPistol'
	bIsBackupWeapon=false

	BonesToLockOnEmpty=(RW_FrontPivot)
    BonesToLockOnEmpty_L=(LW_FrontPivot)
	BonesToLockOnEmpty_Override=(RW_FrontPivot, LW_FrontPivot)
    
	bHasFireLastAnims=true

	// default MIC param names
	BlockEffectsSocketName=BlockEffect
		// Defensive
	BlockDamageMitigation=0.60f
	ParryDamageMitigationPercent=0.5
	ParryStrength=4
	BlockHitAnimCooldownTime=0.5f
	BlockTypes.Add((DmgType=class'KFDT_Bludgeon'))
	BlockTypes.Add((DmgType=class'KFDT_Slashing'))

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Crovel'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	BlockParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Block_melee_01'
	ParryParticleSystem=ParticleSystem'FX_Impacts_EMIT.FX_Parry_melee_01'
	MeleeBlockHitAnims=(Block_Hit_V1, Block_Hit_V2, Block_Hit_V3);

	// Upgrades
	UpgradeFireModes(BLOCK_FIREMODE) = 0
	//Upgrades
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Damage2, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.3f), (Stat=EWUS_Damage1, Scale=1.3f), (Stat=EWUS_Damage2, Scale=1.3f), (Stat=EWUS_Weight, Add=2)))
}

