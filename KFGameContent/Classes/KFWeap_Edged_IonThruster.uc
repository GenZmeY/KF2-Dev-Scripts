//=============================================================================
// KFWeap_Edged_IonThruster
//=============================================================================
// Basic ion beam melee weapon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Edged_IonThruster extends KFWeap_MeleeBase;

/** The current amount of charge/heat this weapon has */
var repnotify float UltimateCharge;
/** The highest amount of charge/heat this weapon can have*/
var float MaxUltimateCharge;
/** How often the DecayAmount is removed from a non-fully charged weapon */
var float DecayInterval;
/** How much charge to remove every <DecayInterval> seconds*/
var float DecayAmount;

/** How much charge to gain when hitting with each Firemode */
var array<float> UltimateChargePerHit;
/** How much charge to gain with a successful block */
var float UltimateChargePerBlock;
/** How much charge to gain with a successful parry */
var float UltimateChargePerParry;

/** Name of the special anim used for the ultimate attack */
var name UltimateAttackAnim;

/** Hitbox for the normal attack */
var array<MeleeHitBoxInfo> DefaultHitboxChain;
/** Hitbox for the ultimate attack */
var array<MeleeHitBoxInfo> UltimateHitboxChain;

/** Hit range for the default attack */
var int DefaultMaxHitRange;
/** Hit range for the ultimate attack, generated from DefaultMaxHitrange and UltimateRangeScale*/
var int UltimateMaxHitRange;
/** Relative length of the ultimate hitbox compared to the default hitbox*/
var float UltimateRangeScale;
/** Width of the ultimate hotbox */
var float UltimateWidthScale;
/** Extent of the default hitbox, defaults to 0*/
var vector DefaultHitboxExtent;
/** Extent of the Ultimate Hitbox*/
var vector UltimateHitboxExtent;

/** Particle system that plays constantly on the weapon */
var transient KFParticleSystemComponent BaseFlamePSC;
var transient KFParticleSystemComponent BaseGlowPSC;
var transient KFParticleSystemComponent BaseLightsPSC;
var const ParticleSystem BaseFlameFXTemplate;
var const ParticleSystem BaseGlowFXTemplate;
var const ParticleSystem BaseLightsFXTemplate;

var int PanelCount;
var KFParticleSystemComponent PersistentPanelPSC[12]; // Size here should equal PanelCount
var const ParticleSystem PersistentPanelEffect;

/** Particle system that plays when the weapon is fully charged */
var transient KFParticleSystemComponent ChargedPSC;
var const ParticleSystem ChargedEffect;

/** Sound loop to play when the weapon is not fully charged */
var AkEvent IdleSoundLoop;
var AkEvent IdleSoundStop;
/** Sound loop to play when the weapon is fully charged */
var AkEvent ChargedSoundLoop;
var AkEvent ChargedSoundStop;

/* Light that is applied to the blade and the bone to attach to*/
var PointLightComponent BladeLight;
var Name LightAttachBone;

replication
{
	if (bNetDirty)
		UltimateCharge;
}

simulated event ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
	case nameof(UltimateCharge):
		AdjustChargeFX();
		break;
	default:
		super.ReplicatedEvent(VarName);
	};
}

simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	SetupHitboxes();
	//Decay time removed due to feedback
	//SetTimer(DecayInterval, true, nameof(TimeR_UltimateChargeDecay));
}

/** Create box the default and ultimate hitboxes */
simulated function SetupHitboxes()
{
	SetupChain(DefaultHitboxChain, DefaultMaxHitRange, DefaultHitboxExtent);
	UltimateMaxHitRange = UltimateRangeScale * DefaultMaxHitRange;
	UltimateHitboxExtent.X = UltimateWidthScale;
	UltimateHitboxExtent.Y = UltimateWidthScale;
	UltimateHitboxExtent.Z = UltimateWidthScale;
	SetupChain(UltimateHitboxChain, UltimateMaxHitRange, UltimateHitboxExtent);

	// set the default hitbox as the active hitbox
	MeleeAttackHelper.HitboxExtent = DefaultHitboxExtent;
	MeleeAttackHelper.SetHitboxChain(DefaultHitboxChain);
	MeleeAttackHelper.SetMeleeRange(DefaultMaxHitRange);
}

/** Programmatically generate the hitbox chain */
simulated function SetupChain(out array<MeleeHitBoxInfo> OutputChain, int InputHitRange, vector HitboxExtent)
{
	local vector BoneAxis;
	local float Dist;
	local MeleeHitBoxInfo TempHitBoxInfo;

	BoneAxis = vect(0, 0, 1);
	for (Dist = InputHitRange; Dist > 0; Dist -= MeleeAttackHelper.HitboxSpacing)
	{
		TempHitBoxInfo.BoneOffset = (Dist - HitboxExtent.X) * BoneAxis;
		OutputChain.AddItem(TempHitBoxInfo);
	}
}

/** Lose charge over time */
simulated function Timer_UltimateChargeDecay()
{
	// as long as not already fully charged
	if (UltimateCharge != MaxUltimateCharge)
	{
		AdjustUltimateCharge(DecayAmount * -1);
	}
}

simulated function string GetSpecialAmmoForHUD()
{
	return int(UltimateCharge)$"%";
}

/** When this weapon hits with an attack */
simulated function NotifyMeleeCollision(Actor HitActor, optional vector HitLocation)
{
	local KFPawn_Monster Victim;

	if (HitActor.bWorldGeometry)
	{
		return;
	}

	Victim = KFPawn_Monster(HitActor);
	if ( Victim == None || (Victim.bPlayedDeath && `TimeSince(Victim.TimeOfDeath) > 0.f) )
	{
		return;
	}

	if(Victim != none)
	{
		// hit something with a melee attack so gain charge
		AdjustUltimateCharge(UltimateChargePerHit[CurrentFireMode]);
	}
}

/** When this weapon parries an attack */
simulated function NotifyAttackParried()
{
	AdjustUltimateCharge(UltimateChargePerParry);
}

/** When this weapon blocks an attack */
simulated function NotifyAttackBlocked()
{
	AdjustUltimateCharge(UltimateChargePerBlock);
}

/** Whether the weapon is fully charged */
simulated function bool IsFullyCharged()
{
	return UltimateCharge >= MaxUltimateCharge;
}

/** Increase or decrease ultimate charge as long as not already fully charged*/
simulated function AdjustUltimateCharge(float AdjustAmount)
{
	if (!IsFullyCharged())
	{
		UltimateCharge = FClamp(UltimateCharge + AdjustAmount, 0.f, MaxUltimateCharge);
		AdjustChargeFX();
	}
}

simulated function AdjustChargeFX()
{
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		KFPawn(Instigator).SetWeaponComponentRTPCValue("Weapon_Charge", UltimateCharge / MaxUltimateCharge);
		Instigator.SetRTPCValue('Weapon_Charge', UltimateCharge / MaxUltimateCharge);

		if (IsFullyCharged())
		{
			ActivatePSC(ChargedPSC, ChargedEffect, 'Hand_FX_Start_R');
			AdjustLoopingWeaponSound(true);
		}
	}
}

/** Determine which looping idle/charged sound to play */
simulated function AdjustLoopingWeaponSound(bool bShouldPlay)
{
	local KFPawn InstigatorPawn;

	if (Instigator != none)
	{
		InstigatorPawn = KFPawn(Instigator);
		if (InstigatorPawn != none)
		{
			if (bShouldPlay)
			{
				if (IsFullyCharged())
				{
					InstigatorPawn.PlayWeaponSoundEvent(IdleSoundStop);
					InstigatorPawn.PlayWeaponSoundEvent(ChargedSoundLoop);
				}
				else
				{
					InstigatorPawn.PlayWeaponSoundEvent(ChargedSoundStop);
					InstigatorPawn.PlayWeaponSoundEvent(IdleSoundLoop);
				}
			}
			else
			{
				InstigatorPawn.PlayWeaponSoundEvent(IdleSoundStop);
				InstigatorPawn.PlayWeaponSoundEvent(ChargedSoundStop);
			}
		}
	}
}

// OLD WAY (heavyfire firemode)
//simulated state MeleeHeavyAttacking
//{
//	simulated event BeginState(Name PreviousStateName)
//	{
//		Super.BeginState(PreviousStateName);
//
//		if (IsFullyCharged())
//		{
//			// perform ultimate
//			SendToFiringState(CUSTOM_FIREMODE);
//		}
//	}
//}

// NEW WAY (reload firemode)
simulated function StartFire(byte FireModeNum)
{
	if (FireModeNum == RELOAD_FIREMODE && IsFullyCharged())
	{
		FireModeNum = CUSTOM_FIREMODE;
	}

	super.StartFire(FireModeNum);
}

/** State for the fully charged Ultimate attack */
simulated state UltimateAttackState extends MeleeHeavyAttacking
{
	simulated function bool TryPutDown() { return false; }

	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);

		// stop the player from interrupting the super attack with another attack
		StartFireDisabled = true;

		// swap to the larger ultimate hitbox
		MeleeAttackHelper.HitboxExtent = UltimateHitboxExtent;
		MeleeAttackHelper.SetHitboxChain(UltimateHitboxChain);
		MeleeAttackHelper.SetMeleeRange(UltimateMaxHitRange);
		MeleeAttackHelper.bUseDirectionalMelee = false;
		MeleeAttackHelper.bHasChainAttacks = false;
	}

	simulated function name GetMeleeAnimName(EPawnOctant AtkDir, EMeleeAttackType AtkType)
	{
		// use the special attack anim
		return UltimateAttackAnim;
	}

	simulated event EndState(Name NextStateName)
	{
		super.EndState(NextStateName);

		// consume charge
		UltimateCharge = 0;
		AdjustLoopingWeaponSound(true);
		KFPawn(Instigator).SetWeaponComponentRTPCValue("Weapon_Charge", 0.0f);
		Instigator.SetRTPCValue('Weapon_Charge', 0.0f);

		// disable "charged" vfx
		if (ChargedPSC != none)
		{
			ChargedPSC.DeactivateSystem();
		}

		// player can now interrupt attacks with other attacks again
		StartFireDisabled = false;

		// swap back to the default hitbox
		MeleeAttackHelper.HitboxExtent = DefaultHitboxExtent;
		MeleeAttackHelper.SetHitboxChain(DefaultHitboxChain);
		MeleeAttackHelper.SetMeleeRange(DefaultMaxHitRange);
		MeleeAttackHelper.bUseDirectionalMelee = true;
		MeleeAttackHelper.bHasChainAttacks = true;
	}
}

simulated function ActivatePSC(out KFParticleSystemComponent OutPSC, ParticleSystem ParticleEffect, name SocketName)
{
	if (MySkelMesh != none)
	{
		MySkelMesh.AttachComponentToSocket(OutPSC, SocketName);
		OutPSC.SetFOV(MySkelMesh.FOV);
	}
	else
	{
		AttachComponent(OutPSC);
	}

	OutPSC.ActivateSystem();

	if (OutPSC != none)
	{
		OutPSC.SetTemplate(ParticleEffect);
		OutPSC.SetDepthPriorityGroup(SDPG_Foreground);
	}
}

simulated state WeaponEquipping
{
	// when picked up, start the persistent sound and particles
	simulated event BeginState(Name PreviousStateName)
	{
		local int i;
		local name PSCSocketName;

		super.BeginState(PreviousStateName);
		ActivatePSC(BaseFlamePSC, BaseFlameFXTemplate, 'Hand_FX_Start_R');
		ActivatePSC(BaseGlowPSC, BaseGlowFXTemplate, 'Hand_FX_Start_R');
		ActivatePSC(BaseLightsPSC, BaseLightsFXTemplate, 'Hand_FX_Start_R');

		for (i = 0; i < PanelCount; i++)
		{
			PSCSocketName = 'RW_HeatShield';
			if (i+1 < 10)
			{
				PSCSocketName = Name(PSCSocketName$'0');
			}
			PSCSocketName = Name(PSCSocketName$(i+1));

			ActivatePSC(PersistentPanelPSC[i], PersistentPanelEffect, PSCSocketName);
		}

		AdjustLoopingWeaponSound(true);

		if (MySkelMesh != none)
		{
			MySkelMesh.AttachComponentToSocket(BladeLight, LightAttachBone);
			BladeLight.SetEnabled(true);
		}
	}
}

simulated state Inactive
{
	// when dropped, destroyed, etc, play the stop on the persistent sound
	simulated event BeginState(Name PreviousStateName)
	{
		local int i;

		super.BeginState(PreviousStateName);

		if (BaseFlamePSC != none)
		{
			BaseFlamePSC.DeactivateSystem();
		}

		if (BaseGlowPSC != none)
		{
			BaseGlowPSC.DeactivateSystem();
		}

		if (BaseLightsPSC != none)
		{
			BaseLightsPSC.DeactivateSystem();
		}

		for (i = 0; i < PanelCount; i++)
		{
			PersistentPanelPSC[i].DeactivateSystem();
		}

		AdjustLoopingWeaponSound(false);

		BladeLight.SetEnabled(false);
	}
}

simulated function DetachWeapon()
{
	AdjustLoopingWeaponSound(false);
	Super.DetachWeapon();
}

simulated state WeaponPuttingDown
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		AdjustLoopingWeaponSound(false);
	}
}

simulated state WeaponAbortEquip
{
	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		AdjustLoopingWeaponSound(false);
	}
}

simulated event bool HasAmmo(byte FireModeNum, optional int Amount)
{
	if (FireModeNum == CUSTOM_FIREMODE)
	{
		return IsFullyCharged();
	}

	return super.HasAmmo(FireModeNum, Amount);
}

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=2,Y=0,Z=0)

	// Content
	PackageKey="Ion_Sword"
	FirstPersonMeshName="WEP_1P_Ion_Sword_MESH.Wep_1stP_Ion_Sword_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Ion_Sword_ANIM.Wep_1stP_Ion_Sword_Anim"
	PickupMeshName="WEP_3P_Ion_Sword_MESH.Wep_3rdP_Ion_Sword_Pickup"
	AttachmentArchetypeName="WEP_Ion_Sword_ARCH.Wep_Ion_Thruster_3P"

	Begin Object Name=MeleeHelper_0
		//bDebugShowCollision=true
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Bladed_melee_impact'
		MeleeImpactCamShakeScale=0.03f //0.3
		// modified combo sequences
		ChainSequence_F=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardRight, DIR_ForwardLeft, DIR_BackwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L=(DIR_Right, DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
		ChainSequence_R=(DIR_Left, DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_IonThruster'
	InstantHitDamage(DEFAULT_FIREMODE)=92

	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_IonThrusterHeavy'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=152

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_IonThrusterStab'
	InstantHitDamage(BASH_FIREMODE)=85

	FiringStatesArray(CUSTOM_FIREMODE)=UltimateAttackState
	InstantHitDamageTypes(CUSTOM_FIREMODE)=class'KFDT_Slashing_IonThrusterSpecial'
	InstantHitDamage(CUSTOM_FIREMODE)=400
	InstantHitMomentum(CUSTOM_FIREMODE)=100000.f
	WeaponFireTypes(CUSTOM_FIREMODE)=EWFT_Custom

	// Inventory
	GroupPriority=125
	InventorySize=8
	WeaponSelectTexture=Texture2D'WEP_UI_Ion_Sword_TEX.UI_WeaponSelect_IonSword'
	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	ParryDamageMitigationPercent=0.4
	BlockDamageMitigation=0.5
	ParryStrength=5

	UltimateCharge=0.0f
	MaxUltimateCharge=100.0f;

	//Decay time removed. Enable by uncommenting the line in PreBeginPlay()
	DecayInterval=1.f
	DecayAmount=1.f

	UltimateChargePerHit(DEFAULT_FIREMODE)=1.0f
	UltimateChargePerHit(BASH_FIREMODE)=1.0f
	UltimateChargePerHit(HEAVY_ATK_FIREMODE)=3.0f
	UltimateChargePerHit(CUSTOM_FIREMODE)=0.0f
	UltimateChargePerBlock=1.0f
	UltimateChargePerParry=5.0f

	UltimateAttackAnim=Super_Attack

	DefaultMaxHitRange=240
	UltimateRangeScale=2.0f
	UltimateWidthScale=70.f

	PanelCount=12

	BaseFlameFXTemplate=ParticleSystem'WEP_Ion_Sword_EMIT.FX_ION_Idle_Base_Flame_01'
	BaseGlowFXTemplate=ParticleSystem'WEP_Ion_Sword_EMIT.FX_ION_Idle_Base_Glow_01'
	BaseLightsFXTemplate=ParticleSystem'WEP_Ion_Sword_EMIT.FX_ION_Idle_Base_Lights_01'
	PersistentPanelEffect=ParticleSystem'WEP_Ion_Sword_EMIT.FX_ION_Idle_Heat_Panel_01'
	ChargedEffect=ParticleSystem'WEP_Ion_Sword_EMIT.FX_ION_Charged_Ring_01'


	// Create all these particle system components off the bat so that the tick group can be set
	// fixes issue where the particle systems get offset during animations
	Begin Object Class=KFParticleSystemComponent Name=ChargedParticleSystem
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=BasePSC0
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=BasePSC1
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=BasePSC2
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC0
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC1
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC2
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC3
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC4
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC5
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC6
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC7
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC8
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC9
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC10
		TickGroup=TG_PostUpdateWork
	End Object

	Begin Object Class=KFParticleSystemComponent Name=PanelPSC11
		TickGroup=TG_PostUpdateWork
	End Object

	ChargedPSC=ChargedParticleSystem
	BaseFlamePSC=BasePSC0
	BaseGlowPSC=BasePSC1
	BaseLightsPSC=BasePSC2
	PersistentPanelPSC(0)=PanelPSC0
	PersistentPanelPSC(1)=PanelPSC1
	PersistentPanelPSC(2)=PanelPSC2
	PersistentPanelPSC(3)=PanelPSC3
	PersistentPanelPSC(4)=PanelPSC4
	PersistentPanelPSC(5)=PanelPSC5
	PersistentPanelPSC(6)=PanelPSC6
	PersistentPanelPSC(7)=PanelPSC7
	PersistentPanelPSC(8)=PanelPSC8
	PersistentPanelPSC(9)=PanelPSC9
	PersistentPanelPSC(10)=PanelPSC10
	PersistentPanelPSC(11)=PanelPSC11

	IdleSoundLoop=AkEvent'WW_WEP_MEL_IonThruster.Play_WEP_IonThruster_Handling_Idle_LP'
	IdleSoundStop=AkEvent'WW_WEP_MEL_IonThruster.Stop_WEP_IonThruster_Handling_Idle_LP'
	ChargedSoundLoop=AkEvent'WW_WEP_MEL_IonThruster.Play_WEP_IonThruster_Handling_Idle_Super_LP'
	ChargedSoundStop=AkEvent'WW_WEP_MEL_IonThruster.Stop_WEP_IonThruster_Handling_Idle_Super_LP'

    Begin Object Class=PointLightComponent Name=BladePointLight
		LightColor=(R=250,G=150,B=85,A=255)
		Brightness=0.125f
		FalloffExponent=4.f
		Radius=128.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=TRUE
		bCastPerObjectShadows=false
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	BladeLight=BladePointLight
	LightAttachBone=Hand_FX_Start_R
}
