//=============================================================================
// KFSM_RagdollKnockdown
//=============================================================================
// Sends pawn into a temporary ragdoll
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFSM_RagdollKnockdown extends KFSpecialMove;

/** If falling past this distance during knockdown kill pawn */
var(Physics) float  KnockdownMaxZ;

/** maximum number of pawns that can use this SM at once */
var const int MaxKnockdownPawns;

var transient vector KnockdownStartLoc;

/** Dazed particle effect */
var transient ParticleSystemComponent DazedPSC;

//failsafe 
var int MaxKnockDownTests;
var int CurrentKnockdownTests;

protected function bool InternalCanDoSpecialMove()
{
	local Pawn P;
	local int KnockdownCount;
	local bool bMayHavePartialKinematics;

	// If we have a dismembered limb (partial kinematics), then we don't want to apply
	// impulses via SetRBLinearVelocity.  For now, just prevent the knockdown.
	// @note: have to make some assumptions because gore is handled clientside
	bMayHavePartialKinematics = KFPOwner.IsHeadless();
	if ( bMayHavePartialKinematics )
	{
		return false;
	}

	// fast (no-cast) count of knocked down pawns
	foreach PawnOwner.WorldInfo.AllPawns( class'Pawn', P )
	{
		if ( P.Physics == PHYS_RigidBody && !P.bPlayedDeath )
		{
			KnockdownCount++;
		}
	}

	// handle MaxKnockdownPawns
	if ( KnockdownCount >= MaxKnockdownPawns )
	{
		return false;
	}

	return Super.InternalCanDoSpecialMove();
}

/** Notification called when Special Move starts */
function SpecialMoveStarted(bool bForced, Name PrevMove )
{
	local TWDeferredWorkManager DeferredWorkManager;

	DeferredWorkManager = TWDeferredWorkManager(KFPOwner.WorldInfo.DeferredWorkManager);

	// KnockdownImpulse is replicated before this move (if this has problems go back to repnotify KnockdownImpulse)
	DeferredWorkManager.SetTimer(0.0001, false, nameof(DeferApplyKnockdownImpulse), self);

	// Spawn the dazed particle effect
	if( KFPOwner.WorldInfo.NetMode != NM_DedicatedServer )
	{
		DazedPSC = class'KFSM_Stunned'.static.AttachDazedEffect( KFPawn_Monster(KFPOwner) );
	}
}

/** Notification called when Special Move starts */
function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	local TWDeferredWorkManager DeferredWorkManager;
	DeferredWorkManager = TWDeferredWorkManager(KFPOwner.WorldInfo.DeferredWorkManager);
	DeferredWorkManager.ClearTimer(nameof(DeferApplyKnockdownImpulse), self);
	
	// Make sure dazed particle effect is always deactivated
	if( DazedPSC != none && DazedPSC.bIsActive )
	{
		DazedPSC.DeactivateSystem();
	}

	// failsafe in case knockdown needs to be cleaned up
	if ( PawnOwner.Mesh.PhysicsWeight >= 1.f && NextMove != 'KFSM_RecoverFromRagdoll' )
	{
		PawnOwner.ClearTimer(nameof(EndKnockdown), self);
		PawnOwner.ClearTimer(nameof(KnockdownTimer), self);

		TermKnockdownRagdoll(KFPOwner);
	}
}


function DeferApplyKnockdownImpulse()
{
	ApplyKnockdownImpulse(KFPOwner.KnockdownImpulse);
}


/** Applies the contents of KnockdownImpulse. */
function ApplyKnockdownImpulse(const out KnockdownImpulseInfo Info)
{
	local vector PointImpulse;
	local name PointImpulseBoneName;

	// KnockdownImpulse should alwasy be non-zero
	if (IsZero(Info.LinearVelocity) && IsZero(Info.AngularVelocity))
	{
		`warn(self@"invalid KnockdownImpulse for"@PawnOwner);
	}

	if (PawnOwner.Physics != PHYS_RigidBody || PawnOwner.Mesh != PawnOwner.CollisionComponent)
	{
		// first send them to ragdoll
		PlayFallDown();
	}

	if (PawnOwner.Physics == PHYS_RigidBody)
	{
		KnockdownStartLoc = PawnOwner.Location;

		// whole-body velocities
		//@note: we set instead of adding for angular velocity as it's generally zero for newly created ragdolls
		//	and if it weren't, the client wouldn't be able to reliably derive the same value so it would just cause mismatches
		PawnOwner.Mesh.SetRBAngularVelocity(Info.AngularVelocity, false);
		if (!IsZero(Info.LinearVelocity))
		{
			PawnOwner.Mesh.SetRBLinearVelocity(Info.LinearVelocity, true);
		}

		if ( !IsZero(Info.ImpulseStrength) )
		{
			// handle radial and point impulses exclusively (network optimization)
			if ( Info.bIsRadialImpulse )
			{
				PawnOwner.Mesh.AddRadialImpulse(Info.ImpulsePosition, Info.ImpulseStrength.X, Info.ImpulseStrength.Y, RIF_Linear, true);
			}
			else
			{
				// Apply the same scaling factor we use for dead ragdolls
				PointImpulse = Info.ImpulseStrength * KFPOwner.KnockdownImpulseScale;

				if ( Info.PointImpulseHitZone != 255 ) 
				{
					PointImpulseBoneName = 	KFPOwner.HitZones[Info.PointImpulseHitZone].BoneName;
					// make sure it's a valid RB bone
					PointImpulseBoneName = KFPOwner.GetRBBoneFromBoneName(PointImpulseBoneName);
				}

				PawnOwner.Mesh.AddImpulse(PointImpulse, Info.ImpulsePosition, PointImpulseBoneName, true);
			}
		}

		if (KFPOwner.Role == ROLE_Authority )
		{
			// check for rest on an interval, but also set a maximum time
			PawnOwner.SetTimer(1.5f, false, nameof(EndKnockdown), self);
			PawnOwner.SetTimer(0.20f, true, nameof(KnockdownTimer), self);
		}
	}
	else
	{
		`warn(self@"failed to transition to RigidBody for"@GetFuncName());
		KFPOwner.EndSpecialMove();
	}
}

protected function PlayFallDown()
{
    //Reset phys asset for the same reason as we would if dying
    if (KFPOwner.bReinitPhysAssetOnDeath && KFPOwner.CharacterArch != none && KFPOwner.CharacterArch.PhysAsset != none)
    {
        KFPOwner.Mesh.SetPhysicsAsset(KFPOwner.CharacterArch.PhysAsset, , true);
    }

	KFPOwner.PrepareRagdoll();

	if( KFPOwner.InitRagdoll() )
	{
		// Move into post so that we are hitting physics from last frame, rather than animated from this
		PawnOwner.Mesh.SetTickGroup(TG_PostAsyncWork);
		PawnOwner.SetTickGroup(TG_PostAsyncWork);

		if( PawnOwner.Mesh.PhysicsAssetInstance != None )
		{
			// Make sure all motors are off on joints.
			PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularPositionDrive(FALSE, FALSE, PawnOwner.Mesh, TRUE);
			// Turn on velocity motors, to add some joint friction
			PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularDriveParams(0.f, 0.f, 0.004f, PawnOwner.Mesh, TRUE);
			// Don't set motors on dangly bits.
			PawnOwner.Mesh.PhysicsAssetInstance.SetAllMotorsAngularVelocityDrive(TRUE, TRUE, PawnOwner.Mesh, TRUE);
		}

		PawnOwner.Mesh.bUpdateJointsFromAnimation = FALSE;

		// we purposefully do NOT turn collide with RBBC_Pawn on
		// we will innerpentrate other ragdolled pawns as we do not collide with the Pawn channel.  This is acceptable because if we do
		// collide with other ragdolled pawns there is a chance that we will have the physics system forcibly push us apart causing one
		// or both the pawns to fly through the world
		PawnOwner.Mesh.SetRBChannel(RBCC_KnockedDownPawn);
		PawnOwner.Mesh.SetRBCollidesWithChannel(RBCC_KnockedDownPawn, TRUE);
		PawnOwner.Mesh.SetRBCollidesWithChannel(RBCC_Pawn, FALSE);
		PawnOwner.Mesh.SetRBCollidesWithChannel(RBCC_DeadPawn, FALSE);

		//ReduceConstraintLimits();
	}
	else
	{
		`Warn("Failed to init ragdoll for"@self);
	}
}

protected event KnockdownFailsafe()
{
	PawnOwner.Died(PawnOwner.LastHitBy, class'KFDT_Falling', PawnOwner.Location);
}

/** Timer called to check if ragdoll has come to a rest */
protected function KnockdownTimer()
{
	CurrentKnockdownTests++;
	if ( PawnOwner.Physics != PHYS_RigidBody || VSizeSq( PawnOwner.Velocity) < 100.f || !PawnOwner.Mesh.RigidBodyIsAwake() || MaxKnockdownTests == CurrentKnockdownTests)
	{
		EndKnockdown(true);
	}
}

/** Initiate recover from ragdoll on the server */
protected function EndKnockdown(optional bool bForceEnd = false)
{
	CurrentKnockdownTests = 0;
	//don't let them recover if they shouldn't
	if (!bForceEnd)
	{
		if (!(PawnOwner.Physics != PHYS_RigidBody || VSizeSq(PawnOwner.Velocity) < 100.f || !PawnOwner.Mesh.RigidBodyIsAwake()))
		{
			`log("failed to recover from knockdown " @PawnOwner.Physics @VSizeSq(PawnOwner.Velocity) < 100.f @PawnOwner.Mesh.RigidBodyIsAwake());
			return;
		}
	}
	
	PawnOwner.ClearTimer(nameof(EndKnockdown), self);
	PawnOwner.ClearTimer(nameof(KnockdownTimer), self);

	// Deactivate dazed particle effect
	if( DazedPSC != none )
	{
		DazedPSC.DeactivateSystem();
	}

	// if we've fallen a significant distance then assume we're dead
	if ( Abs(KnockdownStartLoc.Z - PawnOwner.Location.Z) > KnockdownMaxZ )
	{
		KnockdownFailsafe();
	}

	KFPOwner.KnockdownImpulse.LinearVelocity = vect(0,0,0);
	KFPOwner.KnockdownImpulse.AngularVelocity = vect(0,0,0);

	// If we have a dismembered limb (partial kinematics), then we can't get back up
	// note: It should be possible to handle this using bEnableFullAnimWeightBodies/bAlwaysFullAnimWeight
	// on the dismembered limb, but for now just kill the pawn.
	if ( KFPOwner.HasInjuredHitZones() )
	{
		KnockdownFailsafe();
	}

	// if we're still alive at this point
	if ( PawnOwner.IsAliveAndWell() && PawnOwner.Physics == PHYS_RigidBody )
	{
		KFPOwner.DoSpecialmove(SM_RecoverFromRagdoll, TRUE);

		if ( KFPOwner.SpecialMove != SM_RecoverFromRagdoll )
		{
			TermKnockdownRagdoll(KFPOwner);
			`log(GetFuncName() @ "Failed to find special move class for: SM_RecoverFromRagdoll" @ self);
		}
	}
	// If something else changed owner's physics mode - should not happen!
	else if ( PawnOwner.Physics != PHYS_RigidBody )
	{
		// if this happens the first place to look is a SetPhysics() call in AIC state Action_Idle
		`Warn("Knockdown timer called outside of PHYS_RigidBody"@PawnOwner.Physics@KFPOwner.SpecialMove);
		KnockdownFailsafe();
	}
}

/** Restore normal pawn physics */
static function TermKnockdownRagdoll(KFPawn P)
{
	local SkeletalMeshComponent Mesh;
	local SkeletalMeshComponent DefaultMesh;

	if ( P.bPlayedDeath )
	{
		return;	// Skip TermKnockdown after death and use full ragdoll
	}

	// this code is a lot like TermRagdoll, but without turning off the PhysicsAssetInstance
	P.SetPhysics(PHYS_Falling);
	P.Velocity = vect(0,0,0);
	P.Acceleration = vect(0,0,0);
	P.CollisionComponent = P.CylinderComponent;

	Mesh = P.Mesh;
	DefaultMesh = P.default.Mesh;

	// Restore things we turned off when we went into rag doll
	if( !DefaultMesh.bHasPhysicsAssetInstance )
	{
		Mesh.SetHasPhysicsAssetInstance(FALSE);
	}
	Mesh.MinDistFactorForKinematicUpdate = DefaultMesh.MinDistFactorForKinematicUpdate;
	Mesh.bUpdateKinematicBonesFromAnimation = DefaultMesh.bUpdateKinematicBonesFromAnimation;
	Mesh.bUpdateJointsFromAnimation = DefaultMesh.bUpdateJointsFromAnimation;
	Mesh.PhysicsWeight = DefaultMesh.PhysicsWeight;

	// Restore non-default collision settings to the way it was before knockdown
	RestoreRBCollision(P);

	// Kick dead bodies
	//Mesh.bUpdateKinematicBonesFromAnimation = true;
	//Mesh.SetRBCollidesWithChannel(RBCC_DeadPawn, TRUE);

	// restore danglers
	if( Mesh != None && Mesh.PhysicsAssetInstance != None )
	{
		Mesh.PhysicsAssetInstance.SetFullAnimWeightBonesFixed(FALSE, Mesh);
	}

	// If Pawn was using partial kinamatics for gore (e.g. Headless), reset those settings now
	if ( P.bHasBrokenConstraints && P.HasInjuredHitZones() )
	{
		P.InitPartialKinematics();
		P.Mesh.UpdateMeshForBrokenConstraints();
	}
}

/** If RB settings were modified while alive (e.g. Ragdoll knockdown) restore settings */
static function RestoreRBCollision(KFPawn P)
{
	P.Mesh.SetRBCollidesWithChannel(RBCC_KnockedDownPawn, FALSE);

	if( !P.Mesh.bUpdateKinematicBonesFromAnimation )
	{
		// No RB collision
		P.Mesh.SetRBChannel(RBCC_Nothing);
	}
	else
	{
		// Go back to being a pawn, and can collide with other live pawns (for flappy bits), 
		// and corpses, but not knocked down alive people )
		P.Mesh.SetRBChannel(RBCC_Pawn);
		P.Mesh.SetRBCollidesWithChannel(RBCC_Pawn, P.default.Mesh.RBCollideWithChannels.Pawn);
	}

	P.UpdateMeshForFleXCollision();
}

defaultproperties
{
	Handle=KFSM_Knockdown
	KnockdownMaxZ=750.f
	MaxKnockdownPawns=5

	bCanOnlyWanderAtEnd=true
    bDisablesWeaponFiring=true
	MaxKnockdownTests=25
}