//=============================================================================
// KFDT_Explosive_HuskCannonImpact
//=============================================================================
// Explosive damage type for the Husk Cannon direct hit
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Explosive_HuskCannonImpact extends KFDT_Ballistic_Shell
    abstract
    hidedropdown;

defaultproperties
{
	bNoInstigatorDamage=false
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=1500//1500 //2500 //1500
	KDamageImpulse=900 //900
	GibImpulseScale=0.15 //0.15
	KDeathUpKick=500//225  //500 //1500
	KDeathVel=500 //225 //500

	//Perk
	ModifierPerkList(0)=class'KFPerk_Firebug'
    ModifierPerkList(1)=class'KFPerk_Demolitionist'
	
	WeaponDef=class'KFWeapDef_HuskCannon'
}
 