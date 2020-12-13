//=============================================================================
// KFPawn_ZedBloat_Versus
//=============================================================================
// Bloat Versus pawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedBloat_Versus extends KFPawn_ZedBloat;

/** Spawn a puke mine */
simulated function ANIMNOTIFY_PukeMineAttack()
{
	local vector SpawnLocation;
	local rotator SpawnRotation;

	if( Role == ROLE_Authority )
	{
		Mesh.GetSocketWorldLocationAndRotation( 'PukeSocket', SpawnLocation, SpawnRotation );
		SpawnPukeMine( SpawnLocation, SpawnRotation );
	}
}

defaultproperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30
	VomitDamage=20  //
	//defaults
	Begin Object Name=MeleeHelper_0
		BaseDamage=20.f
		MaxHitRange=250.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object
	MeleeAttackHelper=MeleeHelper_0

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)= class'KFSM_PlayerBloat_Melee2'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)= class'KFSM_PlayerBloat_PukeMineAttack'
		SpecialMoveClasses(SM_PlayerZedMove_V)= class'KFSM_PlayerBloat_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_MMB)= class'KFSM_PlayerBloat_Block'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_V
	MoveListGamepadScheme(ZGM_Block_R1)=SM_PlayerZedMove_MMB
	MoveListGamepadScheme(ZGM_Attack_R2)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Attack_L2)=SM_PlayerZedMove_RMB

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=1.25f,	SpecialMoveIcon=Texture2D'ZED_Bloat_UI.ZED-VS_Icons_Bloat-Puke', NameLocalizationKey="Puke")
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=1.55f,	SpecialMoveIcon=Texture2D'ZED_Bloat_UI.ZED-VS_Icons_Bloat-PukeMine', NameLocalizationKey="Mine") //1.35
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=0.0f,	bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=0.5f,	SpecialMoveIcon=Texture2D'ZED_Bloat_UI.ZED-VS_Icons_Bloat-Melee', NameLocalizationKey="Heavy")
	SpecialMoveCooldowns(4)=(SMHandle=SM_PlayerZedMove_MMB,		CooldownTime=0.5f,	SpecialMoveIcon=Texture2D'ZED_Shared_UI.ZED-VS_Icons_Generic-Block', NameLocalizationKey="Block") //1.7
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.5f,	SpecialMoveIcon=Texture2D'ZED_Bloat_UI.ZED-VS_Icons_Bloat-Jump', bShowOnHud=false)) // Jump always at end of array

    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.8)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.75)))  //1.0 //0.55
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.3)))  //0.9  0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.6)))  //1.01
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.65)))  //0.76
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.9)))  //0.5 //0.45 //0.65
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9)))  //0.5 //0.45 //0.65
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.0)))  //0.8
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(1.5)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.5)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.4)))   //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.2)))  //0.88

    // special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.1))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(0.7)))  //0.9  1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_DBShotgun', 	     DamageScale=(0.5)))  
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.70)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.4)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.4)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.85)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(2.0)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_ExplosiveSubmunition_HX25', 	 DamageScale=(0.6)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_EvisceratorProj', 	 DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Eviscerator', 	     DamageScale=(0.7)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_DragonsBreath', 	 DamageScale=(1.0)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon_Crovel', 	    	 DamageScale=(1.2)))  //0.8
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',	 DamageScale=(0.58)))

	IncapSettings(AF_Stun)=		(Vulnerability=(0.2, 0.7, 0.2, 0.2, 0.2), Cooldown=10.0, Duration=1.5) //0.5, 1.0, 0.5, 0.5, 0.5
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.2),                     Cooldown=10)
    IncapSettings(AF_Stumble)=	(Vulnerability=(0.1),                     Cooldown=5)
    IncapSettings(AF_GunHit)=	(Vulnerability=(0.2),                     Cooldown=1.7)
    IncapSettings(AF_MeleeHit)=	(Vulnerability=(0.5),                     Cooldown=1.35)
    IncapSettings(AF_Poison)=	(Vulnerability=(0.6),                     Cooldown=20.0, Duration=1.5)
    IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=10.0, Duration=2.5)
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.9),                     Cooldown=5.0,  Duration=3.0)
    IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                    Cooldown=10.0, Duration=2.2) //0.98
    IncapSettings(AF_Freeze)=	(Vulnerability=(0.5),                    Cooldown=1.5,  Duration=0.5) //0.98
    IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.25))

    // Faster sprint
	SprintSpeed=410//445.0f //400 //420
	SprintStrafeSpeed=300.f//295.f //250
	Groundspeed=270//2.85f  //260 //250 //280

	Health=700  //485  600
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=350, DmgScale=1.001, SkinID=1)//gorehealth 90  175
    DoshValue=25    // 1.2x 17 default because they have 1.2x more health
    XPValues(0)=40  // 1.2 x 2x default because they have 1.2x more health

	// Blocking higher values = less resistance
	MinBlockFOV=0.f

	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=60,Z=60),
		OffsetLow=(X=-220,Y=100,Z=50),
		OffsetMid=(X=-160,Y=50,Z=10),
		)}
}
