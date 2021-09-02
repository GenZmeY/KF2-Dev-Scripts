//=============================================================================
// KFPawn_ZedFleshpound
//=============================================================================
// Fleshpound pawn class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedFleshpound extends KFPawn_Monster;

/** Sounds */
var AkComponent RageAkComponent;
var AkEvent RageLoopSound;
var AkEvent RageStopSound;
var bool bPlayingRageSound;

/** Material parameters for rage light glow */
var LinearColor DefaultGlowColor;
var LinearColor EnragedGlowColor;
var() LinearColor DeadGlowColor;

var class<KFDamageType> RageBumpDamageType;

// Rage lights :)
var name BattlePhaseLightFrontSocketName;
var transient PointLightComponent BattlePhaseLightTemplateYellow;
var transient PointLightComponent BattlePhaseLightTemplateRed;
var transient PointLightComponent BattlePhaseLightFront;

/** Footstep camera shake */
var protected const float FootstepCameraShakePitchAmplitude;
var protected const float FootstepCameraShakeRollAmplitude;

/*********************************************************************************************
* Initialization
********************************************************************************************* */

/** TEMP [See when this was added in sourcecontrol] */
simulated event PreBeginPlay()
{
	Super.PreBeginPlay();

	if( WorldInfo.NetMode != NM_DedicatedServer && Mesh != None )
	{
		UpdateGameplayMICParams();
	}
}

/**
 * Check on various replicated data and act accordingly.
 */
simulated event ReplicatedEvent(name VarName)
{
	switch( VarName )
	{
	case nameof(bIsEnraged):
		SetEnraged(bIsEnraged);
		break;
	}

	Super.ReplicatedEvent(VarName);
}

/*********************************************************************************************
* Notifications
********************************************************************************************* */

/** Interrupt certain moves when bEmpDisrupted is set */
function OnStackingAfflictionChanged(byte Id)
{
	local KFAIController_ZedFleshpound FpAIC;

	Super.OnStackingAfflictionChanged(Id);

	if( bEmpDisrupted && MyKFAIC != none && IsAliveAndWell() )
	{
		if( IsDoingSpecialMove(SM_Taunt) )
		{
			EndSpecialMove( SM_Taunt );
		}

		FpAIC = KFAIController_ZedFleshpound(MyKFAIC);
		if ( FpAIC != None && FpAIC.RagePlugin != none )
		{
			FpAIC.RagePlugin.EndRage();
		}
	}
}

/*********************************************************************************************
* Movement
********************************************************************************************* */

/** No FP steering initially */
simulated function StartSteering() {}

/** Don't start sprinting if not enraged */
function SetSprinting( bool bNewSprintStatus )
{
	// Don't start sprinting if not enraged
	if( bNewSprintStatus && !IsEnraged() && (MyKFAIC == none || !MyKFAIC.bHasDebugCommand) )
	{
		return;
	}

	Super.SetSprinting( bNewSprintStatus );
}

/** Overridden to cause slight camera shakes when walking. */
simulated event PlayFootStepSound(int FootDown)
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( IsHumanControlled() && IsLocallyControlled() )
		{
			FootstepCameraShake.RotOscillation.Pitch.Amplitude = 0;
			FootstepCameraShake.RotOscillation.Roll.Amplitude = 0;
		}
		else
		{
			FootstepCameraShake.RotOscillation.Pitch.Amplitude = FootstepCameraShakePitchAmplitude;
			FootstepCameraShake.RotOscillation.Roll.Amplitude = FootstepCameraShakeRollAmplitude;
			FootstepCameraShakeInnerRadius = default.FootstepCameraShakeInnerRadius;
			FootstepCameraShakeOuterRadius = default.FootstepCameraShakeOuterRadius;
			if( !bIsSprinting || VSizeSQ(Velocity) < 10000.f )
			{
				FootstepCameraShake.RotOscillation.Pitch.Amplitude *= 0.75f;
				FootstepCameraShake.RotOscillation.Roll.Amplitude *= 0.75f;
			}
		}
	}

	super.PlayFootStepSound( FootDown );
}

/*********************************************************************************************
* Rage Related
********************************************************************************************* */

/** Called on server when pawn should have been crippled (e.g. Headless) */
function CauseHeadTrauma( float BleedOutTime=5.f )
{
	super.CauseHeadTrauma( BleedOutTime );

	// End rage when decapped
	SetEnraged( false );
}

/** Returns TRUE if this zed can block attacks */
function bool CanBlock()
{
	return !IsEnraged() && super.CanBlock();
}

/** Turns off FX and sounds */
simulated function TerminateEffectsOnDeath()
{
	StopRageSound();
    UpdateBattlePhaseLights();
    super.TerminateEffectsOnDeath();
}

/** Updates dynamic lights based on rage status */
simulated function UpdateBattlePhaseLights()
{
    local PointLightComponent LightTemplate;

    if( BattlePhaseLightFront != none )
    {
        BattlePhaseLightFront.DetachFromAny();
        BattlePhaseLightFront = none;
    }

    if( IsAliveAndWell() )
    {
        if( bIsEnraged )
        {
            LightTemplate = BattlePhaseLightTemplateRed;
        }
        else
        {
            LightTemplate = BattlePhaseLightTemplateYellow;
        }

        if( LightTemplate != none )
        {
    	    BattlePhaseLightFront = new(self) Class'PointLightComponent' (LightTemplate);
    	}

        if( BattlePhaseLightFront != none )
        {
            Mesh.AttachComponentToSocket(BattlePhaseLightFront, BattlePhaseLightFrontSocketName);
            BattlePhaseLightFront.SetEnabled( true );
        }
    }
}

/** Called by PawnAnimInfo when determining whether an attack with bSpecializedMode TRUE can be performed. This makes the
	FleshPound use attacks from his PawnAnimInfo that are configured as "specialized" only if he's enraged. */
function bool ShouldPlaySpecialMeleeAnims()
{
	return IsEnraged();
}

/** Return current rage status */
simulated event bool IsEnraged()
{
	return bIsEnraged;
}

/** Enrage this FleshPound! */
simulated function bool SetEnraged( bool bNewEnraged )
{
	local bool bSuccess;

	bSuccess = super.SetEnraged(bNewEnraged);
	if (bSuccess)
	{
		if ( WorldInfo.NetMode != NM_DedicatedServer )
		{
			/** Set the proper glow material */
			UpdateGameplayMICParams();
		}
	}

	return bSuccess;
}

/** Handle GlowColor MIC Param */
simulated function UpdateGameplayMICParams()
{
    super.UpdateGameplayMICParams();

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		UpdateBattlePhaseLights();

        if( !IsAliveAndWell() )
        {
            SetGlowColors(DeadGlowColor);
        }
        else
        {
    		if ( bIsEnraged )
    		{
                SetGlowColors(EnragedGlowColor);
    		}
    		else
    		{
                SetGlowColors(DefaultGlowColor);
    		}
		}
	}
}

simulated function SetGlowColors(LinearColor GlowColor)
{
    local MaterialInstanceConstant MIC;
    local int Idx;

    MIC = CharacterMICs[0];

    //Update base mesh
    if (MIC != none)
    {
        MIC.SetVectorParameterValue('Vector_GlowColor', GlowColor);
    }

    //Update any PAC MICs (See King/Mini Fleshpound)
    for (Idx = 0; Idx < `MAX_COSMETIC_ATTACHMENTS; ++Idx)
    {
        if (ThirdPersonAttachments[Idx] != none)
        {
            MIC = MaterialInstanceConstant(ThirdPersonAttachments[Idx].GetMaterial(0));
            if (MIC != none)
            {
                MIC.SetVectorParameterValue('Vector_GlowColor', GlowColor);
            }
        }
    }
}

/** Stops the rage sound with an akevent */
simulated function StopRageSound()
{
	if(bPlayingRageSound && RageAkComponent.IsPlaying(RageLoopSound) )
	{
		RageAkComponent.PlayEvent( RageStopSound, true, true );
		bPlayingRageSound = false;
	}
}

/* PlayDying() is called on server/standalone game when killed
and also on net client when pawn gets bTearOff set to true (and bPlayedDeath is false)
*/
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	Super.PlayDying(DamageType, HitLoc);

	// Turn off lights on death
	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		SetEnraged( false );
	}
}

function class<KFDamageType> GetBumpAttackDamageType()
{
	return RageBumpDamageType;
}

/**
 * Used to adjust strength of all incoming afflictions (similar to AdjustDamage)
 * based on current situation / state.
 */
simulated function AdjustAffliction(out float AfflictionPower)
{
	if ( bIsEnraged )
	{
		AfflictionPower *= 0.25f;
	}
}

/** Track the fleshpound's speed and play the appropriate cues */
simulated event Tick( float DeltaTime )
{
	super.Tick( DeltaTime );

	if( WorldInfo.NetMode != NM_DedicatedServer && IsAliveAndWell() )
	{
		if( bIsSprinting && IsEnraged() && Physics == PHYS_Walking && Mesh.RootMotionMode == RMM_Ignore && VSizeSQ(Velocity) > 40000.f )
		{
			if( !RageAkComponent.IsPlaying(RageLoopSound) )
			{
				RageAkComponent.PlayEvent( RageLoopSound, true, true );
				bPlayingRageSound = true;
			}
		}
		else
		{
			StopRageSound();
		}
	}
}

/*********************************************************************************************
* Debugging
**********************************************************************************************/

/** Render some Fleshpound specific debug text over his head */
simulated function GetOverheadDebugText( KFHUDBase HUD, out array<string> OverheadTexts, out array<Color> OverheadColors )
{
	local string DebugText;
	local float RedScalar,  Scalar;
	local color ModifyTextColor;

    if( HUD.ShouldDisplayDebug('All') || HUD.ShouldDisplayDebug('AISpecial') )
    {
    	if( !bIsEnraged )
    	{
    		Scalar = 1.f;// - FClamp( float(AccumulatedDOT) / float(default.HealthMax * RageThresholdPercentage), 0.f, 1.f );
    		RedScalar = FClamp( (1.f - Scalar) / 0.5f, 0.f, 1.f );
    		//GreenScalar = FClamp( (Scalar / 0.5f), 0.f, 1.f );

    		ModifyTextColor.R = FloatToByte( RedScalar );
    		ModifyTextColor.B = 0;
    		ModifyTextColor.G = FloatToByte( Scalar );
    		ModifyTextColor.A = 255;
    		//DebugText = DebugText$"AccumulatedDOT: "$AccumulatedDOT$" Sprinting: "$bIsSprinting;
    	}
    	else
    	{
    		ModifyTextColor.R = 255;
    		ModifyTextColor.G = 0;
    		ModifyTextColor.B = 0;
    		ModifyTextColor.A = 255;
    		DebugText = "ENRAGED!!!";
    		if( IsDoingSpecialMove() )
    		{
    			DebugText = DebugText$" SPECIALMOVE: "$SpecialMove$"\n";
    		}
    		if( MyKFAIC.GetActiveCommand() != none )
    		{
    			DebugText = DebugText$" COMMAND "$MyKFAIC.GetActiveCommand()$"\nSTATE: "$MyKFAIC.GetActiveCommand().GetStateName();
    		}
    	}
	}

	Super.GetOverheadDebugText( HUD, OverheadTexts, OverheadColors );
	OverheadTexts[OverheadTexts.Length] = DebugText;
	OverheadColors[OverheadTexts.Length - 1] = ModifyTextColor;
}

/*********************************************************************************************
* Dialog
**********************************************************************************************/

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	return 130;//SPOTZ_Fleshpound
}

/** Returns (hardcoded) dialog event ID for when trader gives advice to player who was killed by this zed type */
static function int GetTraderAdviceID()
{
	return 43;//TRAD_AdviceFleshpound
}

DefaultProperties
{
	LocalizationKey=KFPawn_ZedFleshpound
	bLargeZed=true

	Begin Object Name=KFPawnSkeletalMeshComponent
		// Enabling kinematic for physics interaction while alive.  (see also MinDistFactorForKinematicUpdate)
		bUpdateKinematicBonesFromAnimation=true
		// Beam weapons (microwave gun, flamey things, etc.) won't hit his head without this
		BlockNonZeroExtent=true
End Object

	// ---------------------------------------------
	// Stats
	XPValues(0)=35
	XPValues(1)=47
	XPValues(2)=63
	XPValues(3)=72

	bIsFleshpoundClass=true

	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_Fleshpound_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Fleshpound_ANIM.Fleshpound_AnimGroup'
	DifficultySettings=class'KFDifficulty_Fleshpound'

	EnragedGlowColor=(R=1,G=0)
	//DebugRange_Melee_Material=Material'ENG_EditorResources_MAT.Debug_Radius_M'
	DefaultGlowColor=(R=1,G=0.35f)
	DeadGlowColor=(R=0.0f,G=0.0f)

	// ---------------------------------------------
	// Gameplay
	bCanRage=true
	bCanMeleeAttack=true
	ZedBumpDamageScale=0.f
	RageBumpDamageType=class'KFGameContent.KFDT_HeavyZedBump'

	Begin Object Name=MeleeHelper_0
		BaseDamage=55.f
		MaxHitRange=250.f
	    MomentumTransfer=55000.f
		MyDamageType=class'KFDT_Bludgeon_Fleshpound'
	End Object

	Health=1500
	Mass=200.f

	// Penetration
    PenetrationResistance=5.0

    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.75)))  //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.5))) //0.3
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.6))) //0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.3)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(1.0)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(1.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.75)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.25)))
    //DamageTypeModifiers.Add((DamageType=class'KFDamageType', 	DamageScale=(0.5))) // All others

    //special case
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_MicrowaveRifle',   DamageScale=(0.8)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGTeslauncherDoT',     DamageScale=(0.5)))

	// ---------------------------------------------
	// Block Settings
	MinBlockFOV=0.1f

	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
	HeadlessBleedOutTime=7.f
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=650, DmgScale=1.1, SkinID=1)
	HitZones[3]       =(ZoneName=heart,	   BoneName=Spine1,		  Limb=BP_Special,  GoreHealth=150, DmgScale=1.1, SkinID=2)
	HitZones[5]		  =(ZoneName=lforearm, BoneName=LeftForearm,  Limb=BP_LeftArm,  GoreHealth=20,  DmgScale=0.2, SkinID=3)
	HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20,  DmgScale=0.2, SkinID=3)

	WeakSpotSocketNames.Add(WeakPointSocket1) // Chest

	DoshValue=200

	// ---------------------------------------------
	// Movement Physics
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0055.000000
	End Object

	GroundSpeed=260.f
	SprintSpeed=725.f     //600
	ReachedEnemyThresholdScale=1.f
	//ReachedGoalThresholdOverride=127.5f
	//bCollideAsEncroacher=true
	PhysRagdollImpulseScale=1.5f
	KnockdownImpulseScale=2.0f

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedFleshpound'
	BumpDamageType=class'KFDT_NPCBump_Large'
	BumpFrequency=0.1
	DamageRecoveryTimeHeavy=0.85f   //0.25f   melee hits
	DamageRecoveryTimeMedium=0.85   //0.09f  gunhits

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Taunt)=class'KFGame.KFSM_Zed_Taunt'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Block)=class'KFSM_Block'
	End Object
	RotationRate=(Pitch=50000,Yaw=40000,Roll=50000)

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(0.5, 0.55, 0.5, 0.0, 0.55),   Cooldown=10.0, Duration=1.55) //1.2
	IncapSettings(AF_Knockdown)=(Vulnerability=(0.25, 0.25, 0.5, 0.25, 0.4),  Cooldown=10.0)  //leg 0.25
	IncapSettings(AF_Stumble)=	(Vulnerability=(0.2, 0.25, 0.25, 0.0, 0.4),   Cooldown=5.0)
	IncapSettings(AF_GunHit)=	(Vulnerability=(0.0, 0.0, 0.0, 0.0, 0.5),     Cooldown=1.7)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(1.0),                         Cooldown=1.2)
	IncapSettings(AF_Poison)=	(Vulnerability=(0.15),	                      Cooldown=20.5, Duration=5.0)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                         Cooldown=17.0, Duration=2.5)
	IncapSettings(AF_FirePanic)=(Vulnerability=(0.4),                         Cooldown=10.0, Duration=3.5)
	IncapSettings(AF_EMP)=		(Vulnerability=(0.95),                        Cooldown=10.0, ChildAfflictionCooldown=10.0, Duration=2.2)
	IncapSettings(AF_Freeze)=	(Vulnerability=(0.95),                        Cooldown=10.5,  Duration=1.0)
	IncapSettings(AF_Snare)=	(Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0),     Cooldown=8.5,  Duration=5.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.75)) //0.25

	Begin Object Name=Afflictions_0
		FireFullyCharredDuration=5
		AfflictionClasses(AF_EMP)=class'KFAffliction_EMPDisrupt'
	End Object

	ParryResistance=4

    // ---------------------------------------------
    // sounds
	RageLoopSound=AkEvent'ww_zed_fleshpound_2.Play_FleshPound_Rage_Start'
	RageStopSound=AkEvent'ww_zed_fleshpound_2.Play_FleshPound_Rage_Stop'
	Begin Object Class=AkComponent name=RageAkComponent0
		BoneName=dummy
		bStopWhenOwnerDestroyed=true
		bForceOcclusionUpdateInterval=true
		OcclusionUpdateInterval=0.2f
	End Object
    RageAkComponent=RageAkComponent0
    Components.Add( RageAkComponent0 )

    // ---------------------------------------------
    // effects
	Begin Object Class=CameraShake Name=FootstepCameraShake0
		bSingleInstance=true
		OscillationDuration=0.25f
		RotOscillation={(Pitch=(Amplitude=120.f,Frequency=60.f),Roll=(Amplitude=60.f,Frequency=40.f))}
	End Object
	FootstepCameraShake=FootstepCameraShake0
	FootstepCameraShakePitchAmplitude=120.f
	FootstepCameraShakeRollAmplitude=60.f
	FootstepCameraShakeInnerRadius=200
	FootstepCameraShakeOuterRadius=900
//	bMarkExtraEndpoints=true

    // ---------------------------------------------
    // enraged lights
    Begin Object Class=PointLightComponent Name=PointLightComponent1
        Brightness=1.f
        Radius=128.f
        FalloffExponent=4.f
        LightColor=(R=250,G=200,B=25,A=255)//(R=231,G=215,B=161,A=255)
        CastShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    BattlePhaseLightTemplateYellow=PointLightComponent1

    Begin Object Class=PointLightComponent Name=PointLightComponent2
        Brightness=1.f
        Radius=128.f
        FalloffExponent=4.f
        LightColor=(R=255,G=64,B=64,A=255)//(R=231,G=144,B=0,A=255)
        CastShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    BattlePhaseLightTemplateRed=PointLightComponent2

    BattlePhaseLightFrontSocketName=Light

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Fleshpound';
`endif

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Large

    OnDeathAchievementID=KFACHID_ItsOnlyAFleshWound

	ZEDCowboyHatAttachName=Hat_Attach
}