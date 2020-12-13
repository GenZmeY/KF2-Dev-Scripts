//=============================================================================
// KFDT_Bludgeon_PatriarchKick
//=============================================================================
// Mech leg kick bludgeon damage from Patriarch
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFDT_Bludgeon_PatriarchKick extends KFDT_Bludgeon_Patriarch
	abstract;

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
	OverrideImpactSound=AkEvent'WW_Skin_Impacts.Play_Player_Damage_Pat_Leg_2D'

}