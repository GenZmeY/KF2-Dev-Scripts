//=============================================================================
// KFDT_Toxic_BloatKingPukeMine
//=============================================================================
// Bloat puke mine bile attack damagetype
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Toxic_BloatKingPukeMine extends KFDT_Toxic
	abstract
	hidedropdown;

defaultproperties
{
	// override DoT from KFDT_Toxic
	DoT_Type=DOT_None

    // Allowed to damage the bloat king
    bNoInstigatorDamage=false
    bConsideredIndirectOrAoE=true
	// Ignore the self inflicted scale
	bIgnoreSelfInflictedScale=true
}