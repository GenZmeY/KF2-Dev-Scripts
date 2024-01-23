//=============================================================================
// KFDoorActor
//=============================================================================
// Class for placeable doors.  Used intead of the InterpActor method so that
// we can easily replicate damage states and use skeletal animation.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFDoorActor extends KFWeldableActor
	hidecategories(Movement, Collision, Physics, Object, Mobile)
	placeable
	native
	nativeReplication;

`include(KFGame\KFGameAnalytics.uci);

/** The base width of a doors SkeletalMeshComponent */
const SkeletalMesh_Width = 256;
const KActorOffset = 25;

/** Reference to the door trigger */
var KFDoorTrigger DoorTrigger;

var bool bIsInteractive;

/*********************************************************************************************
 * @name	Meshes / Materials / Particles
 ********************************************************************************************* */

struct native DoorMeshAttachment
{
    var() StaticMeshComponent     Component;         // Component which needs to be attached
	var() name                    AttachTo;			 // Bone or socket name to which the attachment should be attached
	var() bool                    bSocketAttach;	 // Whether to attach it to a socket or a bone

    structdefaultproperties
    {
        AttachTo=DoorLeft
    }
};

/** Information of all the mesh attachments for the vehicle */
var() array<DoorMeshAttachment> MeshAttachments;

/** Mesh for the weld that goes between the center of two doors or the end of the left door  */
var() StaticMeshComponent     CenterWeldComponent;

/** skeletal mesh used for open/close animations */
var() const editconst SkeletalMeshComponent	SkeletalMeshComp;

var array<MaterialInstanceConstant> 	HealthMICs;

enum EDoorMaterialType
{
	EDMT_Metal,
	EDMT_Wood
};

var() EDoorMaterialType DoorMaterial;

/*********************************************************************************************
 * @name	Open / Close
 ********************************************************************************************* */

enum EDoorMechanism
{
	EDM_Hinge,
	EDM_Slide,
	EDM_Lift,
};

/** type of networking to use */
var(Opening) EDoorMechanism DoorMechanism;
/** The amount of time before a door can be used again */
var(Opening) float CooldownTime;
/** The time it takes to open / close a door */
var(Opening) float OpenBlendTime;
/** ONLY FOR HINGED DOORS Defines how far we want to open our hinged doors in degrees */
var(Opening) int   HingedRotation;
/** ONLY FOR SLIDING DOORS Defines how far we want sliding doors to move */
var(Opening) int   SlideTranslation;
/** ONLY FOR LIFT DOORS Defines how far we want lift doors to raise */
var(Opening) int   LiftTranslation;
/** If set, door opens and closes automatically */
var(Opening) const editconst bool bAutomaticDoor;

/** Has the last door move (open/shut) completed? */
var transient bool bDoorMoveCompleted;

/** The time when the door was last used */
var transient float LastUsedTime;

/** current state of the door if it hasn't been destroyed - note it's possible for bIsDoorOpen to be false and bIsDoorDestroyed to be true so check both */
var () bool bStartDoorOpen;
var repnotify transient bool bIsDoorOpen;
var transient bool bLocalIsDoorOpen;
var transient bool bReverseHinge;
var transient bool bCanCloseDoor;

/** When true, the door can be processed for resets */
var transient bool bHasBeenDirtied;

/*********************************************************************************************
 * @name	Health
 ********************************************************************************************* */

enum EDoorFastening
{
	EDF_ArcWelding,
	EDF_Rivets
};

var EDoorFastening FastenerType;

/** Starting health for a door */
var() int MaxHealth;
/** Current door health for damage/destruction */
var repnotify transient int Health;

/** Should this door explode? */
var repnotify transient bool bShouldExplode;
var transient KFPlayerController ExplosionInstigatorController;

/** While the door is being attacked it takes longer to weld */
var() float CombatWeldModifier<ClampMin=0.0 | ClampMax=1.0>;
/** The amount of time a door is considered in combat after being hit */
var float CombatLength;

/** True if this projectile has already blown up, used to ensure only a single explosion. */
var repnotify transient byte HitCount;
const HIT_DIRECTION_FLAG = 0x80;

/** Last time the door took damage */
var transient float LastHitTime;

/** Cached SkelControlSingleBone */
var transient SkelControlSingleBone MovementControl;

/** Cached AnimNodeSlot */
var transient AnimNodeSlot BashSlot;

/** A scaler to fit a door into its proper frame. Double the frame size if we are only using one door for this actor */
var() float FrameSizeOfTwoDoors;

/*********************************************************************************************
 * @name	AI
 ********************************************************************************************* */

/** NavigationPoint associated with this actor for sending AI related notifications (could be a LiftCenter or DoorMarker) */
var NavigationPoint MyMarker;
/** true when AI is waiting for us to finish moving */
var bool bMonitorDoor;

//var() KFNavMeshObstacle_Door MyNavMeshObstacle;

/** Navigation handle used for pathing when using NavMesh */
//var     class<KFNavigationHandle>       NavigationHandleClass;
//var     KFNavigationHandle              MyKFNavigationHandle;

/*********************************************************************************************
 * @name	Physics
 ********************************************************************************************* */

/** The impulse to provide the doors when they are destroyed */
var() float BrokenDoorImpulse;
/** The maximum angular velocity applied to a broken hinged door*/
var() float MaxAngularVelocity;

/** settings for TryPushPawns */
const DoorWidth = 200;
const HumanPushDistance = 40;
const SlidingPushForce = 750;
const VerticalPushForce = 100;

/** Adjusts the "push" plane of the door (the threshold for pushing forward or backward) along its X-axis */
//var() float PushOriginOffset;

/** Cache of physical broken door pieces, needed so they can be deleted when the door is restored through a non-reset method */
var array<KActor> BrokenDoorPhysicsActors;

/*********************************************************************************************
 * @name	Effects
 ********************************************************************************************* */

const BashHingedAnim_F = 'DoorBash_A';
const BashHingedAnim_B = 'DoorBash_B';
const BashSlidingAnim_F = 'DoorBashSliding_A';
const BashSlidingAnim_B = 'DoorBashSliding_B';

/** sound played when the mover is interpolated forward */
var(Sound) AkBaseSoundObject OpenSound;
/** looping sound while opening */
var(Sound) AkBaseSoundObject OpeningAmbientSound;
/** sound played when mover finished moving forward */
var(Sound) AkBaseSoundObject OpenedSound;
/** sound played when the mover is interpolated in reverse */
var(Sound) AkBaseSoundObject CloseSound;
/** looping sound while closing */
var(Sound) AkBaseSoundObject ClosingAmbientSound;
/** sound played when mover finished moving backward */
var(Sound) AkBaseSoundObject ClosedSound;
/** sound played when door is destroyed */
var(Sound) AkBaseSoundObject DestroyedSound;
/** component for looping sounds */
var AkComponent AmbientSoundComponent;
/** used for playing sounds (set to center of doorway in PostBeginPlay because sometimes the actor location is under the floor and sounds don't play right) */
var transient vector SoundOrigin;

/** played when the melee attack hits world geometry */
var() DestroyedEffectParams DamageEmitter;
/** played when the melee attack hits world geometry and the door has no health */
var() array<DestroyedEffectParams> DestroyedEmitters;

/** Physics actors spawned when a door is broken */
var transient array<ParticleSystemComponent> BrokenDoorParticleEffects;

var() FXTemplate OnDoorOpenEmitterTemplate;
var ParticleSystemComponent OnDoorOpenEmitter;

/*********************************************************************************************
 * @name	UI
 ********************************************************************************************* */

/** Offset from door location (bottom) to closer to eye level for UI, FX, sounds, etc */
var transient vector VisualDoorLocation;

/** Localized strings */
var localized string ExplosiveString;

cpptext
{
	virtual void TickSpecial( FLOAT DeltaSeconds );
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );

    // Ensure the SkeletalMeshComp has no pre-existing animations
    virtual void PostLoad();

	// Attach static meshes in PostEditChangeProperty
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive, AActor *SourceActor, DWORD TraceFlags);

#if WITH_EDITOR
	virtual INT AddMyMarker(AActor *S);
#endif
}

replication
{
	if ( bNetDirty )
		HitCount, bIsDoorOpen, Health, bShouldExplode, bIsInteractive;

	if ( bNetDirty && DoorMechanism == EDM_Hinge )
		bReverseHinge;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == nameof(bIsDoorOpen))
	{
		if ( bIsDoorOpen )
		{
			// not already open (see InitSkelControl)
			if ( MovementControl.StrengthTarget == 0 )
			{
				OpenDoor(None);
			}
		}
		else
		{
			CloseDoor();
		}
	}
	else if ( VarName == nameof(Health) )
	{
    	UpdateHealthMICs();
    	// In case the door was destroyed and it was still welded
    	if( Health <= 0 )
    	{
            UpdateIntegrityMIC();
    	}
	}
	else if ( VarName == nameof(bShouldExplode) )
	{
     	UpdateIntegrityMIC();
	}
	else if ( VarName == nameof(HitCount) )
	{
		PlayTakeHitEffects();
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

/*********************************************************************************************
 * @name	Initialization
 ********************************************************************************************* */

native function InitBrokenAttachment( StaticMeshComponent Attachment, KFKActorSpawnable SpawnedKActor );

/** The SkeletalMeshComponents Animations are being instanced from AnimTreeTemplate
* 	before PostInitAnimTree. Be sure to never set the Mesh's animations directly through
*	the package */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	MovementControl = SkelControlSingleBone(SkelComp.FindSkelControl('MovementControl'));
	BashSlot = AnimNodeSlot(SkeletalMeshComp.FindAnimNode('Slot_Bash'));

    // set open animation based on door mechanism
    InitSkelControl();
}

simulated event PostBeginPlay()
{
	local int i, NumActualDoors;
	local float MyRadius, MyHeight;
	local vector X,Y,Z;

	Super.PostBeginPlay();

	Health = MaxHealth;
	LastUsedTime = WorldInfo.TimeSeconds - CooldownTime;	// Ensures doors can be used immediately

	// create ambient sound component if needed
	if (OpeningAmbientSound != None || ClosingAmbientSound != None)
	{
		AmbientSoundComponent = new(self) class'AkComponent';
		AttachComponent(AmbientSoundComponent);
	}

	InitializeDoorMIC();
    if (CenterWeldComponent != none)
    {
        CenterWeldComponent.SetHidden(bStartDoorOpen);
    }

	if( class'KFAIController'.default.bUseNavMesh )
	{
        //InitNavigationHandle();
    }

	for( i = 0; i < MeshAttachments.length; ++i )
	{
		if( MeshAttachments[i].Component.StaticMesh != none )
		{
			SoundOrigin += MeshAttachments[i].Component.Bounds.Origin;
			NumActualDoors++;
		}
	}

	if( NumActualDoors > 0 )
	{
		SoundOrigin /= NumActualDoors;
	}
	else
	{
		SoundOrigin = Location;
	}

	if( NumActualDoors > 1 )
	{
		// With double doors, the weld UI location is in the center, so this is good for visual testing
		VisualDoorLocation = WeldUILocation;
	}
	else
	{
		// With single doors, the weld UI location is at the doorstop, which isn't ideal for visual testing
		// and can often intersect with the doorframe geometry. Offset visual test location to center of door instead.
		// Since there are always 2 door components whether or not there are 2 actual doors, we multiply the radius by
		// 0.25 instead of 0.5 to get the center (Radius / 4). -MattF
		GetAxes( Rotation, X,Y,Z );
		GetBoundingCylinder( MyRadius, MyHeight );
		VisualDoorLocation = WeldUILocation - (MyRadius * 0.25f * Y);
	}
}

/** Grab the doors materials and create MICs to visualize door damage */
simulated function InitializeDoorMIC()
{
	local MaterialInstanceConstant NewMIC, AltMIC;
	local byte i, MaterialIndex;

	if (HealthMICs.Length <= 0 && WorldInfo.NetMode != NM_DedicatedServer)
	{
		if ( MeshAttachments.Length > 0 )
		{
			for( MaterialIndex = 0; MaterialIndex < MeshAttachments[0].Component.GetNumElements(); MaterialIndex++ )
			{
				if( MeshAttachments[0].Component.GetMaterial(MaterialIndex) != none )
				{
					// We are not using "CreateAndSetMaterialInstanceConstant" because
					// a single MIC will be created for each MeshAttachment
					NewMIC = new class'MaterialInstanceConstant';
					NewMIC.SetParent( MeshAttachments[0].Component.GetMaterial(MaterialIndex) );

					HealthMICs.AddItem(NewMIC);

		        	// Apply the MIC to our door components
			        for ( i = 0; i < MeshAttachments.length; i++ )
			        {
			        	// Only apply MIC to components that share the same material
			        	if( MeshAttachments[i].Component.GetMaterial(MaterialIndex) == NewMIC.Parent )
			        	{
					   	    MeshAttachments[i].Component.SetMaterial(MaterialIndex, NewMIC);
					   	}
					   	else
					   	{
					   		// If this mesh component had a custom material, allow it to use it instead of our mirrored MIC
							AltMIC = new class'MaterialInstanceConstant';
							AltMIC.SetParent( MeshAttachments[i].Component.GetMaterial(MaterialIndex) );

							HealthMICs.AddItem( AltMIC );
					   	    MeshAttachments[i].Component.SetMaterial( MaterialIndex, AltMIC );
						}
			   	    }
		   		}
			}
   	    }

   	    if ( CenterWeldComponent != none && CenterWeldComponent.GetMaterial(0) != none )
   	    {
   	    	IntegrityMIC = CenterWeldComponent.CreateAndSetMaterialInstanceConstant( 0 );
	   	    IntegrityMIC.SetScalarParameterValue('doorWeld', 0.f);
            UpdateIntegrityMIC();
   	    }
	}
}

/** Set up skel control for open/close */
simulated function InitSkelControl()
{
    MovementControl.BlendInTime = OpenBlendTime;
    MovementControl.BlendOutTime = OpenBlendTime;
    switch (DoorMechanism)
    {
    case EDM_Hinge:
        MovementControl.bApplyTranslation = false;
        MovementControl.bApplyRotation = true;
        MovementControl.BoneRotation.Yaw = HingedRotation * DegToUnrRot;
        break;
    case EDM_Slide:
        MovementControl.bApplyTranslation = true;
        MovementControl.bApplyRotation = false;
        MovementControl.BoneTranslation.Y = SlideTranslation;
        MovementControl.BoneTranslation.Z = 0;
        break;
    case EDM_Lift:
        MovementControl.bApplyTranslation = true;
        MovementControl.bApplyRotation = false;
        MovementControl.BoneTranslation.Y = 0;
        MovementControl.BoneTranslation.Z = LiftTranslation;
        break;
    }

    // start in level-set state.  default is open.
    if (Role == ROLE_Authority)
    {
        MovementControl.SetSkelControlStrength(bStartDoorOpen ? 1.f : 0.f, 0.f);
        bIsDoorOpen = bStartDoorOpen;
        bLocalIsDoorOpen = bStartDoorOpen;
        WeldIntegrity = (bStartWelded && !bStartDoorOpen) ? MaxWeldIntegrity : 0;
    }
}

/*********************************************************************************************
 * @name	Open / Close
 ********************************************************************************************* */

/** Returns true if door is open or destroyed */
native function bool IsCompletelyOpen() const;

/** Handling Toggle event from Kismet. */
simulated function OnToggle(SeqAct_Toggle action)
{
	if ( bAutomaticDoor )
		return;

	if (action.InputLinks[0].bHasImpulse && WeldIntegrity <= 0)
	{
		OpenDoor(None);
	}
	else if (action.InputLinks[1].bHasImpulse)
	{
		CloseDoor();
	}
	else if (action.InputLinks[2].bHasImpulse)
	{
		UseDoor(None);
	}
}

/** Server only */
function UseDoor(Pawn P)
{
	// Doors cannot be used until the cooldown time has passed
	if ( `TimeSince(LastUsedTime) < CooldownTime)
	{
		return;
	}

	if ( bAutomaticDoor )
		return;

	if ( bIsDoorOpen )
	{
		CloseDoor();
	}
	else if ( WeldIntegrity <= 0 )
	{
		OpenDoor(P);
	}
	LastUsedTime = WorldInfo.TimeSeconds;
}

/** automatic doors open when bumped */
event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	local Pawn P;

	if ( bAutomaticDoor && !bIsDoorOpen && Role == ROLE_Authority )
	{
		P = Pawn(Other);
		if ( P != None && WeldIntegrity <= 0 )
		{
			OpenDoor(P);
			SetTimer(3.f, false, nameof(CloseDoor));
		}
	}

`if(`__TW_PATHFINDING_)
	if( KFPawn(Other) != none && !KFPawn(Other).IsHumanControlled() )
	{
		`AILog_Ext( GetFuncName()$" "$self$" by "$KFPawn(Other).MyKFAIC, 'Doors',  KFPawn(Other).MyKFAIC );
	}
`endif
}

/** Initiate door opening animation */
simulated protected function OpenDoor(Pawn P)
{
	local Vector Loc;
	local Rotator Rot;

	if ( bIsDestroyed || bLocalIsDoorOpen  || WeldIntegrity > 0)
	{
	 	return;
	}

	bIsDoorOpen = true;
	bForceNetUpdate = true;
	bDoorMoveCompleted = false;

	// Local (non-replicated) open flag
	bLocalIsDoorOpen = true;

	if ( DoorMechanism == EDM_Hinge )
	{
		OpenSwingingDoor(P);
	}

	//if( MyNavMeshObstacle != none )
	//{
	//	MyNavMeshObstacle.SetEnabled(false);
	//}

	SetTickIsDisabled(false);
	PlayMovingSound(false);
	MovementControl.SetSkelControlActive(true);

	if (OnDoorOpenEmitterTemplate.ParticleTemplate != none && (OnDoorOpenEmitter == none || !OnDoorOpenEmitter.bIsActive))
	{
		if (OnDoorOpenEmitter != none)
		{
			OnDoorOpenEmitter.DeactivateSystem();
		}

		Loc = Location + OnDoorOpenEmitterTemplate.RelativeOffset;
		Rot = Rotation + OnDoorOpenEmitterTemplate.RelativeRotation;

		OnDoorOpenEmitter = WorldInfo.MyEmitterPool.SpawnEmitter(OnDoorOpenEmitterTemplate.ParticleTemplate, Loc, Rot);
	}
}

/** Determine direction of hinge and push pawns back */
simulated private function OpenSwingingDoor(Pawn P)
{
	local vector X, Y, Z;
	local int DefaultYaw;

	if ( Role == ROLE_Authority )
	{
		GetAxes(Rotation, X, Y, Z);

		// (Server Only) if the animation is not playing update hinge direction
		if ( P != None && MovementControl.BlendTimeToGo <= 0 )
		{
			bReverseHinge = (X dot (P.Location - Location) > 0.f) ? false : true;
		}
	}
	DefaultYaw = Abs(MovementControl.BoneRotation.Yaw);
	MovementControl.BoneRotation.Yaw = ( bReverseHinge ) ? -DefaultYaw : DefaultYaw;
}

/** To close the door, just reverse the animation */
simulated function CloseDoor()
{
	if( bIsDestroyed || !bLocalIsDoorOpen || !bCanCloseDoor)
	{
	 	return;
	}

	// If door has been closed, it's dirty
	bHasBeenDirtied = true;

	bIsDoorOpen = false;
	bForceNetUpdate = true;
	bDoorMoveCompleted = false;

	// Local (non-replicated) open flag
	bLocalIsDoorOpen = false;

	SetTickIsDisabled(false);
	PlayMovingSound(true);

	//if( MyNavMeshObstacle != none )
	//{
	//	MyNavMeshObstacle.SetEnabled(true);
	//}

	MovementControl.SetSkelControlActive(false);

	if ( DoorMechanism == EDM_Hinge )
	{
		SetTimer(OpenBlendTime * 0.65, false, nameof(TryPushPawns));
	}
	else
	{
		SetTimer(OpenBlendTime * 0.5, false, nameof(TryPushPawns));
	}
}

/** Notification when a door finishes opening or closing */
event NotifyDoorMoveCompleted( bool bOpened )
{
    if( bOpened )
    {
        OnOpenFinish();
    }
    else
    {
        OnCloseFinish();
    }

    SetRBCollideWithDeadPawn(!bOpened);
}

/** Called once we've finished opening the door */
function OnOpenFinish()
{
	local DoorMarker DoorNav;

	if (AmbientSoundComponent != None)
	{
		AmbientSoundComponent.StopEvents();
	}

	DoorNav = DoorMarker(MyMarker);
	if (DoorNav != None)
	{
		if( bMonitorDoor )
		{
			NotifyAIDoorOpened();
		}
		DoorNav.MoverOpened();
	}

	if (OpenedSound != None)
	{
		PlaySoundBase(OpenedSound,,,, SoundOrigin);
	}
}

/** Called once we've finished closing the door */
function OnCloseFinish()
{
	local DoorMarker DoorNav;

	if (AmbientSoundComponent != None)
	{
		AmbientSoundComponent.StopEvents();
	}

	DoorNav = DoorMarker(MyMarker);
	if (DoorNav != None)
	{
		DoorNav.MoverClosed();
	}

	if (ClosedSound != None)
	{
		PlaySoundBase(ClosedSound,,,, SoundOrigin);
	}
}

/*********************************************************************************************
 * @name	Momentum Push
 ********************************************************************************************* */

// Used when a pawn is standing ontop of a door
function vector GetPushDirection( Vector PawnLocation )
{
	local bool bInFrontOfDoor;
	local vector DoorX, DoorY, DoorZ, PushDir;

    GetAxes(Rotation, DoorX, DoorY, DoorZ);
	bInFrontOfDoor = ( DoorX dot ( PawnLocation - Location ) > 0.f );

	PushDir = SlidingPushForce * DoorX;
	PushDir *= ( bInFrontOfDoor ) ? 1 : -1;
	PushDir.z = 50;

	return PushDir;
}

/** Called only if a a door closes on a pawn*/
private function TryPushPawns()
{
	local Pawn P;
	local bool bInFrontOfDoor;
	local vector DoorX, DoorY, DoorZ, PushDir, OffsetLocation;
	local rotator DoorYRot;

    GetAxes(Rotation, DoorX, DoorY, DoorZ);
	DoorYRot = rotator(DoorY);

	OffsetLocation = Location + DoorX;// * PushOriginOffset;

	foreach WorldInfo.AllPawns( class'Pawn', P, Location, DoorWidth )
	{
		if ( !P.IsAliveAndWell() )
			continue;

		if( !bIsDoorOpen && P.IsPlayerOwned() )
		{
			if( PointDistToPlane( OffsetLocation, DoorYRot, P.Location ) < HumanPushDistance )
			{
				bInFrontOfDoor = (DoorX dot (P.Location - OffsetLocation) > 0.f);
				PushDir = SlidingPushForce * DoorX;

	   			if( DoorMechanism == EDoorMechanism.EDM_Hinge )
				{
					if ( bReverseHinge )
					{
	                    PushDir *= -1;
					}
				}
				else
				{
					PushDir *= ( bInFrontOfDoor ) ? 1 : -1;
				}

                PushDir.Z += VerticalPushForce; //Small vertical fix to help the player avoid tripping over mesh edges in door frames
				P.AddVelocity( PushDir, P.Location, class'KFDT_Bludgeon');
			}
		}
		// prevent closing on an AI
		else if ( !bIsDoorOpen )
		{
			if( PointDistToPlane( Location, DoorYRot, P.Location ) < (0.85 * P.CylinderComponent.default.CollisionRadius) )
			{
				OpenDoor(None);
			}
		}
	}
}

/*********************************************************************************************
 * @name	Damage and Welding
 ********************************************************************************************* */

simulated function InitializeWeldableComponent()
{
	WeldableComponent.SetOwner(self);
	WeldableComponent.WeldIntegrity = (bStartWelded && !bStartDoorOpen) ? MaxWeldIntegrity : 0;
	WeldableComponent.MaxWeldIntegrity = MaxWeldIntegrity;
	WeldableComponent.DemoWeldRequired = DemoWeldRequired;
	WeldableComponent.bWeldable = true;
	WeldableComponent.bUnweldable = true;
	WeldableComponent.bRepairable = true;
	WeldableComponent.Delegate_AdjustWeldAmount = AdjustWeldCompWeldAmount;
	WeldableComponent.Delegate_OnWeldIntegrityChanged = OnWeldCompWeldIntegrityChanged;
	WeldableComponent.Delegate_OnRepairProgressChanged = OnWeldCompRepairProgressChanged;

	WeldableComponent.SetCollisionCylinderSize(200, 200);
}

function AdjustWeldCompWeldAmount(out int Amount)
{
	// reduce weld strength if it's being attacked
	if ( UnderAttack() )
	{
		Amount *= CombatWeldModifier;
	}
}

simulated function OnWeldCompWeldIntegrityChanged(int Amount, KFPawn Welder)
{
	if (Role == ROLE_Authority)
	{
		FastenWeld(Amount, Welder);
		WeldableComponent.SetWeldIntegrity(WeldIntegrity);
	}
	else
	{
		WeldIntegrity = WeldableComponent.WeldIntegrity;
		DemoWeld = WeldableComponent.DemoWeld;
		UpdateIntegrityMIC();
	}
}

simulated function OnWeldCompRepairProgressChanged(float Amount, KFPawn Welder)
{
	if (Role == ROLE_Authority)
	{
		Repair(Amount, Welder);
	}
	else
	{
		RepairProgress = WeldableComponent.RepairProgress;
	}
}

/** When welded shut, do damage to the door */
event TakeDamage(int Damage, Controller EventInstigator, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local KFPawn_Monster KFPM;
	local KFCharacterInfo_Monster MonsterInfo;
	local class<KFDamageType> KFDT;

	if ( Role < ROLE_Authority )
	{
		return;
	}

	if (!bIsInteractive)
	{
		return;
	}

	// call Actor's version to handle any SeqEvent_TakeDamage for scripting
	Super.TakeDamage(Damage, EventInstigator, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);

    // check can be damaged
	if ( bIsDestroyed || !AllowDamageFrom(EventInstigator, DamageType) )
	{
		return;
	}

	// If the door is welded damage the health and the weld integrity
	if ( WeldIntegrity > 0 )
	{
		KFPM = KFPawn_Monster(DamageCauser);
		if( KFPM != none )
		{
			MonsterInfo = KFPM.GetCharacterMonsterInfo();
			if( MonsterInfo != none )
			{
				PlaySoundBase(GetSoundEffectFromType(MonsterInfo),,,, SoundOrigin);
			}
		}

		if ( Health > 0 )
		{
			Health = Max(Health - Damage, 0 );
			UpdateHealthMICs();
		}

		UpdateWeldIntegrity(-Damage);
		WeldableComponent.UpdateWeldIntegrity(-Damage);

		// if weld is broken
		if ( WeldIntegrity <= 0 || Health <= 0 )
		{
			DestroyDoor( EventInstigator );
		}

		if ( !bIsDestroyed )
		{
			IncrementHitCount( EventInstigator.Pawn );
			PlayTakeHitEffects();
		}

		`DialogManager.PlayDoorTakeDamageDialog( self );

		LastHitTime = WorldInfo.TimeSeconds;
		bForceNetUpdate = true;
	}
	// failsafe for AI deciding to attack the door instead of opening it
	else if( !bIsDoorOpen && EventInstigator != none && EventInstigator.Pawn != none && EventInstigator.GetTeamNum() == 255 )
	{
		KFDT = class<KFDamageType>( DamageType );
		if( KFDT != none && KFDT.default.bAllowAIDoorDestruction )
		{
			IncrementHitCount( EventInstigator.Pawn );
			DestroyDoor( EventInstigator );
		}
		else if( class<KFDT_Ballistic>(DamageType) == none )
		{
			OpenDoor( EventInstigator.Pawn );
		}
	}
}

/** Destroys this door */
function DestroyDoor( optional Controller DestructionInstigator )
{
	WeldIntegrity = 0;
	DemoWeld = 0;
	Health = 0;

	WeldableComponent.SetWeldIntegrity(0);
	WeldableComponent.SetDemoWeld(0);

	//UpdateHealthMICs();
    UpdateIntegrityMIC();

	// Weld and health are gone, destroy the door!
	PlayDestroyed();

	if( MyMarker != none && bMonitorDoor )
	{
		`RecordAIDestroyedDoor( KFAIController(DestructionInstigator), self, "Health:"$Health );
		NotifyAIDoorOpened();
	}
}

/** Returns true if the specificed damage causer can damage this door */
function bool AllowDamageFrom(Controller EventInstigator, class<DamageType> DamageType)
{
	// Human team (0) can only do explosive damage
	if ( EventInstigator == none || (EventInstigator.GetTeamNum() == 0 && class<KFDT_Explosive>(DamageType) == none) )
	{
		return false;
	}
	return true;
}

/** Increase the weld integrity - Network: Server only */
function FastenWeld(int Amount, optional KFPawn Welder)
{
	local KFPlayerController PC;
	local KFPerk WelderPerk;

	if ( bIsDestroyed )
	{
		return;
	}

	// handle unfasten
	if ( Amount < 0 )
	{
		if ( WeldIntegrity > 0 )
		{
			UpdateWeldIntegrity(Amount);

			if( !BeingWelded() )
			{
				if( !BeingUnwelded() )
				{
					WelderPawn = Welder;
				}
			}

			`DialogManager.PlayUnweldDialog( Welder, self, WelderPawn );

			if( WelderPawn == Welder )
			{
				LastUnweldTime = WorldInfo.TimeSeconds;
			}
		}

		if( WeldIntegrity <= 0 )
		{
			bShouldExplode = false;
			DemoWeld = 0;
			ExplosionInstigatorController = none;

			WeldableComponent.SetDemoWeld(0);
		}
	}
	// handle fasten
	else if ( !bIsDoorOpen && WeldIntegrity < MaxWeldIntegrity )
	{
		PC = KFPlayerController(Welder.Controller);
		if ( PC != None )
		{
			PC.AddWeldPoints(Amount);
		}

		// reduce weld strength if it's being attacked
		if ( UnderAttack() )
		{
			Amount *= CombatWeldModifier;
		}

		WelderPerk = PC.GetPerk();
		if( WelderPerk != none && WelderPerk.CanExplosiveWeld() )
		{
			AddExplosiveWeld( Amount, PC );
		}

		// If weld integrity has increased from 0, it's dirty
		bHasBeenDirtied = true;

		UpdateWeldIntegrity(Amount);

		if( WeldIntegrity == MaxWeldIntegrity )
		{
			PC.UnlockHoldOut();
		}

		if( !BeingUnwelded() )
		{
			if( !BeingWelded() )
			{
				WelderPawn = Welder;
			}
		}

		`DialogManager.PlayWeldDialog( Welder, self, WelderPawn );

		if( WelderPawn == Welder )
		{
			LastWeldTime = WorldInfo.TimeSeconds;
		}
	}
	else if( !bIsDoorOpen && WeldIntegrity >= MaxWeldIntegrity &&
			  DemoWeld < DemoWeldRequired )
	{
		PC = KFPlayerController(Welder.Controller);
		if ( PC != None )
		{
			WelderPerk = PC.GetPerk();
			if( WelderPerk != none && WelderPerk.CanExplosiveWeld() )
			{
				AddExplosiveWeld( Amount, PC );
				UpdateIntegrityMIC();
				bForceNetUpdate = true;
			}
		}
	}
	else if ( bIsDoorOpen )
	{
		CloseDoor();
	}
}

simulated function CompleteRepair()
{
	ResetDoor(true);
}

/** Increase the weld integrity - Network: Server only */
function Repair(float Amount, optional KFPawn Welder)
{
	local byte ByteAmount;
    local KFPlayerController KFPC;

	if ( bIsDestroyed )
	{
		ByteAmount = FloatToByte(Amount);
		if ( RepairProgress + ByteAmount >= 255 )
		{
			CompleteRepair();
			if( WorldInfo.NetMode != NM_StandAlone )
			{
				bWasRepaired = true;
				SetTimer( 0.1f, false, nameOf(Timer_ResetRepairFlag) );
			}

            if (Welder != none)
            {
                KFPC = KFPlayerController(Welder.Controller);
                if (KFPC != none)
                {
                    KFPC.DoorRepaired();
                }
            }
		}
		else
		{
			RepairProgress += ByteAmount;
		}

		bForceNetUpdate = true;
	}
}

/** Restores repair flag to FALSE so door can be repaired later */
function Timer_ResetRepairFlag()
{
	bWasRepaired = false;
}

function AddExplosiveWeld( int Amount, KFPlayerController PC )
{
	super.AddExplosiveWeld(Amount, PC);
	if( DemoWeld >= DemoWeldRequired && !bShouldExplode )
	{
		ExplosionInstigatorController = PC;
		bShouldExplode = true;
		bForceNetUpdate = true;
	}
}

function bool CanExplosiveWeld()
{
	return true;
}

/*********************************************************************************************
 * @name	Animation & FX
 ********************************************************************************************* */

/**
 * This function's responsibility is to signal clients to play hit effects on the door
 *
 * Network: Server
 */
function IncrementHitCount( Pawn P )
{
	local vector X, Y, Z;

	if ( !bIsDoorOpen && P != none )
	{
		bForceNetUpdate = true;
	    GetAxes(Rotation, X, Y, Z);
	    HitCount++;

	    if (X dot (P.Location - Location) > 0.f)
		{
			// Set the last bit to indicate the hit direction
	     	HitCount = HitCount | HIT_DIRECTION_FLAG;
		}
		else
		{
			// Clear out the last bit to indicate the hit direction
	     	HitCount = HitCount & byte(~HIT_DIRECTION_FLAG);
		}
	}
}

/** Play bash animations, particle effects, and destruction effects */
simulated function PlayTakeHitEffects()
{
	local name AnimName;
	local bool bReverseDir; // if true rotate the direction of the particle effect and bash anim

	if ( bIsDestroyed || bIsDoorOpen || WorldInfo.NetMode == NM_DedicatedServer )
	{
	 	return;
	}

    SetTickIsDisabled(false);

	if ( `TimeSince(CreationTime) > 1.0f && ActorEffectIsRelevant(Instigator, false) )
	{
		bReverseDir = (HitCount & HIT_DIRECTION_FLAG) > 0;
		AnimName = GetBashAnimName(bReverseDir);
		BashSlot.PlayCustomAnim( AnimName, 1.f );
		SpawnParticlesFromEffectParam( DamageEmitter, bReverseDir );
	}
}

/** Returns name of animation to play when hit by zed */
simulated function name GetBashAnimName(bool bReverse)
{
	if ( DoorMechanism == EDM_Hinge )
	{
		return (bReverse) ? BashHingedAnim_F : BashHingedAnim_B;
	}
	return (bReverse) ? BashSlidingAnim_F : BashSlidingAnim_B;
}

/** Spawn and offset particle effects according to how the mapper set it up */
simulated function SpawnParticlesFromEffectParam( DestroyedEffectParams EffectParam, optional bool bReverseDir )
{
	local Vector Loc;
	local Rotator Rot;

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	if ( EffectParam.ParticleEffect != none )
	{
		Loc = Location + EffectParam.RelativeOffset;
	    Rot = Rotation + EffectParam.RelativeRotation;
	    Rot.Yaw += ( bReverseDir ) ? 32768 : 0;
		BrokenDoorParticleEffects.AddItem( WorldInfo.MyEmitterPool.SpawnEmitter(EffectParam.ParticleEffect, Loc, Rot) );
	}
}

/** Activates the doors physics assets and particles once a door is destroyed */
simulated function PlayDestroyed()
{
	bForceNetUpdate = true;
    SetTickIsDisabled(false);

	bIsDestroyed = true;

	RepairProgress = 0;
    WeldIntegrity = 0;

	WeldableComponent.SetDestroyed(true);
	WeldableComponent.SetRepairProgress(0);
	WeldableComponent.SetWeldIntegrity(0);

	// If door is destroyed, it's dirty
	bHasBeenDirtied = true;

	if ( DestroyedSound != None )
	{
		PlaySoundBase(DestroyedSound,,,, SoundOrigin);
	}

	if ( DoorMechanism == EDM_Hinge )
	{
      	DestroyHingedDoor();
	}
	else
	{
    	DestroyNonPhysicsDoor();
	}

	if( bShouldExplode )
	{
		//blowup
		PlayExplosion();
		bShouldExplode = false;
	}

	// notify owning trigger
	DoorTrigger.OnDestroyOrReset();
}

simulated function PlayExplosion()
{
	local KFExplosionActor ExploActor;
	local GameExplosion	ExplosionTemplate;
	local KFPawn ExplosionInstigator;
	local KFPerk InstigatorPerk;
	local class<KFExplosionActor> KFEAR;

	if ( Role < ROLE_Authority )
	{
		return;
	}

	ExplosionInstigator = KFPawn(ExplosionInstigatorController.Pawn);
	InstigatorPerk = ExplosionInstigator.GetPerk();
	if( ExplosionInstigator != none && InstigatorPerk != none )
	{
		KFEAR = InstigatorPerk.DoorShouldNuke() ? class'KFPerk_Demolitionist'.static.GetNukeExplosionActorClass() : class'KFExplosionActorReplicated';
		ExploActor = Spawn(KFEAR, self,, DoorTrigger.Location,,, true);

		if( ExploActor != None )
		{
			ExploActor.InstigatorController = ExplosionInstigatorController;
			ExploActor.Instigator = ExplosionInstigator;

			ExplosionTemplate = InstigatorPerk.DoorShouldNuke() ? class'KFPerk_Demolitionist'.static.GetNukeExplosionTemplate() : class'KFPerk_Demolitionist'.static.GetDoorTrapsExplosionTemplate();
			ExplosionTemplate.Damage = class'KFPerk_Demolitionist'.static.GetDoorTrapsExplosionTemplate().Damage;
			ExploActor.Explode( ExplosionTemplate );
		}
	}
}

/** If the door is sliding or lifting then only play particle effects and open the door */
simulated function DestroyNonPhysicsDoor()
{
	local byte i;

	for( i = 0; i < DestroyedEmitters.Length; i++ )
	{
		SpawnParticlesFromEffectParam( DestroyedEmitters[i] );
	}

	// @todo: move to destroyed (use blend in time)
	if ( DoorMechanism == EDM_Slide )
	{
		BashSlot.PlayCustomAnim('Door_Slide_broken', 1.f, 0.15f, 0.2f, true, true);
    }
}

/** Restores this door to the way it was at the start of a map */
simulated function ResetDoor( optional bool bRepaired )
{
	local int i;
	local DoorMarker DoorNav;

	// Reset server-controlled variables and force an update
	if( Role == ROLE_Authority )
	{
		Health = MaxHealth;
	    bIsDestroyed = false;
	    bShouldExplode = false;
		WeldIntegrity = 0;
	    DemoWeld = 0;

		WeldableComponent.SetDestroyed(false);
		WeldableComponent.SetWeldIntegrity(0);
		WeldableComponent.SetDemoWeld(0);

	    // Only open door if this wasn't a repair
	    if( bRepaired )
	    {
		    bIsDoorOpen = false;
		}
		else
		{
			bIsDoorOpen = true;
		}

		// Update clients immediately
		bNetDirty = true;
	 	bForceNetUpdate = true;
	}

	// Reset non-replicated variables
	ExplosionInstigatorController = none;
 	bDoorMoveCompleted = true;
 	bHasBeenDirtied = false;

	// Door has not been dirtied and does not need to be ticked yet
    SetTickIsDisabled( true );

    // Reset hinged doors a little differently
   	if( DoorMechanism == EDM_Hinge )
	{
      	ResetHingedDoor( bRepaired );
	}
	else
	{
		BashSlot.StopCustomAnim( 0 );
	}

	// Restore door to closed position if this was a repair
	if( bRepaired )
	{
		bLocalIsDoorOpen = false;

		// Set rigid body collision params
	    SetRBCollideWithDeadPawn( true );

		MovementControl.SetSkelControlStrength( 0.f, 0.f );

		// Need to push any pawns out of door collision (they could get stuck!)
		TryPushPawns();
	}
	else
	{
		bLocalIsDoorOpen = true;

		// Otherwise it stays open
		MovementControl.SetSkelControlStrength( 1.f, 0.f );

		// Set rigid body collision params
	    SetRBCollideWithDeadPawn( false );
	}
	SkeletalMeshComp.ForceSkelUpdate();

	// Make sure door is considered open by AI (if not a repair)
	if( bMonitorDoor && !bRepaired )
	{
		DoorNav = DoorMarker(MyMarker);
		if (DoorNav != None)
		{
			DoorNav.MoverOpened();
		}
		bMonitorDoor = false;
	}
	else if( bRepaired )
	{
		// We need to notify AI that this door is no longer open
		DoorNav = DoorMarker(MyMarker);
		if (DoorNav != None)
		{
			DoorNav.MoverClosed();
		}
	}

	// Update health MIC scalars
	UpdateHealthScalars( 'doorHealthA', 0 );
	UpdateHealthScalars( 'doorHealthB', 0 );
	UpdateHealthScalars( 'doorHealthC', 0 );
	UpdateHealthScalars( 'doorHealthD', 0 );

	// Stop any sounds that might have been playing
	if( AmbientSoundComponent != none && AmbientSoundComponent.IsPlaying() )
	{
		AmbientSoundComponent.StopEvents();
	}

	// Delete broken door particle effects and empty cache
	for( i = 0; i < BrokenDoorParticleEffects.Length; ++i )
	{
		if( BrokenDoorParticleEffects[i] != none && BrokenDoorParticleEffects[i].bIsActive )
		{
			BrokenDoorParticleEffects[i].DeactivateSystem();
		}
	}
	BrokenDoorParticleEffects.Length = 0;

	// Delete broken door particle effects and empty cache
	for( i = 0; i < BrokenDoorPhysicsActors.Length; ++i )
	{
		BrokenDoorPhysicsActors[i].Destroy();
	}
	BrokenDoorPhysicsActors.Length = 0;

	// When repaired, spawn an effect and play a sound
	if( bRepaired && RepairFXTemplate.ParticleTemplate != none && WorldInfo.MyEmitterPool != none )
	{
		WorldInfo.MyEmitterPool.SpawnEmitter( RepairFXTemplate.ParticleTemplate, VisualDoorLocation + RepairFXTemplate.RelativeOffset, rotator(vect(0,0,1)) + RepairFXTemplate.RelativeRotation, self );
		PlaySoundBase( RepairSound,,,, VisualDoorLocation );
	}

	// notify owning trigger
	DoorTrigger.OnDestroyOrReset();
}

/** As the door takes damage, scale its damage paramaters to make it look more beaten */
simulated function UpdateHealthMICs()
{
	local float HealthScaler;

	// Leave the MIC alone when destroyed.  Otherwise, when health is automatically
	// zeroed because of a broken weld there will be a pop (bug #24270)
	if ( Health <= 0 )
	{
		return;
	}

	// If health has dropped, it's dirty
	if( Health < MaxHealth )
	{
		bHasBeenDirtied = true;
	}

	if ( HealthMICs.Length > 0 )
	{
		HealthScaler = 1.f - (float(Health) / float(MaxHealth));

		// Stagger the door damage parameters and scale them so they will reach 1.f at the same time
		UpdateHealthScalars('doorHealthA', HealthScaler);
		if ( HealthScaler >= 0.25f )
		{
			UpdateHealthScalars('doorHealthB', ( HealthScaler - 0.25f ) * 1.32f);
		}
		if ( HealthScaler >= 0.5f )
		{
			UpdateHealthScalars('doorHealthC', ( HealthScaler - 0.5f ) * 2.f);
		}
		if ( HealthScaler >= 0.75f )
		{
			UpdateHealthScalars('doorHealthD', ( HealthScaler - 0.75f ) * 4.f);
		}
	}
}

/** Iterates over all stored health mics and updates their health scalars */
simulated function UpdateHealthScalars(name ScalarName, float Value)
{
	local byte i;

	for( i = 0; i < HealthMICs.Length; i++ )
	{
		HealthMICs[i].SetScalarParameterValue(ScalarName, Value);
	}
}

/** As the door is welded, update the integrityMic to visualize how strong the weld is */
simulated function UpdateIntegrityMIC()
{
	local float IntegrityScaler, ExplosiveScaler;
	local KFDoorMarker DoorMarker;
	local int AttackerCount, QueuedCount;

	if ( IntegrityMIC != none )
	{
		// Have a minimum IntegrityScalar if we have any weld integrity so that
		// the weld will always be at least partially visible on the door
		if(WeldIntegrity > 0)
		{
			// If weld integrity has increased from 0, it's dirty
			bHasBeenDirtied = true;

			IntegrityScaler = FMax(float(WeldIntegrity) / float(MaxWeldIntegrity), MinWeldScalar);
		}
		else
		{
			IntegrityScaler = 0;
		}

		IntegrityMIC.SetScalarParameterValue('doorWeld', IntegrityScaler);

		ExplosiveScaler = bShouldExplode ? 1.f : 0.f;
		IntegrityMIC.SetScalarParameterValue( 'scalar_explosive', ExplosiveScaler );

        if (CenterWeldComponent != none)
        {
            if (CenterWeldComponent.HiddenGame && WeldIntegrity > 0)
            {
                CenterWeldComponent.SetHidden(false);
            }
            else if (!CenterWeldComponent.HiddenGame && WeldIntegrity <= 0)
            {
                CenterWeldComponent.SetHidden(true);
            }
        }
	}

	if( WorldInfo.NetMode != NM_Client && WeldIntegrity > 0 && MyMarker != none )
	{
		DoorMarker = KFDoorMarker( MyMarker );
		if( DoorMarker != none )
		{
			GetQueuedDoorAICounts( AttackerCount, QueuedCount );
			DoorMarker.UpdatePathingCost( AttackerCount, QueuedCount );
		}
	}
}

/*********************************************************************************************
 * @name	RB Physics
 ********************************************************************************************* */

/** Since zeds can move through open doors we need to also allow their corpses to do the same */
simulated function SetRBCollideWithDeadPawn(bool bEnabled)
{
	local int i;

	// Apply the MIC to our door components
	for ( i = 0; i < MeshAttachments.length; i++ )
	{
		MeshAttachments[i].Component.SetRBCollidesWithChannel(RBCC_DeadPawn, bEnabled);
	}
}

/** Hinged doors are special and need to physics assets */
simulated function DestroyHingedDoor()
{
	local bool bReverseDir;  // if true rotate the direction of the particle effect and impulse
	local byte i;

	SkeletalMeshComp.bComponentUseFixedSkelBounds = false;

	// If the map was just loaded skip physics and go straight to hide
	if ( `TimeSince(CreationTime) > 1.0f )
	{
		bCallRigidBodyWakeEvents = true;
        bReverseDir = (HitCount & HIT_DIRECTION_FLAG) > 0;
		// Play the destroyed particle effect
		for( i = 0; i < DestroyedEmitters.Length; i++ )
		{
			SpawnParticlesFromEffectParam( DestroyedEmitters[i], bReverseDir );
		}

		SpawnBrokenDoors( bReverseDir );
	}
	else
	{
    	// If we are joining a game with broken doors, make them invisible
     	for( i = 0; i < MeshAttachments.Length; i++ )
		{
			MeshAttachments[i].Component.SetBlockRigidBody(false);
			MeshAttachments[i].Component.SetActorCollision(false, false);
			MeshAttachments[i].Component.SetHidden( true );
		}
	}
}

simulated function SpawnBrokenDoors( bool bReverseDir )
{
	local KFKActorSpawnable_Door SpawnedKActor;
	local Name BoneName;
	local vector DoorX, DoorY, DoorZ, InitAngVel;
	local Vector AttachmentLocation;
	local Rotator AttachmentRotation;
	local byte i;

	GetAxes(Rotation, DoorX, DoorY, DoorZ);
	DoorX *= ( bReverseDir ) ? -1 : 1;

	for( i = 0; i < MeshAttachments.Length; i++ )
	{
		BoneName = MeshAttachments[i].AttachTo;

		AttachmentLocation = SkeletalMeshComp.GetBoneLocation( BoneName ) + ( DoorX * KActorOffset );
		AttachmentRotation = QuatToRotator( SkeletalMeshComp.GetBoneQuaternion( BoneName ) ) + MeshAttachments[i].Component.Rotation;

		if( WorldInfo.NetMode != NM_DedicatedServer )
		{
			SpawnedKActor = Spawn(class'KFKActorSpawnable_Door', self,, AttachmentLocation, AttachmentRotation );
			if( SpawnedKActor != none && MeshAttachments[i].Component != none )
			{
				InitBrokenAttachment( MeshAttachments[i].Component, SpawnedKActor );

				SpawnedKActor.StaticMeshComponent.SetRBLinearVelocity( DoorX * BrokenDoorImpulse );

				// Set initial angular velocity
				InitAngVel.X = MaxAngularVelocity * FRand();
				InitAngVel.Y = MaxAngularVelocity * FRand();
				InitAngVel.Z = MaxAngularVelocity * FRand();
				SpawnedKActor.StaticMeshComponent.SetRBAngularVelocity( InitAngVel );

				// Start awake
				SpawnedKActor.StaticMeshComponent.WakeRigidBody();

				// Add to array so we can delete these when the door needs to be repaired
				BrokenDoorPhysicsActors.AddItem( SpawnedKActor );
			}
		}

		if( MeshAttachments[i].Component != none )
		{
			// Hide the original attachment
			MeshAttachments[i].Component.SetHidden( true );
			MeshAttachments[i].Component.SetBlockRigidBody(false);
			MeshAttachments[i].Component.SetActorCollision(false, false);
		}
	}
}

/** Hinged doors are special and need to reset physics pieces and collision */
simulated function ResetHingedDoor( optional bool bRepaired )
{
	local byte i;

 	for( i = 0; i < MeshAttachments.Length; i++ )
	{
		MeshAttachments[i].Component.SetBlockRigidBody(true);
		MeshAttachments[i].Component.SetActorCollision(true, true);
		MeshAttachments[i].Component.SetHidden( false );
	}

	// Repaired doors start closed
	if( !bRepaired )
	{
		OpenSwingingDoor( none );
	}

	SkeletalMeshComp.bComponentUseFixedSkelBounds = TRUE;
}

/*********************************************************************************************
 * @name	Dialog & Sound
 ********************************************************************************************* */

/** Based on InterpActor::PlayMovingSound */
simulated private function PlayMovingSound(bool bClosing)
{
	local AkBaseSoundObject SoundToPlay;
	local AkBaseSoundObject AmbientToPlay;

	if (bClosing)
	{
		SoundToPlay = CloseSound;
		AmbientToPlay = OpeningAmbientSound;
	}
	else
	{
		SoundToPlay = OpenSound;
		AmbientToPlay = ClosingAmbientSound;
	}

	if (SoundToPlay != None)
	{
		PlaySoundBase(SoundToPlay, true,,, SoundOrigin);
	}

	if (AkEvent(AmbientToPlay) != None)
	{
		AmbientSoundComponent.StopEvents();
		AmbientSoundComponent.PlayEvent( AkEvent(AmbientToPlay) );
	}
}

function AkEvent GetSoundEffectFromType(KFCharacterInfo_Monster DamagingMonsterInfo)
{
	switch (DoorMaterial)
	{
		case EDMT_Metal:
			return DamagingMonsterInfo.DoorHitSound.Metal;
			break;
		case EDMT_Wood:
			return DamagingMonsterInfo.DoorHitSound.Wood;
			break;
	}
}

function bool UnderAttack()
{
	return `TimeSince(LastHitTime) < CombatLength;
}

/*********************************************************************************************
 * @name	AI Behavior & Navigation
 ********************************************************************************************* */

/** Door is welded shut*/
function bool WeldedShut()
{
    return !IsCompletelyOpen() && WeldIntegrity > 0;
}

/** Alerts NPCs that door they're waiting for has been destroyed or opened */
function NotifyAIDoorOpened()
{
	local DoorMarker DoorNav;
	local KFAIController KFAIC;

	DoorNav = DoorMarker( MyMarker );
	if( DoorNav != None )
	{
		if( bMonitorDoor )
		{
			// notify any Controllers with us as PendingDoor that we have finished moving
			foreach WorldInfo.AllControllers(class'KFAIController', KFAIC)
			{
				if( KFAIC.PendingDoor == self )
				{
					KFAIC.DoorFinished();
				}
 				// Notify other NPCs who might have been waiting around for another door [WIP]
// 				else if( C.PendingDoor != none && C.PendingDoor != self && C.PendingDoor.WeldIntegrity > 0 )
// 				{
// 					MTG = AICommand_MoveToGoal( C.GetActiveCommand() );
// 					if( MTG != none )
// 					{
// 						MTG.bValidRouteCache = false;
// 						C.bReevaluatePath = true;
// 						MTG.CreateTemporaryBlockedPath( C.PendingDoor.MyMarker );
// 						C.ForcePauseAndRepath();
// 					}
// 				}
			}
		}
		DoorNav.MoverOpened();
	}
}

/*********************************************************************************************
 * @name	HUD
 ********************************************************************************************* */

simulated event DrawDoorHUD( HUD HUD, Canvas C )
{
	local PlayerController	PC;
	local Vector	CameraLoc, ScreenLoc;
	local Rotator	CameraRot;
	local float		X, Y;
	local float DOT;

	PC = HUD.PlayerOwner;
	C.SetDrawColor(255,255,255);
	C.Font = class'KFGameEngine'.Static.GetKFCanvasFont();
	// project location onto the hud
	PC.GetPlayerViewPoint( CameraLoc, CameraRot );

	Dot = vector(CameraRot) dot (Location - CameraLoc);
	if( Dot < 0.5f )
	{
		return;
	}
	ScreenLoc = C.Project( WeldUILocation );
	if( ScreenLoc.X < 0 || ScreenLoc.X + WelderIcon.SizeX * 3 >= C.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= C.ClipY)
	{
		return;
	}
	C.SetPos(ScreenLoc.X - WelderIcon.SizeX / 2, ScreenLoc.Y - WelderIcon.SizeY / 2, ScreenLoc.Z);
	C.DrawTexture( WelderIcon, 1.f );

	X = ScreenLoc.X + WelderIcon.SizeX/2 + 5;
	Y = ScreenLoc.Y - WelderIcon.SizeY/2;
	C.SetPos( X, Y );

	if ( bIsDestroyed )
	{
		DrawRepairHUD( C, HUD );
	}
	else
	{
		DrawWeldHUD( C, HUD, X, Y );
	}
}

simulated function DrawWeldHUD( Canvas C, HUD HUD, float PosX, float PosY )
{
	local float WeldPercentageFloat;
	local int WeldPercentage;
	local float FontScale;
	local FontRenderInfo FRI;
	local String Str;

	FRI.bClipText = true;
		// Display weld integrity as a percentage
	FontScale = class'KFGameEngine'.Static.GetKFFontScale();
	WeldPercentageFloat = (float(WeldIntegrity) / float(MaxWeldIntegrity)) * 100.0;
	if( WeldPercentageFloat < 1.f && WeldPercentageFloat > 0.f )
	{
		WeldPercentageFloat = 1.f;
	}
	else if( WeldPercentageFloat > 99.f && WeldPercentageFloat < 100.f )
	{
		WeldPercentageFloat = 99.f;
	}
	WeldPercentage = WeldPercentageFloat;
	Str = WeldIntegrityString@WeldPercentage$"%";
	C.DrawText( Str, TRUE, FontScale, FontScale, FRI );

	if( DemoWeld > 0 && !bShouldExplode )
	{
		C.SetPos( PosX, PosY + 20.f );
		WeldPercentage = float(DemoWeld) / float(DemoWeldRequired) * 100.0;
		Str = ExplosiveString@WeldPercentage$"%";
		C.DrawText( Str, TRUE, FontScale, FontScale, FRI );
	}
}

simulated function DrawRepairHUD( Canvas C, HUD HUD )
{
	local float RepairPercentageFloat;
	local int RepairPercentage;
	local float FontScale;
	local FontRenderInfo FRI;
	local String Str;

	FRI.bClipText = true;

	// Display weld integrity as a percentage
	FontScale = class'KFGameEngine'.Static.GetKFFontScale();
	RepairPercentageFloat = ( float(RepairProgress) / 255.f ) * 100.0;
	if( RepairPercentageFloat > 99.f && RepairPercentageFloat < 100.f )
	{
		RepairPercentageFloat = 99.f;
	}
	RepairPercentage = int( RepairPercentageFloat );
	Str = RepairProgressString @ RepairPercentage $ "%" ;
	C.DrawText( Str, TRUE, FontScale, FontScale, FRI );
}

/** Outputs the number of AI attacking and/or queued for this door */
function GetQueuedDoorAICounts( out int DoorAttackers, out int DoorQueuers )
{
	local KFAIController KFAIC;

	foreach WorldInfo.AllControllers( class'KFAIController', KFAIC )
	{
		if( KFAIC.DoorEnemy == self )
		{
			++DoorAttackers;
		}
		else if( KFAIC.PendingDoor == self )
		{
			++DoorQueuers;
		}
	}
}

/** Scalar to use in KFMeleeHelperAI to break doors faster when more zeds are piled on it */
function float GetAIDoorDamageScale()
{
	local int AttackerCount, QueuedCount;

	GetQueuedDoorAICounts( AttackerCount, QueuedCount );

	return 1.f + fMin( float(AttackerCount) * 0.1f, 1.f );
}

/**
 * Level was reset without reloading
 * Network: ALL. Called on clients to avoid issues that could arise from players joining in progress
 * and thinking they need to reset this actor when they don't.
 */
simulated function Reset()
{
	if( bHasBeenDirtied )
	{
		ResetDoor();
	}
}

simulated function SetInteractive(bool InInteractive)
{
	if (Role == ROLE_Authority)
	{
		bIsInteractive = InInteractive;
		DoorTrigger.SetCollision(InInteractive, DoorTrigger.bBlockActors);
	}
}

defaultproperties
{
	Begin Object Class=SpriteComponent Name=Sprite
		Sprite=Texture2D'EditorResources.door'
		HiddenGame=true
		AlwaysLoadOnClient=False
		AlwaysLoadOnServer=False
		Translation=(X=40,Z=40)
	End Object
	Components.Add(Sprite)

 	// UI
	WelderIcon=Texture2D'UI_World_TEX.welder_door_icon'

	bIsInteractive=true

	bDoorMoveCompleted=true
	bStartDoorOpen=true
    bStartWelded=false

	OpenBlendTime=0.5f
	HingedRotation=90
	SlideTranslation=-100
	LiftTranslation=245

	// actor
	Physics=PHYS_None
	bEdShouldSnap=true
	bStatic=false
	bNoDelete=true
	bTickIsDisabled=true
	CooldownTime=0.5f

	// network
	RemoteRole=ROLE_SimulatedProxy
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bSkipActorPropertyReplication=true
	bIgnoreNetRelevancyCollision=true
	NetUpdateFrequency=0.1	// uses bForceNetUpdate
	bReplicateRigidBodyLocation=true

	// collision
	bCollideActors=true
	bBlockActors=true
	bWorldGeometry=true
	bCollideWorld=false
	bNoEncroachCheck=false
	bProjTarget=true
	bCanStepUpOn=false

	// health
	MaxHealth=4000
	MaxWeldIntegrity=1500
	CombatWeldModifier=0.6
	bCanBeDamaged=true
	CombatLength=1.25
	MinWeldScalar=0.08

	// Explosive weld
	DemoWeldRequired=500

	// forces
	BrokenDoorImpulse=750
	MaxAngularVelocity=2

	// ---------------------------------------------
	// Door Meshes

    FrameSizeOfTwoDoors=SkeletalMesh_Width
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		bUseTickOptimization=FALSE	// need to turn this off because there is no skeletal geometry
		SkeletalMesh=SkeletalMesh'ENV_Doors_Mesh.ENV_Door_Base'
		AnimSets(0)=AnimSet'ENV_Doors_ANIM.Door_Base_Animation'
		AnimTreeTemplate=AnimTree'ENV_Doors_ANIM.ENV_Doors_AnimTree'
		Animations=none
		BlockRigidBody=false
		HiddenGame=true
		HiddenEditor=true
		CollideActors=TRUE
	End Object
 	CollisionComponent=SkeletalMeshComponent0
	SkeletalMeshComp=SkeletalMeshComponent0
	Components.Add(SkeletalMeshComponent0)

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		// Collision
		CollideActors=TRUE
		BlockActors=TRUE
		BlockRigidBody=TRUE
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,DeadPawn=FALSE,Pickup=TRUE,FlexAsset=FALSE)
	End Object

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent1
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		Rotation=(Pitch=32768) // compensate for bone orientation (for uniform SkelControl)
		// Collision
		CollideActors=TRUE
		BlockActors=TRUE
		BlockRigidBody=TRUE
		RBChannel=RBCC_GameplayPhysics
		RBCollideWithChannels=(Default=TRUE,GameplayPhysics=TRUE,EffectPhysics=TRUE,DeadPawn=FALSE,Pickup=TRUE,FlexAsset=FALSE)
	End Object

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent2
		bAllowApproximateOcclusion=TRUE
		bForceDirectLightMap=TRUE
		bUsePrecomputedShadows=TRUE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
		CollideActors=FALSE
		BlockRigidBody=FALSE
	End Object
    CenterWeldComponent=StaticMeshComponent2

	MeshAttachments.Add((Component=StaticMeshComponent0, AttachTo=DoorLeft))
	MeshAttachments.Add((Component=StaticMeshComponent1, AttachTo=DoorRight))

	RepairFXTemplate=(ParticleTemplate=ParticleSystem'FX_Gameplay_EMIT_TWO.FX_Door_Repair_Complete_01')
	RepairSound=AkEvent'WW_ENV_Destruction.Play_Door_Heal'

	//NavigationHandleClass=class'KFNavigationHandle'

	bCanCloseDoor=true
}
