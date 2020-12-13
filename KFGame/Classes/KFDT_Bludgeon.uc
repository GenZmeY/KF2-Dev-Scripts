//=============================================================================
// KFDT_Bludgeon
//=============================================================================
// Any form of blunt force such as a hammer
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Bludgeon extends KFDamageType
	abstract;

`include(KFGameDialog.uci)

/** Returns ID of dialog event for killer to speak after killing a zed using this damage type */
static function int GetKillerDialogID()
{
	return `KILL_Blunt;
}

defaultproperties
{
	KDamageImpulse=400
	KDeathVel=200

	GoreDamageGroup=DGT_MeleeBludgeon
	EffectGroup=FXG_Bludgeon

	BodyWoundDecalMaterials[0]=MaterialInstanceConstant'FX_Impacts_MAT.FX_Blunted_Impact_Flesh_Decal_01_MIC'
}
