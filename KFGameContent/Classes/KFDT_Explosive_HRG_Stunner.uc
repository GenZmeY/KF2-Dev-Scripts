//=============================================================================
// KFDT_Explosive_HRG_Stunner
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_HRG_Stunner extends KFDT_Explosive
	abstract
	hidedropdown;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=3000 //5000 //20000
	GibImpulseScale=0.15
	KDeathUpKick=1000
	KDeathVel=300

	StunPower=200
	StumblePower=100

	//Perk
	ModifierPerkList(0)=class'KFPerk_SWAT'	
	WeaponDef=class'KFWeapDef_HRG_Stunner'
}
