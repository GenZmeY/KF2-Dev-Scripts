//=============================================================================
// KFPawn_ZedStalker
//=============================================================================
// Stalker
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedStalker extends KFPawn_Monster;

var MaterialInstanceConstant SpottedMaterial;

var AkComponent CloakedAkComponent;
var AkEvent CloakedLoop;
var AkEvent CloakedLoopEnd;

var float CloakPercent;

/** The local player controller viewing this pawn */
var KFPlayerController ViewerPlayer;

/** Cloak speeds */
var float CloakSpeed;
var float DeCloakSpeed;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	SetCloaked( true );
	PlayStealthSoundLoop();
}

/**
* Check on various replicated data and act accordingly.
*/
simulated event ReplicatedEvent(name VarName)
{
	switch( VarName )
	{
	case nameof(bIsCloakingSpottedByTeam):
		UpdateGameplayMICParams();
		break;
	case nameof(bIsCloaking):
		ClientCloakingStateUpdated();
		break;
	}

	Super.ReplicatedEvent(VarName);
}

/** Toggle cloaking material */
function SetCloaked(bool bNewCloaking)
{
	if ( bCanCloak )
	{
		if( bNewCloaking && !IsCombatCapable() )
		{
			return;
		}

		if( MaxHeadChunkGoreWhileAlive == 0 && bIsCloaking != bNewCloaking && IsAliveAndWell() )
		{
			`DialogManager.PlaySpotCloakDialog( self, bNewCloaking );
		}

		bIsCloaking = bNewCloaking;

		if( WorldInfo.NetMode != NM_DedicatedServer )
		{
			UpdateGameplayMICParams();
			Mesh.SetPerObjectShadows(!bNewCloaking);
			ClearBloodDecals();
		}

		super.SetCloaked( bNewCloaking );
	}
}

/**
 * bIsCloaking replicated state changed
 * Network: Local and Remote Clients
 */
simulated function ClientCloakingStateUpdated()
{
	if( bIsCloaking )
	{
		ClearBloodDecals();
	}

	UpdateGameplayMICParams();
	Mesh.SetPerObjectShadows( !bIsCloaking );
}

/** Handle cloaking materials */
simulated function UpdateGameplayMICParams()
{
	local bool bIsSpotted;

	super.UpdateGameplayMICParams();

	// Cannot cloak after stalker has been gored
	if ( !bIsGoreMesh && WorldInfo.NetMode != NM_DedicatedServer )
	{
		// visible by local player or team (must go after ServerCallOutCloaking)
		bIsSpotted = (bIsCloakingSpottedByLP || bIsCloakingSpottedByTeam);

		if ( bIsSpotted && bIsCloaking )
		{
			CharacterMICs[0].SetParent(SpottedMaterial);
		}
		else if( CharacterMICs[0].Parent == SpottedMaterial )
		{
			CharacterMICs[0].SetParent(Mesh.SkeletalMesh.Materials[0]);
			PlayStealthSoundLoop();
		}
	}
}

/** Called when SwitchToGoreLOD is successful */
simulated event NotifyGoreMeshActive()
{
	super.NotifyGoreMeshActive();

	`DialogManager.PlaySpotCloakDialog( self, false );

	PlayStealthSoundLoopEnd();

	// Restore to uncloaked values
	bIsCloaking = false;
	bIsCloakingSpottedByLP = false;
	bIsCloakingSpottedByTeam = false;

	// Set to our solid gore mat (only AI-controlled)
	if( PlayerReplicationInfo == none && Mesh.SkeletalMesh.Materials.Length > 2 )
	{
		CharacterMICs[0].SetParent( Mesh.SkeletalMesh.Materials[2] );
	}
}

/** Turns off FX and sounds */
simulated function TerminateEffectsOnDeath()
{
	PlayStealthSoundLoopEnd();
    super.TerminateEffectsOnDeath();
}

simulated function PlayStealthSoundLoop()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && !CloakedAkComponent.IsPlaying(CloakedLoop) )
	{
		CloakedAkComponent.PlayEvent( CloakedLoop, true, true );
	}
}

simulated function PlayStealthSoundLoopEnd()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && CloakedAkComponent.IsPlaying(CloakedLoop) )
	{
		CloakedAkComponent.PlayEvent( CloakedLoopEnd, true, true );
	}
}

/** Overridden to support transparency scalar */
simulated event Tick( float DeltaTime )
{
	local float MinCloakPct;

	super.Tick( DeltaTime );

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( ViewerPlayer == none )
		{
			ViewerPlayer = KFPlayerController( GetALocalPlayerController() );
		}

		MinCloakPct = GetMinCloakPct();

		if( !bIsCloaking )
		{
			if( CloakPercent < 1.0f )
			{
				CloakPercent = fMin( CloakPercent + DeltaTime*DeCloakSpeed, 1.0f );
				CharacterMICs[0].SetScalarParameterValue( 'Transparency', CloakPercent );
			}
		}
		else if( CloakPercent > MinCloakPct )
		{
			CloakPercent = fMax( CloakPercent - DeltaTime*CloakSpeed, MinCloakPct );
			CharacterMICs[0].SetScalarParameterValue( 'Transparency', CloakPercent );
		}
	}
}


/** Gets the minimum cloaked amount based on the viewer */
simulated protected function float GetMinCloakPct()
{
	if( ViewerPlayer != none && (ViewerPlayer.GetTeamNum() == GetTeamNum() || ViewerPlayer.PlayerReplicationInfo.bOnlySpectator) )
	{
		return 0.5f;
	}

	return 0.f;
}

/*********************************************************************************************
`* Perk related
********************************************************************************************* */

/**
 * Called every 0.5f seconds to check if a cloaked zed has been spotted
 * Network: All but dedicated server
 */
simulated event UpdateSpottedStatus()
{
	local bool bOldSpottedByLP;
	local KFPerk LocalPerk;
	local float DistanceSq, Range;

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	bOldSpottedByLP = bIsCloakingSpottedByLP;
	bIsCloakingSpottedByLP = false;

    if( !IsHumanControlled() || bIsSprinting )
    {
    	if( ViewerPlayer == none )
    	{
    		ViewerPlayer = KFPlayerController( GetALocalPlayerController() );
		}

		if( ViewerPlayer != none )
		{
			LocalPerk = ViewerPlayer.GetPerk();
		}

		if ( ViewerPlayer != none && ViewerPlayer.Pawn != None && ViewerPlayer.Pawn.IsAliveAndWell() && LocalPerk != none &&
			 LocalPerk.bCanSeeCloakedZeds && `TimeSince( LastRenderTime ) < 1.f )
		{
			DistanceSq = VSizeSq(ViewerPlayer.Pawn.Location - Location);
			Range = LocalPerk.GetCloakDetectionRange();

			if ( DistanceSq < Square(Range) )
			{
				bIsCloakingSpottedByLP = true;
				if ( LocalPerk.IsCallOutActive() )
				{
					// Beware of server spam.  This RPC is marked unreliable and UpdateSpottedStatus has it's own cooldown timer
					ViewerPlayer.ServerCallOutPawnCloaking(self);
				}
			}
		}
	}

	// If spotted by team already, there is no point in trying to update the MIC here
	if ( !bIsCloakingSpottedByTeam )
	{
		if ( bIsCloakingSpottedByLP != bOldSpottedByLP )
		{
			UpdateGameplayMICParams();
		}
	}
}

/** notification from player with CallOut ability */
function CallOutCloaking( optional KFPlayerController CallOutController )
{
	bIsCloakingSpottedByTeam = true;
	LastStoredCC = CallOutController;
	UpdateGameplayMICParams();
	SetTimer(2.f, false, nameof(CallOutCloakingExpired));
}

/** Call-out cloaking ability has timed out */
function CallOutCloakingExpired()
{
	bIsCloakingSpottedByTeam = false;
	LastStoredCC = none;
	UpdateGameplayMICParams();
}

/** Applies the rally buff and spawns a rally effect */
simulated function bool Rally(
							KFPawn 			RallyInstigator,
							ParticleSystem 	RallyEffect,
							name 			EffectBoneName,
							vector			EffectOffset,
							ParticleSystem	AltRallyEffect,
							name 			AltEffectBoneNames[2],
							vector 			AltEffectOffset,
							optional bool	bSkipEffects=false
						)
{
	local PlayerController PC;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PC = WorldInfo.GetALocalPlayerController();

		// Don't spawn rally effects if cloaking but not spotted
		if( bIsCloaking
			&& !bIsCloakingSpottedByLP
			&& !bIsCloakingSpottedByTeam
			&& PC.GetTeamNum() < 255
			&& PC.Pawn != none
			&& PC.Pawn.IsAliveAndWell() )
		{
			bSkipEffects = true;
		}
	}

	return super.Rally( RallyInstigator, RallyEffect, EffectBoneName, EffectOffset, AltRallyEffect, AltEffectBoneNames, AltEffectOffset, bSkipEffects );
}

/* PlayDying() is called on server/standalone game when killed
and also on net client when pawn gets bTearOff set to true (and bPlayedDeath is false)
*/
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	// Uncloak on death
	SetCloaked(false);
	bCanCloak = false;

	Super.PlayDying(DamageType, HitLoc);
}

/** Disable cloaking when crippled/headless */
function CauseHeadTrauma( float BleedOutTime=5.f )
{
	Super.CauseHeadTrauma( BleedOutTime );

	if( bIsHeadless && IsAliveAndWell() && !IsDoingSpecialMove() )
	{
		SetCloaked( false );
	}
}

/** Interrupt certain moves when bEmpDisrupted is set */
function OnStackingAfflictionChanged(byte Id)
{
	Super.OnStackingAfflictionChanged(Id);

	if( Role == ROLE_Authority && IsAliveAndWell() )
	{
		if ( Id == AF_EMP )
		{
			SetCloaked( !bEMPPanicked && !bEMPDisrupted );
		}
	}
}

function PlayHit( float Damage, Controller InstigatedBy, vector HitLocation, class<DamageType> damageType, vector Momentum, TraceHitInfo HitInfo )
{
 	super.PlayHit( Damage, InstigatedBy, HitLocation, damageType, Momentum, HitInfo );

	SetCloaked( false );

	// SetTimer times are max values pulled from KFPawnAnimInfo::PlayHitReactionAnim

	// if last hit caused call to DoPauseAI
	if( HitFxInfo.DamageType != none && HitFxInfo.DamageType.default.MeleeHitPower > 0 )
	{
		SetTimer( 1.f, false, nameof(ReCloakTimer) );
	}
	else // light hit or DOT
	{
		SetTimer( 0.35f, false, nameof(ReCloakTimer) );
	}
}

simulated function PlayHeadAsplode()
{
	if( bIsCloaking )
	{
		SetCloaked( false );
	}

	bCanCloak = false;

	super.PlayHeadAsplode();
}

simulated function ReCloakTimer()
{
	SetCloaked( true );
}

static function bool IsStalkerPawn()
{
	return true;
}

/** Returns (hardcoded) dialog event ID for when players kills this zed type */
function int GetKillerDialogID()
{
	return 66;//KILL_Female
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	if( bIsCloaking && MaxHeadChunkGoreWhileAlive == 0 )
    {
        return 135;//SPOTZ_Cloaked
    }

	return 125;//SPOTZ_Generic
}

/** Returns (hardcoded) dialog event ID for when trader gives advice to player who was killed by this zed type */
static function int GetTraderAdviceID()
{
	return 40;//TRAD_AdviceStalker
}

DefaultProperties
{
	LocalizationKey=KFPawn_ZedStalker
	Begin Object Name=KFPawnSkeletalMeshComponent
		// Enabling for bAlwaysFullAnimWeight bones
		bUpdateKinematicBonesFromAnimation=true
		// Shadows off at spawn since she spawns cloaked
		bAllowPerObjectShadows=false
	End Object

	// ---------------------------------------------
	// Stats
	XPValues(0)=8
	XPValues(1)=10
	XPValues(2)=10
	XPValues(3)=10

	// ---------------------------------------------
	// Content
    MonsterArchPath="ZED_ARCH.ZED_Stalker_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Stalker_ANIM.Stalker_AnimGroup'
	DifficultySettings=class'KFDifficulty_Stalker'

	SpottedMaterial=MaterialInstanceConstant'ZED_Stalker_MAT.ZED_Stalker_Visible_MAT'

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Evade)				=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)			=class'KFSM_Evade_Fear'
		SpecialMoveClasses(SM_Emerge)				=class'KFSM_Emerge'
	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(2.0, 2.0, 1.0, 1.0), Cooldown=5.0, Duration=3.0)
	IncapSettings(AF_Knockdown)=(Vulnerability=(1.5),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(1.f),                     Cooldown=0.5)
	IncapSettings(AF_GunHit)=	(Vulnerability=(0.75),                    Cooldown=0.0)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(2.0),                     Cooldown=0.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(3),                       Cooldown=3.0,  Duration=4.0)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Poison)=	(Vulnerability=(10.0),                    Cooldown=7.5,  Duration=5.5)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=20.5, Duration=5.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(2.5),                     Cooldown=1.5,  Duration=4.0)
	IncapSettings(AF_Snare)=	(Vulnerability=(10.0, 10.0, 10.0, 10.0),  Cooldown=5.5,  Duration=4.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(2.0))

	ParryResistance=1

	// ---------------------------------------------
	// Gameplay
	bCanGrabAttack=false
	bCanMeleeAttack=true

	Begin Object Name=MeleeHelper_0
		BaseDamage=9.f
		MaxHitRange=180.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	Health=75
	DoshValue=15
	Mass=50.f

	bIsStalkerClass=true

	// ---------------------------------------------
	// Penetration
    PenetrationResistance=0.5

	// ---------------------------------------------
	// Resistance & Vulnerability
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.9))) //0.8
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.5))) //2.5
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.0)))  //0.7
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.0)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.85)))  //0.6
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.85))) //0.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.2)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive',            	    DamageScale=(0.75))) //0.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(1.0)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(1.0)))

    // ---------------------------------------------
	// Movement / Physics
	GroundSpeed=400.f
	SprintSpeed=500.f
	PhysRagdollImpulseScale=0.9f
	KnockdownImpulseScale=0.9f

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFAIController_ZedStalker'
	DamageRecoveryTimeHeavy=0.65f
	DamageRecoveryTimeMedium=1.0f
	ElitePawnClass.Add(class'KFPawn_ZedDAR_EMP')
	ElitePawnClass.Add(class'KFPawn_ZedDAR_Laser')
	ElitePawnClass.Add(class'KFPawn_ZedDAR_Rocket')

	RotationRate=(Pitch=50000,Yaw=45000,Roll=50000)

	// ---------------------------------------------
	// Cloaking
	bIsCloaking=true
	bCanCloak=true
	bCloakOnMeleeEnd=true
	CloakPercent=1.0f
	DeCloakSpeed=4.5f
	CloakSpeed=4.0f
	//CloakDuration=1.2

	// ---------------------------------------------
	// Audio
	CloakedLoop=AkEvent'WW_ZED_Stalker.ZED_Stalker_SFX_Stealth_LP'
	CloakedLoopEnd=AkEvent'WW_ZED_Stalker.ZED_Stalker_SFX_Stealth_LP_Stop'
	Begin Object Class=AkComponent name=CloakedAkComponent0
		BoneName=dummy
		bStopWhenOwnerDestroyed=true
		bForceOcclusionUpdateInterval=true
		OcclusionUpdateInterval=0.4f
	End Object
    CloakedAkComponent=CloakedAkComponent0
    Components.Add( CloakedAkComponent0 )

	ZEDCowboyHatAttachName=Hat_Attach

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Stalker';
`endif
}
