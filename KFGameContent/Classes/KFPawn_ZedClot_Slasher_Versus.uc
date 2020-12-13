//=============================================================================
// KFPawn_ZedClot_Slasher_Versus
//=============================================================================
// Slash Versus pawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedClot_Slasher_Versus extends KFPawn_ZedClot_Slasher;

/** Custom third person camera offsets */
var() float	MegaJumpZ;

/** Mega Jump Forward Scale */
var() float	MegaJumpForwardScale;

/** Returns the sprint jump velocity, used in modifying jump mechanics while sprinting */
simulated function vector GetSprintJumpVelocity( vector ViewDirection )
{
	return ViewDirection * MegaJumpZ * GetDirectionalJumpScale();
}

simulated function float GetJumpZ()
{
	return MegaJumpZ;
}

simulated function float GetDirectionalJumpScale()
{
	return MegaJumpForwardScale;
}

defaultproperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30
	
	bHasExtraSprintJumpVelocity=true

	// Really fast sprint
    SprintSpeed=650  //600 //700
    SprintStrafeSpeed=450.f
    GroundSpeed=500  //430 //600

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_GrappleAttack)=none
		SpecialMoveClasses(SM_PlayerZedMove_LMB)= class'KFSM_PlayerSlasher_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)= class'KFSM_PlayerSlasher_Melee2'
		SpecialMoveClasses(SM_PlayerZedMove_V)= class'KFSM_PlayerSlasher_Roll'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Melee_Triangle)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Special_R3)=SM_PlayerZedMove_V

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=0.25f,	SpecialMoveIcon=Texture2D'ZED_Slasher_UI.ZED-VS_Icons_Slasher-Melee', NameLocalizationKey="Light")
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=1.0f,	SpecialMoveIcon=Texture2D'ZED_Slasher_UI.ZED-VS_Icons_Slasher-HeavyMelee', NameLocalizationKey="Heavy")
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=0.0f,	bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=0.2f,	SpecialMoveIcon=Texture2D'ZED_Slasher_UI.ZED-VS_Icons_Slasher-Evade', NameLocalizationKey="Evade")
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.0f,	SpecialMoveIcon=Texture2D'ZED_Slasher_UI.ZED-VS_Icons_Slasher-Jump', bShowOnHud=false)) // Jump always at end of array)) // Jump always at end of array

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.8)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.5)))  //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.4)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.4)))  //1.01
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.5)))  //0.76
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.8)))  //0.5  //0.65
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.8)))  //0.5 //0.65
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.8)))  //0.8 //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.35)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.35)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.4)))   //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(1.0)))  //0.88

// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.0))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(1.0)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(0.75)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.65)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.6)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.7)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(1.7)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_ExplosiveSubmunition_HX25', 	 DamageScale=(0.6)))  //0.9
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

	Begin Object Name=MeleeHelper_0
		BaseDamage=15.0 // 12.f //20
		MaxHitRange=172.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
		MeleeImpactCamScale=0.2
		PlayerDoorDamageMultiplier=5.f
	End Object
	MeleeAttackHelper=MeleeHelper_0

    Health=150 // 3.25x default //250  //200
    // Override Head GoreHealth (aka HeadHealth)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=85, DmgScale=1.001, SkinID=1) // default is 20  //gorehealth 75
    DoshValue=20.0 // 2x default because they are harder to hit
    XPValues(0)=32 // 4x default because they are harder to hit

    // Vulnerable damage types
   // DamageTypeModifiers.Add((DamageType=class'KFGameContent.KFDT_Ballistic_AR15', DamageScale=(1.5))
    //DamageTypeModifiers.Add((DamageType=class'KFGameContent.KFDT_Ballistic_Rem1858', DamageScale=(1.5))

    MegaJumpZ=1250
    MegaJumpForwardScale=0.25
    JumpBumpDamageType=class'KFDT_Bludgeon_ZedJump'

	ThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=50,Z=0),
		OffsetLow=(X=-220,Y=50,Z=0),
		OffsetMid=(X=-145,Y=50,Z=-30),
		)}
}
