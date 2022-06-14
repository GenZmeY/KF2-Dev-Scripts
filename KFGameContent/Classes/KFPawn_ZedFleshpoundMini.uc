//=============================================================================
// KFPawn_ZedFleshpoundMini
//=============================================================================
// Mini variant of the flesh pound.  Smaller and less health.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Dan Weiss
//=============================================================================

class KFPawn_ZedFleshpoundMini extends KFPawn_ZedFleshpound;

defaultproperties
{
    LocalizationKey=KFPawn_ZedFleshpoundMini
    MonsterArchPath="ZED_ARCH.ZED_FleshpoundMini_Archetype"
    DifficultySettings=class'KFDifficulty_FleshpoundMini'
	ZedBumpDamageScale = 0.25f
    Health=750
    Mass=100

	RageBumpDamageType = class'KFGameContent.KFDT_MediumZedBump'

    GroundSpeed=450.f //260
	SprintSpeed=650.f     //600 //700

	DoshValue=75 //200 //25 //50

    // Stats
    XPValues(0)=17
    XPValues(1)=22
    XPValues(2)=30
    XPValues(3)=34

    Begin Object Name=MeleeHelper_0
        BaseDamage=49.f
        MaxHitRange=250.f
        MomentumTransfer=55000.f
        MyDamageType=class'KFDT_Bludgeon_Fleshpound'
    End Object


	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.62)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.62)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.75)))  //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.62))) //0.3
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.62))) //0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.37)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(1.0)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.75)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.31)))
    //DamageTypeModifiers.Add((DamageType=class'KFDamageType', 	DamageScale=(0.5))) // All others

    //special case
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MicrowaveRifle',   DamageScale=(0.8)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGTeslauncherDoT',     DamageScale=(0.5)))

        // for reference: Vulnerability=(default, head, legs, arms, special)
    IncapSettings(AF_Stun)=     (Vulnerability=(0.5, 0.55, 0.5, 0.0, 0.55),   Cooldown=10.0, Duration=1.55) //1.2
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.25, 0.25, 0.5, 0.25, 0.4),  Cooldown=10.0)  //leg 0.25
    IncapSettings(AF_Stumble)=  (Vulnerability=(0.37, 0.46, 0.46, 0.15, 0.75),  Cooldown=3.5)
    IncapSettings(AF_GunHit)=   (Vulnerability=(0.0, 0.0, 0.0, 0.0, 0.5),     Cooldown=1.7)
    IncapSettings(AF_MeleeHit)= (Vulnerability=(1.0),                         Cooldown=1.2)
    IncapSettings(AF_Poison)=   (Vulnerability=(0.15),                        Cooldown=20.5, Duration=5.0)
    IncapSettings(AF_Microwave)=(Vulnerability=(0.55),                         Cooldown=17.0, Duration=2.5)
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.45),                         Cooldown=10.0, Duration=3.5)
    IncapSettings(AF_EMP)=      (Vulnerability=(0.95),                        Cooldown=10.0, Duration=2.2)
    IncapSettings(AF_Freeze)=   (Vulnerability=(0.95),                        Cooldown=10.5,  Duration=1.0)
    IncapSettings(AF_Snare)=    (Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0),     Cooldown=8.5,  Duration=5.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.75))
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))
    
	ShrinkEffectModifier = 0.2f

	ZEDCowboyHatAttachName=HEAD_Attach
}