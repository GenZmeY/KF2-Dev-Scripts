

//=============================================================================
// KFGFxWidget_RhythmCounter
//=============================================================================
// HUD Widget that displays messages to the player
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 01/14/2015
//=============================================================================

class KFGFxWidget_RhythmCounter extends GFxObject;

function SetCount( int Count, int Max )
{
	SetInt("count", Min(Count, Max));
	SetBonusPercentage(float(Min(Max,Count)) / float(Max));
}

function SetBonusPercentage( float NewValue )
{
	SetFloat("bonusPercentage", NewValue);
}
