//=============================================================================
// KFSM_Emerge_Crawler
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Emerge_Crawler extends KFSM_Emerge;

var() byte LastEmergeType;

/** Stop the movement and play the stun animation for all clients */
function name PlayEmerge()
{
	local name EmergeAnim;
	
	EmergeAnim = Super.PlayEmerge();
	LastEmergeType = KFPOwner.SpecialMoveFlags & 15;

	// Special cases for Crawler's collision restoration and physics adjustments after emerge
	//SetCrawlerPostEmergeFlags( EmergeAnim );

	return EmergeAnim;
}

/** Crawler-specific emerge handling to make adjustments immediately after emerging to avoid unwanted
	basechanges, etc. */
function SetCrawlerPostEmergeFlags( name EmergeAnim )
{
	// deprecated function
}

/** Called from SpecialMoveEnded */
//function RestoreCollision()
//{
//	// @hack: collision tends to be in the wall, nudge outward.  FitCollision will be less likely to fail
//	if ( EmergeType == EMERGE_Wall248UU )
//	{
//		PawnOwner.SetLocation( PawnOwner.Location + 45.f * vector(PawnOwner.rotation) );
//	}
//	else if ( EmergeType == EMERGE_WallHigh )
//	{
//		PawnOwner.SetLocation( PawnOwner.Location + 60.f * vector(PawnOwner.rotation) );
//	}
//	else if ( EmergeType == EMERGE_Ceiling )
//	{
//		PawnOwner.SetLocation( PawnOwner.Location + 48.f * vect(0,0,-1) );
//	}
//
//	Super.RestoreCollision();
//}

/** Variant is still using parent's array length!  Just hardcode variant here */
function name GetEmergeAnim( byte EmergeType, int Variant )
{
	switch( EmergeType )
	{
	 	case EMERGE_Floor:
	 		 return FloorEmerge[Variant];
	 	case EMERGE_Wall248UU:
	 		 return Wall248Emerge[0];
 		case EMERGE_WallHigh:
	 		 return WallHighEmerge[0];
		case EMERGE_Ceiling:
	 		 return CeilingEmerge[0];
	}

	`log(GetFuncName()@"Failed to find valid anim for:"$EmergeType@"variant:"$Variant);
}

/** Disabled */
function PushOverlappingHumans();

DefaultProperties
{
	DefaultAICommandClass=class'KFGame.AICommand_CrawlerEmerge'
	AITimeout=11.f

	// removed all wall crawling anims
	Wall248Emerge=(Enter_vent_C_V2)
	WallHighEmerge=(Enter_ventHigh_C_V2)
	CeilingEmerge=(Enter_Ceiling_V4)
}