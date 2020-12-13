//=============================================================================
// KFAnim_RandomScripted
//=============================================================================
// A custom random node that allows game code to "suggest" the next anim.
// This is unreliable and not synchronized with other game clients, but it
// is synchronized with another anims in this node.  For reliable actions use
// SpecialMoves and AnimNodeSlots instead.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAnim_RandomScripted extends KFAnim_Random
	native(Anim);

/** If set, this nodes first child is a taunt/challenge animation */
var() bool bHasTauntAnim;

cpptext
{
	/** Notification to this blend that a child UAnimNodeSequence has reached the end and stopped playing. Not called if child has bLooping set to true or if user calls StopAnim. */
	virtual void OnChildAnimEnd(UAnimNodeSequence* Child, FLOAT PlayedTime, FLOAT ExcessTime);
}

/** Queue up a specific child by index.  If this child is only scripted it should have Chance=0 */
function QueueAnimChild(INT ChildIndex, optional float MaxWaitTime=3.f)
{
	PendingChildIndex = ChildIndex;
}

/** For simplicity always assume taunt walks are at index 0 */
function QueueTauntWalk()
{
	if ( bHasTauntAnim )
	{
		QueueAnimChild(0);
	}
}

defaultproperties
{
}
	