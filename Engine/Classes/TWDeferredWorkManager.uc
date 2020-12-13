//=============================================================================
// TWDeferredWorkManager
//=============================================================================
// This class handles deferring physics related tasks to the post tick since they can't occur
// during async while PhysX is running. This class can defer other tasks outside of physics as well.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================


class TWDeferredWorkManager extends Actor
	native(TW);


/** Struct of data needed to call deferred function. */
struct native AnimNotifyData
{
	var AnimNotify Caller;
	var AnimNodeSequence NodeSeq;
};

/** Struct of data needed to call deferred function. */
struct native AnimNotifyEndData
{
	var AnimNotify Caller;
	var AnimNodeSequence NodeSeq;
	var float AnimCurrentTime;
};

/** Struct of data needed to call deferred function. */
struct native AnimNotifyTickData
{
	var AnimNotify Caller;
	var AnimNodeSequence NodeSeq;
	var float AnimCurrentTime;
	var float AnimTimeStep;
	var float InTotalDuration;
};


/** This holds pointers to AnimNotify */
var() array<AnimNotifyData> AnimNotifyDataArray;

/** This holds pointers to AnimNotify */
var() array<AnimNotifyTickData> AnimNotifyTickDataArray;

/** This holds pointers to AnimNotify */
var() array<AnimNotifyEndData> AnimNotifyEndDataArray;


cpptext
{	
	virtual UBOOL Tick( FLOAT DeltaTime, enum ELevelTick TickType );
	
}


native function bool IsDuringAsyncWork();

/** Defers the Anim Notify data to be called later.
 *
 *	@param NewAnimNotifyData data will be added to an array and called later.
 */
native function DeferNotify(AnimNotify Caller,  AnimNodeSequence NodeSeq);

/** Defers the Anim Notify data to be called later.
 *
 *	@param NewAnimNotifyData data will be added to an array and called later.
 */
native function DeferNotifyTick(AnimNotify Caller, AnimNodeSequence NodeSeq, const float AnimCurrentTime, const float AnimTimeStep, const float InTotalDuration);

/** Defers the Anim Notify data to be called later.
 *
 *	@param NewAnimNotifyData data will be added to an array and called later.
 */
native function DeferNotifyEnd(AnimNotify Caller, AnimNodeSequence NodeSeq, const float AnimCurrentTime);


/** Defers the Anim Notify data to be called later.
 *
 *	@param NewAnimNotifyData data will be added to an array and called later.
 */
function DeferSpecialMoveAnimEnd(Object Caller)
{
	SetTimer(0.0001, false, 'DeferOnAnimEnd', Caller);
}



defaultproperties
{
	/** This should always be post async work. */
	TickGroup=TG_PostAsyncWork
}