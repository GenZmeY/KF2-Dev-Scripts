//=============================================================================
// KFSM_Emerge
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 3/14/2014
//=============================================================================

class KFSM_Emerge extends KFSpecialMove;

var()	array<name>	FloorEmerge;
var()	array<name>	Wall248Emerge;
var()	array<name>	WallHighEmerge;
var()	array<name>	CeilingEmerge;

var()	float BlendOutTime;

/** If set, triggers a SM_RagdollKnockdown move at the end */
var bool bDoKnockdown;

/** Pack the animation index we'll be using for the zed to emerge */
static function byte PackAnimFlag( EEmergeAnim EmergeType, optional out byte LastAnimVariant )
{
	local byte Variant;
	local int NumAnims;

	NumAnims = GetEmergeAnimNum(EmergeType);

	if ( ( EmergeType == EMERGE_Wall248UU || EmergeType == EMERGE_WallHigh ) )
    {
    	Variant = 0;
		if ( NumAnims > 1 )
		{
			while ( Variant == LastAnimVariant )
			{
				Variant = Rand(NumAnims);
			}
		}

		LastAnimVariant = Variant;
    }
    else
    {
		Variant = Rand(NumAnims);
	}
	// pack into two nibbles
	return EmergeType + (Variant << 4);
}

static function int GetEmergeAnimNum( byte EmergeType )
{
	switch( EmergeType )
	{
	 	case EMERGE_Floor:
	 		 return default.FloorEmerge.Length;
	 	case EMERGE_Wall248UU:
	 		 return default.Wall248Emerge.Length;
 		case EMERGE_WallHigh:
	 		 return default.WallHighEmerge.Length;
		case EMERGE_Ceiling:
	 		 return default.CeilingEmerge.Length;
	}

	`log(GetFuncName()@"Failed to find valid anim for:"$EmergeType);
}

function name GetEmergeAnim( byte EmergeType, int Variant )
{
	switch( EmergeType )
	{
	 	case EMERGE_Floor:
	 		 return FloorEmerge[Variant];
	 	case EMERGE_Wall248UU:
	 		 return Wall248Emerge[Variant];
 		case EMERGE_WallHigh:
	 		 return WallHighEmerge[Variant];
		case EMERGE_Ceiling:
	 		 return CeilingEmerge[Variant];
	}

	`log(GetFuncName()@"Failed to find valid anim for:"$EmergeType@"variant:"$Variant);
}

/** Allow override from Knockdown (see ANIMNOTIFY_Knockdown) */
function bool CanOverrideMoveWith( Name NewMove )
{
	if ( NewMove == 'KFSM_Knockdown' )
		return true;

	return Super.CanOverrideMoveWith(NewMove);;
}

/** Notification called when Special Move starts */
function SpecialMoveStarted(bool bForced, Name PrevMove )
{
	super.SpecialMoveStarted( bForced, PrevMove );
	
	PlayEmerge();
	bDoKnockdown = false;
}

/** Stop the movement and play the stun animation for all clients */
function name PlayEmerge()
{
	local byte Type, Variant;
	local name EmergeAnim;
	
	Type = KFPOwner.SpecialMoveFlags & 15;
	Variant = KFPOwner.SpecialMoveFlags >> 4;
	EmergeAnim = GetEmergeAnim(Type, Variant);
	
	PlaySpecialMoveAnim( EmergeAnim, EAS_FullBody, 0.0f, BlendOutTime, 1.f, false );
	
	// Turn on Root translation
	EnableRootMotion();

	// Use root rotation to rotate the actor.
	KFPOwner.BodyStanceNodes[EAS_FullBody].SetRootBoneRotationOption(RRO_Extract, RRO_Extract, RRO_Extract);
	KFPOwner.Mesh.RootMotionRotationMode = RMRM_RotateActor;

	KFPOwner.SetCollision(KFPOwner.bCollideActors, FALSE);
	KFPOwner.bCollideWorld = FALSE;

	// Custom handler for destructibles
	if( KFPOwner.WorldInfo.NetMode != NM_Client )
	{
		KFPOwner.SetTimer( 0.25f, true, nameOf(Timer_CheckForPortalDestructibles), self );
	}

	// Force always relevant to fix a bug where the actor becomes relevant midway through his root motion 
	// animation. bUpdateSimulatedPosition might be a alternative?
	KFPOwner.bAlwaysRelevant = true;

	return EmergeAnim;
}

/** Notification called when Special Move starts when ReplicatedSpecialMove changes*/
function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	Super.SpecialMoveEnded(PrevMove, NextMove);

	// Reset root rotation
	KFPOwner.BodyStanceNodes[EAS_FullBody].SetRootBoneRotationOption(RRO_Discard, RRO_Discard, RRO_Discard);
	KFPOwner.Mesh.RootMotionRotationMode = RMRM_Ignore;

	// Reset root translation
	DisableRootMotion();

	KFPOwner.bAlwaysRelevant = PawnOwner.default.bAlwaysRelevant;

	RestoreCollision();

	if( KFPOwner.WorldInfo.NetMode != NM_Client )
	{
		KFPOwner.ClearTimer( nameOf(Timer_CheckForPortalDestructibles), self );
	}

	// Sometime after the move is over make sure our new AI was able to generate a valid path
	if ( PawnOwner.Role == ROLE_Authority && !PawnOwner.IsHumanControlled() )
	{
		PawnOwner.SetTimer(5.f, false, nameof(FindAnchorFailsafe), self);
	}
}

function Timer_CheckForPortalDestructibles()
{
	local KFPawn_Monster KFPM;
	local KFDestructibleActor KFDA;

	if( KFPOwner.bCollideWorld )
	{
		return;
	}

	KFPM = KFPawn_Monster( KFPOwner );
	if( KFPM != none )
	{
		foreach KFPOwner.OverlappingActors( class'KFDestructibleActor', KFDA, KFPOwner.CylinderComponent.CollisionRadius,, true )
		{
			KFDA.BumpedByMonster( KFPM, Normal(KFDA.Location - KFPOwner.Location) );
		}
	}
}

/**
 * Notification called when body stance animation finished playing.
 */
function AnimEndNotify(AnimNodeSequence SeqNode, float PlayedTime, float ExcessTime)
{
	// @hack: For knockdown use SM override isntead of ending this move.  Ending it at the
	// same time will trigger a SetPhysics call from AI state Action_Idle and break knockdown

	if ( bDoKnockdown )
	{
		KFPOwner.Knockdown(PawnOwner.Velocity, vect(1,1,1));
	}

	// If we're still in emerge (e.g. no knockdown, knockdown failed) end normally
	if ( KFPOwner.SpecialMove == SM_Emerge  )
	{
		KFPOwner.EndSpecialMove();
	}
}

/** When emerge is complete need to reenable collision settings */
function RestoreCollision()
{
	KFPOwner.SetCollision(PawnOwner.default.bCollideActors, PawnOwner.default.bBlockActors);
 	KFPOwner.bCollideWorld = TRUE;
	KFPOwner.FitCollision();

	PushOverlappingHumans();
}

/** If the pawn is overlapping with another pawn at the end of emerging, give it a push back */
function PushOverlappingHumans()
{
	local Pawn P;

	if ( PawnOwner.Role < ROLE_Authority )
	{
		return;
	}

	foreach PawnOwner.WorldInfo.AllPawns(class'Pawn', P, PawnOwner.Location, PawnOwner.CylinderComponent.CollisionRadius)
	{
		if ( P == KFPOwner || P.Controller == none || !P.Controller.bIsPlayer )
		{
			continue;
		}

		P.Velocity += (100 + KFPOwner.CylinderComponent.CollisionRadius) * vector( KFPOwner.Rotation ) * 2.5f;
		P.Velocity.Z = 200 + KFPOwner.CylinderComponent.CollisionHeight;
		P.SetPhysics(PHYS_Falling);
	}
}

/** Timer used to exist gracefully if something has gone wrong */
function AbortSpecialMove()
{
	super.AbortSpecialMove();
	// Kill the zed if it doesn't have the emerge animation yet
	PawnOwner.Died( None, PawnOwner.WorldInfo.KillzDamageType, PawnOwner.Location );
}

/** Sometime after the move is over make sure our new AI was able to generate a valid path */
function FindAnchorFailsafe()
{
	if ( PawnOwner.Role == ROLE_Authority && !PawnOwner.IsHumanControlled() )
	{
		if ( `TimeSinceEx(PawnOwner, PawnOwner.FindAnchorFailedTime) < 5.f)
		{
			`Warn("Zed unable to resume pathing after SM_Emerge"@PawnOwner@KFPOwner.SpecialMove);
			PawnOwner.Died( None, PawnOwner.WorldInfo.KillzDamageType, PawnOwner.Location );
		}
	}
}

defaultproperties
{
	Handle=SM_Emerge
	SMRootMotionMode=RMM_Translate
	bPawnRotationLocked=true
	bDisablePhysics=true
	bCanOnlyWanderAtEnd=true
	bShouldDeferToPostTick=true

	// animations
	FloorEmerge=(Enter_Floor_V1, Enter_Floor_V2, Enter_Floor_V3)
	Wall248Emerge=(Enter_vent_C_V1, Enter_vent_C_V2, Enter_vent_L_V1, Enter_vent_L_V2, Enter_vent_R_V1, Enter_vent_R_V2)
	WallHighEmerge=(Enter_ventHigh_C_V1, Enter_ventHigh_C_V2, Enter_ventHigh_L_V1, Enter_ventHigh_L_V2, Enter_ventHigh_R_V1, Enter_ventHigh_R_V2)
	CeilingEmerge=(Enter_Ceiling_V1, Enter_Ceiling_V2, Enter_Ceiling_V3, Enter_Ceiling_V4)

	BlendOutTime=0.2

	DefaultAICommandClass=class'KFGame.AICommand_PushedBySM'
}