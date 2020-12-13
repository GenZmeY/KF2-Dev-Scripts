//=============================================================================
// KFDT_Bludgeon_Matriarch
//=============================================================================
// Bludgeon damage from Matriarch
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_Matriarch extends KFDT_Bludgeon
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
	KDeathUpKick=300
	KDeathVel=950

	bAllowAIDoorDestruction=true
}