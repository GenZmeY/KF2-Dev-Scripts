//=============================================================================
// KFAfflictions_Fire_Patriarch
//=============================================================================
// Afflictions class for Patriarch to handle additional body material
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAffliction_Fire_Patriarch extends KFAffliction_Fire;

/** Overloaded to support secondary body mat */
function SetMaterialParameter(float BurnedAmount)
{
	// cap at 35% burn
	Super.SetMaterialParameter(fMin(BurnedAmount, 0.35f));
}

defaultproperties
{
	//defaults
}