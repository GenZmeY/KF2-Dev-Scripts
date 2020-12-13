//=============================================================================
// KFPawn_ZedSiren_Versus
//=============================================================================
// Siren Versus pawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedSiren_Versus extends KFPawn_ZedSiren;

function SetSprinting( bool bNewSprintStatus )
{
	if( bNewSprintStatus && (IsDoingSpecialMove(SM_PlayerZedMove_LMB) || IsDoingSpecialMove(SM_PlayerZedMove_RMB)) )
	{
		return;
	}

	super.SetSprinting( bNewSprintStatus );
}

defaultproperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30

	// Off by default, turned on by the vortex SM
	bCanHeadTrack=false
	bIsHeadTrackingActive=false

	Begin Object Name=MeleeHelper_0
		BaseDamage=13.f
		MaxHitRange=180.f
		MomentumTransfer=100000.f // for kick
		MyDamageType=class'KFDT_Slashing_ZedWeak'
		MeleeImpactCamScale=0.2
		PlayerDoorDamageMultiplier=5.f
	End Object
	MeleeAttackHelper=MeleeHelper_0

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)=class'KFSM_PlayerSiren_NormalScream'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)=class'KFSM_PlayerSiren_VortexScream'
		SpecialMoveClasses(SM_PlayerZedMove_V)=class'KFSM_PlayerSiren_Melee'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_V
	MoveListGamepadScheme(ZGM_Attack_L2)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Attack_R2)=SM_PlayerZedMove_LMB

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=2.5f,		SpecialMoveIcon=Texture2D'ZED_Siren_UI.ZED-VS_Icons_Siren-Scream', NameLocalizationKey="Scream")
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=12.0f,		SpecialMoveIcon=Texture2D'ZED_Siren_UI.ZED-VS_Icons_Siren-PullIn', NameLocalizationKey="Vortex") //8.0
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=0.0f,		bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=0.0f,		SpecialMoveIcon=Texture2D'ZED_Siren_UI.ZED-VS_Icons_Siren-Bite', NameLocalizationKey="Bite")
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.5f,		SpecialMoveIcon=Texture2D'ZED_Siren_UI.ZED-VS_Icons_Siren-Jump', bShowOnHud=false)) // Jump always at end of array

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.8)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.7)))  //1.0 //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.6)))  //1.01  0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.75)))  //0.76  0.5 //0.65
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.8)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.8)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.8)))  //0.8 //0.3
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.75)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.5)))  //0.85  0.35
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.6)))   //1.0 //0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.30)))  //0.88

// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.0))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(1.1)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(0.85)))  //0.9  0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.75)))  //0.9   0.65
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.6)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.75)))  //0.9  0.7
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(1.5)))  //0.9 //0.7
	DamageTypeModifiers.Add((DamageType=class'KFDT_ExplosiveSubmunition_HX25', 	 DamageScale=(0.6)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_EvisceratorProj', 	 DamageScale=(0.4)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Eviscerator', 	     DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_DragonsBreath', 	 DamageScale=(1.1)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon_Crovel', 	    	 DamageScale=(1.2)))  //0.8




	IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 0.5, 0.1, 0.1, 0.1), Cooldown=3.0, Duration=2.0)
	IncapSettings(AF_Knockdown)=(Vulnerability=(0.3),                     Cooldown=10.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(0.2),                     Cooldown=3.0)
	IncapSettings(AF_GunHit)=	(Vulnerability=(1.0),                     Cooldown=0.75)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                     Cooldown=0.5)
	IncapSettings(AF_Poison)=	(Vulnerability=(1),                       Cooldown=5.0, Duration=2.0)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=5.0, Duration=2.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(1.0),                     Cooldown=8.0, Duration=3)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0, Duration=3.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(1.0),                     Cooldown=1.5, Duration=2.0)
	IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.25))

    SprintSpeed=430.0f  //450
    SprintStrafeSpeed=300.f
    GroundSpeed=200.0f

// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=155, DmgScale=1.01, SkinID=1) // KF1=200

    Health=300 // KF1=300
    DoshValue=25.0 // default because they have the same health as survival
    XPValues(0)=22 // 2x default because they are harder to hit/kill

	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=50,Z=25),
		OffsetLow=(X=-220,Y=50,Z=50),
		OffsetMid=(X=-140,Y=50,Z=-10),
		)}
}
