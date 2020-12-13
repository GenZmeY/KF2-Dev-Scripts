//=============================================================================
// KFDT_Toxic_HansGrenade
//=============================================================================
// Hans Nerve Gas Grenade DamageType
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFDT_Toxic_HansGrenade extends KFDT_Toxic
	abstract
	hidedropdown;

`include(KFGame/KFGameDialog.uci)

static function int GetKillerDialogID()
{
	return `HANS_KillGas;
}

defaultproperties
{
	// override DoT from KFDT_Toxic
	DoT_Type=DOT_None

    // Don't let Hans damage himself with his grenade
    bNoInstigatorDamage=true
}
