//=============================================================================
// KFSM_Stumble
//=============================================================================
// Stumble (aka Stagger, Knockback) on damage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Stumble extends KFSM_PlaySingleAnim;

/** Anims are pulled from the pawn's AnimInfo class (see KFPawnAnimInfo) */
enum EStubmleAnim
{
	ESA_Body_Forward,
	ESA_Body_Backward,
	ESA_Body_Left,
	ESA_Body_Right,
	ESA_Leg_L_Forward,
	ESA_Leg_L_Backward,
	ESA_Leg_L_Left,
	ESA_Leg_L_Right,
	ESA_Leg_R_Forward,
	ESA_Leg_R_Backward,
	ESA_Leg_R_Left,
	ESA_Leg_R_Right,
	ESA_Parry,
};

/** If true, try to perform a leg stumble */
static function bool ShouldDoLegStumble(KFPawn P, EHitZoneBodyPart HitZoneLimb)
{
	if ( HitZoneLimb == BP_LeftLeg || HitZoneLimb == BP_RightLeg )
	{
		return (VSizeSq(P.Velocity) > 100.f);
	}
	return false;
}

static function byte PackBodyHitSMFlags(KFPawn P, vector HitDir)
{
	local EPawnOctant HitRegion;
	local byte Type;

	HitRegion = P.CalcOctagonRegion(P.Rotation, -Normal(HitDir));
	Type = GetStumbleTypeFromRegion(HitRegion);

	// pack into two nibbles
	return Type + (GetRandomVariant(P, Type) << 4);
}

static function byte PackLegHitSMFlags(KFPawn P, vector HitDir, bool bLeftLeg)
{
	local EPawnOctant HitRegion;
	local byte Type;

	if ( P.Floor.Z < 0.98f )
	{
		// get direction based on footing slope
		HitRegion = P.CalcOctagonRegion(P.Rotation, Normal2D(P.Floor));
		Type = GetStumbleTypeFromRegion(HitRegion);
	}
	else
	{
		// get 4-way direction from hit (random reverse)
		HitRegion = P.CalcOctagonRegion(P.Rotation, -Normal(HitDir));
		Type = GetStumbleTypeFromRegion(HitRegion, true);
	}

	// offset anim index by leg
	if ( bLeftLeg )
	{
		Type += ESA_Leg_L_Forward;
	}
	else
	{
		Type += ESA_Leg_R_Forward;
	}

	return Type + (GetRandomVariant(P, Type) << 4);
}

/** Initialize flags for parry animation type */
static function byte PackParrySMFlags(KFPawn P, vector HitDir)
{
	return ESA_Parry + (GetRandomVariant(P, ESA_Parry) << 4);
}

/** Debugging */
static function byte PackRandomSMFlags(KFPawn P)
{
	local byte Type;
	Type = Rand(ESA_MAX);
	return Type + (GetRandomVariant(P, Type) << 4);
}

/** Helper for PackSMFlags */
static function byte GetRandomVariant(KFPawn P, byte Type)
{
	local int NumVariants;
	NumVariants = P.PawnAnimInfo.StumbleAnims[Type].Anims.Length;
	return Rand(NumVariants);
}

/** Helper for PackSMFlags */
static function byte GetStumbleTypeFromRegion(EPawnOctant HitRegion, optional bool bRandomReverse)
{
	if ( bRandomReverse )
	{
		switch (HitRegion)
		{
		case DIR_Forward:
		case DIR_Backward:
			return (FRand() > 0.5) ? ESA_Body_Forward : ESA_Body_Backward;
		case DIR_Left:
		case DIR_Right:
			return (FRand() > 0.5) ? ESA_Body_Left : ESA_Body_Right;
		case DIR_ForwardLeft:
		case DIR_ForwardRight:
		case DIR_BackwardLeft:
		case DIR_BackwardRight:
			return ESA_Body_Forward + Rand(4);
		}
	}
	else
	{
		switch (HitRegion)
		{
		case DIR_Forward:
			return ESA_Body_Forward;
		case DIR_ForwardLeft:
			return (FRand() > 0.5) ? ESA_Body_Forward : ESA_Body_Left;
		case DIR_ForwardRight:
			return (FRand() > 0.5) ? ESA_Body_Forward : ESA_Body_Right;
		case DIR_Backward:
			return ESA_Body_Backward;
		case DIR_BackwardLeft:
			return (FRand() > 0.5) ? ESA_Body_Backward : ESA_Body_Left;
		case DIR_BackwardRight:
			return (FRand() > 0.5) ? ESA_Body_Backward : ESA_Body_Right;
		case DIR_Left:
			return ESA_Body_Left;
		case DIR_Right:
			return ESA_Body_Right;
		}
	}

	return ESA_Body_Forward;
}

/**
 * Checks to see if this Special Move can be done.
 */
protected function bool InternalCanDoSpecialMove()
{
	// Only valid while walking or falling slowly.  This makes stumble exclusive to HandleMomentum()
	return (!KFPOwner.IsImpaired() || KFPOwner.IsHeadless()) && (PawnOwner.Physics == PHYS_Walking || (PawnOwner.Physics == PHYS_Falling &&
        Abs(PawnOwner.Velocity.Z) < 250 && VSize2d(PawnOwner.Velocity) < 600));
}

function PlayAnimation()
{
	local byte Type, Variant;

	Type = KFPOwner.SpecialMoveFlags & 15;
	Variant = KFPOwner.SpecialMoveFlags >> 4;
	AnimName = KFPOwner.PawnAnimInfo.StumbleAnims[Type].Anims[Variant];

	PlaySpecialMoveAnim(AnimName, EAS_FullBody, BlendInTime, BlendOutTime, 1.f);

	// Clear the special move flags now so that SpecialMoveFlagsUpdated never fails
	KFPOwner.SpecialMoveFlags = 255;

	if ( KFPOwner.Role == ROLE_Authority )
	{
		bCanBeInterrupted = false;
		KFPOwner.SetTimer(RandRange(0.5f, 0.75f), false, nameof(EnableInterrupt), Self);
	}
}

function EnableInterrupt()
{
	bCanBeInterrupted = true;
}

/** called when DoSpecialMove() is called again with this special move, but the special move flags have changed */
function SpecialMoveFlagsUpdated()
{
	// If the move flags are updated play a new animation (chain stumble)
	// This can happen on a client if the server interrupted a stumble and
	// then started a new one on the same frame.
	PlayAnimation();
}

DefaultProperties
{
	Handle=KFSM_Stumble

	bUseRootMotion=true
	BlendOutTime=0.2f
	AbortBlendOutTime=0.1f

	// ---------------------------------------------
	// AI/Navigation
	DefaultAICommandClass=class'KFGame.AICommand_Stumble'
	AITimeout=5.f

	bDisablesWeaponFiring=true
	bCanOnlyWanderAtEnd=true
}
