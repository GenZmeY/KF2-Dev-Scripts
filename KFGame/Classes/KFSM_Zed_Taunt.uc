//=============================================================================
// KFSM_Zed_Taunt
//=============================================================================
// Play a taunt animation sequence
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFSM_Zed_Taunt extends KFSM_PlaySingleAnim;

enum ETauntType
{
	TAUNT_Standard,
	TAUNT_EnemyKilled,
	TAUNT_Enraged,
};

var byte CurrentTauntType;

/** Generic flags for player controlled zeds (versus) */
static function byte PackFlagsBase(KFPawn P)
{
	return PackSMFlags(P, TAUNT_Standard);
}

static function byte PackSMFlags( KFPawn P, byte InTauntType )
{
	local byte Variant;
	local KFPawnAnimInfo PAI;

	PAI = P.PawnAnimInfo;
	Variant = 255;
	// Get the number of taunt anims from the AnimInfo class
	switch ( InTauntType )
	{
	case TAUNT_Enraged:
		if( PAI.TauntEnragedAnims.Length > 0 )
		{
			Variant = Rand(PAI.TauntEnragedAnims.Length);
		}
		break;
	case TAUNT_EnemyKilled:
		if( PAI.TauntKillAnims.Length > 0 )
		{
			Variant = Rand(PAI.TauntKillAnims.Length);
		}
		break;
	case TAUNT_Standard:
		if( PAI.TauntAnims.Length > 0 )
		{
			Variant = Rand(PAI.TauntAnims.Length);
		}
		break;
	}

	if ( Variant != 255 )
	{
		return InTauntType + (Variant << 4);
	}
	else
	{
		return 255;
	}
}

function PlayAnimation()
{
	local byte Variant;

	CurrentTauntType = KFPOwner.SpecialMoveFlags & 15;
	Variant = KFPOwner.SpecialMoveFlags >> 4;

	switch ( CurrentTauntType )
	{
	case TAUNT_Enraged:
		AnimName = KFPOwner.PawnAnimInfo.TauntEnragedAnims[Variant];
		break;
	case TAUNT_EnemyKilled:
		AnimName = KFPOwner.PawnAnimInfo.TauntKillAnims[Variant];
		break;
	default:
		AnimName = KFPOwner.PawnAnimInfo.TauntAnims[Variant];
		break;
	}

	`AILog_Ext( GetFuncName()$" "$self$" chose taunt animation "$AnimName, 'AIController', AIOwner );
	//KFAIController(PawnOwner.Controller).msg( GetFuncName()$": "$AnimName$" BlendIn: "$BlendInTime$" BlendOut: "$BlendOutTime );
	PlaySpecialMoveAnim( AnimName, AnimStance, BlendInTime, BlendOutTime, 1.f );
}
function SpecialMoveEnded(Name PrevMove, Name NextMove)
{
	// abort animation if something ended the taunt early
 	if ( KFPOwner.BodyStanceNodes[AnimStance].bIsPlayingCustomAnim )
 	{
		KFPOwner.StopBodyAnim(AnimStance, 0.2);
	}

	if( AIOwner != none )
	{
		AIOwner.AIZeroMovementVariables();
	}
	Super.SpecialMoveEnded(PrevMove, NextMove);
}

DefaultProperties
{
	// ---------------------------------------------
	// SpecialMove
	Handle=KFSM_Taunt
	bDisableMovement=true
	bDisablesWeaponFiring=true
}
