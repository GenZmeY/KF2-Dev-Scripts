//=============================================================================
// BaseAITypes
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class BaseAITypes extends Object
	native(Types)
	abstract
	config(AI);

enum EActionPriority
{
	AP_Invalid,
	AP_Logic,
	AP_Kismet,	// default GoW priority, not only for kismet
	AP_Reaction,
};

enum EBaseMoveMood
{
	BMM_Invalid,
	BMM_Static,
	BMM_Slow,
	BMM_Normal,
	BMM_Fast,
};

enum EBaseMoveType
{
	BMT_Invalid,
	BMT_Normal,
	BMT_Combat,
	BMT_Careful,
	BMT_Pain,
};

enum EWSPerceptionMode
{
    WSPM_None,
    WSPM_Memory,
    WSPM_Belief,
    WSPM_Hearing,
    WSPM_Sight,
};

enum EWSSymbolicAngle
{
    WSSA_Front,
    WSSA_Side,
    WSSA_Back,
    WSSA_Unknown,
};

enum EBTResult
{ 
	BTR_Error,
	BTR_Abort,
	BTR_Fail,
	BTR_Success,
	BTR_NotFinished,
};

// ----------------------------------------------------------------------- //
// Debug types
// ----------------------------------------------------------------------- //
enum EDebugLineType
{
	DLT_Generic,
	DLT_InstantFire,
	DLT_NoPath,
	DLT_LeaderFollowing,
	DLT_Failed,
	DLT_Red,
	DLT_Green,
	DLT_Blue,
};

struct native SpaceLineInfo
{
	var vector Start;
	var vector End;
	var EDebugLineType Type;
	var init string Comment;
	var native Name Category;

	structcpptext
	{
	/** Constructors */
	FSpaceLineInfo() {}
	FSpaceLineInfo(EEventParm)
	{
		appMemzero(this, sizeof(FSpaceLineInfo));
	}
	FSpaceLineInfo(FVector inStart,FVector inEnd,BYTE inType, const FString& inComment,FName inCategory=NAME_None) 
		: Start(inStart), End(inEnd), Type(inType), Comment(inComment), Category(inCategory)
	{}
	}
};

defaultproperties
{
}
