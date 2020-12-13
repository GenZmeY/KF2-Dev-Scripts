//=============================================================================
// KFDT_Slashing_Patriarch
//=============================================================================
// Slashing damage from Patriarch
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_Patriarch extends KFDT_Slashing
	abstract
	hidedropdown;

`include(KFGame/KFGameDialog.uci)

static function int GetKillerDialogID()
{
	return `BOSS_KillBase;
}

defaultproperties
{
    bExtraMomentumZ=true

	KDamageImpulse=1000
	KDeathUpKick=200
	KDeathVel=800

}