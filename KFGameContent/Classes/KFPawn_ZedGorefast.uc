//=============================================================================
// KFPawn_ZedGorefast
//=============================================================================
// Gorefast
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedGorefast extends KFPawn_Monster;

/** Returns (hardcoded) dialog event ID for when trader gives advice to player who was killed by this zed type */
static function int GetTraderAdviceID()
{
	return 38;//TRAD_AdviceGorefast
}

DefaultProperties
{
	LocalizationKey=KFPawn_ZedGorefast
	// ---------------------------------------------
	// Stats
	XPValues(0)=11
	XPValues(1)=14
	XPValues(2)=14
	XPValues(3)=14

	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_Gorefast_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Gorefast_Anim.Gorefast_AnimGroup'
	DifficultySettings=class'KFDifficulty_Gorefast'

	//DebugRange_Melee_Material=Material'ENG_EditorResources_MAT.Debug_Radius_M'
	RotationRate=(Pitch=50000,Yaw=45000,Roll=50000)

	// ---------------------------------------------
	// Gameplay

	Begin Object Name=MeleeHelper_0
		BaseDamage=10.f
		MaxHitRange=192.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_Gorefast'
	End Object

	Health=200.f
	DoshValue=12
	Mass=65.f

	// Penetration
    PenetrationResistance=1.5

	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=50, DmgScale=1.1, SkinID=1)
	HitZones.Add((ZoneName=rblade, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20, DmgScale=0.1, SkinID=2))

	// ---------------------------------------------
	// Movement Physics
	GroundSpeed=240.f
	SprintSpeed=450.f
	MaxFallSpeed=6000.f
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0048.000000 // Mesh is pulled back by 20 UU
	End Object

	// ---------------------------------------------
	// AI / Navigation
	ElitePawnClass.Add(class'KFPawn_ZedGorefastDualBlade')
	ControllerClass=class'KFAIController_ZedGorefast'
	ReachedEnemyThresholdScale=1.f
	//ReachedGoalThresholdOverride=0
	DamageRecoveryTimeHeavy=0.85f
	DamageRecoveryTimeMedium=1.0f

	KnockdownImpulseScale=1.0f

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Taunt)=class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
		SpecialMoveClasses(SM_Block)=class'KFSM_Block'

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
	
	ShrinkEffectModifier = 0.6f

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

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Gorefast';
`endif

    // ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Medium

	// Only used in Volter Castle for now when the spawn volume has bForceUseMapReplacePawn set to true
	// If we need to reuse it more we'll have to connect map to zed here
	MapReplacePawnClass.Add(class'KFPawn_ZedHansClot')
}
