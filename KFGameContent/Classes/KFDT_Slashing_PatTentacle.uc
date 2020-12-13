//=============================================================================
// KFDT_Slashing_PatTentacle
//=============================================================================
// Slashing damage from Patriarch tentacle attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing_PatTentacle extends KFDT_Slashing
	abstract
	hidedropdown;

`include(KFGame/KFGameDialog.uci)

static function int GetKillerDialogID()
{
	return `Patty_TentacleKill;
}

defaultproperties
{
    bExtraMomentumZ=true

	KDamageImpulse=1200
	KDeathUpKick=50
	KDeathVel=650
}