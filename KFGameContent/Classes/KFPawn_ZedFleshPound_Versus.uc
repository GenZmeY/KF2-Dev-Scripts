//=============================================================================
// KFPawn_ZedFleshPound_Versus
//=============================================================================
// Fleshpound Versus pawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedFleshPound_Versus extends KFPawn_ZedFleshpound;

/** Ground speed to use when sprinting and enraged */
var const protected float RageSprintSpeed;

/** Rage bump damage variables */
var const protected int RageBumpDamage;
var const protected float RageBumpRadius;
var const protected float RageBumpMomentum;

function PossessedBy( Controller C, bool bVehicleTransition )
{
	Super.PossessedBy( C, bVehicleTransition );

	if( WorldInfo.NetMode != NM_DedicatedServer && Mesh != None )
	{
		UpdateGameplayMICParams();
	}
}

/** Disallow sprinting if we've been struck by an EMP */
function SetSprinting(bool bNewSprintStatus)
{
	if( bEmpDisrupted )
	{
		bNewSprintStatus = false;
	}

	super(KFPawn_Monster).SetSprinting( bNewSprintStatus );
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

/** Ends rage mode 3 seconds after melee damage is done */
function NotifyMeleeDamageDealt()
{
	if( !IsTimerActive(nameOf(EndRage)) )
	{
		SetTimer( 3.f, false, nameOf(EndRage) );
	}
}

/** Ends rage mode */
function EndRage()
{
	SetEnraged( false );
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

	Health=2281//1725 //1983 //2181feltok

	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_PlayerZedMove_LMB)=class'KFSM_PlayerFleshpound_Melee'
		SpecialMoveClasses(SM_PlayerZedMove_RMB)=class'KFSM_PlayerFleshpound_Melee2'
		SpecialMoveClasses(SM_PlayerZedMove_V)=class'KFSM_PlayerFleshpound_Rage'
		SpecialMoveClasses(SM_PlayerZedMove_MMB)= class'KFSM_PlayerFleshpound_Block'
	End Object

	MoveListGamepadScheme(ZGM_Melee_Square)=SM_PlayerZedMove_LMB
	MoveListGamepadScheme(ZGM_Melee_Triangle)=SM_PlayerZedMove_RMB
	MoveListGamepadScheme(ZGM_Block_R1)=SM_PlayerZedMove_MMB
	MoveListGamepadScheme(ZGM_Special_R3)=SM_PlayerZedMove_V

	SpecialMoveCooldowns(0)=(SMHandle=SM_PlayerZedMove_LMB,		CooldownTime=0.75f,	SpecialMoveIcon=Texture2D'ZED_Fleshpound_UI.ZED-VS_Icons_Fleshpound-LightAttack', NameLocalizationKey="Light")
	SpecialMoveCooldowns(1)=(SMHandle=SM_PlayerZedMove_RMB,		CooldownTime=1.5f,	SpecialMoveIcon=Texture2D'ZED_Fleshpound_UI.ZED-VS_Icons_Fleshpound-HeavyAttack', NameLocalizationKey="Heavy")
	SpecialMoveCooldowns(2)=(SMHandle=SM_Taunt,					CooldownTime=0.0f,	bShowOnHud=false)
	SpecialMoveCooldowns(3)=(SMHandle=SM_PlayerZedMove_V,		CooldownTime=10.5f,	SpecialMoveIcon=Texture2D'ZED_Fleshpound_UI.ZED-VS_Icons_Fleshpound-Rage', NameLocalizationKey="Rage")
	SpecialMoveCooldowns(4)=(SMHandle=SM_PlayerZedMove_MMB,		CooldownTime=0.2,	SpecialMoveIcon=Texture2D'ZED_Shared_UI.ZED-VS_Icons_Generic-Block', NameLocalizationKey="Block") //0.5
	SpecialMoveCooldowns.Add((SMHandle=SM_Jump,					CooldownTime=1.25f,	SpecialMoveIcon=Texture2D'ZED_Fleshpound_UI.ZED-VS_Icons_Fleshpound-Jump', bShowOnHud=false)) // Jump always at end of array

	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.75)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive_RPG7', 	        DamageScale=(1.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(1.5)))  //0.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.5)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic', DamageScale=(0.7f)))

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGTeslauncherDoT',     DamageScale=(0.5)))

	IncapSettings(AF_Stun)=		(Vulnerability=(0.2, 0.25, 0.2, 0.0, 0.25),   Cooldown=10.0, Duration=1.5) //0.5, 0.55, 0.5, 0.0, 0.55
	IncapSettings(AF_Knockdown)=(Vulnerability=(0.25, 0.25, 0.25, 0.25, 0.4), Cooldown=10.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(0.2, 0.25, 0.25, 0.0, 0.4),   Cooldown=7.0)
	IncapSettings(AF_GunHit)=	(Vulnerability=(0.0, 0.0, 0.0, 0.0, 0.5),     Cooldown=1.7)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                         Cooldown=1.2)
	IncapSettings(AF_Poison)=	(Vulnerability=(0.6),                         Cooldown=20.0, Duration=1.5)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                         Cooldown=17.0, Duration=2.5)
	IncapSettings(AF_FirePanic)=(Vulnerability=(0.7),                         Cooldown=12.0, Duration=3.5)
	IncapSettings(AF_EMP)=		(Vulnerability=(0.3),                         Cooldown=10.0, Duration=2.2) //0.95
	IncapSettings(AF_Freeze)=	(Vulnerability=(0.5),                         Cooldown=1.5,  Duration=0.5) //0.95
	IncapSettings(AF_Snare)=	(Vulnerability=(0.7, 0.7, 1.0, 0.7),      Cooldown=8.5,  Duration=1.5)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.25))

	//defaults
	Begin Object Name=MeleeHelper_0
		BaseDamage=30
		MaxHitRange=250.f
		MomentumTransfer=55000.f
		MyDamageType=class'KFDT_Bludgeon_Fleshpound'
		MeleeImpactCamScale=0.45
		PlayerDoorDamageMultiplier=5.f
	End Object
	MeleeAttackHelper=MeleeHelper_0

    DoshValue=300.0 // 1.5x default because they are harder to hit/kill
    XPValues(0)=105.0// 1.5 X 2x default because they are harder to hit/kill

	// Movement speeds
    SprintSpeed=550 //750
    RageSprintSpeed=700
    SprintStrafeSpeed=450
    GroundSpeed=275  //300

	// Rage
	RageBumpDamage=2
	RageBumpRadius=240.f
	RageBumpMomentum=500.f

    // Blocking higher values = less resistance
	MinBlockFOV=0.f

	//defaults
	ThirdPersonViewOffset={(
		OffsetHigh=(X=-175,Y=60,Z=60),
		OffsetLow=(X=-220,Y=100,Z=50),
		OffsetMid=(X=-160,Y=50,Z=30),
		)}

//	Health=3500
//	DrawScale3D=(X=1.25,Y=1.25,Z=1.25)
//	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=2000, DmgScale=1.1, SkinID=1)
//	HitZones[3]       =(ZoneName=heart,	   BoneName=Spine2,		  Limb=BP_Special,  GoreHealth=1500, DmgScale=1.1, SkinID=2)
//	HitZones[5]		  =(ZoneName=lforearm, BoneName=LeftForearm,  Limb=BP_LeftArm,  GoreHealth=200,  DmgScale=0.5, SkinID=3)
//	HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=200,  DmgScale=0.5, SkinID=3)
}
