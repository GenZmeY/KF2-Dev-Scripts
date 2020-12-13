//=============================================================================
// KFDT_Explosive_HRGWinterbite
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_HRGWinterbite extends KFDT_Freeze
	abstract;

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	GibImpulseScale=0.15
	KDeathUpKick=700
	KDeathVel=300

	StumblePower=25
	FreezePower=20 //25

	//Prevent self-inflicted damage.
	bNoInstigatorDamage=true

	//Perk
	ModifierPerkList(0)=class'KFPerk_Gunslinger'

	WeaponDef=class'KFWeapDef_HRGWinterbite'
}
