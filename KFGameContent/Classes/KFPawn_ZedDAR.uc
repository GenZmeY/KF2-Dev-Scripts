//=============================================================================
// KFPawn_ZedDAR
//=============================================================================
// Base pawn for evil DAR robots.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedDAR extends KFPawn_Monster
	abstract;

var protected KFAIController_ZedDAR MyDARController;

var class<KFProjectile> RangedProjectileClass;

var const name FiringSocketLName;
var const name FiringSocketRName;
var name FiringSocketName;

var protected transient bool bHasExploded;
/** Explosion template for backpack/suicide */
var protected KFGameExplosion ExplosionTemplate;

/** HitZoneIndex of backpack zone */
const ChestBombZoneIndex = 3;

var transient bool bChestArmorDestroyedThisFrame;

function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);

	MyDARController = KFAIController_ZedDAR(C);
}

simulated function StartRangedAttack()
{
	local KFSM_RangedAttack RangedSM;

	if(MyDARController != none)
	{
		RangedSM = KFSM_RangedAttack(SpecialMoves[SpecialMove]);
		MyDARController.FireRangedAttack(RangedProjectileClass, RangedSM.GetFireOffset());
	}
}

function OnStackingAfflictionChanged(byte Id)
{
	Super.OnStackingAfflictionChanged(Id);

	if (MyKFAIC == none || !IsAliveAndWell())
	{
		return;
	}

	if (bEMPDisrupted)
	{
		if (IsDoingSpecialMove(SM_StandAndShootAttack))
		{
			EndSpecialMove();
		}
	}
}

function AdjustPlayHitForArmor(out float InDamage, out TraceHitInfo InHitInfo)
{
	local int HitZoneIdx;

	// If the gore health is empty, then the armor has been completely reduced (and fallen off)
	// so play the normal hit otherwise mark it as taken by the armor
	HitZoneIdx = GetHitZoneIndex(InHitInfo.BoneName);
	if (HitZoneIdx == INDEX_NONE || HitZones[HitZoneIdx].GoreHealth > 0)
	{
		super.AdjustPlayHitForArmor(InDamage, InHitInfo);
	}
}

function int GetHitZoneIndex(name BoneName)
{
	if (BoneName == 'KBArmor')
	{
		//Known arbitrary, hacking some things in place
		return OverrideArmorFXIndex;
	}

	return super.GetHitZoneIndex(BoneName);
}

simulated function KFSkinTypeEffects GetHitZoneSkinTypeEffects(int HitZoneIdx)
{
	if (HitZoneIdx == OverrideArmorFXIndex)
	{
		return CharacterArch.ImpactSkins[3];
	}
	return super.GetHitZoneSkinTypeEffects(HitZoneIdx);
}

function CauseHeadTrauma(float BleedOutTime = 5.f)
{
	// DAR doesn't bleed out from losing its head.
}

function ZedExplodeArmor(int ArmorZoneIdx, name ArmorZoneName)
{
	super.ZedExplodeArmor(ArmorZoneIdx, ArmorZoneName);
	if (MyDARController != none)
	{
		MyDARController.OnArmorLoss(ArmorZoneName);
	}

	if (ArmorZoneName == 'front')
	{
		bChestArmorDestroyedThisFrame = true;
	}
}

function SetSprinting(bool bNewSprintStatus)
{
	if (bNewSprintStatus)
	{
		if(CanDoSpecialMove(SM_SprintStart))
		{
			DoSpecialMove(SM_SprintStart, true,, SpecialMoves[SM_SprintStart].PackFlagsBase(self));
		}
	}
	else
	{
		super.SetSprinting(bNewSprintStatus);
	}
}

simulated function NotifySpecialMoveEnded(KFSpecialMove FinishedMove, ESpecialMove SMHandle)
{
	super.NotifySpecialMoveEnded(FinishedMove, SMHandle);

	if (SMHandle == SM_SprintStart)
	{
		// Finish sprinting setup
		super.SetSprinting(true);
	}
}

function PlayHit(float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo)
{
	super.PlayHit(Damage, InstigatedBy, HitLocation, damageType, Momentum, HitInfo);

	if (Role == ROLE_Authority && TimeOfDeath == WorldInfo.TimeSeconds && bChestArmorDestroyedThisFrame)
	{
		bChestArmorDestroyedThisFrame = false;
		TriggerExplosion(true);
	}
}

/** Plays hit effects on dead zeds, this includes dismemberment and obliteration */
simulated function PlayDeadHitEffects(vector HitLocation, vector HitDirection, int HitZoneIndex, name HitZoneName, name HitBoneName, class<KFDamageType> DmgType, optional bool bUseHitImpulse)
{
	local class<KFProj_PinningBullet> PinProjectileClass;
	local KFPawn DeadPawn;
	local KFGoreManager GoreManager;
	local bool bIsDismemberingHit;
	local bool bWasObliterated;

	// If ragdoll and gore is not allowed for dead bodies, check the time of death
	// to see when the pawn died, and skip if he has been dead for a while
	if (bAllowRagdollAndGoreOnDeadBodies || `TimeSince(TimeOfDeath) <= 3.f )
	{
	// If this zone is 'injured' try to dismember it
	if ((InjuredHitZones & (1 << HitZoneIndex)) > 0 && !HitZones[HitZoneIndex].bPlayedInjury)
	{
		bIsDismemberingHit = PlayDismemberment(HitZoneIndex, DmgType, HitDirection);

		// If there was no dismemberment, explode head instead
		if (!bIsDismemberingHit && (InjuredHitZones & (1 << HZI_Head)) > 0)
		{
			PlayHeadAsplode();
			// Set bIsDismemberingHit to true to add an impulse to the neck
			bIsDismemberingHit = true;
		}
	}

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
	// If the gore manager doesn't allow mutilation, then we don't allow anything other than basic effects.
	if (GoreManager.AllowMutilation() && (HitFxInfo.bObliterated || HitZoneIndex == 3) && `TimeSince(TimeOfDeath) < 0.25f && !bUseDamageInflation)
	{
		bWasObliterated = true;
		bIsDismemberingHit = true;
		HandlePartialGoreAndGibs(DmgType, HitLocation, HitDirection, HitBoneName, true);

		GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);
		GoreManager.SpawnObliterationBloodEffect(self);
	}
	else
	{
		// Handle damage types from projectiles that can pin zeds to walls
		PinProjectileClass = DmgType.static.GetPinProjectileClass();
		if (PinProjectileClass != none)
		{
			DeadPawn = self;
			PinProjectileClass.static.CreatePin(DeadPawn, HitLocation, HitDirection, HitBoneName);
		}

		HandlePartialGoreAndGibs(DmgType, HitLocation, HitDirection, HitBoneName, false);
	}

	// Apply an impulse to attached limbs and ragdoll
	HandleRagdollImpulseEffects(HitLocation, HitDirection, HitZoneName, HitBoneName, DmgType, bIsDismemberingHit, bUseHitImpulse);
	}

	// Play blood effects. Apply more blood if this was a dismembering hit
	ApplyBloodDecals(HitZoneIndex, HitLocation, HitDirection, HitZoneName, HitBoneName, DmgType, bIsDismemberingHit, bWasObliterated);
}

function bool CanInjureHitZone(class<DamageType> DamageType, int HitZoneIdx)
{
	if (HitZoneIdx == ChestBombZoneIndex && (!bPlayedDeath || WorldInfo.TimeSeconds == TimeOfDeath))
	{
		return true;
	}

	return super.CanInjureHitZone(DamageType, HitZoneIdx);
}

/** Reliably play any gore effects related to a zone/limb being dismembered */
simulated function HitZoneInjured(optional int HitZoneIdx = INDEX_None)
{
	Super.HitZoneInjured(HitZoneIdx);

	// Server only since we use a replicated explosion actor
	if (Role == ROLE_Authority && HitZoneIdx == ChestBombZoneIndex)
	{
		TriggerExplosion(true);
	}
}

/** Called when husk backpack is exploded or when husk suicides */
simulated function TriggerExplosion(optional bool bIgnoreHumans)
{
	local KFExplosionActorReplicated ExploActor;
	local Controller DamageInstigator, OldController;
	local bool bExplodeOnDeath;

	bExplodeOnDeath = WorldInfo.TimeSeconds == TimeOfDeath;


	// Only living husks can explode... and only once
	if (!bHasExploded)
	{
		OldController = Controller;
		bHasExploded = true;

		if (Role == ROLE_Authority)
		{
			// explode using the given template
			ExploActor = Spawn(class'KFExplosionActorReplicated', self);
			if (ExploActor != None)
			{
				DamageInstigator = (bIgnoreHumans && LastHitBy != none && KFPlayerController(LastHitBy) != none) ? LastHitBy : MyKFAIC;
				ExploActor.InstigatorController = DamageInstigator;
				ExploActor.Instigator = self;

				// Force ourselves to get hit.  These settings are not replicated,
				// but they only really make a difference on the server anyway.
				ExploActor.Attachee = self;
				if (bIgnoreHumans)
				{
					ExplosionTemplate.ActorClassToIgnoreForDamage = class'KFPawn_Human';
				}
				else
				{
					ExplosionTemplate.ActorClassToIgnoreForDamage = none;
				}

				ExploActor.Explode(ExplosionTemplate, vect(0, 0, 1));
			}

			// Make sure we're dead!
			if (!bPlayedDeath || bExplodeOnDeath)
			{
				Health = 0;
				Died(DamageInstigator, ExplosionTemplate.MyDamageType, Location);
			}
		}

		OnExploded(OldController);
	}
}

/** Overriden in subclasses.  Determines if we should explode on death in specific game modes */
function bool WeeklyShouldExplodeOnDeath()
{
	return !bHasExploded;
}

/** Do any explosion death-related actions */
simulated function OnExploded(Controller SuicideController);

/**
 * Return true if this pawn is ok with having the input head bone be broken
 *
 * @param	BoneName	the head bone to check to see if we all it to break.
 */
simulated function bool ShouldAllowHeadBoneToBreak(name BoneName)
{
    return true;
}

defaultproperties
{
	MinSpawnSquadSizeType=EST_Medium

	bEnableAimOffset=true

	Health=775//462 //562
	DoshValue=17
	Mass=85.f //65

	// ---------------------------------------------
	// Stats
	XPValues(0)=15
	XPValues(1)=20
	XPValues(2)=27
	XPValues(3)=31

	// ---------------------------------------------
	// Movement / Physics
	GroundSpeed=170.0f
	SprintSpeed=600.0f //450 //550

	RotationRate=(Pitch=50000,Yaw=66000,Roll=50000)

	Begin Object Name=MeleeHelper_0
		BaseDamage=10.f
		MaxHitRange=180.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	ArmorInfoClass=class'KFZedArmorInfo_EvilDAR'
	ArmorZoneStatus=3
	PreviousArmorZoneStatus=3
	OverrideArmorFXIndex=200
	RepArmorPct[0]=255
	RepArmorPct[1]=255

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_SprintStart)=class'KFGame.KFSM_StartSprintAnim'
	End Object

	// Explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	LightColor = (R=128,G=200,B=255,A=255)
	bCastPerObjectShadows = false
	End Object

	// Backpack/Suicide Explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
	Damage=25
	DamageRadius=500
	DamageFalloffExponent=0.5f
	DamageDelay=0.f
	bFullDamageToAttachee=true

	// Damage Effects
	MyDamageType = class'KFDT_EMP'
	FractureMeshRadius = 200.0
	FracturePartVel = 500.0
	ExplosionEffects = KFImpactEffectInfo'FX_Impacts_ARCH.Explosions.EDar_EMP_Explosion'
	ExplosionSound = AkEvent'WW_WEP_EXP_Grenade_EMP.Play_WEP_EXP_Grenade_EMP_Explosion'

	// Dynamic Light
	ExploLight=ExplosionPointLight
	ExploLightStartFadeOutTime=0.0
	ExploLightFadeOutTime=0.5

	// Camera Shake
	CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.HuskSuicide'
	CamShakeInnerRadius=450
	CamShakeOuterRadius=900
	CamShakeFalloff=1.f
	bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0


	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 2.0, 0.5, 0.5, 2.0), Cooldown=5.0,  Duration=1.5)
	IncapSettings(AF_Knockdown)=(Vulnerability=(1.0),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(1.0),                     Cooldown=1.0)   //0.4
	IncapSettings(AF_GunHit)=	(Vulnerability=(0.9),                     Cooldown=0.2)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                     Cooldown=0.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(0.5),                     Cooldown=6.0,  Duration=5.0)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Poison)=	(Vulnerability=(0.05),	                  Cooldown=20.5, Duration=5.0)
	IncapSettings(AF_Microwave)=(Vulnerability=(3),                       Cooldown=6.5,  Duration=4.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(0.9),                     Cooldown=1.0,  Duration=4.2)
	IncapSettings(AF_Snare)=	(Vulnerability=(1.0, 1.0, 2.0, 1.0, 1.0), Cooldown=5.5,  Duration=3.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.01))
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))

	ShrinkEffectModifier = 0.7f


    ParryResistance=1

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.05))) //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.05)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.2)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.0)))  //0.7
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))  //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.25)))  //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(1.25)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.5))) //0.5 //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(3.25))) //0.85 //2.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 				    DamageScale=(2.5))) //0.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.85))) //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.05))) //0.25

	//special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_HRGHealthrower',       				DamageScale=(1.2)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_Beam',       				DamageScale=(3.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGeneratorSphereImpact',       		DamageScale=(2)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_DefaultFiremodeZapDamage', 	DamageScale=(3.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_AltFiremodeZapDamage',		DamageScale=(3.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_MineReconstructorExplosion',       	DamageScale=(1.8)))


	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=350, DmgScale=1.001, SkinID=1)  // KF1=200     //154
    HitZones[3]       =(ZoneName=heart,	   BoneName=Spine1,		  Limb=BP_Special,  GoreHealth=150, DmgScale=3.5, SkinID=2) //1.4

	WeakSpotSocketNames.Empty()
	WeakSpotSocketNames.Add(FX_Armor_Chest) // Chest

	StartSprintingSound=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_Thruster_Start'
	SprintLoopingSound=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_Thruster_LP'
	StopSprintingSound=AkEvent'WW_ZED_Evil_DAR.Play_ZED_EvilDAR_SFX_Thruster_Stop'

	ZEDCowboyHatAttachName=Hat_Attach
}
