//=============================================================================
// KFSM_Block
//=============================================================================
// Handles playing directional blocks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_Block extends KFSM_PlaySingleAnim;

/** Animation to play */
var const array<AnimVariants> BlockAnims;

/** Cached gameinfo reference */
var protected KFGameInfo MyKFGI;

/** Cached reference to monster pawn */
var protected KFPawn_Monster MyMonsterPawn;

/** How many times a block has been executed while in the special move */
var protected int NumBlocks;

/** The direction of the hit reaction when a block is broken */
var protected EPawnOctant ReactionDir;

/** Used to determine if the animation needs to be blended out when the special move ends */
var protected bool bPlayedBlockBreak;

/** When TRUE, will use the Monster pawn's BlockSprintSpeedModifier */
var protected bool bUseBlockSprintSpeed;

/** How long from start of block until Zed can actually block. */
var protected float WindupTime;

static function byte PackBlockSMFLags( byte BlockDir )
{
	local byte Variant;

	Variant = Rand( 2 );
	return BlockDir + ( Variant << 4 );
}

/** Checks to see if this Special Move can be done */
protected function bool InternalCanDoSpecialMove()
{
	// Can block if not doing a special move or already in a block
	return ( !KFPOwner.IsDoingSpecialMove() || KFPOwner.IsDoingSpecialMove(SM_Block) );
}

/**
 * Allow melee attacks to override blocks. This is so if the AI bumps an enemy,
 * they will always be able attack
 */
function bool CanOverrideMoveWith( Name NewMove )
{
	if( NewMove == class'KFSM_MeleeAttack'.default.Handle )
	{
		return true;
	}

	return super.CanOverrideMoveWith( NewMove );
}

/** Can the special move be chained after the current one finishes? */
function bool CanChainMove( Name NextMove )
{
	return NextMove == class.name;
}

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	// Cache our pawn
	if( MyMonsterPawn == none )
	{
		MyMonsterPawn = KFPawn_Monster( KFPOwner );
	}

	// Reset block breaker values
	bPlayedBlockBreak = false;
	ReactionDir = DIR_None;
	NumBlocks = 1;

	if( MyMonsterPawn.Role == ROLE_Authority )
	{
		bUseBlockSprintSpeed = true;
		AdjustSprintSpeed();

		MyMonsterPawn.SetTimer( MyMonsterPawn.GetBlockSettings().Duration, false, nameOf(Timer_BlockDurationExpired), self );
		MyMonsterPawn.SetTimer( WindupTime, false, nameOf(Timer_EnableBlocking), self );
	}

	super.SpecialMoveStarted( bForced, PrevMove );
}

function AdjustSprintSpeed()
{
	local float GCMoveSpeedMod;

	// Only allow for server and local player
	if( MyMonsterPawn.Role == ROLE_Authority )
	{
		GCMoveSpeedMod = 1.0f;

		// Set movement speed modifier
		if( MyMonsterPawn.WorldInfo.Game != none )
		{
			if( MyKFGI == none )
			{
				MyKFGI = KFGameInfo( MyMonsterPawn.WorldInfo.Game );
			}

			if( MyKFGI != none && MyKFGI.GameConductor != none )
			{
				GCMoveSpeedMod = MyKFGI.GameConductor.CurrentAIMovementSpeedMod;
			}
		}

		MyMonsterPawn.AdjustMovementSpeed( GCMoveSpeedMod );
	}
}

/**
 * Network: SERVER
 */
function float GetSprintSpeedModifier()
{
	return bUseBlockSprintSpeed ? MyMonsterPawn.GetBlockingSprintSpeedModifier() : 1.0f;
}

function PlayAnimation()
{
	local byte Type, Variant;

	Type = MyMonsterPawn.SpecialMoveFlags & 15;
	Variant = MyMonsterPawn.SpecialMoveFlags >> 4;

	AnimName = BlockAnims[Type].Anims[Variant];

	// Call super; play selected animation
	super.PlayAnimation();

	// Clear the special move flags on the next frame
	MyMonsterPawn.SetTimer( MyMonsterPawn.WorldInfo.DeltaSeconds, false, nameOf(Timer_ResetSpecialMoveFlags), self );

	// Make sure that everything is sent this frame so that the special move flags can be safely cleared
	MyMonsterPawn.bForceNetUpdate = true;
}

/** Resets the special move flags on the pawn for future updates */
function Timer_ResetSpecialMoveFlags()
{
	MyMonsterPawn.SpecialMoveFlags = 255;
}

/** Called when DoSpecialMove() is called again with this special move, but the special move flags have changed */
function SpecialMoveFlagsUpdated()
{
	local EPawnOctant BlockDir;

	if( MyMonsterPawn.SpecialMoveFlags != 255 && !MyMonsterPawn.IsTimerActive( nameOf(Timer_BlockBroken), self) )
	{
		// Increment our block number
		++NumBlocks;

		// End the block cycle if we've reached the maximum number of hits
		if( NumBlocks > MyMonsterPawn.GetBlockSettings().MaxBlocks )
		{
			BlockDir = EPawnOctant( MyMonsterPawn.SpecialMoveFlags & 15 );
			if( BlockDir == DIR_Right )
			{
				ReactionDir = DIR_ForwardLeft;
			}
			else if( BlockDir == DIR_Left )
			{
				ReactionDir = DIR_ForwardRight;
			}
			else
			{
				ReactionDir = DIR_Forward;
			}

			// End the special move with a hit reaction (block breaker!)
			MyMonsterPawn.ClearTimer( nameOf(Timer_BlockDurationExpired), self );
			MyMonsterPawn.SetTimer( BlendInTime, false, nameOf(Timer_BlockBroken), self );
		}
		else if( MyMonsterPawn.Role == ROLE_Authority )
		{
			MyMonsterPawn.SetTimer( MyMonsterPawn.GetBlockSettings().Duration, false, nameOf(Timer_BlockDurationExpired), self );
		}

		PlayAnimation();
	}
}

/** Toggles the blocking flag on the owner pawn to TRUE */
function Timer_EnableBlocking()
{
	MyMonsterPawn.bIsBlocking = true;
}

/** We've reached the end of our block, end the special move */
function Timer_BlockDurationExpired()
{
	if( MyMonsterPawn != none )
	{
		MyMonsterPawn.EndSpecialMove();
	}
}

/** Block was broken by too many successive hits */
function Timer_BlockBroken()
{
	bPlayedBlockBreak = true;
	MyMonsterPawn.StopBodyAnim( AnimStance, BlendOutTime );
	MyMonsterPawn.PawnAnimInfo.PlayHitReactionAnim( MyMonsterPawn, HIT_Heavy, ReactionDir );
	MyMonsterPawn.EndSpecialMove();
}

/** Hit reactions won't interrupt blocks */
function NotifyHitReactionInterrupt();

function SpecialMoveEnded( Name PrevMove, Name NextMove )
{
	super(KFSpecialMove).SpecialMoveEnded( PrevMove, NextMove );

	// Stop looping anim, clear timers and blocking flag
	if( MyMonsterPawn != none )
	{
		if( !bPlayedBlockBreak )
		{
			MyMonsterPawn.StopBodyAnim( AnimStance, BlendOutTime );
		}

		if( MyMonsterPawn.Role == ROLE_Authority )
		{
			bUseBlockSprintSpeed = false;
			AdjustSprintSpeed();

			MyMonsterPawn.ClearTimer( nameOf(Timer_ResetSpecialMoveFlags), self );
			MyMonsterPawn.ClearTimer( nameOf(Timer_EnableBlocking), self );
			MyMonsterPawn.ClearTimer( nameOf(Timer_BlockDurationExpired), self );
			MyMonsterPawn.ClearTimer( nameOf(Timer_BlockBroken), self );
			MyMonsterPawn.bIsBlocking = false;
			MyMonsterPawn.LastBlockTime = MyMonsterPawn.WorldInfo.TimeSeconds;
		}
	}
}

DefaultProperties
{
	// ---------------------------------------------
	// SpecialMove
	Handle=KFSM_Block
	bCanBeInterrupted=true

	WindupTime=0.25f

	// ---------------------------------------------
	// Animations
	AnimStance=EAS_UpperBody
	bUseRootMotion=false
	bLoopAnim=true
	BlendInTime=0.2f

	BlockAnims(DIR_Forward)=(Anims=(Block_Idle, Block_Idle))
	BlockAnims(DIR_Backward)=(Anims=(Block_Idle, Block_Idle))
	BlockAnims(DIR_Left)=(Anims=(Block_R, Block_R))
	BlockAnims(DIR_Right)=(Anims=(Block_L, Block_L))
}