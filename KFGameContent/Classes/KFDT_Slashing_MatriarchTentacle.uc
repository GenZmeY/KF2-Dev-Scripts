//=============================================================================
// KFDT_Slashing_MatriarchTentacle
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_MatriarchTentacle extends KFDT_Slashing
	abstract
	hidedropdown;

`include(KFGame/KFGameDialog.uci)

static function int GetKillerDialogID()
{
	return `MATTY_ScorpionWhipKill;
}

defaultproperties
{
    bExtraMomentumZ=true

	KDamageImpulse=1200
	KDeathUpKick=50
	KDeathVel=650
}