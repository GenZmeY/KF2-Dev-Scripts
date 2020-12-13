//=============================================================================
// KFPawn_ZedGorefast_Versus
//=============================================================================
// Gorefast Versus pawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedGorefast_Versus extends KFPawn_ZedGorefast;

DefaultProperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)= class'KFSM_PlayerGorefast_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)= class'KFSM_PlayerGorefast_Melee2'
		SpecialMoveClasses(SM_PlayerZedMove_V)= class'KFSM_PlayerGorefast_Melee3'
		SpecialMoveClasses(SM_PlayerZedMove_MMB)= class'KFSM_PlayerGorefast_Block'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Melee_Triangle)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Block_R1)=SM_PlayerZedMove_MMB
	MoveListGamepadScheme(ZGM_Special_R3)=SM_PlayerZedMove_V

	Begin Object Name=MeleeHelper_0
		BaseDamage=14//25.f //20 //12
		MaxHitRange=192.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_Gorefast'
		MeleeImpactCamScale=0.2
		PlayerDoorDamageMultiplier=5.f
	End Object

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=0.26f,	SpecialMoveIcon=Texture2D'ZED_Gorefast_UI.ZED-VS_Icons_Gorefast-Melee', NameLocalizationKey="Light")  //0.35
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=0.52f,	SpecialMoveIcon=Texture2D'ZED_Gorefast_UI.ZED-VS_Icons_Gorefast-HeavyMelee', NameLocalizationKey="Heavy")  //0.7
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=0.0f,	bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=1.27f,	SpecialMoveIcon=Texture2D'ZED_Gorefast_UI.ZED-VS_Icons_Gorefast-BladeSwing', NameLocalizationKey="Spin") //1.7
	SpecialMoveCooldowns(4)=(SMHandle=SM_PlayerZedMove_MMB,		CooldownTime=0.2f,	SpecialMoveIcon=Texture2D'ZED_Shared_UI.ZED-VS_Icons_Generic-Block', NameLocalizationKey="Block")  //0.5
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.f,	SpecialMoveIcon=Texture2D'ZED_Gorefast_UI.ZED-VS_Icons_Gorefast-Jump', bShowOnHud=false)) // Jump always at end of array

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.8)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.7)))  //1.0 //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.6)))  //0.9  0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.55)))  //1.01
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.7)))  //0.76
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.85)))  //0.5 //0.4 //0.55
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.85)))  //0.5  //0.4 //0.55
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.8)))  //0.8 //0.3
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.75)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.5)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.6)))   //1.0 //0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.5)))  //0.88 //1.0


// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.0))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(1.2)))  //0.9  1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(0.90)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.80)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.6)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.9)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(1.7)))  //0.9 //0.7
	DamageTypeModifiers.Add((DamageType=class'KFDT_ExplosiveSubmunition_HX25', 	 DamageScale=(0.6)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_EvisceratorProj', 	 DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Eviscerator', 	     DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_DragonsBreath', 	 DamageScale=(1.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon_Crovel', 	    	 DamageScale=(1.2)))  //0.8



	IncapSettings(AF_Stun)=		(Vulnerability=(0.2, 0.7, 0.2, 0.2, 0.2), Cooldown=10.0, Duration=1.5) //0.5, 1.0, 0.5, 0.5, 0.5
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.2),                     Cooldown=10)
    IncapSettings(AF_Stumble)=	(Vulnerability=(0.1),                     Cooldown=5)
    IncapSettings(AF_GunHit)=	(Vulnerability=(0.2),                     Cooldown=1.7)
    IncapSettings(AF_MeleeHit)=	(Vulnerability=(0.5),                     Cooldown=1.35)
    IncapSettings(AF_Poison)=	(Vulnerability=(0.6),                     Cooldown=20.0, Duration=1.5)
    IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=10.0, Duration=2.5)
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.9),                     Cooldown=5.0,  Duration=3.0)
    IncapSettings(AF_EMP)=		(Vulnerability=(2.0),                    Cooldown=10.0, Duration=2.2) //0.98
    IncapSettings(AF_Freeze)=	(Vulnerability=(0.5),                    Cooldown=1.5,  Duration=0.5) //0.98
    IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.25))

	//IncapSettings(AF_Stun)=		(Vulnerability=(1.8), Cooldown=5.0)
	//IncapSettings(AF_Knockdown)=(Vulnerability=(1.5), Cooldown=9.0)
	//IncapSettings(AF_Stumble)=	(Vulnerability=(1.2), Cooldown=5.0)
	//IncapSettings(AF_GunHit)=	(Vulnerability=(2.f), Cooldown=1.5)
	//IncapSettings(AF_MeleeHit)= (Vulnerability=(0.5), Cooldown=0.3)

    // Vulnerable damage types
   // DamageTypeModifiers.Add((DamageType=class'KFGameContent.KFDT_Ballistic_AR15', DamageScale=(1.25)))
   // DamageTypeModifiers.Add((DamageType=class'KFGameContent.KFDT_Ballistic_Rem1858', DamageScale=(1.25)))

	// Resistant damage types
  //  DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', DamageScale=(0.2f)))
  //  DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', DamageScale=(0.2f)))
   // DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.15)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.15)))

    Health=500 // 1.375x default  275
    DoshValue=28.0 // 2x default because they are harder to hit/kill
    XPValues(0)=44 // 4x default because they are harder to hit/kill

    // Override Head GoreHealth (aka HeadHealth)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=100, DmgScale=1.001, SkinID=1) // default is 20

    // Really fast sprint
    SprintSpeed=550 //570
    SprintStrafeSpeed=350
    GroundSpeed=350 //250

    // Blocking
	MinBlockFOV=1 //0

	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=50,Z=25),
		OffsetLow=(X=-220,Y=50,Z=50),
		OffsetMid=(X=-140,Y=50,Z=-10),
		)}
}
