//=============================================================================
// KFPawn_ZedBloatKingSubspawn
//=============================================================================
// It's a poop.  Monster.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedBloatKingSubspawn extends KFPawn_Monster;

var KFGameExplosion DeathExplosionTemplate;
var bool bPlayedExplosion;
var bool bDelayedExplosion;

simulated event bool CanDoSpecialMove(ESpecialMove AMove, optional bool bForceCheck)
{
	if (AMove == SM_Custom1)
	{
		return !IsDoingSpecialMove(SM_Custom1);
	}

	return super.CanDoSpecialmove(AMove, bForceCheck);
}

function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if (!bPlayedExplosion)
	{
		Explode();
	}

	return super.Died(Killer, DamageType, HitLocation);
}

simulated event Tick(float DeltaTime)
{
	super.Tick(DeltaTime);

	if (bDelayedExplosion && !bPlayedExplosion)
	{
		Explode();
	}
}

function DelayExplode()
{
	bDelayedExplosion = true;
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local KFExplosionActor ExploActor;

	super.PlayDying(DamageType, HitLoc);

	if (!bPlayedExplosion)
	{
		bPlayedExplosion = true;

		//Visual explosion + lingering dot damage
		ExploActor = Spawn(class'KFExplosion_BloatKingSubspawn', self, , Location, rotator(vect(0, 0, 1)));
		if (ExploActor != none)
		{
			ExploActor.InstigatorController = Controller;
			ExploActor.Instigator = self;
			ExploActor.Explode(DeathExplosionTemplate);
		}

		//Hide mesh behind the FX
		Mesh.SetHidden(true);
	}
}

simulated function Explode()
{
	if (Role == ROLE_Authority && IsAliveAndWell())
	{
		KilledBy(self);
	}
}

function CauseHeadTrauma(float BleedOutTime = 5.f)
{
	if (IsAliveAndWell())
	{
		return;
	}

	super.CauseHeadTrauma(BleedOutTime);
}

simulated function PlayHeadAsplode()
{
	if (IsAliveAndWell())
	{
		return;
	}

	super.PlayHeadAsplode();
}

simulated function ApplyHeadChunkGore(class<KFDamageType> DmgType, vector HitLocation, vector HitDirection)
{
	if (IsAliveAndWell())
	{
		return;
	}

	super.ApplyHeadChunkGore(DmgType, HitLocation, HitDirection);
}

defaultproperties
{
	LocalizationKey=KFPawn_ZedBloatKingSubspawn

	// Used for special crawler gas AOE attack "explosion" template
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=15 //50  //12 //16
        DamageRadius=350 //600 //450 //400 //425
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_BloatKingSubspawnExplosion'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0
        ExplosionEffects=KFImpactEffectInfo'CHR_Bile_ARCH.FX_Bile_Explosion_01'
        ExplosionSound=AkEvent'WW_ZED_Abomination.Play_Bile_Explode'
        MomentumTransferScale=100

        // Dynamic Light
        ExploLight=none

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=250 //450
        CamShakeOuterRadius=525 //900
        CamShakeFalloff=1.f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    DeathExplosionTemplate=ExploTemplate0

	// Third person body component
	Begin Object Name=KFPawnSkeletalMeshComponent
		Translation=(Z=-40)
		bPerBoneMotionBlur=false
	End Object

	Begin Object Name=CollisionCylinder
		CollisionHeight=40.0
		CollisionRadius=+47.0
	End Object

	// ---------------------------------------------
	// Stats
	XPValues(0)=8
	XPValues(1)=10
	XPValues(2)=10
	XPValues(3)=10

	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_KingBloatSubspawn_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Crawler_ANIM.Crawler_AnimGroup'
	DifficultySettings=class'KFDifficulty_BloatKingSubspawn'


//'CHR_Bile_ANIM.Bile_AnimGroup'
//'ZED_Crawler_ANIM.Crawler_AnimGroup'
	// ---------------------------------------------
	// Gameplay
	Begin Object Name=MeleeHelper_0
		BaseDamage=10.f //7
		MaxHitRange=190.f //180
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	Health=250 //55 //450 //700 //900 //810
	DoshValue=10
	Mass=50.f
	bKnockdownWhenJumpedOn=true

	// Penetration
    PenetrationResistance=0.1

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.0))) //2.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.0)))  //0.75 //0.8
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))   //0.45
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.9))) //0.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.2)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive',   	            DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 		                DamageScale=(0.0))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_BloatKingFart',        DamageScale=(0.00))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_BloatPukeMine',        DamageScale=(0.00)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_BloatKingPukeMine',    DamageScale=(0.00)))




	// ---------------------------------------------
	// Movement / Physics
	ReachedGoalThresh_Walking=0.f
	RotationRate=(Pitch=90000,Yaw=45000,Roll=90000)
	GroundSpeed=450.f
	SprintSpeed=550.f //500
	MaxFallSpeed=6000
	JumpZ=750
	bUseQuadrupedFloorConform=true

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedBloatKingSubspawn'
	bDisableTurnInPlace=true
	bBlocksNavigation=true
	DamageRecoveryTimeHeavy=0.75f
	DamageRecoveryTimeMedium=1.0f

	KnockdownImpulseScale=1.0f

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Custom1)=class'KFSM_BloatKingSubspawn_Explode'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(2.0),                     Cooldown=5.0,  Duration=2.5)
	IncapSettings(AF_Knockdown)=(Vulnerability=(3.f),                     Cooldown=0.0)   // 2 cool1
	IncapSettings(AF_Stumble)=	(Vulnerability=(2.f),                     Cooldown=0.2)
	IncapSettings(AF_GunHit)=	(Vulnerability=(2.5),                     Cooldown=0.2)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(2.0),                     Cooldown=0.0)
	IncapSettings(AF_Poison)=	(Vulnerability=(0.0),                     Cooldown=7.5,  Duration=5.5)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=7.5,  Duration=3.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(3),                       Cooldown=7.0,  Duration=5)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(2.5),                     Cooldown=1.5,  Duration=4.5)
	IncapSettings(AF_Snare)=	(Vulnerability=(10.0),  Cooldown=5.5,  Duration=4.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(2.0))

	ParryResistance=1

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Crawler'; //@TODO: Replace me
`endif

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Crawler
}