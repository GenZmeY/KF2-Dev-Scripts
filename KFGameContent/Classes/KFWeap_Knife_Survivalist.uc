//=============================================================================
// KFWeap_Knife_Berserker
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Knife_Survivalist extends KFWeap_Edged_Knife;

defaultproperties
{
	// Content
	PackageKey="Survival_Knife"
	FirstPersonMeshName="WEP_1P_Survival_Knife_MESH.Wep_1stP_SurvivalKnife_Rig"
	AttachmentArchetypeName="WEP_SurvivalistKnife_ARCH.Wep_SurvivalistKnife_3P"

	Begin Object Name=FirstPersonMesh
	AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object
	
	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_Survivalist'
	WeaponSelectTexture=Texture2D'Wep_UI_Survival_Knife_TEX.UI_WeaponSelect_SurvivalistKnife'

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_Knife_Survivalist'
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_KnifeHeavy_Survivalist'
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_KnifeStab_Survivalist'
}