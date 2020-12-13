//=============================================================================
// KFGameInfo
//=============================================================================
// Base GameInfo for KFGame
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedCrawler_Versus extends KFPawn_ZedCrawler;

var Controller OldController;

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local KFPlayerController KFPC;

	super.PlayDying( DamageType, HitLoc );

	if( OldController != none && DamageType == class'KFSM_PlayerCrawler_Suicide'.default.SuicideDamageType )
	{
	    KFPC = KFPlayerController( OldController );
	    if( KFPC != none )
	    {
			// If player respawned immediately, don't swap to suicide cam
			if( (KFPC.Pawn != none && KFPC.Pawn != self) || KFPC.IsInState('Spectating') )
			{
				return;
			}

	        KFPC.SetCameraMode( 'ZedSuicide' );
	        KFPlayerCamera_Versus(KFPC.PlayerCamera).SwapToZedSuicideCam( Location );
	    }
	}
}

DefaultProperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30
	//DrawScale3D=(X=1.5,Y=1.5,Z=1.25)

    Health=250// almost 5x default // 250.f //150
    DoshValue=25.0      // 2x default because they are harder to hit
    XPValues(0)=32.0    // 4x default because they are harder to hit

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)=class'KFSM_PlayerCrawler_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)=class'KFSM_PlayerCrawler_Melee2'
		SpecialMoveClasses(SM_PlayerZedMove_G)=class'KFSM_PlayerCrawler_Suicide'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Melee_Triangle)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Explosive_Ll)=SM_PlayerZedMove_G

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=0.65f,	SpecialMoveIcon=Texture2D'ZED_Crawler_UI.ZED-VS_Icons_Crawler-LightLeap', NameLocalizationKey="Light")
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB, 		CooldownTime=1.0f,	SpecialMoveIcon=Texture2D'ZED_Crawler_UI.ZED-VS_Icons_Crawler-HeavyLeap', NameLocalizationKey="Heavy")
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt, 				CooldownTime=0.0f,	bShowOnHud=false)
	SpecialMoveCooldowns(6)=(SMHandle=SM_PlayerZedMove_G,	CooldownTime=0.0f,	SpecialMoveIcon=Texture2D'ZED_Crawler_UI.ZED-VS_Icons_Crawler-Explode', NameLocalizationKey="Suicide")
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=0.85f,	SpecialMoveIcon=Texture2D'ZED_Crawler_UI.ZED-VS_Icons_Crawler-Jump', bShowOnHud=false)) // Jump always at end of array

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.3)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.8)))  //1.0 //0.7
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.3)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.4)))  //1.01
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.5)))  //0.76
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.8)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.8)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(1.0)))  //0.8 //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.35)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.35)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.4)))   //1.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(1.0)))  //0.88


// special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AR15',              DamageScale=(1.2))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MB500', 	         DamageScale=(0.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858', 	         DamageScale=(0.75)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Colt1911', 	     DamageScale=(0.65)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm', 	             DamageScale=(1.6)))  //0.9
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Pistol_Medic', 	 DamageScale=(1.5)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Winchester', 	     DamageScale=(0.7)))  //0.9
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_CaulkBurn', 	         DamageScale=(2.0)))  //0.9
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

	//defaults
	Begin Object Name=MeleeHelper_0
		BaseDamage=15.f //20.f
		MaxHitRange=180.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
		MeleeImpactCamScale=0.2
		PlayerDoorDamageMultiplier=5.f

	End Object
	MeleeAttackHelper=MeleeHelper_0

	bHasExtraSprintJumpVelocity=true

    // Override Head GoreHealth (aka HeadHealth)
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=100, DmgScale=1.001, SkinID=1) // default is 20 GoreHealth=75

    // Really fast sprint
    SprintSpeed=700.f  //600
    SprintStrafeSpeed=500.f  //500
    GroundSpeed=600   //300
    JumpZ=1000  //900

    JumpBumpDamageType=class'KFDT_Bludgeon_ZedJump'

	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-300,Y=60,Z=60),
		OffsetLow=(X=-220,Y=60,Z=25),
		OffsetMid=(X=-250,Y=60,Z=-30),
		)}
}
