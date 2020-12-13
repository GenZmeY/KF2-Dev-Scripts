//=============================================================================
// KFPawn_Scripted
//=============================================================================
// Pawn for scripted characters
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFPawn_Scripted extends KFPawn
	native(Pawn)
	implements(KFInterface_TriggerOwner);

var localized string ScriptedPawnString;

// Character archetype for the pawn
var repnotify KFCharacterInfo_ScriptedPawn ScriptedCharArchTemplate;
var KFCharacterInfo_ScriptedPawn ScriptedCharArch;
var bool bCanCurrentlyBeTargetedByZeds;
var repnotify transient KFWeldableComponent WeldableComponent;
var repnotify transient KFWeldableTrigger WeldableTrigger;

var transient KFTrigger_NotifyOwner ZedProximityTrigger, PlayerProximityTrigger;
var transient bool bZedInProximity, bPlayerInProximity;

var repnotify byte CurrentState;
var byte PreviousState;

var transient repnotify bool bActive;
var transient bool bStartInactive;

var string IconPath;

var KFDoorActor BlockingDoor;
var float SpeedScalarForObstacles;

var array<ExtraVFXInfo> ScriptedStateVFX;

/** Amount of timer since last damage to consider "recent" in terms of UI messaging to the player*/
var float RecentDamageTimerLength;

/** Default material for this scripted pawn's mesh*/
var MaterialInterface DefaultMaterial;

/** Whether to block PCs */
var() bool bBlockPlayers<DisplayName = Block Human Players>;
/** Whether to block PC controlled zeds (team == 255) */
var() bool bBlockZedPlayers<DisplayName = Block Zed Players>;
/** Whether to block AI Zeds */
var() bool bBlockMonsters<DisplayName = Block AI>;
/** Whether to block anything when at zero health or marked dead */
var() bool bBlockInStoppedState<DisplayName = Block When In Stopped State>;
/** If the current scripted pawn state doesn't allow movement */
var bool bIsInStoppedState;

delegate Delegate_OnReachedRouteMarker(int MarkerIdx, SplineActor Marker, int SubIdx, float DistSinceLastMarker);
delegate Delegate_OnEndedRoute(bool bSuccess);
delegate Delegate_OnTakeDamage(int Damage);
delegate Delegate_OnHealDamage(int HealAmount);
delegate Delegate_OnChangeState(int CurrState, int PrevState);

replication
{
	if (bNetDirty)
		ScriptedCharArchTemplate, CurrentState, WeldableComponent, WeldableTrigger, bActive;
}

cpptext
{
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags);
	virtual UBOOL IgnoreBlockingBy(const AActor* Other) const;
	// also checks whether the pawn is active
	virtual UBOOL IsAliveAndWell() const;
}

simulated event ReplicatedEvent(name VarName)
{
	switch (VarName)
	{
	case nameof(ScriptedCharArchTemplate):
		SetCharacterArch(ScriptedCharArchTemplate, true);

		// attempts to initialize weldable component will fail before we get our archetype
		InitializeWeldableComponent();
		break;

	case nameof(WeldableComponent):
		InitializeWeldableComponent();
		break;

	case nameof(WeldableTrigger):
		InitializeWeldableTrigger();
		break;

	case nameof(CurrentState):
		SetPawnState(CurrentState);
		break;

	case nameof(bActive):
		SetActive(bActive);
		break;

	default:
		super.ReplicatedEvent(VarName);
		break;
	}
}

function Initialize(KFCharacterInfo_ScriptedPawn InCharInfo, int InHealth, int InHealthMax)
{
	local int i;

	if (Role < ROLE_Authority)
	{
		return;
	}

	SetCharacterArch(InCharInfo, true);

	if (ScriptedCharArch.bDisableCollisionOnStart)
	{
		SetCollision(false, false);
	}

	Health = Clamp(InHealth, 1, InHealthMax);
	HealthMax = InHealthMax;

	if (ScriptedCharArch.bPawnCanBeWelded || ScriptedCharArch.bPawnCanBeUnwelded)
	{
		InitializeWeldable();
	}

	// if pawn isn't allowed to die, then make sure any state set to a health percentage less than 1
	// gets set to something a little bit more than 1
	if (!ScriptedCharArch.bPawnCanBeKilled)
	{
		for (i = 0; i < ScriptedCharArch.States.Length; ++i)
		{
			ScriptedCharArch.States[i].HealthPctThreshold = FMax(ScriptedCharArch.States[i].HealthPctThreshold, (1.1f / float(HealthMax)));
		}
	}

	if (ScriptedCharArch.bUseZedProximityTrigger || ScriptedCharArch.bUsePlayerProximityTrigger)
	{
		InitializeProximityTriggers();
	}

	// save off the default material in case a specific state does not specify a material
	DefaultMaterial = Mesh.GetMaterial(0);

	SetPawnState(0);
	UpdatePawnState();
	SetCanBeTargeted(false);

	if (ScriptedCharArch.bIsFlyingPawn)
	{
		SetPhysics(PHYS_Flying);
		bCollideWorld = false;
	}
	else
	{
		SetPhysics(PHYS_Walking);
		bCollideWorld = true; // must collide with world until it lands
	}
}

function InitializeWeldable()
{
	WeldableComponent = Spawn(class'KFWeldableComponent', self);
	InitializeWeldableComponent();

	WeldableTrigger = Spawn(class'KFWeldableTrigger', self);
	InitializeWeldableTrigger();

	WeldableTrigger.SetCollision(false, false);
	UpdateWeldIntegrity();
}

simulated function InitializeWeldableComponent()
{
	local float WeldCompRadius, WeldCompHeight;
	local KFGameReplicationInfo KFGRI;

	// If we don't have an archetype, wait for it
	// (InitializeWeldableComponent will be called from ReplicatedEvent)
	if (ScriptedCharArch != none && WeldableComponent != none)
	{
		KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

		WeldableComponent.SetOwner(self);
		WeldableComponent.SetBase(self);
		WeldableComponent.MaxWeldIntegrity = ScriptedCharArch.PawnMaxWeldIntegrityPerPlayer[KFGRI.GetNumPlayers()-1];
		if (Role == ROLE_Authority)
		{
			WeldableComponent.WeldIntegrity = WeldableComponent.MaxWeldIntegrity;
		}
		WeldableComponent.bWeldable = ScriptedCharArch.bPawnCanBeWelded;
		WeldableComponent.bUnweldable = ScriptedCharArch.bPawnCanBeUnwelded;
		WeldableComponent.Delegate_OnWeldIntegrityChanged = OnWelded;

		WeldCompRadius = WeldableComponent.GetCollisionCylinderRadius();
		WeldCompHeight = WeldableComponent.GetCollisionCylinderHeight();
		WeldableComponent.SetCollisionCylinderSize(WeldCompRadius * ScriptedCharArch.PawnWeldableComponentScale, WeldCompHeight);
		WeldableComponent.SetCollision(bActive, false);
	}
}

simulated function InitializeWeldableTrigger()
{
	if (WeldableTrigger != none)
	{
		WeldableTrigger.SetOwner(self);
		WeldableTrigger.SetBase(self);
		WeldableTrigger.WeldableComponent = WeldableComponent;
	}
}

simulated function InitializeProximityTriggers()
{
	local float TrigRadius, TrigHeight;

	PlayerProximityTrigger = Spawn(class'KFTrigger_NotifyOwner', self);
	PlayerProximityTrigger.SetOwner(self);
	PlayerProximityTrigger.SetBase(self);

	TrigRadius = CylinderComponent(PlayerProximityTrigger.CollisionComponent).CollisionRadius;
	TrigHeight = CylinderComponent(PlayerProximityTrigger.CollisionComponent).CollisionHeight;
	CylinderComponent(PlayerProximityTrigger.CollisionComponent).SetCylinderSize(TrigRadius * ScriptedCharArch.PlayerProximityTriggerScale, TrigHeight);

	ZedProximityTrigger = Spawn(class'KFTrigger_NotifyOwner', self);
	ZedProximityTrigger.SetOwner(self);
	ZedProximityTrigger.SetBase(self);

	TrigRadius = CylinderComponent(ZedProximityTrigger.CollisionComponent).CollisionRadius;
	TrigHeight = CylinderComponent(ZedProximityTrigger.CollisionComponent).CollisionHeight;
	CylinderComponent(ZedProximityTrigger.CollisionComponent).SetCylinderSize(TrigRadius * ScriptedCharArch.ZedProximityTriggerScale, TrigHeight);
}

simulated function OnWelded(int Amount, KFPawn Welder)
{
	local float WeldAmountPct;
	local float HealAmount;

	if (Role == ROLE_Authority && WeldableComponent != none)
	{
		WeldAmountPct = float(Amount) / float(WeldableComponent.MaxWeldIntegrity);
		HealAmount = WeldAmountPct * float(HealthMax);
		Health += HealAmount;

		UpdateWeldIntegrity();
		UpdatePawnState(1);

		if (Delegate_OnHealDamage != none)
		{
			Delegate_OnHealDamage(HealAmount);
		}
	}
}

simulated function UpdateWeldIntegrity()
{
	if (Role == ROLE_Authority && WeldableComponent != none)
	{
		// set weldintegrity based on current health, because health and weldintegrity can get out of sync due to rounding error
		WeldableComponent.SetWeldIntegrity((float(Health) / float(HealthMax)) * WeldableComponent.MaxWeldIntegrity);
	}
}

simulated function SetEscortPawnOnHud()
{
	local KFPlayerController KFPC;

	ForEach LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		if (KFPC.MyGFxHUD != None && KFPC.MyGFxHUD.BossHealthBar != none)
		{
			KFPC.MyGFxHUD.BossHealthBar.SetEscortPawn(self);
		}
	}
}


simulated function RemoveEscortPawnOnHud()
{
	local KFPlayerController KFPC;

	ForEach LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		if (KFPC.MyGFxHUD != None && KFPC.MyGFxHUD.BossHealthBar != none)
		{
			KFPC.MyGFxHUD.BossHealthBar.Deactivate();
		}
	}
}

/** Called from Possessed event when this controller has taken control of a Pawn */
function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);

	/** Set MyKFAIC for convenience to avoid casting */
	if (KFAIController(C) != none)
	{
		MyKFAIC = KFAIController(C);
	}

	KFGameInfo(WorldInfo.Game).Teams[0].AddToTeam(C);
}

simulated event byte ScriptGetTeamNum()
{
	return 0;
}

function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	if (InstigatedBy.GetTeamNum() == GetTeamNum() || !bCanCurrentlyBeTargetedByZeds || !bActive)
	{
		InDamage = 0;
	}
	else
	{
		super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

		if (InDamage >= Health && !ScriptedCharArch.bPawnCanBeKilled)
		{
			InDamage = Max(Health - 1, 0);
		}
	}
}

function Timer_RecentDamage() {}
function bool WasAttackedRecently()
{
	return IsTimerActive(nameof(Timer_RecentDamage));
}


event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int OldHealth, ActualDamage;

	OldHealth = Health;
	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	ActualDamage = OldHealth - Health;

	if (ActualDamage > 0)
	{
		SetTimer(RecentDamageTimerLength, false, nameof(Timer_RecentDamage), self);

		if (WeldableComponent != none)
		{
			UpdateWeldIntegrity();
		}

		UpdatePawnState(-1);

		if (Delegate_OnTakeDamage != none)
		{
			Delegate_OnTakeDamage(ActualDamage);
		}
	}
}

simulated function PlayTakeHitEffects(vector HitDirection, vector HitLocation, optional bool bUseHitImpulse = true)
{
	TryPlayHitReactionAnim(HitDirection, HitFxInfo.DamageType, HitFxInfo.HitBoneIndex);
}

/** Calculate type of hit reaction animation from damage info */
simulated function bool TryPlayHitReactionAnim(vector HitDirection, class<KFDamageType> damageType, byte HitZoneIdx)
{
	local EPawnOctant AnimDir;
	local EHitReactionAnimType HitReactionType;
	local EHitZoneBodyPart BodyPart;
	local bool bOnlyAdditiveHits;

	if( damageType == none || ActorTimeSince(NextHitReactionAnim_ActorTime) < 0 )
	{
		return false;
	}

	// cannot play hit reaction anims during special moves
	if ( IsDoingSpecialMove() )
	{
		bOnlyAdditiveHits = true;
		if ( !SpecialMoves[SpecialMove].bAllowHitReactions )
		{
			return false;
		}
	}

	// Set the limb used for incap effects
	BodyPart = (HitZoneIdx != 255 && HitZoneIdx < HitZones.Length) ? HitZones[HitZoneIdx].Limb : BP_Torso;

	HitReactionType = HIT_Light;
	// If we're moving (e.g. DoPauseAI wasn't called because of incap cooldown) don't try hard/medium
	// This is not 100% reliable, but worst case we get a reasonable upper body blend while moving
	bOnlyAdditiveHits = bOnlyAdditiveHits || VSizeSq(Velocity) > 50.f;

	if ( !bOnlyAdditiveHits )
	{
		HitReactionType = EHitReactionAnimType(AfflictionHandler.GetPredictedHitReaction(DamageType, BodyPart));
	}

	switch (BodyPart)
	{
	case BP_LeftArm:
		AnimDir = CalcOctagonRegion(Rotation, -HitDirection);
		if ( AnimDir == DIR_Forward || AnimDir == DIR_ForwardLeft || AnimDir == DIR_ForwardRight )
			AnimDir = DIR_ForwardLeft;
		else
			AnimDir = DIR_BackwardLeft;
		break;
	case BP_RightArm:
		AnimDir = CalcOctagonRegion(Rotation, -HitDirection);
		if ( AnimDir == DIR_Forward || AnimDir == DIR_ForwardLeft || AnimDir == DIR_ForwardRight )
			AnimDir = DIR_ForwardRight;
		else
			AnimDir = DIR_BackwardRight;
		break;
	default:
		AnimDir = CalcOctagonRegion(Rotation, -HitDirection);
		break;
	}

	// Play animation
	return PawnAnimInfo.PlayHitReactionAnim(self, HitReactionType, AnimDir);
}

simulated function bool CanBeHealed()
{
	return ScriptedCharArch.bPawnCanBeHealed;
}

event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType, optional bool bRepairArmor=true, optional bool bMessageHealer=true)
{
	local bool result;
	local int PrevHealth;

	if (!bActive || !ScriptedCharArch.bPawnCanBeHealed)
	{
		return false;
	}

	PrevHealth = Health;
	result = Super.HealDamage(Amount, Healer, DamageType, bRepairArmor, bMessageHealer);

	UpdateWeldIntegrity();
	UpdatePawnState(1);

	if (Delegate_OnHealDamage != none)
	{
		Delegate_OnHealDamage(Health - PrevHealth);
	}

	return result;
}

function UpdatePawnState(optional int HealthDelta = 0)
{
	local int i;
	local float HealthPct;

	HealthPct = float(Health) / float(HealthMax);

	if (HealthDelta > 0)
	{
		for (i = 0; i < CurrentState; ++i)
		{
			if (HealthPct >= ScriptedCharArch.States[i].HealthPctThreshold)
			{
				break;
			}
		}
	}
	else
	{
		for (i = CurrentState; i < ScriptedCharArch.States.Length - 1; ++i)
		{
			if (HealthPct >= ScriptedCharArch.States[i + 1].HealthPctThreshold)
			{
				break;
			}
		}
	}

	SetPawnState(i);
}

simulated function SetPawnState(int InState)
{
	local int ExitTransitionType, EnterTransitionType;

	if (Role == ROLE_Authority && InState == CurrentState)
	{
		return;
	}

	if (ScriptedCharArchTemplate != none)
	{
		if (CharacterArch == none)
		{
			// Make sure arch is set because this function could be called after ScriptedCharArchTemplate is
			// replicated but before ScriptedCharArchTemplate is repnotified
			SetCharacterArch(ScriptedCharArchTemplate, true);
		}

		if (Role == ROLE_Authority)
		{
			CurrentState = InState;
			SetCanBeTargeted(ScriptedCharArch.States[InState].bCanBeTargetedByZeds);
		}

		if (CurrentState != PreviousState)
		{
			UpdatePawnSpeed();

			// set whether this current state allows movement
			bIsInStoppedState = ScriptedCharArch.States[CurrentState].SpeedScalar <= 0.0f;

			if (PreviousState < CurrentState)
			{
				ExitTransitionType = FXTransitionType_PlayGreaterStateTransition;
				EnterTransitionType = FXTransitionType_PlayLesserStateTransition;
			}
			else if (PreviousState > CurrentState)
			{
				ExitTransitionType = FXTransitionType_PlayLesserStateTransition;
				EnterTransitionType = FXTransitionType_PlayGreaterStateTransition;
			}

			StopExtraVFX(Name("EnterState"$PreviousState));

			PlayExtraVFX(Name("ExitState"$PreviousState$"-"$ExitTransitionType));
			PlayExtraVFX(Name("EnterState"$CurrentState$"-"$EnterTransitionType));

			PlayExtraVFX(Name("ExitState"$PreviousState));
			PlayExtraVFX(Name("EnterState"$CurrentState));

			CheckScriptedPawnMaterial();
			DoSpecialMove(SM_ScriptedPawnStateChange, true);
		}

		if (Delegate_OnChangeState != none)
		{
			Delegate_OnChangeState(CurrentState, PreviousState);
		}

		PreviousState = CurrentState;
	}
}

simulated function CheckScriptedPawnMaterial()
{
	//change the material based on the new state
	if (bActive && ScriptedCharArch.States[CurrentState].HighlightedStateMaterial != none)
	{
		Mesh.SetMaterial(0, ScriptedCharArch.States[CurrentState].HighlightedStateMaterial);
	}
	else if (ScriptedCharArch.States[CurrentState].DefaultStateMaterial != none)
	{
		Mesh.SetMaterial(0, ScriptedCharArch.States[CurrentState].DefaultStateMaterial);
	}
	else
	{
		// if there isn't a material set, use the default material
		Mesh.SetMaterial(0, DefaultMaterial);
	}
}

function bool IsBlockedByZed()
{
	return ScriptedCharArch.bUseZedProximityTrigger && bZedInProximity;
}

function UpdatePawnSpeed()
{
	GroundSpeed = ScriptedCharArch.PawnSpeed * ScriptedCharArch.States[CurrentState].SpeedScalar;

	if (IsBlockedByZed())
	{
		GroundSpeed *= ScriptedCharArch.SpeedScalarForZedProximity;
	}

	if (ScriptedCharArch.bUsePlayerProximityTrigger && bPlayerInProximity)
	{
		GroundSpeed *= ScriptedCharArch.SpeedScalarForPlayerProximity;
	}

	// used to pause the scripted pawn in front of closed doors and other obstacles
	GroundSpeed *= SpeedScalarForObstacles;
}

simulated function bool IsInCriticalCondition()
{
	return CurrentState == ScriptedCharArch.States.Length - 1;
}

simulated function name GetStateTransitionAnim()
{
	if (CurrentState != PreviousState)
	{
		if (ScriptedCharArch.States[CurrentState].EnterAnim != `NAME_None)
		{
			return ScriptedCharArch.States[CurrentState].EnterAnim;
		}
		else if (PreviousState != 255 && ScriptedCharArch.States[PreviousState].ExitAnim != `NAME_None)
		{
			return ScriptedCharArch.States[PreviousState].ExitAnim;
		}
	}

	return `NAME_None;
}

simulated function SetCharacterArch(KFCharacterInfoBase Info, optional bool bForce)
{
	local int i, j;
	local ExtraVFXInfo FX;

	super.SetCharacterArch(Info, bForce);

	// SetCharacterArch sets CharacterArch, which is an instance of Info and can't be replicated,
	// so replicate the template (Info) instead
	if (Role == ROLE_Authority)
	{
		ScriptedCharArchTemplate = KFCharacterInfo_ScriptedPawn(Info);
	}

	ScriptedCharArch = KFCharacterInfo_ScriptedPawn(CharacterArch);

	// utilized by the PlayExtraVFX system similar to the archetype's ExtraVFX array
	// putting these effects in a separate array so that the archetype asset storing ExtraVFX won't be modified
	// must be setup before updating pawn state

	// normally ExtraVFX has start and stop SFX events, but EnterFX will handle the start and ExitFX
	// will handle the stop
	for (i = 0; i < ScriptedCharArch.States.Length; ++i)
	{
		for (j = 0; j < ScriptedCharArch.States[i].EnterFX.Length; ++j)
		{
			FX.VFX = ScriptedCharArch.States[i].EnterFX[j].VFX;
			FX.SFXStartEvent = ScriptedCharArch.States[i].EnterFX[j].SFX;
			FX.SocketName = ScriptedCharArch.States[i].EnterFX[j].SocketName;
			FX.Label = Name("EnterState"$i);
			if (ScriptedCharArch.States[i].EnterFX[j].TransitionType != FXTransitionType_PlayAlways)
			{
				FX.Label = Name(FX.Label $ "-" $ int(ScriptedCharArch.States[i].EnterFX[j].TransitionType));
			}
			ScriptedStateVFX.AddItem(FX);
		}

		for (j = 0; j < ScriptedCharArch.States[i].ExitFX.Length; ++j)
		{
			FX.VFX = ScriptedCharArch.States[i].ExitFX[j].VFX;
			FX.SFXStartEvent = ScriptedCharArch.States[i].ExitFX[j].SFX;
			FX.SocketName = ScriptedCharArch.States[i].ExitFX[j].SocketName;
			FX.Label = Name("ExitState"$i);
			if (ScriptedCharArch.States[i].ExitFX[j].TransitionType != FXTransitionType_PlayAlways)
			{
				FX.Label = Name(FX.Label $ "-" $ int(ScriptedCharArch.States[i].ExitFX[j].TransitionType));
			}
			ScriptedStateVFX.AddItem(FX);
		}
	}
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	local KFAIController KFAIC;

	KFAIC = KFAIController(Controller);
	if (KFAIC != none && KFAIC.CommandList != none)
	{
		KFAIC.AbortCommand(KFAIC.CommandList);
	}

	return super.Died(Killer, damageType, HitLocation);
}

function HandleMomentum(vector Momentum, Vector HitLocation, class<DamageType> DamageType, optional TraceHitInfo HitInfo)
{
	if (ScriptedCharArch.bPawnHandlesMomentum)
	{
		super.HandleMomentum(Momentum, HitLocation, DamageType, HitInfo);
	}
}

function bool CanBeGrabbed(KFPawn GrabbingPawn, optional bool bIgnoreFalling, optional bool bAllowSameTeamGrab)
{
	return ScriptedCharArch.bPawnCanBeGrabbed;
}

event Landed(vector HitNormal, Actor FloorActor)
{
	super.Landed(HitNormal, FloorActor);
	bCollideWorld = false;
}

function StartRoute(SplineActor SplineStart, SplineActor SplineEnd, int SegmentGranularity)
{
	class'AICommand_ScriptedPawn_TraverseSpline'.static.TraverseSpline(MyKFAIC, SplineStart, SplineEnd, SegmentGranularity);
}

function ReachedRouteMarker(int MarkerIdx, SplineActor Marker, int SubIdx, float DistSinceLastMarker)
{
	if (Delegate_OnReachedRouteMarker != none)
	{
		Delegate_OnReachedRouteMarker(MarkerIdx, Marker, SubIdx, DistSinceLastMarker);
	}
}

// ReachedGoal is called when the pawn successfully completes its scripted route
function ReachedGoal()
{
	FinishSequence();
	Finish(false);
}

// EndedRoute is called when the pawn either reaches the last node in the route (and should disappear)
// or dies and does not reach its goal
function EndedRoute(bool bSuccess)
{
	FinishSequence();

	if (bSuccess)
	{
		Finish(true);
	}

	if (Delegate_OnEndedRoute != none)
	{
		Delegate_OnEndedRoute(bSuccess);
	}
}

// Allow the sequence action to resolve itself
// NOTE: Must be called before "Finish"
function FinishSequence()
{
	local int i;
	local Sequence GameSeq;
	local array<SequenceObject> AllPawnStartActions;

	GameSeq = WorldInfo.GetGameSequence();
	if (GameSeq != None)
	{
		// find any matinee actions that exist
		GameSeq.FindSeqObjectsByClass(class'KFSeqAct_StartScriptedPawn', true, AllPawnStartActions);
		for (i = 0; i < AllPawnStartActions.Length; i++)
		{
			KFSeqAct_StartScriptedPawn(AllPawnStartActions[i]).CheckPawnFinished(self);
		}

		AllPawnStartActions.length = 0;
		GameSeq.FindSeqObjectsByClass(class'KFSeqAct_RestartScriptedPawn', true, AllPawnStartActions);
		for (i = 0; i < AllPawnStartActions.Length; i++)
		{
			KFSeqAct_RestartScriptedPawn(AllPawnStartActions[i]).CheckPawnFinished(self);
		}
	}
}

// Stuff that happens when the pawn starts its route
function Start()
{
	SetCollision(true, true);

	if (WeldableComponent != none)
	{
		WeldableComponent.SetCollision(bActive, false);
	}

	if (WeldableTrigger != none)
	{
		WeldableTrigger.SetCollision(bActive, false);
	}

	UpdatePawnState();

	if (bStartInactive)
	{
		SetActive(false);
	}
}

simulated function PlayFinishedSounds()
{
	local int i;

	// generally used to stop the looping sounds
	for (i = 0; i < ScriptedCharArch.FinishSoundEvents.length; i++)
	{
		PlaySoundBase(ScriptedCharArch.FinishSoundEvents[i], false, WorldInfo.NetMode == NM_DedicatedServer);
	}
}

// Stuff that happens when the pawn ends its route
function Finish(bool bHide)
{
	if (ScriptedCharArch.bHideOnFinish)
	{
		if (bHide)
		{
			SetPhysics(PHYS_None);
			SetHidden(true);

			// only used when hiding the pawn, otherwise want to keep playing its normal sounds
			PlayFinishedSounds();
		}

		SetCollision(false, false);
	}
	else
	{
		// manually stop the cart at the end since physics are still enabled if the pawn doesn't get hidden
		if (bHide)
		{
			GroundSpeed = 0.0f;
			Velocity = vect(0, 0, 0);
		}
	}

	DamageOverTimeArray.length = 0; // remove damage over time effects
	//bPlayedDeath = true; // forces zeds to find a new target // Now accomplished in ZedBaseCommand with CanAITargetThisPawn
	SetCanBeTargeted(false); // prevents zeds from re-targeting

	if (WeldableComponent != none)
	{
		WeldableComponent.SetCollision(false, false);
	}

	if (WeldableTrigger != none)
	{
		WeldableTrigger.SetCollision(false, false);
	}

	SetActive(false);
}

simulated event Bump(Actor Other, PrimitiveComponent OtherComp, Vector HitNormal)
{
	local vector ToOther;
	if (KFPawn(Other) != none)
	{
		ToOther = Normal(Other.Location - Location);
		if ((ToOther Dot HitNormal) < 0)
		{
			// This is the case where the scripted pawn bumps into another pawn.
			// Move the pawn.
			KFPawn(Other).AddVelocity(HitNormal*(-ScriptedCharArch.PawnBumpImpulse), vect(0,0,0), none);
		}
		else
		{
			// This is the case where another pawn bumps into the scripted pawn.
			// Probably don't need to do anything.
		}
	}
}

function bool CanAITargetThisPawn(Controller TargetingController)
{
    return bCanCurrentlyBeTargetedByZeds;
}

function SetCanBeTargeted(bool InCanBeTargeted)
{
	local bool bCouldPreviouslyBeTargetedByZeds;
	local KFPawn_Monster KFPM;

	bCouldPreviouslyBeTargetedByZeds = bCanCurrentlyBeTargetedByZeds;
	bCanCurrentlyBeTargetedByZeds = ScriptedCharArch != none && ScriptedCharArch.States[CurrentState].bCanBeTargetedByZeds && InCanBeTargeted;
	if (bCouldPreviouslyBeTargetedByZeds && !bCanCurrentlyBeTargetedByZeds)
	{
		foreach WorldInfo.AllPawns(class'KFPawn_Monster', KFPM)
		{
			if (KFPM.GetEnemy() == self)
			{
				KFAIController(KFPM.Controller).FindNewEnemy();
			}
		}
	}
}

simulated function Texture2D GetStateIconTexture()
{
	if (CurrentState == 255)
	{
		return none;
	}

	return ScriptedCharArch.States[CurrentState].Icon;
}

function NotifyTriggerTouch(KFTrigger_NotifyOwner Sender, Actor Toucher, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local KFPawn_Monster Zed;
	local KFPawn_Human Player;

	if (Sender == ZedProximityTrigger)
	{
		if (ScriptedCharArch.bUseZedProximityTrigger)
		{
			Zed = KFPawn_Monster(Toucher);
			if (Zed != none)
			{
				bZedInProximity = true;

				// aggro
				if (bCanCurrentlyBeTargetedByZeds && KFAIController(Zed.Controller) != none)
				{
					KFAIController(Zed.Controller).SetEnemy(self);
				}
			}
		}

		UpdatePawnSpeed();
	}

	if (Sender == PlayerProximityTrigger)
	{
		if (ScriptedCharArch.bUsePlayerProximityTrigger)
		{
			Player = KFPawn_Human(Toucher);
			if (Player != none)
			{
				bPlayerInProximity = true;
			}
		}

		UpdatePawnSpeed();
	}
}

function NotifyTriggerUnTouch(KFTrigger_NotifyOwner Sender, Actor UnToucher)
{
	local KFPawn_Monster Zed;
	local KFPawn_Human Player;

	if (Sender == ZedProximityTrigger)
	{
		if (ScriptedCharArch.bUseZedProximityTrigger)
		{
			Zed = KFPawn_Monster(UnToucher);
			if (Zed != none)
			{
				bZedInProximity = false;
				foreach ZedProximityTrigger.TouchingActors(class'KFPawn_Monster', Zed)
				{
					if (Zed != UnToucher)
					{
						bZedInProximity = true;
						break;
					}
				}
			}
		}

		UpdatePawnSpeed();
	}

	if (Sender == PlayerProximityTrigger)
	{
		if (ScriptedCharArch.bUsePlayerProximityTrigger)
		{
			Player = KFPawn_Human(UnToucher);
			if (Player != none)
			{
				bPlayerInProximity = false;
				foreach PlayerProximityTrigger.TouchingActors(class'KFPawn_Human', Player)
				{
					if (Player != UnToucher)
					{
						bPlayerInProximity = true;
						break;
					}
				}
			}
		}

		UpdatePawnSpeed();
	}
}

simulated function SetActive(bool InActive)
{
	if (Role == ROLE_Authority)
	{
		if (bActive == InActive)
		{
			// Don't retrigger activation events if we are already active/unactive.
			return;
		}

		bActive = InActive;
		SetCanBeTargeted(bActive);
		UpdateWeldIntegrity();
		UpdatePawnSpeed();
	}

	if (WeldableComponent != none)
	{
		WeldableComponent.SetCollision(bActive, false);
	}

	if (WeldableTrigger != none)
	{
		WeldableTrigger.SetCollision(bActive, false);
	}

	if (InActive)
	{
		SetEscortPawnOnHud();
	}
	else
	{
		//hide boss healthbar
		RemoveEscortPawnOnHud();
	}

	CheckScriptedPawnMaterial();
}

simulated function bool ShouldShowOnHUD()
{
	return bActive;
}

simulated function float GetHealthPercent()
{
	return fclamp(float(Health) / float(HealthMax), 0.0f, 1.0f);
}

static function string GetLocalizedName()
{
	return default.ScriptedPawnString;
}

simulated function string GetIconPath()
{
	return IconPath;
}

simulated function StartDoorWait(KFDoorActor Door)
{
	BlockingDoor = Door;
	SpeedScalarForObstacles = 0.0f;
	UpdatePawnSpeed();
	SetTimer(0.5f, true, nameof(Timer_DoorWait), self);
}

simulated function PlayExtraVFX(Name FXLabel)
{
	local int i;
	local ExtraVFXAttachmentInfo VFXAttachment;
	local bool bActivatedExistingSystem;

	if (WorldInfo.NetMode != NM_DedicatedServer && FXLabel != `NAME_NONE)
	{
		// if this has already been spawned before, play the existing system in the parent instead
		for (i = 0; i < ExtraVFXAttachments.Length; ++i)
		{
			if (ExtraVFXAttachments[i].Info.Label == FXLabel)
			{
				bActivatedExistingSystem = true;
			}
		}

		if (!bActivatedExistingSystem)
		{
			for (i = 0; i < ScriptedStateVFX.Length; ++i)
			{
				if (ScriptedStateVFX[i].Label == FXLabel)
				{
					VFXAttachment.VFXComponent = SpawnExtraVFX(ScriptedStateVFX[i]);
					VFXAttachment.Info = ScriptedStateVFX[i];
					ExtraVFXAttachments.AddItem(VFXAttachment);
				}
			}
		}
	}

	super.PlayExtraVFX(FXLabel);
}

simulated function Timer_DoorWait()
{
	if (BlockingDoor == none || BlockingDoor.bIsDoorOpen || BlockingDoor.bIsDestroyed)
	{
		BlockingDoor = none;
		SpeedScalarForObstacles = 1.0f;
		UpdatePawnSpeed();
		ClearTimer(nameof(Timer_DoorWait), self);
	}
}

defaultproperties
{
	ControllerClass=class'KFGame.KFAIController_ScriptedPawn'

	CurrentState=255
	PreviousState=255

	AccelRate=0

	bAlwaysRelevant=true

	// Bone names (don't need 'em, having them causes warnings)
	LeftFootBoneName=""
	RightFootBoneName=""
	LeftHandBoneName=""
	RightHandBoneName=""
	HeadBoneName=""
	TorsoBoneName=""
	PelvisBoneName=""

	// ---------------------------------------------
	// Special moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_ScriptedPawnStateChange)=class'KFGame.KFSM_PlaySingleAnim_ScriptedPawn'
	End Object

	IconPath="ZED_Patriarch_UI.ZED-VS_Icon_Boss"

	SpeedScalarForObstacles=1.0f;
	RecentDamageTimerLength=5.0f;

	Begin Object Name=CollisionCylinder
		CollisionRadius=+0108.000000
		CollisionHeight=+0086.000000
		BlockZeroExtent=false // blocked by mesh
	End Object

	bBlockPlayers=false
	bBlockZedPlayers=true
	bBlockMonsters=true

	bCanBeAdheredTo=false
	bCanBeFrictionedTo=false

	bBlockInStoppedState=false
	bIsInStoppedState=false
}
