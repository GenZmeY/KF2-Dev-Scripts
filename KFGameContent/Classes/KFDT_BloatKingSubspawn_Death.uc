//=============================================================================
// KFDT_BloatKingSubspawn_Death
//=============================================================================
// Bloat King poop monster death attack damagetype
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFDT_BloatKingSubspawn_Death extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	DoT_Type=DOT_None

	bNoInstigatorDamage=true
	bConsideredIndirectOrAoE=true
}
