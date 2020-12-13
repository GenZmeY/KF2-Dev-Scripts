//=============================================================================
// KFDT_DrainHealth
//=============================================================================
// Health drain damage type
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_DrainHealth extends KFDamageType
	abstract
	hidedropdown;

defaultproperties
{
    bArmorStops=false
	EffectGroup=FXG_DrainLife
}
