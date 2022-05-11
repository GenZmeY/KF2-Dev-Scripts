//=============================================================================
// KFPawn_ZedGorefastDualBlade
//=============================================================================
// Dual-bladed version of the Gorefast
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedGorefastDualBlade extends KFPawn_ZedGorefast;

defaultproperties
{
	LocalizationKey=KFPawn_ZedGorefastDualBlade
	MonsterArchPath="ZED_ARCH.ZED_Gorefast2_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Gorefast2_ANIM.Gorefast2_AnimGroup'
	ControllerClass=class'KFAIController_ZedGorefastDualBlade'
	DifficultySettings=class'KFDifficulty_GorefastDualBlade'

	// Stats
	XPValues(0)=11
	XPValues(1)=14
	XPValues(2)=14
	XPValues(3)=14

	// ---------------------------------------------
	// Gameplay

	Begin Object Name=MeleeHelper_0
		BaseDamage=10.f
		MaxHitRange=210.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_Gorefast'
	End Object

	Health=400.f
	DoshValue=12
	Mass=100.0 //65.0

	// Penetration
    PenetrationResistance=1.5

	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=150, DmgScale=1.1, SkinID=1)
	//HitZones.Add((ZoneName=rblade, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20, DmgScale=0.1, SkinID=2))
	HitZones[5]		  =(ZoneName=lforearm, BoneName=LeftForearm,  Limb=BP_LeftArm,  GoreHealth=20,  DmgScale=0.2, SkinID=2)
	HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20,  DmgScale=0.2, SkinID=2)

	// ---------------------------------------------
	// Movement Physics
	GroundSpeed=240.f
	SprintSpeed=535.f
	MaxFallSpeed=6000.f
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0048.000000 // Mesh is pulled back by 20 UU
	End Object

	// ---------------------------------------------
	// AI / Navigation

	DamageRecoveryTimeHeavy=0.85f
	DamageRecoveryTimeMedium=1.0f

	KnockdownImpulseScale=1.0f



	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(2.0, 2.0, 1.0, 1.0, 1.0), Cooldown=5.0, Duration=2.5)
	IncapSettings(AF_Knockdown)=(Vulnerability=(1.f),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(1.f),                     Cooldown=0.5)
	IncapSettings(AF_GunHit)=	(Vulnerability=(1.75),                    Cooldown=0.0)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(2.0),                     Cooldown=0.3)
	IncapSettings(AF_Poison)=	(Vulnerability=(10.0),                    Cooldown=10,   Duration=3.5)
	IncapSettings(AF_Microwave)=(Vulnerability=(2.0),                     Cooldown=6.0,  Duration=3.5)
	IncapSettings(AF_FirePanic)=(Vulnerability=(0.75),                    Cooldown=6.0,  Duration=3.5)  //0.2
	IncapSettings(AF_EMP)=		(Vulnerability=(2.0),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Freeze)=   (Vulnerability=(2.0),                     Cooldown=1.5,  Duration=4.0)
	IncapSettings(AF_Snare)=	(Vulnerability=(10.0, 10.0, 10.0, 10.0),  Cooldown=5.5,  Duration=4.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(2.0))
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))
	
	ShrinkEffectModifier = 0.4f

	ParryResistance=2

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.0))) //0.5  0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.2)))  //1  //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.6)))   //1.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.0))) 
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.25)))   //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.8)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.85))) //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.85)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.75)))

	//Special Case damage resistance
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm',              DamageScale=(1.0))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858',          DamageScale=(1.0))

	// ---------------------------------------------
	// Block Settings
	MinBlockFOV=0.1f



}