//=============================================================================
// KFDT_Bludgeon_Patriarch
//=============================================================================
// Bludgeon damage from Patriarch
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon_Patriarch extends KFDT_Bludgeon
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