//=============================================================================
// KFPawn_ZedClot_Slasher
//=============================================================================
// Slasher clot
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedClot_Slasher extends KFPawn_ZedClot;

/** Returns (hardcoded) trader advice dialog ID */
static function int GetTraderAdviceID()
{
	return 37;//TRAD_AdviceClotS
}

DefaultProperties
{
	LocalizationKey=KFPawn_ZedClot_Slasher
	// ---------------------------------------------
	// Stats
	XPValues(0)=8
	XPValues(1)=11
	XPValues(2)=11
	XPValues(3)=11

	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_Clot_Slasher_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Clot_Anim.SlasherClot_AnimGroup'
	DifficultySettings=class'KFDifficulty_ClotSlasher'

	// ---------------------------------------------
	// Gameplay
	GrabAttackFrequency=0.38f

	// ---------------------------------------------
	// Movement Physics
	GroundSpeed=300.f
	SprintSpeed=500.f
	
	RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedClot_Slasher'
	//bPreferDarkness=true
	DamageRecoveryTimeHeavy=0.65f
	DamageRecoveryTimeMedium=1.0f
	
	KnockdownImpulseScale=1.0f

	// ---------------------------------------------
	// Within KFPawn
	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(2.0, 2.0, 1.0, 2.0, 1.0), Cooldown=3.0, Duration=3.0)
	IncapSettings(AF_Knockdown)=(Vulnerability=(1.f),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(1.3f),                    Cooldown=0.3)
	IncapSettings(AF_GunHit)=	(Vulnerability=(2.f),                     Cooldown=0.2)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(2.0),                     Cooldown=0.0)
	IncapSettings(AF_Poison)=	(Vulnerability=(1.0),                     Cooldown=5.0, Duration=4.5)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=5.0, Duration=2.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(0.7),                     Cooldown=7.0, Duration=5)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0, Duration=5.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(2.5),                     Cooldown=1.5, Duration=4.0)
	IncapSettings(AF_Snare)=	(Vulnerability=(10.0, 10.0, 10.0, 10.0),  Cooldown=5.5, Duration=4.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(2.0))
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))

	ShrinkEffectModifier =2.0f //3.0f // Triple shrinking speed

	ParryResistance=0

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.5))) //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.0)))   //0.78  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.01)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))   //0.3 45
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.85))) //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9)))  //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.25)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(1.0)))

	// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Knife',              DamageScale=(1.0))
	
`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Slasher';
`endif

	ZEDCowboyHatAttachName=Hat_Attach
}
