//=============================================================================
// KFPawn_ZedMatriarch
//=============================================================================
// Pawn class for the matriarch.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFPawn_ZedMatriarch extends KFPawn_MonsterBoss;

const HEAD_ARMOR_IDX = 0;
const CLAW_ARMOR_IDX = 1;

const BATTLE_PHASE_SHIELD = 0;
const BATTLE_PHASE_ARMOR = 1;
const BATTLE_PHASE_FLESH = 2;
const BATTLE_PHASE_CLOAK = 3;

//=============================================================================
// @name Battle Phases
//=============================================================================

struct BattleDamageFXInfo
{
	var ParticleSystem Template;
	var array<name> Sockets;
};

struct BattleDamageInfo
{
	var array<BattleDamageFXInfo> FXInfo;
	var transient array<ParticleSystemComponent> FXComponents;
};

/** Info for patriarch battle phases */
struct MatriarchBattlePhaseInfo
{
	var float NextPhaseHealthPctThreshold;

	// sweeping melee attack
    var bool bCanUseSweepingClaw;

	// instant ranged attack that jumps between players
	var bool bCanUseTeslaBlast;

	// sweeping ranged beam attack
	var bool bCanUsePlasmaCannon;

	// aoe attack around Matriarch
	var bool bCanUseLightningStorm;

	// shield against explosives
	var bool bCanUseWarningSiren;

	// ranged grapple attack
	var bool bCanUseScorpionWhip;

	/** Damage done by tentacle attack this battle phase */
	var int TentacleDamage;

	/** Base damage done by Melee Helper (this will replace the melee helper's BaseDamage) */
	var float MeleeBaseDamage;
	var float MeleeDamageScale;

	var float GroundSpeedScale;
	var float SprintSpeedScale;

	var bool bCanCloak;

	var bool bUseAltSprintAnim;

	var bool bShouldTaunt;

	var array<IncapSettingsInfo> IncapSettings;

	var BattleDamageInfo DamageFX;
};

var array<MatriarchBattlePhaseInfo> BattlePhases;
var int TentacleDamage;
var class<KFDamageType> TentacleDamageType;
var bool bUseAltSprintAnim;
var bool bShouldTaunt;

//=============================================================================
// @name Dialog
//=============================================================================

/** Restricts how often tickdialog can be called */
var float TickDialogInterval;

//=============================================================================
// @name FX
//=============================================================================

/** Component used by the beam special move to play a hit location sound effect */
var AkComponent BeamHitAC;

var name LightSocketFront;
var name LightSocketBack;

var transient PointLightComponent LightTemplate_Phase1;
var transient PointLightComponent LightTemplate_Phase2;
var transient PointLightComponent LightTemplate_Phase3;
var transient PointLightComponent LightTemplate_Phase4;

var transient PointLightComponent BattlePhaseLightFront;
var transient PointLightComponent BattlePhaseLightBack;

var LinearColor GlowColor_Phase1;
var LinearColor GlowColor_Phase2;
var LinearColor GlowColor_Phase3;
var LinearColor GlowColor_Phase4;

//=============================================================================
// @name Gun tracking
//=============================================================================

/** Skel control for gun arm tracking */
var SkelControlLookAt GunTrackingSkelCtrl;

/** Allows gun tracking on the server if server aim precision is necessary (player-controlled, etc) */
var protected const bool bUseServerSideGunTracking;

/** Turns gun tracking on and off */
var bool bGunTracking;

/** The target to use for tracking */
var repnotify Pawn GunTarget;

var name GunTargetBoneName;

var Pawn BeamTarget;

//=============================================================================
// @name Shield
//=============================================================================

/** Shield Vars */
/** Amount of health shield has remaining */
var repnotify bool					bShieldUp;
var bool							bShieldBroken;
var float                           ShieldHealth;
var float                           ShieldHealthMax;
var const array<float>              ShieldHealthMaxDefaults;
var float							ShieldHealthScale;

var float							ShieldBreakPawnHealthPct;

/** Replicated shield health percentage */
var repnotify   byte            ShieldHealthPctByte;

var float LastShieldHealthPct;

var ParticleSystem InvulnerableShieldFX;
var ParticleSystemComponent InvulnerableShieldPSC;
var name ShieldSocketName;

var KFSkinTypeEffects ShieldImpactEffects;
var KFGameExplosion ShieldShatterExplosionTemplate;

var const color ShieldColorGreen;
var const color ShieldCoreColorGreen;
var const color ShieldColorYellow;
var const color ShieldCoreColorYellow;
var const color ShieldColorOrange;
var const color ShieldCoreColorOrange;
var const color ShieldColorRed;
var const color ShieldCoreColorRed;

//=============================================================================
// @name Cloaking
//=============================================================================

/** Effect played upon cloaking/uncloaking */
var ParticleSystem CloakFX;
var Name CloakFXSocketName;

/** Gameplay-driven Ak objects, instanced at runtime */
var AkComponent CloakedAkComponent;
var AkEvent CloakedLoop;
var AkEvent CloakedLoopEnd;

/** Percent cloaked [0-1.0] */
var float CloakPercent;

/** Cloak speeds */
var float CloakSpeed;
var float DeCloakSpeed;

/** Cloak damage shimmer */
var float CloakShimmerAmount;
var float LastCloakShimmerTime;

//=============================================================================
// @name Minions
//=============================================================================

var float MinionSpawnDuration;

//=============================================================================
// @name Bump
//=============================================================================

/** The damage type to use when sprinting and bumping zeds */
var class<KFDamageType> HeavyBumpDamageType;

//=============================================================================
// @name Code
//=============================================================================

replication
{
    if (bNetDirty)
        bShieldUp, ShieldHealthPctByte, GunTarget, bUseAltSprintAnim, BeamTarget;
}

simulated event ReplicatedEvent(name VarName)
{
    switch (VarName)
    {
    case nameof(ShieldHealthPctByte):
        UpdateShield();
        break;

	case nameOf(bIsCloakingSpottedByTeam):
		UpdateGameplayMICParams();
		break;
		
	case nameof(bShieldUp):
		SetShieldUp(bShieldUp);
		break;

	case nameOf(bIsCloaking):
		ClientCloakingStateUpdated();
		break;

	case nameOf(GunTarget):
		SetGunTracking(GunTarget != none);
		break;

	case nameof(ArmorZoneStatus):
		super.ReplicatedEvent(VarName);
		OnArmorZoneStatusUpdated();
		break;

    default:
        super.ReplicatedEvent(VarName);
    }
}

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	// Give Matriarch his weapon
    AddDefaultInventory();

    // Set weapon state to active
    if (Weapon != none)
    {
    	Weapon.GotoState('Active');
    }

`if(`notdefined(ShippingPC))
	if (KFPC != none)
	{
		KFPC.MyGFxHUD.bossHealthBar.SetVisible(true);
	}
`endif

	// Start the dialog timer
    if( WorldInfo.NetMode != NM_Client )
    {
        SetTimer(2.f, false, nameOf(Timer_TickDialog));
    }
}

/** Cache skel controls */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	if (WorldInfo.NetMode != NM_DedicatedServer || bUseServerSideGunTracking)
	{
		GunTrackingSkelCtrl = SkelControlLookAt(SkelComp.FindSkelControl('GunTracking'));
		GunTrackingSkelCtrl.SetSkelControlActive( false );
	}
}

/** Called from Possessed event when this controller has taken control of a Pawn */
function PossessedBy(Controller C, bool bVehicleTransition)
{
    Super.PossessedBy(C, bVehicleTransition);
    InitializeCurrentBattlePhase();
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float HealthPct;

	super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

	HealthPct = float(Health) / float(HealthMax);
	if (HealthPct <= BattlePhases[CurrentBattlePhase].NextPhaseHealthPctThreshold)
	{
		IncrementBattlePhase();
	}
}

function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	// let the shield absorb unadjusted damage...
	if (bShieldUp && ShieldHealth > 0)
    {
        ShieldHealth -= InDamage;

        if (ShieldHealth < 0)
        {
            InDamage = Abs(ShieldHealth);
            ShieldHealth = 0;
        }
        else
        {
            InDamage = 0;
        }

        ShieldHealthPctByte = FloatToByte(FClamp(ShieldHealth / ShieldHealthMax, 0.f, 1.f));
        UpdateShield();
    }

	// then let the pawn adjust the remaining damage (if any)
	super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);
}

simulated event Tick(float DeltaTime)
{
	local int i;
	local float MinCloakPct;
	local KFCharacterInfo_Monster MonsterInfo;

	super.Tick(DeltaTime);
	UpdateGunTrackingSkelCtrl(DeltaTime);

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MonsterInfo = GetCharacterMonsterInfo();
		if (CharacterMICs[0].Parent != MonsterInfo.SpottedSkins[0])
		{
			MinCloakPct = GetMinCloakPct();

			if (!bIsCloaking)
			{
				if (CloakPercent < 1.0f)
				{
					CloakPercent = fMin(CloakPercent + DeltaTime*DeCloakSpeed, 1.f);

					if (CloakPercent == 1.0f)
					{
						UpdateGameplayMICParams();
					}
					else
					{
						for (i = 0; i < CharacterMICs.Length; ++i)
						{
							CharacterMICs[i].SetScalarParameterValue('Transparency', CloakPercent);
						}
					}
				}
			}
			else if (CloakPercent > MinCloakPct)
			{
				CloakPercent = fMax(CloakPercent - DeltaTime*CloakSpeed, MinCloakPct);
				for (i = 0; i < CharacterMICs.Length; ++i)
				{
					CharacterMICs[i].SetScalarParameterValue('Transparency', CloakPercent);
				}
			}
		}
	}
}

/** Gets the minimum cloaked amount based on the viewer */
simulated protected function float GetMinCloakPct()
{
	return 0.f;
}

//=============================================================================
// @name Shield
//=============================================================================

simulated function SetShieldUp(bool bUp)
{
	if (bShieldBroken)
	{
		return;
	}

	if (Role == ROLE_Authority && ShieldHealth > 0)
	{
		bShieldUp = bUp;

		if (Role == Role_Authority)
		{
			`DialogManager.PlayMatriarchShieldUpEvent(self);
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		if (bShieldUp)
		{
			// this creates a new component instead of reactivating the old one because reactivating
			// doesn't work at the moment or maybe ever?
			ActivateShieldFX();
		}
		else
		{
			InvulnerableShieldPSC.DeactivateSystem();
			InvulnerableShieldPSC = none;
		}
	}
}

function ActivateShield()
{
    local KFGameInfo KFGI;
    local float HealthMod;
    local float HeadHealthMod;

    KFGI = KFGameInfo(WorldInfo.Game);
    if (KFGI != None)
    {
        HealthMod = 1.f;
        KFGI.DifficultyInfo.GetAIHealthModifier(self, KFGI.GetModifiedGameDifficulty(), KFGI.GetLivingPlayerCount(), HealthMod, HeadHealthMod);

        ShieldHealth = ShieldHealthMaxDefaults[KFGI.GetModifiedGameDifficulty()] * HealthMod * ShieldHealthScale;
        
		if (KFGI.OutbreakEvent != none && KFGi.OutbreakEvent.ActiveEvent.bBossRushMode)
		{
			ShieldHealth = ShieldHealth * ArmorInfo.ArmorScale;
		}

		
		ShieldHealthMax = ShieldHealth;
        ShieldHealthPctByte = FloatToByte( fClamp(ShieldHealth / ShieldHealthMax, 0.f, 1.f) );

		UpdateShield();
    }
}

simulated function ActivateShieldFX()
{
	if (InvulnerableShieldPSC == none)
	{
		InvulnerableShieldPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(InvulnerableShieldFX, Mesh, ShieldSocketName, true);
		InvulnerableShieldPSC.SetAbsolute(false, true, true);
	}
}

simulated function UpdateShield()
{
    local float ShieldHealthPct;

	if (bShieldBroken)
	{
		return;
	}

    ShieldHealthPct = ByteToFloat(ShieldHealthPctByte);
	if (ShieldHealthPctByte == 0)
    {
        BreakShield();
    }

	if (WorldInfo.NetMode == NM_DedicatedServer)
	{
		return;
	}

    if (ShieldHealthPct > 0.f && LastShieldHealthPct <= 0.f)
    {
        ActivateShieldFX();
    }

    if (InvulnerableShieldPSC != none)
	{
		if (ShieldHealthPct >= 0.75f) // Green
		{
			if (LastShieldHealthPct < 0.75f)
			{
				InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorGreen));
				InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorGreen));
			}
		}
		else if (ShieldHealthPct >= 0.5f) // Yellow
		{
			if (LastShieldHealthPct >= 0.75f || LastShieldHealthPct < 0.5f)
			{
				InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorYellow));
				InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorYellow));
			}
		}
		else if (ShieldHealthPct >= 0.25f) // Orange
		{
			if (LastShieldHealthPct >= 0.5f || LastShieldHealthPct < 0.25f)
			{
				InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorOrange));
				InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorOrange));
			}
		}
		else if (LastShieldHealthPct >= 0.25f) // Red
		{
			InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorRed));
			InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorRed));
		}
	}

    //// Scale the invulnerable material param
    //TorsoMIC.SetScalarParameterValue('Scalar_DamageResist', ShieldHealthPct);

	// Cache off so we know whether the material params need to change
    LastShieldHealthPct = ShieldHealthPct;
    UpdateShieldUI();
}

/** Creates a vector parameter from a standard color */
simulated function vector MakeVectorFromColor(color InColor)
{
    local LinearColor LinColor;
    local vector ColorVec;

    LinColor = ColorToLinearColor(InColor);
    ColorVec.X = LinColor.R;
    ColorVec.Y = LinColor.G;
    ColorVec.Z = LinColor.B;

    return ColorVec;
}

/** Breaks the shield */
simulated function BreakShield()
{
    local KFExplosionActor ExplosionActor;

	if (bShieldBroken)
	{
		return;
	}

	bShieldBroken = true;
	bShieldUp = false;

	// Spawn a shatter explosion
	// Spawn on server (to actually do damage) and client (to actually produce visuals)
	// (why doesn't the actor replicate its explosion?)
    ExplosionActor = Spawn(class'KFExplosionActor', self, , Location, rotator(vect(0, 0, 1)));
    if (ExplosionActor != None)
    {
        ExplosionActor.Explode(ShieldShatterExplosionTemplate);
    }

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        // Detach shield and zero out material params
        DetachShieldFX();
        //TorsoMIC.SetScalarParameterValue('Scalar_DamageResist', 0.0);
    }

	if (Role == ROLE_Authority)
	{
		SetBattlePhase(BATTLE_PHASE_ARMOR);
	}
}

simulated function DetachShieldFX()
{
    LastShieldHealthPct = 0.f;
    DetachEmitter(InvulnerableShieldPSC);
    UpdateShieldUI();
}

simulated function UpdateShieldUI()
{
    if (KFPC != none && KFPC.IsLocalController())
    {
        if (KFPC.MyGFxHUD != none && KFPC.MyGFxHUD.bossHealthBar != none)
        {
            KFPC.MyGFxHUD.bossHealthBar.UpdateBossShield(LastShieldHealthPct);
        }
    }
}

//=============================================================================
// @name Gun tracking
//=============================================================================

/** Toggles gun tracking on and off */
simulated function SetGunTracking(bool bEnableTracking)
{
	if (WorldInfo.NetMode != NM_DedicatedServer || bUseServerSideGunTracking)
	{
		bGunTracking = bEnableTracking;
		GunTrackingSkelCtrl.SetSkelControlActive( bEnableTracking );
	}

	if (Role == ROLE_Authority)
	{
		if (bEnableTracking && Controller != None && Controller.Enemy != none)
		{
			GunTarget = Controller.Enemy;
		}
		else
		{
			GunTarget = none;
		}
	}

	bForceNetUpdate = true;
}

/** Updates our gun tracking skeletal control */
simulated function UpdateGunTrackingSkelCtrl(float DeltaTime)
{
	// Track the player with the gun arm
	if (GunTrackingSkelCtrl != none)
	{
		if (bGunTracking && GunTarget != None)
		{
			GunTrackingSkelCtrl.DesiredTargetLocation = GunTarget.Mesh.GetBoneLocation(GunTargetBoneName);
			GunTrackingSkelCtrl.InterpolateTargetLocation(DeltaTime);
		}
		else
		{
			GunTrackingSkelCtrl.SetSkelControlActive(false);
		}
	}
}

//=============================================================================
// @name Phases
//=============================================================================

function bool CanUseSweepingClaw()
{
	return BattlePhases[CurrentBattlePhase].bCanUseSweepingClaw &&
		CanDoSpecialMove(SM_Custom1);
}

function bool CanUseTeslaBlast()
{
	return	BattlePhases[CurrentBattlePhase].bCanUseTeslaBlast &&
			CanDoSpecialMove(SM_StandAndShootAttack) &&
			PowerClawIsFunctional();
}

function bool CanUsePlasmaCannon()
{
	return	BattlePhases[CurrentBattlePhase].bCanUsePlasmaCannon &&
			CanDoSpecialMove(SM_HoseWeaponAttack) &&
			PowerClawIsFunctional();
}

function bool CanUseLightningStorm()
{
	return BattlePhases[CurrentBattlePhase].bCanUseLightningStorm &&
		CanDoSpecialMove(SM_Custom2);
}

function bool CanUseWarningSiren()
{
	return BattlePhases[CurrentBattlePhase].bCanUseWarningSiren &&
		CanDoSpecialMove(SM_SonicAttack);
}

function bool CanUseScorpionWhip()
{
	return !PowerClawIsFunctional() &&
		CanDoSpecialMove(SM_GrappleAttack);
}

function SetBattlePhase(int Phase)
{
	if (Phase > CurrentBattlePhase && Phase < BattlePhases.Length)
	{
		CurrentBattlePhase = Phase;

		if (CurrentBattlePhase > BATTLE_PHASE_SHIELD)
		{
			ShieldHealthPctByte = 0;
			UpdateShield();
		}

		if (CurrentBattlePhase > BATTLE_PHASE_ARMOR)
		{
			ArmorInfo.ExplodeArmor(HEAD_ARMOR_IDX);
			ArmorInfo.ExplodeArmor(CLAW_ARMOR_IDX);
			ArmorInfo.UpdateArmorUI();
			
			// Forcing armor to be updated.
			OnArmorZoneStatusUpdated();
		}

		DoStumble();
		SummonMinions();
		InitializeCurrentBattlePhase();
		OnBattlePhaseChanged();
		bForceNetUpdate = true;
	}
}

function IncrementBattlePhase()
{
	SetBattlePhase(CurrentBattlePhase + 1);
}

function InitializeCurrentBattlePhase()
{
	local int i;

	TentacleDamage = BattlePhases[CurrentBattlePhase].TentacleDamage;
	MeleeAttackHelper.BaseDamage = MeleeAttackHelper.default.BaseDamage * BattlePhases[CurrentBattlePhase].MeleeDamageScale;
	InitialGroundSpeedModifier = BattlePhases[CurrentBattlePhase].GroundSpeedScale;
	bCanCloak = BattlePhases[CurrentBattlePhase].bCanCloak;
	bUseAltSprintAnim = BattlePhases[CurrentBattlePhase].bUseAltSprintAnim;
	bShouldTaunt = BattlePhases[CurrentBattlePhase].bShouldTaunt;
	IncapSettings = BattlePhases[CurrentBattlePhase].IncapSettings;

	// re-init existing afflictions to account for new IncapSettings
	for (i = 0; i < EAfflictionType_MAX; ++i)
	{
		if (i < AfflictionHandler.Afflictions.Length && AfflictionHandler.Afflictions[i] != none)
		{
			AfflictionHandler.Afflictions[i].Init(self, EAfflictionType(i), none);
		}
	}

	if (bCanCloak)
	{
		SetCloaked(true);
	}

	`DialogManager.PlayMatriarchBattlePhaseDialog(self, CurrentBattlePhase);

	bNetDirty = true;
}

function SummonMinions()
{
    local KFAIWaveInfo MinionWave;
    local KFGameInfo MyKFGameInfo;
	local KFAIController_ZedBoss MyBossAIController;

	MyKFGameInfo = KFGameInfo(WorldInfo.Game);

    // Force frustration mode on
    MyKFGameInfo.GetAIDirector().bForceFrustration = true;

    // Select the correct batch of zeds to spawn during this battle phase
    MinionWave = GetWaveInfo(CurrentBattlePhase, MyKFGameInfo.GetModifiedGameDifficulty());
    if (MinionWave != none)
    {
		if (MyKFGameInfo.SpawnManager != none)
		{
			MyKFGameInfo.SpawnManager.LeftoverSpawnSquad.Length = 0;
		 	MyKFGameInfo.SpawnManager.SummonBossMinions(MinionWave.Squads, GetNumMinionsToSpawn());
		}
	}

	MyBossAIController = KFAIController_ZedBoss(Controller);
	if (MyBossAIController != none)
	{
		MyBossAIController.SetTimer(MinionSpawnDuration, false, nameof(MyBossAIController.Timer_StopSummoningZeds));
	}
}

/** Sets various material scalars and FX based on the phase of battle */
simulated function OnBattlePhaseChanged()
{
    if (WorldInfo.NetMode == NM_DedicatedServer || Health <= 0)
    {
        return;
    }

    super.OnBattlePhaseChanged();

	UpdateBattlePhaseLights();
	UpdateBattlePhaseMaterials();
	UpdateBattlePhaseParticles();
}

/** Updates dynamic lights based on battle phase */
simulated function UpdateBattlePhaseLights()
{
    local PointLightComponent LightTemplate;

    if (BattlePhaseLightFront != none)
    {
        BattlePhaseLightFront.DetachFromAny();
        BattlePhaseLightFront = none;
    }

    if (BattlePhaseLightBack != none)
    {
        BattlePhaseLightBack.DetachFromAny();
        BattlePhaseLightBack = none;
    }

    switch (CurrentBattlePhase)
    {
    case 0:
        LightTemplate = LightTemplate_Phase1;
        break;

    case 1:
        LightTemplate = LightTemplate_Phase2;
        break;

    case 2:
        LightTemplate = LightTemplate_Phase3;
        break;

    case 3:
		// don't activate lights after death
    	if (IsAliveAndWell())
    	{
        	LightTemplate = LightTemplate_Phase4;
        }
        break;
    };

    if (LightTemplate != none)
    {
	    BattlePhaseLightFront = new(self) Class'PointLightComponent' (LightTemplate);
	    BattlePhaseLightBack = new(self) Class'PointLightComponent' (LightTemplate);
	}

    if (BattlePhaseLightFront != none)
    {
        Mesh.AttachComponentToSocket(BattlePhaseLightFront, LightSocketFront);
        BattlePhaseLightFront.SetEnabled(true);
    }

    if (BattlePhaseLightBack != none)
    {
        Mesh.AttachComponentToSocket(BattlePhaseLightBack, LightSocketBack);
        BattlePhaseLightBack.SetEnabled(true);
    }
}

/** Updates battle damage on material instance based on battle phase */
simulated function UpdateBattlePhaseMaterials()
{
	local MaterialInstanceConstant MIC;

	foreach CharacterMICs(MIC)
	{
		switch (CurrentBattlePhase)
		{
		case 1:
			MIC.SetScalarParameterValue('Scalar_BattleGrime', 0.0);
			MIC.SetScalarParameterValue('Scalar_Damage_Blood_Contrast', 1.0);
			MIC.SetScalarParameterValue('Scalar_GlowFlashing', 0.0);
			MIC.SetVectorParameterValue('Vector_GlowColor', GlowColor_Phase1);
			break;

		case 2:
			MIC.SetScalarParameterValue('Scalar_BattleGrime', 0.25);
			MIC.SetScalarParameterValue('Scalar_Damage_Blood_Contrast', 1.48);
			MIC.SetScalarParameterValue('Scalar_GlowFlashing', 0.0);
			MIC.SetVectorParameterValue('Vector_GlowColor', GlowColor_Phase2);
			break;

		case 3:
			MIC.SetScalarParameterValue('Scalar_BattleGrime', 0.25);
			MIC.SetScalarParameterValue('Scalar_Damage_Blood_Contrast', 1.49);
			MIC.SetScalarParameterValue('Scalar_GlowFlashing', 0.0);
			MIC.SetVectorParameterValue('Vector_GlowColor', GlowColor_Phase3);
			break;

		case 4:
			MIC.SetScalarParameterValue('Scalar_BattleGrime', 0.5);
			MIC.SetScalarParameterValue('Scalar_Damage_Blood_Contrast', 1.6);
			// don't activate blinking after death
			MIC.SetScalarParameterValue('Scalar_GlowFlashing', IsAliveAndWell() ? 1.0 : 0.0);
			MIC.SetVectorParameterValue('Vector_GlowColor', GlowColor_Phase4);
			break;
		};
	}
}

simulated function UpdateBattlePhaseParticles()
{
	local int i, j;
	local ParticleSystem PS;
	local name Socket;
	local ParticleSystemComponent PSC;

	if (CurrentBattlePhase > 0)
	{
		for (i = 0; i < BattlePhases[CurrentBattlePhase-1].DamageFX.FXComponents.Length; ++i)
		{
			BattlePhases[CurrentBattlePhase-1].DamageFX.FXComponents[i].DeactivateSystem();
		}
		BattlePhases[CurrentBattlePhase-1].DamageFX.FXComponents.Length = 0;
	}

	for (i = 0; i < BattlePhases[CurrentBattlePhase].DamageFX.FXInfo.Length; ++i)
	{
		PS = BattlePhases[CurrentBattlePhase].DamageFX.FXInfo[i].Template;
		for (j = 0; j < BattlePhases[CurrentBattlePhase].DamageFX.FXInfo[i].Sockets.Length; ++j)
		{
			Socket = BattlePhases[CurrentBattlePhase].DamageFX.FXInfo[i].Sockets[j];
			PSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(PS, Mesh, Socket, true);
			BattlePhases[CurrentBattlePhase].DamageFX.FXComponents.AddItem(PSC);
		}
	}
}

simulated function DoStumble()
{
	if (IsIncapacitated())
	{
		return;
	}

	if (IsDoingSpecialMove())
	{
		EndSpecialMove();
	}

	DoSpecialMove( SM_Stumble,,, class'KFSM_Stumble'.static.PackBodyHitSMFlags(self, -vector(Rotation)) );
}

//=============================================================================
// Cloaking
//=============================================================================

/** Toggle cloaking material */
function SetCloaked(bool bNewCloaking)
{
	if( bCanCloak && bNewCloaking != bIsCloaking )
	{
		if( bNewCloaking && (IsImpaired() || IsIncapacitated()) )
		{
			return;
		}

		if( MaxHeadChunkGoreWhileAlive == 0 && bIsCloaking != bNewCloaking && IsAliveAndWell() )
		{
			`DialogManager.PlaySpotCloakDialog( self, bNewCloaking );
		}

		bIsCloaking = bNewCloaking;

		// Initial spotted callout should be slightly delayed
		if( bIsCloaking )
		{
			bIsCloakingSpottedByLP = false;
			bIsCloakingSpottedByTeam = false;
			LastSpottedStatusUpdate = WorldInfo.TimeSeconds - 0.2f;
		}

		if( WorldInfo.NetMode != NM_DedicatedServer )
		{
			UpdateGameplayMICParams();
			HideBattleDamageFX(bIsCloaking);
		}

		super.SetCloaked( bNewCloaking );

		if (Role == ROLE_Authority && bIsCloaking)
		{
			`DialogManager.PlayMatriarchCloakedEvent(self);
		}
	}
}

simulated function HideBattleDamageFX(bool bHide)
{
	local int i;

	for (i = 0; i < BattlePhases[CurrentBattlePhase].DamageFX.FXComponents.Length; ++i)
	{
		BattlePhases[CurrentBattlePhase].DamageFX.FXComponents[i].SetHidden(bHide);
	}
}

/**
 * bIsCloaking replicated state changed
 * Network: Local and Remote Clients
 */
simulated function ClientCloakingStateUpdated()
{
	if( bIsCloaking )
	{
		ClearBloodDecals();

		// Initial spotted callout should be slightly delayed
		bIsCloakingSpottedByLP = false;
		bIsCloakingSpottedByTeam = false;
		LastSpottedStatusUpdate = WorldInfo.TimeSeconds - 0.2f;
	}

	UpdateGameplayMICParams();
	HideBattleDamageFX(bIsCloaking);
}

/**
 * Called every 0.5f seconds to check if a cloaked zed has been spotted
 * Network: All but dedicated server
 */
simulated event UpdateSpottedStatus()
{
	local bool bOldSpottedByLP;
	local KFPlayerController LocalPC;
	local KFPerk LocalPerk;
	local float DistanceSq, Range;

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	bOldSpottedByLP = bIsCloakingSpottedByLP;
	bIsCloakingSpottedByLP = false;

	LocalPC = KFPlayerController(GetALocalPlayerController());
	if( LocalPC != none )
	{
		LocalPerk = LocalPC.GetPerk();
	}

	if ( LocalPC != none && LocalPC.Pawn != None && LocalPC.Pawn.IsAliveAndWell() && LocalPerk != none &&
		 LocalPerk.bCanSeeCloakedZeds && `TimeSince( LastRenderTime ) < 1.f )
	{
		DistanceSq = VSizeSq(LocalPC.Pawn.Location - Location);
		Range = LocalPerk.GetCloakDetectionRange();

		if ( DistanceSq < Square(Range) )
		{
			bIsCloakingSpottedByLP = true;
			if ( LocalPerk.IsCallOutActive() )
			{
				// Beware of server spam.  This RPC is marked unreliable and UpdateSpottedStatus has it's own cooldown timer
				LocalPC.ServerCallOutPawnCloaking(self);
			}
		}
	}

	// If spotted by team already, there is no point in trying to update the MIC here
	if ( !bIsCloakingSpottedByTeam )
	{
		if ( bIsCloakingSpottedByLP != bOldSpottedByLP )
		{
			UpdateGameplayMICParams();
		}
	}
}

/** notification from player with CallOut ability */
function CallOutCloaking( optional KFPlayerController CallOutController )
{
	bIsCloakingSpottedByTeam = true;
	UpdateGameplayMICParams();
	SetTimer(2.f, false, nameof(CallOutCloakingExpired));
}

/** Call-out cloaking ability has timed out */
function CallOutCloakingExpired()
{
	bIsCloakingSpottedByTeam = false;
	UpdateGameplayMICParams();
}

/** Handle cloaking materials */
simulated function UpdateGameplayMICParams()
{
	local int i;
	local bool bIsSpotted;
	local bool bWasCloaked;
	local KFCharacterInfo_Monster MonsterInfo;

	// skip KFPawn_MonsterBoss because it calls OnBattlePhaseChanged (?)
	super(KFPawn_Monster).UpdateGameplayMICParams();

	// Cannot cloak after patriarch has been gored
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		MonsterInfo = GetCharacterMonsterInfo();

		// visible by local player or team (must go after ServerCallOutCloaking)
		bIsSpotted = (bIsCloakingSpottedByLP || bIsCloakingSpottedByTeam);
		if ((!bIsCloaking || IsImpaired()) && CharacterMICs[0].Parent != MonsterInfo.Skins[0])
		{
			for (i = 0; i < MonsterInfo.Skins.Length; ++i)
			{
				bWasCloaked = bWasCloaked ||
							  (CharacterMICs[i].Parent == MonsterInfo.CloakedSkins[i]) ||
							  (CharacterMICs[i].Parent == MonsterInfo.SpottedSkins[i]);
				CharacterMICs[i].SetParent(MonsterInfo.Skins[i]);
			}

			Mesh.CastShadow = true;
			Mesh.SetPerObjectShadows(true);

			// Needed to avoid effects occurring on gore mesh swap
	   		if (bWasCloaked)
	   		{
				//SetDamageFXActive( true );
				PlayStealthSoundLoopEnd();
				DoCloakFX();
			}

            //Update PAC meshes
            for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; ++i)
            {
                if (ThirdPersonAttachments[i] != none)
                {
                    ThirdPersonAttachments[i].SetHidden(false);
                }
            }
		}
		else if (bIsCloaking && bIsSpotted && CharacterMICs[0].Parent != MonsterInfo.SpottedSkins[0])
		{
			for (i = 0; i < MonsterInfo.SpottedSkins.Length; ++i)
			{
				CharacterMICs[i].SetParent(MonsterInfo.SpottedSkins[i]);
			}

			CloakPercent = 1.0f;

			Mesh.CastShadow = false;
			Mesh.SetPerObjectShadows(false);
			//SetDamageFXActive( false );

            //Update PAC meshes
            for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; ++i)
            {
                if (ThirdPersonAttachments[i] != none)
                {
                    ThirdPersonAttachments[i].SetHidden(true);
                }
            }
		}
		else if (bIsCloaking && !bIsSpotted && CharacterMICs[0].Parent != MonsterInfo.CloakedSkins[0])
		{
			for (i = 0; i < MonsterInfo.CloakedSkins.Length; ++i)
			{
				CharacterMICs[i].SetParent(MonsterInfo.CloakedSkins[i]);
			}

			PlayStealthSoundLoop();
			DoCloakFX();
			Mesh.CastShadow = false;
			Mesh.SetPerObjectShadows(false);
			//SetDamageFXActive( false );

            //Update PAC meshes
            for (i = 0; i < `MAX_COSMETIC_ATTACHMENTS; ++i)
            {
                if (ThirdPersonAttachments[i] != none)
                {
                    ThirdPersonAttachments[i].SetHidden(true);
                }
            }
		}
	}
}

simulated function DoCloakFX()
{
	local ParticleSystemComponent CloakPSC;

    CloakPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment( CloakFX, Mesh, CloakFXSocketName, true );
    CloakPSC.SetAbsolute( false, true, false );
}

simulated function PlayStealthSoundLoop()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && !CloakedAkComponent.IsPlaying(CloakedLoop) )
	{
		CloakedAkComponent.PlayEvent( CloakedLoop, true, true );
	}
}

simulated function PlayStealthSoundLoopEnd()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && CloakedAkComponent.IsPlaying(CloakedLoop) )
	{
		CloakedAkComponent.PlayEvent( CloakedLoopEnd, true, true );
	}
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	// Uncloak on death
	SetCloaked(false);
	bCanCloak = false;

	Super.PlayDying(DamageType, HitLoc);
}

/*********************************************************************************************
* Dialog / Audio
**********************************************************************************************/
/** Returns (hardcoded) dialog event ID for when players kills this zed type */
function int GetKillerDialogID()
{
	return 67;//KILL_Boss
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	if( bIsCloaking && MaxHeadChunkGoreWhileAlive == 0 )
    {
        return 135;//SPOTZ_Cloaked
    }

	return 125;//SPOTZ_Generic
}

/** Players dialog such as taunts at regular intervals */
function Timer_TickDialog()
{
    if (!IsAliveAndWell())
    {
        return;
    }

    if (!IsDoingSpecialMove())
    {
        `DialogManager.PlayMatriarchTickDialog(self, ArmorZoneStatus, CurrentBattlePhase);
    }

    SetTimer(TickDialogInterval, false, nameOf(Timer_TickDialog));
}

function PlayPlasmaCannonDialog()
{
	`DialogManager.PlayMatriarchPlasmaCannonEvent(self);
}

function PlaySweepingClawDialog()
{
	`DialogManager.PlayMatriarchSweepingClawEvent(self);
}

function PlayTeslaBlastDialog()
{
	`DialogManager.PlayMatriarchTeslaBlastEvent(self);
}

function PlayLightningStormDialog()
{
	`DialogManager.PlayMatriarchLightningStormEvent(self);
}

function PlayScorpionWhipDialog()
{
	`DialogManager.PlayMatriarchScorpionWhipEvent(self);
}

function PlayWarningSirenDialog()
{
	`DialogManager.PlayMatriarchWarningSirenEvent(self);
}

/*********************************************************************************************
* @name Armor
**********************************************************************************************/

function ZedExplodeArmor(int ArmorZoneIdx, name ArmorZoneName)
{
	super.ZedExplodeArmor(ArmorZoneIdx, ArmorZoneName);
	OnArmorZoneStatusUpdated();
	`DialogManager.PlayMatriarchExplodeArmorDialog(self, ArmorZoneName);

	if (Role == ROLE_Authority)
	{
		if (ArmorZoneStatus == 0)
		{
			SetBattlePhase(BATTLE_PHASE_FLESH);
		}
		else
		{
			DoStumble();
		}
	}
}

function bool PowerClawIsFunctional()
{
	return bool(ArmorZoneStatus & (1 << CLAW_ARMOR_IDX));
}

simulated function OnArmorZoneStatusUpdated()
{
	local int Idx;

	if ((ArmorZoneStatus & (1 << HEAD_ARMOR_IDX)) == 0)
	{
		Idx = HitZones.Find('BoneName', 'dome');
		if (Idx != INDEX_NONE)
		{
			HitZones.Remove(Idx, 1);
		}
	}

	if ((ArmorZoneStatus & (1 << CLAW_ARMOR_IDX)) == 0)
	{
		Idx = HitZones.Find('BoneName', 'LeftHandCap');
		if (Idx != INDEX_NONE)
		{
			HitZones.Remove(Idx, 1);
		}
	}

	DialogAkComponent.SetRTPCValue("Matriarch_Helmet", int(bool(ArmorZoneStatus & (1 << HEAD_ARMOR_IDX))));
}

/*********************************************************************************************
* @name Gore
**********************************************************************************************/

simulated function ApplyHeadChunkGore(class<KFDamageType> DmgType, vector HitLocation, vector HitDirection)
{
    return;
}

/*********************************************************************************************
* @name KFSkinTypeEffects
**********************************************************************************************/

function int GetHitZoneIndex(name BoneName)
{
	if (BoneName == 'KBArmor')
	{
		//Known arbitrary, hacking some things in place
		return OverrideArmorFXIndex;
	}

	return super.GetHitZoneIndex(BoneName);
}

/** Gets skin effects associated with hit zone (allows pawns to override) */
simulated function KFSkinTypeEffects GetHitZoneSkinTypeEffects( int HitZoneIdx )
{
    if (bShieldUp)
    {
        return ShieldImpactEffects; // InvulnerabilityShield
    }
	else if (bIsCloaking)
	{
		return CharacterArch.ImpactSkins[4]; // 4 = Patriarch_Cloaked
	}
	else if (HitZoneIdx == OverrideArmorFXIndex)
	{
		return CharacterArch.ImpactSkins[5];
	}
    else
    {
        return super.GetHitZoneSkinTypeEffects( HitZoneIdx );
    }
}

/*********************************************************************************************
* @name Movement
**********************************************************************************************/

function AdjustMovementSpeed( float SpeedAdjust )
{
    DesiredAdjustedGroundSpeed = default.GroundSpeed * SpeedAdjust * BattlePhases[CurrentBattlePhase].GroundSpeedScale;

	DesiredAdjustedSprintSpeed = default.SprintSpeed * SpeedAdjust * BattlePhases[CurrentBattlePhase].SprintSpeedScale;
	DesiredAdjustedSprintSpeed *= (IsDoingSpecialMove() ? SpecialMoves[SpecialMove].GetSprintSpeedModifier() : 1.f);
	DesiredAdjustedSprintSpeed = fMax(DesiredAdjustedSprintSpeed, DesiredAdjustedGroundSpeed);

	if (bPlayPanicked)
	{
		// Make sure groundspeed is in "walk" range so animtree can play correct panic anim
		DesiredAdjustedGroundSpeed = Min(DesiredAdjustedGroundSpeed, MovementAnimNode.Constraints[1]);
	}

    NormalGroundSpeed = DesiredAdjustedGroundSpeed;
	NormalSprintSpeed = DesiredAdjustedSprintSpeed;
}

//=============================================================================
// @name Bump
//=============================================================================

function class<KFDamageType> GetBumpAttackDamageType()
{
	return HeavyBumpDamageType;
}

/** Play music for this boss (overridden for each boss) */
function PlayBossMusic()
{
	if( KFGameInfo(WorldInfo.Game) != none )
	{
		KFGameInfo(WorldInfo.Game).ForceMatriarchMusicTrack();
	}
}

defaultproperties
{
	// Stats
	XPValues(0)=1291
	XPValues(1)=1694
	XPValues(2)=1790
	XPValues(3)=1843

	// ---------------------------------------------
	//Movement / Physics
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0055.000000
	End Object

	RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)

	GroundSpeed=300.f
	SprintSpeed=650.f

	KnockdownImpulseScale=1.0f


    // ---------------------------------------------
    // Content
    LocalizationKey=KFPawn_ZedMatriarch
    MonsterArchPath = "ZED_ARCH.ZED_Matriarch_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Matriarch_ANIM.Matriarch_AnimGroup'

    Begin Object Name=KFPawnSkeletalMeshComponent
        // Enabling kinematic for physics interaction while alive.  (see also MinDistFactorForKinematicUpdate)
        bUpdateKinematicBonesFromAnimation = true

		// Enabling skel controls when not rendered (for guntracking on server)
		bIgnoreControllersWhenNotRendered=false

		// Beam weapons (microwave gun, flamey things, etc.) won't hit her hand armor without this
		BlockNonZeroExtent=true
    End Object

	DefaultInventory(0) = class'KFWeap_PowerClaw_Matriarch'

	// ---------------------------------------------
	//Gameplay
	Health=7000
	Mass=200.f
	DoshValue=500
	ParryResistance=4

	TentacleDamageType=class'KFDT_Slashing_MatriarchTentacle'
	DifficultySettings=class'KFDifficulty_Matriarch'

	Begin Object Name=MeleeHelper_0
		BaseDamage=55.f
		MaxHitRange=375.f
		MomentumTransfer=40000.f
		MyDamageType=class'KFDT_Bludgeon_Matriarch'
	End Object

    PenetrationResistance=4.0

	TickDialogInterval=0.5

	CloakPercent=1.0f
	DeCloakSpeed=4.5f
	CloakSpeed=3.f
	CloakShimmerAmount=0.6f

	bEnableAimOffset=true

    // ---------------------------------------------
    // Special Moves
    Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Custom1)=class'KFSM_Matriarch_SweepingClaw'
		SpecialMoveClasses(SM_StandAndShootAttack)=class'KFSM_Matriarch_TeslaBlast'
		SpecialMoveClasses(SM_HoseWeaponAttack)=class'KFSM_Matriarch_PlasmaCannon'
		SpecialMoveClasses(SM_Custom2)=class'KFSM_Matriarch_LightningStorm'
        SpecialMoveClasses(SM_GrappleAttack)=class'KFSM_Matriarch_ScorpionWhip'
		SpecialMoveClasses(SM_SonicAttack)=class'KFSM_Matriarch_WarningSiren'
		SpecialMoveClasses(SM_Taunt)=class'KFSM_Matriarch_Taunt'
    End Object

    // ---------------------------------------------
    // AI / Nav
    ControllerClass = class'KFGameContent.KFAIController_ZedMatriarch'
    BumpDamageType=class'KFDT_NPCBump_Large'
	DamageRecoveryTimeHeavy=0.65f
	DamageRecoveryTimeMedium=0.85f

	// ---------------------------------------------
	// Battle Phases

	BattlePhases(0)={(
		NextPhaseHealthPctThreshold=0.75f,
		bCanUseSweepingClaw=true, //Deprecated, Sweeping Claw is not a special move anymore.
		bCanUseTeslaBlast=true,
		bCanUsePlasmaCannon=true,
		bCanUseLightningStorm=true,
		bCanUseWarningSiren=false,
		MeleeDamageScale=1.f,
		GroundSpeedScale=1.f,
		SprintSpeedScale=1.f,
		bCanCloak=false,
		bUseAltSprintAnim=false,
		IncapSettings={(
			// for reference: Vulnerability=(default, head, legs, arms, special)
			/*AF_EMP*/		(Vulnerability=(1.0),                       Cooldown=10.0, Duration=2.5),
			/*AF_FirePanic*/(Vulnerability=(0.0),                       Cooldown=15.0, Duration=1.2),
			/*AF_MeleeHit*/	(Vulnerability=(0.0),                       Cooldown=2.0),
			/*AF_GunHit*/	(Vulnerability=(0.0),                       Cooldown=2.0),
			/*AF_Stumble*/	(Vulnerability=(0.0),                       Cooldown=10.0),
			/*AF_Stun*/		(Vulnerability=(0.0),                       Cooldown=17.0, Duration=1.25),
			/*AF_Poison*/	(Vulnerability=(0.0),						Cooldown=15.0, Duration=1.2),
			/*AF_Snare*/	(Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0),	Cooldown=10.5, Duration=3.0),
			/*AF_Knockdown*/(Vulnerability=(0.0),						Cooldown=20.0),
			/*AF_Freeze*/	(Vulnerability=(0.0),						Cooldown=10.0, Duration=1.0),
			/*AF_Microwave*/(Vulnerability=(0.08),						Cooldown=10.0, Duration=3.0),
			/*AF_Bleed*/	(Vulnerability=(0.15),						Cooldown=10.0),
		)}
	)}
	BattlePhases(1)={(
		NextPhaseHealthPctThreshold=0.5f,
		bCanUseSweepingClaw=true, //Deprecated, Sweeping Claw is not a special move anymore.
		bCanUseTeslaBlast=true,
		bCanUsePlasmaCannon=true,
		bCanUseLightningStorm=true,
		bCanUseWarningSiren=false,
		MeleeDamageScale=1.f,
		GroundSpeedScale=1.5f,
		SprintSpeedScale=1.f,
		bCanCloak=false,
		bUseAltSprintAnim=false,
		bShouldTaunt=true,
		IncapSettings={(
			// for reference: Vulnerability=(default, head, legs, arms, special)
			/*AF_EMP*/		(Vulnerability=(1.0),                       Cooldown=10.0, Duration=2.5),
			/*AF_FirePanic*/(Vulnerability=(0.0),                       Cooldown=15.0, Duration=1.2),
			/*AF_MeleeHit*/	(Vulnerability=(0.1, 0.95, 0.1, 0.1, 0.75), Cooldown=2.0),
			/*AF_GunHit*/	(Vulnerability=(0.1, 0.1, 0.1, 0.1, 0.5),   Cooldown=2.0),
			/*AF_Stumble*/	(Vulnerability=(0.1, 0.3, 0.1, 0.1, 0.4),   Cooldown=10.0),
			/*AF_Stun*/		(Vulnerability=(0.0),                       Cooldown=17.0, Duration=1.25),
			/*AF_Poison*/	(Vulnerability=(0.0),						Cooldown=15.0, Duration=1.2),
			/*AF_Snare*/	(Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0),   Cooldown=10.5, Duration=3.0),
			/*AF_Knockdown*/(Vulnerability=(0.0),                       Cooldown=20.0),
			/*AF_Freeze*/	(Vulnerability=(0.65),                      Cooldown=10.0, Duration=1.0),
			/*AF_Microwave*/(Vulnerability=(0.08),                      Cooldown=10.0, Duration=3.0),
			/*AF_Bleed*/	(Vulnerability=(0.15),                      Cooldown=10.0),
		)},
		DamageFX={(
			FXInfo={(
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Low_Damage_01',
					Sockets=(FX_LeftKnee,Hand_FX_Start_R,FX_RightHip)
				)},
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Medium_Damage_01',
					Sockets=(FX_LeftKnee)
				)},
			)}
		)}
	)}
	BattlePhases(2)={(
		NextPhaseHealthPctThreshold=0.25f,
		bCanUseSweepingClaw=true, //Deprecated, Sweeping Claw is not a special move anymore.
		bCanUseTeslaBlast=false,
		bCanUsePlasmaCannon=false,
		bCanUseLightningStorm=true,
		bCanUseWarningSiren=true,
		MeleeDamageScale=1.f,
		GroundSpeedScale=2.25f,
		SprintSpeedScale=1.05f,
		bCanCloak=false,
		bUseAltSprintAnim=true,
		bShouldTaunt=true,
		IncapSettings={(
			// for reference: Vulnerability=(default, head, legs, arms, special)
			/*AF_EMP*/		(Vulnerability=(1.0),                       Cooldown=10.0, Duration=2.5),
			/*AF_FirePanic*/(Vulnerability=(0.65),                      Cooldown=15.0, Duration=1.2),
			/*AF_MeleeHit*/	(Vulnerability=(0.1, 0.95, 0.1, 0.1, 0.75), Cooldown=2.0),
			/*AF_GunHit*/	(Vulnerability=(0.1, 0.1, 0.1, 0.1, 0.5),   Cooldown=2.0),
			/*AF_Stumble*/	(Vulnerability=(0.1, 0.3, 0.1, 0.1, 0.4),   Cooldown=10.0),
			/*AF_Stun*/		(Vulnerability=(0.1, 0.55, 0.1, 0.1, 0.55), Cooldown=17.0, Duration=1.25),
			/*AF_Poison*/	(Vulnerability=(0.0),						Cooldown=15.0, Duration=1.2),
			/*AF_Snare*/	(Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0),   Cooldown=10.5, Duration=3.0),
			/*AF_Knockdown*/(Vulnerability=(0.1, 0.4, 0.1, 0.1, 0.25),  Cooldown=20.0),
			/*AF_Freeze*/	(Vulnerability=(0.65),                      Cooldown=10.0, Duration=1.0),
			/*AF_Microwave*/(Vulnerability=(0.08),                      Cooldown=10.0, Duration=3.0),
			/*AF_Bleed*/	(Vulnerability=(0.15),                      Cooldown=10.0),
		)},
		DamageFX={(
			FXInfo={(
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Low_Damage_01',
					Sockets=(Hand_FX_Start_R,FX_RightHip)
				)},
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Medium_Damage_01',
					Sockets=(FX_LeftKnee)
				)},
				{(
					Template=ParticleSystem'ZED_Patriarch_EMIT.FX_Patriarch_tentacle_LowD_01',
					Sockets=(FX_Armor_Chest)
				)},
				{(
					Template=ParticleSystem'ZED_Patriarch_EMIT.FX_Patriarch_tentacle_MidD_01',
					Sockets=(FX_LeftForearm)
				)},
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Damage_Shoulder_02',
					Sockets=(Head_Attach)
				)}
			)}
		)}
	)}
	BattlePhases(3)={(
		NextPhaseHealthPctThreshold=0, // Set to 0, she doesn't have a phase after this one.
		bCanUseSweepingClaw=true, //Deprecated, Sweeping Claw is not a special move anymore.
		bCanUseTeslaBlast=false,
		bCanUsePlasmaCannon=false,
		bCanUseLightningStorm=false,
		bCanUseWarningSiren=true,
		MeleeDamageScale=1.2f,
		GroundSpeedScale=2.5f,
		SprintSpeedScale=1.15f,
		bCanCloak=true,
		bUseAltSprintAnim=true,
		bShouldTaunt=true,
		IncapSettings={(
			// for reference: Vulnerability=(default, head, legs, arms, special)
			/*AF_EMP*/		(Vulnerability=(1.0),                       Cooldown=10.0, Duration=2.5),
			/*AF_FirePanic*/(Vulnerability=(0.65),                      Cooldown=15.0, Duration=1.2),
			/*AF_MeleeHit*/	(Vulnerability=(0.1, 0.95, 0.1, 0.1, 0.75), Cooldown=2.0),
			/*AF_GunHit*/	(Vulnerability=(0.1, 0.1, 0.1, 0.1, 0.5),   Cooldown=2.0),
			/*AF_Stumble*/	(Vulnerability=(0.1, 0.3, 0.1, 0.1, 0.4),   Cooldown=10.0),
			/*AF_Stun*/		(Vulnerability=(0.1, 0.55, 0.1, 0.1, 0.55), Cooldown=17.0, Duration=1.25),
			/*AF_Poison*/	(Vulnerability=(0.0),						Cooldown=15.0, Duration=1.2),
			/*AF_Snare*/	(Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0),   Cooldown=10.5, Duration=3.0),
			/*AF_Knockdown*/(Vulnerability=(0.1, 0.4, 0.1, 0.1, 0.25),  Cooldown=20.0),
			/*AF_Freeze*/	(Vulnerability=(0.65),                      Cooldown=10.0, Duration=1.0),
			/*AF_Microwave*/(Vulnerability=(0.08),                      Cooldown=10.0, Duration=3.0),
			/*AF_Bleed*/	(Vulnerability=(0.15),                      Cooldown=10.0),
		)},
		DamageFX={(
			FXInfo={(
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_High_Damage_01',
					Sockets=(FX_LeftKnee,Hand_FX_Start_R,FX_RightHip)
				)},
				{(
					Template=ParticleSystem'ZED_Patriarch_EMIT.FX_Patriarch_tentacle_HighD_01',
					Sockets=(FX_Armor_Chest)
				)},
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Low_Damage_01',
					Sockets=(FX_Armor_Chest)
				)},
				{(
					Template=ParticleSystem'ZED_Patriarch_EMIT.FX_Patriarch_tentacle_HighD_01',
					Sockets=(FX_LeftForearm)
				)},
				{(
					Template=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Damage_Shoulder_01',
					Sockets=(Head_Attach)
				)}
			)}
		)}
	)}

	// Summon squads by difficulty @TODO: Switch to Matriarch
	SummonWaves(0)={(
		PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Normal_One',
		PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Normal_Two',
		PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Normal_Three'
	)}
	SummonWaves(1)={(
		PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Hard_One',
		PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Hard_Two',
		PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Hard_Three'
	)}
	SummonWaves(2)={(
		PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Suicidal_One',
		PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Suicidal_Two',
		PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_Suicidal_Three'
	)}
	SummonWaves(3)={(
		PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_HOE_One',
		PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_HOE_Two',
		PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Matriarch.Mat_Minions_HOE_Three'
	)}
	NumMinionsToSpawn=(X=3, Y=5)
	MinionSpawnDuration=30.f

	// ---------------------------------------------
    // Shield

	bShieldUp=true

    // invulnerable effects
    Begin Object Class=KFSkinTypeEffects_InvulnerabilityShield Name=ShieldEffects
		ImpactFXArray[0]={(
			Type=FXG_Ballistic,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[1]={(
			Type=FXG_Bludgeon,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[2]={(
			Type=FXG_Piercing,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[3]={(
			Type=FXG_Slashing,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[4]={(
			Type=FXG_Fire,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[5]={(
			Type=FXG_Toxic,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[6]={(
			Type=FXG_Healing,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[7]={(
			Type=FXG_Sawblade,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[8]={(
			Type=FXG_DrainLife,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[9]={(
			Type=FXG_IncendiaryRound,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[10]={(
			Type=FXG_UnexplodedGrenade,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[11]={(
			Type=FXG_MicrowaveBlast,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[12]={(
			Type=FXG_ShieldBash,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[13]={(
			Type=FXG_MetalMace,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[14]={(
			Type=FXG_Flare,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[15]={(
			Type=FXG_Freeze,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[16]={(
			Type=FXG_Bludgeon_Chains,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[17]={(
			Type=FXG_MicrowaveProj,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[18]={(
			Type=FXG_Electricity,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[19]={(
			Type=FXG_Slashing_Ion,
			DefaultParticle=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
    End Object

    // Shield FX
    ShieldImpactEffects=ShieldEffects
    InvulnerableShieldFX=ParticleSystem'ZED_Matriarch_EMIT.FX_Matriarch_Shield'
    ShieldSocketName=Root

    // Shield colors
    ShieldColorGreen=(R=50,G=255,B=50)
    ShieldCoreColorGreen=(R=0,G=255,B=0)
    ShieldColorYellow=(R=255,G=255,B=20)
    ShieldCoreColorYellow=(R=255,G=255,B=0)
    ShieldColorOrange=(R=255,G=110,B=10)
    ShieldCoreColorOrange=(R=255,G=105,B=0)
    ShieldColorRed=(R=255,G=20,B=20)
    ShieldCoreColorRed=(R=255,G=10,B=10)

	// Glow colors
	GlowColor_Phase1=(R=0.1, G=1.0)
    GlowColor_Phase2=(R=1.0, G=0.5)
    GlowColor_Phase3=(R=1.0, G=0.1)
    GlowColor_Phase4=(R=2.0)

	// ---------------------------------------------
    // damage phase lights and effects
    Begin Object Class=PointLightComponent Name=PointLightComponent0
        Brightness=1.f
        Radius=128.f
        LightColor=(R=168,G=222,B=173,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    LightTemplate_Phase1=PointLightComponent0

    Begin Object Class=PointLightComponent Name=PointLightComponent1
        Brightness=1.f
        Radius=128.f
        LightColor=(R=231,G=215,B=161,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    LightTemplate_Phase2=PointLightComponent1

    Begin Object Class=PointLightComponent Name=PointLightComponent2
        Brightness=1.f
        Radius=128.f
        LightColor=(R=231,G=144,B=0,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    LightTemplate_Phase3=PointLightComponent2

    Begin Object Class=PointLightComponent Name=PointLightComponent3
        Brightness=2.f
        Radius=128.f
        LightColor=(R=255,G=64,B=64,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)

        // light anim
        AnimationType=1 // LightAnim_Flicker
        AnimationFrequency=5.f
        MinBrightness=1.f
        MaxBrightness=2.f
    End Object
    LightTemplate_Phase4=PointLightComponent3

	LightSocketFront=FX_Armor_Chest
	LightSocketBack=FX_Armor_Back

    // Shield shatter explosion template
    Begin Object Class=KFGameExplosion Name=ShatterExploTemplate0
        Damage=0
        DamageRadius=500
        DamageFalloffExponent=1.f
        DamageDelay=0.f

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=500.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'ZED_Matriarch_ARCH.Matriarch_Shield_Explosion_Arch'
        ExplosionSound=AkEvent'WW_ZED_Matriarch.Play_Matriarch_SFX_Shield_Break'

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=450
        CamShakeOuterRadius=900
        CamShakeFalloff=0.5f
        bOrientCameraShakeTowardsEpicenter=true
        bUseOverlapCheck=false
    End Object
    ShieldShatterExplosionTemplate=ShatterExploTemplate0

    ShieldHealthMaxDefaults[0]=2000
    ShieldHealthMaxDefaults[1]=3000
    ShieldHealthMaxDefaults[2]=4500
    ShieldHealthMaxDefaults[3]=5600
	ShieldHealthScale=1.f

	ShieldBreakPawnHealthPct=0.75f

	// ---------------------------------------------
	// Hit Zones

	HitZones.Empty

	// Dome needs to be first to count as the "head" (HZI_HEAD)
	// We'll remove the dome entry when the head armor breaks so that her real head gets to be the head, too.
	HitZones.Add((ZoneName=dome, 		  BoneName=dome,	 	    Limb=BP_Head, 		GoreHealth=MaxInt,	DmgScale=1.0,	SkinID=2))
	HitZones.Add((ZoneName=head, 		  BoneName=head, 			Limb=BP_Head, 		GoreHealth=MaxInt,	DmgScale=1.3,	SkinID=1))

	HitZones.Add((ZoneName=chest, 		  BoneName=Spine,		    Limb=BP_Torso,		GoreHealth=150,	    DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=abdomen, 	  BoneName=hips,	 		Limb=BP_Torso,		GoreHealth=MaxInt,	DmgScale=0.5,	SkinID=0))
	HitZones.Add((ZoneName=stomach, 	  BoneName=SpineDisc,	 	Limb=BP_Torso,		GoreHealth=MaxInt,	DmgScale=0.25,	SkinID=2))

	HitZones.Add((ZoneName=lupperarm,	  BoneName=LeftShoulder,	Limb=BP_LeftArm,	GoreHealth=50,	    DmgScale=0.5,	SkinID=0))
	HitZones.Add((ZoneName=lupperauldron, BoneName=LeftPauldron,	Limb=BP_LeftArm,	GoreHealth=MaxInt,	DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=lforearm, 	  BoneName=LeftForearm,	    Limb=BP_LeftArm,	GoreHealth=20,	    DmgScale=1.0,	SkinID=0))
	HitZones.Add((ZoneName=lhandcap, 	  BoneName=LeftHandCap,	    Limb=BP_LeftArm,	GoreHealth=MaxInt,	DmgScale=1.0,	SkinID=2))
	HitZones.Add((ZoneName=lhand, 		  BoneName=LeftHandMain,    Limb=BP_LeftArm,	GoreHealth=MaxInt,	DmgScale=1.3,	SkinID=3))

	HitZones.Add((ZoneName=rupperarm,	  BoneName=RightShoulder,	Limb=BP_RightArm,	GoreHealth=50,	    DmgScale=0.5,	SkinID=0))
	HitZones.Add((ZoneName=rupperpauldron,BoneName=RightPauldron,	Limb=BP_RightArm,	GoreHealth=MaxInt,	DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=rupperhose,	  BoneName=RightArmHose1,	Limb=BP_RightArm,	GoreHealth=MaxInt,	DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=rforearm, 	  BoneName=RightForearm, 	Limb=BP_RightArm,	GoreHealth=20,	    DmgScale=0.25,	SkinID=2))

	HitZones.Add((ZoneName=lthigh,		  BoneName=LeftUpLeg,		Limb=BP_LeftLeg,	GoreHealth=100,	    DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=lcalf,	      BoneName=LeftLeg,		    Limb=BP_LeftLeg,	GoreHealth=50,	    DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=lfoot,	      BoneName=LeftFoot,		Limb=BP_LeftLeg,	GoreHealth=MaxInt,	DmgScale=0.25,	SkinID=2))

	HitZones.Add((ZoneName=rthigh,		  BoneName=RightUpLeg,	    Limb=BP_RightLeg,	GoreHealth=100,	    DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=rcalf,		  BoneName=RightLeg,		Limb=BP_RightLeg,	GoreHealth=50,	    DmgScale=0.25,	SkinID=2))
	HitZones.Add((ZoneName=rfoot,	      BoneName=RightFoot,		Limb=BP_RightLeg,	GoreHealth=MaxInt,	DmgScale=0.25,	SkinID=2))

	HitZones.Add((ZoneName=heart, 		  BoneName=Tentacle1,		Limb=BP_Special,	GoreHealth=MaxInt,	DmgScale=1.3,	SkinID=3))
	HitZones.Add((ZoneName=teslacoil, 	  BoneName=EMP_Main,		Limb=BP_Special,	GoreHealth=MaxInt,	DmgScale=1.0,	SkinID=2))

	WeakSpotSocketNames.Empty()
	WeakSpotSocketNames.Add(FX_Dazed) // head weak spot
	WeakSpotSocketNames.Add(Hand_FX_End_L) // Left arm weakspot

	// ---------------------------------------------
	// Damage Type Modifiers

	// Resistant damage types
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.4)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing',	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.9)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.4)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.05)))

    //special case
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MicrowaveRifle',   DamageScale=(0.7)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_HRGHealthrower',       DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.7)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Minigun',          DamageScale=(0.75)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_MineReconstructorExplosion',       	DamageScale=(0.6)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_Beam',       				DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGeneratorSphereImpact',       		DamageScale=(2)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_DefaultFiremodeZapDamage', 	DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_AltFiremodeZapDamage',		DamageScale=(1.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGScorcherLightingImpact', 	    DamageScale=(0.4)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGScorcherDoT',		                DamageScale=(0.4)))

	//DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallImpact',		DamageScale=(0.3)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact',	DamageScale=(0.3)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing_HRG_Vampire_CrystalSpike',			DamageScale=(0.25)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_HRG_Vampire_BloodSuck',				DamageScale=(0.5)))

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallImpact',		DamageScale=(0.4)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact',	DamageScale=(0.4)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing_HRG_Vampire_CrystalSpike',			DamageScale=(0.3)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_HRG_Vampire_BloodSuck',				DamageScale=(0.7)))

	// ---------------------------------------------
    // Armor

	ArmorZoneStatus=3 // 0b00000011
    PreviousArmorZoneStatus=3

	ArmorInfoClass=class'KFZedArmorInfo_Matriarch'
	RepArmorPct[0]=255
	RepArmorPct[1]=255
	OverrideArmorFXIndex=200

	// ---------------------------------------------
    // Cloaking

	bCanCloak=true
	bCloakOnMeleeEnd=true

	CloakedLoop=AkEvent'WW_ZED_Matriarch.Play_Matriarch_SFX_Cloak'
	CloakedLoopEnd=AkEvent'WW_ZED_Matriarch.Stop_Matriarch_SFX_Cloak'
	Begin Object Class=AkComponent name=CloakedAkComponent0
		BoneName=dummy
		bStopWhenOwnerDestroyed=true
		bForceOcclusionUpdateInterval=true
		OcclusionUpdateInterval=0.2f
	End Object
    CloakedAkComponent=CloakedAkComponent0
    Components.Add( CloakedAkComponent0 )

	Begin Object Class=AkComponent name=BeamHitAC0
        bStopWhenOwnerDestroyed=true
    End Object
    Components.Add(BeamHitAC0)
    BeamHitAC=BeamHitAC0

	// ---------------------------------------------
    // Achievements
	OnDeathAchievementID=KFACHID_DefeatMatriarch

	// ---------------------------------------------
    // Bump
	HeavyBumpDamageType=class'KFGameContent.KFDT_HeavyZedBump'

	// ---------------------------------------------
	// Gun tracking
	bUseServerSideGunTracking=true
	GunTargetBoneName=Spine2

	ZEDCowboyHatAttachName=Hat_Attach
}