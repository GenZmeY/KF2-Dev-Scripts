//=============================================================================
// KFWeaponDefintion
//=============================================================================
// A lightweight container for basic weapon properties that can be safely
// accessed without a weapon actor (UI, remote clients).
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFWeapDef_Random extends KFWeaponDefinition
	abstract;

DefaultProperties
{
	ImagePath="wep_ui_shared_tex.UI_WeaponSelect_QuestionMark"
	WeaponClassPath="KFGameContent.KFWeap_Random"
}
