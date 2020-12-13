//=============================================================================
// KFDT_Sonic
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Sonic extends KFDamageType
	abstract;

`include(KFGameDialog.uci)

/** Returns ID of dialog event for damagee to speak after getting damaged by a zed using this damage type */
static function int GetDamageeDialogID()
{
	return `DAMP_Sonic;
}

defaultproperties
{
	bArmorStops=false
	bAllowAIDoorDestruction=true

	ScreenMaterialName=Effect_Siren

    // Obliteration
	bCanObliterate=false
	ObliterationHealthThreshold=-1
	ObliterationDamageThreshold=3
	
	KDamageImpulse=1400
	KDeathUpKick=500
	KDeathVel=700
}