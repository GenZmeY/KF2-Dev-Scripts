//=============================================================================
// KFPawn_ZedScrake
//=============================================================================
// Scrake
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedScrake extends KFPawn_Monster;

var protected AkComponent 	ChainsawIdleAkComponent;
var protected AkEvent		PlayChainsawIdleAkEvent;
var protected AkEvent		StopChainsawIdleAkEvent;

// Chainsaw Particle Fx
var name ExhaustSocketName;
var ParticleSystem ExhaustTemplate;
var ParticleSystemComponent ExhaustPSC;

/** Threshold of health below which the Scrake will start rage charging on normal */
var(RageCharge) float       RageHealthThresholdNormal;
/** Threshold of health below which the Scrake will start rage charging on hard */
var(RageCharge) float       RageHealthThresholdHard;
/** Threshold of health below which the Scrake will start rage charging on suicidal */
var(RageCharge) float       RageHealthThresholdSuicidal;
/** Threshold of health below which the Scrake will start rage charging on hell on earth */
var(RageCharge) float       RageHealthThresholdHellOnEarth;
/** Threshold of health below which the Scrake will start rage charging (determined by difficulty) */
var(RageCharge) float       RageHealthThreshold;

// handle chainsaw idle here instead of through an anim-notify so that we can actually turn it off
simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		ChainsawIdleAkComponent.PlayEvent( PlayChainsawIdleAkEvent, true, true );
		CreateExhaustFx();
	}
}

/** Overridden to support loading the alternate body mic */
simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
	super.SetCharacterArch( Info );

    // Set our secondary material, attach our healing syringes
	if( WorldInfo.NetMode != NM_DedicatedServer && Mesh != None )
	{
		CharacterMICs[1] = Mesh.CreateAndSetMaterialInstanceConstant( 2 );
	}
}

function PossessedBy( Controller C, bool bVehicleTransition )
{
	local KFAIController_Monster KFAICM;

	super.PossessedBy( C, bVehicleTransition );

	if( !IsHumanControlled() )
	{
		KFAICM = KFAIController_Monster( C );

		if( KFAICM != none )
		{
	        // Determine what rage health threshold to use
	        if( KFAICM.Skill == class'KFGameDifficultyInfo'.static.GetDifficultyValue(0) ) // Normal
	        {
	            RageHealthThreshold = RageHealthThresholdNormal;
	        }
	        else if( KFAICM.Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(1) ) // Hard
	        {
	            RageHealthThreshold = RageHealthThresholdHard;
	        }
	        else if( KFAICM.Skill <= class'KFGameDifficultyInfo'.static.GetDifficultyValue(2) ) // Suicidal
	        {
	            RageHealthThreshold = RageHealthThresholdSuicidal;
	        }
	        else // Hell on Earth
	        {
	            RageHealthThreshold = RageHealthThresholdHellOnEarth;
	        }
	    }
	}
	else
	{
		if( WorldInfo.Game.GetModifiedGameDifficulty() == 0 )
		{
            RageHealthThreshold = RageHealthThresholdNormal;
		}
		else if( WorldInfo.Game.GetModifiedGameDifficulty() == 1 )
		{
            RageHealthThreshold = RageHealthThresholdHard;
		}
		else if( WorldInfo.Game.GetModifiedGameDifficulty() == 2 )
		{
            RageHealthThreshold = RageHealthThresholdSuicidal;
		}
		else
		{
            RageHealthThreshold = RageHealthThresholdHellOnEarth;
		}
	}
}

simulated function CreateExhaustFx()
{
	local vector Loc;
	local rotator Rot;

	if ( ExhaustPSC == none && ExhaustTemplate != None )
	{
		if ( Mesh.GetSocketWorldLocationAndRotation(ExhaustSocketName, Loc, Rot) )
		{
			ExhaustPSC = new(self) class'ParticleSystemComponent';
			ExhaustPSC.SetTemplate( ExhaustTemplate );

			Mesh.AttachComponentToSocket(ExhaustPSC, ExhaustSocketName);
		}
	}
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );

	if( bCanRage && !bPlayedDeath && (GetHealthPercentage() < RageHealthThreshold || GetHeadHealthPercent() < RageHealthThreshold) )
	{
		SetEnraged( true );
	}
}

/** Enrage this Scrake! */
//simulated function SetEnraged( bool bNewEnraged );

/** Return current rage status */
simulated event bool IsEnraged()
{
	return bIsEnraged;
}

/** Returns TRUE if this zed can block attacks */
function bool CanBlock()
{
	return !bIsEnraged && super.CanBlock();
}

/** Called on server when pawn should have been crippled (e.g. Headless) */
function CauseHeadTrauma( float BleedOutTime=5.f )
{
	super.CauseHeadTrauma( BleedOutTime );

	// End rage when decapped
	SetEnraged( false );
}

/** Overridden to support secondary body material */
simulated event NotifyGoreMeshActive()
{
	super.NotifyGoreMeshActive();

    // Set our secondary MIC
	if( WorldInfo.NetMode != NM_DedicatedServer && Mesh != None )
	{
		CharacterMICs[1] = Mesh.CreateAndSetMaterialInstanceConstant( 2 );
	}
}

simulated function TerminateEffectsOnDeath()
{
	CleanupChainsaw();
	super.TerminateEffectsOnDeath();
}

simulated function CleanupChainsaw()
{
	local MaterialInstanceConstant ChainsawBladeMIC;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		ChainsawBladeMIC = Mesh.CreateAndSetMaterialInstanceConstant(1);
		ChainsawBladeMIC.SetScalarParameterValue('Animation_Scalar', 0.f);

		ChainsawIdleAkComponent.PlayEvent( StopChainsawIdleAkEvent );

		// Murder chainsaw Fx
		if( ExhaustPSC != none )
		{
			ExhaustPSC.DeactivateSystem();
			DetachComponent(ExhaustPSC);
			WorldInfo.MyEmitterPool.OnParticleSystemFinished(ExhaustPSC);
			ExhaustPSC = None;
		}
	}
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	return 129;//SPOTZ_Scrake
}

/** Returns (hardcoded) dialog event ID for when trader gives advice to player who was killed by this zed type */
static function int GetTraderAdviceID()
{
	return 42;//TRAD_AdviceScrake
}

/*********************************************************************************************
* Movement
********************************************************************************************* */

function SetSprinting( bool bNewSprintStatus )
{
	if( bEmpDisrupted && bNewSprintStatus && (MyKFAIC == none || !MyKFAIC.bHasDebugCommand) )
	{
		return;
	}

	super.SetSprinting( bNewSprintStatus );
}

/*********************************************************************************************
* Notifications
********************************************************************************************* */

/** Interrupt certain moves when bEmpDisrupted is set */
function OnStackingAfflictionChanged(byte Id)
{
	Super.OnStackingAfflictionChanged(Id);

	if( bEMPDisrupted && bIsSprinting && MyKFAIC != none && IsAliveAndWell() )
	{
		SetSprinting( false );
	}
}

defaultproperties
{
	LocalizationKey=KFPawn_ZedScrake
	bLargeZed=true

	Begin Object Name=KFPawnSkeletalMeshComponent
		// Enabling kinematic for physics interaction while alive.  (see also MinDistFactorForKinematicUpdate)
		bUpdateKinematicBonesFromAnimation=true
	End Object

	// ---------------------------------------------
	// Stats
	XPValues(0)=34
	XPValues(1)=45
	XPValues(2)=60
	XPValues(3)=69

	// ---------------------------------------------
	// Content
    MonsterArchPath="ZED_ARCH.ZED_Scrake_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Scrake_ANIM.Scrake_AnimGroup'
	DifficultySettings=class'KFDifficulty_Scrake'

	ExhaustTemplate=ParticleSystem'ZED_Scrake_EMIT.FX_Scrake_Smoke_Idle_01'
	ExhaustSocketName=FX_Exhaust

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Taunt)=class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Block)=class'KFSM_Block'
	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
    IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 1.0, 0.5, 0.5, 0.5), Cooldown=5.0, Duration=1.55) //cooldown 10
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.4, 0.4, 0.5, 0.4),      Cooldown=10)  //leg0.4
    IncapSettings(AF_Stumble)=	(Vulnerability=(0.3),                     Cooldown=3.5) //2.5
    IncapSettings(AF_GunHit)=	(Vulnerability=(0.2),                     Cooldown=1.7)
    IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                     Cooldown=1.35)
	IncapSettings(AF_Poison)=	(Vulnerability=(0.15),	                  Cooldown=20.5, Duration=5.0)
    IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=10.0, Duration=2.5)
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.4),                     Cooldown=7.0,  Duration=3.5)
    IncapSettings(AF_EMP)=		(Vulnerability=(0.98),                    Cooldown=10.0, Duration=2.2)
    IncapSettings(AF_Freeze)=	(Vulnerability=(0.98),                    Cooldown=6.0,  Duration=1.0)
    IncapSettings(AF_Snare)=	(Vulnerability=(1.0, 2.0, 1.0, 1.0),      Cooldown=5.5,  Duration=3.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.75)) //0.5

	Begin Object Name=Afflictions_0
        FireFullyCharredDuration=5
		AfflictionClasses(AF_EMP)=class'KFAffliction_EMPDisrupt'
    End Object

    ParryResistance=4

	// ---------------------------------------------
	// Gameplay
	bCanGrabAttack=false
	ZedBumpDamageScale=0.1f

	Begin Object Name=MeleeHelper_0
		BaseDamage=30.f
		MaxHitRange=200.f
		MomentumTransfer=45000.f
		MyDamageType=class'KFGameContent.KFDT_Slashing_Scrake'
	End Object

	Health=1100
	DoshValue=75
	Mass=130.f

	// Penetration
    PenetrationResistance=4.0

    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.0))) //0.5
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.0))) //0.7
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.9)))  //0.8
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.80))) //0.8
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.0))) //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(1.0))) //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.3)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 				    DamageScale=(1.1)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 				    DamageScale=(0.4)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_RPG7Impact', 	    DamageScale=(4.f)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.25)))

    //special cases
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Hemogoblin',       DamageScale=(0.75)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.6)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGTeslauncherDoT',     DamageScale=(0.6)))

	// ---------------------------------------------
	// Block Settings
	MinBlockFOV=0.1f

	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
	HeadlessBleedOutTime=6.f
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=600, DmgScale=1.1, SkinID=1)
	HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20,  DmgScale=0.2, SkinID=2)
	HitZones.Add((ZoneName=rchainsaw, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20, DmgScale=0.2, SkinID=2))
	HitZones.Add((ZoneName=rchainsawblade, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20, DmgScale=0.2, SkinID=2))

	// ---------------------------------------------
	// Movement / Physics
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0055.000000
	End Object

	RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)

	GroundSpeed=170.f
	SprintSpeed=600.f
	ReachedEnemyThresholdScale=1.f
	PhysRagdollImpulseScale=1.f
	KnockdownImpulseScale=2.0f

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedScrake'
	BumpDamageType=class'KFDT_NPCBump_Large'
	DamageRecoveryTimeHeavy=0.85     //0.2f
	DamageRecoveryTimeMedium=0.75   //0.09f   //0.85

	bCanRage=true
	bIsEnraged=false
	RageHealthThresholdNormal=0.5
    RageHealthThresholdHard=0.75
    RageHealthThresholdSuicidal=0.75
    RageHealthThresholdHellOnEarth=0.90

	// Sound
	Begin Object Class=AkComponent name=ChainsawAkComponent0
		BoneName=dummy
		bStopWhenOwnerDestroyed=true
		bForceOcclusionUpdateInterval=true
		OcclusionUpdateInterval=0.2f
	End Object
    ChainsawIdleAkComponent=ChainsawAkComponent0
    Components.Add(ChainsawAkComponent0)

    PlayChainsawIdleAkEvent=AkEvent'WW_ZED_Scrake_2.ZED_Scrake_SFX_Chainsaw_Idle_LP'
    StopChainsawIdleAkEvent=AkEvent'WW_ZED_Scrake_2.ZED_Scrake_SFX_Chainsaw_Idle_LP_Stop'

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Scrake';
`endif

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Large

    OnDeathAchievementID=KFACHID_HackAndSlash
}
