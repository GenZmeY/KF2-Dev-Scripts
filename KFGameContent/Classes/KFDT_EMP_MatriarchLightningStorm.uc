//=============================================================================
// KFDT_EMP_MatriarchLightningStorm
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDT_EMP_MatriarchLightningStorm extends KFDT_EMP
	abstract
	hidedropdown;

defaultproperties
{
    bArmorStops=true

	RadialDamageImpulse=2000
	KDeathUpKick=500
	KDeathVel=300

	EMPPower=40

	bAllowAIDoorDestruction=true

	bNoInstigatorDamage=true
}