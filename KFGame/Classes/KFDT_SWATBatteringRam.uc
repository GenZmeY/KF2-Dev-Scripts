//=============================================================================
// KFDT_SWATBatteringRam
//=============================================================================
// Used for the SWAT level 25 ZED TIME - Battering Ram Perk skill
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_SWATBatteringRam extends KFDT_Bludgeon
	abstract;

defaultproperties
{
	//Physics
	KDeathUpKick=4000
	KDeathVel=1000

	ModifierPerkList(0)=class'KFPerk_Swat'
}