//=============================================================================
// KFSeqAct_ToggleEx
//=============================================================================
// Works the same as toggle, but has the ability to trigger the opposite action
// on all other actors of the same type that are not linked to the action.
// The Toggle input link will continue to function the same, since each actor
// is responsible for its own toggle functionality.
//
// EXAMPLE: Action takes an input of 3 PlayerStarts, set to toggle to ON. All
// other PlayerStarts will then receive the toggle OFF.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_ToggleEx extends SeqAct_Toggle
	native(Sequence);

/** If TRUE, actors linked to this action are dynamic and can use the faster DynamicActors iterator */
var() bool bUseDynamicActorIterator;

cpptext
{
	virtual void Activated();
}

defaultproperties
{
	HandlerName="OnToggle"
	ObjName="Toggle EX"
	bUseDynamicActorIterator=false
}