//=============================================================================
// KFDT_Bludgeon_BloatKing
//=============================================================================
// Bludgeon damage from Bloat King
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_BloatKing extends KFDT_Bludgeon
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