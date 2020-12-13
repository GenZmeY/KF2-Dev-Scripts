//=============================================================================
// KFPawn_ZedClot_AlphaKing_Versus
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedClot_AlphaKing_Versus extends KFPawn_ZedClot_AlphaKing;

defaultproperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30

	//defaults
	Begin Object Name=MeleeHelper_0
		BaseDamage=10.f
		MaxHitRange=172.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
		MeleeImpactCamScale=0.2
		PlayerDoorDamageMultiplier=5.f
	End Object
	MeleeAttackHelper=MeleeHelper_0

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)=class'KFSM_PlayerAlpha_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)=class'KFSM_PlayerAlpha_Grab'
		SpecialMoveClasses(SM_PlayerZedMove_V)=class'KFSM_PlayerAlpha_Rally'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Melee_Triangle)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Special_R3)=SM_PlayerZedMove_V

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=0.18f, SpecialMoveIcon=Texture2D'ZED_Clot_UI.ZED-VS_Icons_AlphaClot-Melee', NameLocalizationKey="Melee")  //0.25
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=0.0f,  SpecialMoveIcon=Texture2D'ZED_Clot_UI.ZED-VS_Icons_AlphaClot-Grab', NameLocalizationKey="Grab")
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=0.0f,  bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=1.5f,  SpecialMoveIcon=Texture2D'ZED_Clot_UI.ZED-VS_Icons_AlphaClot-Enrage', NameLocalizationKey="Rally")
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.f, 	SpecialMoveIcon=Texture2D'ZED_Clot_UI.ZED-VS_Icons_AlphaClot-Jump', bShowOnHud=false)) // Jump always at end of array

	bWeakZedGrab=false

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.8)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.7)))  //1.0 //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.5)))  //0.9 //0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.4)))  //1.01
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.5)))  //0.76
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.8)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.8)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.0)))  //0.8 //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.35)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.35)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.4)))   //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.5)))  //0.88 //1.0

// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.0))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(1.0)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(0.75)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.65)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.6)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.6)))  //0.9 0.7
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(2.0)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_ExplosiveSubmunition_HX25', 	 DamageScale=(0.6)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_EvisceratorProj', 	 DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Eviscerator', 	     DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon_Crovel', 	    	 DamageScale=(1.2)))  //0.8

	IncapSettings(AF_Stun)=		(Vulnerability=(0.2, 0.7, 0.2, 0.2, 0.2), Cooldown=10.0, Duration=1.5) //0.5, 1.0, 0.5, 0.5, 0.5
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.2),                     Cooldown=10)
    IncapSettings(AF_Stumble)=	(Vulnerability=(0.1),                     Cooldown=5)
    IncapSettings(AF_GunHit)=	(Vulnerability=(0.2),                     Cooldown=1.7)
    IncapSettings(AF_MeleeHit)=	(Vulnerability=(0.5),                     Cooldown=1.35)
    IncapSettings(AF_Poison)=	(Vulnerability=(0.6),                     Cooldown=20.0, Duration=1.5)
    IncapSettings(AF_Microwave)=(Vulnerability=(0.25),                     Cooldown=10.0, Duration=2.5)
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.9),                     Cooldown=5.0,  Duration=3.0)
    IncapSettings(AF_EMP)=		(Vulnerability=(0.7),                     Cooldown=10.0, Duration=2.2) //0.98
    IncapSettings(AF_Freeze)=	(Vulnerability=(0.5),                     Cooldown=1.5,  Duration=0.5) //0.98
    IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.25))

    Health=350 // 4.5x default //300.f  //455 //200
    // Override Head GoreHealth (aka HeadHealth)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=85, DmgScale=1.01, SkinID=1) // default is 20
    DoshValue=20.0 // 2x default because they are harder to hit
    XPValues(0)=32 // 4x default because they are harder to hit

    // Vulnerable damage types
    //DamageTypeModifiers.Add((DamageType=class'KFGameContent.KFDT_Ballistic_AR15', DamageScale=(1.5)))
    //DamageTypeModifiers.Add((DamageType=class'KFGameContent.KFDT_Ballistic_Rem1858', DamageScale=(1.5)))

    SprintSpeed=575.f  //570 //550
    SprintStrafeSpeed=325.f
    GroundSpeed=325.f //250 //300

	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-140,Y=50,Z=0),
		OffsetLow=(X=-220,Y=50,Z=50),
		OffsetMid=(X=-160,Y=50,Z=0),
		)}
}

