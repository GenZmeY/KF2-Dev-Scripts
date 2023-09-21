//=============================================================================
// KFPawn_ZedHansClot
//=============================================================================
// KF Pawn for Hans Clot
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//
//=============================================================================

class KFPawn_ZedHansClot extends KFPawn_ZedClot;

/** Returns (hardcoded) trader advice dialog ID */
static function int GetTraderAdviceID()
{
	return 36;//TRAD_AdviceClotU
}

defaultproperties
{
	LocalizationKey=KFPawn_ZedHansClot
	// ---------------------------------------------
	// Stats
	XPValues(0)=8
	XPValues(1)=11
	XPValues(2)=11
	XPValues(3)=11

	Begin Object Name=KFPawnSkeletalMeshComponent
		bPerBoneMotionBlur=false
	End Object

	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_HansClot_Archetype" 
	PawnAnimInfo=KFPawnAnimInfo'ZED_Clot_Anim.UndevClot_AnimGroup'
	DifficultySettings=class'KFDifficulty_ClotCyst'

	// ---------------------------------------------
	// Gameplay
	GrabAttackFrequency=0.8f
	KnockedDownBySonicWaveOdds=0.35f

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		  (Vulnerability=(2.0, 2.0, 1.0, 1.0, 1.0), Cooldown=3.0, Duration=3.0)
	IncapSettings(AF_Knockdown)=  (Vulnerability=(1.f),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	  (Vulnerability=(1.3f),                    Cooldown=0.2)
	IncapSettings(AF_GunHit)=	  (Vulnerability=(2.f),                     Cooldown=0.2)
	IncapSettings(AF_MeleeHit)=	  (Vulnerability=(2.0),                     Cooldown=0.0)
	IncapSettings(AF_Poison)=	  (Vulnerability=(5), 	                    Cooldown=6.0,  Duration=4.5)
	IncapSettings(AF_Microwave)=  (Vulnerability=(0.5), 	                Cooldown=8.0,  Duration=4.5)
	IncapSettings(AF_FirePanic)=  (Vulnerability=(1.5), 	                Cooldown=7.0,  Duration=5)
	IncapSettings(AF_EMP)=		  (Vulnerability=(2.5),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Freeze)=	  (Vulnerability=(2.5),                     Cooldown=1.5,  Duration=5.0)
	IncapSettings(AF_Snare)=	  (Vulnerability=(10.0, 10.0, 10.0, 10.0),  Cooldown=5.5,  Duration=4.0)
    IncapSettings(AF_Bleed)=      (Vulnerability=(2.0))
    IncapSettings(AF_Shrink)=     (Vulnerability=(1.0))

	ShrinkEffectModifier = 2.0f

    ParryResistance=0	

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.5)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.5)))  //2.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.01)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))  //0.76
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.85))) //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9)))  // 0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.0)))   //0.8
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.25)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(1.0)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(1.0))) //0.9


	// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Knife',              DamageScale=(1.0))

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedClot_Cyst'
	PeripheralVision=-0.5f //180
	DamageRecoveryTimeHeavy=0.85f
	DamageRecoveryTimeMedium=1.0f
	
	RotationRate=(Pitch=50000,Yaw=20000,Roll=50000)
	
	KnockdownImpulseScale=1.0f

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Underdeveloped';
`endif
}


