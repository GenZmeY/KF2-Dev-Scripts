//=============================================================================
// KFPawn_ZedSiren
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedSiren extends KFPawn_Monster;

/** Neck light */
var protected PointLightComponent NeckLightComponent;
var protected const name NeckLightSocketName;
var protected const float ScreamLightFlickerRate;
var protected const float ScreamLightRadius;
var protected const float ScreamLightFalloffExponent;
var protected const float MinFlickerBrightness;
var protected const float MaxFlickerBrightness;

/** Initialize our light */
simulated function SetCharacterArch( KFCharacterInfoBase Info, optional bool bForce )
{
	super.SetCharacterArch( Info, bForce );

	if( WorldInfo.NetMode != NM_DedicatedServer && !NeckLightComponent.bAttached && WorldInfo.GetDetailMode() > DM_Low )
	{
		Mesh.AttachComponentToSocket( NeckLightComponent, NeckLightSocketName );
		NeckLightComponent.SetEnabled( true );
		`LightPool.RegisterPointLight( NeckLightComponent, LPP_GameplayUsed );
	}
}

simulated function ANIMNOTIFY_SirenScream()
{
	local KFSM_Siren_Scream ScreamSM;

	ScreamSM = KFSM_Siren_Scream(SpecialMoves[SpecialMove]);
    if( ScreamSM != none )
    {
    	ScreamSM.ScreamBegan();
    	if( WorldInfo.NetMode != NM_Client )
    	{
	    	DisablebOnDeathAchivement();
	    }
    }
}

simulated function EnableScreamFlicker( bool bEnabled )
{
	if( WorldInfo.NetMode == NM_DedicatedServer || bPlayedDeath || NeckLightComponent == none || !NeckLightComponent.bAttached )
	{
		return;
	}

	if( bEnabled )
	{
		NeckLightComponent.AnimationType = LightAnim_Strobe;
		NeckLightComponent.AnimationFrequency = ScreamLightFlickerRate;
		NeckLightComponent.Radius = ScreamLightRadius;
		NeckLightComponent.FalloffExponent = ScreamLightFalloffExponent;
		NeckLightComponent.MinBrightness = MinFlickerBrightness;
		NeckLightComponent.MaxBrightness = MaxFlickerBrightness;
	}
	else
	{
		NeckLightComponent.AnimationType = default.NeckLightComponent.AnimationType;
		NeckLightComponent.AnimationFrequency = default.NeckLightComponent.AnimationFrequency;
		NeckLightComponent.Radius = default.NeckLightComponent.Radius;
		NeckLightComponent.FalloffExponent = default.NeckLightComponent.FalloffExponent;
		NeckLightComponent.MinBrightness = default.NeckLightComponent.MinBrightness;
		NeckLightComponent.MaxBrightness = default.NeckLightComponent.MaxBrightness;
	}

	NeckLightComponent.DetachFromAny();
	Mesh.AttachComponentToSocket( NeckLightComponent, NeckLightSocketName );
}

 /** Clean up function to terminate any effects on death */
 simulated function TerminateEffectsOnDeath()
 {
	local MaterialInstanceConstant MIC;

 	super.TerminateEffectsOnDeath();

 	if( NeckLightComponent != none && NeckLightComponent.bAttached )
 	{
		NeckLightComponent.DetachFromAny();
		NeckLightComponent = none;
	}

	// reset xmas transition effect
	foreach CharacterMICs(MIC)
	{
		MIC.SetScalarParameterValue('Scalar_TransitionEffect', 0);
	}
 }

/** Returns (hardcoded) dialog event ID for when players kills this zed type */
function int GetKillerDialogID()
{
	return 66;//KILL_Female
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	return 128;//SPOTZ_Siren
}

/** Returns (hardcoded) dialog event ID for when trader gives advice to player who was killed by this zed type */
static function int GetTraderAdviceID()
{
	return 44;//TRAD_AdviceSiren
}

defaultproperties
{
	LocalizationKey=KFPawn_ZedSiren
	// ---------------------------------------------
	// Stats
	XPValues(0)=11
	XPValues(1)=15
	XPValues(2)=15
	XPValues(3)=15

	// ---------------------------------------------
	// Content
    MonsterArchPath="ZED_ARCH.ZED_Siren_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Siren_ANIM.Siren_AnimGroup'
	DifficultySettings=class'KFDifficulty_Siren'

	Begin Object Name=KFPawnSkeletalMeshComponent
		bPerBoneMotionBlur=false
	End Object

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Taunt)=class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_SonicAttack)=class'KFGameContent.KFSM_Siren_Scream'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 2.0, 0.5, 0.5, 2.0), Cooldown=5.0,  Duration=1.5)
	IncapSettings(AF_Knockdown)=(Vulnerability=(1.0),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(1.0),                     Cooldown=1.0)   //0.4
	IncapSettings(AF_GunHit)=	(Vulnerability=(0.9),                     Cooldown=0.2)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                     Cooldown=0.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(0.9),                     Cooldown=6.0,  Duration=5.0)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Poison)=	(Vulnerability=(0.15),	                  Cooldown=20.5, Duration=5.0)
	IncapSettings(AF_Microwave)=(Vulnerability=(3),                       Cooldown=6.5,  Duration=4.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(2.0),                     Cooldown=1.5,  Duration=4.2)
	IncapSettings(AF_Snare)=	(Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0), Cooldown=5.5,  Duration=3.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(1.0))
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))
	
	ShrinkEffectModifier = 0.7f

	Begin Object Name=Afflictions_0
		AfflictionClasses(AF_EMP)=class'KFAffliction_EMPDisrupt'
	End Object

	ParryResistance=1

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.0))) //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.0)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.0)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.0)))  //0.7
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))  //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.0)))  //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(1.0)))  //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.5))) //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.85))) //0.85
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 				    DamageScale=(0.85))) //0.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.5))) //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.25))) //0.25	


	//Special Case damage resistance
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_9mm',              DamageScale=(1.0))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rem1858',          DamageScale=(1.0))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_DBShotgun',        DamageScale=(1.1))

	// ---------------------------------------------
	// Visuals
    Begin Object Class=PointLightComponent Name=NeckLightComponent0
        FalloffExponent=2.f
        Brightness=0.8f
        Radius=35.f
        LightColor=(R=250,G=50,B=50,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        bEnabled=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=true)

        // light anim
        AnimationType=1
        AnimationFrequency=5.f
        MinBrightness=0.75f
        MaxBrightness=1.2f
    End Object
    NeckLightComponent=NeckLightComponent0
    NeckLightSocketName=NeckLightSocket

	ScreamLightFlickerRate=4.25f
	ScreamLightFalloffExponent=2.f
	ScreamLightRadius=200.f
	MinFlickerBrightness=0.4f
	MaxFlickerBrightness=2.0f

	// ---------------------------------------------
	// Gameplay
	Begin Object Name=MeleeHelper_0
		BaseDamage=13.f //13
		MaxHitRange=180.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	Health=230 // KF1=300
	DoshValue=25
	Mass=50.f

	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
	HeadlessBleedOutTime=5.f
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=155, DmgScale=1.1, SkinID=1) // KF1=200
	HitZones[1]		  =(ZoneName=neck,	  BoneName=Neck,   Limb=BP_Head,  GoreHealth=20,  DmgScale=1.1, SkinID=2)
	HitZones[2]		  =(ZoneName=chest,   BoneName=Spine2, Limb=BP_Torso, GoreHealth=150, DmgScale=0.5, SkinID=3) //0.5
	HitZones[11]	  =(ZoneName=abdomen, BoneName=Hips,   Limb=BP_Torso, GoreHealth=150, DmgScale=0.5, SkinID=3)  //0.5

	WeakSpotSocketNames.Empty;	// Ignore the head
	WeakSpotSocketNames.Add(Head_Attach); // Neck

	// ---------------------------------------------
	// Movement / Physics
	GroundSpeed=200.0f
	SprintSpeed=275.0f //200.00
	PhysRagdollImpulseScale=0.5f
	KnockdownImpulseScale=0.5f

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedSiren'
	DamageRecoveryTimeHeavy=0.75f
	DamageRecoveryTimeMedium=1.0f

	RotationRate=(Pitch=50000,Yaw=20000,Roll=50000)

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Siren';
`endif
	
	OnDeathAchievementID=KFACHID_DeadSilence

	ZEDCowboyHatAttachName=Hat_Attach
}
