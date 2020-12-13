//=============================================================================
// KFPawn_ZedStalker_Versus
//=============================================================================
// Player-controlled Stalker pawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedStalker_Versus extends KFPawn_ZedStalker;

/**
 * Called every 0.5f seconds to check if a cloaked zed has been spotted
 * Network: All but dedicated server
 */
simulated event UpdateSpottedStatus()
{
	if( !bIsSprinting )
	{
		if( bIsCloakingSpottedByLP )
		{
			bIsCloakingSpottedByLP = false;
			UpdateGameplayMICParams();
		}

		return;
	}

	super.UpdateSpottedStatus();
}

/** notification from player with CallOut ability */
function CallOutCloaking( optional KFPlayerController CallOutController )
{
	if( !bIsSprinting )
	{
		if( bIsCloakingSpottedByTeam )
		{
			bIsCloakingSpottedByTeam = false;
			UpdateGameplayMICParams();
		}

		return;
	}

	super.CallOutCloaking( CallOutController );
}

defaultproperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)= class'KFSM_PlayerStalker_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)= class'KFSM_PlayerStalker_Melee2'
		SpecialMoveClasses(SM_PlayerZedMove_V)= class'KFSM_PlayerStalker_Roll'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Melee_Triangle)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Special_R3)=SM_PlayerZedMove_V

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=0.25f,	SpecialMoveIcon=Texture2D'ZED_Stalker_UI.ZED-VS_Icons_Stalker-Melee', NameLocalizationKey="Light")
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=1.0f,	SpecialMoveIcon=Texture2D'ZED_Stalker_UI.ZED-VS_Icons_Stalker-HeavyMelee', NameLocalizationKey="Heavy")
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=0.0f,	bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=0.35f,	SpecialMoveIcon=Texture2D'ZED_Stalker_UI.ZED-VS_Icons_Stalker-Evade', NameLocalizationKey="Evade")
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.0f,	SpecialMoveIcon=Texture2D'ZED_Stalker_UI.ZED-VS_Icons_Stalker-Jump', bShowOnHud=false)) // Jump always at end of array)) // Jump always at end of array

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.1)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.7)))  //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.4)))  //1.01
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.4)))  //0.76  0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.75)))  //0.5 //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.75)))  //0.5 //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.8)))  //0.8 //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.35)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.20)))  //0.85  0.35
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.4)))   //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(1.0)))  //0.88


// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.2))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(0.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(0.75)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.65)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.6)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.6)))  //0.9  0.7
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_ExplosiveSubmunition_HX25', 	 DamageScale=(0.5)))  //0.9  0.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_EvisceratorProj', 	 DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing_Eviscerator', 	     DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon_Crovel', 	    	 DamageScale=(1.2)))  //0.8



	IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 0.5, 0.1, 0.1, 0.1), Cooldown=3.0, Duration=2.0)
	IncapSettings(AF_Knockdown)=(Vulnerability=(0.5),                     Cooldown=3.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(0.1),                     Cooldown=3.0)
	IncapSettings(AF_GunHit)=	(Vulnerability=(1.0),                     Cooldown=0.75)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                     Cooldown=0.5)
	IncapSettings(AF_Poison)=	(Vulnerability=(1),                       Cooldown=5.0, Duration=2.0)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.25),                     Cooldown=5.0, Duration=2.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(0.5),                     Cooldown=7.0, Duration=3)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0, Duration=3.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(1.0),                     Cooldown=1.5, Duration=2.0)
	IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.25))



	//defaults
	Begin Object Name=MeleeHelper_0
		BaseDamage=20 //20
		MaxHitRange=180.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
		MeleeImpactCamScale=0.2
		PlayerDoorDamageMultiplier=5.f
	End Object
	MeleeAttackHelper=MeleeHelper_0

	Health=130 // 2.5x default  //200 //100
    // Override Head GoreHealth (aka HeadHealth)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=100, DmgScale=1.001, SkinID=1) // default is 20  GoreHealth=75
    DoshValue=30.0 // 2x default because they are harder to hit/kill
    XPValues(0)=32 // 4x default because they are harder to hit/kill

    // Really fast sprint
    SprintSpeed=700  //620
    SprintStrafeSpeed=425.f
    GroundSpeed=500  //390


    JumpZ=1100  //750

    CloakSpeed=2.0f

	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=50,Z=25),
		OffsetLow=(X=-220,Y=50,Z=50),
		OffsetMid=(X=-150,Y=50,Z=-30),
		)}
}
