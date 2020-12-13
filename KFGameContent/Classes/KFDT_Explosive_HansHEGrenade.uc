//=============================================================================
// KFDT_Explosive_HansHEGrenade
//=============================================================================
// Explosive damage type for Hans' high explosive grenades
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Explosive_HansHEGrenade extends KFDT_Explosive_HEGrenade
	abstract
	hidedropdown;

`include(KFGame/KFGameDialog.uci)

static function int GetKillerDialogID()
{
	return `HANS_KillNade;
}

defaultproperties
{
    // Don't let Hans damage himself with his grenade
    bNoInstigatorDamage=true
}
