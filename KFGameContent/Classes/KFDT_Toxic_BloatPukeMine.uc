//=============================================================================
// KFDT_Toxic_BloatPukeMine
//=============================================================================
// Bloat puke mine bile attack damagetype
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Toxic_BloatPukeMine extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	// override DoT from KFDT_Toxic
	DoT_Type=DOT_None

    // Don't let Hans damage himself with his grenade
    bNoInstigatorDamage=true
    bConsideredIndirectOrAoE=true
}