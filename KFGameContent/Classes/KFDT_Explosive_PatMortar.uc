//=============================================================================
// KFDT_Explosive_PatMortar
//=============================================================================
// Explosive damage type for the Patriarch missile
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Explosive_PatMortar extends KFDT_Explosive
	abstract
	hidedropdown;

`include(KFGame/KFGameDialog.uci)

static function int GetKillerDialogID()
{
	return `PATTY_MortarKill;
}

defaultproperties
{
	bShouldSpawnPersistentBlood=true

	// physics impact
	RadialDamageImpulse=1000
	KDeathUpKick=900
	KDeathVel=900
}