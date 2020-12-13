//=============================================================================
// KFCharacterInfo_ScriptedPawn
//=============================================================================
// Character info for scripted pawns
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFCharacterInfo_ScriptedPawn extends KFCharacterInfoBase;

enum FXTransitionType
{
	/** Always play regardless of the previous state */
	FXTransitionType_PlayAlways,
	/** In EnterState FROM a greater numbered state or in ExitState TO a greater numbered state */
	FXTransitionType_PlayGreaterStateTransition,
	/** In EnterState FROM a lower numbered state or in ExitState TO a lower numbered state */
	FXTransitionType_PlayLesserStateTransition
};

struct ScriptedPawnStateFX
{
	/** Particles to play */
	var() ParticleSystem VFX;
	/** Sound event to play */
	var() AkEvent SFX;
	/** Socket to attach particles or sounds to, if desired (otherwise plays at root) */
	var() name SocketName;
	/** Whether to play this FX based on the previous state 
		FXTransitionType_PlayAlways - Always play regardless of the previous state 
		FXTransitionType_PlayGreaterStateTransition - In EnterState FROM a greater (health) state or in ExitState TO a greater (health) state 
		FXTransitionType_PlayLesserStateTransition - In EnterState FROM a lower (health) state or in ExitState TO a lower (health) state */
	var() FXTransitionType TransitionType;
};

struct ScriptedPawnStateInfo
{
	// Percentage of health at which to activate this state
	var() float HealthPctThreshold<ClampMin=0.0 | ClampMax=1.0>;
	// How much to scale the speed by for this state
	var() float SpeedScalar<ClampMin=0.0 | ClampMax=1.0>;
	// Whether the pawn can be targeted by zeds in this state
	var() bool bCanBeTargetedByZeds;
	// FX to play upon entering state
	var() array<ScriptedPawnStateFX> EnterFX;
	// FX to play upon exiting state
	var() array<ScriptedPawnStateFX> ExitFX;
	// Anim to play upon entering state
	var() name EnterAnim;
	// Anim to play upon exiting state
	var() name ExitAnim;
	// Icon that represents this state and gets displayed above pawn
	var() Texture2D Icon;
	// Material for this state, None will set to default material
	var() MaterialInstance DefaultStateMaterial;
	// Material for this state when highlighted, Non will set to default StateMaterial
	var() MaterialInstance HighlightedStateMaterial;
	// Color of the scripted pawn health bar during this state
	var() Color PawnHealthBarColor;

	structdefaultproperties
	{
		HealthPctThreshold=1.0
		SpeedScalar=1.0
		bCanBeTargetedByZeds=true
	}
};

var() array<ScriptedPawnStateInfo> States;

// events to play when the scripted pawn reaches the finish (including stop events)
var() array<AkEvent> FinishSoundEvents;

// How fast the pawn should move
var() float PawnSpeed;
// Whether pawn should fly or walk
var() bool bIsFlyingPawn;
// Whether pawn can be bumped or pushed
var() bool bPawnHandlesMomentum;
// How hard pawn bumps other pawns
var() float PawnBumpImpulse;
// Whether pawn can be grabbed by zeds
var() bool bPawnCanBeGrabbed;
// Whether to enable weldable options below
var() bool bEnableWeldOptions;
// Whether pawn can be welded
var() bool bPawnCanBeWelded<EditCondition=bEnableWeldOptions>;
// Whether pawn can be unwelded
var() bool bPawnCanBeUnwelded<EditCondition=bEnableWeldOptions>;
// How much pawn can be welded
var() float PawnMaxWeldIntegrityPerPlayer[6]<EditCondition=bEnableWeldOptions>;
// How much to scale the pawn's weldable collision component (default radius is 1m/100uu)
var() float PawnWeldableComponentScale<EditCondition=bEnableWeldOptions>;
// Whether pawn can be healed
var() bool bPawnCanBeHealed;
// Whether the pawn can die and be cleaned-up in code when health reaches zero
var() bool bPawnCanBeKilled;
// Whether proximity options are enabled
var() bool bEnableProximityOptions;
// How much to scale the pawn's proximity trigger for zeds (default radius is 1m/100uu)
var() float ZedProximityTriggerScale<EditCondition=bEnableProximityOptions>;
// How much to scale the pawn's proximity trigger for players (default radius is 1m/100uu)
var() float PlayerProximityTriggerScale<EditCondition=bEnableProximityOptions>;
// Whether pawn/zed behavior changes when zeds are close
var() bool bUseZedProximityTrigger<EditCondition=bEnableProximityOptions>;
// How pawn's speed should scale when zeds are close
var() float SpeedScalarForZedProximity<EditCondition=bUseZedProximityTrigger>;
// Whether pawn/player behavior changes when players are close
var() bool bUsePlayerProximityTrigger<EditCondition=bEnableProximityOptions>;
// How pawn's speed should scale when players are close
var() float SpeedScalarForPlayerProximity<EditCondition=bUsePlayerProximityTrigger>;
// Whether the pawn should remove collision when reaching the goal and then become hidden when finished
var() bool bHideOnFinish;
// Whether pawn should have no collision until it hits the start point
var() bool bDisableCollisionOnStart;

/** Character mesh to use */
var(ThirdPerson) SkeletalMesh CharacterMesh<DisplayName=Body Mesh>;
/** Aggressively optimized mesh for the server with minimal bones */
var(Server) SkeletalMesh ServerMesh;

/** Sets the pawns character mesh from it's CharacterInfo, and updates instance of player in map if there is one. */
simulated function SetCharacterMeshFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI )
{
	super.SetCharacterMeshFromArch( KFP, KFPRI );

	if( CharacterMesh != none )
	{
        // Assign the body mesh to the pawn
		if ( KFP.WorldInfo.NetMode == NM_DedicatedServer && ServerMesh != None )
		{
			KFP.Mesh.SetSkeletalMesh(ServerMesh);
		}
		else
		{
			KFP.Mesh.SetSkeletalMesh(CharacterMesh);
		}
		KFP.Mesh.SetScale(DefaultMeshScale);
        KFP.PitchAudio(DefaultMeshScale);
	}
}

defaultproperties
{
	PawnSpeed=150
	PawnBumpImpulse=100
	PawnWeldableComponentScale=2.f
	PawnMaxWeldIntegrityPerPlayer(0)=1500
	PawnMaxWeldIntegrityPerPlayer(1)=1500
	PawnMaxWeldIntegrityPerPlayer(2)=1500
	PawnMaxWeldIntegrityPerPlayer(3)=1500
	PawnMaxWeldIntegrityPerPlayer(4)=1500
	PawnMaxWeldIntegrityPerPlayer(5)=1500

	ZedProximityTriggerScale=2.f
	PlayerProximityTriggerScale=2.f
	SpeedScalarForZedProximity=1.f
	SpeedScalarForPlayerProximity=1.f

	bHideOnFinish=true
	bDisableCollisionOnStart=true
}