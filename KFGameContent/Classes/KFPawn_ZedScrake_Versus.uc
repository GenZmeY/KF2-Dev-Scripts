//=============================================================================
// KFPawn_ZedScrake_Versus
//=============================================================================
// Scrake Versus pawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedScrake_Versus extends KFPawn_ZedScrake;

/** Ground speed to use when sprinting and enraged */
var const protected float RageSprintSpeed;

/** Rage bump damage variables */
var const protected class<KFDamageType> RageBumpDamageType;
var const protected int RageBumpDamage;
var const protected float RageBumpRadius;
var const protected float RageBumpMomentum;

/** Disallow sprinting if we've been struck by an EMP */
function SetSprinting(bool bNewSprintStatus)
{
	if( bEmpDisrupted )
	{
		bNewSprintStatus = false;
	}

	super.SetSprinting( bNewSprintStatus );
}

/** Enrage this FleshPound! */
simulated function bool SetEnraged( bool bNewEnraged )
{
	local bool bSuccess;

	bSuccess = super.SetEnraged( bNewEnraged );

	if( bIsEnraged )
	{
		if( !IsTimerActive(nameOf(Timer_RageBump)) )
		{
			SetTimer( 0.25f, true, nameOf(Timer_RageBump) );
		}

		SprintSpeed = RageSprintSpeed;
	}
	else if( IsTimerActive(nameOf(Timer_RageBump)) )
	{
		ClearTimer( nameOf(Timer_RageBump) );

		SprintSpeed = default.SprintSpeed;
	}

	return bSuccess;
}

/** Applies damage and impulse to nearby pawns and objects */
simulated protected function Timer_RageBump()
{
	HurtRadius( RageBumpDamage, RageBumpRadius, RageBumpDamageType, RageBumpMomentum, Location, self, Controller );
}

/** Clear our rage bump timer */
simulated function PlayDying( class<DamageType> DamageType, vector HitLoc )
{
	ClearTimer( nameOf(Timer_RageBump) );

	super.PlayDying( DamageType, HitLoc );
}

DefaultProperties
{
	bVersusZed=true
	TeammateCollisionRadiusPercent=0.30

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)= class'KFSM_PlayerScrake_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)= class'KFSM_PlayerScrake_Melee2'
		SpecialMoveClasses(SM_PlayerZedMove_V)= class'KFSM_PlayerScrake_Melee3'
		SpecialMoveClasses(SM_PlayerZedMove_MMB)= class'KFSM_PlayerScrake_Block'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Melee_Triangle)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Block_R1)=SM_PlayerZedMove_MMB
	MoveListGamepadScheme(ZGM_Special_R3)=SM_PlayerZedMove_V

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=0.5f,  SpecialMoveIcon=Texture2D'ZED_Scrake_UI.ZED-VS_Icons_Scrake-LightLunge', NameLocalizationKey="Light")
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=1.5f,  SpecialMoveIcon=Texture2D'ZED_Scrake_UI.ZED-VS_Icons_Scrake-HeavyLunge', NameLocalizationKey="Heavy")
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=1.0f,  bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=2.5f,  SpecialMoveIcon=Texture2D'ZED_Scrake_UI.ZED-VS_Icons_Scrake-SpinAttack', NameLocalizationKey="Spin")
	SpecialMoveCooldowns(4)=(SMHandle=SM_PlayerZedMove_MMB,		CooldownTime=0.2,	SpecialMoveIcon=Texture2D'ZED_Shared_UI.ZED-VS_Icons_Generic-Block', NameLocalizationKey="Block") //0.5
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.25f, SpecialMoveIcon=Texture2D'ZED_Scrake_UI.ZED-VS_Icons_Scrake-Jump', bShowOnHud=false)) // Jump always at end of array

    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.6)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.5)))
	
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.6)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGTeslauncherDoT',     DamageScale=(0.6)))

	IncapSettings(AF_Stun)=		(Vulnerability=(0.2, 0.7, 0.2, 0.2, 0.2), Cooldown=10.0, Duration=1.5) //0.5, 1.0, 0.5, 0.5, 0.5
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.2),                     Cooldown=10)
    IncapSettings(AF_Stumble)=	(Vulnerability=(0.1),                     Cooldown=5)
    IncapSettings(AF_GunHit)=	(Vulnerability=(0.2),                     Cooldown=1.7)
    IncapSettings(AF_MeleeHit)=	(Vulnerability=(0.5),                     Cooldown=1.35)
    IncapSettings(AF_Poison)=	(Vulnerability=(0.6),                     Cooldown=20.0, Duration=1.5)
    IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=10.0, Duration=2.5)
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.9),                     Cooldown=5.0,  Duration=3.0)
    IncapSettings(AF_EMP)=		(Vulnerability=(0.98),                    Cooldown=10.0, Duration=2.2) //0.98
    IncapSettings(AF_Freeze)=	(Vulnerability=(0.5),                    Cooldown=1.5,  Duration=0.5) //0.98
    IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.25))
    
   // IncapSettings(AF_Stun)=		(Vulnerability=(2.f), Cooldown=6.0)
    //IncapSettings(AF_Knockdown)=(Vulnerability=(2.f), Cooldown=17.0)
  //  IncapSettings(AF_Stumble)=	(Vulnerability=(1.2), Cooldown=8.0)
  //  IncapSettings(AF_GunHit)=	(Vulnerability=(2.5), Cooldown=3.0)
   // IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.2), Cooldown=4.0)

	//defaults
	Begin Object Name=MeleeHelper_0
		BaseDamage=15//30.f  //20
		MaxHitRange=200.f
		MomentumTransfer=45000.f
		MyDamageType=class'KFGameContent.KFDT_Slashing_Scrake'
		MeleeImpactCamScale=0.45
		PlayerDoorDamageMultiplier=5.f
	End Object
	MeleeAttackHelper=MeleeHelper_0

	Health=1600  //1565  //1300
	DoshValue=260.0 // 1.5x default because they are harder to hit/kill
	XPValues(0)=102 // 1.5 X 2x default because they are harder to hit/kill

	// Movement speeds
	SprintSpeed=530
	RageSprintSpeed=650
	SprintStrafeSpeed=350.f
	Groundspeed=220.f

	// Rage
	RageHealthThresholdNormal=0.75
	RageBumpDamage=2
	RageBumpRadius=240.f
	RageBumpMomentum=500.f
	RageBumpDamageType=class'KFGameContent.KFDT_HeavyZedBump'

	// Blocking
	MinBlockFOV=0.f
	
	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=60,Z=60),
		OffsetLow=(X=-220,Y=100,Z=50),
		OffsetMid=(X=-160,Y=50,Z=0),
		)}

//	Health=3500
//	DrawScale3D=(X=1.25,Y=1.25,Z=1.25)
//	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=3500, DmgScale=1.1, SkinID=1)
//	HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=200,  DmgScale=0.5, SkinID=2)
}
